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

pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
end)

local CONFIG = {
	ToggleKey = Enum.KeyCode.Tab,
	Accent = Color3.fromRGB(233, 185, 73),
	Text = Color3.fromRGB(237, 232, 220),
	DarkText = Color3.fromRGB(27, 26, 20),
	Missing = Color3.fromRGB(244, 164, 124),
	PanelColor = Color3.fromRGB(16, 21, 19),

	PanelTransparency = 0.32,
	FontEnum = Enum.Font.PatrickHand,

	FontScale = 1.354,
	CraftCompleteSound = "rbxassetid://100545760361878",
	QueueMax = 8,
	BackpackSlots = 24,
	BarResetSpeed = 35,
	BlurSize = 12,
	SelectFade = 0.12,
	DimTransparency = 0.16,
	DimColor = Color3.fromRGB(12, 11, 6),
	MaxWidthStretch = 1.2,
	HotbarBoost = 1,
	HotbarTouchBoost = 1.3,
	MenuWidthFraction = 0.878,

	BagIcon = "rbxassetid://79330975561485",
	EquipmentIcons = {
		Helmet = "rbxassetid://122411372685446",
		Chest = "rbxassetid://82728361755910",
		Gloves = "rbxassetid://140397145487659",
		Legs = "rbxassetid://109587618198386",
		Boots = "rbxassetid://104349095380038",
	},

	Tuner = true,
	DesignWidth = 1280,
	DesignHeight = 720,
}
local FONT = Font.fromEnum(CONFIG.FontEnum)

local function ts(size)
	return math.floor(size * CONFIG.FontScale + 0.5)
end

local ITEMS = {
	planks = { Name = "Planks", Image = "rbxassetid://78387750873126" },
	stone = { Name = "Stone", Image = "rbxassetid://127351259030040" },
	leaves = { Name = "Leaves", Image = "rbxassetid://94252892154991" },
	rope = { Name = "Rope", Image = "rbxassetid://94728420315409", Desc = "Used in most tool recipes." },
	fiber = { Name = "Fiber", Image = "rbxassetid://85899584797851" },
	scrap = { Name = "Scrap", Image = "rbxassetid://123247338574784" },
	plastic = { Name = "Plastic", Image = "rbxassetid://126538877519520" },
	nails = { Name = "Nails", Image = "rbxassetid://100720163739756", Desc = "Used for building." },
	hide = { Name = "Hide", Image = "rbxassetid://137106848150031" },
	cup_clean = { Name = "Clean Water Cup", Image = "rbxassetid://75855735142648", Desc = "Safe drinking water." },
	cup_sea = { Name = "Seawater Cup", Image = "rbxassetid://94755334875949" },
	stone_axe = { Name = "Stone Axe", Image = "rbxassetid://73396827796121", Desc = "Chops trees for wood." },
	stone_pickaxe = { Name = "Stone Pickaxe", Image = "rbxassetid://103209016597189", Desc = "Mines stone from rocks." },
	stone_spear = { Name = "Stone Spear", Image = "rbxassetid://131953404883594", Desc = "A long-reach thrusting weapon." },
	wooden_club = { Name = "Wooden Club", Image = "rbxassetid://77142435102160", Desc = "A heavy, simple striking weapon." },
	stone_sword = { Name = "Stone Sword", Image = "rbxassetid://99964958308218", Desc = "A basic slashing weapon." },
	torch = { Name = "Torch", Image = "rbxassetid://128672619441958", Desc = "Lights up the dark." },
	bow = { Name = "Bow", Image = "rbxassetid://103839860687597", Desc = "A wooden bow for firing arrows." },
	stone_arrows = { Name = "Stone Arrows", Image = "rbxassetid://87510233891000", Desc = "Stone-tipped arrows for a bow." },
	wooden_shield = { Name = "Wooden Shield", Image = "rbxassetid://104624286311499", Desc = "Blocks incoming attacks." },
	building_hammer = { Name = "Building Hammer", Image = "rbxassetid://85234448517206", Desc = "A tool for planning and placing structures." },
	map = { Name = "Map", Image = "", Desc = "Shows the islands and where you are." },
	compass = { Name = "Compass", Image = "", Desc = "Points the way while you explore." },
}

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

local CRAFT_TIME = {
	stone_pickaxe = 4, stone_axe = 4, stone_spear = 3, wooden_club = 2.5, stone_sword = 5,
	torch = 2, wooden_shield = 4, map = 3, compass = 3, rope = 1.5, nails = 1,
}

local HOLD_DELAY = 0.30
local HOLD_FILL = 1.20
local SLIDE_PX = 200
local SLIDE_MIN = 8
local SLIDE_MAX = 30
local THROW_DELAY = 0.15
local THROW_TIME = 0.45
local TAP_GUARD = 0.25
local FLY_TIME = 0.18
local FLY_START = 1.12
local DRAG_START_PX = 10
local DRAG_SCALE = 1.15
local DRAG_TOUCH_UP = 36
local DROP_IN_TIME = 0.12
local HOTBAR_COUNT = 8
local CORAL = Color3.fromRGB(244, 164, 124)

local bp = {}
local hb = {}
local worn = {}
do
	local start = { { "planks", 12 }, { "stone", 9 }, { "leaves", 14 }, { "rope", 3 }, { "fiber", 6 }, { "scrap", 2 }, { "hide", 3 }, { "cup_clean", 1 } }
	for index, entry in ipairs(start) do
		bp[index] = { id = entry[1], n = entry[2] }
	end
	hb[1] = { id = "stone_axe", n = 1 }
	hb[2] = { id = "torch", n = 1 }
	hb[3] = { id = "cup_sea", n = 1 }
end

local selectedCategory = "Tools"
local selectedRecipe = "stone_pickaxe"
local pick = nil
local hold = nil
local tapGuardUntil = 0
local selectedHotbar = 1
local isOpen = false

local queue = {}
local unitStarted = false
local unitElapsed = 0
local finishing = nil

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

local function slotsOf(area)
	return area == "bp" and bp or hb
end

local function sizeOf(area)
	return area == "bp" and CONFIG.BackpackSlots or HOTBAR_COUNT
end

local function countItem(id)
	local total = 0
	for _, area in ipairs({ "bp", "hb" }) do
		local list = slotsOf(area)
		for index = 1, sizeOf(area) do
			local entry = list[index]
			if entry and entry.id == id then
				total += entry.n
			end
		end
	end
	return total
end

local function removeItem(id, amount)
	for _, area in ipairs({ "bp", "hb" }) do
		local list = slotsOf(area)
		for index = sizeOf(area), 1, -1 do
			if amount <= 0 then
				return
			end
			local entry = list[index]
			if entry and entry.id == id then
				local take = math.min(entry.n, amount)
				entry.n -= take
				amount -= take
				if entry.n <= 0 then
					list[index] = nil
				end
			end
		end
	end
end

local function available(id)
	return countItem(id) - (reserved()[id] or 0)
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
	for _, area in ipairs({ "bp", "hb" }) do
		local list = slotsOf(area)
		for index = 1, sizeOf(area) do
			local entry = list[index]
			if entry and entry.id == id then
				entry.n += amount
				return true
			end
		end
	end
	for _, area in ipairs({ "bp", "hb" }) do
		local list = slotsOf(area)
		for index = 1, sizeOf(area) do
			if not list[index] then
				list[index] = { id = id, n = amount }
				return true
			end
		end
	end
	return false
end

local gui = new("ScreenGui", {
	Name = "HorizonInventoryUI",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 10,
}, playerGui)

local craftSound = new("Sound", { Name = "CraftComplete", SoundId = CONFIG.CraftCompleteSound }, gui)

