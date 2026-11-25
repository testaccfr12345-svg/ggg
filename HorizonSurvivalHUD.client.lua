local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local ASSETS = {
	Health = { Id = "130177617556652", Canvas = 420, X = 120, Y = 120, Width = 180, Height = 179 },
	Hunger = { Id = "96663414336154", Plain = true },
	Thirst = { Id = "101658142884052", Canvas = 1024, X = 296, Y = 274, Width = 426, Height = 476 },
}

local DEMO = { Health = 85, Hunger = 64, Thirst = 18 }
local ORDER = { "Health", "Hunger", "Thirst" }
local CREAM = Color3.fromRGB(237, 232, 220)
local BLACK = Color3.new(0, 0, 0)
local HAZE = "rbxassetid://130881451468251"
local FONT = Enum.Font.PatrickHand
local COLORS = {
	Health = Color3.fromRGB(224, 122, 110),
	Hunger = Color3.fromRGB(235, 170, 106),
	Thirst = Color3.fromRGB(128, 185, 221),
}
local MARKS = {
	Health = { { -1.5, -0.5, 0.95 }, { -3.6, 0.1, 0.91 }, { -3.7, 0.0, 0.87 }, { -0.6, -0.6, 0.87 }, { -0.6, 0.5, 0.88 }, { -2.3, 0.2, 0.99 }, { 0.6, -0.1, 1.00 }, { -3.8, 0.5, 0.90 }, { -3.0, -0.6, 0.90 }, { 2.7, -0.5, 0.94 } },
	Hunger = { { 1.2, -0.2, 0.94 }, { -3.7, -0.6, 0.89 }, { 1.5, -0.1, 0.90 }, { 0.7, -0.1, 0.90 }, { 2.5, 0.3, 0.89 }, { 0.6, 0.0, 0.98 }, { 1.9, -0.3, 1.00 }, { -3.2, -0.1, 0.97 }, { -2.9, 0.0, 0.87 }, { 1.4, 0.4, 0.94 } },
	Thirst = { { 3.2, -0.3, 0.96 }, { 0.8, 0.1, 0.92 }, { 2.9, 0.6, 0.93 }, { 1.4, -0.6, 0.96 }, { 1.2, 0.7, 0.98 }, { -1.8, -0.2, 0.95 }, { -4.0, -0.1, 0.88 }, { -3.2, -0.6, 0.97 }, { -3.1, -0.4, 0.91 }, { 3.1, -0.6, 0.92 } },
}
local LOW = 25
local STROKE = "rbxassetid://75577921024956"
local FRAME_W, FRAME_H, FRAMES = 48, 144, 20
local function clamp(x, a, b)
	if x < a then
		return a
	elseif x > b then
		return b
	end
	return x
end
local function round(x)
	return math.floor(x + 0.5)
end
local FILL_TWEEN = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local PULSE_TWEEN = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local previous = playerGui:FindFirstChild("HorizonSurvivalHUD")
if previous then
	previous:Destroy()
end

local function create(className, name, parent, properties)
	local object = Instance.new(className)
	object.Name = name
	if object:IsA("GuiObject") then
		object.BorderSizePixel = 0
	end
	for property, value in pairs(properties) do
		object[property] = value
	end
	object.Parent = parent
	return object
end

local gui = create("ScreenGui", "HorizonSurvivalHUD", playerGui, {
	ResetOnSpawn = false,
	IgnoreGuiInset = false,
	DisplayOrder = 10,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
})
pcall(function()
	gui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
end)
pcall(function()
	gui.ClipToDeviceSafeArea = false
end)

local root = create("Frame", "SurvivalStats", gui, {
	AnchorPoint = Vector2.new(0, 0),
	Position = UDim2.fromOffset(18, 8),
	Size = UDim2.fromOffset(140, 63),
	BackgroundTransparency = 1,
})
local rootScale = create("UIScale", "Scale", root, {})
create("ImageLabel", "Haze", root, {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.new(1, 60, 1, 46),
	BackgroundTransparency = 1,
	Image = HAZE,
	ImageColor3 = BLACK,
	ImageTransparency = 0.75,
	ScaleType = Enum.ScaleType.Stretch,
	ZIndex = 0,
})
local rowsFrame = create("Frame", "Rows", root, {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	ZIndex = 1,
})
create("UIListLayout", "Layout", rowsFrame, {
	FillDirection = Enum.FillDirection.Vertical,
	Padding = UDim.new(0, 6),
	SortOrder = Enum.SortOrder.LayoutOrder,
})

