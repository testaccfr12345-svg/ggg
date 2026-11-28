local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local SHOW_TEST_BUTTONS = true

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local existing = playerGui:FindFirstChild("HorizonItemFeed")
if existing then
	existing:Destroy()
end

local CONFIG = {
	Added = Color3.fromRGB(237, 232, 220),
	Removed = Color3.fromRGB(224, 122, 110),
	Shadow = Color3.fromRGB(24, 19, 15),
	FontEnum = Enum.Font.PatrickHand,
	FontScale = 1.354,
	TextSize = 16,
	IconSize = 16,
	LetterSpacing = 0.6,
	Top = 14,
	LineHeight = 25,
	MaxLines = 4,
	RankAlpha = { 1, 0.8, 0.55, 0.35 },
	ShowTime = 3,
	FadeInTime = 0.2,
	FadeOutTime = 0.4,
	DesignWidth = 896,
	DesignHeight = 414,
	Icons = {
		Wood = "",
		Planks = "",
		Stone = "",
		Thatch = "",
		Fiber = "",
		Rope = "",
	},
}

local TEST_ITEMS = { "Wood", "Planks", "Stone", "Thatch", "Fiber", "Rope" }

local FONT = Font.fromEnum(CONFIG.FontEnum)

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

local function spaced(str, px)
	local gap = '<font size="' .. math.max(1, math.floor(px * CONFIG.FontScale / 0.24 + 0.5)) .. '"> </font>'
	local chars = {}
	for _, code in utf8.codes(str) do
		table.insert(chars, utf8.char(code))
	end
	return table.concat(chars, gap)
end

local gui = new("ScreenGui", {
	Name = "HorizonItemFeed",
	ResetOnSpawn = false,
	ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 15,
}, playerGui)

local stage = new("Frame", {
	Name = "Stage",
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.fromScale(0.5, 0),
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

local lines = {}

local function applyLine(line)
	local alpha = line.Fade.Value * (CONFIG.RankAlpha[line.Rank] or 0)
	line.Label.TextTransparency = 1 - alpha
	line.Icon.ImageTransparency = 1 - alpha
	line.Shadow.Transparency = 1 - 0.6 * alpha
end

local function layout()
	for index, line in ipairs(lines) do
		line.Rank = index
		line.Frame.Position = UDim2.new(0.5, 0, 0, CONFIG.Top + (index - 1) * CONFIG.LineHeight)
		applyLine(line)
	end
end

local function setText(line)
	local sign = line.Amount > 0 and "+" or "-"
	line.Label.Text = spaced(sign .. math.abs(line.Amount) .. " " .. line.Item, CONFIG.LetterSpacing)
end

local function removeLine(line)
	local index = table.find(lines, line)
	if index then
		table.remove(lines, index)
	end
	line.Removed = true
	if line.Tween then
		line.Tween:Cancel()
	end
	local out = TweenService:Create(line.Fade, TweenInfo.new(CONFIG.FadeOutTime, Enum.EasingStyle.Sine, Enum.EasingDirection.In), { Value = 0 })
	line.Tween = out
	out.Completed:Once(function()
		line.Frame:Destroy()
	end)
	out:Play()
	layout()
end

local function startTimer(line)
	line.Token += 1
	local token = line.Token
	task.delay(CONFIG.ShowTime, function()
		if line.Token == token and not line.Removed then
			removeLine(line)
		end
	end)
end

local function makeLine(item, amount)
	local color = amount > 0 and CONFIG.Added or CONFIG.Removed
	local frame = new("Frame", {
		Name = "Line",
		AnchorPoint = Vector2.new(0.5, 0),
		Size = UDim2.fromOffset(0, CONFIG.LineHeight),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
	}, stage)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
	}, frame)
	local iconId = CONFIG.Icons[item] or ""
	local icon = new("ImageLabel", {
		Name = "Icon",
		LayoutOrder = 1,
		Size = UDim2.fromOffset(CONFIG.IconSize, CONFIG.IconSize),
		BackgroundTransparency = 1,
		ScaleType = Enum.ScaleType.Fit,
		Image = iconId,
		ImageColor3 = color,
		ImageTransparency = 1,
		Visible = iconId ~= "",
	}, frame)
	local label = new("TextLabel", {
		Name = "Text",
		LayoutOrder = 2,
		Size = UDim2.fromOffset(0, CONFIG.LineHeight),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		FontFace = FONT,
		TextSize = math.floor(CONFIG.TextSize * CONFIG.FontScale + 0.5),
		TextColor3 = color,
		TextTransparency = 1,
		RichText = true,
		Text = "",
	}, frame)
	local shadow = new("UIShadow", {
		Mode = Enum.ApplyShadowMode.Text,
		Color = CONFIG.Shadow,
		Offset = UDim2.fromOffset(0, 2),
		BlurRadius = UDim.new(0, 3),
		Transparency = 1,
	}, label)
	local fade = new("NumberValue", { Value = 0 }, frame)
	local line = {
		Item = item,
		Added = amount > 0,
		Amount = amount,
		Frame = frame,
		Icon = icon,
		Label = label,
		Shadow = shadow,
		Fade = fade,
		Rank = 1,
		Token = 0,
		Removed = false,
	}
	fade.Changed:Connect(function()
		applyLine(line)
	end)
	setText(line)
	return line
end

local ItemFeed = {}

function ItemFeed.Add(itemName, amount)
	amount = math.floor(tonumber(amount) or 0)
	if amount == 0 or type(itemName) ~= "string" or itemName == "" then
		return
	end
	local added = amount > 0
	for _, line in ipairs(lines) do
		if line.Item == itemName and line.Added == added and not line.Removed then
			line.Amount += amount
			setText(line)
			startTimer(line)
			return
		end
	end
	local line = makeLine(itemName, amount)
	table.insert(lines, 1, line)
	while #lines > CONFIG.MaxLines do
		removeLine(lines[#lines])
	end
	layout()
	line.Tween = TweenService:Create(line.Fade, TweenInfo.new(CONFIG.FadeInTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), { Value = 1 })
	line.Tween:Play()
	startTimer(line)
end

shared.ItemFeed = ItemFeed

local feedEvent = new("BindableEvent", { Name = "ItemFeedAdd" }, gui)
feedEvent.Event:Connect(ItemFeed.Add)

if SHOW_TEST_BUTTONS then
	local testButtons = new("Frame", {
		Name = "TestButtons",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 12, 0.5, 0),
		Size = UDim2.fromOffset(74, 66),
		BackgroundTransparency = 1,
	}, stage)
	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
	}, testButtons)
	for order, entry in ipairs({ { "+ Item", 1 }, { "- Item", -1 } }) do
		local button = new("TextButton", {
			Name = entry[2] > 0 and "AddItem" or "RemoveItem",
			LayoutOrder = order,
			Size = UDim2.fromOffset(74, 30),
			BackgroundColor3 = Color3.fromRGB(16, 21, 19),
			BackgroundTransparency = 0.4,
			AutoButtonColor = false,
			FontFace = FONT,
			TextSize = 20,
			TextColor3 = entry[2] > 0 and CONFIG.Added or CONFIG.Removed,
			Text = entry[1],
		}, testButtons)
		new("UICorner", { CornerRadius = UDim.new(0, 8) }, button)
		button.Activated:Connect(function()
			ItemFeed.Add(TEST_ITEMS[math.random(1, #TEST_ITEMS)], math.random(1, 6) * entry[2])
		end)
	end
end
