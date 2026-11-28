local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local existing = playerGui:FindFirstChild("HorizonForgeUI")
if existing then
	existing:Destroy()
end

pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
end)

local SHOW_TEST_BUTTONS = true

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
	BackpackSlots = 24,
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

	ForgeSlots = 16,
	DoubleTapTime = 0.35,
	ForgeTitle = "Refining Forge",
	TestFuelItems = { planks = true },
	TestBurnTime = 16,
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

local HOLD_DELAY = 0.30
local HOLD_FILL = 1.20
local SLIDE_PX = 200
local SLIDE_MIN = 8
local SLIDE_MAX = 30
local TAP_GUARD = 0.25
local FLY_TIME = 0.18
local FLY_START = 1.12
local DRAG_START_PX = 10
local DRAG_SCALE = 1.15
local DRAG_TOUCH_UP = 36
local DROP_IN_TIME = 0.12
local CORAL = Color3.fromRGB(244, 164, 124)

local HOTBAR_SLOT = 62
local bp = {}
local worn = {}
do
	local start = { { "planks", 12 }, { "stone", 9 }, { "leaves", 14 }, { "rope", 3 }, { "fiber", 6 }, { "scrap", 2 }, { "hide", 3 }, { "cup_clean", 1 } }
	for index, entry in ipairs(start) do
		bp[index] = { id = entry[1], n = entry[2] }
	end
end

local forge = { Id = nil, Size = CONFIG.ForgeSlots, Slots = {}, HasFuel = false, Burning = false, TimeLeft = 0 }
do
	local start = { { "stone", 9 }, { "stone", 9 }, { "planks", 12 }, { "cup_clean", 1 } }
	for index, entry in ipairs(start) do
		forge.Slots[index] = { id = entry[1], n = entry[2] }
	end
end
local storage = forge

local ForgeHooks = {}

function ForgeHooks.OpenForge(forgeId) end

function ForgeHooks.MoveToForge(slot, amount) end

function ForgeHooks.TakeFromForge(slot, amount) end

function ForgeHooks.TakeAll() end

function ForgeHooks.LightFire() end

function ForgeHooks.PutOutFire() end

local pick = nil
local hold = nil
local tapGuardUntil = 0
local isOpen = false
local lastTap = nil

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

local function slotsOf(area)
	return area == "bp" and bp or storage.Slots
end

local function sizeOf(area)
	return area == "bp" and CONFIG.BackpackSlots or storage.Size
end

local function addItem(id, amount)
	for index = 1, CONFIG.BackpackSlots do
		local entry = bp[index]
		if entry and entry.id == id then
			entry.n += amount
			return true
		end
	end
	for index = 1, CONFIG.BackpackSlots do
		if not bp[index] then
			bp[index] = { id = id, n = amount }
			return true
		end
	end
	return false
end

local gui = new("ScreenGui", {
	Name = "HorizonForgeUI",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 11,
}, playerGui)


local motion = require(script:WaitForChild("ForgeModule")).new(gui, CONFIG, ITEMS, {
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

local blur = Lighting:FindFirstChild("HorizonForgeBlur") or new("BlurEffect", { Name = "HorizonForgeBlur" }, Lighting)
blur.Size = 0

local INV_W, STORAGE_W, PANEL_GAP = 464, 464, 20
local MENU_W, MENU_H = INV_W + PANEL_GAP + STORAGE_W, 560
local INV_HOME, STORAGE_HOME = UDim2.fromOffset(0, 0), UDim2.fromOffset(INV_W + PANEL_GAP, 0)
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

local storagePanel = panel(panels, "ForgePanel", INV_W + PANEL_GAP, 0, STORAGE_W, 560)
storagePanel.Active = true
for _, child in ipairs(invPanel:GetChildren()) do
	if child:IsA("TextLabel") and child.Text == "Inventory" then
		local forgeTitle = child:Clone()
		forgeTitle.Name = "ForgeTitle"
		forgeTitle.Text = CONFIG.ForgeTitle
		forgeTitle.Parent = storagePanel
		break
	end
end

local headerRight = new("Frame", {
	Name = "HeaderRight",
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -71, 0, 10),
	Size = UDim2.fromOffset(0, 32),
	AutomaticSize = Enum.AutomaticSize.X,
	BackgroundTransparency = 1,
}, storagePanel)
new("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Right,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	SortOrder = Enum.SortOrder.LayoutOrder,
	Padding = UDim.new(0, 16),
}, headerRight)
local forgeStatus = text(headerRight, {
	LayoutOrder = 1,
	Size = UDim2.fromOffset(0, 32),
	AutomaticSize = Enum.AutomaticSize.X,
	TextSize = 30 / CONFIG.FontScale,
	TextColor3 = CONFIG.Accent,
	Visible = false,
})
local storageCount = text(storagePanel, {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -20, 0, 63),
	Size = UDim2.fromOffset(120, 24),
	TextSize = 28 / CONFIG.FontScale,
	TextTransparency = 0.3,
	TextXAlignment = Enum.TextXAlignment.Right,
})

