--!nonstrict
--[[
	THE HORIZON — Inventory, Crafting & Hotbar UI  (client)
	Put this LocalScript in StarterPlayer > StarterPlayerScripts.

	What it does
	  • Inventory panel (5 armour slots + 30-slot backpack)
	  • Crafting panel (Tools / Resources / Consumables, item strip, preview,
	    materials, Craft / All, queue + Clear queue)
	  • 8-slot hotbar (keys 1–8), crosshair, TAB button
	  • Crafting progress at the top-right that slides in, fills once per item,
	    counts the amount down (100x → 99x …) and slides out when done

	IMPORTANT
	  This is the UI with a LOCAL DEMO inventory so you can test it in Studio.
	  The client must never give itself items. When you hook it up, replace the
	  body of `requestCraft` with a call to your server, and feed `inventory`
	  from server data. Search for "SERVER HOOK".

	  Don't run this together with the old SurvivalCraftingUI / SurvivalInventoryUI
	  scripts — they would both draw on screen.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local existing = playerGui:FindFirstChild("HorizonInventoryUI")
if existing then
	existing:Destroy()
end

-- Our own hotbar replaces Roblox's default backpack bar.
pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
end)
-- Roblox's player list also opens with Tab. Uncomment if it gets in the way:
-- pcall(function() StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false) end)

--------------------------------------------------------------------------------
-- CONFIG
--------------------------------------------------------------------------------
local CONFIG = {
	ToggleKey = Enum.KeyCode.Tab,
	Accent = Color3.fromRGB(233, 185, 73),
	Text = Color3.fromRGB(237, 232, 220),
	DarkText = Color3.fromRGB(27, 26, 20),
	Missing = Color3.fromRGB(244, 164, 124),
	PanelColor = Color3.fromRGB(16, 21, 19),
	-- The HTML uses 0.32 over a dark scene. The real game world is bright, so the
	-- panels need to be more solid to look as dark as the preview.
	PanelTransparency = 0.15,
	FontEnum = Enum.Font.PatrickHand,
	-- Roblox TextSize = the font's full line height; HTML font-size = its em size.
	-- Patrick Hand's line height is 1.354 em, so this makes text match the HTML.
	FontScale = 1.354,
	CraftCompleteSound = "rbxassetid://100545760361878",
	QueueMax = 8, -- different items in the queue at once
	BackpackSlots = 30,
	BarResetSpeed = 35, -- how fast the bar slides back to empty between items (higher = faster)
	BlurSize = 12, -- background blur while the menu is open
	DimTransparency = 0.45, -- dark layer behind the menu (darker than the HTML because the game world is bright)
	-- Equipment slot icons. Upload the PNGs in design/equipment_icons/ as Decals
	-- and paste the rbxassetid:// ids here. Empty = shows the slot name instead.
	EquipmentIcons = {
		Helmet = "",
		Chest = "",
		Gloves = "",
		Legs = "",
		Boots = "",
	},
	-- everything is laid out on a 1280 x 720 design screen (same as the HTML preview)
	DesignWidth = 1280,
	DesignHeight = 720,
}
local FONT = Font.fromEnum(CONFIG.FontEnum)
-- HTML font-size (px) → Roblox TextSize
local function ts(size)
	return math.floor(size * CONFIG.FontScale + 0.5)
end

--------------------------------------------------------------------------------
-- ITEMS (images from your old crafting script)
--------------------------------------------------------------------------------
local ITEMS = {
	planks = { Name = "Planks", Image = "rbxassetid://78387750873126" },
	stone = { Name = "Stone", Image = "rbxassetid://127351259030040" },
	leaves = { Name = "Leaves", Image = "rbxassetid://94252892154991" },
	rope = { Name = "Rope", Image = "rbxassetid://94728420315409", Desc = "A simple binding material made from leaves." },
	fiber = { Name = "Fiber", Image = "rbxassetid://85899584797851" },
	scrap = { Name = "Scrap", Image = "rbxassetid://123247338574784" },
	plastic = { Name = "Plastic", Image = "rbxassetid://126538877519520" },
	nails = { Name = "Nails", Image = "rbxassetid://100720163739756", Desc = "Basic metal fasteners used in construction." },
	hide = { Name = "Hide", Image = "rbxassetid://137106848150031" },
	cup_clean = { Name = "Clean Water Cup", Image = "rbxassetid://75855735142648", Desc = "Safe drinking water." },
	cup_sea = { Name = "Seawater Cup", Image = "rbxassetid://94755334875949" },
	stone_axe = { Name = "Stone Axe", Image = "rbxassetid://73396827796121", Desc = "A basic chopping tool for cutting trees and gathering planks." },
	stone_pickaxe = { Name = "Stone Pickaxe", Image = "rbxassetid://103209016597189", Desc = "A basic mining tool for breaking stone and gathering ore." },
	stone_spear = { Name = "Stone Spear", Image = "rbxassetid://131953404883594", Desc = "A simple spear for hunting and defending yourself." },
	wooden_club = { Name = "Wooden Club", Image = "rbxassetid://77142435102160", Desc = "A rough wooden club for close combat." },
	stone_sword = { Name = "Stone Sword", Image = "rbxassetid://99964958308218", Desc = "A sharper stone weapon for stronger melee attacks." },
	torch = { Name = "Torch", Image = "rbxassetid://128672619441958", Desc = "A handheld light for exploring dark areas." },
	bow = { Name = "Bow", Image = "rbxassetid://103839860687597", Desc = "A wooden bow for firing arrows." },
	stone_arrows = { Name = "Stone Arrows", Image = "rbxassetid://87510233891000", Desc = "Stone-tipped arrows for a bow." },
	wooden_shield = { Name = "Wooden Shield", Image = "rbxassetid://104624286311499", Desc = "A wooden shield for blocking attacks." },
	building_hammer = { Name = "Building Hammer", Image = "rbxassetid://85234448517206", Desc = "A tool for planning and placing structures." },
	map = { Name = "Map", Image = "", Desc = "A hide map for finding your way." },
	compass = { Name = "Compass", Image = "", Desc = "A compass for finding your direction." },
}

