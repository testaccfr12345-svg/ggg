local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

for _, name in ipairs({ "HorizonBuildUI", "HorizonBuildDim", "HorizonBuildButtons" }) do
	local existing = playerGui:FindFirstChild(name)
	if existing then
		existing:Destroy()
	end
end

local CONFIG = {
	Accent = Color3.fromRGB(233, 185, 73),
	Text = Color3.fromRGB(237, 232, 220),
	Ink = Color3.fromRGB(27, 26, 20),
	Red = Color3.fromRGB(244, 164, 124),
	PanelColor = Color3.fromRGB(16, 21, 19),
	DimColor = Color3.fromRGB(6, 9, 8),
	DimTransparency = 0.58,
	PanelTransparency = 0.28,
	BlurSize = 12,
	FontEnum = Enum.Font.PatrickHand,
	FontScale = 1.354,
	DesignWidth = 896,
	DesignHeight = 414,
	HammerName = "Building Hammer",
	TestPieceImage = "rbxassetid://137129354242963",
	ShowWithoutHammer = true,
	BuildKey = Enum.KeyCode.B,
	RotateKey = Enum.KeyCode.R,
	UpgradeKey = Enum.KeyCode.E,
	RepairKey = Enum.KeyCode.R,
	DestroyKey = Enum.KeyCode.X,

	Icons = {
		Build = "rbxassetid://101709534722383",
		Rotate = "rbxassetid://79907808407701",
		Upgrade = "rbxassetid://102141489103280",
		Repair = "rbxassetid://137499770517153",
		Destroy = "rbxassetid://94996894660218",
	},

	MaterialIcons = {
		Planks = "rbxassetid://78387750873126",
		Stone = "rbxassetid://127351259030040",
	},

	PieceImages = {
		["Wooden Platform"] = "",
		["Stone Platform"] = "",
		["Wooden Triangle Platform"] = "",
		["Stone Triangle Platform"] = "",
		["Wooden Wall"] = "rbxassetid://137129354242963",
		["Stone Wall"] = "",
		["Wooden Half Wall"] = "",
		["Stone Half Wall"] = "",
		["Wooden Low Wall"] = "",
		["Stone Low Wall"] = "",
		["Wooden Window Wall"] = "",
		["Stone Window Wall"] = "",
		["Wooden Door Wall"] = "",
		["Stone Door Wall"] = "",
		["Wooden Ceiling"] = "",
		["Stone Ceiling"] = "",
		["Wooden Triangle Ceiling"] = "",
		["Stone Triangle Ceiling"] = "",
		["Wooden Stairs"] = "",
		["Stone Stairs"] = "",
		["Wooden Roof"] = "",
		["Stone Roof"] = "",
		["Wooden Window"] = "",
		["Stone Window"] = "",
		["Wooden Door"] = "",
		["Stone Door"] = "",
		["Crafting Table"] = "",
		["Furnace"] = "",
		["Cooking Pot"] = "",
		["Preserving Box"] = "",
		["Compost Bin"] = "",
		["Drying Rack"] = "",
		["Campfire"] = "",
		["Rain Collector"] = "",
		["Water Jug"] = "",
		["Bear Trap"] = "",
		["Fish Trap"] = "",
		["Bed"] = "",
		["Sleeping Mat"] = "",
		["Wooden Table"] = "",
		["Wooden Chair"] = "",
		["Chest"] = "",
		["Big Chest"] = "",
		["Wooden Sign"] = "",
		["Wall Torch"] = "",
		["Ground Torch"] = "",
		["Raft"] = "",
		["Boat"] = "",
	},
}

local TABS = { "Structures", "Crafting", "Survival", "Furniture", "Boats" }

local PIECES = {
	Structures = {
		{ "Wooden Platform", "A flat floor to build on." },
		{ "Triangle Platform", "A triangle floor for odd corners." },
		{ "Wall", "A solid wall. Keeps the wind and the beasts out." },
		{ "Half Wall", "Half height. Good for railings." },
		{ "Low Wall", "A low wall to mark your space." },
		{ "Window Wall", "A wall with a gap to look through." },
		{ "Door Wall", "A wall with a doorway. Add a door." },
		{ "Ceiling", "A roof piece that goes on top of walls." },
		{ "Triangle Ceiling", "A triangle ceiling for odd corners." },
		{ "Stairs", "Takes you up a floor." },
		{ "Roof", "A slanted roof to keep the rain off." },
		{ "Window", "Fits into a window wall." },
		{ "Door", "Fits into a door wall." },
	},
	Crafting = {
		{ "Crafting Table" }, { "Furnace" }, { "Cooking Pot" }, { "Preserving Box" }, { "Compost Bin" }, { "Drying Rack" },
	},
	Survival = {
		{ "Campfire" }, { "Rain Collector" }, { "Water Jug" }, { "Bear Trap" }, { "Fish Trap" },
	},
	Furniture = {
		{ "Bed" }, { "Sleeping Mat" }, { "Wooden Table" }, { "Wooden Chair" }, { "Chest" }, { "Big Chest" }, { "Wooden Sign" }, { "Wall Torch" }, { "Ground Torch" },
	},
	Boats = {
		{ "Raft" }, { "Boat" },
	},
}

local STONE_WALL_DESC = "Stacked stone blocks. Much harder to break than wood."

local PLACEHOLDER_STRUCTURE_COSTS = {
	["Wooden Platform"] = 4,
	["Triangle Platform"] = 2,
	["Wall"] = 4,
	["Half Wall"] = 2,
	["Low Wall"] = 1,
	["Window Wall"] = 3,
	["Door Wall"] = 3,
	["Ceiling"] = 4,
	["Triangle Ceiling"] = 2,
	["Stairs"] = 4,
	["Roof"] = 4,
	["Window"] = 2,
	["Door"] = 3,
}

local PLACEHOLDER_MATERIALS = {
	Planks = 40,
	Stone = 7,
}

local BuildHooks = {}

function BuildHooks.IsHammerEquipped()
	if CONFIG.ShowWithoutHammer then
		return true
	end
	local character = player.Character
	local tool = character and character:FindFirstChildOfClass("Tool")
	return tool ~= nil and tool.Name == CONFIG.HammerName
end

function BuildHooks.GetLookedAtPiece()
	return nil
end

function BuildHooks.GetMaterialCount(material)
	return PLACEHOLDER_MATERIALS[material] or 0
