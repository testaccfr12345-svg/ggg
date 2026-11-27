local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local FORCE_SHOW = true

local CREAM = Color3.fromRGB(237, 232, 220)
local DARK = Color3.fromRGB(16, 21, 19)
local FONT = Enum.Font.PatrickHand
local ROWS = {
	{ name = "Sprint", key = "Shift", icon = "rbxassetid://116064107344508", attr = "Sprinting" },
	{ name = "Crouch", key = "C", icon = "rbxassetid://116577259921226", attr = "Crouching" },
	{ name = "Jump", key = "Space", icon = "rbxassetid://90498940473124" },
}
local FADE = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local old = playerGui:FindFirstChild("HorizonKeyHints")
if old then
	old:Destroy()
end

local gui = Instance.new("ScreenGui")
gui.Name = "HorizonKeyHints"
gui.ResetOnSpawn = false
gui.DisplayOrder = 5
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local root = Instance.new("Frame")
root.Name = "Controls"
root.AnchorPoint = Vector2.new(1, 1)
root.Size = UDim2.fromOffset(148, 92)
root.BackgroundTransparency = 1
root.Parent = gui
local rootScale = Instance.new("UIScale")
rootScale.Parent = root
local list = Instance.new("UIListLayout")
list.FillDirection = Enum.FillDirection.Vertical
list.Padding = UDim.new(0, 7)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = root

local rows = {}
for i, r in ipairs(ROWS) do
	local row = Instance.new("Frame")
	row.Name = r.name
	row.Size = UDim2.fromOffset(148, 26)
	row.BackgroundTransparency = 1
	row.LayoutOrder = i
	row.Parent = root

	local icon = Instance.new("ImageLabel")
	icon.Name = "Icon"
	icon.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.Position = UDim2.fromOffset(11, 13)
	icon.Size = UDim2.fromOffset(19, 19)
	icon.BackgroundTransparency = 1
	icon.Image = r.icon
	icon.ImageColor3 = CREAM
	icon.ScaleType = Enum.ScaleType.Fit
	icon.Parent = row

	local label = Instance.new("TextLabel")
	label.Name = "Name"
	label.Position = UDim2.fromOffset(30, 0)
	label.Size = UDim2.fromOffset(58, 26)
	label.BackgroundTransparency = 1
	label.Font = FONT
	label.TextSize = 23
	label.TextColor3 = CREAM
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = r.name
	label.Parent = row

	local key = Instance.new("TextLabel")
	key.Name = "Key"
	key.Position = UDim2.fromOffset(96, 0)
	key.Size = UDim2.fromOffset(52, 26)
	key.BackgroundColor3 = DARK
	key.BackgroundTransparency = 0.5
	key.BorderSizePixel = 0
	key.Font = FONT
	key.TextSize = 20
	key.TextColor3 = CREAM
	key.Text = r.key
	key.Parent = row
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = key
	local stroke = Instance.new("UIStroke")
	stroke.Color = CREAM
	stroke.Thickness = 1
	stroke.Transparency = 0.82
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	pcall(function()
		stroke.BorderStrokePosition = Enum.BorderStrokePosition.Inner
	end)
	stroke.Parent = key

	local fade = Instance.new("NumberValue")
	fade.Value = 0.85
	local look = { bg = 0.5, ring = 0.82 }
	local function apply()
		local a = fade.Value
		icon.ImageTransparency = 1 - a
		label.TextTransparency = 1 - a
		key.TextTransparency = 1 - a
		key.BackgroundTransparency = 1 - (1 - look.bg) * a
		stroke.Transparency = 1 - (1 - look.ring) * a
	end
	fade.Changed:Connect(apply)
	apply()
	rows[r.name] = { def = r, fade = fade, look = look, stroke = stroke, apply = apply, tweens = {} }
end

local function setRow(row, opacity, on)
	for _, tw in ipairs(row.tweens) do
		tw:Cancel()
	end
	row.look.bg = on and 0.38 or 0.5
	row.look.ring = on and 0.3 or 0.82
	row.stroke.Thickness = on and 1.2 or 1
	local tw = TweenService:Create(row.fade, FADE, { Value = opacity })
	row.tweens = { tw }
	tw:Play()
	row.apply()
end

local function refresh()
	local active
	if player:GetAttribute("Sprinting") == true then
		active = "Sprint"
	elseif player:GetAttribute("Crouching") == true then
		active = "Crouch"
	end
	for name, row in pairs(rows) do
		local me = active == name
		setRow(row, me and 1 or (active and 0.5 or 0.85), me)
	end
end
player:GetAttributeChangedSignal("Sprinting"):Connect(refresh)
player:GetAttributeChangedSignal("Crouching"):Connect(refresh)

local function toggle(attr, other)
	local on = player:GetAttribute(attr) ~= true
	if on then
		player:SetAttribute(other, false)
	end
	player:SetAttribute(attr, on)
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed or not gui.Enabled then
		return
	end
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		toggle("Sprinting", "Crouching")
	elseif input.KeyCode == Enum.KeyCode.C then
		toggle("Crouching", "Sprinting")
	end
end)

local function resize()
	local vp = gui.AbsoluteSize
	if vp.X <= 0 or vp.Y <= 0 then
		return
	end
	local s = math.clamp(math.min(vp.X / 1280, vp.Y / 720), 0.75, 2.5)
	rootScale.Scale = s
	root.Position = UDim2.new(1, -28 * s, 1, -26 * s)
end
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(resize)

local function isPC()
	local ok, pref = pcall(function()
		return UserInputService.PreferredInput
	end)
	if ok and pref then
		return pref == Enum.PreferredInput.KeyboardAndMouse
	end
	return UserInputService.KeyboardEnabled and not UserInputService.TouchEnabled
end
local function updateEnabled()
	gui.Enabled = FORCE_SHOW or isPC()
end
pcall(function()
	UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(updateEnabled)
end)

player.CharacterAdded:Connect(function()
	player:SetAttribute("Sprinting", false)
	player:SetAttribute("Crouching", false)
end)

updateEnabled()
resize()
refresh()
