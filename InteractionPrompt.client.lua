local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")

local SHOW_TUNER = true

local PROMPT_SETTINGS = {
    PC = {
        X = 0,
        Y = 3,
        Scale = 117,
        BoxWidth = 29,
        BoxHeight = 29,
        HintTextSize = 25,
        ActionTextSize = 26,
        Gap = 3,
        BoxTransparency = 50,
        CornerRadius = 5,
        BoxEdgeBlur = 5,
        ShadowOpacity = 80,
        ShadowOffset = 2,
        ShadowBlur = 2,
        FadeInTime = 0.1,
        FadeOutTime = 0.1,
    },
    Mobile = {
        X = 0,
        Y = 3,
        Scale = 117,
        BoxHeight = 29,
        HintTextSize = 20,
        ActionTextSize = 26,
        Gap = 3,
        BoxTransparency = 50,
        CornerRadius = 5,
        BoxEdgeBlur = 5,
        ShadowOpacity = 80,
        ShadowOffset = 2,
        ShadowBlur = 2,
        FadeInTime = 0.1,
        FadeOutTime = 0.1,
    },
}


local IVORY = Color3.fromRGB(237, 232, 220)
local KEY_BACKGROUND = Color3.fromRGB(37, 30, 24)
local SHADOW = Color3.fromRGB(24, 19, 15)

local function createLabel(parent, name, color)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.BackgroundTransparency = 1
    label.Active = false
    label.Font = Enum.Font.GothamMedium
    label.TextColor3 = color
    label.TextTruncate = Enum.TextTruncate.AtEnd
    label.Text = ""
    label.Parent = parent
    return label
end

local function addTextShadow(label, name)
    local shadow = Instance.new("UIShadow")
    shadow.Name = name
    shadow.Mode = Enum.ApplyShadowMode.Text
    shadow.Color = SHADOW
    shadow.Parent = label
    return shadow
end

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local gui = Instance.new("ScreenGui")
gui.Name = "HorizonInteractionPrompt"
gui.ResetOnSpawn = false
gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
gui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.None
gui.DisplayOrder = 20
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local root = Instance.new("Frame")
root.Name = "SafeArea"
root.BackgroundTransparency = 1
root.Size = UDim2.fromScale(1, 1)
root.Parent = gui

local prompt = Instance.new("Frame")
prompt.Name = "Prompt"
prompt.AnchorPoint = Vector2.new(0.5, 1)
prompt.BackgroundTransparency = 1
prompt.Parent = root

local keycap = Instance.new("Frame")
keycap.Name = "Keycap"
keycap.AnchorPoint = Vector2.new(0.5, 0)
keycap.Position = UDim2.fromScale(0.5, 0)
keycap.BackgroundColor3 = KEY_BACKGROUND
keycap.BorderSizePixel = 0
keycap.Parent = prompt

local corner = Instance.new("UICorner")
corner.Parent = keycap

local keycapShadow = Instance.new("UIShadow")
keycapShadow.Name = "KeycapShadow"
keycapShadow.Color = KEY_BACKGROUND
keycapShadow.Offset = UDim2.fromOffset(0, 0)
keycapShadow.Spread = UDim2.fromOffset(0, 0)
keycapShadow.ShowBehindParent = false
keycapShadow.Transparency = 0.45
keycapShadow.Parent = keycap

local key = createLabel(keycap, "Key", IVORY)
key.Size = UDim2.fromScale(1, 1)
key.Text = "E"
key.Font = Enum.Font.PatrickHand

local tap = createLabel(keycap, "Tap", IVORY)
tap.Size = UDim2.fromScale(1, 1)
tap.Text = "TAP"
tap.Font = Enum.Font.PatrickHand
local tapShadow = addTextShadow(tap, "TapShadow")

local action = createLabel(prompt, "Action", IVORY)
action.Font = Enum.Font.PatrickHand
action.ZIndex = 2
action.Text = "CHOP PALM TREE"
local actionShadow = addTextShadow(action, "ActionShadow")

local isTouch = false
local fadeTween

local opacity = Instance.new("NumberValue")
opacity.Name = "PromptOpacity"
opacity.Value = 0
opacity.Parent = gui

local function applyOpacity()
    local settings = PROMPT_SETTINGS[isTouch and "Mobile" or "PC"]
    local alpha = opacity.Value
    key.TextTransparency = 1 - alpha
    tap.TextTransparency = 1 - alpha
    action.TextTransparency = 1 - alpha
    keycap.BackgroundTransparency = 1 - (1 - settings.BoxTransparency / 100) * alpha
    local shadowTransparency = 1 - settings.ShadowOpacity / 100 * alpha
    tapShadow.Transparency = shadowTransparency
    actionShadow.Transparency = shadowTransparency
    keycapShadow.Transparency = 1 - 0.55 * alpha
end

