--!nonstrict
--[[
	THE HORIZON — Inventory & Crafting server
	ModuleScript named "HorizonInventoryService" in ServerScriptService.
	Started by the Script "HorizonInventoryServer" (same folder).

	The server owns everything:
	  • each player's items (counts), item order and hotbar
	  • the craft queue and its timing (materials are taken when each item STARTS)
	  • equipping the Tool for the selected hotbar slot
	The client only ASKS (craft / clear queue / select slot) and draws what the
	server sends back. It can never give itself items.

	Other server scripts (gathering, building, loot …) use:
	  local Inventory = require(game.ServerScriptService.HorizonInventoryService)
	  Inventory.AddItem(player, "stone", 3)
	  Inventory.RemoveItem(player, "planks", 2)   --> true / false
	  Inventory.GetCount(player, "rope")

	Not done yet: SAVING. Items reset when the player leaves. Saving comes with
	the per-world save system (it needs the world id).
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

local Items = require(ReplicatedStorage:WaitForChild("HorizonItems"))
local ITEMS = Items.ITEMS

local CONFIG = {
	RemotesFolder = "HorizonRemotes", -- created in ReplicatedStorage
	-- Tool templates: a Folder in ServerStorage. Name each Tool by its item id
	-- ("stone_axe") or its display name ("Stone Axe"). Missing = nothing in hand.
	ToolsFolder = "HorizonTools",
	-- Crafted items from these categories go into the first free hotbar slot
	AutoHotbarCategories = { Tools = true },
	-- Anti-spam: actions per second per player (extra ones are ignored)
	ActionsPerSecond = 12,
	ActionBurst = 20,
	-- Studio ONLY: test items so you can try crafting before gathering exists.
	-- Live servers start players with nothing.
	StudioStarterItems = {
		{ "planks", 12 }, { "stone", 9 }, { "leaves", 14 }, { "rope", 3 }, { "fiber", 6 }, { "scrap", 2 },
		{ "hide", 3 }, { "cup_clean", 1 }, { "stone_axe", 1 }, { "torch", 1 }, { "cup_sea", 1 },
	},
	StudioStarterHotbar = { "stone_axe", "torch", "cup_sea" },
}

local Service = {}
local playerData = {} -- [Player] = data
local stateRemote, actionRemote
local started = false

local function now()
	return workspace:GetServerTimeNow()
end

--------------------------------------------------------------------------------
-- STATE → CLIENT
--------------------------------------------------------------------------------
local function buildState(data, crafted)
	local queue = {}
	for index, job in ipairs(data.queue) do
		queue[index] = { id = job.id, count = job.count, total = job.total }
	end
	return {
		inv = data.inv,
		order = data.order,
		hotbar = data.hotbar, -- "" = empty slot
		selected = data.selected,
		queue = queue,
		unit = data.unit and { startedAt = data.unit.startedAt, dur = data.unit.dur } or nil,
		crafted = crafted, -- { id, total, done } when an item just finished
	}
end

local function sync(data, crafted)
	if data.player.Parent then
		stateRemote:FireClient(data.player, buildState(data, crafted))
	end
end

--------------------------------------------------------------------------------
-- TOOLS (hotbar → hand)
--------------------------------------------------------------------------------
local function findToolTemplate(id)
	local folder = ServerStorage:FindFirstChild(CONFIG.ToolsFolder)
	if not folder then
		return nil
	end
	local tool = folder:FindFirstChild(id) or folder:FindFirstChild(ITEMS[id].Name)
	if tool and tool:IsA("Tool") then
		return tool
	end
	return nil
end

local function unequip(data)
	if data.tool then
		data.tool:Destroy()
		data.tool = nil
		data.toolId = nil
	end
end

local function equipSelected(data)
	local id = data.hotbar[data.selected]
	if id == "" or (data.inv[id] or 0) < 1 then
		unequip(data)
		return
	end
	local character = data.player.Character
	if data.tool and data.toolId == id and character and data.tool.Parent == character then
		return
	end
	unequip(data)
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local template = findToolTemplate(id)
	if not humanoid or humanoid.Health <= 0 or not template then
		return
	end
	local tool = template:Clone()
	tool.CanBeDropped = false
	tool:SetAttribute("HorizonItem", id)
	data.tool = tool
	data.toolId = id
	humanoid:EquipTool(tool)
end

--------------------------------------------------------------------------------
-- INVENTORY
--------------------------------------------------------------------------------
local function isCount(n)
	return type(n) == "number" and n == n and n >= 1 and n < 1e6 and math.floor(n) == n
end

local function addRaw(data, id, amount)
	if not data.inv[id] then
		data.inv[id] = 0
		table.insert(data.order, id)
	end
	data.inv[id] += amount
	-- new tools go into the first free hotbar slot
	local category = Items.categoryOf(id)
	if category and CONFIG.AutoHotbarCategories[category] and not table.find(data.hotbar, id) then
		local free = table.find(data.hotbar, "")
		if free then
			data.hotbar[free] = id
		end
	end
end

local function removeRaw(data, id, amount)
	local have = data.inv[id] or 0
	if have < amount then
		return false
	end
	if have == amount then
		data.inv[id] = nil
		local at = table.find(data.order, id)
		if at then
			table.remove(data.order, at)
		end
		for slot, hotId in ipairs(data.hotbar) do
			if hotId == id then
				data.hotbar[slot] = ""
			end
		end
		if data.toolId == id then
			unequip(data)
		end
	else
		data.inv[id] = have - amount
	end
	return true
end

function Service.AddItem(player, id, amount)
	local data = playerData[player]
	amount = amount or 1
	if not data or not ITEMS[id] or not isCount(amount) then
		return false
	end
	addRaw(data, id, amount)
	equipSelected(data)
	sync(data)
	return true
end

function Service.RemoveItem(player, id, amount)
	local data = playerData[player]
	amount = amount or 1
	if not data or not ITEMS[id] or not isCount(amount) then
		return false
	end
	local ok = removeRaw(data, id, amount)
	if ok then
		sync(data)
	end
	return ok
end

function Service.GetCount(player, id)
	local data = playerData[player]
	return data and data.inv[id] or 0
end

--------------------------------------------------------------------------------
-- CRAFTING
--------------------------------------------------------------------------------
-- materials still needed by queued items that haven't started yet
local function reserved(data)
	local need = {}
	for index, job in ipairs(data.queue) do
		local units = job.count - ((index == 1 and data.unit) and 1 or 0)
		for _, mat in ipairs(job.mats) do
			need[mat[1]] = (need[mat[1]] or 0) + mat[2] * units
		end
	end
	return need
end

local function maxCraftable(data, recipe)
	if not recipe.mats then
		return 0
	end
	local need = reserved(data)
	local n = math.huge
	for _, mat in ipairs(recipe.mats) do
		local free = (data.inv[mat[1]] or 0) - (need[mat[1]] or 0)
		n = math.min(n, math.floor(free / mat[2]))
	end
	if n == math.huge then
		return 0
	end
	return math.max(0, n)
end

-- start the next item if nothing is crafting; materials are taken here
local function startNextUnit(data)
	while not data.unit and data.queue[1] do
		local job = data.queue[1]
		local ok = true
		for _, mat in ipairs(job.mats) do
			if (data.inv[mat[1]] or 0) < mat[2] then
				ok = false
				break
			end
		end
		if ok then
			for _, mat in ipairs(job.mats) do
				removeRaw(data, mat[1], mat[2])
			end
			data.unit = { startedAt = now(), dur = job.dur }
		else
			-- materials went missing (used elsewhere): drop this entry
			table.remove(data.queue, 1)
		end
	end
end

local function handleCraft(data, recipeId, amount)
	if type(recipeId) ~= "string" then
		return
	end
	local recipe = Items.findRecipe(recipeId)
	if not recipe or not recipe.mats then
		return
	end
	local maxN = maxCraftable(data, recipe)
	local n
	if amount == "all" then
		n = maxN
	elseif isCount(amount) then
		n = math.min(amount, maxN)
	else
		return
	end
	if n < 1 then
		sync(data) -- client was out of date; send the truth
		return
	end
	local last = data.queue[#data.queue]
	if last and last.id == recipe.id then
		last.count += n
		last.total += n
	elseif #data.queue < Items.QUEUE_MAX then
		table.insert(data.queue, {
			id = recipe.id,
			dur = Items.craftTime(recipe.id),
			mats = recipe.mats,
			count = n,
			total = n,
		})
	else
		sync(data)
		return
	end
	startNextUnit(data)
	sync(data)
end

-- clears everything except the item currently being crafted
local function handleClear(data)
	if #data.queue == 0 then
		return
	end
	if data.unit then
		local first = data.queue[1]
		first.total = first.total - first.count + 1
		first.count = 1
		data.queue = { first }
	else
		data.queue = {}
	end
	sync(data)
end

local function handleHotbar(data, index)
	if not isCount(index) or index > Items.HOTBAR_SLOTS then
		return
	end
	data.selected = index
	equipSelected(data)
end

local function step()
	local t = now()
	for _, data in pairs(playerData) do
		local unit = data.unit
		if unit and t >= unit.startedAt + unit.dur then
			local job = data.queue[1]
			data.unit = nil
			addRaw(data, job.id, 1)
			job.count -= 1
			if job.count <= 0 then
				table.remove(data.queue, 1)
			end
			startNextUnit(data)
			equipSelected(data)
			sync(data, { id = job.id, total = job.total, done = #data.queue == 0 })
		end
	end
end

--------------------------------------------------------------------------------
-- PLAYERS + REMOTES
--------------------------------------------------------------------------------
local function allowAction(data)
	local t = os.clock()
	data.tokens = math.min(CONFIG.ActionBurst, data.tokens + (t - data.tokenTime) * CONFIG.ActionsPerSecond)
	data.tokenTime = t
	if data.tokens < 1 then
		return false
	end
	data.tokens -= 1
	return true
end

local function onPlayerAdded(player)
	if playerData[player] then
		return
	end
	local hotbar = table.create(Items.HOTBAR_SLOTS, "")
	local data = {
		player = player,
		inv = {},
		order = {},
		hotbar = hotbar,
		selected = 1,
		queue = {},
		unit = nil,
		tool = nil,
		toolId = nil,
		tokens = CONFIG.ActionBurst,
		tokenTime = os.clock(),
	}
	playerData[player] = data

	if RunService:IsStudio() then
		for _, entry in ipairs(CONFIG.StudioStarterItems) do
			if ITEMS[entry[1]] then
				addRaw(data, entry[1], entry[2])
			end
		end
		table.clear(hotbar)
		for slot = 1, Items.HOTBAR_SLOTS do
			local id = CONFIG.StudioStarterHotbar[slot]
			hotbar[slot] = (id and data.inv[id]) and id or ""
		end
	end

	local function onCharacter(character)
		data.tool = nil
		data.toolId = nil
		character:WaitForChild("Humanoid", 10)
		if playerData[player] == data then
			equipSelected(data)
		end
	end
	player.CharacterAdded:Connect(onCharacter)
	if player.Character then
		task.spawn(onCharacter, player.Character)
	end
	sync(data)
end

local function onPlayerRemoving(player)
	local data = playerData[player]
	if data then
		unequip(data)
		playerData[player] = nil
	end
end

function Service.Start()
	if started then
		return
	end
	started = true

	local folder = ReplicatedStorage:FindFirstChild(CONFIG.RemotesFolder)
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = CONFIG.RemotesFolder
		folder.Parent = ReplicatedStorage
	end
	local function remote(name)
		local r = folder:FindFirstChild(name)
		if not r then
			r = Instance.new("RemoteEvent")
			r.Name = name
			r.Parent = folder
		end
		return r
	end
	actionRemote = remote("InventoryAction") -- client → server: ("craft", id, amount|"all") / ("clear") / ("hotbar", index) / ("sync")
	stateRemote = remote("InventoryState") -- server → client: full inventory + queue state

	actionRemote.OnServerEvent:Connect(function(player, action, a, b)
		local data = playerData[player]
		if not data or type(action) ~= "string" or not allowAction(data) then
			return
		end
		if action == "craft" then
			handleCraft(data, a, b)
		elseif action == "clear" then
			handleClear(data)
		elseif action == "hotbar" then
			handleHotbar(data, a)
		elseif action == "sync" then
			sync(data)
		end
	end)

	Players.PlayerAdded:Connect(onPlayerAdded)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(onPlayerAdded, player)
	end
	RunService.Heartbeat:Connect(step)
end

return Service