end

function BuildHooks.GetPieceCost(name, stone)
	local base = PLACEHOLDER_STRUCTURE_COSTS[name]
	if not base then
		return nil
	end
	if stone then
		return "Stone", base + 1
	end
	return "Planks", base
end

function BuildHooks.StartPlacing(name, stone) end

function BuildHooks.RotatePlacing() end

function BuildHooks.PlacePiece(name, stone) end

function BuildHooks.CancelPlacing() end

function BuildHooks.Upgrade(piece) end

function BuildHooks.Repair(piece) end

function BuildHooks.Destroy(piece) end

local FONT = Font.fromEnum(CONFIG.FontEnum)
local WHITE = Color3.new(1, 1, 1)
local BLACK = Color3.new(0, 0, 0)

local function ts(size)
	return math.floor(size * CONFIG.FontScale + 0.5)
end

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
	return new("UICorner", { CornerRadius = typeof(radius) == "UDim" and radius or UDim.new(0, radius) }, parent)
end

local function ring(parent, thickness, transparency, radius)
	local frame = new("Frame", {
		Name = "Ring",
		Position = UDim2.fromOffset(thickness, thickness),
		Size = UDim2.new(1, -2 * thickness, 1, -2 * thickness),
		BackgroundTransparency = 1,
	}, parent)
	if typeof(radius) == "UDim" then
		corner(frame, radius)
	else
		corner(frame, math.max(0, radius - thickness))
	end
	local stroke = new("UIStroke", {
		Color = CONFIG.Text,
		Thickness = thickness,
		Transparency = transparency,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, frame)
	return stroke, frame
end

local function text(parent, size, props)
	local label = new("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		FontFace = FONT,
		TextSize = ts(size),
		TextColor3 = CONFIG.Text,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		Text = "",
		ZIndex = 2,
	}, parent)
	for key, value in pairs(props or {}) do
		label[key] = value
	end
	return label
end

local function addShadow(label)
	local shadow = label:Clone()
	shadow.Name = label.Name .. "Shadow"
	shadow.TextColor3 = BLACK
	shadow.TextTransparency = 0.55
	shadow.Position = label.Position + UDim2.fromOffset(0, 1.5)
	shadow.ZIndex = label.ZIndex - 1
	shadow.Parent = label.Parent
	label:GetPropertyChangedSignal("Text"):Connect(function()
		shadow.Text = label.Text
	end)
	label:GetPropertyChangedSignal("Visible"):Connect(function()
		shadow.Visible = label.Visible
	end)
	label:GetPropertyChangedSignal("Position"):Connect(function()
		shadow.Position = label.Position + UDim2.fromOffset(0, 1.5)
	end)
	label:GetPropertyChangedSignal("Size"):Connect(function()
		shadow.Size = label.Size
	end)
	return shadow
end

local function spaced(str, px)
	local gap = '<font size="' .. math.max(1, math.floor(px * CONFIG.FontScale / 0.24 + 0.5)) .. '"> </font>'
	local chars = {}
	for _, code in utf8.codes(str) do
		table.insert(chars, utf8.char(code))
	end
	return table.concat(chars, gap)
end

local function textWidth(str, size)
	return TextService:GetTextSize(str, ts(size), CONFIG.FontEnum, Vector2.new(2000, 200)).X
end

local function image(parent, size, props)
	local label = new("ImageLabel", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(size, size),
		BackgroundTransparency = 1,
		ScaleType = Enum.ScaleType.Fit,
		ImageColor3 = WHITE,
		ZIndex = 2,
	}, parent)
	for key, value in pairs(props or {}) do
		label[key] = value
	end
	return label
end

local function isStructure(tab)
	return tab == "Structures"
end

local function fullName(name, stone, structure)
	if not structure then
		return name
	end
	local short = name == "Wooden Platform" and "Platform" or name
	return (stone and "Stone " or "Wooden ") .. short
end

local function pieceImage(name, stone, structure)
	local id = CONFIG.PieceImages[fullName(name, stone, structure)] or ""
	if id == "" then
		return CONFIG.TestPieceImage or ""
	end
	return id
end

local dimGui = new("ScreenGui", {
	Name = "HorizonBuildDim",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ScreenInsets = Enum.ScreenInsets.None,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 11,
	Enabled = true,
}, playerGui)

local dim = new("TextButton", {
	Name = "Dim",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = CONFIG.DimColor,
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	AutoButtonColor = false,
	Text = "",
	Visible = false,
}, dimGui)

local gui = new("ScreenGui", {
	Name = "HorizonBuildUI",
	ResetOnSpawn = false,
	ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 12,
}, playerGui)

local modal = new("TextButton", {
	Name = "MouseUnlock",
	Size = UDim2.fromOffset(0, 0),
	BackgroundTransparency = 1,
	Text = "",
	Modal = true,
	Visible = false,
}, gui)

local blur = Lighting:FindFirstChild("HorizonBuildBlur") or new("BlurEffect", { Name = "HorizonBuildBlur" }, Lighting)
blur.Size = 0

local stage = new("Frame", {
	Name = "Stage",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(CONFIG.DesignWidth, CONFIG.DesignHeight),
	BackgroundTransparency = 1,
}, gui)
local stageScale = new("UIScale", {}, stage)

local function updateScale()
	local size = gui.AbsoluteSize
	if size.X < 1 or size.Y < 1 then
		return
	end
	local sc = math.min(size.X / CONFIG.DesignWidth, size.Y / CONFIG.DesignHeight)
	stageScale.Scale = sc
	stage.Size = UDim2.fromOffset(size.X / sc, size.Y / sc)
end
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateScale)
updateScale()

local MENU_W, MENU_H = 620, 380
local menuWidth = MENU_W

local menuHolder = new("Frame", {
	Name = "BuildMenu",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(MENU_W, MENU_H),
	BackgroundTransparency = 1,
	ZIndex = 2,
}, dimGui)
local menuScale = new("UIScale", {}, menuHolder)

local menu = new("Frame", {
	Name = "Panel",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = CONFIG.PanelColor,
	BackgroundTransparency = CONFIG.PanelTransparency,
	BorderSizePixel = 0,
	Active = true,
	Visible = false,
}, menuHolder)
corner(menu, 14)
local openScale = new("UIScale", { Scale = 1 }, menu)