-- mats = nil means "Recipe not set yet"
local RECIPES = {
	Tools = {
		{ id = "stone_pickaxe", mats = { { "planks", 4 }, { "stone", 4 }, { "rope", 2 } } },
		{ id = "stone_axe", mats = { { "planks", 3 }, { "stone", 4 }, { "rope", 2 } } },
		{ id = "stone_spear", mats = { { "planks", 3 }, { "stone", 1 }, { "rope", 1 } } },
		{ id = "wooden_club", mats = { { "planks", 3 }, { "rope", 1 } } },
		{ id = "stone_sword", mats = { { "planks", 3 }, { "stone", 5 }, { "rope", 2 } } },
		{ id = "torch", mats = { { "planks", 1 }, { "leaves", 4 }, { "rope", 1 } } },
		{ id = "bow", mats = nil },
		{ id = "stone_arrows", mats = nil },
		{ id = "wooden_shield", mats = { { "planks", 6 }, { "rope", 2 }, { "hide", 1 } } },
		{ id = "building_hammer", mats = nil },
		{ id = "map", mats = { { "hide", 2 }, { "fiber", 2 } } },
		{ id = "compass", mats = { { "scrap", 3 }, { "plastic", 1 } } },
	},
	Resources = {
		{ id = "rope", mats = { { "leaves", 3 } } },
		{ id = "nails", mats = { { "scrap", 1 } } },
	},
	Consumables = {
		{ id = "cup_clean", mats = nil },
	},
}
local CATEGORY_ORDER = { "Tools", "Resources", "Consumables" }

-- Seconds per item. Placeholders — set your real times here.
local CRAFT_TIME = {
	stone_pickaxe = 4, stone_axe = 4, stone_spear = 3, wooden_club = 2.5, stone_sword = 5,
	torch = 2, wooden_shield = 4, map = 3, compass = 3, rope = 1.5, nails = 1,
}

--------------------------------------------------------------------------------
-- DEMO STATE (SERVER HOOK: replace with real player data)
--------------------------------------------------------------------------------
local inventory = { planks = 12, stone = 9, leaves = 14, rope = 3, fiber = 6, scrap = 2, hide = 3, cup_clean = 1 }
local inventoryOrder = { "planks", "stone", "leaves", "rope", "fiber", "scrap", "hide", "cup_clean" }
local hotbarItems = { "stone_axe", "torch", "cup_sea", false, false, false, false, false }

local selectedCategory = "Tools"
local selectedRecipe = "stone_pickaxe"
local selectedSlot = nil
local selectedHotbar = 1
local isOpen = false

-- crafting queue: { id, dur, mats, count, total }
local queue = {}
local unitStarted = false
local unitElapsed = 0
local finishing = nil -- { id, total } while the "Crafted" state is shown

--------------------------------------------------------------------------------
-- HELPERS
--------------------------------------------------------------------------------
local function new(className, props, parent)
	local object = Instance.new(className)
	for key, value in pairs(props) do
		object[key] = value
	end
	if parent then
		object.Parent = parent
	end
	return object
end

local function corner(parent, radius)
	return new("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
end

local function stroke(parent, color, thickness, transparency)
	return new("UIStroke", {
		Color = color,
		Thickness = thickness,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, parent)
end

local function text(parent, props)
	local label = new("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		FontFace = FONT,
		TextColor3 = CONFIG.Text,
		TextSize = 18,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Text = "",
	}, parent)
	for key, value in pairs(props) do
		label[key] = value
	end
	label.TextSize = ts(props.TextSize or 18)
	return label
end

local function textButton(parent, props)
	local button = new("TextButton", {
		AutoButtonColor = false,
		BorderSizePixel = 0,
		FontFace = FONT,
		TextColor3 = CONFIG.Text,
		TextSize = 18,
		Text = "",
	}, parent)
	for key, value in pairs(props) do
		button[key] = value
	end
	button.TextSize = ts(props.TextSize or 18)
	return button
end

local function tween(object, duration, props, style, direction)
	local t = TweenService:Create(
		object,
		TweenInfo.new(duration, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out),
		props
	)
	t:Play()
	return t
end

local function textWidth(str, size)
	return TextService:GetTextSize(str, ts(size), CONFIG.FontEnum, Vector2.new(2000, 200)).X
end

local function panel(parent, name, x, y, w, h)
	local frame = new("Frame", {
		Name = name,
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(w, h),
		BackgroundColor3 = CONFIG.PanelColor,
		BackgroundTransparency = CONFIG.PanelTransparency,
		BorderSizePixel = 0,
	}, parent)
	corner(frame, 14)
	return frame
end

-- An item picture; falls back to the item name when there is no image yet.
local function itemIcon(parent, size, position, anchor)
	local image = new("ImageLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(size, size),
		Position = position,
		AnchorPoint = anchor or Vector2.new(0.5, 0.5),
		ScaleType = Enum.ScaleType.Fit,
		Image = "",
	}, parent)
	local fallback = text(image, {
		Size = UDim2.fromScale(1, 1),
		TextXAlignment = Enum.TextXAlignment.Center,
		TextWrapped = true,
		TextSize = math.max(12, math.floor(size / 3.6)),
		Visible = false,
	})
	return {
		Image = image,
		Set = function(itemId)
			local item = itemId and ITEMS[itemId]
			local hasImage = item and item.Image ~= "" or false
			image.Image = hasImage and item.Image or ""
			fallback.Text = item and item.Name or ""
			fallback.Visible = item ~= nil and not hasImage
			image.Visible = item ~= nil
		end,
		SetFaded = function(faded)
			image.ImageTransparency = faded and 0.55 or 0
			fallback.TextTransparency = faded and 0.55 or 0
		end,
	}
end

--------------------------------------------------------------------------------
-- INVENTORY / CRAFT LOGIC
--------------------------------------------------------------------------------
local function findRecipe(id)
	for _, list in pairs(RECIPES) do
		for _, recipe in ipairs(list) do
			if recipe.id == id then
				return recipe
			end
		end
	end
	return nil
end

local function currentRecipe()
	return findRecipe(selectedRecipe) or RECIPES[selectedCategory][1]
end

-- materials still needed for queued items that haven't started yet
local function reserved()
	local need = {}
	for index, job in ipairs(queue) do
		local units = job.count - ((index == 1 and unitStarted) and 1 or 0)
		for _, mat in ipairs(job.mats) do
			need[mat[1]] = (need[mat[1]] or 0) + mat[2] * units
		end
	end
	return need
end

local function available(id)
	return (inventory[id] or 0) - (reserved()[id] or 0)
end

local function maxCraftable(recipe)
	if not recipe.mats then
		return 0
	end
	local n = math.huge
	for _, mat in ipairs(recipe.mats) do
		n = math.min(n, math.floor(available(mat[1]) / mat[2]))
	end
	if n == math.huge then
		return 0
	end
	return math.max(0, n)
end

