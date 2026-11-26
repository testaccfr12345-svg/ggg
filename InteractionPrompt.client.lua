local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local TweenService = game:GetService("TweenService")

local PROMPT_SETTINGS = {
    PC = {
        X = 0,
        Y = 3,
        Scale = 117,
        BoxWidth = 29,
        BoxHeight = 29,
        HintTextSize = 19,
        ActionTextSize = 28,
        Gap = 3,
        KeyY = 3,
        BoxTransparency = 50,
        CornerRadius = 5,
        BoxEdgeBlur = 5,
        ShadowOpacity = 55,
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
        HintTextSize = 19,
        ActionTextSize = 28,
        Gap = 3,
        KeyY = 3,
        BoxTransparency = 50,
        CornerRadius = 5,
        BoxEdgeBlur = 5,
        ShadowOpacity = 55,
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

local haze = Instance.new("ImageLabel")
haze.Name = "Haze"
haze.AnchorPoint = Vector2.new(0.5, 0.5)
haze.Position = UDim2.fromScale(0.5, 0.5)
haze.Size = UDim2.new(1, 60, 1, 46)
haze.BackgroundTransparency = 1
haze.Image = "rbxassetid://130881451468251"
haze.ImageColor3 = Color3.new(0, 0, 0)
haze.ImageTransparency = 1
haze.ZIndex = 0
haze.Parent = prompt

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
    haze.ImageTransparency = 1 - 0.18 * alpha
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
    keycap.Position = UDim2.new(0.5, 0, 0, math.round(settings.KeyY * scale))
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