local content = new("Frame", {
	Name = "Content",
	Position = UDim2.fromOffset(14, 14),
	Size = UDim2.new(1, -28, 1, -28),
	BackgroundTransparency = 1,
}, menu)

text(content, 27, { Name = "Title", Size = UDim2.fromOffset(200, 30), Text = spaced("Build", 1), RichText = true })

local closeButton = new("TextButton", {
	Name = "Close",
	Position = UDim2.new(1, -30, 0, 0),
	Size = UDim2.fromOffset(30, 30),
	BackgroundColor3 = WHITE,
	BackgroundTransparency = 0.93,
	AutoButtonColor = false,
	Text = "",
}, content)
corner(closeButton, 15)
for _, rotation in ipairs({ 45, -45 }) do
	local line = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(2, 14),
		Rotation = rotation,
		BackgroundColor3 = CONFIG.Text,
		BorderSizePixel = 0,
		ZIndex = 2,
	}, closeButton)
	corner(line, 1)
end

local tabButtons = {}
do
	local right = 562 - 10
	for index = #TABS, 1, -1 do
		local name = TABS[index]
		local width = math.ceil(textWidth(name, 17)) + 26
		right -= width
		local pill = new("TextButton", {
			Name = name .. "Tab",
			Position = UDim2.new(1, right - 592, 0, 0),
			Size = UDim2.fromOffset(width, 30),
			BackgroundColor3 = WHITE,
			BackgroundTransparency = 0.93,
			AutoButtonColor = false,
			FontFace = FONT,
			TextSize = ts(17),
			TextColor3 = CONFIG.Text,
			Text = name,
		}, content)
		corner(pill, 15)
		tabButtons[name] = pill
		right -= 6
	end
end

local function splitName(name, width, size)
	if textWidth(name, size) <= width then
		return { name }
	end
	local best, bestDiff = nil, math.huge
	for position in name:gmatch("() ") do
		local a, b = name:sub(1, position - 1), name:sub(position + 1)
		local diff = math.abs(textWidth(a, size) - textWidth(b, size))
		if diff < bestDiff then
			best, bestDiff = { a, b }, diff
		end
	end
	return best or { name }
end

local strips = {}
local tiles = {}
for _, tab in ipairs(TABS) do
	local strip = new("ScrollingFrame", {
		Name = tab .. "Strip",
		Position = UDim2.fromOffset(0, 40),
		Size = UDim2.new(1, 0, 0, 85),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollingDirection = Enum.ScrollingDirection.X,
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 0,
		ElasticBehavior = Enum.ElasticBehavior.Never,
		Visible = false,
	}, content)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 7),
	}, strip)
	strips[tab] = strip
	tiles[tab] = {}
	for order, entry in ipairs(PIECES[tab]) do
		local name = entry[1]
		local tile = new("TextButton", {
			Name = name,
			LayoutOrder = order,
			Size = UDim2.fromOffset(74, 84),
			BackgroundColor3 = WHITE,
			BackgroundTransparency = 0.93,
			AutoButtonColor = false,
			Text = "",
		}, strip)
		corner(tile, 9)
		local outline = ring(tile, 2, 1, 9)
		outline.Color = CONFIG.Accent
		local lines = splitName(name, 68, 13)
		local height = 48 + 1 + #lines * 13.26
		local top = 2 + (80 - height) / 2
		local pictureSize = isStructure(tab) and 46 or 34
		local picture = image(tile, pictureSize, { Position = UDim2.fromOffset(37, top + 24) })
		for index, line in ipairs(lines) do
			text(tile, 13, {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromOffset(37, top + 49 + (index - 0.5) * 13.26),
				Size = UDim2.fromOffset(72, 18),
				Text = line,
				TextXAlignment = Enum.TextXAlignment.Center,
			})
		end
		tiles[tab][name] = { Button = tile, Stroke = outline, Picture = picture }
	end
end

local preview = new("Frame", {
	Name = "Preview",
	Position = UDim2.fromOffset(0, 135),
	Size = UDim2.new(0.5, -6, 0, 217),
	BackgroundColor3 = WHITE,
	BackgroundTransparency = 0.95,
	BorderSizePixel = 0,
}, content)
corner(preview, 11)
local previewPicture = image(preview, 104)
local previewName = text(preview, 26, { AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.new(1, -28, 0, 26), TextXAlignment = Enum.TextXAlignment.Center })
local previewCategory = text(preview, 14, { AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.new(1, -28, 0, 19), TextTransparency = 0.3, TextXAlignment = Enum.TextXAlignment.Center })
local previewDesc = text(preview, 15, {
	AnchorPoint = Vector2.new(0.5, 0),
	Size = UDim2.new(1, -28, 0, 20),
	TextTransparency = 0.15,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextYAlignment = Enum.TextYAlignment.Top,
})

local side = new("Frame", {
	Name = "Side",
	Position = UDim2.new(0.5, 6, 0, 135),
	Size = UDim2.new(0.5, -6, 0, 217),
	BackgroundTransparency = 1,
}, content)

local typeRow = new("Frame", { Name = "TypeRow", Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1 }, side)
text(typeRow, 30 / CONFIG.FontScale, { Size = UDim2.fromOffset(100, 30), Text = "Type", TextTransparency = 0.3 })
local typeButtons = {}
do
	local right = 290
	for _, entry in ipairs({ { "stone", "Stone" }, { "wood", "Wood" } }) do
		local width = math.ceil(textWidth(entry[2], 17)) + 30
		right -= width
		local pill = new("TextButton", {
			Name = entry[2],
			Position = UDim2.new(1, right - 290, 0, 0),
			Size = UDim2.fromOffset(width, 30),
			BackgroundColor3 = WHITE,
			BackgroundTransparency = 0.93,
			AutoButtonColor = false,
			FontFace = FONT,
			TextSize = ts(17),
			TextColor3 = CONFIG.Text,
			Text = entry[2],
		}, typeRow)
		corner(pill, 15)
		typeButtons[entry[1]] = pill
		right -= 6
	end
end

local materialsLabel = text(side, 30 / CONFIG.FontScale, { Size = UDim2.new(1, 0, 0, 20), Text = "Required materials", TextTransparency = 0.3 })