local function canQueue(recipe)
	local last = queue[#queue]
	return (last ~= nil and last.id == recipe.id) or #queue < CONFIG.QueueMax
end

local function addItem(id, amount)
	if not inventory[id] then
		inventory[id] = 0
	end
	if not table.find(inventoryOrder, id) then
		table.insert(inventoryOrder, id)
	end
	inventory[id] += amount
end

--------------------------------------------------------------------------------
-- GUI ROOT
--------------------------------------------------------------------------------
local gui = new("ScreenGui", {
	Name = "HorizonInventoryUI",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 10,
}, playerGui)

local craftSound = new("Sound", { Name = "CraftComplete", SoundId = CONFIG.CraftCompleteSound }, gui)

local dim = new("Frame", {
	Name = "Dim",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.fromRGB(6, 9, 8),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Visible = false,
}, gui)

-- frees the mouse in first person while the menu is open
local modal = textButton(gui, {
	Name = "MouseUnlock",
	Size = UDim2.fromOffset(0, 0),
	BackgroundTransparency = 1,
	Modal = true,
	Visible = false,
})

local blur = Lighting:FindFirstChild("HorizonInventoryBlur") or new("BlurEffect", { Name = "HorizonInventoryBlur" }, Lighting)
blur.Size = 0

-- the two panels together are 1124 x 560; this frame is scaled to fit the safe area
local MENU_W, MENU_H = 1124, 560
local canvas = new("Frame", {
	Name = "Menu",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(MENU_W, MENU_H),
	BackgroundTransparency = 1,
}, gui)
local canvasScale = new("UIScale", {}, canvas)

local panels = new("Frame", {
	Name = "Panels",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Visible = false,
}, canvas)
local panelsScale = new("UIScale", { Scale = 0.97 }, panels)

local hudScales = {}
local function hudScale(parent)
	local scale = new("UIScale", {}, parent)
	table.insert(hudScales, scale)
	return scale
end

--------------------------------------------------------------------------------
-- INVENTORY PANEL
--------------------------------------------------------------------------------
local invPanel = panel(panels, "InventoryPanel", 0, 0, 464, 560)
text(invPanel, { Position = UDim2.fromOffset(20, 20), Size = UDim2.fromOffset(300, 32), Text = "Inventory", TextSize = 30 })
local usedLabel = text(invPanel, {
	Position = UDim2.fromOffset(20, 20),
	Size = UDim2.fromOffset(424, 32),
	TextSize = 19,
	TextTransparency = 0.3,
	TextXAlignment = Enum.TextXAlignment.Right,
})
text(invPanel, { Position = UDim2.fromOffset(20, 64), Size = UDim2.fromOffset(200, 20), Text = "Equipment", TextSize = 17, TextTransparency = 0.3 })

-- dashed outline (Roblox has no dashed strokes, so it's built from small bars)
local function dashedBorder(parent, size, color, transparency)
	local dash, gap, thick, inset = 6, 6, 2, 8
	local run = size - inset * 2
	local count = math.floor((run + gap) / (dash + gap))
	local start = inset + (run - (count * dash + (count - 1) * gap)) / 2
	for i = 0, count - 1 do
		local at = start + i * (dash + gap)
		for _, spec in ipairs({
			{ at, 0, dash, thick },
			{ at, size - thick, dash, thick },
			{ 0, at, thick, dash },
			{ size - thick, at, thick, dash },
		}) do
			new("Frame", {
				Position = UDim2.fromOffset(spec[1], spec[2]),
				Size = UDim2.fromOffset(spec[3], spec[4]),
				BackgroundColor3 = color,
				BackgroundTransparency = transparency,
				BorderSizePixel = 0,
			}, parent)
		end
	end
end

for index, slotName in ipairs({ "Helmet", "Chest", "Gloves", "Legs", "Boots" }) do
	local slot = textButton(invPanel, {
		Name = slotName .. "Slot",
		Position = UDim2.fromOffset(20 + (index - 1) * 72, 90),
		Size = UDim2.fromOffset(64, 64),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.96,
	})
	corner(slot, 8)
	dashedBorder(slot, 64, CONFIG.Text, 0.82)
	local image = CONFIG.EquipmentIcons[slotName]
	if image and image ~= "" then
		new("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(36, 36),
			BackgroundTransparency = 1,
			Image = image,
			ImageTransparency = 0.7,
		}, slot)
	else
		text(slot, {
			Size = UDim2.fromScale(1, 1),
			Text = slotName,
			TextSize = 14,
			TextTransparency = 0.7,
			TextXAlignment = Enum.TextXAlignment.Center,
		})
	end
end

text(invPanel, { Position = UDim2.fromOffset(20, 168), Size = UDim2.fromOffset(150, 20), Text = "Backpack", TextSize = 17, TextTransparency = 0.3 })
local invInfo = text(invPanel, {
	Position = UDim2.fromOffset(170, 168),
	Size = UDim2.fromOffset(274, 20),
	TextSize = 17,
	TextXAlignment = Enum.TextXAlignment.Right,
	Text = "Click an item",
})

local backpackSlots = {}
for index = 1, CONFIG.BackpackSlots do
	local column = (index - 1) % 6
	local row = math.floor((index - 1) / 6)
	local slot = textButton(invPanel, {
		Name = "Slot" .. index,
		Position = UDim2.fromOffset(20 + column * 72, 194 + row * 72),
		Size = UDim2.fromOffset(64, 64),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.93,
	})
	corner(slot, 8)
	local outline = stroke(slot, CONFIG.Accent, 2, 1)
	local icon = itemIcon(slot, 52, UDim2.fromScale(0.5, 0.5))
	local count = text(slot, {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -6, 1, -2),
		Size = UDim2.fromOffset(40, 18),
		TextSize = 17,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 2,
	})
	local pop = new("UIScale", {}, slot)
	backpackSlots[index] = { Button = slot, Stroke = outline, Icon = icon, Count = count, Item = nil, Pop = pop }
end

--------------------------------------------------------------------------------
-- CRAFTING PANEL
--------------------------------------------------------------------------------
local craftPanel = panel(panels, "CraftingPanel", 484, 0, 640, 560)
text(craftPanel, { Position = UDim2.fromOffset(20, 20), Size = UDim2.fromOffset(200, 36), Text = "Crafting", TextSize = 30 })

-- close (X)
local closeButton = textButton(craftPanel, {
	Name = "Close",
	Position = UDim2.fromOffset(584, 20),
	Size = UDim2.fromOffset(36, 36),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BackgroundTransparency = 0.93,
})
corner(closeButton, 18)
for _, rotation in ipairs({ 45, -45 }) do
	local line = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(2, 14),
		Rotation = rotation,
		BackgroundColor3 = CONFIG.Text,
		BorderSizePixel = 0,
	}, closeButton)
	corner(line, 1)
end