local motion = require(script:WaitForChild("Motion")).new(gui, CONFIG, ITEMS, {
	FLY_TIME = FLY_TIME,
	FLY_START = FLY_START,
	DRAG_SCALE = DRAG_SCALE,
	DRAG_TOUCH_UP = DRAG_TOUCH_UP,
}, function()
	local camera = workspace.CurrentCamera
	local size = camera and camera.ViewportSize or Vector2.new(CONFIG.DesignWidth, CONFIG.DesignHeight)
	return math.min(size.X / CONFIG.DesignWidth, size.Y / CONFIG.DesignHeight)
end)
local hoverKey = nil
local pc = nil
local snapOutlines = false

local dim = new("TextButton", {
	Name = "Dim",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = CONFIG.DimColor,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	AutoButtonColor = false,
	Text = "",
	Visible = false,
}, gui)

local modal = textButton(gui, {
	Name = "MouseUnlock",
	Size = UDim2.fromOffset(0, 0),
	BackgroundTransparency = 1,
	Modal = true,
	Visible = false,
})

local blur = Lighting:FindFirstChild("HorizonInventoryBlur") or new("BlurEffect", { Name = "HorizonInventoryBlur" }, Lighting)
blur.Size = 0

local INV_W, CRAFT_W, PANEL_GAP = 464, 640, 20
local MENU_W, MENU_H = INV_W + PANEL_GAP + CRAFT_W, 560
local INV_HOME, CRAFT_HOME = UDim2.fromOffset(0, 0), UDim2.fromOffset(INV_W + PANEL_GAP, 0)
local stretch = 1
local INV_EXTRA_H = 3
local dashesBuilt = false
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

local invPanel = panel(panels, "InventoryPanel", 0, 0, 464, 560)
invPanel.Active = true
text(invPanel, { Position = UDim2.fromOffset(20, 11), Size = UDim2.fromOffset(300, 32), Text = "Inventory", TextSize = 44 / CONFIG.FontScale })
local usedLabel = text(invPanel, {
	Position = UDim2.fromOffset(20, 10),
	Size = UDim2.new(1, -40, 0, 32),
	TextSize = 32 / CONFIG.FontScale,
	TextTransparency = 0.3,
	TextXAlignment = Enum.TextXAlignment.Right,
})
text(invPanel, { Position = UDim2.fromOffset(20, 63), Size = UDim2.fromOffset(200, 24), Text = "Equipment", TextSize = 28 / CONFIG.FontScale, TextTransparency = 0.3 })

local EQUIP_LAYOUT = {
	Helmet = { 47, 30, 57, 25 },
	Chest = { 42, 26, 57, 24 },
	Legs = { 42, 27, 55, 24 },
	Boots = { 40, 26, 57, 24 },
	Gloves = { 41, 27, 57, 24 },
}
local equipSlots = {}
for index, slotName in ipairs({ "Helmet", "Chest", "Legs", "Boots", "Gloves" }) do
	local layout = EQUIP_LAYOUT[slotName]
	local faded = nil
	local slot = textButton(invPanel, {
		Name = slotName .. "Slot",
		Position = UDim2.new((index - 1) / 5, 20 - (index - 1) * 6.4, 0, 92),
		Size = UDim2.new(1 / 5, -14.4, 0, 72),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.96,
	})
	corner(slot, 10)
	local ring = new("Frame", { Position = UDim2.fromOffset(1, 1), Size = UDim2.new(1, -2, 1, -2), BackgroundTransparency = 1 }, slot)
	corner(ring, 9)
	stroke(ring, CONFIG.Text, 1, 0.88)
	local hoverRing = new("Frame", { Position = UDim2.fromOffset(2, 2), Size = UDim2.new(1, -4, 1, -4), BackgroundTransparency = 1 }, slot)
	corner(hoverRing, 8)
	local hoverStroke = stroke(hoverRing, CONFIG.Accent, 2, 1)
	local image = CONFIG.EquipmentIcons[slotName]
	if image and image ~= "" then
		faded = new("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0, layout[2]),
			Size = UDim2.fromOffset(layout[1], layout[1]),
			BackgroundTransparency = 1,
			Image = image,
			ImageTransparency = 0.45,
		}, slot)
	end
	local wornIcon = itemIcon(slot, layout[1], UDim2.new(0.5, 0, 0, layout[2]))
	wornIcon.Set(nil)
	equipSlots[slotName] = { Button = slot, Faded = faded, WornIcon = wornIcon, HoverStroke = hoverStroke }
	text(slot, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0, layout[3]),
		Size = UDim2.new(1, -8, 0, 18),
		Text = slotName,
		TextSize = layout[4] / CONFIG.FontScale,
		TextTransparency = 0.45,
		TextXAlignment = Enum.TextXAlignment.Center,
	})
end

text(invPanel, { Position = UDim2.fromOffset(20, 177), Size = UDim2.fromOffset(150, 24), Text = "Backpack", TextSize = 30 / CONFIG.FontScale, TextTransparency = 0.3 })
local invInfo = text(invPanel, {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -20, 0, 178),
	Size = UDim2.fromOffset(274, 24),
	TextSize = 27 / CONFIG.FontScale,
	TextXAlignment = Enum.TextXAlignment.Right,
	Text = "",
})

local BAR_PICK = ColorSequence.new(Color3.fromRGB(246, 213, 122), Color3.fromRGB(233, 185, 73))
local BAR_THROW = ColorSequence.new(Color3.fromRGB(248, 196, 168), CORAL)

local function makeBar(button)
	local track = new("Frame", {
		Name = "AmountBar",
		Position = UDim2.fromOffset(5, 4),
		Size = UDim2.new(1, -10, 0, 5),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.28,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 4,
	}, button)
	corner(track, 3)
	stroke(track, CONFIG.Text, 1, 0.88)
	new("UIPadding", {
		PaddingTop = UDim.new(0, 1),
		PaddingBottom = UDim.new(0, 1),
		PaddingLeft = UDim.new(0, 1),
		PaddingRight = UDim.new(0, 1),
	}, track)
	local fill = new("Frame", {
		Name = "Fill",
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BorderSizePixel = 0,
		ZIndex = 5,
	}, track)
	corner(fill, 2)
	local gradient = new("UIGradient", { Rotation = 90, Color = BAR_PICK }, fill)
	local glow = stroke(fill, CONFIG.Accent, 1.5, 0.6)
	return { Track = track, Fill = fill, Gradient = gradient, Glow = glow }
end

local function setBar(bar, kind, fraction)
	if not kind then
		bar.Track.Visible = false
		return
	end
	bar.Track.Visible = true
	bar.Gradient.Color = kind == "throw" and BAR_THROW or BAR_PICK
	bar.Glow.Color = kind == "throw" and CORAL or CONFIG.Accent
	bar.Fill.Size = UDim2.fromScale(math.clamp(fraction, 0, 1), 1)
end

local function makeSlotHolder(parent, name, props)
	local holder = new("Frame", { Name = name .. "Holder", BackgroundTransparency = 1 }, parent)
	for key, value in pairs(props) do
		holder[key] = value
	end
	local button = textButton(holder, {
		Name = name,
		Size = UDim2.fromScale(1, 1),
		BorderSizePixel = 0,
	})
	return holder, button
end