local materialRow = new("Frame", {
	Name = "MaterialRow",
	Size = UDim2.new(1, 0, 0, 52),
	BackgroundColor3 = WHITE,
	BackgroundTransparency = 0.94,
	BorderSizePixel = 0,
}, side)
corner(materialRow, 10)
local materialIcon = image(materialRow, 42, { Position = UDim2.fromOffset(32, 26) })
local materialName = text(materialRow, 30 / CONFIG.FontScale, { Position = UDim2.fromOffset(64, 4), Size = UDim2.fromOffset(149, 20) })
local materialStatus = text(materialRow, 24 / CONFIG.FontScale, { Position = UDim2.fromOffset(65, 28), Size = UDim2.fromOffset(150, 16) })
local materialAmount = text(materialRow, 22, {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -13, 0, -1),
	Size = UDim2.fromOffset(80, 52),
	TextXAlignment = Enum.TextXAlignment.Right,
})

local selectButton = new("TextButton", {
	Name = "Select",
	Position = UDim2.fromOffset(0, 165),
	Size = UDim2.new(1, 0, 0, 52),
	BackgroundColor3 = CONFIG.Accent,
	AutoButtonColor = false,
	FontFace = FONT,
	TextSize = ts(32),
	TextColor3 = CONFIG.Ink,
	Text = "",
}, side)
corner(selectButton, 12)

local buttonGui = new("ScreenGui", {
	Name = "HorizonBuildButtons",
	ResetOnSpawn = false,
	DisplayOrder = 5,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
}, playerGui)
pcall(function()
	buttonGui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
end)

local PRESS = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TOGGLE = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function mobileButton(name, iconId, label)
	local button = new("TextButton", {
		Name = name,
		Text = "",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(48, 48),
		BackgroundColor3 = CONFIG.PanelColor,
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
		Visible = false,
	}, buttonGui)
	corner(button, UDim.new(0.5, 0))
	local stroke = new("UIStroke", {
		Color = CONFIG.Text,
		Thickness = 1,
		Transparency = 0.75,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	}, button)
	pcall(function()
		stroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner
	end)
	local inner = new("Frame", {
		Name = "Content",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(48, 48),
		BackgroundTransparency = 1,
	}, button)
	local fit = new("UIScale", {}, inner)
	local top = (48 - (16 + 1 + 11)) / 2
	new("ImageLabel", {
		Name = "Icon",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, top),
		Size = UDim2.fromOffset(16, 16),
		BackgroundTransparency = 1,
		Image = iconId,
		ImageColor3 = WHITE,
		ScaleType = Enum.ScaleType.Fit,
	}, inner)
	new("TextLabel", {
		Name = "Label",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, top + 16 + 1),
		Size = UDim2.new(1, 0, 0, 11),
		BackgroundTransparency = 1,
		Font = CONFIG.FontEnum,
		Text = label,
		TextSize = 15,
		TextColor3 = CONFIG.Text,
	}, inner)
	local entry = { Button = button, Stroke = stroke, Fit = fit, On = false }
	local holdInput = nil
	local function setPressed(on)
		TweenService:Create(fit, PRESS, { Scale = on and 0.985 or 1 }):Play()
		TweenService:Create(button, PRESS, { BackgroundTransparency = on and 0.46 or 0.5 }):Play()
	end
	button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			holdInput = input
			setPressed(true)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input == holdInput then
			holdInput = nil
			setPressed(false)
		end
	end)
	return entry
end

local buildButton = mobileButton("Build", CONFIG.Icons.Build, "Build")
local rotateButton = mobileButton("Rotate", CONFIG.Icons.Rotate, "Rotate")

local function setButtonOn(entry, on)
	if entry.On == on then
		return
	end
	entry.On = on
	TweenService:Create(entry.Stroke, TOGGLE, { Transparency = 0.75 }):Play()
end

local touchGui, nativeJump
local touchWatch = {}

local function placeButtons()
	local cx, cy
	if nativeJump and touchGui and nativeJump.AbsoluteSize.X > 0 then
		local position = nativeJump.AbsolutePosition - buttonGui.AbsolutePosition
		local size = nativeJump.AbsoluteSize
		cx, cy = position.X + size.X / 2, position.Y + size.Y / 2
	else
		local viewport = buttonGui.AbsoluteSize
		local small = math.min(viewport.X, viewport.Y) <= 500
		local size = small and 70 or 120
		local x, y = small and -95 or -170, small and -90 or -210
		cx, cy = viewport.X + x + size / 2, viewport.Y + y + size / 2
	end
	buildButton.Button.Position = UDim2.fromOffset(cx + 26.5, cy - 131)
	rotateButton.Button.Position = UDim2.fromOffset(cx + 26.5, cy - 189)
end

local function bindTouchGui()
	for _, c in ipairs(touchWatch) do
		c:Disconnect()
	end
	table.clear(touchWatch)
	touchGui = playerGui:FindFirstChild("TouchGui")
	if touchGui and touchGui:IsA("ScreenGui") then
		buttonGui.IgnoreGuiInset = touchGui.IgnoreGuiInset
	end
	local frame = touchGui and touchGui:FindFirstChild("TouchControlFrame")
	nativeJump = frame and frame:FindFirstChild("JumpButton")
	if frame then
		table.insert(touchWatch, frame.ChildAdded:Connect(function(c)
			if c.Name == "JumpButton" then
				task.defer(bindTouchGui)
			end
		end))
	end
	if nativeJump then
		table.insert(touchWatch, nativeJump:GetPropertyChangedSignal("AbsolutePosition"):Connect(placeButtons))
		table.insert(touchWatch, nativeJump:GetPropertyChangedSignal("AbsoluteSize"):Connect(placeButtons))
	elseif touchGui then
		table.insert(touchWatch, touchGui.DescendantAdded:Connect(function(d)
			if d.Name == "JumpButton" or d.Name == "TouchControlFrame" then
				task.defer(bindTouchGui)
			end
		end))
	end
	placeButtons()
end

playerGui.ChildAdded:Connect(function(c)
	if c.Name == "TouchGui" then
		task.defer(bindTouchGui)
	end
end)
buttonGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(placeButtons)
buttonGui:GetPropertyChangedSignal("AbsolutePosition"):Connect(placeButtons)
bindTouchGui()

