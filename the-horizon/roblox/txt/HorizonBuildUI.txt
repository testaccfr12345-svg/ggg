local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

for _, name in ipairs({ "HorizonBuildUI", "HorizonBuildDim" }) do
	local existing = playerGui:FindFirstChild(name)
	if existing then
		existing:Destroy()
	end
end

local CONFIG = {
	Accent = Color3.fromRGB(233, 185, 73),
	Text = Color3.fromRGB(237, 232, 220),
	Ink = Color3.fromRGB(27, 26, 20),
	Red = Color3.fromRGB(224, 122, 110),
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

local function tween(object, duration, props, style, direction)
	local t = TweenService:Create(object, TweenInfo.new(duration, style or Enum.EasingStyle.Sine, direction or Enum.EasingDirection.Out), props)
	t:Play()
	return t
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
	return CONFIG.PieceImages[fullName(name, stone, structure)] or ""
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

local menu = new("Frame", {
	Name = "BuildMenu",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 14),
	Size = UDim2.fromOffset(620, 380),
	BackgroundColor3 = CONFIG.PanelColor,
	BackgroundTransparency = CONFIG.PanelTransparency,
	BorderSizePixel = 0,
	Active = true,
	Visible = false,
}, stage)
corner(menu, 14)

local content = new("Frame", {
	Name = "Content",
	Position = UDim2.fromOffset(14, 14),
	Size = UDim2.fromOffset(592, 352),
	BackgroundTransparency = 1,
}, menu)

text(content, 27, { Name = "Title", Size = UDim2.fromOffset(200, 30), Text = spaced("Build", 1), RichText = true })

local closeButton = new("TextButton", {
	Name = "Close",
	Position = UDim2.fromOffset(562, 0),
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
			Position = UDim2.fromOffset(right, 0),
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
		Size = UDim2.fromOffset(592, 85),
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
	Size = UDim2.fromOffset(290, 217),
	BackgroundColor3 = WHITE,
	BackgroundTransparency = 0.95,
	BorderSizePixel = 0,
}, content)
corner(preview, 11)
local previewPicture = image(preview, 104)
local previewName = text(preview, 26, { AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.fromOffset(262, 26), TextXAlignment = Enum.TextXAlignment.Center })
local previewCategory = text(preview, 14, { AnchorPoint = Vector2.new(0.5, 0), Size = UDim2.fromOffset(262, 19), TextTransparency = 0.3, TextXAlignment = Enum.TextXAlignment.Center })
local previewDesc = text(preview, 15, {
	AnchorPoint = Vector2.new(0.5, 0),
	Size = UDim2.fromOffset(262, 20),
	TextTransparency = 0.15,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Center,
	TextYAlignment = Enum.TextYAlignment.Top,
})

local side = new("Frame", {
	Name = "Side",
	Position = UDim2.fromOffset(302, 135),
	Size = UDim2.fromOffset(290, 217),
	BackgroundTransparency = 1,
}, content)

local typeRow = new("Frame", { Name = "TypeRow", Size = UDim2.fromOffset(290, 30), BackgroundTransparency = 1 }, side)
text(typeRow, 15, { Size = UDim2.fromOffset(100, 30), Text = "Type", TextTransparency = 0.3 })
local typeButtons = {}
do
	local right = 290
	for _, entry in ipairs({ { "stone", "Stone" }, { "wood", "Wood" } }) do
		local width = math.ceil(textWidth(entry[2], 17)) + 30
		right -= width
		local pill = new("TextButton", {
			Name = entry[2],
			Position = UDim2.fromOffset(right, 0),
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

local materialsLabel = text(side, 15, { Size = UDim2.fromOffset(290, 20), Text = "Required materials", TextTransparency = 0.3 })

local materialRow = new("Frame", {
	Name = "MaterialRow",
	Size = UDim2.fromOffset(290, 42),
	BackgroundColor3 = WHITE,
	BackgroundTransparency = 0.94,
	BorderSizePixel = 0,
}, side)
corner(materialRow, 9)
local materialIcon = image(materialRow, 26, { Position = UDim2.fromOffset(23, 21) })
local materialName = text(materialRow, 16, { Position = UDim2.fromOffset(44, 6), Size = UDim2.fromOffset(160, 17) })
local materialStatus = text(materialRow, 13, { Position = UDim2.fromOffset(44, 23), Size = UDim2.fromOffset(160, 14) })
local materialAmount = text(materialRow, 18, {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -10, 0, 0),
	Size = UDim2.fromOffset(100, 42),
	TextXAlignment = Enum.TextXAlignment.Right,
})

local selectButton = new("TextButton", {
	Name = "Select",
	Position = UDim2.fromOffset(0, 173),
	Size = UDim2.fromOffset(290, 44),
	BackgroundColor3 = CONFIG.Accent,
	AutoButtonColor = false,
	FontFace = FONT,
	TextSize = ts(23),
	TextColor3 = CONFIG.Ink,
	RichText = true,
	Text = "",
}, side)
corner(selectButton, 11)

local function mobileButton(name, iconId, label, rightOffset, bottomOffset)
	local button = new("TextButton", {
		Name = name,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -rightOffset, 1, -bottomOffset),
		Size = UDim2.fromOffset(48, 48),
		BackgroundColor3 = CONFIG.PanelColor,
		BackgroundTransparency = 0.5,
		AutoButtonColor = false,
		Text = "",
		Visible = false,
	}, stage)
	corner(button, UDim.new(0.5, 0))
	local stroke = ring(button, 1.5, 0.75, UDim.new(0.5, 0))
	image(button, 18, { Position = UDim2.fromOffset(24, 18), Image = iconId })
	text(button, 11, {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromOffset(24, 33.5),
		Size = UDim2.fromOffset(48, 14),
		Text = label,
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			button.BackgroundTransparency = 0.38
		end
	end)
	button.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			button.BackgroundTransparency = 0.5
		end
	end)
	return { Button = button, Stroke = stroke }
