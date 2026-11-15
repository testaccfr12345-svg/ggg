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
	BackpackSlots = 26,
	BarResetSpeed = 35,
	BlurSize = 12,
	DimTransparency = 0.16,
	DimColor = Color3.fromRGB(12, 11, 6),
	MaxWidthStretch = 1.2,
	HotbarBoost = 1,
	HotbarTouchBoost = 1.3,
	MenuWidthFraction = 0.878,

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

local inventory = { planks = 12, stone = 9, leaves = 14, rope = 3, fiber = 6, scrap = 2, hide = 3, cup_clean = 1 }
local inventoryOrder = { "planks", "stone", "leaves", "rope", "fiber", "scrap", "hide", "cup_clean" }
local hotbarItems = { "stone_axe", "torch", "cup_sea", false, false, false, false, false }

local selectedCategory = "Tools"
local selectedRecipe = "stone_pickaxe"
local selectedSlot = nil
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

local function escapeRich(str)
	return (str:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function renderSpacing(label)
	local px = label:GetAttribute("LetterSpacing") or 0
	local raw = label:GetAttribute("RawText") or ""
	local out
	if px <= 0 then
		out = escapeRich(raw)
	else
		local gap = '<font size="' .. math.max(1, math.floor(px * 5 + 0.5)) .. '"> </font>'
		local chars = {}
		for _, code in utf8.codes(raw) do
			table.insert(chars, escapeRich(utf8.char(code)))
		end
		out = table.concat(chars, gap)
	end
	label:SetAttribute("RenderedText", out)
	label.Text = out
end

local function letterSpacing(label, px)
	if label:GetAttribute("RawText") == nil then
		label:SetAttribute("RawText", label.Text)
		label.RichText = true
		label:GetPropertyChangedSignal("Text"):Connect(function()
			if label.Text ~= label:GetAttribute("RenderedText") then
				label:SetAttribute("RawText", label.Text)
				renderSpacing(label)
			end
		end)
	end
	label:SetAttribute("LetterSpacing", math.max(0, px))
	renderSpacing(label)
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
	BackgroundColor3 = CONFIG.DimColor,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
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
local INV_EXTRA_H = 12
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
for index, slotName in ipairs({ "Helmet", "Chest", "Legs", "Boots", "Gloves" }) do
	local layout = EQUIP_LAYOUT[slotName]
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
	local image = CONFIG.EquipmentIcons[slotName]
	if image and image ~= "" then
		new("ImageLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0, layout[2]),
			Size = UDim2.fromOffset(layout[1], layout[1]),
			BackgroundTransparency = 1,
			Image = image,
			ImageTransparency = 0.45,
		}, slot)
	end
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

local backpackSlots = {}
for index = 1, CONFIG.BackpackSlots do
	local column = (index - 1) % 6
	local row = math.floor((index - 1) / 6)
	local slot = textButton(invPanel, {
		Name = "Slot" .. index,
		Position = UDim2.new(column / 6, 20 - column * 16 / 3, 0, 208 + row * 72),
		Size = UDim2.new(1 / 6, -40 / 3, 0, 64),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.93,
	})
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
	local pop = new("UIScale", {}, slot)
	backpackSlots[index] = { Button = slot, Stroke = outline, Icon = icon, Count = count, Item = nil, Pop = pop }
end

local craftPanel = panel(panels, "CraftingPanel", INV_W + PANEL_GAP, 0, CRAFT_W, 560)
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
		Position = UDim2.fromOffset(20, 72),
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
local craftButtonScale = new("UIScale", {}, craftButton)

local HOTBAR_SLOT, HOTBAR_GAP = 72, 8
local HOTBAR_W = 9 * HOTBAR_SLOT + 8 * HOTBAR_GAP
local HOTBAR_BORDER = Color3.fromRGB(237, 232, 220)