local function fadePrompt(visible)
    if fadeTween then
        fadeTween:Cancel()
        fadeTween = nil
    end

    local target = visible and 1 or 0
    local distance = math.abs(target - opacity.Value)
    if distance < 0.001 then
        opacity.Value = target
        prompt.Visible = visible
        return
    end

    local settings = PROMPT_SETTINGS[isTouch and "Mobile" or "PC"]
    local duration = (visible and settings.FadeInTime or settings.FadeOutTime) * distance
    local direction = visible and Enum.EasingDirection.Out or Enum.EasingDirection.In
    local tween = TweenService:Create(opacity, TweenInfo.new(duration, Enum.EasingStyle.Sine, direction), { Value = target })
    fadeTween = tween
    prompt.Visible = true

    tween.Completed:Once(function(playbackState)
        if fadeTween == tween and playbackState == Enum.PlaybackState.Completed then
            fadeTween = nil
            prompt.Visible = visible
        end
    end)
    tween:Play()
end

local function preferredMode()
    return UserInputService.PreferredInput == Enum.PreferredInput.Touch and "Mobile" or "PC"
end

local function layout()
    local size = root.AbsoluteSize
    if size.X <= 24 or size.Y <= 24 then
        return
    end

    local settings = PROMPT_SETTINGS[isTouch and "Mobile" or "PC"]
    local deviceScale = math.clamp(math.min(size.X, size.Y) / 610, 0.8, 1.35)
    local boxWidth = settings.BoxWidth or settings.BoxHeight
    local actionLineHeight = math.max(25, settings.ActionTextSize + 5)
    local totalHeight = settings.BoxHeight + settings.Gap + actionLineHeight
    local scale = math.min(deviceScale * settings.Scale / 100, (size.X - 24) / boxWidth, (size.Y - 8) / totalHeight)

    local hintWidth = math.round(boxWidth * scale)
    local hintHeight = math.round(settings.BoxHeight * scale)
    local actionHeight = math.round(actionLineHeight * scale)
    local actionTop = hintHeight + math.round(settings.Gap * scale)
    local promptHeight = actionTop + actionHeight

    keycap.Size = UDim2.fromOffset(hintWidth, hintHeight)
    corner.CornerRadius = UDim.new(0, math.round(settings.CornerRadius * scale))
    keycapShadow.Enabled = settings.BoxEdgeBlur > 0 and settings.BoxTransparency < 100
    keycapShadow.BlurRadius = UDim.new(0, settings.BoxEdgeBlur)

    local hintTextSize = math.max(1, math.round(settings.HintTextSize * scale))
    key.TextSize = hintTextSize
    tap.TextSize = hintTextSize
    action.Position = UDim2.fromOffset(0, actionTop)
    action.Size = UDim2.new(1, 0, 0, actionHeight)
    action.TextSize = math.max(1, math.round(settings.ActionTextSize * scale))

    local shadowOffset = UDim2.fromOffset(0, settings.ShadowOffset)
    local shadowBlur = UDim.new(0, settings.ShadowBlur)
    tapShadow.Offset = shadowOffset
    tapShadow.BlurRadius = shadowBlur
    actionShadow.Offset = shadowOffset
    actionShadow.BlurRadius = shadowBlur

    local textBounds = TextService:GetTextSize(action.Text, action.TextSize, action.Font, Vector2.new(10000, 10000))
    local promptWidth = math.min(size.X - 24, math.max(hintWidth, math.ceil(textBounds.X) + 12))
    local xLimit = math.floor((size.X - promptWidth - 24) / 2)
    local x = math.clamp(math.round(settings.X * deviceScale), -xLimit, xLimit)
    local bottom = size.Y * 0.81 + settings.Y * deviceScale
    bottom = math.clamp(bottom, math.min(promptHeight, size.Y), size.Y)

    prompt.Size = UDim2.fromOffset(promptWidth, promptHeight)
    prompt.Position = UDim2.new(0.5, x, 0, math.round(bottom))
    applyOpacity()
end

local function updateInput()
    isTouch = preferredMode() == "Mobile"
    key.Visible = not isTouch
    tap.Visible = isTouch
    layout()
end

root:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(updateInput)

opacity:GetPropertyChangedSignal("Value"):Connect(applyOpacity)
applyOpacity()
gui.Parent = playerGui
updateInput()
fadePrompt(true)

