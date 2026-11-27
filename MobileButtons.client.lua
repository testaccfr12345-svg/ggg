local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local CREAM = Color3.fromRGB(237, 232, 220)
local DARK = Color3.fromRGB(16, 21, 19)
local FONT = Enum.Font.PatrickHand
local ICONS = {
	Jump = "rbxassetid://90498940473124",
	Sprint = "rbxassetid://116064107344508",
	Crouch = "rbxassetid://116577259921226",
}
local TOGGLE = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local old = playerGui:FindFirstChild("HorizonMobileButtons")
if old then
	old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "HorizonMobileButtons"
gui.ResetOnSpawn = false
gui.DisplayOrder = 5
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
	gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
end)
gui.Parent = playerGui

local function makeButton(name, size, iconSize, textSize, labelHeight, gap)
	local b = Instance.new("TextButton")
	b.Name = name
	b.Text = ""
	b.AutoButtonColor = false
	b.AnchorPoint = Vector2.new(0.5, 0.5)
	b.Size = UDim2.fromOffset(size, size)
	b.BackgroundColor3 = DARK
	b.BackgroundTransparency = 0.5
	b.BorderSizePixel = 0
	b.Parent = gui
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0.5, 0)
	c.Parent = b
	local st = Instance.new("UIStroke")
	st.Color = CREAM
	st.Thickness = 1
	st.Transparency = 0.75
	st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	pcall(function()
		st.BorderStrokePosition = Enum.BorderStrokePosition.Inner
	end)
	st.Parent = b
	local sc = Instance.new("UIScale")
	sc.Parent = b
	local inner = Instance.new("Frame")
	inner.Name = "Content"
	inner.AnchorPoint = Vector2.new(0.5, 0.5)
	inner.Position = UDim2.fromScale(0.5, 0.5)
	inner.Size = UDim2.fromOffset(size, size)
	inner.BackgroundTransparency = 1
	inner.Parent = b
	local fit = Instance.new("UIScale")
	fit.Parent = inner
	local top = (size - (iconSize + gap + labelHeight)) / 2
	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.AnchorPoint = Vector2.new(0.5, 0)
	icon.Position = UDim2.new(0.5, 0, 0, top)
	icon.Size = UDim2.fromOffset(iconSize, iconSize)
	icon.BackgroundTransparency = 1
	icon.Image = ICONS[name]
	icon.ImageColor3 = CREAM
	icon.ScaleType = Enum.ScaleType.Fit
	icon.Parent = inner
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.AnchorPoint = Vector2.new(0.5, 0)
	label.Position = UDim2.new(0.5, 0, 0, top + iconSize + gap)
	label.Size = UDim2.new(1, 0, 0, labelHeight)
	label.BackgroundTransparency = 1
	label.Font = FONT
	label.Text = name
	label.TextSize = textSize
	label.TextColor3 = CREAM
	label.Parent = inner
	return { button = b, stroke = st, scale = sc, fit = fit, base = size, icon = icon, iconTop = top }
end

local jump = makeButton("Jump", 70, 25, 20, 15, 2)
local sprint = makeButton("Sprint", 48, 16, 15, 11, 1)
local crouch = makeButton("Crouch", 48, 16, 15, 11, 1)

local touchGui, nativeJump
local watch = {}

local function disconnectAll()
	for _, c in ipairs(watch) do
		c:Disconnect()
	end
	for i = #watch, 1, -1 do
		watch[i] = nil
	end
end

local function place()
	local size, cx, cy
	if nativeJump and touchGui and nativeJump.AbsoluteSize.X > 0 then
		local p = nativeJump.AbsolutePosition - gui.AbsolutePosition
		local s = nativeJump.AbsoluteSize
		size = s.X
		cx, cy = p.X + s.X / 2, p.Y + s.Y / 2
	else
		local vp = gui.AbsoluteSize
		local small = math.min(vp.X, vp.Y) <= 500
		size = small and 70 or 120
		local x, y = small and -95 or -170, small and -90 or -210
		cx, cy = vp.X + x + size / 2, vp.Y + y + size / 2
	end
	jump.button.Size = UDim2.fromOffset(size, size)
	jump.fitBase = size / 70
	jump.fit.Scale = jump.fitBase * (jump.pressed and 0.95 or 1)
	jump.button.Position = UDim2.fromOffset(cx, cy)
	sprint.button.Position = UDim2.fromOffset(cx - 71.5, cy - 57)
	crouch.button.Position = UDim2.fromOffset(cx - 87.5, cy + 17)