-- category tabs (right-aligned, before the close button)
local categoryButtons = {}
do
	local right = 584 - 6
	for index = #CATEGORY_ORDER, 1, -1 do
		local name = CATEGORY_ORDER[index]
		local width = math.ceil(textWidth(name, 19)) + 32
		right -= width
		local tab = textButton(craftPanel, {
			Name = name .. "Tab",
			Position = UDim2.fromOffset(right, 20),
			Size = UDim2.fromOffset(width, 36),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.93,
			Text = name,
			TextSize = 19,
		})
		corner(tab, 18)
		categoryButtons[name] = tab
		right -= 8
	end
end

-- item strip
local strip = new("ScrollingFrame", {
	Name = "ItemStrip",
	Position = UDim2.fromOffset(20, 72),
	Size = UDim2.fromOffset(600, 112),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	ScrollingDirection = Enum.ScrollingDirection.X,
	AutomaticCanvasSize = Enum.AutomaticSize.X,
	CanvasSize = UDim2.new(),
	ScrollBarThickness = 4,
	ScrollBarImageColor3 = CONFIG.Text,
	ScrollBarImageTransparency = 0.7,
	ElasticBehavior = Enum.ElasticBehavior.Never,
}, craftPanel)
new("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, 8),
}, strip)
new("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingLeft = UDim.new(0, 2) }, strip)

local recipeTiles = {}
for _, category in ipairs(CATEGORY_ORDER) do
	for order, recipe in ipairs(RECIPES[category]) do
		local tile = textButton(strip, {
			Name = recipe.id,
			LayoutOrder = order,
			Size = UDim2.fromOffset(90, 100),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.95,
			Visible = false,
		})
		corner(tile, 10)
		local outline = stroke(tile, CONFIG.Accent, 2, 1)
		local content = new("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
		}, tile)
		new("UIListLayout", {
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			Padding = UDim.new(0, 6),
		}, content)
		local iconHolder = new("Frame", { LayoutOrder = 1, Size = UDim2.fromOffset(56, 56), BackgroundTransparency = 1 }, content)
		local icon = itemIcon(iconHolder, 56, UDim2.fromScale(0.5, 0.5))
		icon.Set(recipe.id)
		text(content, {
			LayoutOrder = 2,
			Size = UDim2.fromOffset(82, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Text = ITEMS[recipe.id].Name,
			TextSize = 16,
			LineHeight = 0.78, -- HTML line-height 1.05
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Center,
		})
		local badge = new("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -5, 0, 4),
			Size = UDim2.fromOffset(28, 20),
			BackgroundColor3 = CONFIG.Accent,
			BorderSizePixel = 0,
			Visible = false,
			ZIndex = 3,
		}, tile)
		corner(badge, 10)
		local badgeText = text(badge, {
			Size = UDim2.fromScale(1, 1),
			TextSize = 14,
			TextColor3 = CONFIG.DarkText,
			TextXAlignment = Enum.TextXAlignment.Center,
			ZIndex = 3,
		})
		local pop = new("UIScale", {}, tile)
		recipeTiles[recipe.id] = { Button = tile, Stroke = outline, Icon = icon, Badge = badge, BadgeText = badgeText, Category = category, Pop = pop }
	end
end