local function keycap(parent, props)
	local cap = new("Frame", {
		Name = "Keycap",
		Size = UDim2.fromOffset(30, 26),
		BackgroundColor3 = CONFIG.PanelColor,
		BackgroundTransparency = 0.5,
		BorderSizePixel = 0,
	}, parent)
	for key, value in pairs(props or {}) do
		cap[key] = value
	end
	corner(cap, 6)
	local stroke = ring(cap, 1, 0.82, 6)
	local label = text(cap, 15, { Size = UDim2.fromScale(1, 1), TextXAlignment = Enum.TextXAlignment.Center })
	local icon = image(cap, 15, { Position = UDim2.fromScale(0.5, 0.5), Visible = false })
	return { Frame = cap, Stroke = stroke, Label = label, Icon = icon }
end

local function setKeycapOn(cap, on)
	cap.Frame.BackgroundTransparency = on and 0.38 or 0.5
	cap.Stroke.Transparency = on and 0.3 or 0.82
end

local function setKeycapContent(cap, label, iconId, iconSize)
	if iconId then
		cap.Label.Text = ""
		cap.Icon.Image = iconId
		cap.Icon.Size = UDim2.fromOffset(iconSize or 15, iconSize or 15)
		cap.Icon.Visible = true
	else
		cap.Label.Text = label
		cap.Icon.Visible = false
	end
end

local legend = new("Frame", {
	Name = "BuildKeys",
	AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, -28, 1, -22),
	Size = UDim2.fromOffset(144, 58),
	BackgroundTransparency = 1,
	Visible = false,
}, stage)

local function legendRow(iconId, label, key, y)
	local row = new("Frame", { Name = label .. "Row", Position = UDim2.fromOffset(0, y), Size = UDim2.fromOffset(144, 26), BackgroundTransparency = 1 }, legend)
	image(row, 17, { Position = UDim2.fromOffset(10, 13), Image = iconId })
	local name = text(row, 16, { Position = UDim2.fromOffset(28, 0), Size = UDim2.fromOffset(56, 26), Text = label })
	addShadow(name)
	local cap = keycap(row, { Position = UDim2.fromOffset(92, 0), Size = UDim2.fromOffset(52, 26) })
	cap.Label.Text = key
	return { Row = row, Cap = cap }
end

local rotateKeyRow = legendRow(CONFIG.Icons.Rotate, "Rotate", "R", 0)
local buildKeyRow = legendRow(CONFIG.Icons.Build, "Build", "B", 32)

local prompt = new("Frame", {
	Name = "PlacePrompt",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0.5, 37),
	Size = UDim2.fromOffset(600, 80),
	BackgroundTransparency = 1,
	Visible = false,
}, stage)
local promptCap = keycap(prompt, { AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromOffset(300, 0) })
promptCap.Frame.BackgroundTransparency = 0.45
local promptText = text(prompt, 17, {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.fromOffset(300, 32),
	Size = UDim2.fromOffset(600, 23),
	RichText = true,
	TextXAlignment = Enum.TextXAlignment.Center,
})
addShadow(promptText)
local promptCost = text(prompt, 13, {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.fromOffset(300, 57),
	Size = UDim2.fromOffset(600, 18),
	TextTransparency = 0.3,
	TextXAlignment = Enum.TextXAlignment.Center,
})
addShadow(promptCost)

local pieceMenu = new("Frame", {
	Name = "PieceMenu",
	Position = UDim2.new(0.5, -306, 0.5, -44),
	Size = UDim2.fromOffset(280, 160),
	BackgroundTransparency = 1,
	Visible = false,
}, stage)
local pieceName = text(pieceMenu, 15, { Position = UDim2.fromOffset(4, 0), Size = UDim2.fromOffset(276, 20), RichText = true, TextTransparency = 0.2 })
addShadow(pieceName)
local healthBack = new("Frame", {
	Position = UDim2.fromOffset(4, 24),
	Size = UDim2.fromOffset(80, 3),
	BackgroundColor3 = WHITE,
	BackgroundTransparency = 0.8,
	BorderSizePixel = 0,
}, pieceMenu)
corner(healthBack, 2)
local healthFill = new("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = CONFIG.Text, BorderSizePixel = 0 }, healthBack)
corner(healthFill, 2)
local healthText = text(pieceMenu, 12, { Position = UDim2.fromOffset(4, 29), Size = UDim2.fromOffset(120, 16), TextTransparency = 0.3 })

local function pieceRow(kind, title, keyLabel, iconId)
	local row = new("TextButton", {
		Name = kind,
		Size = UDim2.fromOffset(280, 34),
		BackgroundColor3 = CONFIG.PanelColor,
		BackgroundTransparency = 0.5,
		AutoButtonColor = false,
		Text = "",
		Visible = false,
	}, pieceMenu)
	corner(row, 8)
	local cap = keycap(row, { Position = UDim2.fromOffset(6, 4) })
	local name = text(row, 17, { Position = UDim2.fromOffset(45, 0), Size = UDim2.fromOffset(170, 34), RichText = true, Text = spaced(title, 1.2) })
	local cost = text(row, 13, {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 0),
		Size = UDim2.fromOffset(100, 34),
		TextTransparency = 0.3,
		TextXAlignment = Enum.TextXAlignment.Right,
	})
	return { Kind = kind, Button = row, Cap = cap, Name = name, Cost = cost, KeyLabel = keyLabel, IconId = iconId }
end

local pieceRows = {
	pieceRow("Upgrade", "UPGRADE TO STONE", "E", CONFIG.Icons.Upgrade),
	pieceRow("Repair", "REPAIR", "R", CONFIG.Icons.Repair),
	pieceRow("Destroy", "DESTROY", "X", CONFIG.Icons.Destroy),
}

local state = {
	hammer = false,
	menuOpen = false,
	tab = "Structures",
	selected = PIECES.Structures[1][1],
	stone = false,
	placing = nil,
	piece = nil,
	pieceKey = nil,
	rowOff = {},
}

local function isMobile()
	local ok, preferred = pcall(function()
		return UserInputService.PreferredInput
	end)
	if ok and preferred then
		return preferred == Enum.PreferredInput.Touch
	end
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function updateMenuLayout()
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local viewport = camera.ViewportSize
	local safe = gui.AbsoluteSize
	local sc = math.min(safe.X / CONFIG.DesignWidth, safe.Y / CONFIG.DesignHeight)
	local top = GuiService:GetGuiInset().Y + 6
	local scale = math.min(sc, (viewport.Y - top - 8) / MENU_H)
	local half = MENU_H * scale / 2
	local centerY = math.max(viewport.Y / 2, top + half)
	menuScale.Scale = scale
	menuHolder.Position = UDim2.fromOffset(math.floor(viewport.X / 2 + 0.5), math.floor(centerY + 0.5))