local backpackSlots = {}
local BACKPACK_SLOT_H = (560 - 208 - 3 * 8) / 4
for index = 1, CONFIG.BackpackSlots do
	local column = (index - 1) % 6
	local row = math.floor((index - 1) / 6)
	local holder, slot = makeSlotHolder(invPanel, "Slot" .. index, {
		Position = UDim2.new(column / 6, 20 - column * 16 / 3, 0, 208 + row * (BACKPACK_SLOT_H + 8)),
		Size = UDim2.new(1 / 6, -40 / 3, 0, BACKPACK_SLOT_H),
	})
	slot.BackgroundColor3 = Color3.new(1, 1, 1)
	slot.BackgroundTransparency = 0.93
	corner(slot, 8)
	local ring = new("Frame", { Position = UDim2.fromOffset(2, 2), Size = UDim2.new(1, -4, 1, -4), BackgroundTransparency = 1 }, slot)
	corner(ring, 6)
	local outline = stroke(ring, CONFIG.Accent, 2, 1)
	local icon = itemIcon(slot, 52, UDim2.fromScale(0.5, 0.5))
	local count = text(slot, {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -7, 1, -6),
		Size = UDim2.fromOffset(40, 18),
		TextSize = 26 / CONFIG.FontScale,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 2,
	})
	local bar = makeBar(slot)
	backpackSlots[index] = { Holder = holder, Button = slot, Stroke = outline, Icon = icon, Count = count, Bar = bar }
end

local craftPanel = panel(panels, "CraftingPanel", INV_W + PANEL_GAP, 0, CRAFT_W, 560)
craftPanel.Active = true
text(craftPanel, { Position = UDim2.fromOffset(19, 7), Size = UDim2.fromOffset(200, 36), Text = "Crafting", TextSize = 30 })

local closeButton = textButton(craftPanel, {
	Name = "Close",
	Position = UDim2.new(1, -59, 0, 17),
	Size = UDim2.fromOffset(41, 41),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BackgroundTransparency = 0.93,
})
corner(closeButton, 18)
for _, rotation in ipairs({ 45, -45 }) do
	local line = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(3, 16),
		Rotation = rotation,
		BackgroundColor3 = CONFIG.Text,
		BorderSizePixel = 0,
	}, closeButton)
	corner(line, 2)
end

local categoryButtons = {}
do
	local tabTextSize = 30 / CONFIG.FontScale
	local tabHeight = 40
	local right = -59 - 8
	for index = #CATEGORY_ORDER, 1, -1 do
		local name = CATEGORY_ORDER[index]
		local width = math.ceil(textWidth(name, tabTextSize)) + 30
		right -= width
		local tab = textButton(craftPanel, {
			Name = name .. "Tab",
			Position = UDim2.new(1, right, 0, 17 + (41 - tabHeight) / 2),
			Size = UDim2.fromOffset(width, tabHeight),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.93,
			Text = name,
			TextSize = tabTextSize,
		})
		corner(tab, tabHeight / 2)
		categoryButtons[name] = tab
		right -= 8
	end
end

local strips = {}
for _, category in ipairs(CATEGORY_ORDER) do
	local strip = new("ScrollingFrame", {
		Name = "ItemStrip",
		Position = UDim2.fromOffset(20, 73),
		Size = UDim2.new(1, -40, 0, 112),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollingDirection = Enum.ScrollingDirection.X,
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 4,
		ScrollBarImageColor3 = CONFIG.Text,
		ScrollBarImageTransparency = 0.7,
		ElasticBehavior = Enum.ElasticBehavior.Never,
		Visible = category == selectedCategory,
	}, craftPanel)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
	}, strip)
	strips[category] = strip
end

local recipeTiles = {}
for _, category in ipairs(CATEGORY_ORDER) do
	for order, recipe in ipairs(RECIPES[category]) do
		local tile = textButton(strips[category], {
			Name = recipe.id,
			LayoutOrder = order,
			Size = UDim2.fromOffset(90, 100),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.95,
		})
		corner(tile, 10)
		local outlineHolder = new("Frame", { Position = UDim2.fromOffset(2, 2), Size = UDim2.new(1, -4, 1, -4), BackgroundTransparency = 1 }, tile)
		corner(outlineHolder, 8)
		local outline = stroke(outlineHolder, CONFIG.Accent, 2, 1)
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
		local icon = itemIcon(iconHolder, 66, UDim2.new(0.5, -2, 0.5, 2))
		icon.Set(recipe.id)
		local nameSize = 25 / CONFIG.FontScale
		local nameLines = 1
		local nameHolder = new("Frame", { LayoutOrder = 2, Size = UDim2.new(1, 0, 0, 20 * nameLines), BackgroundTransparency = 1 }, content)
		local nameLabel = text(nameHolder, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 2),
			Size = UDim2.new(1, -4, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Text = ITEMS[recipe.id].Name,
			TextSize = nameSize,
			LineHeight = 0.82,
			TextWrapped = false,
			TextXAlignment = Enum.TextXAlignment.Center,
		})
		local badge = new("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -5, 0, 5),
			Size = UDim2.fromOffset(18, 18),
			BackgroundColor3 = CONFIG.Accent,
			BorderSizePixel = 0,
			Visible = false,
			ZIndex = 3,
		}, tile)
		corner(badge, 9)
		local badgeText = text(badge, {
			Size = UDim2.fromScale(1, 1),
			TextSize = 11,
			TextColor3 = CONFIG.DarkText,
			TextXAlignment = Enum.TextXAlignment.Center,
			ZIndex = 3,
		})
		local pop = new("UIScale", {}, tile)
		recipeTiles[recipe.id] = { Button = tile, Stroke = outline, Icon = icon, NameLabel = nameLabel, Badge = badge, BadgeText = badgeText, Category = category, Pop = pop }
	end
end

local preview = new("Frame", {
	Name = "Preview",
	Position = UDim2.fromOffset(20, 198),
	Size = UDim2.new(0.5, -28, 0, 342),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BackgroundTransparency = 0.95,
	BorderSizePixel = 0,
}, craftPanel)
corner(preview, 12)
local previewIconHolder = new("Frame", { AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.fromOffset(156, 164), BackgroundTransparency = 1 }, preview)
local previewIcon = itemIcon(previewIconHolder, 156, UDim2.fromOffset(78, 91))
local previewNameHolder = new("Frame", { Name = "NameHolder", AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.new(1, -25, 0, 31), BackgroundTransparency = 1 }, preview)
local previewName = text(previewNameHolder, {
	Position = UDim2.fromOffset(0, 16),
	Size = UDim2.fromScale(1, 1),
	TextSize = 39,
	TextXAlignment = Enum.TextXAlignment.Center,
})
local previewCategoryHolder = new("Frame", { Name = "CategoryHolder", AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.new(1, -24, 0, 22), BackgroundTransparency = 1 }, preview)
local previewCategory = text(previewCategoryHolder, {
	Position = UDim2.fromOffset(0, 30),
	Size = UDim2.fromScale(1, 1),
	TextSize = 32 / CONFIG.FontScale,
	TextTransparency = 0.3,
	TextXAlignment = Enum.TextXAlignment.Center,
})
local previewDescHolder = new("Frame", { Name = "DescHolder", AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.fromOffset(240, 0), BackgroundTransparency = 1 }, preview)
local previewDesc = text(previewDescHolder, {
	Position = UDim2.fromOffset(0, 13),
	Size = UDim2.fromScale(1, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	TextSize = 32 / CONFIG.FontScale,
	TextTransparency = 0.15,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextYAlignment = Enum.TextYAlignment.Top,
})
new("UIPadding", { PaddingTop = UDim.new(0, 12) }, previewDesc)

local function layoutPreview()
	local descHeight = 0
	if previewDesc.Text ~= "" then
		descHeight = TextService:GetTextSize(previewDesc.Text, previewDesc.TextSize, CONFIG.FontEnum, Vector2.new(240, 2000)).Y
	end
	local descHolderHeight = 13 + 12 + descHeight
	local gap = 4
	local total = 164 + 31 + 22 + descHolderHeight + gap * 3
	local y = (342 - total) / 2
	previewIconHolder.Position = UDim2.new(0.5, 0, 0, y)
	y += 164 + gap
	previewNameHolder.Position = UDim2.new(0.5, 0, 0, y)
	y += 31 + gap
	previewCategoryHolder.Position = UDim2.new(0.5, 0, 0, y)
	y += 22 + gap
	previewDescHolder.Position = UDim2.new(0.5, 0, 0, y)
	previewDescHolder.Size = UDim2.fromOffset(240, descHolderHeight)
end

local right = new("Frame", {
	Name = "Requirements",
	Position = UDim2.new(0.5, 8, 0, 198),
	Size = UDim2.new(0.5, -28, 0, 342),
	BackgroundTransparency = 1,
}, craftPanel)
text(right, { Size = UDim2.new(1, 0, 0, 20), Text = "Required materials", TextSize = 30 / CONFIG.FontScale, TextTransparency = 0.3 })

local materialRows = {}
for index = 1, 3 do
	local row = new("Frame", {
		Position = UDim2.fromOffset(0, 31 + (index - 1) * 60),
		Size = UDim2.new(1, 0, 0, 52),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.94,
		BorderSizePixel = 0,
		Visible = false,
	}, right)
	corner(row, 10)
	local icon = itemIcon(row, 42, UDim2.fromOffset(32, 26))
	local name = text(row, { Position = UDim2.fromOffset(64, 4), Size = UDim2.fromOffset(149, 20), TextSize = 30 / CONFIG.FontScale })
	local status = text(row, { Position = UDim2.fromOffset(65, 28), Size = UDim2.fromOffset(150, 16), TextSize = 24 / CONFIG.FontScale })
	local amount = text(row, {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -13, 0, -1),
		Size = UDim2.fromOffset(80, 52),
		TextSize = 22,
		TextXAlignment = Enum.TextXAlignment.Right,
	})
	materialRows[index] = { Row = row, Icon = icon, Name = name, Status = status, Amount = amount }