local function cropIcon(parent, name, asset, color, transparency, offsetY, z)
	local box = create("Frame", name, parent, {
		Position = UDim2.fromOffset(0, offsetY),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		ZIndex = z,
	})
	if asset.Plain then
		return create("ImageLabel", "Image", box, {
			BackgroundTransparency = 1,
			Image = "rbxassetid://" .. asset.Id,
			ImageColor3 = color,
			ImageTransparency = transparency,
			ScaleType = Enum.ScaleType.Fit,
			Size = UDim2.fromScale(1, 1),
			ZIndex = z,
		})
	end
	local fit = math.min(15 / asset.Width, 15 / asset.Height)
	local image = create("ImageLabel", "Image", box, {
		BackgroundTransparency = 1,
		Image = "rbxassetid://" .. asset.Id,
		ImageColor3 = color,
		ImageTransparency = transparency,
		Size = UDim2.fromOffset(asset.Canvas * fit, asset.Canvas * fit),
		Position = UDim2.fromOffset(7.5 - (asset.X + asset.Width / 2) * fit, 7.5 - (asset.Y + asset.Height / 2) * fit),
		ZIndex = z,
	})
	return image
end

local rows = {}
local drawMarks

local function makeRow(name, order)
	local row = create("Frame", name, rowsFrame, {
		Size = UDim2.fromOffset(0, 17),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		LayoutOrder = order,
	})
	create("UIListLayout", "Layout", row, {
		FillDirection = Enum.FillDirection.Horizontal,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		Padding = UDim.new(0, 9),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})

	local iconHolder = create("Frame", "Icon", row, {
		Size = UDim2.fromOffset(15, 15),
		BackgroundTransparency = 1,
		LayoutOrder = 1,
	})
	local icon = cropIcon(iconHolder, "Main", ASSETS[name], COLORS[name], 0, 0, 2)

	local marks = create("Frame", "Marks", row, {
		Size = UDim2.fromOffset(81.75, 17),
		BackgroundTransparency = 1,
		LayoutOrder = 2,
	})
	local strokes = {}
	for i = 0, 9 do
		local m = MARKS[name][i + 1]
		local cx = 7.5 * i + 3.75 + m[2] + (i >= 5 and 6.75 or 0)
		local holder = create("Frame", "Stroke" .. (i + 1), marks, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(cx, 8.5),
			Size = UDim2.fromOffset(8, 24 * m[3]),
			Rotation = m[1],
			BackgroundTransparency = 1,
		})
		create("ImageLabel", "Track", holder, {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Image = STROKE,
			ImageRectOffset = Vector2.new(FRAMES * FRAME_W, 0),
			ImageRectSize = Vector2.new(FRAME_W, FRAME_H),
			ImageColor3 = COLORS[name],
			ImageTransparency = 0.78,
			ScaleType = Enum.ScaleType.Stretch,
			ZIndex = 1,
		})
		local fill = create("ImageLabel", "Fill", holder, {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Image = STROKE,
			ImageRectOffset = Vector2.new(0, 0),
			ImageRectSize = Vector2.new(FRAME_W, FRAME_H),
			ImageColor3 = COLORS[name],
			ScaleType = Enum.ScaleType.Stretch,
			Visible = false,
			ZIndex = 2,
		})
		strokes[i + 1] = { fill = fill, frame = -1 }
	end

	local valueHolder = create("Frame", "Value", row, {
		Size = UDim2.fromOffset(18, 17),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		LayoutOrder = 3,
	})
	local value = create("TextLabel", "Main", valueHolder, {
		Size = UDim2.fromOffset(18, 17),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		Font = FONT,
		TextSize = 19,
		TextColor3 = CREAM,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
		ZIndex = 2,
	})

	local pulse = Instance.new("NumberValue")
	local r = {
		name = name,
		icon = icon,
		value = value,
		strokes = strokes,
		pulse = pulse,
		pulseTween = nil,
		low = false,
		shownPct = Instance.new("NumberValue"),
		fillTween = nil,
	}

	local function applyPulse(t)
		icon.ImageTransparency = t
		value.TextTransparency = t
	end
	pulse.Changed:Connect(applyPulse)
	r.shownPct.Changed:Connect(function(v)
		drawMarks(r, v)
	end)
	r.applyPulse = applyPulse
	rows[name] = r
	return r
end

for i, name in ipairs(ORDER) do
	makeRow(name, i)
end