end

local function pieceDesc(tab, name, stone)
	for _, entry in ipairs(PIECES[tab]) do
		if entry[1] == name then
			if stone and name == "Wall" then
				return STONE_WALL_DESC
			end
			return entry[2] or ""
		end
	end
	return ""
end

local function costInfo(name, stone)
	local material, amount = BuildHooks.GetPieceCost(name, stone)
	if not material then
		return nil
	end
	local have = BuildHooks.GetMaterialCount(material)
	return { material = material, amount = amount, have = have, ok = have >= amount }
end

local function layoutPreview(desc, pictureSize)
	local columnWidth = (menuWidth - 28 - 12) / 2
	local center = columnWidth / 2
	local textWidthMax = columnWidth - 28
	local descHeight = 0
	if desc ~= "" then
		descHeight = TextService:GetTextSize(desc, ts(15), CONFIG.FontEnum, Vector2.new(textWidthMax, 1000)).Y
	end
	local total = 104 + 2 + 26 + 2 + 19 + (desc ~= "" and (4 + descHeight) or 0)
	local y = (217 - total) / 2
	previewPicture.Size = UDim2.fromOffset(pictureSize, pictureSize)
	previewPicture.Position = UDim2.fromOffset(center, y + 52)
	y += 104 + 2
	previewName.Position = UDim2.fromOffset(center, y)
	y += 26 + 2
	previewCategory.Position = UDim2.fromOffset(center, y)
	y += 19 + 4
	previewDesc.Position = UDim2.fromOffset(center, y)
	previewDesc.Size = UDim2.fromOffset(textWidthMax, descHeight)
	previewDesc.Visible = desc ~= ""
end

local function renderMenu()
	for name, pill in pairs(tabButtons) do
		local on = name == state.tab
		pill.BackgroundColor3 = on and CONFIG.Accent or WHITE
		pill.BackgroundTransparency = on and 0 or 0.93
		pill.TextColor3 = on and CONFIG.Ink or CONFIG.Text
	end
	local structure = isStructure(state.tab)
	local stone = structure and state.stone
	for tab, strip in pairs(strips) do
		strip.Visible = tab == state.tab
	end
	for name, tile in pairs(tiles[state.tab]) do
		local on = name == state.selected
		tile.Stroke.Transparency = on and 0 or 1
		tile.Button.BackgroundTransparency = on and 0.9 or 0.93
		tile.Picture.Image = pieceImage(name, stone, structure)
	end

	local name = state.selected
	previewPicture.Image = pieceImage(name, stone, structure)
	previewName.Text = fullName(name, stone, structure)
	previewCategory.Text = state.tab
	local desc = pieceDesc(state.tab, name, stone)
	previewDesc.Text = desc
	layoutPreview(desc, structure and 104 or 84)

	typeRow.Visible = structure
	for key, pill in pairs(typeButtons) do
		local on = (key == "stone") == state.stone
		pill.BackgroundColor3 = on and CONFIG.Accent or WHITE
		pill.BackgroundTransparency = on and 0 or 0.93
		pill.TextColor3 = on and CONFIG.Ink or CONFIG.Text
	end
	local top = structure and 37 or 0
	materialsLabel.Position = UDim2.fromOffset(0, top + 2)
	materialRow.Position = UDim2.fromOffset(0, top + 29)

	local cost = costInfo(name, stone)
	if cost then
		materialIcon.Image = CONFIG.MaterialIcons[cost.material] or ""
		materialIcon.Visible = true
		materialName.Text = cost.material
		materialStatus.Text = cost.ok and "Ready" or ("Need " .. (cost.amount - cost.have) .. " more")
		materialStatus.TextColor3 = cost.ok and CONFIG.Accent or CONFIG.Red
		materialAmount.Text = cost.have .. " / " .. cost.amount
		materialAmount.TextColor3 = cost.ok and CONFIG.Text or CONFIG.Red
	else
		materialIcon.Visible = false
		materialName.Text = "No recipe yet"
		materialStatus.Text = ""
		materialAmount.Text = ""
	end
	materialName.Position = UDim2.fromOffset(cost and 64 or 16, cost and 4 or 16)

	local can = cost ~= nil and cost.ok
	selectButton.Active = can
	selectButton.BackgroundColor3 = can and CONFIG.Accent or WHITE
	selectButton.BackgroundTransparency = can and 0 or 0.92
	selectButton.TextColor3 = can and CONFIG.Ink or CONFIG.Text
	selectButton.TextTransparency = can and 0 or 0.4
	selectButton.Text = can and "Select" or (cost and "Missing materials" or "Not available yet")
end

local function renderPieceMenu()
	local piece = state.piece
	local show = state.hammer and not state.placing and not state.menuOpen and piece ~= nil
	pieceMenu.Visible = show
	if not show then
		return
	end
	local mobile = isMobile()
	local maxHealth = math.max(1, piece.MaxHealth or 100)
	local health = math.clamp(piece.Health or maxHealth, 0, maxHealth)
	pieceName.Text = spaced(string.upper(fullName(piece.Name, piece.Stone, piece.Structure)), 1.5)
	healthFill.Size = UDim2.fromScale(health / maxHealth, 1)
	healthText.Text = math.floor(health + 0.5) .. " / " .. math.floor(maxHealth + 0.5)

	local y = 54
	for index, row in ipairs(pieceRows) do
		local visible = true
		local costText, bad, off = "", false, false
		if row.Kind == "Upgrade" then
			visible = piece.Structure and not piece.Stone
			if visible then
				local amount = piece.UpgradeCost or 0
				costText = amount .. " Stone"
				bad = BuildHooks.GetMaterialCount("Stone") < amount
			end
		elseif row.Kind == "Repair" then
			local material = piece.RepairMaterial or (piece.Stone and "Stone" or "Planks")
			local amount = piece.RepairCost or 0
			off = health >= maxHealth
			costText = off and "Full" or (amount .. " " .. material)
			bad = not off and BuildHooks.GetMaterialCount(material) < amount
		else
			local material = piece.RefundMaterial or (piece.Stone and "Stone" or "Planks")
			costText = "+" .. (piece.Refund or 0) .. " " .. material
		end
		row.Button.Visible = visible
		state.rowOff[row.Kind] = off or not visible
		if visible then
			row.Button.Position = UDim2.fromOffset(0, y)
			y += 39
			local first = index == 1 or (index == 2 and not pieceRows[1].Button.Visible)
			local base = first and 0.38 or 0.5
			local fade = off and 0.55 or 0
			row.Button.BackgroundTransparency = 1 - (1 - base) * (1 - fade)
			row.Cost.Text = costText
			row.Cost.TextColor3 = bad and CONFIG.Red or CONFIG.Text
			row.Cost.TextTransparency = 1 - (bad and 1 or 0.7) * (1 - fade)
			row.Name.TextTransparency = fade
			row.Cap.Frame.BackgroundTransparency = 1 - 0.5 * (1 - fade)
			row.Cap.Stroke.Transparency = 1 - 0.18 * (1 - fade)
			row.Cap.Label.TextTransparency = fade
			row.Cap.Icon.ImageTransparency = fade
			if mobile then
				setKeycapContent(row.Cap, nil, row.IconId, 15)
			else
				setKeycapContent(row.Cap, row.KeyLabel)
			end
			row.Button.Active = mobile and not off
		end
	end