local closeButton = textButton(storagePanel, {
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

local GRID_TOP = 92
local BUTTON_Y = 560 + INV_EXTRA_H - 20 - 52

local storageSlots = {}
for index = 1, CONFIG.ForgeSlots do
	local holder, slot = makeSlotHolder(storagePanel, "Forge" .. index, {
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
	storageSlots[index] = { Holder = holder, Button = slot, Stroke = outline, Icon = icon, Count = count, Bar = bar }
end

text(storagePanel, {
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 0, BUTTON_Y - 14),
	Size = UDim2.new(1, -40, 0, 44),
	Text = "Requires fuel to activate. Put unrefined resources in this to refine them.",
	TextSize = 21 / CONFIG.FontScale,
	TextTransparency = 0.4,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextYAlignment = Enum.TextYAlignment.Bottom,
})

local fireButton = textButton(storagePanel, {
	Name = "Fire",
	Position = UDim2.fromOffset(20, BUTTON_Y),
	Size = UDim2.new(0.5, -26, 0, 52),
	BackgroundColor3 = CONFIG.Accent,
	TextColor3 = CONFIG.DarkText,
	TextSize = 32,
	Text = "Light fire",
})
corner(fireButton, 12)
local takeAllButton = textButton(storagePanel, {
	Name = "TakeAll",
	Position = UDim2.new(0.5, 6, 0, BUTTON_Y),
	Size = UDim2.new(0.5, -26, 0, 52),
	BackgroundColor3 = CONFIG.Accent,
	TextColor3 = CONFIG.DarkText,
	TextSize = 32,
	Text = "Take all",
})
corner(takeAllButton, 12)

local confirmShade = new("TextButton", {
	Name = "ConfirmShade",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Color3.new(0, 0, 0),
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	AutoButtonColor = false,
	Text = "",
	Visible = false,
	ZIndex = 20,
}, gui)
local confirmBox = new("Frame", {
	Name = "Confirm",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Size = UDim2.fromOffset(444, 200),
	BackgroundColor3 = Color3.fromRGB(10, 13, 12),
	BackgroundTransparency = 0.05,
	BorderSizePixel = 0,
	Active = true,
	Visible = false,
	ZIndex = 21,
}, gui)
corner(confirmBox, 14)
local confirmScale = new("UIScale", {}, confirmBox)
local confirmTitle = text(confirmBox, {
	Position = UDim2.fromOffset(20, 18),
	Size = UDim2.new(1, -40, 0, 34),
	TextSize = 38 / CONFIG.FontScale,
	TextXAlignment = Enum.TextXAlignment.Center,
	ZIndex = 22,
})
local confirmBody = text(confirmBox, {
	Position = UDim2.fromOffset(22, 60),
	Size = UDim2.new(1, -44, 0, 50),
	TextSize = 22 / CONFIG.FontScale,
	TextTransparency = 0.15,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextYAlignment = Enum.TextYAlignment.Top,
	ZIndex = 22,
})
local confirmCancel = textButton(confirmBox, {
	Name = "Cancel",
	Position = UDim2.new(0, 22, 1, -70),
	Size = UDim2.new(0.5, -28, 0, 48),
	BackgroundColor3 = Color3.new(1, 1, 1),
	BackgroundTransparency = 0.93,
	TextSize = 26 / CONFIG.FontScale,
	Text = "Cancel",
	ZIndex = 22,
})
corner(confirmCancel, 12)
local confirmOk = textButton(confirmBox, {
	Name = "Confirm",
	Position = UDim2.new(0.5, 6, 1, -70),
	Size = UDim2.new(0.5, -28, 0, 48),
	BackgroundColor3 = CONFIG.Accent,
	TextColor3 = CONFIG.DarkText,
	TextSize = 26 / CONFIG.FontScale,
	Text = "",
	ZIndex = 22,
})
corner(confirmOk, 12)

local confirmArea = nil
local confirmFade = new("NumberValue", { Value = 0 }, confirmBox)
local function applyConfirmFade()
	local a = confirmFade.Value
	confirmShade.BackgroundTransparency = 1 - 0.45 * a
	confirmBox.BackgroundTransparency = 1 - 0.95 * a
	confirmTitle.TextTransparency = 1 - a
	confirmBody.TextTransparency = 1 - 0.85 * a
	confirmCancel.BackgroundTransparency = 1 - 0.07 * a
	confirmCancel.TextTransparency = 1 - a
	confirmOk.BackgroundTransparency = 1 - a
	confirmOk.TextTransparency = 1 - a
end
confirmFade.Changed:Connect(applyConfirmFade)

local function hideConfirm(instant)
	confirmArea = nil
	if instant then
		confirmFade.Value = 0
		confirmShade.Visible = false
		confirmBox.Visible = false
		return
	end
	local out = tween(confirmFade, 0.12, { Value = 0 }, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
	out.Completed:Once(function(state)
		if state == Enum.PlaybackState.Completed and not confirmArea then
			confirmShade.Visible = false
			confirmBox.Visible = false
		end
	end)
end

local function askMoveAll(area)
	local count = 0
	for index = 1, sizeOf(area) do
		if slotsOf(area)[index] then
			count += 1
		end
	end
	if count == 0 then
		return
	end
	confirmArea = area
	local take = area == "st"
	confirmTitle.Text = take and "Take everything?" or "Store everything?"
	confirmBody.Text = "Are you sure? This will move all " .. count .. " item" .. (count == 1 and "" or "s")
		.. (take and " from the forge to your backpack." or " from your backpack to storage.")
	confirmOk.Text = take and "Take all" or "Store all"
	confirmScale.Scale = canvasScale.Scale * 1.25
	confirmBox.Position = canvas.Position
	confirmShade.Visible = true
	confirmBox.Visible = true
	tween(confirmFade, 0.15, { Value = 1 }, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
end

local testButtons = nil
if SHOW_TEST_BUTTONS then
	testButtons = new("Frame", {
		Name = "TestButtons",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 16, 0.5, 0),
		Size = UDim2.fromOffset(90, 78),
		BackgroundTransparency = 1,
	}, gui)
	new("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6) }, testButtons)
end

local slotSide = BACKPACK_SLOT_H

local function layoutStorageSlots()
	for index, slot in ipairs(storageSlots) do
		local column = (index - 1) % 6
		local row = math.floor((index - 1) / 6)
		slot.Holder.Position = UDim2.new(column / 6, 20 - column * 16 / 3, 0, GRID_TOP + row * (slotSide + 8))
		slot.Holder.Size = UDim2.new(1 / 6, -40 / 3, 0, slotSide)
	end
end

local function applyStretch(k)
	if dashesBuilt and math.abs(k - stretch) < 0.001 then
		return
	end
	dashesBuilt = true
	stretch = k
	local invW = INV_W * k
	local storageW = STORAGE_W * k
	MENU_W = invW + PANEL_GAP + storageW
	STORAGE_HOME = UDim2.fromOffset(invW + PANEL_GAP, 0)
	canvas.Size = UDim2.fromOffset(MENU_W, MENU_H)
	invPanel.Size = UDim2.fromOffset(invW - 1, MENU_H + INV_EXTRA_H)
	storagePanel.Size = UDim2.fromOffset(storageW - 1, MENU_H + INV_EXTRA_H)
	invPanel.Position = INV_HOME
	storagePanel.Position = STORAGE_HOME
	slotSide = (invW - 1) / 6 - 40 / 3
	for index, slot in ipairs(backpackSlots) do
		local column = (index - 1) % 6
		local row = math.floor((index - 1) / 6)
		slot.Holder.Position = UDim2.new(column / 6, 20 - column * 16 / 3, 0, 208 + row * (slotSide + 8))
		slot.Holder.Size = UDim2.new(1 / 6, -40 / 3, 0, slotSide)
	end
	layoutStorageSlots()
end

local function updateScale()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local viewport = camera.ViewportSize
	local topInset = GuiService:GetGuiInset().Y
	local sc = math.min(viewport.X / CONFIG.DesignWidth, viewport.Y / CONFIG.DesignHeight)
	local touchOnly = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
	local hb = sc * (touchOnly and CONFIG.HotbarTouchBoost or CONFIG.HotbarBoost)
	local gap = 8 * sc
	local top = math.max(topInset, 48 * sc) + 2 * sc
	local bottom = viewport.Y - (14 + HOTBAR_SLOT) * hb - (28 + INV_EXTRA_H) * sc
	local availH = math.max(100, bottom - top)
	local availW = viewport.X - gap * 2
	local fitH = math.min(sc, availH / MENU_H)
	applyStretch(math.clamp((viewport.X * CONFIG.MenuWidthFraction / fitH - PANEL_GAP) / (INV_W + STORAGE_W), 1, CONFIG.MaxWidthStretch))
	local menuScale = math.min(fitH, availW / MENU_W)
	canvasScale.Scale = menuScale
	local snapped = math.floor((INV_W * stretch + PANEL_GAP) * menuScale + 0.5) / menuScale
	STORAGE_HOME = UDim2.fromOffset(snapped, 0)
	storagePanel.Position = STORAGE_HOME
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
end

local function isTouchInput()
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function updateHints()
	local area = nil
	if hold and hold.shown and hold.kind == "pick" then
		area = hold.area
	elseif pick then
		area = pick.area
	end
	local header = headerText()
	local fromBackpack = header ~= "" and area == "bp"
	invInfo.Text = fromBackpack and header or ((isTouchInput() and "Tap" or "Click") .. " ore or fuel to put it in")
	invInfo.TextTransparency = fromBackpack and 0 or 0.3
end

local function formatTime(seconds)
	seconds = math.max(0, math.ceil(seconds))
	return string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
end

local function refreshForgeState()
	forgeStatus.Visible = forge.Burning
	forgeStatus.Text = "Refining... (" .. formatTime(forge.TimeLeft) .. ")"
	local can = forge.HasFuel or forge.Burning
	fireButton.Active = can
	fireButton.Text = forge.Burning and "Put out fire" or (forge.HasFuel and "Light fire" or "No fuel")
	fireButton.BackgroundColor3 = can and CONFIG.Accent or Color3.new(1, 1, 1)
	fireButton.BackgroundTransparency = can and 0 or 0.92
	fireButton.TextColor3 = can and CONFIG.DarkText or CONFIG.Text
	fireButton.TextTransparency = can and 0 or 0.5
end

local function testFuelCheck()
	if not SHOW_TEST_BUTTONS then
		return
	end
	local hasFuel = false
	for index = 1, forge.Size do
		local entry = forge.Slots[index]
		if entry and CONFIG.TestFuelItems[entry.id] then
			hasFuel = true
		end
	end
	forge.HasFuel = hasFuel
	if not hasFuel then
		forge.Burning = false
	end
end

local function refreshStorage()
	local used = 0
	for index, ui in ipairs(storageSlots) do
		if forge.Slots[index] then
			used += 1
		end
		renderSlot(ui, "st", index)
	end
	storageCount.Text = used .. " / " .. forge.Size
	testFuelCheck()
	refreshForgeState()
end

local function refreshSlots()
	refreshInventory()
	refreshStorage()
	updateHints()
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
local function setOpen(open, kind)
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
	if testButtons then
		testButtons.Visible = not open
	end
	if not open then
		hideConfirm(true)
	end
	snapOutlines = not open
	refreshSlots()
	snapOutlines = false
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
		forge.Id = kind
		lastTap = nil
		ForgeHooks.OpenForge(kind)
		updateScale()
		layoutStorageSlots()
		refreshSlots()
		invPanel.Position = INV_HOME
		storagePanel.Position = STORAGE_HOME
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

local connections = {}
local function connect(signal, fn)
	local c = signal:Connect(fn)
	table.insert(connections, c)
	return c
end

local function showToast(id, message)
	motion:toast(id, message)
end

local function afterItemsChanged()
	refreshSlots()
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

local function slotUi(area, index)
	return area == "bp" and backpackSlots[index] or storageSlots[index]
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
	local srcArea, srcIndex, srcAmount = pick.area, pick.i, pick.n or from.n
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
	if srcArea == "bp" and area == "st" then
		ForgeHooks.MoveToForge(srcIndex, srcAmount)
	elseif srcArea == "st" and area == "bp" then
		ForgeHooks.TakeFromForge(srcIndex, srcAmount)
	end
	pick = nil
	afterItemsChanged()
	return true
end

local function quickMove(area, index, keepFlyers, instant, amount)
	local fromList = slotsOf(area)
	local entry = fromList[index]
	if not entry then
		return false
	end
	if not keepFlyers then
		motion:finishAll()
	end
	local toArea = area == "bp" and "st" or "bp"
	local toList, toSize = slotsOf(toArea), sizeOf(toArea)
	local fromAbs = centerOf(slotUi(area, index).Icon.Image)
	local id = entry.id
	local moved = false
	local count = math.clamp(amount or entry.n, 1, entry.n)
	local rest = entry.n - count
	entry.n = count
	for i = 1, toSize do
		local target = toList[i]
		if target and target.id == id then
			local dst = slotUi(toArea, i)
			if not instant then
				dst.FrozenCount = dst.FrozenCount or dst.Count.Text
			end
			target.n += entry.n
			entry.n = 0
			if instant then
				dst.FrozenCount = nil
			else
				flyInto(id, fromAbs, dst, dst.Icon.Image, false, false)
			end
			moved = true
			break
		end
	end
	if entry.n > 0 then
		for i = 1, toSize do
			if not toList[i] then
				toList[i] = { id = id, n = entry.n }
				entry.n = 0
				if not instant then
					local dst = slotUi(toArea, i)
					flyInto(id, fromAbs, dst, dst.Icon.Image, true, false)
				end
				moved = true
				break
			end
		end
	end
	local done = count - entry.n
	entry.n += rest
	if entry.n <= 0 then
		fromList[index] = nil
	end
	if pick and pick.area == area and pick.i == index then
		pick = nil
	end
	if done > 0 and not instant then
		if area == "bp" then
			ForgeHooks.MoveToForge(index, done)
		else
			ForgeHooks.TakeFromForge(index, done)
		end
	elseif not instant then
		showToast(id, toArea == "bp" and "Backpack is full" or "Forge is full")
	end
	return moved
end

local function moveAll(area)
	motion:finishAll()
	pick = nil
	ForgeHooks.TakeAll()
	for index = 1, sizeOf(area) do
		if slotsOf(area)[index] then
			quickMove(area, index, true, true)
		end
	end
	afterItemsChanged()
end

local function tapSlot(area, index)
	if not isOpen then
		return
	end
	local now = os.clock()
	local entry = slotsOf(area)[index]
	local double = lastTap ~= nil and lastTap.area == area and lastTap.i == index and now - lastTap.t < CONFIG.DoubleTapTime
	lastTap = { area = area, i = index, t = now }
	if double and entry then
		lastTap = nil
		pick = nil
		if quickMove(area, index) then
			afterItemsChanged()
		else
			refreshSlots()
		end
		return
	end
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
for index, ui in ipairs(storageSlots) do
	slotLookup[ui.Button] = { area = "st", i = index }
end
for slotName, ui in pairs(equipSlots) do
	slotLookup[ui.Button] = { equip = slotName }
end

local function overPanels(position)
	for _, frame in ipairs({ invPanel, storagePanel }) do
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

local function designScale()
	return canvasScale.Scale * panelsScale.Scale
end

local function isPointer(input)
	return input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1
end

local function beginPress(area, index, input)
	if hold or not isOpen then
		return
	end
	if pc and input.UserInputType == Enum.UserInputType.MouseButton1 and pc.press({ area = area, i = index }, "left", input) then
		return
	end
	local entry = slotsOf(area)[index]
	local kind = nil
	if entry and entry.n >= 2 and not pick and input.UserInputType == Enum.UserInputType.Touch then
		kind = "pick"
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
		local moved = (position.X - h.slideX) / math.max(designScale(), 0.01) / perItem
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
	end
end

pc = motion:attachPC({
	bp = bp,
	list = slotsOf,
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
	quickMove = function(area, index)
		if quickMove(area, index) then
			afterItemsChanged()
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

for index, ui in ipairs(storageSlots) do
	connect(ui.Button.InputBegan, function(input)
		if isPointer(input) then
			beginPress("st", index, input)
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 and pc then
			pc.press({ area = "st", i = index }, "right", input)
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

connect(closeButton.Activated, function()
	setOpen(false)
end)
connect(takeAllButton.Activated, function()
	if isOpen and not confirmArea then
		askMoveAll("st")
	end
end)
connect(fireButton.Activated, function()
	if not isOpen then
		return
	end
	if forge.Burning then
		ForgeHooks.PutOutFire()
		if SHOW_TEST_BUTTONS then
			forge.Burning = false
		end
	elseif forge.HasFuel then
		ForgeHooks.LightFire()
		if SHOW_TEST_BUTTONS then
			forge.Burning = true
			forge.TimeLeft = CONFIG.TestBurnTime
		end
	end
	refreshForgeState()
end)
connect(confirmCancel.Activated, function()
	if confirmArea then
		hideConfirm()
	end
end)
connect(confirmOk.Activated, function()
	local area = confirmArea
	if area and isOpen then
		hideConfirm()
		moveAll(area)
	end
end)

if testButtons then
	local button = textButton(testButtons, {
		Name = "Forge",
		Size = UDim2.fromOffset(90, 36),
		BackgroundColor3 = CONFIG.PanelColor,
		BackgroundTransparency = 0.4,
		TextSize = 22 / CONFIG.FontScale,
		Text = "Forge",
	})
	corner(button, 8)
	connect(button.Activated, function()
		if not isOpen then
			setOpen(true, "TestForge")
		end
	end)
end

connect(UserInputService.InputBegan, function(input)
	if UserInputService:GetFocusedTextBox() then
		return
	end
	if input.KeyCode == CONFIG.ToggleKey and isOpen then
		setOpen(false)
	end
end)

connect(RunService.Heartbeat, function(dt)
	if SHOW_TEST_BUTTONS and forge.Burning then
		forge.TimeLeft -= dt
		if forge.TimeLeft <= 0 then
			forge.TimeLeft = CONFIG.TestBurnTime
		end
		if isOpen then
			forgeStatus.Text = "Refining... (" .. formatTime(forge.TimeLeft) .. ")"
		end
	end
end)

local openEvent = new("BindableEvent", { Name = "OpenForge" }, gui)
local closeEvent = new("BindableEvent", { Name = "CloseForge" }, gui)
local stateEvent = new("BindableEvent", { Name = "SetForgeState" }, gui)
connect(openEvent.Event, function(forgeId)
	if not isOpen then
		setOpen(true, forgeId)
	end
end)
connect(closeEvent.Event, function()
	if isOpen then
		setOpen(false)
	end
end)
connect(stateEvent.Event, function(state)
	if type(state) ~= "table" then
		return
	end
	if type(state.Items) == "table" then
		table.clear(forge.Slots)
		for index = 1, forge.Size do
			local entry = state.Items[index]
			if entry and entry.id and (entry.n or 0) > 0 then
				forge.Slots[index] = { id = entry.id, n = entry.n }
			end
		end
	end
	if state.HasFuel ~= nil then
		forge.HasFuel = state.HasFuel == true
	end
	if state.Burning ~= nil then
		forge.Burning = state.Burning == true
	end
	if type(state.TimeLeft) == "number" then
		forge.TimeLeft = state.TimeLeft
	end
	refreshSlots()
end)

gui.Destroying:Connect(function()
	for _, c in ipairs(connections) do
		c:Disconnect()
	end
	if cameraConnection then
		cameraConnection:Disconnect()
	end
	cameraWatch:Disconnect()
	blur:Destroy()
	if touchControlsBefore ~= nil then
		GuiService.TouchControlsEnabled = touchControlsBefore
	end
	freeze(false)
end)

refreshSlots()
isOpen = true
setOpen(false)
panels.Visible = false
dim.Visible = false