end

local noRecipe = new("Frame", {
	Position = UDim2.fromOffset(0, 31),
	Size = UDim2.new(1, 0, 0, 56),
	BackgroundTransparency = 1,
	Visible = false,
}, right)
corner(noRecipe, 10)
stroke(noRecipe, CONFIG.Text, 2, 0.8)
text(noRecipe, { Position = UDim2.fromOffset(16, 0), Size = UDim2.new(1, -32, 0, 56), Text = "Recipe not set yet", TextTransparency = 0.25 })

local queuedLabel = text(right, { Position = UDim2.fromOffset(0, 256), Size = UDim2.fromOffset(180, 26), TextSize = 17, TextTransparency = 0.3 })
local clearButton = textButton(right, {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, 0, 0, 256),
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
	Size = UDim2.new(1, 0, 0, 52),
	BackgroundColor3 = CONFIG.Accent,
	TextSize = 32,
	Text = "Craft",
})
corner(craftButton, 12)

local HOTBAR_SLOT, HOTBAR_GAP = 62, 6
local BAG_SLOT = HOTBAR_SLOT * 0.8
local HOTBAR_W = 8 * HOTBAR_SLOT + 8 * HOTBAR_GAP + BAG_SLOT

local hotbarGroup = new("Frame", {
	Name = "HotbarGroup",
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -9),
	Size = UDim2.fromOffset(HOTBAR_W, HOTBAR_SLOT),
	BackgroundTransparency = 1,
}, gui)
local hotbarScale = new("UIScale", {}, hotbarGroup)

local hotbar = new("Frame", {
	Name = "Hotbar",
	Size = UDim2.fromOffset(HOTBAR_W, HOTBAR_SLOT),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
}, hotbarGroup)

local function hotbarBox(parent, name, index, size)
	size = size or HOTBAR_SLOT
	local box = textButton(parent, {
		Name = name,
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, (index - 1) * (HOTBAR_SLOT + HOTBAR_GAP), 0.5, 0),
		Size = UDim2.fromOffset(size, size),
		BackgroundColor3 = CONFIG.PanelColor,
		BackgroundTransparency = 0.45,
	})
	corner(box, 4)
	return box
end

local hotbarSlots = {}
for index = 1, HOTBAR_COUNT do
	local holder, slot = makeSlotHolder(hotbar, "Hotbar" .. index, {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, (index - 1) * (HOTBAR_SLOT + HOTBAR_GAP), 0.5, 0),
		Size = UDim2.fromOffset(HOTBAR_SLOT, HOTBAR_SLOT),
	})
	slot.BackgroundColor3 = CONFIG.PanelColor
	slot.BackgroundTransparency = 0.45
	corner(slot, 4)
	local ring = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1 }, slot)
	corner(ring, 4)
	local outline = stroke(ring, CONFIG.Accent, 2, 1)
	local icon = itemIcon(slot, 48 * HOTBAR_SLOT / 72, UDim2.fromScale(0.5, 0.5))
	local count = text(slot, {
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -5, 1, -3),
		Size = UDim2.fromOffset(40, 16),
		TextSize = 22 / CONFIG.FontScale,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 2,
	})
	local bar = makeBar(slot)
	hotbarSlots[index] = { Holder = holder, Button = slot, Stroke = outline, Icon = icon, Count = count, Bar = bar }
end

local keyboard = UserInputService.KeyboardEnabled
local openButton = hotbarBox(hotbarGroup, "OpenInventory", 9, BAG_SLOT)
do
	new("ImageLabel", {
		Name = "BagIcon",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(BAG_SLOT * 0.58, BAG_SLOT * 0.58),
		BackgroundTransparency = 1,
		Image = CONFIG.BagIcon,
		ScaleType = Enum.ScaleType.Fit,
	}, openButton)
	if keyboard then
		text(openButton, { AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 0, -2), Size = UDim2.fromOffset(40, 14), Text = "TAB", TextSize = 11, TextTransparency = 0.35, TextXAlignment = Enum.TextXAlignment.Center })
	end
end


local hotName = text(gui, {
	Name = "HeldItemName",
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -105),
	Size = UDim2.fromOffset(400, 24),
	TextSize = 32 / CONFIG.FontScale,
	TextTransparency = 1,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextStrokeTransparency = 1,
})
local hotNameScale = new("UIScale", {}, hotName)

local crosshair = new("Frame", {
	Name = "Crosshair",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(18, 18),
	BackgroundTransparency = 1,
}, gui)
new("Frame", { Position = UDim2.fromOffset(8, 0), Size = UDim2.fromOffset(2, 18), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.3, BorderSizePixel = 0 }, crosshair)
new("Frame", { Position = UDim2.fromOffset(0, 8), Size = UDim2.fromOffset(18, 2), BackgroundColor3 = Color3.new(1, 1, 1), BackgroundTransparency = 0.3, BorderSizePixel = 0 }, crosshair)

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

local function applyStretch(k)
	if dashesBuilt and math.abs(k - stretch) < 0.001 then
		return
	end
	dashesBuilt = true
	stretch = k
	local invW = INV_W * k
	local craftW = CRAFT_W * k
	MENU_W = invW + PANEL_GAP + craftW
	CRAFT_HOME = UDim2.fromOffset(invW + PANEL_GAP, 0)
	canvas.Size = UDim2.fromOffset(MENU_W, MENU_H)
	invPanel.Size = UDim2.fromOffset(invW - 1, MENU_H + INV_EXTRA_H)
	craftPanel.Size = UDim2.fromOffset(craftW, MENU_H)
	invPanel.Position = INV_HOME
	craftPanel.Position = CRAFT_HOME
	for _, tile in pairs(recipeTiles) do
		tile.Button.Size = UDim2.fromOffset(90 * k, 100)
	end
	local slotSide = (invW - 1) / 6 - 40 / 3
	for index, slot in ipairs(backpackSlots) do
		local column = (index - 1) % 6
		local row = math.floor((index - 1) / 6)
		slot.Holder.Position = UDim2.new(column / 6, 20 - column * 16 / 3, 0, 208 + row * (slotSide + 8))
		slot.Holder.Size = UDim2.new(1 / 6, -40 / 3, 0, slotSide)
	end