if SHOW_TUNER then
	local FIELDS = {
		{ "Scale", 5 }, { "X", 2 }, { "Y", 2 }, { "BoxWidth", 1 }, { "BoxHeight", 1 }, { "HintTextSize", 1 },
		{ "ActionTextSize", 1 }, { "Gap", 1 }, { "CornerRadius", 1 }, { "BoxTransparency", 5 }, { "BoxEdgeBlur", 1 },
		{ "ShadowOpacity", 5 }, { "ShadowOffset", 1 }, { "ShadowBlur", 1 },
	}
	local tg = Instance.new("ScreenGui")
	tg.Name = "PromptTuner"
	tg.ResetOnSpawn = false
	tg.DisplayOrder = 1000
	tg.Parent = playerGui
	local panel = Instance.new("Frame")
	panel.AnchorPoint = Vector2.new(1, 0)
	panel.Position = UDim2.new(1, -10, 0, 10)
	panel.Size = UDim2.fromOffset(230, 34 + #FIELDS * 24 + 34)
	panel.BackgroundColor3 = Color3.fromRGB(16, 21, 19)
	panel.BackgroundTransparency = 0.1
	panel.BorderSizePixel = 0
	panel.Active = true
	panel.Parent = tg
	local pc = Instance.new("UICorner")
	pc.CornerRadius = UDim.new(0, 8)
	pc.Parent = panel
	local function lbl(parent, text, x, y, w, h)
		local l = Instance.new("TextLabel")
		l.BackgroundTransparency = 1
		l.Position = UDim2.fromOffset(x, y)
		l.Size = UDim2.fromOffset(w, h)
		l.Font = Enum.Font.GothamMedium
		l.TextSize = 12
		l.TextColor3 = IVORY
		l.TextXAlignment = Enum.TextXAlignment.Left
		l.Text = text
		l.Parent = parent
		return l
	end
	local function btn(parent, text, x, y, w, h)
		local b = Instance.new("TextButton")
		b.Position = UDim2.fromOffset(x, y)
		b.Size = UDim2.fromOffset(w, h)
		b.BackgroundColor3 = Color3.fromRGB(45, 50, 48)
		b.BorderSizePixel = 0
		b.Font = Enum.Font.GothamBold
		b.TextSize = 14
		b.TextColor3 = IVORY
		b.Text = text
		b.AutoButtonColor = true
		b.Parent = parent
		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 5)
		c.Parent = b
		return b
	end
	local title = lbl(panel, "", 10, 6, 150, 22)
	title.TextColor3 = Color3.fromRGB(233, 185, 73)
	local hide = btn(panel, "-", 196, 6, 24, 22)
	local values = {}
	local function current()
		return PROMPT_SETTINGS[isTouch and "Mobile" or "PC"]
	end
	local function refresh()
		local st = current()
		title.Text = "Prompt Tuner (" .. (isTouch and "Mobile" or "PC") .. ")"
		for _, f in ipairs(FIELDS) do
			values[f[1]].Text = tostring(st[f[1]] or st.BoxHeight)
		end
	end
	for i, f in ipairs(FIELDS) do
		local y = 34 + (i - 1) * 24
		lbl(panel, f[1], 10, y, 110, 22)
		local v = lbl(panel, "", 122, y, 40, 22)
		v.TextXAlignment = Enum.TextXAlignment.Center
		values[f[1]] = v
		btn(panel, "-", 166, y, 24, 22).Activated:Connect(function()
			local st = current()
			st[f[1]] = (st[f[1]] or st.BoxHeight) - f[2]
			layout()
			refresh()
		end)
		btn(panel, "+", 196, y, 24, 22).Activated:Connect(function()
			local st = current()
			st[f[1]] = (st[f[1]] or st.BoxHeight) + f[2]
			layout()
			refresh()
		end)
	end
	local copy = btn(panel, "Copy settings", 10, 34 + #FIELDS * 24 + 4, 210, 24)
	copy.BackgroundColor3 = Color3.fromRGB(233, 185, 73)
	copy.TextColor3 = Color3.fromRGB(27, 26, 20)
	local box = Instance.new("TextBox")
	box.AnchorPoint = Vector2.new(0.5, 0.5)
	box.Position = UDim2.fromScale(0.5, 0.5)
	box.Size = UDim2.new(0.8, 0, 0, 120)
	box.BackgroundColor3 = Color3.fromRGB(16, 21, 19)
	box.BorderSizePixel = 0
	box.TextColor3 = IVORY
	box.Font = Enum.Font.Code
	box.TextSize = 13
	box.TextWrapped = true
	box.ClearTextOnFocus = false
	box.TextEditable = false
	box.Visible = false
	box.Parent = tg
	copy.Activated:Connect(function()
		local parts = {}
		for _, mode in ipairs({ "PC", "Mobile" }) do
			local st = PROMPT_SETTINGS[mode]
			local kv = {}
			for _, f in ipairs(FIELDS) do
				if st[f[1]] ~= nil then
					table.insert(kv, f[1] .. "=" .. tostring(st[f[1]]))
				end
			end
			table.insert(parts, mode .. ": " .. table.concat(kv, ", "))
		end
		box.Text = table.concat(parts, "\n")
		box.Visible = not box.Visible
	end)
	local open = true
	hide.Activated:Connect(function()
		open = not open
		hide.Text = open and "-" or "+"
		panel.Size = open and UDim2.fromOffset(230, 34 + #FIELDS * 24 + 34) or UDim2.fromOffset(230, 34)
		for _, c in ipairs(panel:GetChildren()) do
			if c:IsA("GuiObject") and c ~= title and c ~= hide then
				c.Visible = open
			end
		end
	end)
	UserInputService:GetPropertyChangedSignal("PreferredInput"):Connect(refresh)
	refresh()
end