end

local buildButton = mobileButton("BuildButton", CONFIG.Icons.Build, "Build", 58, 162)
local rotateButton = mobileButton("RotateButton", CONFIG.Icons.Rotate, "Rotate", 58, 220)

local function setButtonOn(entry, on)
	entry.Stroke.Thickness = on and 1.2 or 1.5
	entry.Stroke.Transparency = on and 0.3 or 0.75
	entry.Stroke.Parent.Position = UDim2.fromOffset(entry.Stroke.Thickness, entry.Stroke.Thickness)
	entry.Stroke.Parent.Size = UDim2.new(1, -2 * entry.Stroke.Thickness, 1, -2 * entry.Stroke.Thickness)
end

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
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
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
	local descHeight = 0
	if desc ~= "" then
		descHeight = TextService:GetTextSize(desc, ts(15), CONFIG.FontEnum, Vector2.new(262, 1000)).Y
	end
	local total = 104 + 2 + 26 + 2 + 19 + (desc ~= "" and (4 + descHeight) or 0)
	local y = (217 - total) / 2
	previewPicture.Size = UDim2.fromOffset(pictureSize, pictureSize)
	previewPicture.Position = UDim2.fromOffset(145, y + 52)
	y += 104 + 2
	previewName.Position = UDim2.fromOffset(145, y)
	y += 26 + 2
	previewCategory.Position = UDim2.fromOffset(145, y)
	y += 19 + 4
	previewDesc.Position = UDim2.fromOffset(145, y)
	previewDesc.Size = UDim2.fromOffset(262, descHeight)
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
	else
		materialIcon.Visible = false
		materialName.Text = "No recipe yet"
		materialStatus.Text = ""
		materialAmount.Text = ""
	end
	materialName.Position = UDim2.fromOffset(cost and 44 or 12, cost and 6 or 12)

	local can = cost ~= nil and cost.ok
	selectButton.Active = can
	selectButton.BackgroundColor3 = can and CONFIG.Accent or WHITE
	selectButton.BackgroundTransparency = can and 0 or 0.92
	selectButton.TextColor3 = can and CONFIG.Ink or CONFIG.Text
	selectButton.TextTransparency = can and 0 or 0.4
	selectButton.Text = spaced(can and "Select" or (cost and "Missing materials" or "Not available yet"), 1)
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
local fadeValue = new("NumberValue", { Name = "BuildMenuFade", Value = 0 }, gui)
local fadeTweens = {}

local function snapshotFade()
	table.clear(fadeEntries)
	for _, object in ipairs(menu:GetDescendants()) do
		local props = nil
		if object:IsA("GuiObject") then
			props = { BackgroundTransparency = object.BackgroundTransparency }
			if object:IsA("TextLabel") or object:IsA("TextButton") then
				props.TextTransparency = object.TextTransparency
			elseif object:IsA("ImageLabel") or object:IsA("ImageButton") then
				props.ImageTransparency = object.ImageTransparency
			end
		elseif object:IsA("UIStroke") then
			props = { Transparency = object.Transparency }
		end
		if props then
			table.insert(fadeEntries, { object, props })
		end
	end
	table.insert(fadeEntries, { menu, { BackgroundTransparency = CONFIG.PanelTransparency } })
end

local function applyFade(alpha)
	for _, entry in ipairs(fadeEntries) do
		for prop, base in pairs(entry[2]) do
			entry[1][prop] = 1 - (1 - base) * alpha
		end
	end
end

fadeValue.Changed:Connect(applyFade)

local function stopFade()
	for _, t in ipairs(fadeTweens) do
		t:Cancel()
	end
	table.clear(fadeTweens)
end

local function restoreFade()
	if #fadeEntries > 0 then
		applyFade(1)
		table.clear(fadeEntries)
	end
end

local function setMenu(open, instant)
	if state.menuOpen == open then
		return
	end
	state.menuOpen = open
	modal.Visible = open
	stopFade()
	restoreFade()
	if open then
		renderMenu()
		snapshotFade()
		fadeValue.Value = 0
		applyFade(0)
		menu.Visible = true
		dim.Visible = true
		local fadeIn = tween(fadeValue, 0.16, { Value = 1 })
		table.insert(fadeTweens, fadeIn)
		fadeIn.Completed:Once(function(playback)
			if playback == Enum.PlaybackState.Completed and state.menuOpen then
				table.clear(fadeEntries)
				renderMenu()
			end
		end)
		table.insert(fadeTweens, tween(dim, 0.16, { BackgroundTransparency = CONFIG.DimTransparency }))
		table.insert(fadeTweens, tween(blur, 0.16, { Size = CONFIG.BlurSize }))
	elseif instant then
		menu.Visible = false
		dim.Visible = false
		dim.BackgroundTransparency = 1
		blur.Size = 0
	else
		snapshotFade()
		fadeValue.Value = 1
		local out = tween(fadeValue, 0.12, { Value = 0 }, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
		table.insert(fadeTweens, out)
		table.insert(fadeTweens, tween(dim, 0.12, { BackgroundTransparency = 1 }, Enum.EasingStyle.Sine, Enum.EasingDirection.In))
		table.insert(fadeTweens, tween(blur, 0.12, { Size = 0 }, Enum.EasingStyle.Sine, Enum.EasingDirection.In))
		out.Completed:Once(function(playback)
			if playback == Enum.PlaybackState.Completed and not state.menuOpen then
				menu.Visible = false
				dim.Visible = false
				restoreFade()
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
		if state.menuOpen and #fadeEntries == 0 then
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
end)

renderMenu()
renderHud()