end

local function updateScale()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local viewport = camera.ViewportSize
	local topInset = GuiService:GetGuiInset().Y

	local sc = math.min(viewport.X / CONFIG.DesignWidth, viewport.Y / CONFIG.DesignHeight)
	for _, uiScale in ipairs(hudScales) do
		uiScale.Scale = sc
	end

	local touchOnly = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	local hb = sc * (touchOnly and CONFIG.HotbarTouchBoost or CONFIG.HotbarBoost)
	hotbarScale.Scale = hb
	hotNameScale.Scale = sc
	hotbarGroup.Position = UDim2.new(0.5, 0, 1, -9 * hb)
	hotName.Position = UDim2.new(0.5, 0, 1, -(9 + HOTBAR_SLOT) * hb - 11 * sc)

	progressHome = UDim2.new(1, -12 * sc, 0, 12 * sc)
	progressAway = UDim2.new(1, 12 * sc, 0, 12 * sc)
	progress.Position = progress.Visible and progressHome or progressAway

	local gap = 8 * sc
	local top = math.max(topInset, 48 * sc) + 2 * sc
	local bottom = viewport.Y - (14 + HOTBAR_SLOT) * hb - (28 + INV_EXTRA_H) * sc
	local availH = math.max(100, bottom - top)
	local availW = viewport.X - gap * 2
	local fitH = math.min(sc, availH / MENU_H)
	applyStretch(math.clamp((viewport.X * CONFIG.MenuWidthFraction / fitH - PANEL_GAP) / (INV_W + CRAFT_W), 1, CONFIG.MaxWidthStretch))
	local menuScale = math.min(fitH, availW / MENU_W)
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

