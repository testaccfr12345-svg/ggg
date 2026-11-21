local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local ContentProvider = game:GetService("ContentProvider")

local CFG = {
	Sounds = {
		click = { 117258347937945, 0.7 },
		error = { 83340678230226, 0.7 },
		death = { 98352871212739, 1 },
		wake = { 107350614991623, 0.7 },
	},
	Icons = {
		respawn = "rbxassetid://84195781992190",
		spectate = "rbxassetid://118090942879672",
		lobby = "rbxassetid://89417626626034",
		back = "rbxassetid://111560708284255",
		chevron = "rbxassetid://137935344939357",
		lungOutline = "rbxassetid://91220162326369",
		lungFill = "rbxassetid://117299378249299",
		joinBg = "rbxassetid://140078431096703",
		lobbyBg = "rbxassetid://109346762822915",
	},
	PanelAlpha = 0.68,
}

local ACCENT = Color3.fromHex("E9B949")
local CREAM = Color3.fromHex("EDE8DC")
local DARK = Color3.fromHex("1B1A14")
local CORAL = Color3.fromHex("F4A47C")
local PANEL = Color3.fromRGB(16, 21, 19)
local PANEL_T = 1 - CFG.PanelAlpha
local WHITE, BLACK = Color3.new(1, 1, 1), Color3.new(0, 0, 0)
local FONT = Enum.Font.PatrickHand
local V2 = Vector2.new
local QUINT, QUAD, OUT, IN = Enum.EasingStyle.Quint, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, Enum.EasingDirection.In

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
for _, n in ipairs({ "HorizonDeathBack", "HorizonDeath", "HorizonSpectateHUD" }) do

	local old = playerGui:FindFirstChild(n)
	if old then
		old:Destroy()
	end
end

local snd = {}
local preload = {}
for n, d in pairs(CFG.Sounds) do
	local s = Instance.new("Sound")
	s.Name = "HorizonDeath_" .. n
	s.SoundId = d[1] ~= 0 and "rbxassetid://" .. d[1] or ""
	s.Volume = d[2]
	s.Parent = SoundService
	snd[n] = s
	table.insert(preload, s)
end
for _, id in pairs(CFG.Icons) do
	if id ~= "" then
		table.insert(preload, id)
	end
end
task.spawn(pcall, ContentProvider.PreloadAsync, ContentProvider, preload)
local function play(n)
	local s = snd[n]
	if s and s.SoundId ~= "" then
		s.TimePosition = 0
		s:Play()
	end
end
local tapped = false
local function onTap(btn, fn)
	btn.Activated:Connect(function()
		tapped = false
		fn()
		if not tapped then
			play("click")
		end
	end)
end
local function sfx(n)
	tapped = true
	play(n)
end

local FADE = { Frame = { "BackgroundTransparency" }, TextLabel = { "BackgroundTransparency", "TextTransparency" }, TextButton = { "BackgroundTransparency", "TextTransparency" }, ImageLabel = { "BackgroundTransparency", "ImageTransparency" }, UIStroke = { "Transparency" } }
local building
local function newGroup()
	local g = { items = {}, v = 0 }
	g.value = Instance.new("NumberValue")
	g.value.Changed:Connect(function(x)
		g.v = x
		for inst, base in pairs(g.items) do
			for p, b in pairs(base) do
				inst[p] = 1 - (1 - b) * x
			end
		end
	end)
	return g
end
local function new(class, props)
	local inst = Instance.new(class)
	if inst:IsA("GuiObject") then
		inst.BorderSizePixel = 0
	end
	local parent = props.Parent
	props.Parent = nil
	for k, v in pairs(props) do
		inst[k] = v
	end
	inst.Parent = parent
	local fp = FADE[class]
	if fp and building then
		local b = {}
		for _, p in ipairs(fp) do
			b[p] = inst[p]
			inst[p] = 1 - (1 - inst[p]) * building.v
		end
		building.items[inst] = b
	end
	return inst
end
local function fadeTo(g, to, t, style, dir)
	if g.tw then
		g.tw:Cancel()
	end
	if t <= 0 then
		g.value.Value = to
		return
	end
	g.tw = TweenService:Create(g.value, TweenInfo.new(t, style or QUAD, dir or OUT), { Value = to })
	g.tw:Play()
end
local function frame(parent, props)
	props.Parent = parent
	if props.BackgroundTransparency == nil then
		props.BackgroundTransparency = 1
	end
	return new("Frame", props)
end
local function text(parent, str, size, props)
	props = props or {}
	props.Parent = parent
	props.Text = str
	props.TextSize = size
	props.Font = FONT
	props.BackgroundTransparency = 1
	if props.TextColor3 == nil then
		props.TextColor3 = CREAM
	end
	if props.TextXAlignment == nil then
		props.TextXAlignment = Enum.TextXAlignment.Left
	end
	return new("TextLabel", props)