-- preview (left column)
local preview = new("Frame", {
	Name = "Preview",
	Position = UDim2.fromOffset(20, 198),
	Size = UDim2.fromOffset(292, 342),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BackgroundTransparency = 0.95,
	BorderSizePixel = 0,
}, craftPanel)
corner(preview, 12)
new("UIListLayout", {
	SortOrder = Enum.SortOrder.LayoutOrder,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	Padding = UDim.new(0, 4),
}, preview)
local previewIconHolder = new("Frame", { LayoutOrder = 1, Size = UDim2.fromOffset(156, 164), BackgroundTransparency = 1 }, preview)
local previewIcon = itemIcon(previewIconHolder, 156, UDim2.fromOffset(78, 78))
local previewPop = new("UIScale", {}, previewIcon.Image)
local function popPreview()
	previewPop.Scale = 0.82
	previewIcon.Image.Rotation = -8
	tween(previewPop, 0.2, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	tween(previewIcon.Image, 0.2, { Rotation = 0 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end
local previewName = text(preview, {
	LayoutOrder = 2,
	Size = UDim2.fromOffset(268, 32),
	TextSize = 32,
	TextXAlignment = Enum.TextXAlignment.Center,
})
local previewCategory = text(preview, {
	LayoutOrder = 3,
	Size = UDim2.fromOffset(268, 22),
	TextSize = 16,
	TextTransparency = 0.3,
	TextXAlignment = Enum.TextXAlignment.Center,
})
local previewDesc = text(preview, {
	LayoutOrder = 4,
	Size = UDim2.fromOffset(240, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	TextSize = 18,
	TextTransparency = 0.15,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextYAlignment = Enum.TextYAlignment.Top,
})
new("UIPadding", { PaddingTop = UDim.new(0, 6) }, previewDesc)

-- materials + buttons (right column)
local right = new("Frame", {
	Name = "Requirements",
	Position = UDim2.fromOffset(328, 198),
	Size = UDim2.fromOffset(292, 342),
	BackgroundTransparency = 1,
}, craftPanel)
text(right, { Size = UDim2.fromOffset(292, 20), Text = "Required materials", TextSize = 17, TextTransparency = 0.3 })

local materialRows = {}
for index = 1, 3 do
	local row = new("Frame", {
		Position = UDim2.fromOffset(0, 28 + (index - 1) * 56),
		Size = UDim2.fromOffset(292, 48),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.94,
		BorderSizePixel = 0,
		Visible = false,
	}, right)
	corner(row, 10)
	local icon = itemIcon(row, 40, UDim2.fromOffset(32, 24))
	local name = text(row, { Position = UDim2.fromOffset(62, 6), Size = UDim2.fromOffset(150, 20), TextSize = 19 })
	local status = text(row, { Position = UDim2.fromOffset(62, 26), Size = UDim2.fromOffset(150, 16), TextSize = 15 })
	local amount = text(row, {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 0),
		Size = UDim2.fromOffset(80, 48),
		TextSize = 21,
		TextXAlignment = Enum.TextXAlignment.Right,
	})
	materialRows[index] = { Row = row, Icon = icon, Name = name, Status = status, Amount = amount }
end

local noRecipe = new("Frame", {
	Position = UDim2.fromOffset(0, 28),
	Size = UDim2.fromOffset(292, 56),
	BackgroundTransparency = 1,
	Visible = false,
}, right)
corner(noRecipe, 10)
stroke(noRecipe, CONFIG.Text, 2, 0.8)
text(noRecipe, { Position = UDim2.fromOffset(16, 0), Size = UDim2.fromOffset(260, 56), Text = "Recipe not set yet", TextTransparency = 0.25 })

local queuedLabel = text(right, { Position = UDim2.fromOffset(0, 256), Size = UDim2.fromOffset(180, 26), TextSize = 17, TextTransparency = 0.3 })
local clearButton = textButton(right, {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.fromOffset(292, 256),
	Size = UDim2.fromOffset(104, 26),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BackgroundTransparency = 0.92,
	Text = "Clear queue",
	TextSize = 15,
	Visible = false,
})
corner(clearButton, 13)

local craftButton = textButton(right, {
	Position = UDim2.fromOffset(0, 290),
	Size = UDim2.fromOffset(292, 52),
	BackgroundColor3 = CONFIG.Accent,
	TextSize = 26,
	Text = "Craft",
})
corner(craftButton, 12)
local craftButtonScale = new("UIScale", {}, craftButton)


--------------------------------------------------------------------------------
-- HUD: hotbar, item name, crosshair, inventory button
--------------------------------------------------------------------------------
-- hotbar + inventory button, centred at the bottom (584 + 8 + 80 = 672 wide)
local hotbarGroup = new("Frame", {
	Name = "HotbarGroup",
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -14),
	Size = UDim2.fromOffset(672, 80),
	BackgroundTransparency = 1,
}, gui)
hudScale(hotbarGroup)

local hotbar = new("Frame", {
	Name = "Hotbar",
	Size = UDim2.fromOffset(584, 80),
	BackgroundColor3 = CONFIG.PanelColor,
	BackgroundTransparency = CONFIG.PanelTransparency,
	BorderSizePixel = 0,
}, hotbarGroup)
corner(hotbar, 12)

local hotbarSlots = {}
for index = 1, 8 do
	local slot = textButton(hotbar, {
		Name = "Hotbar" .. index,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(40 + (index - 1) * 72, 40),
		Size = UDim2.fromOffset(64, 64),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.94,
	})
	corner(slot, 8)
	local outline = stroke(slot, Color3.new(1, 1, 1), 2, 0.9)
	text(slot, { Position = UDim2.fromOffset(6, 1), Size = UDim2.fromOffset(20, 18), Text = tostring(index), TextSize = 15, TextTransparency = 0.25 })
	local icon = itemIcon(slot, 40, UDim2.fromScale(0.5, 0.5))
	local pop = new("UIScale", {}, slot)
	hotbarSlots[index] = { Button = slot, Stroke = outline, Icon = icon, Pop = pop }
end

-- inventory button, right next to slot 8
local keyboard = UserInputService.KeyboardEnabled
local openButton = textButton(hotbarGroup, {
	Name = "OpenInventory",
	Position = UDim2.fromOffset(592, 0),
	Size = UDim2.fromOffset(80, 80),
	BackgroundColor3 = CONFIG.PanelColor,
	BackgroundTransparency = CONFIG.PanelTransparency,
})
corner(openButton, 12)
local openStroke = stroke(openButton, CONFIG.Accent, 2, 1)
local openPop = new("UIScale", {}, openButton)
do
	-- simple backpack icon built from frames
	local line = 2.6
	local bag = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(40, 43),
		Size = UDim2.fromOffset(19, 16),
		BackgroundTransparency = 1,
	}, openButton)
	corner(bag, 4)
	stroke(bag, CONFIG.Text, line, 0)
	local handle = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromOffset(40, 35 - line),
		Size = UDim2.fromOffset(7, 4),
		BackgroundTransparency = 1,
	}, openButton)
	corner(handle, 4)
	stroke(handle, CONFIG.Text, line, 0)
	local strap = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(40, 43),
		Size = UDim2.fromOffset(14, line),
		BackgroundColor3 = CONFIG.Text,
		BorderSizePixel = 0,
	}, openButton)
	corner(strap, 1)
	if keyboard then
		text(openButton, { Position = UDim2.fromOffset(6, 1), Size = UDim2.fromOffset(40, 18), Text = "TAB", TextSize = 13, TextTransparency = 0.35 })
	end
end

local hotName = text(gui, {
	Name = "HeldItemName",
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -100),
	Size = UDim2.fromOffset(400, 24),
	TextSize = 20,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextStrokeTransparency = 0.7,
})
hudScale(hotName)

local crosshair = new("Frame", {
	Name = "Crosshair",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(18, 18),
	BackgroundTransparency = 1,
}, gui)
new("Frame", { Position = UDim2.fromOffset(8, 0), Size = UDim2.fromOffset(2, 18), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.3, BorderSizePixel = 0 }, crosshair)
new("Frame", { Position = UDim2.fromOffset(0, 8), Size = UDim2.fromOffset(18, 2), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.3, BorderSizePixel = 0 }, crosshair)

--------------------------------------------------------------------------------
-- HUD: crafting progress (top-right, outside the menu)
--------------------------------------------------------------------------------
local progressHome = UDim2.new(1, -12, 0, 12)
local progressAway = UDim2.new(1, 12, 0, 12)

local progress = new("Frame", {
	Name = "CraftingProgress",
	AnchorPoint = Vector2.new(1, 0),
	Position = progressAway,
	Size = UDim2.fromOffset(190, 30),
	BackgroundTransparency = 1,
	Visible = false,
}, gui)
hudScale(progress)

local progressTitle = text(progress, {
	Size = UDim2.fromOffset(148, 20),
	TextSize = 17,
	TextColor3 = Color3.new(1, 1, 1),
	TextTruncate = Enum.TextTruncate.AtEnd,
	TextStrokeTransparency = 0.6,
})
local progressAmount = text(progress, {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.fromOffset(190, 0),
	Size = UDim2.fromOffset(42, 20),
	TextSize = 17,
	TextColor3 = Color3.new(1, 1, 1),
	TextXAlignment = Enum.TextXAlignment.Right,
	TextStrokeTransparency = 0.6,
})
local amountScale = new("UIScale", {}, progressAmount)
local barBack = new("Frame", {
	Position = UDim2.fromOffset(0, 24),
	Size = UDim2.fromOffset(190, 4),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BackgroundTransparency = 0.8,
	BorderSizePixel = 0,
	ClipsDescendants = true,
}, progress)
new("UICorner", { CornerRadius = UDim.new(1, 0) }, barBack)
local barFill = new("Frame", {
	Size = UDim2.fromScale(0, 1),
	BackgroundColor3 = CONFIG.Accent,
	BorderSizePixel = 0,
}, barBack)
new("UICorner", { CornerRadius = UDim.new(1, 0) }, barFill)