local hotbarGroup = new("Frame", {
	Name = "HotbarGroup",
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -14),
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

local function hotbarBox(parent, name, index)
	local box = textButton(parent, {
		Name = name,
		Position = UDim2.fromOffset((index - 1) * (HOTBAR_SLOT + HOTBAR_GAP), 0),
		Size = UDim2.fromOffset(HOTBAR_SLOT, HOTBAR_SLOT),
		BackgroundColor3 = CONFIG.PanelColor,
		BackgroundTransparency = 0.45,
	})
	corner(box, 4)
	local ring = new("Frame", { BackgroundTransparency = 1 }, box)
	local ringCorner = new("UICorner", {}, ring)
	local ringStroke = stroke(ring, HOTBAR_BORDER, 1, 0.86)
	local function setBorder(selected)
		local width = selected and 2 or 1
		ring.Position = UDim2.fromOffset(width, width)
		ring.Size = UDim2.new(1, -2 * width, 1, -2 * width)
		ringCorner.CornerRadius = UDim.new(0, math.max(0, 4 - width))
		ringStroke.Thickness = width
		ringStroke.Color = selected and CONFIG.Accent or HOTBAR_BORDER
		ringStroke.Transparency = selected and 0 or 0.86
		box.BackgroundTransparency = selected and 0.22 or 0.45
	end
	setBorder(false)
	return box, setBorder
end

local hotbarSlots = {}
for index = 1, 8 do
	local slot, setBorder = hotbarBox(hotbar, "Hotbar" .. index, index)
	local icon = itemIcon(slot, 48, UDim2.fromScale(0.5, 0.5))
	hotbarSlots[index] = { Button = slot, SetBorder = setBorder, Icon = icon }
end

local keyboard = UserInputService.KeyboardEnabled
local openButton, setOpenBorder = hotbarBox(hotbarGroup, "OpenInventory", 9)
do
	local k = 26 / 28
	local line = 2.2 * k
	local origin = HOTBAR_SLOT / 2 - 13
	local bag = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(origin + 14 * k, origin + 16.5 * k),
		Size = UDim2.fromOffset((18 - 2.2) * k, (15 - 2.2) * k),
		BackgroundTransparency = 1,
	}, openButton)
	corner(bag, 3.4 * k)
	stroke(bag, CONFIG.Text, line, 0)
	local handle = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromOffset(origin + 14 * k, origin + (9 - 1.1) * k),
		Size = UDim2.fromOffset((8 - 2.2) * k, (5.5 - 2.2) * k),
		BackgroundTransparency = 1,
	}, openButton)
	corner(handle, 3 * k)
	stroke(handle, CONFIG.Text, line, 0)
	local strap = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(origin + 14 * k, origin + 16.5 * k),
		Size = UDim2.fromOffset(10 * k + line, line),
		BackgroundColor3 = CONFIG.Text,
		BorderSizePixel = 0,
	}, openButton)
	corner(strap, 1)
	if keyboard then
		text(openButton, { Position = UDim2.fromOffset(5, 1), Size = UDim2.fromOffset(40, 16), Text = "TAB", TextSize = 11, TextTransparency = 0.35 })
	end
end