end

local function renderHud()
	local mobile = isMobile()
	local hammer = state.hammer
	local buildOn = state.menuOpen or state.placing ~= nil
	buildButton.Button.Visible = mobile and hammer and not state.menuOpen
	setButtonOn(buildButton, buildOn)
	rotateButton.Button.Visible = mobile and hammer and state.placing ~= nil and not state.menuOpen
	legend.Visible = not mobile and hammer and not state.menuOpen
	rotateKeyRow.Row.Visible = state.placing ~= nil
	setKeycapOn(buildKeyRow.Cap, buildOn)

	local placing = state.placing
	prompt.Visible = hammer and placing ~= nil and not state.menuOpen
	if prompt.Visible then
		if mobile then
			setKeycapContent(promptCap, "TAP")
			promptCap.Frame.Size = UDim2.fromOffset(math.max(30, math.ceil(textWidth("TAP", 15)) + 14), 26)
		else
			setKeycapContent(promptCap, "CLICK")
			promptCap.Frame.Size = UDim2.fromOffset(math.max(30, math.ceil(textWidth("CLICK", 15)) + 14), 26)
		end
		promptText.Text = spaced("PLACE " .. string.upper(fullName(placing.name, placing.stone, placing.structure)), 1.5)
		local cost = costInfo(placing.name, placing.stone)
		if cost then
			promptCost.Text = cost.ok and (cost.amount .. " " .. cost.material) or ("Need " .. (cost.amount - cost.have) .. " more " .. cost.material)
			promptCost.TextColor3 = cost.ok and CONFIG.Text or CONFIG.Red
			promptCost.TextTransparency = cost.ok and 0.3 or 0
		else
			promptCost.Text = ""
		end
	end
	renderPieceMenu()
end

local fadeEntries = {}
local fadeActive = false
local fadeValue = new("NumberValue", { Name = "BuildMenuFade", Value = 1 }, gui)
local textFadeValue = new("NumberValue", { Name = "BuildMenuTextFade", Value = 1 }, gui)
local fadeTweens = {}

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
	for _, object in ipairs(menu:GetDescendants()) do
		local props, textProps = nil, nil
		if object:IsA("GuiObject") then
			props = { BackgroundTransparency = object.BackgroundTransparency }
			if object:IsA("TextLabel") or object:IsA("TextButton") or object:IsA("TextBox") then
				textProps = { TextTransparency = object.TextTransparency }
			elseif object:IsA("ImageLabel") or object:IsA("ImageButton") then
				props.ImageTransparency = object.ImageTransparency
			end
			if object:IsA("ScrollingFrame") then
				props.ScrollBarImageTransparency = object.ScrollBarImageTransparency
			end
		elseif object:IsA("UIStroke") then
			props = { Transparency = object.Transparency }
		end
		if props then
			table.insert(fadeEntries, { object, props, textProps })
		end
	end
	table.insert(fadeEntries, { menu, { BackgroundTransparency = menu.BackgroundTransparency } })
	fadeActive = true
end

local function onFadeChanged()
	if fadeActive then
		applyFade(fadeValue.Value, textFadeValue.Value)
	end
end
fadeValue.Changed:Connect(onFadeChanged)
textFadeValue.Changed:Connect(onFadeChanged)

local function stopFade()
	for _, t in ipairs(fadeTweens) do
		t:Cancel()
	end
	table.clear(fadeTweens)
end

local function fadeTween(object, duration, props, style, direction, delay)
	local t = TweenService:Create(object, TweenInfo.new(duration, style, direction, 0, false, delay or 0), props)
	t:Play()
	table.insert(fadeTweens, t)
	return t
end

local menuLockUntil = 0
local function setMenu(open, instant)
	if state.menuOpen == open then
		return
	end
	if not instant and os.clock() < menuLockUntil then
		return
	end
	menuLockUntil = os.clock() + (open and 0.26 or 0.18) + 0.1
	state.menuOpen = open
	modal.Visible = open
	stopFade()
	local Sine, Quint = Enum.EasingStyle.Sine, Enum.EasingStyle.Quint
	local Out, In = Enum.EasingDirection.Out, Enum.EasingDirection.In
	if open then
		updateMenuLayout()
		endFade()
		renderMenu()
		startFade()
		fadeValue.Value = 0
		textFadeValue.Value = 0
		applyFade(0, 0)
		openScale.Scale = 0.985
		menu.Visible = true
		dim.Visible = true
		fadeTween(openScale, 0.26, { Scale = 1 }, Quint, Out)
		fadeTween(fadeValue, 0.2, { Value = 1 }, Sine, Out)
		local fadeIn = fadeTween(textFadeValue, 0.2, { Value = 1 }, Sine, Out)
		fadeTween(dim, 0.2, { BackgroundTransparency = CONFIG.DimTransparency }, Sine, Out)
		fadeTween(blur, 0.2, { Size = CONFIG.BlurSize }, Sine, Out)
		fadeIn.Completed:Once(function(playback)
			if playback == Enum.PlaybackState.Completed and state.menuOpen then
				endFade()
			end
		end)
	elseif instant then
		endFade()
		menu.Visible = false
		dim.Visible = false
		dim.BackgroundTransparency = 1
		blur.Size = 0
		openScale.Scale = 1
	else
		startFade()
		fadeValue.Value = 1
		textFadeValue.Value = 1
		fadeTween(textFadeValue, 0.07, { Value = 0 }, Sine, In)
		local out = fadeTween(openScale, 0.12, { Scale = 0.96 }, Sine, In, 0.06)
		fadeTween(fadeValue, 0.18, { Value = 0 }, Sine, In)
		fadeTween(dim, 0.16, { BackgroundTransparency = 1 }, Sine, In)
		fadeTween(blur, 0.16, { Size = 0 }, Sine, In)
		out.Completed:Once(function(playback)
			if playback == Enum.PlaybackState.Completed and not state.menuOpen then
				menu.Visible = false
				dim.Visible = false
				endFade()
				openScale.Scale = 1
			end
		end)
	end
	renderHud()