end

local function hideNative()
	if nativeJump and nativeJump.Visible then
		nativeJump.Visible = false
	end
end

local function bindTouchGui()
	disconnectAll()
	touchGui = playerGui:FindFirstChild("TouchGui")
	if touchGui and touchGui:IsA("ScreenGui") then
		gui.IgnoreGuiInset = touchGui.IgnoreGuiInset
	end
	local frame = touchGui and touchGui:FindFirstChild("TouchControlFrame")
	nativeJump = frame and frame:FindFirstChild("JumpButton")
	if frame then
		table.insert(watch, frame.ChildAdded:Connect(function(c)
			if c.Name == "JumpButton" then
				task.defer(bindTouchGui)
			end
		end))
	end
	if nativeJump then
		hideNative()
		table.insert(watch, nativeJump:GetPropertyChangedSignal("Visible"):Connect(hideNative))
		table.insert(watch, nativeJump:GetPropertyChangedSignal("AbsolutePosition"):Connect(place))
		table.insert(watch, nativeJump:GetPropertyChangedSignal("AbsoluteSize"):Connect(place))
	elseif touchGui then
		table.insert(watch, touchGui.DescendantAdded:Connect(function(d)
			if d.Name == "JumpButton" or d.Name == "TouchControlFrame" then
				task.defer(bindTouchGui)
			end
		end))
	end
	place()
end

playerGui.ChildAdded:Connect(function(c)
	if c.Name == "TouchGui" then
		task.defer(bindTouchGui)
	end
end)
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(place)
gui:GetPropertyChangedSignal("AbsolutePosition"):Connect(place)

local function isTouch()
	local ok, pref = pcall(function()
		return UserInputService.PreferredInput
	end)
	if ok and pref then
		return pref == Enum.PreferredInput.Touch
	end
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end
local function updateEnabled()
	gui.Enabled = isTouch()
end
pcall(function()
	UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(updateEnabled)
end)
updateEnabled()

local function humanoid()
	local char = player.Character
	return char and char:FindFirstChildOfClass("Humanoid")
end

local held = false
local holdInput
local PRESS = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local function setJump(on)
	if held == on then
		return
	end
	held = on
	jump.pressed = on
	TweenService:Create(jump.fit, PRESS, { Scale = (jump.fitBase or 1) * (on and 0.95 or 1) }):Play()
	TweenService:Create(jump.button, PRESS, { BackgroundTransparency = on and 0.46 or 0.5 }):Play()
	local h = humanoid()
	if h then
		h.Jump = on
	end
end
jump.button.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
		holdInput = input
		setJump(true)
	end
end)
jump.button.InputEnded:Connect(function(input)
	if input == holdInput then
		holdInput = nil
		setJump(false)
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input == holdInput then
		holdInput = nil
		setJump(false)
	end
end)
RunService:BindToRenderStep("HorizonJumpButton", Enum.RenderPriority.Input.Value + 1, function()
	if held then
		local h = humanoid()
		if h then
			h.Jump = true
		end
	end
end)

local states = { Sprint = false, Crouch = false }
local toggles = { Sprint = sprint, Crouch = crouch }
local ATTR = { Sprint = "Sprinting", Crouch = "Crouching" }
local function setState(name, on)
	states[name] = on
	local t = toggles[name]
	TweenService:Create(t.stroke, TOGGLE, { Thickness = 1, Transparency = on and 0.3 or 0.75 }):Play()
	player:SetAttribute(ATTR[name], on)
end
for name, t in pairs(toggles) do
	t.button.Activated:Connect(function()
		local on = not states[name]
		if on then
			for other in pairs(toggles) do
				if other ~= name then
					setState(other, false)
				end
			end
		end
		setState(name, on)
	end)
end
local function resetToggles()
	setState("Sprint", false)
	setState("Crouch", false)
	holdInput = nil
	setJump(false)
end
player.CharacterAdded:Connect(resetToggles)
resetToggles()

bindTouchGui()