local hotName = text(gui, {
	Name = "HeldItemName",
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -97),
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
	hotbarGroup.Position = UDim2.new(0.5, 0, 1, -14 * hb)
	hotName.Position = UDim2.new(0.5, 0, 1, -(14 + HOTBAR_SLOT) * hb - 3 * sc)

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
	invInfo.Text = selectedId and (ITEMS[selectedId].Name .. " x" .. inventory[selectedId]) or ""
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
		tile.Badge.Size = UDim2.fromOffset(math.max(28, math.ceil(textWidth("x" .. n, 14)) + 12), 20)
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
	for index, slot in ipairs(hotbarSlots) do
		local id = hotbarItems[index]
		slot.Icon.Set(id or nil)
		local on = selectedHotbar == index
		slot.SetBorder(on)
	end
	local held = hotbarItems[selectedHotbar]
	hotName.Text = held and ITEMS[held].Name or ""
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
		if slot.Item == id and selectedSlot ~= index then
			slot.Stroke.Color = CONFIG.Accent
			slot.Stroke.Transparency = 0
			tween(slot.Stroke, 0.6, { Transparency = 1 })
			slot.Pop.Scale = 1.12
			tween(slot.Pop, 0.2, { Scale = 1 }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
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

	setOpenBorder(open)

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

local hotNameToken = 0
local hotNameTweens = {}
local function flashHotName()
	hotNameToken += 1
	local token = hotNameToken
	for _, t in ipairs(hotNameTweens) do
		t:Cancel()
	end
	table.clear(hotNameTweens)
	if hotbarItems[selectedHotbar] then
		hotName.TextTransparency = 0
		hotName.TextStrokeTransparency = 0.7
		task.delay(1.2, function()
			if token ~= hotNameToken then
				return
			end
			table.insert(hotNameTweens, tween(hotName, 0.4, { TextTransparency = 1, TextStrokeTransparency = 1 }))
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

for index, slot in ipairs(backpackSlots) do
	connect(slot.Button.Activated, function()
		selectedSlot = slot.Item and index or nil
		refreshInventory()
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

connect(RunService.Heartbeat, function(dt)
	local job = queue[1]
	if job then
		if not unitStarted then

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
					draining = true
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

refreshInventory()
refreshCrafting()
refreshHotbar()
isOpen = true
setOpen(false)
panels.Visible = false
dim.Visible = false

local function startTuner()
	local target = gui
	local oldTuner = playerGui:FindFirstChild("HorizonUITuner")
	if oldTuner then
		oldTuner:Destroy()
	end

	local T_ACCENT = Color3.fromRGB(233, 185, 73)
	local T_TEXT = Color3.fromRGB(237, 232, 220)
	local T_BG = Color3.fromRGB(16, 21, 19)
	local T_FONT = Enum.Font.GothamMedium
	local T_STEPS = { 1, 0.1, 2, 5, 10 }
	local W = 236

	local tunerGui = Instance.new("ScreenGui")
	tunerGui.Name = "HorizonUITuner"
	tunerGui.ResetOnSpawn = false
	tunerGui.IgnoreGuiInset = true
	tunerGui.DisplayOrder = 1000
	tunerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	tunerGui.Parent = playerGui

	local function make(className, props, parent)
		local o = Instance.new(className)
		for k, v in pairs(props) do
			o[k] = v
		end
		o.Parent = parent
		return o
	end
	local function round(parent, r)
		make("UICorner", { CornerRadius = UDim.new(0, r) }, parent)
	end

	local catcher = make("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Visible = false,
		ZIndex = 1,
	}, tunerGui)
	local highlight = make("Frame", { BackgroundTransparency = 1, Visible = false, ZIndex = 2 }, tunerGui)
	make("UIStroke", { Color = T_ACCENT, Thickness = 2 }, highlight)

	local panel = make("Frame", {
		Position = UDim2.fromOffset(12, 60),
		Size = UDim2.fromOffset(W, 316),
		BackgroundColor3 = T_BG,
		BackgroundTransparency = 0.05,
		ZIndex = 10,
	}, tunerGui)
	round(panel, 8)
	make("UIStroke", { Color = T_ACCENT, Thickness = 1, Transparency = 0.4 }, panel)

	local function label(parent, text, x, y, w, h, size)
		return make("TextLabel", {
			Position = UDim2.fromOffset(x, y),
			Size = UDim2.fromOffset(w, h),
			BackgroundTransparency = 1,
			Font = T_FONT,
			Text = text,
			TextSize = size or 12,
			TextColor3 = T_TEXT,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextTruncate = Enum.TextTruncate.AtEnd,
			ZIndex = 11,
		}, parent)
	end
	local function button(parent, text, x, y, w, h)
		local b = make("TextButton", {
			Position = UDim2.fromOffset(x, y),
			Size = UDim2.fromOffset(w, h),
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0.88,
			AutoButtonColor = true,
			Font = T_FONT,
			Text = text,
			TextSize = 12,
			TextColor3 = T_TEXT,
			ZIndex = 11,
		}, parent)
		round(b, 5)
		return b
	end

	local titleBar = make("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, ZIndex = 11 }, panel)
	label(titleBar, "UI Tuner  (drag here)", 8, 0, 170, 24, 12).TextColor3 = T_ACCENT
	local minButton = button(titleBar, "–", W - 28, 3, 22, 18)

	local body = make("Frame", {
		Position = UDim2.fromOffset(0, 24),
		Size = UDim2.new(1, 0, 1, -24),
		BackgroundTransparency = 1,
		ZIndex = 11,
	}, panel)

	local pickButton = button(body, "Pick", 8, 0, 52, 24)
	local dragButton = button(body, "Drag", 64, 0, 52, 24)
	local upButton = button(body, "Bigger part", 120, 0, 74, 24)
	local stepButton = button(body, "x1", 198, 0, 30, 24)

	local nameLabel = label(body, "Tap Pick, then tap something", 8, 28, W - 16, 16, 12)
	nameLabel.TextColor3 = T_ACCENT
	local changeLabel = label(body, "", 8, 44, W - 16, 30, 11)
	changeLabel.TextWrapped = true
	changeLabel.TextTruncate = Enum.TextTruncate.None
	changeLabel.TextYAlignment = Enum.TextYAlignment.Top

	local selected = nil
	local originals = {}
	local stepIndex = 1
	local mode = "none"

	local function step()
		return T_STEPS[stepIndex]
	end
	local function isText(o)
		return o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox")
	end

	local SLOT_NAMES = { Helmet = true, Chest = true, Gloves = true, Legs = true, Boots = true }
	local NAMED = {
		Menu = "Whole menu",
		Panels = "Both panels",
		InventoryPanel = "Inventory panel",
		CraftingPanel = "Crafting panel",
		Close = "Close (X) button",
		ItemStrip = "Recipe tile row",
		Preview = "Item preview box",
		Requirements = "Materials column",
		HotbarGroup = "Hotbar + bag button",
		Hotbar = "Hotbar",
		OpenInventory = "Bag button",
		HeldItemName = "Held item name",
		CraftingProgress = "Crafting progress",
		Dashes = "Dashed outline",
		Crosshair = "Crosshair",
	}

	local friendly
	friendly = function(o)
		if not o or o == target then
			return "UI"
		end
		local n = o.Name
		if NAMED[n] then
			return NAMED[n]
		end
		local slotName = n:match("^(%a+)Slot$")
		if slotName and SLOT_NAMES[slotName] then
			return slotName .. " slot"
		end
		local num = n:match("^Slot(%d+)$")
		if num then
			return "Backpack slot " .. num
		end
		num = n:match("^Hotbar(%d+)$")
		if num then
			return "Hotbar slot " .. num
		end
		local tab = n:match("^(%a+)Tab$")
		if tab then
			return tab .. " tab"
		end
		if ITEMS[n] and o:IsA("GuiButton") then
			return ITEMS[n].Name .. " recipe tile"
		end
		if o:IsA("ImageLabel") or o:IsA("ImageButton") then
			for slot, img in pairs(CONFIG.EquipmentIcons) do
				if img ~= "" and o.Image == img then
					return slot .. " icon"
				end
			end
			for _, item in pairs(ITEMS) do
				if item.Image ~= "" and o.Image == item.Image then
					return item.Name .. " icon (" .. friendly(o.Parent) .. ")"
				end
			end
			return "Picture in " .. friendly(o.Parent)
		end
		if isText(o) and o.Text ~= "" then
			local t = o.Text
			if #t > 22 then
				t = t:sub(1, 20) .. "…"
			end
			return '"' .. t .. '" ' .. (o:IsA("TextButton") and "button" or "text")
		end
		if isText(o) then
			return "Empty text in " .. friendly(o.Parent)
		end
		return "Part of " .. friendly(o.Parent)
	end

	local function remember(o)
		if originals[o] then
			return
		end
		local entry = { Position = o.Position, Size = o.Size, compX = 0, compY = 0, Spacing = o:GetAttribute("LetterSpacing") or 0 }
		if isText(o) then
			entry.TextSize = o.TextSize
		end
		originals[o] = entry
	end

	local function changes(o)
		local orig = originals[o]
		if not orig then
			return {}
		end
		local list = {}
		local dx = math.floor((o.Position.X.Offset - orig.Position.X.Offset - orig.compX) * 10 + 0.5) / 10
		local dy = math.floor((o.Position.Y.Offset - orig.Position.Y.Offset - orig.compY) * 10 + 0.5) / 10
		if dx ~= 0 then
			table.insert(list, "moved " .. math.abs(dx) .. (dx < 0 and " left" or " right"))
		end
		if dy ~= 0 then
			table.insert(list, "moved " .. math.abs(dy) .. (dy < 0 and " up" or " down"))
		end
		local dw = math.floor((o.Size.X.Offset - orig.Size.X.Offset) * 10 + 0.5) / 10
		local dh = math.floor((o.Size.Y.Offset - orig.Size.Y.Offset) * 10 + 0.5) / 10
		if dw ~= 0 then
			table.insert(list, (dw < 0 and "narrower " or "wider ") .. math.abs(dw))
		end
		if dh ~= 0 then
			table.insert(list, (dh < 0 and "shorter " or "taller ") .. math.abs(dh))
		end
		local ds = math.floor(((o:GetAttribute("LetterSpacing") or 0) - orig.Spacing) * 10 + 0.5) / 10
		if ds ~= 0 then
			table.insert(list, "letters " .. (ds < 0 and "closer " or "wider ") .. math.abs(ds))
		end
		if orig.TextSize and o.TextSize ~= orig.TextSize then
			local dt = math.floor((o.TextSize - orig.TextSize) * 10 + 0.5) / 10
			table.insert(list, "text " .. (dt < 0 and "smaller " or "bigger ") .. math.abs(dt))
		end
		return list
	end

	local function refreshInfo()
		if not selected or not selected.Parent then
			selected = nil
			nameLabel.Text = "Tap Pick, then tap something"
			changeLabel.Text = ""
			return
		end
		nameLabel.Text = friendly(selected)
		local list = changes(selected)
		changeLabel.Text = #list > 0 and table.concat(list, ", ") or "No changes yet"
	end

	local function selectObject(o)
		selected = o
		refreshInfo()
	end

	local function setMode(m)
		mode = mode == m and "none" or m
		catcher.Visible = mode ~= "none"
		pickButton.TextColor3 = mode == "pick" and T_ACCENT or T_TEXT
		dragButton.TextColor3 = mode == "drag" and T_ACCENT or T_TEXT
		pickButton.BackgroundTransparency = mode == "pick" and 0.6 or 0.88
		dragButton.BackgroundTransparency = mode == "drag" and 0.6 or 0.88
	end

	local function effectiveScale(o)
		local sc = 1
		local cur = o.Parent
		while cur and cur ~= target do
			local u = cur:FindFirstChildOfClass("UIScale")
			if u then
				sc *= u.Scale
			end
			cur = cur.Parent
		end
		return sc
	end

	local function apply(kind, a, b)
		local o = selected
		if not o then
			return
		end
		remember(o)
		local n = step()
		if kind == "move" then
			local p = o.Position
			o.Position = UDim2.new(p.X.Scale, p.X.Offset + a * n, p.Y.Scale, p.Y.Offset + b * n)
		elseif kind == "size" and isText(o) and b == 0 and a ~= 0 then
			letterSpacing(o, (o:GetAttribute("LetterSpacing") or 0) + a * n)
		elseif kind == "size" then
			local sz = o.Size
			local dw, dh = a * n, b * n
			o.Size = UDim2.new(sz.X.Scale, sz.X.Offset + dw, sz.Y.Scale, sz.Y.Offset + dh)
			local shiftX = -dw * (0.5 - o.AnchorPoint.X)
			local shiftY = -dh * (0.5 - o.AnchorPoint.Y)
			if shiftX ~= 0 or shiftY ~= 0 then
				local p = o.Position
				o.Position = UDim2.new(p.X.Scale, p.X.Offset + shiftX, p.Y.Scale, p.Y.Offset + shiftY)
				local orig = originals[o]
				orig.compX += shiftX
				orig.compY += shiftY
			end
		elseif kind == "text" and isText(o) then
			o.TextSize = math.clamp(o.TextSize + a * n, 1, 100)
		end
		refreshInfo()
	end

	local function holdButton(b, fn)
		local holding = false
		b.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			holding = true
			fn()
			task.delay(0.35, function()
				while holding do
					fn()
					task.wait(0.07)
				end
			end)
		end)
		b.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				holding = false
			end
		end)
		b.MouseLeave:Connect(function()
			holding = false
		end)
	end

	local sections = {
		{ "Move", { { "Left", "move", -1, 0 }, { "Right", "move", 1, 0 }, { "Up", "move", 0, -1 }, { "Down", "move", 0, 1 } } },
		{ "Size", { { "Smaller", "size", -1, -1 }, { "Bigger", "size", 1, 1 } } },
		{ "Text", { { "Smaller", "text", -1, 0 }, { "Bigger", "text", 1, 0 } } },
		{ "Width", { { "Narrower", "size", -1, 0 }, { "Wider", "size", 1, 0 } } },
		{ "Height", { { "Shorter", "size", 0, -1 }, { "Taller", "size", 0, 1 } } },
	}
	local y = 78
	for _, section in ipairs(sections) do
		label(body, section[1], 8, y, 50, 24, 12).TextTransparency = 0.25
		local count = #section[2]
		local x0, total = 58, W - 58 - 8
		local bw = (total - (count - 1) * 4) / count
		for i, spec in ipairs(section[2]) do
			local b = button(body, spec[1], x0 + (i - 1) * (bw + 4), y, bw, 24)
			holdButton(b, function()
				apply(spec[2], spec[3], spec[4])
			end)
		end
		y += 30
	end

	local resetButton = button(body, "Undo this", 8, y + 2, 70, 22)
	local resetAllButton = button(body, "Undo all", 82, y + 2, 64, 22)
	local copyButton = button(body, "Copy all", 150, y + 2, W - 158, 22)
	copyButton.BackgroundColor3 = T_ACCENT
	copyButton.BackgroundTransparency = 0
	copyButton.TextColor3 = Color3.fromRGB(27, 26, 20)
	panel.Size = UDim2.fromOffset(W, 24 + y + 30)
	local fullHeight = 24 + y + 30

	local exportFrame = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0.96, 0, 0.92, 0),
		BackgroundColor3 = T_BG,
		BackgroundTransparency = 0,
		Visible = false,
		ZIndex = 20,
	}, tunerGui)
	round(exportFrame, 8)
	make("UIStroke", { Color = T_ACCENT, Thickness = 1 }, exportFrame)
	label(exportFrame, "Screenshot this (scroll for more) and send it", 10, 4, 400, 22, 13).ZIndex = 21
	local closeExport = button(exportFrame, "Close", 0, 4, 60, 22)
	closeExport.AnchorPoint = Vector2.new(1, 0)
	closeExport.Position = UDim2.new(1, -8, 0, 4)
	closeExport.ZIndex = 21
	local exportScroll = make("ScrollingFrame", {
		Position = UDim2.fromOffset(8, 30),
		Size = UDim2.new(1, -16, 1, -84),
		BackgroundTransparency = 1,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 6,
		ZIndex = 21,
	}, exportFrame)
	local copyHint = label(exportFrame, "Tap the box below, hold, Select All, Copy, then send it:", 10, 0, 600, 18, 12)
	copyHint.AnchorPoint = Vector2.new(0, 1)
	copyHint.Position = UDim2.new(0, 10, 1, -46)
	copyHint.TextColor3 = T_ACCENT
	copyHint.ZIndex = 21
	local copyBox = make("TextBox", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 8, 1, -8),
		Size = UDim2.new(1, -16, 0, 34),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.9,
		ClearTextOnFocus = false,
		TextEditable = true,
		MultiLine = false,
		TextWrapped = false,
		ClipsDescendants = true,
		Font = Enum.Font.Code,
		TextSize = 13,
		TextColor3 = T_TEXT,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
		ZIndex = 21,
	}, exportFrame)
	round(copyBox, 6)
	local copyCode = ""
	local copyParts = {}
	local copyIndex = 1
	local partButton = button(exportFrame, "Next part", 0, 0, 90, 22)
	partButton.AnchorPoint = Vector2.new(1, 1)
	partButton.Position = UDim2.new(1, -8, 1, -46)
	partButton.ZIndex = 21
	partButton.Visible = false
	local function showPart()
		copyCode = copyParts[copyIndex] or ""
		copyBox.Text = copyCode
		if #copyParts > 1 then
			copyHint.Text = "Part " .. copyIndex .. " of " .. #copyParts .. ": tap box, hold, Select All, Copy, send. Then Next part."
		else
			copyHint.Text = "Tap the box below, hold, Select All, Copy, then send it:"
		end
		partButton.Visible = #copyParts > 1
	end
	partButton.Activated:Connect(function()
		copyBox:ReleaseFocus()
		copyIndex = copyIndex % math.max(#copyParts, 1) + 1
		showPart()
	end)
	copyBox.Focused:Connect(function()
		if copyBox.Text ~= copyCode then
			copyBox:ReleaseFocus()
			copyBox.Text = copyCode
			return
		end
		task.defer(function()
			copyBox.SelectionStart = 1
			copyBox.CursorPosition = #copyCode + 1
		end)
	end)
	copyBox.FocusLost:Connect(function()
		copyBox.Text = copyCode
	end)
	copyBox:GetPropertyChangedSignal("Text"):Connect(function()
		if copyBox.Text ~= copyCode and not copyBox:IsFocused() then
			copyBox.Text = copyCode
		end
	end)
	local exportBox = make("TextLabel", {
		Size = UDim2.new(1, -8, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		TextWrapped = true,
		Font = Enum.Font.Code,
		TextSize = 14,
		TextColor3 = T_TEXT,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Text = "",
		ZIndex = 21,
	}, exportScroll)

	local function pathOf(o)
		local parts = {}
		local cur = o
		while cur and cur ~= target do
			local name = cur.Name
			local parent = cur.Parent
			if parent then
				local same, index = 0, 0
				for _, c in ipairs(parent:GetChildren()) do
					if c.Name == name then
						same += 1
						if c == cur then
							index = same
						end
					end
				end
				if same > 1 then
					name = name .. "#" .. index
				end
			end
			table.insert(parts, 1, name)
			cur = parent
		end
		return (table.concat(parts, "/"):gsub("^Menu/Panels/", ""))
	end
	local function udim2(u)
		return string.format("%g,%g,%g,%g", u.X.Scale, u.X.Offset, u.Y.Scale, u.Y.Offset)
	end

	local function buildCode()
		local parts = {}
		for o, orig in pairs(originals) do
			if o.Parent and #changes(o) > 0 then
				local entry = pathOf(o) .. "=P" .. udim2(o.Position) .. "/S" .. udim2(o.Size)
				if orig.TextSize then
					entry ..= "/T" .. o.TextSize
				end
				if (o:GetAttribute("LetterSpacing") or 0) ~= 0 then
					entry ..= "/L" .. o:GetAttribute("LetterSpacing")
				end
				table.insert(parts, entry)
			end
		end
		table.sort(parts)
		return "HZT " .. table.concat(parts, " ; ") .. " ; COUNT=" .. #parts
	end

	local function buildExport()
		local lines = {}
		for o, orig in pairs(originals) do
			if o.Parent then
				local list = changes(o)
				if #list > 0 then
					local exact = "P " .. udim2(o.Position) .. "  S " .. udim2(o.Size)
					if orig.TextSize then
						exact ..= "  T " .. o.TextSize
					end
					table.insert(lines, "• " .. friendly(o) .. ": " .. table.concat(list, ", ") .. "\n   " .. pathOf(o) .. "  " .. exact)
				end
			end
		end
		table.sort(lines)
		if #lines == 0 then
			return "No changes yet"
		end
		local cam = workspace.CurrentCamera
		local vp = cam and cam.ViewportSize or Vector2.zero
		table.insert(lines, 1, string.format("HorizonUITuner export, screen %dx%d", vp.X, vp.Y))
		return table.concat(lines, "\n")
	end

	local function pickAt(pos)
		for _, o in ipairs(playerGui:GetGuiObjectsAtPosition(pos.X, pos.Y)) do
			if o:IsDescendantOf(target) and o.Name ~= "Dim" and o.Name ~= "MouseUnlock" then
				return o
			end
		end
		return nil
	end

	local dragging = nil
	catcher.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		if mode == "pick" then
			local o = pickAt(input.Position)
			if o then
				selectObject(o)
			end
		elseif mode == "drag" and selected then
			remember(selected)
			dragging = { start = input.Position, pos = selected.Position, scale = effectiveScale(selected) }
		end
	end)

	local panelDrag = nil
	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			panelDrag = { start = input.Position, pos = panel.Position }
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		if panelDrag then
			local d = input.Position - panelDrag.start
			panel.Position = UDim2.fromOffset(panelDrag.pos.X.Offset + d.X, panelDrag.pos.Y.Offset + d.Y)
		elseif dragging and selected then
			local d = (input.Position - dragging.start) / math.max(dragging.scale, 0.01)
			local p = dragging.pos
			selected.Position = UDim2.new(p.X.Scale, p.X.Offset + math.floor(d.X + 0.5), p.Y.Scale, p.Y.Offset + math.floor(d.Y + 0.5))
			refreshInfo()
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = nil
			panelDrag = nil
		end
	end)

	pickButton.Activated:Connect(function()
		setMode("pick")
	end)
	dragButton.Activated:Connect(function()
		setMode("drag")
	end)
	upButton.Activated:Connect(function()
		if selected and selected.Parent and selected.Parent ~= target then
			selectObject(selected.Parent)
		end
	end)
	stepButton.Activated:Connect(function()
		stepIndex = stepIndex % #T_STEPS + 1
		stepButton.Text = "x" .. step()
	end)

	local function restore(o)
		local orig = originals[o]
		if not orig then
			return
		end
		o.Position = orig.Position
		o.Size = orig.Size
		if orig.TextSize then
			o.TextSize = orig.TextSize
		end
		if (o:GetAttribute("LetterSpacing") or 0) ~= orig.Spacing then
			letterSpacing(o, orig.Spacing)
		end
		originals[o] = nil
	end
	resetButton.Activated:Connect(function()
		if selected then
			restore(selected)
			refreshInfo()
		end
	end)
	resetAllButton.Activated:Connect(function()
		for o in pairs(originals) do
			if o.Parent then
				restore(o)
			end
		end
		table.clear(originals)
		refreshInfo()
	end)
	local exportNumber = 0
	copyButton.Activated:Connect(function()
		copyBox:ReleaseFocus()
		exportNumber += 1
		exportBox.Text = "Export #" .. exportNumber .. "\n" .. buildExport()
		local all = buildCode()
		table.clear(copyParts)
		local current = ""
		for entry in (all:gsub("^HZT ", "") .. " ; "):gmatch("(.-) ; ") do
			if entry ~= "" then
				if #current + #entry > 500 and current ~= "" then
					table.insert(copyParts, "HZT#" .. exportNumber .. " " .. current)
					current = ""
				end
				current = current == "" and entry or (current .. " ; " .. entry)
			end
		end
		table.insert(copyParts, "HZT#" .. exportNumber .. " " .. current)
		copyIndex = 1
		showPart()
		exportFrame.Visible = true
	end)
	closeExport.Activated:Connect(function()
		copyBox:ReleaseFocus()
		exportFrame.Visible = false
	end)

	local minimized = false
	minButton.Activated:Connect(function()
		minimized = not minimized
		body.Visible = not minimized
		panel.Size = UDim2.fromOffset(W, minimized and 24 or fullHeight)
		minButton.Text = minimized and "+" or "–"
	end)

	RunService.RenderStepped:Connect(function()
		if selected and selected.Parent and selected:IsA("GuiObject") and selected.Visible then
			highlight.Visible = true
			local origin = tunerGui.AbsolutePosition
			highlight.Position = UDim2.fromOffset(selected.AbsolutePosition.X - origin.X, selected.AbsolutePosition.Y - origin.Y)
			highlight.Size = UDim2.fromOffset(selected.AbsoluteSize.X, selected.AbsoluteSize.Y)
		else
			highlight.Visible = false
		end
	end)

	gui.Destroying:Connect(function()
		tunerGui:Destroy()
	end)
end
if CONFIG.Tuner then
	startTuner()
end