end

local function cancelPlacing()
	if state.placing then
		state.placing = nil
		BuildHooks.CancelPlacing()
	end
end

local function openMenu()
	if not state.hammer then
		return
	end
	cancelPlacing()
	setMenu(true)
end

local function toggleBuild()
	if not state.hammer then
		return
	end
	if state.menuOpen then
		setMenu(false)
	elseif state.placing then
		cancelPlacing()
		renderHud()
	else
		openMenu()
	end
end

local function selectPiece()
	local structure = isStructure(state.tab)
	local stone = structure and state.stone
	local cost = costInfo(state.selected, stone)
	if not (cost and cost.ok) then
		return
	end
	state.placing = { name = state.selected, stone = stone, structure = structure }
	setMenu(false)
	BuildHooks.StartPlacing(state.selected, stone)
	renderHud()
end

local function rotatePlacing()
	if state.placing and not state.menuOpen then
		BuildHooks.RotatePlacing()
	end
end

local function placePiece()
	local placing = state.placing
	if not (state.hammer and placing and not state.menuOpen) then
		return
	end
	local cost = costInfo(placing.name, placing.stone)
	if not (cost and cost.ok) then
		return
	end
	BuildHooks.PlacePiece(placing.name, placing.stone)
end

local function pieceAction(kind)
	if not pieceMenu.Visible or state.rowOff[kind] then
		return
	end
	local piece = state.piece
	if kind == "Upgrade" then
		BuildHooks.Upgrade(piece)
	elseif kind == "Repair" then
		BuildHooks.Repair(piece)
	elseif kind == "Destroy" then
		BuildHooks.Destroy(piece)
	end
end

local function setHammer(on)
	if state.hammer == on then
		return
	end
	state.hammer = on
	if not on then
		cancelPlacing()
		setMenu(false, true)
		state.piece = nil
		state.pieceKey = nil
	end
	renderHud()
end

for name, pill in pairs(tabButtons) do
	pill.Activated:Connect(function()
		if state.tab == name then
			return
		end
		state.tab = name
		state.selected = PIECES[name][1][1]
		strips[name].CanvasPosition = Vector2.zero
		renderMenu()
	end)
end

for tab, list in pairs(tiles) do
	for name, tile in pairs(list) do
		tile.Button.Activated:Connect(function()
			if state.tab == tab then
				state.selected = name
				renderMenu()
			end
		end)
	end
end

for key, pill in pairs(typeButtons) do
	pill.Activated:Connect(function()
		state.stone = key == "stone"
		renderMenu()
	end)
end

for _, row in ipairs(pieceRows) do
	row.Button.Activated:Connect(function()
		if isMobile() then
			pieceAction(row.Kind)
		end
	end)
end

selectButton.Activated:Connect(selectPiece)
closeButton.Activated:Connect(function()
	setMenu(false)
end)
dim.Activated:Connect(function()
	setMenu(false)
end)
buildButton.Button.Activated:Connect(toggleBuild)
rotateButton.Button.Activated:Connect(rotatePlacing)

UserInputService.InputBegan:Connect(function(input, processed)
	if UserInputService:GetFocusedTextBox() then
		return
	end
	local key = input.KeyCode
	if key == CONFIG.BuildKey then
		toggleBuild()
		return
	end
	if not state.hammer then
		return
	end
	if state.menuOpen then
		return
	end
	if state.placing then
		if key == CONFIG.RotateKey then
			rotatePlacing()
		elseif input.UserInputType == Enum.UserInputType.MouseButton1 and not processed then
			placePiece()
		end
		return
	end
	if key == CONFIG.UpgradeKey then
		pieceAction("Upgrade")
	elseif key == CONFIG.RepairKey then
		pieceAction("Repair")
	elseif key == CONFIG.DestroyKey then
		pieceAction("Destroy")
	end
end)

UserInputService.TouchTapInWorld:Connect(function(_, processedByUI)
	if not processedByUI and state.placing then
		placePiece()
	end
end)

local function pieceSignature(piece)
	if not piece then
		return nil
	end
	return table.concat({
		tostring(piece.Id), tostring(piece.Name), tostring(piece.Stone), tostring(piece.Structure),
		tostring(piece.Health), tostring(piece.MaxHealth), tostring(piece.UpgradeCost),
		tostring(piece.RepairCost), tostring(piece.RepairMaterial), tostring(piece.Refund), tostring(piece.RefundMaterial),
	}, "|")
end

local refreshTimer = 0
local lastMobile = isMobile()
RunService.RenderStepped:Connect(function(dt)
	setHammer(BuildHooks.IsHammerEquipped() == true)
	if not state.hammer then
		return
	end
	local piece = nil
	if not state.placing and not state.menuOpen then
		piece = BuildHooks.GetLookedAtPiece()
	end
	local signature = pieceSignature(piece)
	local changed = signature ~= state.pieceKey
	state.piece = piece
	state.pieceKey = signature
	refreshTimer += dt
	local mobile = isMobile()
	if mobile ~= lastMobile then
		lastMobile = mobile
		changed = true
	end
	if refreshTimer >= 0.25 then
		refreshTimer = 0
		changed = true
		if state.menuOpen and not fadeActive then
			updateMenuLayout()
			renderMenu()
		end
	end
	if changed then
		renderHud()
	end
end)

gui.Destroying:Connect(function()
	blur:Destroy()
	dimGui:Destroy()
	buttonGui:Destroy()
end)

renderMenu()
renderHud()