local function setLow(r, low)
	if r.low == low then
		return
	end
	r.low = low
	if r.pulseTween then
		r.pulseTween:Cancel()
		r.pulseTween = nil
	end
	r.pulse.Value = 0
	r.applyPulse(0)
	if low then
		r.pulseTween = TweenService:Create(r.pulse, PULSE_TWEEN, { Value = 0.6 })
		r.pulseTween:Play()
	end
end

drawMarks = function(r, percent)
	for i, st in ipairs(r.strokes) do
		local k = round(clamp(percent / 10 - (i - 1), 0, 1) * FRAMES)
		if k ~= st.frame then
			st.frame = k
			st.fill.Visible = k > 0
			st.fill.ImageRectOffset = Vector2.new(k * FRAME_W, 0)
		end
	end
end

local function show(name, percent, shown, instant)
	local r = rows[name]
	percent = clamp(percent, 0, 100)
	r.value.Text = tostring(round(shown))
	setLow(r, percent < LOW)
	if r.fillTween then
		r.fillTween:Cancel()
		r.fillTween = nil
	end
	if instant then
		r.shownPct.Value = percent
		drawMarks(r, percent)
	else
		r.fillTween = TweenService:Create(r.shownPct, FILL_TWEEN, { Value = percent })
		r.fillTween:Play()
	end
end

local function resize()
	local camera = Workspace.CurrentCamera
	local h = camera and camera.ViewportSize.Y or 414
	rootScale.Scale = clamp(h / 550, 1, 1)
end

local cameraConnection
local function bindCamera()
	if cameraConnection then
		cameraConnection:Disconnect()
		cameraConnection = nil
	end
	local camera = Workspace.CurrentCamera
	if camera then
		cameraConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(resize)
	end
	resize()
end

local function numberAttribute(name, fallback)
	local value = player:GetAttribute(name)
	if type(value) == "number" and value == value and math.abs(value) < math.huge then
		return value
	end
	return fallback
end

local function updateNeed(name, instant)
	local maximum = numberAttribute(name .. "Max", 100)
	local value = numberAttribute(name, maximum * DEMO[name] / 100)
	local percent = maximum > 0 and clamp(value / maximum, 0, 1) * 100 or 0
	show(name, percent, percent, instant)
end

local connections = {}
local characterConnections = {}
local healthConnections = {}

local function disconnectAll(group)
	for _, connection in ipairs(group) do
		connection:Disconnect()
	end
	for i = #group, 1, -1 do
		group[i] = nil
	end
end

local function bindHealth(humanoid, instant)
	disconnectAll(healthConnections)
	if not humanoid then
		show("Health", DEMO.Health, DEMO.Health, instant)
		return
	end
	local function update()
		local maxHealth = humanoid.MaxHealth
		local health = math.max(0, humanoid.Health)
		show("Health", maxHealth > 0 and health / maxHealth * 100 or 0, health, false)
	end
	table.insert(healthConnections, humanoid.HealthChanged:Connect(update))
	table.insert(healthConnections, humanoid:GetPropertyChangedSignal("MaxHealth"):Connect(update))
	update()
end

local function bindCharacter(character)
	disconnectAll(characterConnections)
	if not character then
		bindHealth(nil, false)
		return
	end
	local function refresh(child)
		if child:IsA("Humanoid") then
			bindHealth(character:FindFirstChildOfClass("Humanoid"), false)
		end
	end
	table.insert(characterConnections, character.ChildAdded:Connect(refresh))
	table.insert(characterConnections, character.ChildRemoved:Connect(refresh))
	bindHealth(character:FindFirstChildOfClass("Humanoid"), false)
end

for _, name in ipairs({ "Hunger", "Thirst" }) do
	local function update()
		updateNeed(name, false)
	end
	table.insert(connections, player:GetAttributeChangedSignal(name):Connect(update))
	table.insert(connections, player:GetAttributeChangedSignal(name .. "Max"):Connect(update))
	updateNeed(name, true)
end

table.insert(connections, player.CharacterAdded:Connect(bindCharacter))
table.insert(connections, player.CharacterRemoving:Connect(function()
	bindCharacter(nil)
end))
table.insert(connections, Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(bindCamera))

gui.Destroying:Connect(function()
	for _, r in pairs(rows) do
		if r.pulseTween then
			r.pulseTween:Cancel()
		end
		if r.fillTween then
			r.fillTween:Cancel()
		end
	end
	if cameraConnection then
		cameraConnection:Disconnect()
	end
	disconnectAll(connections)
	disconnectAll(characterConnections)
	disconnectAll(healthConnections)
end)

bindCamera()
bindCharacter(player.Character)