-- fades the whole progress element (0 = shown, 1 = hidden)
local progressAlpha = new("NumberValue", { Name = "ProgressAlpha", Value = 1 }, gui)
local function applyProgressAlpha()
	local a = progressAlpha.Value
	progressTitle.TextTransparency = a
	progressAmount.TextTransparency = a
	progressTitle.TextStrokeTransparency = 0.6 + 0.4 * a
	progressAmount.TextStrokeTransparency = 0.6 + 0.4 * a
	barBack.BackgroundTransparency = 0.8 + 0.2 * a
	barFill.BackgroundTransparency = a
end
progressAlpha.Changed:Connect(applyProgressAlpha)
applyProgressAlpha()

--------------------------------------------------------------------------------
-- SCALING
--------------------------------------------------------------------------------
local function updateScale()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local viewport = camera.ViewportSize
	local topInset = GuiService:GetGuiInset().Y -- Roblox top bar (menu / chat buttons)

	-- one scale for everything, like fitting the 1280 x 720 preview to the screen
	local sc = math.min(viewport.X / CONFIG.DesignWidth, viewport.Y / CONFIG.DesignHeight)
	for _, uiScale in ipairs(hudScales) do
		uiScale.Scale = sc
	end

	-- hotbar at the bottom, held-item name just above it
	hotbarGroup.Position = UDim2.new(0.5, 0, 1, -14 * sc)
	hotName.Position = UDim2.new(0.5, 0, 1, -(14 + 80 + 8) * sc)

	-- crafting progress in the top-right corner (Roblox's buttons are top-left)
	progressHome = UDim2.new(1, -12 * sc, 0, 12 * sc)
	progressAway = UDim2.new(1, 12 * sc, 0, 12 * sc)
	progress.Position = progress.Visible and progressHome or progressAway

	-- menu: between the top bar / progress strip and the top of the hotbar
	local gap = 8 * sc
	local top = math.max(topInset, 48 * sc) + gap
	local bottom = viewport.Y - (14 + 80) * sc - gap
	local availH = math.max(100, bottom - top)
	local availW = viewport.X - gap * 2
	local menuScale = math.min(sc, availH / MENU_H, availW / MENU_W)
	canvasScale.Scale = menuScale
	canvas.Position = UDim2.fromOffset(viewport.X / 2, top + availH / 2)
end
local cameraConnection
local function watchCamera()
	if cameraConnection then
		cameraConnection:Disconnect()
	end
	local camera = workspace.CurrentCamera
	if camera then
		cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
	end
	updateScale()
end
watchCamera()
local cameraWatch = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(watchCamera)

--------------------------------------------------------------------------------
-- REFRESH
--------------------------------------------------------------------------------
local function visibleInventoryKeys()
	local keys = {}
	for _, id in ipairs(inventoryOrder) do
		if (inventory[id] or 0) > 0 then
			table.insert(keys, id)
		end
	end
	return keys
end

local function refreshInventory()
	local keys = visibleInventoryKeys()
	usedLabel.Text = #keys .. " / " .. CONFIG.BackpackSlots
	for index, slot in ipairs(backpackSlots) do
		local id = keys[index]
		slot.Item = id
		slot.Icon.Set(id)
		local amount = id and inventory[id] or 0
		slot.Count.Text = amount > 1 and tostring(amount) or ""
		local selected = selectedSlot == index and id ~= nil
		slot.Stroke.Color = CONFIG.Accent
		slot.Stroke.Transparency = selected and 0 or 1
	end
	local selectedId = selectedSlot and keys[selectedSlot]
	invInfo.Text = selectedId and (ITEMS[selectedId].Name .. "  x" .. inventory[selectedId]) or "Click an item"
end

local function queuedCount(id)
	local n = 0
	for _, job in ipairs(queue) do
		if job.id == id then
			n += job.count
		end
	end
	return n
end

local function refreshCrafting()
	for name, tab in pairs(categoryButtons) do
		local on = name == selectedCategory
		tab.BackgroundColor3 = on and CONFIG.Accent or Color3.new(1, 1, 1)
		tab.BackgroundTransparency = on and 0 or 0.93
		tab.TextColor3 = on and CONFIG.DarkText or CONFIG.Text
	end

	local recipe = currentRecipe()
	for id, tile in pairs(recipeTiles) do
		tile.Button.Visible = tile.Category == selectedCategory
		local on = id == recipe.id
		local n = queuedCount(id)
		tile.Stroke.Transparency = on and 0 or 1
		tile.Button.BackgroundTransparency = on and 0.88 or 0.95
		tile.Icon.SetFaded(maxCraftable(findRecipe(id)) == 0 and n == 0)
		tile.Badge.Visible = n > 0
		tile.BadgeText.Text = "x" .. n
		tile.Badge.Size = UDim2.fromOffset(math.max(28, math.ceil(textWidth("x" .. n, 14)) + 12), 20)
	end

	local item = ITEMS[recipe.id]
	previewIcon.Set(recipe.id)
	previewName.Text = item.Name
	previewCategory.Text = selectedCategory .. (CRAFT_TIME[recipe.id] and ("  ·  " .. CRAFT_TIME[recipe.id] .. "s to craft") or "")
	previewDesc.Text = item.Desc or ""

	local mats = recipe.mats or {}
	for index, row in ipairs(materialRows) do
		local mat = mats[index]
		row.Row.Visible = mat ~= nil
		if mat then
			local have = math.max(0, available(mat[1]))
			local ok = have >= mat[2]
			row.Icon.Set(mat[1])
			row.Name.Text = ITEMS[mat[1]].Name
			row.Status.Text = ok and "Ready" or ("Need " .. (mat[2] - have) .. " more")
			row.Status.TextColor3 = ok and CONFIG.Accent or CONFIG.Missing
			row.Amount.Text = have .. " / " .. mat[2]
			row.Amount.TextColor3 = ok and CONFIG.Text or CONFIG.Missing
		end
	end
	noRecipe.Visible = recipe.mats == nil

	local maxN = maxCraftable(recipe)
	local full = not canQueue(recipe)
	local can = maxN > 0 and not full
	craftButton.Text = full and "Queue full" or (maxN > 0 and "Craft" or (recipe.mats and "Missing materials" or "Recipe not set"))
	craftButton.BackgroundColor3 = can and CONFIG.Accent or Color3.new(1, 1, 1)
	craftButton.BackgroundTransparency = can and 0 or 0.92
	craftButton.TextColor3 = can and CONFIG.DarkText or CONFIG.Text
	craftButton.TextTransparency = can and 0 or 0.4
	craftButton.Active = can

	local n = queuedCount(recipe.id)
	queuedLabel.Text = n > 0 and (n .. " in queue") or ""
	clearButton.Visible = #queue > 1 or (#queue == 1 and (queue[1].count > 1 or not unitStarted))
end

local function refreshHotbar()
	for index, slot in ipairs(hotbarSlots) do
		local id = hotbarItems[index]
		slot.Icon.Set(id or nil)
		local on = selectedHotbar == index
		slot.Stroke.Color = on and CONFIG.Accent or Color3.new(1, 1, 1)
		slot.Stroke.Transparency = on and 0 or 0.9
		slot.Button.BackgroundTransparency = on and 0.84 or 0.94
	end
	local held = hotbarItems[selectedHotbar]
	hotName.Text = held and ITEMS[held].Name or "Empty hand"
end

--------------------------------------------------------------------------------
-- CRAFTING PROGRESS
--------------------------------------------------------------------------------
local progressState = "hidden" -- hidden | showing | leaving
local progressTweens = {}
local progressToken = 0
local displayedFill = 0
local draining = false

local function stopProgressTweens()
	for _, t in ipairs(progressTweens) do
		t:Cancel()
	end
	table.clear(progressTweens)
end

local function updateProgressText()
	local job = queue[1]
	if job then
		progressTitle.Text = "Crafting " .. ITEMS[job.id].Name
		progressAmount.Text = "x" .. job.count
	elseif finishing then
		progressTitle.Text = "Crafted " .. ITEMS[finishing.id].Name
		progressAmount.Text = "x" .. finishing.total
	end
	-- title uses all the room the amount leaves (like the HTML)
	local amountWidth = math.ceil(textWidth(progressAmount.Text, 17))
	progressAmount.Size = UDim2.fromOffset(amountWidth, 20)
	progressTitle.Size = UDim2.fromOffset(190 - amountWidth - 8, 20)
end

local function showProgress()
	progressToken += 1
	updateProgressText()
	if progressState == "showing" then
		return
	end
	stopProgressTweens()
	if progressState == "hidden" then
		progress.Position = progressAway
		progressAlpha.Value = 1
		displayedFill = 0
		barFill.Size = UDim2.fromScale(0, 1)
	end
	progress.Visible = true
	progressState = "showing"
	table.insert(progressTweens, tween(progress, 0.2, { Position = progressHome }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out))
	table.insert(progressTweens, tween(progressAlpha, 0.16, { Value = 0 }))
end

local function hideProgress()
	progressToken += 1
	local token = progressToken
	stopProgressTweens()
	progressState = "leaving"
	local out = tween(progress, 0.2, { Position = progressAway }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
	table.insert(progressTweens, out)
	table.insert(progressTweens, tween(progressAlpha, 0.16, { Value = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In))
	out.Completed:Once(function(state)
		if state == Enum.PlaybackState.Completed and token == progressToken then
			progress.Visible = false
			progressState = "hidden"
			finishing = nil
		end
	end)
end

local function finishProgress(job)
	finishing = { id = job.id, total = job.total }
	updateProgressText()
	craftSound:Play()
	progressToken += 1
	local token = progressToken
	task.delay(0.65, function()
		if token ~= progressToken or #queue > 0 then
			return
		end
		hideProgress()
	end)
end

local function popAmount()
	amountScale.Scale = 1.25
	tween(amountScale, 0.18, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

local function flashItem(id)
	for index, slot in ipairs(backpackSlots) do
		if slot.Item == id and selectedSlot ~= index then
			slot.Stroke.Color = CONFIG.Accent
			slot.Stroke.Transparency = 0
			tween(slot.Stroke, 0.6, { Transparency = 1 })
			slot.Pop.Scale = 1.12
			tween(slot.Pop, 0.2, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		end
	end
end

--------------------------------------------------------------------------------
-- ACTIONS
--------------------------------------------------------------------------------
-- SERVER HOOK: send the craft request to the server here and only add to the
-- queue when the server says yes. Right now it runs locally for testing.
local function requestCraft(recipe, amount)
	if amount < 1 or not canQueue(recipe) then
		return
	end
	local last = queue[#queue]
	if last and last.id == recipe.id then
		last.count += amount
		last.total += amount
	else
		table.insert(queue, {
			id = recipe.id,
			dur = CRAFT_TIME[recipe.id] or 3,
			mats = recipe.mats,
			count = amount,
			total = amount,
		})
	end
	if finishing then
		draining = true -- bar was full from the last batch: slide it back smoothly
	end
	finishing = nil
	selectedSlot = nil
	showProgress()
	refreshInventory()
	refreshCrafting()
end

local function clearQueue()
	if #queue == 0 then
		return
	end
	if unitStarted then
		local first = queue[1]
		first.total = first.total - first.count + 1
		first.count = 1
		queue = { first }
	else
		queue = {}
		unitElapsed = 0
		hideProgress()
	end
	updateProgressText()
	refreshCrafting()
end

local touchControlsBefore = nil
local menuTweens = {}
local INV_HOME, CRAFT_HOME = UDim2.fromOffset(0, 0), UDim2.fromOffset(484, 0)
local function stopMenuTweens()
	for _, t in ipairs(menuTweens) do
		t:Cancel()
	end
	table.clear(menuTweens)
end
local function menuTween(object, duration, props, style, direction)
	local t = tween(object, duration, props, style, direction)
	table.insert(menuTweens, t)
	return t
end

local function setOpen(open)
	if isOpen == open and panels.Visible == open then
		return
	end
	isOpen = open
	modal.Visible = open
	crosshair.Visible = not open
	hotName.Visible = not open

	-- inventory button shows it's active
	openStroke.Transparency = open and 0 or 1
	openPop.Scale = 0.88
	tween(openPop, 0.16, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

	-- hide the mobile thumbstick / jump button while the menu is open
	if UserInputService.TouchEnabled then
		if open then
			touchControlsBefore = GuiService.TouchControlsEnabled
			GuiService.TouchControlsEnabled = false
		elseif touchControlsBefore ~= nil then
			GuiService.TouchControlsEnabled = touchControlsBefore
			touchControlsBefore = nil
		end
	end

	stopMenuTweens()
	if open then
		updateScale()
		refreshInventory()
		refreshCrafting()
		panels.Visible = true
		dim.Visible = true
		-- panels snap in from the sides with a little overshoot
		panelsScale.Scale = 0.94
		invPanel.Position = INV_HOME + UDim2.fromOffset(-28, 0)
		craftPanel.Position = CRAFT_HOME + UDim2.fromOffset(28, 0)
		menuTween(panelsScale, 0.16, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		menuTween(invPanel, 0.16, { Position = INV_HOME }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		menuTween(craftPanel, 0.16, { Position = CRAFT_HOME }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		menuTween(dim, 0.12, { BackgroundTransparency = CONFIG.DimTransparency })
		menuTween(blur, 0.12, { Size = CONFIG.BlurSize })
	else
		local out = menuTween(panelsScale, 0.1, { Scale = 0.94 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		menuTween(invPanel, 0.1, { Position = INV_HOME + UDim2.fromOffset(-28, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		menuTween(craftPanel, 0.1, { Position = CRAFT_HOME + UDim2.fromOffset(28, 0) }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		menuTween(dim, 0.1, { BackgroundTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		menuTween(blur, 0.1, { Size = 0 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		out.Completed:Once(function(state)
			if state == Enum.PlaybackState.Completed and not isOpen then
				panels.Visible = false
				dim.Visible = false
			end
		end)
	end
end

local function selectHotbar(index)
	selectedHotbar = index
	refreshHotbar()
	local pop = hotbarSlots[index].Pop
	pop.Scale = 0.86
	tween(pop, 0.16, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	-- SERVER HOOK: equip hotbarItems[index] here
end

--------------------------------------------------------------------------------
-- CONNECTIONS
--------------------------------------------------------------------------------
local connections = {}
local function connect(signal, fn)
	local c = signal:Connect(fn)
	table.insert(connections, c)
	return c
end

for name, tab in pairs(categoryButtons) do
	connect(tab.Activated, function()
		if selectedCategory == name then
			return
		end
		local oldIndex, newIndex = table.find(CATEGORY_ORDER, selectedCategory), table.find(CATEGORY_ORDER, name)
		selectedCategory = name
		selectedRecipe = RECIPES[name][1].id
		strip.CanvasPosition = Vector2.zero
		refreshCrafting()
		-- item strip slides in from the side you moved towards
		local dir = (newIndex or 0) > (oldIndex or 0) and 1 or -1
		strip.Position = UDim2.fromOffset(20 + dir * 30, 72)
		tween(strip, 0.16, { Position = UDim2.fromOffset(20, 72) }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
		popPreview()
	end)
end

for id, tile in pairs(recipeTiles) do
	connect(tile.Button.Activated, function()
		if selectedRecipe ~= id then
			popPreview()
		end
		selectedRecipe = id
		refreshCrafting()
		tile.Pop.Scale = 0.9
		tween(tile.Pop, 0.16, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	end)
end

for index, slot in ipairs(backpackSlots) do
	connect(slot.Button.Activated, function()
		selectedSlot = slot.Item and index or nil
		refreshInventory()
		if slot.Item then
			slot.Pop.Scale = 0.88
			tween(slot.Pop, 0.16, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
		end
	end)
end

for index, slot in ipairs(hotbarSlots) do
	connect(slot.Button.Activated, function()
		selectHotbar(index)
	end)
end

connect(craftButton.Activated, function()
	local recipe = currentRecipe()
	if maxCraftable(recipe) < 1 then
		return
	end
	craftButtonScale.Scale = 0.92
	tween(craftButtonScale, 0.16, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
	requestCraft(recipe, 1)
end)

connect(clearButton.Activated, clearQueue)
connect(closeButton.Activated, function()
	setOpen(false)
end)
connect(openButton.Activated, function()
	setOpen(not isOpen)
end)

local numberKeys = {
	[Enum.KeyCode.One] = 1, [Enum.KeyCode.Two] = 2, [Enum.KeyCode.Three] = 3, [Enum.KeyCode.Four] = 4,
	[Enum.KeyCode.Five] = 5, [Enum.KeyCode.Six] = 6, [Enum.KeyCode.Seven] = 7, [Enum.KeyCode.Eight] = 8,
}
connect(UserInputService.InputBegan, function(input, processed)
	if UserInputService:GetFocusedTextBox() then
		return
	end
	if input.KeyCode == CONFIG.ToggleKey then
		setOpen(not isOpen)
		return
	end
	if processed then
		return
	end
	local slot = numberKeys[input.KeyCode]
	if slot then
		selectHotbar(slot)
	end
end)

-- crafting clock + bar
connect(RunService.Heartbeat, function(dt)
	local job = queue[1]
	if job then
		if not unitStarted then
			-- materials are taken when each item starts
			local ok = true
			for _, mat in ipairs(job.mats) do
				if (inventory[mat[1]] or 0) < mat[2] then
					ok = false
					break
				end
			end
			if ok then
				for _, mat in ipairs(job.mats) do
					inventory[mat[1]] -= mat[2]
				end
				unitStarted = true
				unitElapsed = 0
			else
				table.remove(queue, 1)
			end
			refreshInventory()
			refreshCrafting()
			if #queue == 0 and progressState == "showing" then
				hideProgress()
			end
		else
			unitElapsed += dt
			if unitElapsed >= job.dur then
				unitStarted = false
				unitElapsed = 0
				addItem(job.id, 1)
				job.count -= 1
				if job.count <= 0 then
					table.remove(queue, 1)
				end
				if #queue > 0 then
					draining = true -- next item: slide the bar back quickly
					popAmount()
					updateProgressText()
				else
					draining = false
					displayedFill = 1
					finishProgress(job)
				end
				refreshInventory()
				refreshCrafting()
				flashItem(job.id)
			end
		end
	end

	-- bar: fills once per item, then does a very fast smooth slide back to empty
	if progress.Visible then
		local target
		local current = queue[1]
		if current then
			target = unitStarted and math.clamp(unitElapsed / current.dur, 0, 1) or 0
		else
			target = 1
		end
		if draining then
			displayedFill += (target - displayedFill) * math.min(1, dt * CONFIG.BarResetSpeed)
			if math.abs(displayedFill - target) < 0.01 then
				draining = false
				displayedFill = target
			end
		else
			displayedFill = target
		end
		barFill.Size = UDim2.fromScale(displayedFill, 1)
	end
end)

gui.Destroying:Connect(function()
	for _, c in ipairs(connections) do
		c:Disconnect()
	end
	if cameraConnection then
		cameraConnection:Disconnect()
	end
	cameraWatch:Disconnect()
	stopProgressTweens()
	blur:Destroy()
	if touchControlsBefore ~= nil then
		GuiService.TouchControlsEnabled = touchControlsBefore
	end
end)

--------------------------------------------------------------------------------
-- START
--------------------------------------------------------------------------------
refreshInventory()
refreshCrafting()
refreshHotbar()
isOpen = true
setOpen(false)
panels.Visible = false
dim.Visible = false
