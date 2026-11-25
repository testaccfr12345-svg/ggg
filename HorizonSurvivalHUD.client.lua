local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local ASSETS = {
	Health = { Id = "130177617556652", Canvas = 420, X = 120, Y = 120, Width = 180, Height = 179 },
	Hunger = { Id = "95673501620571", Canvas = 420, X = 113, Y = 96, Width = 199, Height = 225 },
	Thirst = { Id = "101658142884052", Canvas = 1024, X = 296, Y = 274, Width = 426, Height = 476 },
}

local DEMO = { Health = 85, Hunger = 64, Thirst = 18 }
local ORDER = { "Health", "Hunger", "Thirst" }
local CREAM = Color3.fromRGB(237, 232, 220)
local CORAL = Color3.fromRGB(244, 164, 124)
local TRACK = Color3.fromRGB(16, 21, 19)
local FONT = Enum.Font.PatrickHand
local COLORS = {
	Health = Color3.fromRGB(208, 105, 93),
	Hunger = Color3.fromRGB(163, 186, 114),
	Thirst = Color3.fromRGB(125, 176, 204),
}
local MARKS = {
	Health = { { -1.5, -0.5, 0.95 }, { -3.6, 0.1, 0.91 }, { -3.7, 0.0, 0.87 }, { -0.6, -0.6, 0.87 }, { -0.6, 0.5, 0.88 }, { -2.3, 0.2, 0.99 }, { 0.6, -0.1, 1.00 }, { -3.8, 0.5, 0.90 }, { -3.0, -0.6, 0.90 }, { 2.7, -0.5, 0.94 } },
	Hunger = { { 1.2, -0.2, 0.94 }, { -3.7, -0.6, 0.89 }, { 1.5, -0.1, 0.90 }, { 0.7, -0.1, 0.90 }, { 2.5, 0.3, 0.89 }, { 0.6, 0.0, 0.98 }, { 1.9, -0.3, 1.00 }, { -3.2, -0.1, 0.97 }, { -2.9, 0.0, 0.87 }, { 1.4, 0.4, 0.94 } },
	Thirst = { { 3.2, -0.3, 0.96 }, { 0.8, 0.1, 0.92 }, { 2.9, 0.6, 0.93 }, { 1.4, -0.6, 0.96 }, { 1.2, 0.7, 0.98 }, { -1.8, -0.2, 0.95 }, { -4.0, -0.1, 0.88 }, { -3.2, -0.6, 0.97 }, { -3.1, -0.4, 0.91 }, { 3.1, -0.6, 0.92 } },
}
local LOW = 25
local TIP = 0.1
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

local root = create("Frame", "SurvivalStats", gui, {
	AnchorPoint = Vector2.new(0, 0),
	Position = UDim2.fromOffset(18, 8),
	Size = UDim2.fromOffset(0, 0),
	AutomaticSize = Enum.AutomaticSize.XY,
	BackgroundTransparency = 1,
})
local rootScale = create("UIScale", "Scale", root, {})
create("UIListLayout", "Rows", root, {
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

local function makeRow(name, order)
	local row = create("Frame", name, root, {
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
	local icon = cropIcon(iconHolder, "Main", ASSETS[name], CREAM, 0, 0, 2)

	local marks = create("Frame", "Marks", row, {
		Size = UDim2.fromOffset(81.75, 17),
		BackgroundTransparency = 1,
		LayoutOrder = 2,
	})
	local strokes = {}
	for i = 0, 9 do
		local m = MARKS[name][i + 1]
		local h = 15 * m[3]
		local cx = 7.5 * i + 3.75 + m[2] + (i >= 5 and 6.75 or 0)
		local holder = create("Frame", "Stroke" .. (i + 1), marks, {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromOffset(cx, 8.5),
			Size = UDim2.fromOffset(3, h),
			Rotation = m[1],
			BackgroundTransparency = 1,
		})
		local track = create("Frame", "Track", holder, {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = TRACK,
			BackgroundTransparency = 0.5,
			ZIndex = 1,
		})
		create("UICorner", "Corner", track, { CornerRadius = UDim.new(0.5, 0) })
		local fill = create("Frame", "Fill", holder, {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.fromScale(0.5, 1),
			Size = UDim2.fromScale(1, 0),
			BackgroundColor3 = COLORS[name],
			Visible = false,
			ZIndex = 2,
		})
		create("UICorner", "Corner", fill, { CornerRadius = UDim.new(0.5, 0) })
		strokes[i + 1] = { fill = fill, track = track, frac = 0 }
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
		tweens = {},
		ttweens = {},
	}

	local function applyPulse(t)
		icon.ImageTransparency = t
		value.TextTransparency = t
		for _, s in ipairs(strokes) do
			s.fill.BackgroundTransparency = t
		end
	end
	pulse.Changed:Connect(applyPulse)
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
	local color = low and CORAL or CREAM
	r.icon.ImageColor3 = color
	r.value.TextColor3 = color
	for _, s in ipairs(r.strokes) do
		s.fill.BackgroundColor3 = low and CORAL or COLORS[r.name]
	end
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

local function show(name, percent, shown, instant)
	local r = rows[name]
	percent = clamp(percent, 0, 100)
	r.value.Text = tostring(round(shown))
	setLow(r, percent < LOW)
	for i, s in ipairs(r.strokes) do
		local frac = clamp(percent / 10 - (i - 1), 0, 1)
		if frac ~= s.frac or instant then
			s.frac = frac
			if r.tweens[i] then
				r.tweens[i]:Cancel()
				r.tweens[i] = nil
			end
			if r.ttweens[i] then
				r.ttweens[i]:Cancel()
				r.ttweens[i] = nil
			end
			local goal = UDim2.fromScale(1, frac)
			local tgoal = UDim2.fromScale(1, frac >= 1 and TIP or clamp(1 - frac + (frac > 0 and TIP or 0), 0, 1))
			s.track.Visible = true
			if frac > 0 then
				s.fill.Visible = true
			end
			if instant then
				s.fill.Size = goal
				s.fill.Visible = frac > 0
				s.track.Size = tgoal
				s.track.Visible = frac < 1
			else
				local tt = TweenService:Create(s.track, FILL_TWEEN, { Size = tgoal })
				r.ttweens[i] = tt
				tt.Completed:Connect(function(state)
					if state == Enum.PlaybackState.Completed and s.frac >= 1 then
						s.track.Visible = false
					end
				end)
				tt:Play()
				local tw = TweenService:Create(s.fill, FILL_TWEEN, { Size = goal })
				r.tweens[i] = tw
				tw.Completed:Connect(function(state)
					if state == Enum.PlaybackState.Completed and s.frac <= 0 then
						s.fill.Visible = false
					end
				end)
				tw:Play()
			end
		end
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
		for _, tw in pairs(r.tweens) do
			tw:Cancel()
		end
		for _, tw in pairs(r.ttweens) do
			tw:Cancel()
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