end
local function round(inst, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = typeof(r) == "UDim" and r or UDim.new(0, r)
	c.Parent = inst
end
local function shadow(l, t)
	new("UIStroke", { Parent = l, Color = BLACK, Thickness = 1.5, Transparency = t or 0.6 })
	return l
end
local function textW(str, size)
	return TextService:GetTextSize(str, size, FONT, V2(4000, 4000)).X
end
local function icon(parent, id, size, color, props)
	props.Parent = parent
	props.Size = UDim2.fromOffset(size, size)
	props.BackgroundTransparency = 1
	props.Image = id
	props.ImageColor3 = color
	props.ScaleType = Enum.ScaleType.Fit
	return new("ImageLabel", props)
end

local backGui = Instance.new("ScreenGui")
backGui.Name = "HorizonDeathBack"
backGui.IgnoreGuiInset = true
backGui.ResetOnSpawn = false
backGui.DisplayOrder = 60
backGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
	backGui.ScreenInsets = Enum.ScreenInsets.None
end)
backGui.Parent = playerGui
local lobbyBg = new("ImageLabel", { Parent = backGui, Name = "LobbyBackground", Image = CFG.Icons.lobbyBg, ScaleType = Enum.ScaleType.Crop, Size = UDim2.fromScale(1, 1), BackgroundTransparency = 0, BackgroundColor3 = BLACK, Visible = false })
local lobbyShade = new("Frame", { Parent = lobbyBg, Name = "Shade", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 0.65, BackgroundColor3 = BLACK })
local shade = new("Frame", { Parent = backGui, Name = "Shade", Size = UDim2.fromScale(1, 1), BackgroundColor3 = BLACK, BackgroundTransparency = 1, Visible = false })
local lids = new("Frame", { Parent = backGui, Name = "Eyelids", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ClipsDescendants = true, Visible = false })
local lidParts = {}
for i, side in ipairs({ -1, 1 }) do
	local holder = new("Frame", { Parent = lids, Name = side < 0 and "Top" or "Bottom", AnchorPoint = V2(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1 })
	local rings = {}
	for k, q in ipairs({ { 0, 0 }, { 14, 0.45 }, { 30, 0.72 }, { 48, 0.88 } }) do
		local c = new("Frame", { Parent = holder, AnchorPoint = V2(0.5, 0.5), BackgroundColor3 = BLACK, BackgroundTransparency = q[2], ZIndex = 5 - k })
		round(c, UDim.new(0.5, 0))
		rings[k] = { f = c, grow = q[1] }
	end
	lidParts[i] = { holder = holder, rings = rings, side = side }
end

local gui = Instance.new("ScreenGui")
gui.Name = "HorizonDeath"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.DisplayOrder = 61
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
pcall(function()
	gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
end)
pcall(function()
	gui.ClipToDeviceSafeArea = false
end)
gui.Parent = playerGui
local cv = frame(gui, { Name = "Canvas", AnchorPoint = V2(0.5, 0.5), Size = UDim2.fromOffset(1280, 720) })
local cvScale = Instance.new("UIScale")
cvScale.Parent = cv
local function fit()
	local a = gui.AbsoluteSize
	if a.X < 10 or a.Y < 10 then
		a = workspace.CurrentCamera.ViewportSize
	end
	local s = math.max(math.min(a.Y / 720, a.X / 1280), 0.2)
	local top = math.max(0, math.min(game:GetService("GuiService"):GetGuiInset().Y + 6 - 84 * s, a.Y - 690 * s))
	cvScale.Scale = s
	cv.Position = UDim2.fromOffset(a.X / 2, top + 360 * s)
	cv.Size = UDim2.fromOffset(a.X / s, 720)
end
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
fit()
local function fromBottom(x, y)
	return UDim2.new(0, x, 1, y - 720)
end

local gDied = newGroup()
building = gDied
local diedRoot = frame(cv, { Name = "YouDied", Size = UDim2.fromScale(1, 1), Visible = false })
local diedW = math.ceil(textW("YOU DIED", 100)) + 24
building = nil
local diedCG = new("CanvasGroup", { Parent = diedRoot, Name = "Text", AnchorPoint = V2(0.5, 0.5), Position = UDim2.new(0.5, 0, 0, 345), Size = UDim2.fromOffset(diedW, 120), BackgroundTransparency = 1, GroupTransparency = 1 })
local diedL = text(diedCG, "YOU DIED", 100, { AnchorPoint = V2(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(diedW - 12, 110), TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = WHITE })
new("UIStroke", { Parent = diedL, Color = WHITE, Thickness = 2, Transparency = 0, LineJoinMode = Enum.LineJoinMode.Round })
local diedScale = Instance.new("UIScale")
local DIED_SCALE = 640 / diedW
diedScale.Scale = DIED_SCALE
diedScale.Parent = diedCG
local diedTw, diedGrow

local gMenu = newGroup()
building = gMenu
local menu = frame(cv, { Name = "Menu", Size = UDim2.fromScale(1, 1), Visible = false })
local title = text(menu, "You Died", 100, { Name = "Title", Position = UDim2.fromOffset(40, 66), Size = UDim2.fromOffset(900, 96), TextColor3 = CORAL })
local titleScale = Instance.new("UIScale")
titleScale.Scale = 1.22
titleScale.Parent = title
shadow(title, 0.75)
local cause = shadow(text(menu, "", 38, { Name = "Cause", Position = UDim2.fromOffset(40, 181.4), Size = UDim2.fromOffset(900, 38), TextTransparency = 0.1 }), 0.55)
local tip = frame(menu, { Name = "Tip", AnchorPoint = V2(0, 1), Position = fromBottom(40, 654), Size = UDim2.fromOffset(580, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = PANEL_T, BackgroundColor3 = PANEL })
round(tip, 16)
local tp = Instance.new("UIPadding")
tp.PaddingLeft, tp.PaddingRight, tp.PaddingTop, tp.PaddingBottom = UDim.new(0, 24), UDim.new(0, 24), UDim.new(0, 20), UDim.new(0, 20)
tp.Parent = tip
local tl = Instance.new("UIListLayout")
tl.SortOrder = Enum.SortOrder.LayoutOrder
tl.Padding = UDim.new(0, 6)
tl.Parent = tip
local tipHead = frame(tip, { Name = "Head", Size = UDim2.new(1, 0, 0, 34), LayoutOrder = 1 })
round(frame(tipHead, { AnchorPoint = V2(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(12, 12), BackgroundTransparency = 0, BackgroundColor3 = ACCENT }), 3)
text(tipHead, "Tip", 34, { Position = UDim2.fromOffset(22, 0), Size = UDim2.fromOffset(200, 34), TextColor3 = ACCENT })
local tipText = text(tip, "", 36, { Name = "Text", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true, LineHeight = 0.886, LayoutOrder = 2 })

local function menuButton(name, label, ico, i, main)
	local b = new("TextButton", { Parent = menu, Name = name, Text = "", AutoButtonColor = false, AnchorPoint = V2(1, 0), Position = UDim2.new(1, -35, 0, 466 + (i - 1) * 66), Size = UDim2.fromOffset(340, 56), BackgroundColor3 = main and ACCENT or PANEL, BackgroundTransparency = main and 0 or PANEL_T })
	round(b, 12)
	new("UIStroke", { Parent = b, Color = main and ACCENT or CREAM, Thickness = 1, Transparency = main and 0 or 0.86, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
	icon(b, ico, 32, main and DARK or CREAM, { AnchorPoint = V2(0.5, 0.5), Position = UDim2.fromOffset(34, 28) })
	local l = text(b, label, 32, { Position = UDim2.fromOffset(59, 12), Size = UDim2.new(1, -79, 0, 32), TextColor3 = main and DARK or CREAM })
	return b, l
end
local respawnB, respawnL = menuButton("RespawnButton", "Respawn", CFG.Icons.respawn, 1, true)
local spectateB = menuButton("SpectateButton", "Spectate", CFG.Icons.spectate, 2, false)
local lobbyB = menuButton("LobbyButton", "Return to lobby", CFG.Icons.lobby, 3, false)

local gSpec = newGroup()
building = gSpec
local spec = frame(cv, { Name = "Spectate", Size = UDim2.fromScale(1, 1), Visible = false })
local specW = 24 + math.ceil(textW("SPECTATING", 30))
local specTag = frame(spec, { Name = "Label", AnchorPoint = V2(0.5, 0), Position = UDim2.new(0.5, 0, 0, 30), Size = UDim2.fromOffset(specW, 30) })
round(frame(specTag, { Position = UDim2.fromOffset(0, 9), Size = UDim2.fromOffset(12, 12), BackgroundTransparency = 0, BackgroundColor3 = ACCENT }), 2)
shadow(text(specTag, "SPECTATING", 30, { Position = UDim2.fromOffset(24, 0), Size = UDim2.fromOffset(specW, 30), TextTransparency = 0.1 }))
local gWho = newGroup()
building = gWho
local whoRow = frame(spec, { Name = "Player", AnchorPoint = V2(0.5, 0), Position = UDim2.new(0.5, 0, 1, 612 - 720), Size = UDim2.fromOffset(400, 44) })
local whoName = shadow(text(whoRow, "", 49, { AnchorPoint = V2(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(600, 49), TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = WHITE }))
building = gSpec
local prevB = new("TextButton", { Parent = spec, Name = "Previous", Text = "", AutoButtonColor = false, AnchorPoint = V2(0.5, 0), Size = UDim2.fromOffset(44, 44), BackgroundTransparency = 1 })
icon(prevB, CFG.Icons.chevron, 26, CREAM, { AnchorPoint = V2(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Rotation = 180 })
local nextB = new("TextButton", { Parent = spec, Name = "Next", Text = "", AutoButtonColor = false, AnchorPoint = V2(0.5, 0), Size = UDim2.fromOffset(44, 44), BackgroundTransparency = 1 })
icon(nextB, CFG.Icons.chevron, 26, CREAM, { AnchorPoint = V2(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
local backW = 12 + 17 + 6 + math.ceil(textW("Back", 27)) + 18
local specBack = new("TextButton", { Parent = spec, Name = "BackButton", Text = "", AutoButtonColor = false, AnchorPoint = V2(0.5, 0), Position = UDim2.new(0.5, 0, 1, 664 - 720), Size = UDim2.fromOffset(backW, 42), BackgroundColor3 = PANEL, BackgroundTransparency = PANEL_T })
round(specBack, 10)
new("UIStroke", { Parent = specBack, Color = CREAM, Thickness = 1, Transparency = 0.86, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
icon(specBack, CFG.Icons.back, 17, CREAM, { AnchorPoint = V2(0, 0.5), Position = UDim2.new(0, 12, 0.5, 0) })
text(specBack, "Back", 27, { Position = UDim2.fromOffset(35, 0), Size = UDim2.new(1, -35, 1, 0) })

local gNote = newGroup()
building = gNote
local note = shadow(text(cv, "", 43, { Name = "Notification", AnchorPoint = V2(0.5, 0), Position = UDim2.new(0.5, 0, 0, 26), Size = UDim2.fromOffset(1000, 47), TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = WHITE, Visible = false }), 0.4)
building = nil

local hudGui = Instance.new("ScreenGui")
hudGui.Name = "HorizonSpectateHUD"
hudGui.ResetOnSpawn = false
hudGui.DisplayOrder = 61
hudGui.Enabled = false
pcall(function()
	hudGui.ScreenInsets = Enum.ScreenInsets.CoreUISafeInsets
end)
hudGui.Parent = playerGui
local ASSETS = {
	Health = { Id = "83496106777704", Canvas = 1024, X = 160, Y = 160, Width = 704, Height = 704 },
	Hunger = { Id = "92015841820092", Canvas = 720, X = 250, Y = 126, Width = 290, Height = 452 },
	Thirst = { Id = "107037349047540", Canvas = 720, X = 168, Y = 146, Width = 388, Height = 428 },
}
local TUNE = {
	Health = { Height = 89, IconHeight = 52, IconWidth = 52, IconX = 58, IconY = 44.5, TextHeight = 89, TextSize = 52, TextWidth = 180, TextX = 112, TextY = -0.865801, Width = 826.839831, X = 0, Y = 0 },
	Hunger = { Height = 89, IconHeight = 54, IconWidth = 35, IconX = 58, IconY = 44.5, TextHeight = 89, TextSize = 52, TextWidth = 180, TextX = 112, TextY = -1.298701, Width = 403.419916, X = 0, Y = 108 },
	Thirst = { Height = 89, IconHeight = 54, IconWidth = 49, IconX = 58, IconY = 44.5, TextHeight = 89, TextSize = 52, TextWidth = 180, TextX = 112, TextY = -1.731602, Width = 403.419916, X = 423.419916, Y = 108 },
}
local HUD_TEXT = Color3.fromRGB(241, 237, 230)
local hud = Instance.new("Frame")
hud.Name = "SurvivalStats"
hud.AnchorPoint = V2(0, 1)
hud.Size = UDim2.fromOffset(1000, 197)
hud.BackgroundTransparency = 1
hud.Parent = hudGui
local hudScale = Instance.new("UIScale")
hudScale.Parent = hud
local function placeImage(image, asset, cx, cy, w, h, pw, ph)
	local fx, fy = w / asset.Width, h / asset.Height
	image.Image = "rbxassetid://" .. asset.Id
	image.Size = UDim2.fromScale(asset.Canvas * fx / pw, asset.Canvas * fy / ph)
	image.Position = UDim2.fromScale((cx - (asset.X + asset.Width / 2) * fx) / pw, (cy - (asset.Y + asset.Height / 2) * fy) / ph)
end
local bars = {}
for name, col in pairs({ Health = Color3.fromRGB(174, 87, 80), Hunger = Color3.fromRGB(133, 157, 99), Thirst = Color3.fromRGB(104, 150, 174) }) do
	local t = TUNE[name]
	local bar = Instance.new("Frame")
	bar.Name = name
	bar.Position = UDim2.fromScale(t.X / 1000, t.Y / 197)
	bar.Size = UDim2.fromScale(t.Width / 1000, t.Height / 197)
	bar.BackgroundColor3 = Color3.fromRGB(52, 53, 55)
	bar.BackgroundTransparency = 0.5
	bar.BorderSizePixel = 0
	bar.Parent = hud
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = col
	fill.BorderSizePixel = 0
	fill.ZIndex = 2
	fill.Parent = bar
	local ic = Instance.new("ImageLabel")
	ic.Name = "Icon"
	ic.BackgroundTransparency = 1
	ic.ImageColor3 = name == "Health" and Color3.fromRGB(248, 244, 239) or HUD_TEXT
	ic.ZIndex = 3
	ic.Parent = bar
	placeImage(ic, ASSETS[name], t.IconX, t.IconY, t.IconWidth, t.IconHeight, t.Width, t.Height)
	local val = Instance.new("TextLabel")
	val.Name = "Value"
	val.BackgroundTransparency = 1
	val.Position = UDim2.fromScale(t.TextX / t.Width, t.TextY / t.Height)
	val.Size = UDim2.fromScale(t.TextWidth / t.Width, t.TextHeight / t.Height)
	val.Font = Enum.Font.GothamBold
	val.TextColor3 = HUD_TEXT
	val.TextSize = t.TextSize
	val.TextXAlignment = Enum.TextXAlignment.Left
	val.ZIndex = 3
	val.Parent = bar
	bars[name] = { bar = bar, fill = fill, val = val }
end
local lung = Instance.new("Frame")
lung.Name = "Stamina"
lung.Position = UDim2.fromScale(731 / TUNE.Health.Width, 0.5 / 89)
lung.Size = UDim2.fromScale(88 / TUNE.Health.Width, 88 / 89)
lung.BackgroundTransparency = 1
lung.ZIndex = 4
lung.Parent = bars.Health.bar
local LUNG = Color3.fromHex("FCE6C6")
local lungOutline = Instance.new("ImageLabel")
lungOutline.Size = UDim2.fromScale(1, 1)
lungOutline.BackgroundTransparency = 1
lungOutline.Image = CFG.Icons.lungOutline
lungOutline.ImageColor3 = LUNG
lungOutline.ScaleType = Enum.ScaleType.Fit
lungOutline.ZIndex = 5
lungOutline.Parent = lung
local lungClip = Instance.new("Frame")
lungClip.BackgroundTransparency = 1
lungClip.ClipsDescendants = true
lungClip.ZIndex = 4
lungClip.Parent = lung
local lungFill = Instance.new("ImageLabel")
lungFill.BackgroundTransparency = 1
lungFill.Image = CFG.Icons.lungFill
lungFill.ImageColor3 = LUNG
lungFill.ScaleType = Enum.ScaleType.Fit
lungFill.ZIndex = 4
lungFill.Parent = lungClip
local function setLung(r)
	local top = 346 / 420 - (346 - 83) / 420 * math.clamp(r, 0, 1)
	lungClip.Position = UDim2.fromScale(0, top)
	lungClip.Size = UDim2.fromScale(1, 1 - top)
	lungFill.Position = UDim2.fromScale(0, -top / (1 - top))
	lungFill.Size = UDim2.fromScale(1, 1 / (1 - top))
end
local function hudResize()
	local vp = hudGui.AbsoluteSize
	if vp.X <= 0 or vp.Y <= 0 then
		return
	end
	local left = math.round(math.clamp(vp.X * 52 / 1536, 12, 52))
	local bottom = math.round(math.clamp(vp.Y * 66 / 864, 16, 66))
	local target = 350 / 1000 * math.clamp(math.min(vp.X / 1536, vp.Y / 864), 0.66, 1.35)
	if UserInputService.TouchEnabled then
		bottom = math.round(math.clamp(vp.Y * 0.31, 76, 156))
	end
	local base = math.min(target, math.max(1, vp.X - left - 12) / 1000, math.max(1, vp.Y - bottom - 12) / 197)
	hudScale.Scale = math.min(base * 0.95, (vp.X - 24) / TUNE.Health.Width, (vp.Y - 24) / 197)
	hud.Position = UDim2.fromScale((left - 16.3) / vp.X, (vp.Y - bottom + 102) / vp.Y)
end
hudGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(hudResize)
hudResize()
local hudTweens = {}
local function setBar(name, value, frac, instant)
	local b = bars[name]
	b.val.Text = tostring(math.round(value))
	if hudTweens[name] then
		hudTweens[name]:Cancel()
	end
	local goal = UDim2.fromScale(math.clamp(frac, 0, 1), 1)
	if instant then
		b.fill.Size = goal
	else
		hudTweens[name] = TweenService:Create(b.fill, TweenInfo.new(0.35, QUAD, OUT), { Size = goal })
		hudTweens[name]:Play()
	end
end

local state = { dead = false, screen = "none", seq = 0, watching = nil, list = {}, busy = false }
local lightFx = {}
local function hideOwnHud(hide)
	for _, n in ipairs({ "HorizonSurvivalHUD", "StaminaLungUI" }) do
		local g = playerGui:FindFirstChild(n)
		if g and g:IsA("ScreenGui") then
			g.Enabled = not hide
		end
	end
end
local function setShade(t, time, dir)
	shade.Visible = true
	if time and time > 0 then
		TweenService:Create(shade, TweenInfo.new(time, QUAD, dir or OUT), { BackgroundTransparency = t }):Play()
	else
		shade.BackgroundTransparency = t
	end
end
local rest = {}
local function showGroup(g, root, on, slide)
	rest[root] = rest[root] or root.Position
	local r = rest[root]
	local function at(dy)
		return UDim2.new(r.X.Scale, r.X.Offset, r.Y.Scale, r.Y.Offset + dy)
	end
	if on then
		root.Visible = true
		root.Position = at(slide and -28 or 0)
		fadeTo(g, 0, 0)
		fadeTo(g, 1, 0.4, QUINT, OUT)
		TweenService:Create(root, TweenInfo.new(0.4, QUINT, OUT), { Position = r }):Play()
	else
		fadeTo(g, 0, 0.16, QUAD, IN)
		TweenService:Create(root, TweenInfo.new(0.16, QUAD, IN), { Position = at(-14) }):Play()
		local my = state.seq
		task.delay(0.17, function()
			if g.v <= 0.01 or my ~= state.seq then
				root.Visible = false
			end
		end)
	end
end
local noteSeq = 0
local function notify(str, bad)
	noteSeq += 1
	local my = noteSeq
	note.Text = str
	note.TextColor3 = bad and CORAL or WHITE
	note.Visible = true
	note.Position = UDim2.new(0.5, 0, 0, -2)
	fadeTo(gNote, 0, 0)
	fadeTo(gNote, 1, 0.4, QUINT, OUT)
	TweenService:Create(note, TweenInfo.new(0.4, QUINT, OUT), { Position = UDim2.new(0.5, 0, 0, 26) }):Play()
	task.delay(bad and 4.9 or 3.9, function()
		if my ~= noteSeq then
			return
		end
		fadeTo(gNote, 0, 0.16, QUAD, IN)
		TweenService:Create(note, TweenInfo.new(0.16, QUAD, IN), { Position = UDim2.new(0.5, 0, 0, 12) }):Play()
		task.delay(0.17, function()
			if my == noteSeq then
				note.Visible = false
			end
		end)
	end)
end

local function remote(name)
	local f = ReplicatedStorage:FindFirstChild("DeathRemotes")
	local r = f and f:FindFirstChild(name)
	if r and r:IsA("RemoteEvent") then
		r:FireServer()
		return true
	end
	return false
end

local function numAttr(p, n, fallback)
	local v = p:GetAttribute(n)
	if type(v) == "number" and v == v and v ~= math.huge and v ~= -math.huge then
		return v
	end
	return fallback
end
local function paintWho(instant)
	local p = state.watching
	if not p then
		return
	end
	whoName.Text = p.DisplayName
	local w = math.max(220, textW(p.DisplayName, 49))
	whoRow.Size = UDim2.fromOffset(w, 44)
	prevB.Position = UDim2.new(0.5, -(w / 2 + 42), 1, 612 - 720)
	nextB.Position = UDim2.new(0.5, w / 2 + 42, 1, 612 - 720)
	local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
	local mh = hum and hum.MaxHealth or 100
	local h = hum and math.max(0, hum.Health) or 0
	setBar("Health", h, mh > 0 and h / mh or 0, instant)
	for _, n in ipairs({ "Hunger", "Thirst" }) do
		local mx = numAttr(p, n .. "Max", 100)
		local v = numAttr(p, n, mx)
		local pct = mx > 0 and math.clamp(v / mx, 0, 1) * 100 or 0
		setBar(n, pct, pct / 100, instant)
	end
	local st, ms = numAttr(p, "Stamina", 1), numAttr(p, "MaxStamina", 1)
	setLung(ms > 0 and st / ms or 1)
end
local function watchList()
	local out = {}
	for _, p in ipairs(Players:GetPlayers()) do
		local hum = p ~= player and p.Character and p.Character:FindFirstChildOfClass("Humanoid")
		if hum and hum.Health > 0 then
			table.insert(out, p)
		end
	end
	return out
end
local function watch(p)
	state.watching = p
	local hum = p and p.Character and p.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		workspace.CurrentCamera.CameraSubject = hum
	end
	paintWho(true)
end
RunService.Heartbeat:Connect(function()
	if state.screen == "spec" and state.watching then
		local p = state.watching
		if not p.Parent or not (p.Character and p.Character:FindFirstChildOfClass("Humanoid")) then
			local l = watchList()
			if #l > 0 then
				watch(l[1])
			end
			return
		end
		paintWho(false)
	end
end)

local function lidLayout(progress)
	local a = backGui.AbsoluteSize
	if a.X <= 0 then
		return
	end
	local s = a.Y / 759
	local R = 3081 * s
	for _, l in ipairs(lidParts) do
		local edge = (l.side < 0 and 380 or 360) * s
		local move = 520 * s * progress
		local cy = l.side < 0 and (edge - R - move) or (edge + R + move)
		l.holder.Position = UDim2.new(0.5, 0, 0, cy)
		for _, r in ipairs(l.rings) do
			local d = (R + r.grow * s) * 2
			r.f.Size = UDim2.fromOffset(d, d)
		end
	end
end
local function lidEase(x)
	x = math.clamp(x, 0, 1)
	local t = x
	for _ = 1, 8 do
		local u = 1 - t
		local bx = 3 * u * u * t * 0.5 + 3 * u * t * t * 0.25 + t * t * t - x
		local d = 3 * u * u * 0.5 + 6 * u * t * (0.25 - 0.5) + 3 * t * t * 0.75
		if math.abs(bx) < 1e-6 or d == 0 then
			break
		end
		t = math.clamp(t - bx / d, 0, 1)
	end
	local u = 1 - t
	return 3 * u * u * t * 0 + 3 * u * t * t * 1 + t * t * t
end
local function easeOut(x)
	return 1 - (1 - x) * (1 - x)
end
local function wakeLook(t)
	local blur, bright
	if t < 1.7 then
		local e = easeOut(t / 1.7)
		blur, bright = 24 - 13 * e, 0.5 + 0.3 * e
	else
		local e = easeOut(math.clamp((t - 1.7) / 1.7, 0, 1))
		blur, bright = 11 * (1 - e), 0.8 + 0.2 * e
	end
	lightFx.blur.Size = blur
	lightFx.cc.TintColor = Color3.new(bright, bright, bright)
end
local function clearFx()
	for _, f in pairs(lightFx) do
		f:Destroy()
	end
	table.clear(lightFx)
end

local function openMenu(ft)
	ft = ft or 0.5
	state.screen = "menu"
	local hasBed = player:GetAttribute("HasBed") == true
	local c = player:GetAttribute("DeathCause")
	cause.Text = type(c) == "string" and c or ""
	respawnL.Text = hasBed and "Respawn at bed" or "Respawn"
	tipText.Text = hasBed and "Sleep in a different bed to move your respawn point." or "Make a bed to set your respawn point."
	lobbyBg.Visible = true
	TweenService:Create(lobbyBg, TweenInfo.new(ft, QUAD, OUT), { ImageTransparency = 0, BackgroundTransparency = 0 }):Play()
	TweenService:Create(lobbyShade, TweenInfo.new(ft, QUAD, OUT), { BackgroundTransparency = 0.65 }):Play()
	setShade(1, ft)
	showGroup(gMenu, menu, true, true)
end

local function onDied()
	if state.dead then
		return
	end
	state.dead = true
	state.seq += 1
	local my = state.seq
	hideOwnHud(true)
	setShade(0)
	diedRoot.Visible = false
	task.delay(1.8, function()
		if my ~= state.seq then
			return
		end
		play("death")
		if diedTw then
			diedTw:Cancel()
		end
		if diedGrow then
			diedGrow:Cancel()
		end
		diedScale.Scale = DIED_SCALE
		diedCG.GroupTransparency = 0
		diedRoot.Visible = true
		fadeTo(gDied, 1, 0)
		task.delay(0.2, function()
			if my ~= state.seq then
				return
			end
			diedGrow = TweenService:Create(diedScale, TweenInfo.new(2.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Scale = DIED_SCALE * 1.1 })
			diedGrow:Play()
		end)
		task.delay(2, function()
			if my ~= state.seq then
				return
			end
			diedTw = TweenService:Create(diedCG, TweenInfo.new(0.45, QUAD, IN), { GroupTransparency = 1 })
			diedTw:Play()
		end)
		task.delay(2.75, function()
			if my ~= state.seq then
				return
			end
			diedRoot.Visible = false
			openMenu(0.4)
		end)
	end)
end
local function hookCharacter(char)
	local hum = char:WaitForChild("Humanoid", 10)
	if hum then
		hum.Died:Connect(onDied)
	end
end
player.CharacterAdded:Connect(hookCharacter)
if player.Character then
	task.spawn(hookCharacter, player.Character)
end

onTap(respawnB, function()
	if state.screen ~= "menu" or state.busy then
		return
	end
	state.busy = true
	state.screen = "black"
	state.seq += 1
	local my = state.seq
	showGroup(gMenu, menu, false)
	setShade(0, 0.45, IN)
	local loaded = false
	local conn = player.CharacterAdded:Connect(function()
		loaded = true
	end)
	local hum0 = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if not remote("Respawn") or hum0 and hum0.Health > 0 then
		loaded = true
	end
	task.delay(3.17, function()
		local waited = 0
		while not loaded and waited < 8 do
			waited += task.wait(0.1)
		end
		conn:Disconnect()
		if my ~= state.seq then
			return
		end
		state.screen = "eyes"
		lobbyBg.Visible = false
		clearFx()
		lightFx.blur = Instance.new("BlurEffect")
		lightFx.blur.Name = "HorizonWakeBlur"
		lightFx.blur.Parent = Lighting
		lightFx.cc = Instance.new("ColorCorrectionEffect")
		lightFx.cc.Name = "HorizonWakeTint"
		lightFx.cc.Parent = Lighting
		wakeLook(0)
		lidLayout(0)
		lids.Visible = true
		shade.Visible = false
		shade.BackgroundTransparency = 1
		hideOwnHud(false)
		play("wake")
		local t0 = os.clock()
		local noted = false
		local step
		step = RunService.RenderStepped:Connect(function()
			local t = os.clock() - t0
			lidLayout(lidEase(t / 3))
			wakeLook(t)
			if t >= 3 and not noted then
				noted = true
				lids.Visible = false
				notify("Back on your feet")
			end
			if t >= 3.4 then
				step:Disconnect()
				clearFx()
				state.screen = "none"
				state.dead = false
				state.busy = false
			end
		end)
	end)
end)

onTap(spectateB, function()
	if state.screen ~= "menu" then
		return
	end
	local l = watchList()
	if #l == 0 then
		sfx("error")
		notify("No one to spectate", true)
		return
	end
	state.screen = "spec"
	showGroup(gMenu, menu, false)
	setShade(0.9, 0.4)
	TweenService:Create(lobbyBg, TweenInfo.new(0.4, QUAD, OUT), { ImageTransparency = 1, BackgroundTransparency = 1 }):Play()
	TweenService:Create(lobbyShade, TweenInfo.new(0.4, QUAD, OUT), { BackgroundTransparency = 1 }):Play()
	watch(l[1])
	hudGui.Enabled = true
	showGroup(gSpec, spec, true, true)
	showGroup(gWho, whoRow, true, true)
end)
local function cycle(d)
	if state.screen ~= "spec" then
		return
	end
	local l = watchList()
	if #l == 0 then
		return
	end
	local i = table.find(l, state.watching) or 0
	watch(l[(i - 1 + d) % #l + 1])
	showGroup(gWho, whoRow, true, true)
end
onTap(prevB, function()
	cycle(-1)
end)
onTap(nextB, function()
	cycle(1)
end)
onTap(specBack, function()
	if state.screen ~= "spec" then
		return
	end
	hudGui.Enabled = false
	state.watching = nil
	local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		workspace.CurrentCamera.CameraSubject = hum
	end
	showGroup(gSpec, spec, false)
	openMenu()
end)

local function joinScreen(sg)
	local root = Instance.new("CanvasGroup")
	root.Name = "JoinScreen"
	root.Size = UDim2.fromScale(1, 1)
	root.BackgroundTransparency = 1
	root.GroupTransparency = 1
	root.Parent = sg
	local bg = Instance.new("ImageLabel")
	bg.Image = CFG.Icons.joinBg
	bg.ScaleType = Enum.ScaleType.Crop
	bg.Size = UDim2.fromScale(1, 1)
	bg.BackgroundColor3 = BLACK
	bg.BorderSizePixel = 0
	bg.Parent = root
	local sh = Instance.new("Frame")
	sh.Size = UDim2.fromScale(1, 1)
	sh.BackgroundColor3 = BLACK
	sh.BackgroundTransparency = 0.75
	sh.BorderSizePixel = 0
	sh.Parent = root
	local vp = workspace.CurrentCamera.ViewportSize
	local s = math.min(vp.X / 1280, vp.Y / 759)
	local c = Instance.new("Frame")
	c.AnchorPoint = V2(0.5, 1)
	c.Position = UDim2.fromScale(0.5, 1)
	c.Size = UDim2.fromOffset(vp.X / s, 759)
	c.BackgroundTransparency = 1
	c.Parent = root
	local sc = Instance.new("UIScale")
	sc.Scale = s
	sc.Parent = c
	for _, q in ipairs({ { "RETURNING TO", 27, 535, ACCENT, 0 }, { "The Lobby", 81, 557, WHITE, 0 }, { "Your world is saved", 30, 635, WHITE, 0.15 } }) do
		local l = Instance.new("TextLabel")
		l.BackgroundTransparency = 1
		l.Font = FONT
		l.Text = q[1]
		l.TextSize = q[2]
		l.TextColor3 = q[4]
		l.TextTransparency = q[5]
		l.AnchorPoint = V2(0.5, 0)
		l.Position = UDim2.new(0.5, 0, 0, q[3])
		l.Size = UDim2.new(1, 0, 0, q[2])
		l.Parent = c
		local st = Instance.new("UIStroke")
		st.Color = BLACK
		st.Thickness = q[2] >= 40 and 3 or 2
		st.Transparency = 0.55
		st.Parent = l
	end
	return root
end
onTap(lobbyB, function()
	if state.screen ~= "menu" or state.busy then
		return
	end
	state.busy = true
	state.screen = "lobby"
	showGroup(gMenu, menu, false)
	setShade(0, 0.45, IN)
	task.delay(0.87, function()
		local sg = Instance.new("ScreenGui")
		sg.Name = "HorizonJoining"
		sg.IgnoreGuiInset = true
		sg.ResetOnSpawn = false
		sg.DisplayOrder = 100
		pcall(function()
			sg.ScreenInsets = Enum.ScreenInsets.None
		end)
		sg.Parent = playerGui
		local root = joinScreen(sg)
		TweenService:Create(root, TweenInfo.new(0.35, QUAD, OUT), { GroupTransparency = 0 }):Play()
		pcall(function()
			game:GetService("TeleportService"):SetTeleportGui(sg)
		end)
		task.delay(0.4, function()
			remote("ReturnToLobby")
		end)
	end)
end)