local function setOutline(ui, on, instant)
	if ui.Outlined == on then
		return
	end
	ui.Outlined = on
	if ui.OutlineTween then
		ui.OutlineTween:Cancel()
		ui.OutlineTween = nil
	end
	if instant then
		ui.Stroke.Transparency = on and 0 or 1
	else
		ui.OutlineTween = tween(ui.Stroke, CONFIG.SelectFade, { Transparency = on and 0 or 1 }, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	end
end

local function validatePick()
	if not pick then
		return
	end
	local entry = slotsOf(pick.area)[pick.i]
	if not entry then
		pick = nil
	elseif pick.n and pick.n >= entry.n then
		pick.n = nil
	end
end

local function renderSlot(ui, area, index)
	local entry = slotsOf(area)[index]
	local hidden = (ui.Hidden or 0) > 0
	local dragging = hold and hold.drag and hold.area == area and hold.i == index
	ui.Icon.Set((entry and not hidden) and entry.id or nil)
	local dim = dragging and not hold.dragAmount or false
	if ui.Dimmed ~= dim then
		ui.Dimmed = dim
		if ui.DimTween then
			ui.DimTween:Cancel()
		end
		ui.DimTween = tween(ui.Icon.Image, dim and 0.1 or 0.25, { ImageTransparency = dim and 0.35 or 0 }, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	end
	local holding = hold and hold.shown and hold.area == area and hold.i == index
	local picked = pick ~= nil and pick.area == area and pick.i == index
	local amount = nil
	if holding and hold.kind == "pick" then
		amount = hold.amount
	elseif picked and pick.n then
		amount = pick.n
	end
	if hidden then
		ui.Count.Text = ""
	elseif ui.FrozenCount then
		ui.Count.Text = ui.FrozenCount
		ui.Count.TextColor3 = CONFIG.Text
	elseif dragging and hold.dragAmount and entry then
		local left = entry.n - hold.dragAmount
		ui.Count.Text = left > 1 and tostring(left) or ""
		ui.Count.TextColor3 = CONFIG.Text
	elseif entry and amount then
		ui.Count.Text = amount .. "/" .. entry.n
		ui.Count.TextColor3 = CONFIG.Accent
	else
		ui.Count.Text = (entry and entry.n > 1) and tostring(entry.n) or ""
		ui.Count.TextColor3 = CONFIG.Text
	end
	if holding and hold.kind == "throw" then
		setBar(ui.Bar, "throw", hold.progress)
	elseif entry and amount then
		setBar(ui.Bar, "pick", amount / entry.n)
	else
		setBar(ui.Bar, nil)
	end
	local hovered = hoverKey == area .. index
	local outlined = picked or (holding and hold.kind == "pick") or hovered or (pc ~= nil and pc.marks[area .. index] == true)
	if area == "hb" and selectedHotbar == index then
		outlined = true
	end
	setOutline(ui, outlined, hovered ~= (ui.Hovered or false) or snapOutlines)
	ui.Hovered = hovered
end

local function headerText()
	local area, index, amount
	if hold and hold.shown and hold.kind == "pick" then
		area, index, amount = hold.area, hold.i, hold.amount
	elseif pick then
		area, index, amount = pick.area, pick.i, pick.n
	end
	if not area then
		return ""
	end
	local entry = slotsOf(area)[index]
	if not entry then
		return ""
	end
	local name = ITEMS[entry.id].Name
	if amount then
		return name .. "  " .. amount .. " / " .. entry.n
	end
	return name .. "  x" .. entry.n
end

local function refreshInventory()
	validatePick()
	local used = 0
	for index, ui in ipairs(backpackSlots) do
		if bp[index] then
			used += 1
		end
		renderSlot(ui, "bp", index)
	end
	usedLabel.Text = used .. " / " .. CONFIG.BackpackSlots
	for slotName, ui in pairs(equipSlots) do
		local item = worn[slotName]
		local hidden = (ui.Hidden or 0) > 0
		ui.WornIcon.Set((item and not hidden) and item.id or nil)
		if ui.Faded then
			ui.Faded.Visible = item == nil or hidden
		end
		ui.HoverStroke.Transparency = hoverKey == "eq" .. slotName and 0 or 1
	end
	invInfo.Text = headerText()
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

	for category, strip in pairs(strips) do
		strip.Visible = category == selectedCategory
	end

	local recipe = currentRecipe()
	for id, tile in pairs(recipeTiles) do
		local on = id == recipe.id
		local n = queuedCount(id)
		tile.Stroke.Transparency = on and 0 or 1
		tile.Button.BackgroundTransparency = on and 0.88 or 0.95
		local faded = maxCraftable(findRecipe(id)) == 0 and n == 0
		tile.Icon.SetFaded(faded)
		tile.NameLabel.TextTransparency = faded and 0.55 or 0
		tile.Badge.Visible = n > 0
		tile.BadgeText.Text = "x" .. n
		tile.Badge.Size = UDim2.fromOffset(math.max(18, math.ceil(textWidth("x" .. n, 11)) + 8), 18)
	end

	local item = ITEMS[recipe.id]
	previewIcon.Set(recipe.id)
	previewName.Text = item.Name
	previewCategory.Text = selectedCategory
	previewDesc.Text = item.Desc or ""
	layoutPreview()

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
	validatePick()
	for index, ui in ipairs(hotbarSlots) do
		renderSlot(ui, "hb", index)
	end
	local held = hb[selectedHotbar]
	hotName.Text = held and ITEMS[held.id].Name or ""
	invInfo.Text = headerText()
end

local function refreshSlots()
	refreshInventory()
	refreshHotbar()
end

local progressState = "hidden"
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
		local entry = bp[index]
		if entry and entry.id == id and not slot.Outlined then
			slot.Stroke.Transparency = 0
			tween(slot.Stroke, 0.6, { Transparency = 1 })
		end
	end
end

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
		draining = true
	end
	finishing = nil
	showProgress()
	refreshSlots()
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
local controls = nil
local frozen = false
local cameraBefore = nil
local function freeze(on)
	if controls and frozen ~= on then
		if on then
			controls:Disable()
		else
			controls:Enable()
		end
	end
	frozen = on
	local camera = workspace.CurrentCamera
	if on then
		if not cameraBefore then
			cameraBefore = camera.CameraType
		end
		camera.CameraType = Enum.CameraType.Scriptable
	elseif cameraBefore then
		camera.CameraType = cameraBefore
		cameraBefore = nil
	end
end
task.spawn(function()
	local ok, module = pcall(function()
		return require(player:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule", 10))
	end)
	if ok and module then
		controls = module:GetControls()
		if frozen then
			controls:Disable()
		end
	end
end)
local menuTweens = {}
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

local fadeEntries = {}
local fadeActive = false
local fadeValue = new("NumberValue", { Name = "MenuFade", Value = 1 }, gui)
local textFadeValue = new("NumberValue", { Name = "MenuTextFade", Value = 1 }, gui)

local function applyFade(a, textA)
	for _, entry in ipairs(fadeEntries) do
		local object = entry[1]
		for prop, base in pairs(entry[2]) do
			object[prop] = 1 - (1 - base) * a
		end
		if entry[3] then
			for prop, base in pairs(entry[3]) do
				object[prop] = 1 - (1 - base) * textA
			end
		end
	end
end

local function endFade()
	if fadeActive then
		applyFade(1, 1)
		fadeActive = false
	end
end

local function startFade()
	endFade()
	table.clear(fadeEntries)
	for _, d in ipairs(panels:GetDescendants()) do
		local props, textProps = nil, nil
		if d:IsA("GuiObject") then
			props = { BackgroundTransparency = d.BackgroundTransparency }
			if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
				textProps = { TextTransparency = d.TextTransparency, TextStrokeTransparency = d.TextStrokeTransparency }
			elseif d:IsA("ImageLabel") or d:IsA("ImageButton") then
				props.ImageTransparency = d.ImageTransparency
			end
			if d:IsA("ScrollingFrame") then
				props.ScrollBarImageTransparency = d.ScrollBarImageTransparency
			end
		elseif d:IsA("UIStroke") then
			props = { Transparency = d.Transparency }
		end
		if props then
			table.insert(fadeEntries, { d, props, textProps })
		end
	end
	fadeActive = true
end

local function onFadeChanged()
	if fadeActive then
		applyFade(fadeValue.Value, textFadeValue.Value)
	end
end
fadeValue.Changed:Connect(onFadeChanged)
textFadeValue.Changed:Connect(onFadeChanged)

local menuLockUntil = 0
local function setOpen(open)
	if isOpen == open and panels.Visible == open then
		return
	end
	if os.clock() < menuLockUntil then
		return
	end
	menuLockUntil = os.clock() + (open and 0.26 or 0.18) + 0.1
	isOpen = open
	modal.Visible = open
	if not open then
		if hold and hold.drag then
			motion:ghostCancel()
		end
		motion:pillHide()
		motion:finishAll()
		if pc then
			pc.close()
		end
		hoverKey = nil
		pick = nil
		hold = nil
	end
	snapOutlines = not open
	refreshSlots()
	snapOutlines = false
	crosshair.Visible = not open
	freeze(open)

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
		refreshSlots()
		refreshCrafting()
		invPanel.Position = INV_HOME
		craftPanel.Position = CRAFT_HOME
		startFade()
		fadeValue.Value = 0
		textFadeValue.Value = 0
		applyFade(0, 0)
		panelsScale.Scale = 0.985
		panels.Visible = true
		dim.Visible = true
		menuTween(panelsScale, 0.26, { Scale = 1 }, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		menuTween(fadeValue, 0.2, { Value = 1 }, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		local fadeIn = TweenService:Create(textFadeValue, TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Value = 1 })
		fadeIn:Play()
		table.insert(menuTweens, fadeIn)
		menuTween(dim, 0.2, { BackgroundTransparency = CONFIG.DimTransparency }, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		menuTween(blur, 0.2, { Size = CONFIG.BlurSize }, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		fadeIn.Completed:Once(function(state)
			if state == Enum.PlaybackState.Completed and isOpen then
				endFade()
			end
		end)
	else
		startFade()
		fadeValue.Value = 1
		textFadeValue.Value = 1
		menuTween(textFadeValue, 0.07, { Value = 0 }, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
		local out = TweenService:Create(panelsScale, TweenInfo.new(0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.In, 0, false, 0.06), { Scale = 0.96 })
		out:Play()
		table.insert(menuTweens, out)
		menuTween(fadeValue, 0.18, { Value = 0 }, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
		menuTween(dim, 0.16, { BackgroundTransparency = 1 }, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
		menuTween(blur, 0.16, { Size = 0 }, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
		out.Completed:Once(function(state)
			if state == Enum.PlaybackState.Completed and not isOpen then
				panels.Visible = false
				dim.Visible = false
				endFade()
			end
		end)
	end
end

local hotNameToken = 0
local hotNameTweens = {}
local function flashHotName()
	hotNameToken += 1
	local token = hotNameToken
	for _, t in ipairs(hotNameTweens) do
		t:Cancel()
	end
	table.clear(hotNameTweens)
	if hb[selectedHotbar] then
		hotName.TextTransparency = 0
		hotName.TextStrokeTransparency = 0.7
		task.delay(2, function()
			if token ~= hotNameToken then
				return
			end
			table.insert(hotNameTweens, tween(hotName, 0.12, { TextStrokeTransparency = 1 }, Enum.EasingStyle.Linear))
			table.insert(hotNameTweens, tween(hotName, 0.25, { TextTransparency = 1 }, Enum.EasingStyle.Sine, Enum.EasingDirection.Out))
		end)
	else
		hotName.TextTransparency = 1
		hotName.TextStrokeTransparency = 1
	end
end

local function selectHotbar(index)
	selectedHotbar = index
	refreshHotbar()
	flashHotName()

end

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
		selectedCategory = name
		selectedRecipe = RECIPES[name][1].id
		strips[name].CanvasPosition = Vector2.zero
		refreshCrafting()

	end)
end

for id, tile in pairs(recipeTiles) do
	connect(tile.Button.Activated, function()
		selectedRecipe = id
		refreshCrafting()
	end)
end

local function showToast(id, message)
	motion:toast(id, message)
end

local function afterItemsChanged()
	refreshSlots()
	refreshCrafting()
end

local function dropPicked()
	if not pick then
		return
	end
	local list = slotsOf(pick.area)
	local entry = list[pick.i]
	if entry then
		local amount = pick.n or entry.n
		entry.n -= amount
		if entry.n <= 0 then
			list[pick.i] = nil
		end
	end
	pick = nil
	afterItemsChanged()
end

local function throwHotbar(index)
	local entry = hb[index]
	if not entry then
		return
	end
	hb[index] = nil
	afterItemsChanged()
end

local function slotUi(area, index)
	return area == "bp" and backpackSlots[index] or hotbarSlots[index]
end

local function centerOf(object)
	return object.AbsolutePosition + object.AbsoluteSize / 2
end

local function flyInto(id, fromAbs, ui, picture, hide, fromGhost)
	if hide then
		ui.Hidden = (ui.Hidden or 0) + 1
	end
	local function land(snap)
		if hide then
			ui.Hidden = math.max(0, (ui.Hidden or 1) - 1)
		end
		ui.FrozenCount = nil
		refreshSlots()
		if not snap then
			if ui.Count and ui.Count.Text ~= "" then
				ui.Count.TextTransparency = 1
				tween(ui.Count, 0.2, { TextTransparency = 0 }, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
			end
		end
	end
	if fromGhost then
		motion:ghostTo(centerOf(picture), picture.AbsoluteSize, DROP_IN_TIME, land)
	else
		motion:fly(id, fromAbs, centerOf(picture), picture.AbsoluteSize, land)
	end
end

local function moveTo(area, index, fromGhost)
	motion:finishAll()
	local fromList = slotsOf(pick.area)
	local from = fromList[pick.i]
	if not from then
		pick = nil
		refreshSlots()
		return false
	end
	local srcUi, dstUi = slotUi(pick.area, pick.i), slotUi(area, index)
	local toList = slotsOf(area)
	local to = toList[index]
	local id = from.id
	local fromAbs = centerOf(srcUi.Icon.Image)
	local swapped = nil
	if pick.n then
		if to and to.id ~= from.id then
			pick = nil
			refreshSlots()
			return false
		end
		if to then
			dstUi.FrozenCount = dstUi.Count.Text
			to.n += pick.n
		else
			toList[index] = { id = id, n = pick.n }
		end
		from.n -= pick.n
		if from.n <= 0 then
			fromList[pick.i] = nil
		end
	else
		if not to then
			toList[index] = from
			fromList[pick.i] = nil
		elseif to.id == from.id then
			dstUi.FrozenCount = dstUi.Count.Text
			to.n += from.n
			fromList[pick.i] = nil
		else
			toList[index] = from
			fromList[pick.i] = to
			swapped = to
		end
	end
	flyInto(id, fromAbs, dstUi, dstUi.Icon.Image, to == nil or swapped ~= nil, fromGhost)
	if swapped then
		flyInto(swapped.id, centerOf(dstUi.Icon.Image), srcUi, srcUi.Icon.Image, true, false)
	end
	pick = nil
	afterItemsChanged()
	return true
end

local function tapSlot(area, index)
	if area == "hb" then
		if not isOpen then
			selectHotbar(index)
		end
		return
	end
	if not isOpen then
		return
	end
	local entry = slotsOf(area)[index]
	if not pick then
		if entry then
			pick = { area = area, i = index }
			refreshSlots()
		end
		return
	end
	if pick.area == area and pick.i == index then
		pick = nil
		refreshSlots()
		return
	end
	moveTo(area, index)
end

local function tapEquip(slotName, fromGhost, force)
	if not isOpen or (not fromGhost and not force and os.clock() < tapGuardUntil) then
		return false
	end
	local ui = equipSlots[slotName]
	if pick then
		local list = slotsOf(pick.area)
		local entry = list[pick.i]
		if not (entry and ITEMS[entry.id].Wear == slotName) then
			return false
		end
		motion:finishAll()
		local srcUi = slotUi(pick.area, pick.i)
		local fromAbs = centerOf(srcUi.Icon.Image)
		local old = worn[slotName]
		worn[slotName] = { id = entry.id, n = 1 }
		entry.n -= 1
		if entry.n <= 0 then
			list[pick.i] = nil
		end
		flyInto(entry.id, fromAbs, ui, ui.WornIcon.Image, true, fromGhost)
		if old then
			if not list[pick.i] then
				list[pick.i] = old
				flyInto(old.id, centerOf(ui.WornIcon.Image), srcUi, srcUi.Icon.Image, true, false)
			else
				addItem(old.id, old.n)
			end
		end
		pick = nil
		afterItemsChanged()
		return true
	end
	local item = worn[slotName]
	if not item then
		return false
	end
	for index = 1, CONFIG.BackpackSlots do
		if not bp[index] then
			motion:finishAll()
			local fromAbs = centerOf(ui.WornIcon.Image)
			bp[index] = item
			worn[slotName] = nil
			flyInto(item.id, fromAbs, backpackSlots[index], backpackSlots[index].Icon.Image, true, false)
			afterItemsChanged()
			return true
		end
	end
	showToast(item.id, "Backpack is full")
	return false
end

local slotLookup = {}
for index, ui in ipairs(backpackSlots) do
	slotLookup[ui.Button] = { area = "bp", i = index }
end
for index, ui in ipairs(hotbarSlots) do
	slotLookup[ui.Button] = { area = "hb", i = index }
end
for slotName, ui in pairs(equipSlots) do
	slotLookup[ui.Button] = { equip = slotName }
end

local function overPanels(position)
	for _, frame in ipairs({ invPanel, craftPanel, hotbarGroup }) do
		local p, size = frame.AbsolutePosition, frame.AbsoluteSize
		if position.X >= p.X and position.X <= p.X + size.X and position.Y >= p.Y and position.Y <= p.Y + size.Y then
			return true
		end
	end
	return false
end

local function dragHover(h)
	local entry = slotsOf(h.area)[h.i]
	if not entry then
		return
	end
	local target = motion:hit(h.lastPos, slotLookup, gui)
	local key = nil
	h.target = nil
	if target then
		if target.equip then
			if ITEMS[entry.id].Wear == target.equip then
				key = "eq" .. target.equip
				h.target = target
			end
		elseif not (target.area == h.area and target.i == h.i) then
			key = target.area .. target.i
			h.target = target
		end
	end
	h.world = target == nil and not overPanels(h.lastPos)
	if h.world then
		motion:pillShow("Release to drop " .. (h.dragAmount or entry.n) .. " " .. ITEMS[entry.id].Name)
	else
		motion:pillHide()
	end
	if key ~= hoverKey then
		hoverKey = key
		refreshSlots()
	end
end

local function startDrag(h, entry, position)
	local amount = nil
	if pick and pick.area == h.area and pick.i == h.i and pick.n then
		amount = pick.n
	end
	pick = nil
	h.drag = true
	h.dragAmount = amount
	h.lastPos = position
	h.touch = h.input.UserInputType == Enum.UserInputType.Touch
	motion:finishAll()
	motion:ghostStart(entry.id, slotUi(h.area, h.i).Icon.Image.AbsoluteSize, amount or entry.n)
	motion:ghostMove(position, h.touch)
	dragHover(h)
	refreshSlots()
end

local function finishDrag(h)
	hoverKey = nil
	motion:pillHide()
	local entry = slotsOf(h.area)[h.i]
	local srcUi = slotUi(h.area, h.i)
	if entry then
		pick = { area = h.area, i = h.i, n = h.dragAmount }
		if h.target and h.target.equip then
			if tapEquip(h.target.equip, true) then
				return
			end
		elseif h.target then
			if moveTo(h.target.area, h.target.i, true) then
				return
			end
		elseif h.world then
			motion:ghostDrop()
			dropPicked()
			return
		end
	end
	pick = nil
	motion:ghostTo(centerOf(srcUi.Icon.Image), srcUi.Icon.Image.AbsoluteSize, FLY_TIME, nil)
	refreshSlots()
end

local function designScale(area)
	if area == "hb" then
		return hotbarScale.Scale
	end
	return canvasScale.Scale * panelsScale.Scale
end

local function isPointer(input)
	return input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1
end

local function beginPress(area, index, input)
	if hold then
		return
	end
	if isOpen and pc and input.UserInputType == Enum.UserInputType.MouseButton1 and pc.press({ area = area, i = index }, "left", input) then
		return
	end
	if area == "bp" and not isOpen then
		return
	end
	local entry = slotsOf(area)[index]
	local kind = nil
	if isOpen then
		if entry and entry.n >= 2 and not pick and area == "bp" and input.UserInputType == Enum.UserInputType.Touch then
			kind = "pick"
		end
	elseif area == "hb" and entry then
		kind = "throw"
	end
	hold = {
		area = area,
		i = index,
		input = input,
		start = Vector2.new(input.Position.X, input.Position.Y),
		t0 = os.clock(),
		kind = kind,
		total = entry and entry.n or 0,
		amount = 1,
		progress = 0,
		shown = false,
		mode = "pending",
	}
end

local function holdMoved(position)
	local h = hold
	if not h or h.cancelled or h.done then
		return
	end
	if h.drag then
		h.lastPos = position
		dragHover(h)
		return
	end
	local delta = position - h.start
	if not h.shown then
		if delta.Magnitude > DRAG_START_PX then
			local entry = slotsOf(h.area)[h.i]
			if isOpen and entry then
				startDrag(h, entry, position)
			else
				h.cancelled = true
			end
		end
		return
	end
	if h.kind ~= "pick" then
		return
	end
	if h.mode == "auto" and math.abs(delta.X) > 6 then
		h.mode = "slide"
		h.slideX = position.X
		h.slideAmount = h.amount
	end
	if h.mode == "slide" then
		local perItem = math.clamp(SLIDE_PX / h.total, SLIDE_MIN, SLIDE_MAX)
		local moved = (position.X - h.slideX) / math.max(designScale(h.area), 0.01) / perItem
		local steps = moved >= 0 and math.floor(moved) or math.ceil(moved)
		local amount = math.clamp(h.slideAmount + steps, 1, h.total)
		if amount ~= h.amount then
			h.amount = amount
			refreshSlots()
		end
	end
end

local function endPress()
	local h = hold
	hold = nil
	if not h then
		return
	end
	local now = os.clock()
	if h.cancelled then
		refreshSlots()
		return
	end
	if h.drag then
		tapGuardUntil = now + TAP_GUARD
		finishDrag(h)
		return
	end
	if h.done or h.shown then
		tapGuardUntil = now + TAP_GUARD
		if not h.done and h.kind == "pick" then
			pick = { area = h.area, i = h.i, n = h.amount < h.total and h.amount or nil }
		end
		refreshSlots()
		return
	end
	if now < tapGuardUntil then
		return
	end
	if isOpen and pc and h.input.UserInputType == Enum.UserInputType.MouseButton1 then
		pc.click(h.area, h.i)
		return
	end
	tapSlot(h.area, h.i)
end

local function updateHold()
	local h = hold
	if h and h.drag then
		motion:ghostMove(h.lastPos, h.touch)
		return
	end
	if not h or h.cancelled or h.done or not h.kind then
		return
	end
	local now = os.clock()
	if h.kind == "pick" then
		if not h.shown then
			if now - h.t0 >= HOLD_DELAY then
				h.shown = true
				h.mode = "auto"
				h.amount = 1
				h.stepAt = now
				refreshSlots()
			end
		elseif h.mode == "auto" and h.amount < h.total then
			local step = math.clamp(HOLD_FILL / h.total, 0.06, 0.25)
			local changed = false
			while h.amount < h.total and now - h.stepAt >= step do
				h.amount += 1
				h.stepAt += step
				changed = true
			end
			if changed then
				refreshSlots()
			end
		end
	elseif h.kind == "throw" then
		local elapsed = now - h.t0
		if elapsed >= THROW_DELAY then
			h.shown = true
			h.progress = math.clamp((elapsed - THROW_DELAY) / THROW_TIME, 0, 1)
			renderSlot(hotbarSlots[h.i], "hb", h.i)
			if h.progress >= 1 then
				h.done = true
				throwHotbar(h.i)
			end
		end
	end
end

pc = motion:attachPC({
	bp = bp,
	hb = hb,
	worn = worn,
	backpackSlots = backpackSlots,
	slotLookup = slotLookup,
	gui = gui,
	dim = dim,
	isOpen = function()
		return isOpen
	end,
	changed = afterItemsChanged,
	refresh = refreshSlots,
	addItem = addItem,
	setHover = function(key)
		if hoverKey ~= key then
			hoverKey = key
			refreshSlots()
		end
	end,
	equip = function(index)
		local entry = bp[index]
		if entry and ITEMS[entry.id].Wear then
			pick = { area = "bp", i = index }
			tapEquip(ITEMS[entry.id].Wear, false, true)
			pick = nil
		end
	end,
	unequip = function(slotName)
		pick = nil
		tapEquip(slotName, false, true)
	end,
})

for index, ui in ipairs(backpackSlots) do
	connect(ui.Button.InputBegan, function(input)
		if isPointer(input) then
			beginPress("bp", index, input)
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 and pc then
			pc.press({ area = "bp", i = index }, "right", input)
		end
	end)
end

for index, ui in ipairs(hotbarSlots) do
	connect(ui.Button.InputBegan, function(input)
		if isPointer(input) then
			beginPress("hb", index, input)
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 and pc then
			pc.press({ area = "hb", i = index }, "right", input)
		end
	end)
end

for slotName, ui in pairs(equipSlots) do
	connect(ui.Button.Activated, function(input)
		if input and input.UserInputType == Enum.UserInputType.MouseButton1 and pc and pc.press({ equip = slotName }, "left", input) then
			return
		end
		tapEquip(slotName)
	end)
end

connect(dim.Activated, function()
	if isOpen and pick and os.clock() >= tapGuardUntil then
		dropPicked()
	end
end)

connect(UserInputService.InputChanged, function(input)
	if not hold then
		return
	end
	if input == hold.input or (input.UserInputType == Enum.UserInputType.MouseMovement and hold.input.UserInputType == Enum.UserInputType.MouseButton1) then
		holdMoved(Vector2.new(input.Position.X, input.Position.Y))
	end
end)

connect(UserInputService.InputEnded, function(input)
	if not hold then
		return
	end
	if input == hold.input or (input.UserInputType == Enum.UserInputType.MouseButton1 and hold.input.UserInputType == Enum.UserInputType.MouseButton1) then
		endPress()
	end
end)

connect(RunService.RenderStepped, updateHold)

connect(craftButton.Activated, function()
	local recipe = currentRecipe()
	if maxCraftable(recipe) < 1 then
		return
	end
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
	if slot and not isOpen then
		selectHotbar(slot)
	end
end)

connect(RunService.Heartbeat, function(dt)
	local job = queue[1]
	if job then
		if not unitStarted then

			local ok = true
			for _, mat in ipairs(job.mats) do
				if countItem(mat[1]) < mat[2] then
					ok = false
					break
				end
			end
			if ok then
				for _, mat in ipairs(job.mats) do
					removeItem(mat[1], mat[2])
				end
				unitStarted = true
				unitElapsed = 0
			else
				table.remove(queue, 1)
			end
			refreshSlots()
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
					draining = true
					popAmount()
					updateProgressText()
				else
					draining = false
					displayedFill = 1
					finishProgress(job)
				end
				refreshSlots()
				refreshCrafting()
				flashItem(job.id)
			end
		end
	end

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
	freeze(false)
end)

refreshSlots()
refreshCrafting()
refreshHotbar()
isOpen = true
setOpen(false)
panels.Visible = false
dim.Visible = false

if CONFIG.Tuner then
	local tunerModule = script:FindFirstChild("Tuner")
	if tunerModule then
		require(tunerModule)(gui, CONFIG, ITEMS)
	end
end
