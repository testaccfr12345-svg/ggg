local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local ContentProvider = game:GetService("ContentProvider")
local StarterGui = game:GetService("StarterGui")

local CFG = {
	Sounds = {
		click = { 117258347937945, 0.7 },
		error = { 83340678230226, 0.7 },
		death = { 98352871212739, 1 },
		wake = { 107350614991623, 0.7 },
	},
	Icons = {
		respawn = "rbxassetid://74439274240651",
		spectate = "rbxassetid://118090942879672",
		lobby = "rbxassetid://89417626626034",
		back = "rbxassetid://111560708284255",
		chevron = "rbxassetid://137935344939357",
		lungOutline = "rbxassetid://91220162326369",
		lungFill = "rbxassetid://117299378249299",
		joinBg = "rbxassetid://140078431096703",
		lobbyBg = "rbxassetid://109346762822915",
		youDied = "rbxassetid://131110407134601",
	},
	PanelAlpha = 0.68,
	ShowTuner = true,
	DemoSpectate = true,
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
task.spawn(function()
	for _ = 1, 20 do
		if pcall(StarterGui.SetCoreGuiEnabled, StarterGui, Enum.CoreGuiType.Health, false) then
			break
		end
		task.wait(0.5)
	end
end)
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
local lids = new("Frame", { Parent = backGui, Name = "Eyelids", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Active = true, Visible = false })
local function lidLayer(name, color, z)
	return new("Frame", { Parent = lids, Name = name, Size = UDim2.fromScale(1, 1), BackgroundColor3 = color, BackgroundTransparency = 1, ZIndex = z })
end
local lidTop = lidLayer("Top", BLACK, 3)
local lidBottom = lidLayer("Bottom", BLACK, 3)
local LID_SOFT = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0),
	NumberSequenceKeypoint.new(0.16, 0.03),
	NumberSequenceKeypoint.new(0.38, 0.28),
	NumberSequenceKeypoint.new(0.62, 0.7),
	NumberSequenceKeypoint.new(0.84, 0.95),
	NumberSequenceKeypoint.new(1, 1),
})
local function lidSegment(parent, isTop)
	local seg = new("Frame", { Parent = parent, AnchorPoint = V2(0.5, 0.5), BackgroundColor3 = BLACK, BackgroundTransparency = 0, ZIndex = 3 })
	local edge = new("Frame", { Parent = seg, Name = "SoftEdge", AnchorPoint = V2(0, isTop and 0 or 1), Position = UDim2.new(0, 0, isTop and 1 or 0, isTop and -1 or 1), BackgroundColor3 = BLACK, BackgroundTransparency = 0, ZIndex = 3 })
	local g = Instance.new("UIGradient")
	g.Rotation = isTop and 90 or 270
	g.Transparency = LID_SOFT
	g.Parent = edge
	return seg, edge
end
local lidSegs = {}
for i = 1, 17 do
	local ang = math.rad(-80 + (i - 1) * 160 / 16)
	local top, topEdge = lidSegment(lidTop, true)
	local bottom, bottomEdge = lidSegment(lidBottom, false)
	lidSegs[i] = { cx = math.sin(ang), cy = math.cos(ang), top = top, bottom = bottom, topEdge = topEdge, bottomEdge = bottomEdge }
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
local diedW0 = math.ceil(textW("YOU DIED", 100)) + 24
building = nil
local diedBox = frame(diedRoot, { Name = "Holder", AnchorPoint = V2(0.5, 0.5), Position = UDim2.new(0.5, 0, 0, 345), Size = UDim2.fromOffset(275.9, 58.6) })
local diedCG = new("CanvasGroup", { Parent = diedBox, Name = "Text", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, GroupTransparency = 1 })
local diedImg = new("ImageLabel", { Parent = diedCG, Name = "Image", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Image = CFG.Icons.youDied, ImageColor3 = WHITE, ScaleType = Enum.ScaleType.Stretch })
local diedScale = Instance.new("UIScale")
local DIED_SCALE = 544 / diedW0
diedScale.Scale = DIED_SCALE
diedScale.Parent = diedBox
local diedTw
local bloodG = {}
for i, parent in ipairs({ diedImg }) do
	local g = Instance.new("UIGradient")
	g.Parent = parent
	bloodG[i] = g
end
local B_LIGHT = Color3.fromRGB(255, 190, 194)
local B_MID = Color3.fromRGB(214, 96, 110)
local B_DEEP = Color3.fromRGB(166, 52, 68)
local B_STOPS = { -1, -0.62, -0.24, 0.24, 0.62, 1 }
local patches = {}
local rng = Random.new()
local function smooth(x)
	x = math.clamp(x, 0, 1)
	return x * x * x * (x * (x * 6 - 15) + 10)
end
local function newStains()
	table.clear(patches)
	local left = rng:NextNumber(0.09, 0.35)
	local right = rng:NextNumber(0.6, 0.91)
	local centers = { left, right }
	if rng:NextInteger(0, 1) == 1 then
		centers[1], centers[2] = right, left
	end
	local third, best = 0.38, -1
	for _, c in ipairs({ 0.07, 0.23, 0.38, 0.57, 0.76, 0.93 }) do
		local sc = math.min(math.abs(c - left), math.abs(c - right)) + rng:NextNumber(0, 0.055)
		if sc > best then
			best, third = sc, c
		end
	end
	centers[3] = third + rng:NextNumber(-0.012, 0.012)
	local delays = { 0, rng:NextNumber(0.36, 0.58), rng:NextNumber(0.84, 1.04) }
	for i, c in ipairs(centers) do
		patches[i] = {
			c = c,
			delay = delays[i],
			reach = rng:NextNumber(0.17, 0.215),
			depth = rng:NextNumber(0.74, 1),
			kl = rng:NextNumber(0.78, 1.22),
			kr = rng:NextNumber(0.78, 1.22),
			ph = rng:NextNumber(0, math.pi * 2),
			r = 0, op = 0, dk = 0,
		}
	end
	local rot = rng:NextNumber(-9, 9)
	for _, g in ipairs(bloodG) do
		g.Rotation = rot
	end
end
local function sampleBlood(x)
	local clear, dark = 1, 0
	for _, p in ipairs(patches) do
		if p.op > 0 then
			local r = p.r * (x < p.c and p.kl or p.kr)
			local d = math.abs(x - p.c)
			local a = smooth((r - d) / (r * 0.85)) * p.op
			clear *= 1 - a
			local core = smooth((r * 0.7 - d) / (r * 0.7)) * p.dk
			dark = math.max(dark, core * a)
		end
	end
	local cov = 1 - clear
	local red = B_LIGHT:Lerp(B_MID, math.clamp(cov * 1.15, 0, 1) * math.max(0.35, dark))
	return WHITE:Lerp(red:Lerp(B_DEEP, dark * dark * 0.6), cov * 0.85)
end
local function paintBlood(t)
	local age0 = (t - 0.2) / 0.75
	local xs = { 0, 1 }
	for _, p in ipairs(patches) do
		local age = math.max(0, age0 - p.delay)
		local g = math.clamp(age / 5.4, 0, 1)
		p.r = 0.008 + p.reach * (1 - (1 - g) ^ 1.6) + math.sin(age * 1.7 + p.ph) * 0.003 * g
		p.op = smooth(age / 0.96)
		p.dk = smooth(age / 2.6) * p.depth
		if p.op > 0 then
			for _, o in ipairs(B_STOPS) do
				local x = p.c + p.r * o * (o < 0 and p.kl or p.kr)
				if x > 0.001 and x < 0.999 then
					table.insert(xs, x)
				end
			end
		end
	end
	table.sort(xs)
	local u = { 0 }
	for i = 2, #xs do
		if xs[i] - u[#u] > 0.002 then
			table.insert(u, xs[i])
		end
	end
	u[#u] = 1
	while #u > 20 do
		local bi, bg = 2, math.huge
		for i = 2, #u - 1 do
			local gap = u[i + 1] - u[i - 1]
			if gap < bg then
				bi, bg = i, gap
			end
		end
		table.remove(u, bi)
	end
	local kps = {}
	for i, x in ipairs(u) do
		kps[i] = ColorSequenceKeypoint.new(x, sampleBlood(x))
	end
	local seq = ColorSequence.new(kps)
	for _, g in ipairs(bloodG) do
		g.Color = seq
	end
end

local gMenu = newGroup()
building = gMenu
local menu = frame(cv, { Name = "Menu", Size = UDim2.fromScale(1, 1), Visible = false })
local title = text(menu, "You Died", 100, { Name = "Title", Position = UDim2.fromOffset(40, 66), Size = UDim2.fromOffset(900, 96), TextColor3 = CORAL })
local titleScale = Instance.new("UIScale")
titleScale.Scale = 1.22
titleScale.Parent = title
shadow(title, 0.75)
local cause = shadow(text(menu, "", 38, { Name = "Cause", AnchorPoint = V2(0.5, 0), Position = UDim2.fromOffset(40 + textW("You Died", 100) * 1.22 / 2, 181.4), Size = UDim2.fromOffset(900, 38), TextXAlignment = Enum.TextXAlignment.Center, TextTransparency = 0.1 }), 0.55)
local tip = frame(menu, { Name = "Tip", AnchorPoint = V2(0, 1), Position = fromBottom(40, 654), Size = UDim2.fromOffset(580, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1 })
local tp = Instance.new("UIPadding")
tp.PaddingLeft, tp.PaddingRight, tp.PaddingTop, tp.PaddingBottom = UDim.new(0, 0), UDim.new(0, 0), UDim.new(0, 0), UDim.new(0, 0)
tp.Parent = tip
local tl = Instance.new("UIListLayout")
tl.SortOrder = Enum.SortOrder.LayoutOrder
tl.Padding = UDim.new(0, 6)
tl.Parent = tip
local tipHead = frame(tip, { Name = "Head", Size = UDim2.new(1, 0, 0, 34), LayoutOrder = 1 })
round(frame(tipHead, { AnchorPoint = V2(0, 0.5), Position = UDim2.new(0, 0, 0.5, 0), Size = UDim2.fromOffset(12, 12), BackgroundTransparency = 0, BackgroundColor3 = ACCENT }), 3)
shadow(text(tipHead, "Tip", 34, { Position = UDim2.fromOffset(22, 0), Size = UDim2.fromOffset(200, 34), TextColor3 = ACCENT }), 0.55)
local tipText = shadow(text(tip, "", 36, { Name = "Text", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, TextWrapped = true, LineHeight = 0.886, LayoutOrder = 2 }), 0.55)

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
local whoRow = frame(spec, { Name = "Player", AnchorPoint = V2(0.5, 0), Position = UDim2.new(0.5, 0, 1, 562 - 720), Size = UDim2.fromOffset(400, 44) })
local whoName = shadow(text(whoRow, "", 49, { AnchorPoint = V2(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(600, 49), TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = WHITE }))
building = gSpec
local prevB = new("TextButton", { Parent = spec, Name = "Previous", Text = "", AutoButtonColor = false, AnchorPoint = V2(0.5, 0), Size = UDim2.fromOffset(44, 44), BackgroundTransparency = 1 })
icon(prevB, CFG.Icons.chevron, 26, CREAM, { AnchorPoint = V2(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Rotation = 180 })
local nextB = new("TextButton", { Parent = spec, Name = "Next", Text = "", AutoButtonColor = false, AnchorPoint = V2(0.5, 0), Size = UDim2.fromOffset(44, 44), BackgroundTransparency = 1 })
icon(nextB, CFG.Icons.chevron, 26, CREAM, { AnchorPoint = V2(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
local backW = 12 + 17 + 6 + math.ceil(textW("Back", 27)) + 18
local specBack = new("TextButton", { Parent = spec, Name = "BackButton", Text = "", AutoButtonColor = false, AnchorPoint = V2(0.5, 0), Position = UDim2.new(0.5, 0, 1, 614 - 720), Size = UDim2.fromOffset(backW, 42), BackgroundColor3 = PANEL, BackgroundTransparency = PANEL_T })
round(specBack, 10)
new("UIStroke", { Parent = specBack, Color = CREAM, Thickness = 1, Transparency = 0.86, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
icon(specBack, CFG.Icons.back, 17, CREAM, { AnchorPoint = V2(0, 0.5), Position = UDim2.new(0, 12, 0.5, 0) })
text(specBack, "Back", 27, { Position = UDim2.fromOffset(35, 0), Size = UDim2.new(1, -35, 1, 0) })

local TRAIT_COLORS = { "CFC5B4", "9CCB86", "7DB3E0", "B79AE6", "E9B949", "F2706A" }
local TRAITS = {
	deep_breath = { "Deep Breath", 1, "rbxassetid://134703443523875" },
	quick_recovery = { "Quick Recovery", 2, "rbxassetid://114308483878858" },
	power_swim = { "Power Swim", 3, "rbxassetid://84312041849462" },
	night_eye = { "Night Eyes", 4, "rbxassetid://77761035149012" },
	snap_reflex = { "Snap Reflex", 4, "rbxassetid://98463663692815" },
	primal_cry = { "Primal Cry", 5, "rbxassetid://101734345778856" },
	iron_lunge = { "Iron Lungs", 5, "rbxassetid://128252861673544" },
	adrenaline_surge = { "Adrenaline Surge", 6, "rbxassetid://83510710583566" },
}
local function findTrait(v)
	if type(v) ~= "string" or v == "" then
		return nil
	end
	if TRAITS[v] then
		return TRAITS[v]
	end
	local lv = v:lower()
	for k, t in pairs(TRAITS) do
		if t[1]:lower() == lv or k == (lv:gsub(" ", "_")) then
			return t
		end
	end
	return nil
end
local traitRow = frame(spec, { Name = "Traits", AnchorPoint = V2(0.5, 0), Position = UDim2.new(0.5, 0, 1, 510 - 720), Size = UDim2.fromOffset(0, 38), AutomaticSize = Enum.AutomaticSize.X })
local trl = Instance.new("UIListLayout")
trl.FillDirection = Enum.FillDirection.Horizontal
trl.HorizontalAlignment = Enum.HorizontalAlignment.Center
trl.VerticalAlignment = Enum.VerticalAlignment.Center
trl.SortOrder = Enum.SortOrder.LayoutOrder
trl.Padding = UDim.new(0, 10)
trl.Parent = traitRow
local pills = {}
for i = 1, 2 do
	local pf = frame(traitRow, { Name = "Trait" .. i, Size = UDim2.fromOffset(0, 38), AutomaticSize = Enum.AutomaticSize.X, BackgroundColor3 = PANEL, BackgroundTransparency = PANEL_T, LayoutOrder = i, Visible = false })
	round(pf, 10)
	local st = new("UIStroke", { Parent = pf, Color = CREAM, Thickness = 1, Transparency = 0.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
	local pp = Instance.new("UIPadding")
	pp.PaddingLeft, pp.PaddingRight = UDim.new(0, 10), UDim.new(0, 14)
	pp.Parent = pf
	local pl = Instance.new("UIListLayout")
	pl.FillDirection = Enum.FillDirection.Horizontal
	pl.VerticalAlignment = Enum.VerticalAlignment.Center
	pl.SortOrder = Enum.SortOrder.LayoutOrder
	pl.Padding = UDim.new(0, 8)
	pl.Parent = pf
	local ic = icon(pf, "", 26, CREAM, { Name = "Icon", LayoutOrder = 1 })
	local tx = text(pf, "", 27, { Name = "Name", Size = UDim2.fromOffset(0, 27), AutomaticSize = Enum.AutomaticSize.X, LayoutOrder = 2 })
	pills[i] = { f = pf, st = st, ic = ic, tx = tx }
end
local traitKey = nil
local function setTraits(a, b)
	local key = tostring(a) .. "|" .. tostring(b)
	if key == traitKey then
		return
	end
	traitKey = key
	local n = 0
	for _, v in ipairs({ a, b }) do
		local t = findTrait(v)
		if t then
			n += 1
			local pl = pills[n]
			local c = Color3.fromHex(TRAIT_COLORS[t[2]])
			pl.tx.Text = t[1]
			pl.tx.TextColor3 = c
			pl.ic.Image = t[3]
			pl.ic.ImageColor3 = c
			pl.st.Color = c
			pl.f.Visible = true
		end
	end
	for i = n + 1, 2 do
		pills[i].f.Visible = false
	end
end

local gNote = newGroup()
building = gNote
local note = text(cv, "", 45, { Name = "Notification", AnchorPoint = V2(0.5, 0), Position = UDim2.new(0.5, 0, 0, 18), Size = UDim2.fromOffset(0, 37.4), AutomaticSize = Enum.AutomaticSize.X, TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = WHITE, Visible = false, ZIndex = 20 })
new("UIStroke", { Parent = note, Color = BLACK, Thickness = 1.5, Transparency = 0.4 })
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
	Health = { Id = "131508582817817", Canvas = 1024, X = 160, Y = 160, Width = 704, Height = 704 },
	Hunger = { Id = "131397258308866", Canvas = 720, X = 250, Y = 126, Width = 290, Height = 452 },
	Thirst = { Id = "91631003184743", Canvas = 720, X = 168, Y = 146, Width = 388, Height = 428 },
}
local HUD_TEXT = Color3.fromRGB(241, 237, 230)
local HUD_LOW = Color3.fromRGB(240, 160, 96)
local hud = Instance.new("Frame")
hud.Name = "SurvivalStats"
hud.Position = UDim2.fromOffset(8, 6)
hud.Size = UDim2.fromOffset(150, 44)
hud.BackgroundTransparency = 1
hud.Parent = hudGui
local hudScale = Instance.new("UIScale")
hudScale.Parent = hud
local bars = {}
local LAYOUT = { Health = { 0, 0, 1 }, Hunger = { 0, 24 / 44, 73 / 150 }, Thirst = { 77 / 150, 24 / 44, 73 / 150 } }
for name, col in pairs({ Health = Color3.fromRGB(196, 82, 76), Hunger = Color3.fromRGB(133, 157, 99), Thirst = Color3.fromRGB(104, 150, 174) }) do
	local l = LAYOUT[name]
	local bar = Instance.new("Frame")
	bar.Name = name
	bar.Position = UDim2.fromScale(l[1], l[2])
	bar.Size = UDim2.fromScale(l[3], 20 / 44)
	bar.BackgroundColor3 = BLACK
	bar.BackgroundTransparency = 0.55
	bar.BorderSizePixel = 0
	bar.ClipsDescendants = true
	bar.Parent = hud
	local c1 = Instance.new("UICorner")
	c1.CornerRadius = UDim.new(0.18, 0)
	c1.Parent = bar
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = col
	fill.BorderSizePixel = 0
	fill.ZIndex = 2
	fill.Parent = bar
	local c2 = Instance.new("UICorner")
	c2.CornerRadius = UDim.new(0.18, 0)
	c2.Parent = fill
	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Size = UDim2.fromScale(1, 1)
	content.BackgroundTransparency = 1
	content.ZIndex = 3
	content.Parent = bar
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 4)
	pad.Parent = content
	local ll = Instance.new("UIListLayout")
	ll.FillDirection = Enum.FillDirection.Horizontal
	ll.VerticalAlignment = Enum.VerticalAlignment.Center
	ll.SortOrder = Enum.SortOrder.LayoutOrder
	ll.Padding = UDim.new(0, 5)
	ll.Parent = content
	local ic = Instance.new("ImageLabel")
	ic.Name = "Icon"
	ic.BackgroundTransparency = 1
	ic.Image = "rbxassetid://" .. ASSETS[name].Id
	ic.ImageColor3 = WHITE
	ic.ScaleType = Enum.ScaleType.Fit
	ic.SizeConstraint = Enum.SizeConstraint.RelativeYY
	ic.Size = UDim2.fromScale(0.8, 0.8)
	ic.LayoutOrder = 1
	ic.ZIndex = 3
	ic.Parent = content
	local val = Instance.new("TextLabel")
	val.Name = "Value"
	val.BackgroundTransparency = 1
	val.Size = UDim2.fromScale(0.6, 0.95)
	val.Font = FONT
	val.TextColor3 = HUD_TEXT
	val.TextScaled = true
	val.TextXAlignment = Enum.TextXAlignment.Left
	val.LayoutOrder = 2
	val.ZIndex = 3
	val.Parent = content
	bars[name] = { bar = bar, fill = fill, val = val }
end
local function setLung() end
local function hudResize()
	local vp = hudGui.AbsoluteSize
	if vp.X <= 0 or vp.Y <= 0 then
		return
	end
	hudScale.Scale = math.clamp(vp.Y / 335, 0.9, 1.8)
end
hudGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(hudResize)
hudResize()
local hudTweens = {}
local function setBar(name, value, frac, instant)
	local b = bars[name]
	b.val.Text = tostring(math.round(value))
	b.val.TextColor3 = frac < 0.25 and HUD_LOW or HUD_TEXT
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

local function demoWho()
	local names = { "kai_builds", "mira_exe", "sunnycove22", "TideRunner", "orca_skipped", "palm.tree.pro" }
	local keys = {}
	for k in pairs(TRAITS) do
		table.insert(keys, k)
	end
	local k1 = keys[math.random(#keys)]
	local k2 = keys[math.random(#keys)]
	while k2 == k1 do
		k2 = keys[math.random(#keys)]
	end
	local count = math.random(0, 2)
	return names[math.random(#names)], count >= 1 and k1 or nil, count >= 2 and k2 or nil
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
local noteText, noteUntil = nil, 0
local function notify(str)
	if noteText == str and os.clock() < noteUntil then
		return
	end
	noteSeq += 1
	local my = noteSeq
	noteText, noteUntil = str, os.clock() + 2.6
	note.Text = str
	note.Visible = true
	note.Position = UDim2.new(0.5, 0, 0, -10)
	fadeTo(gNote, 0, 0)
	fadeTo(gNote, 1, 0.4, QUINT, OUT)
	TweenService:Create(note, TweenInfo.new(0.4, QUINT, OUT), { Position = UDim2.new(0.5, 0, 0, 18) }):Play()
	task.delay(2.4, function()
		if my ~= noteSeq then
			return
		end
		fadeTo(gNote, 0, 0.2, QUAD, IN)
		TweenService:Create(note, TweenInfo.new(0.2, QUAD, IN), { Position = UDim2.new(0.5, 0, 0, 4) }):Play()
		task.delay(0.21, function()
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
local function layoutWho(name)
	whoName.Text = name
	local w = math.max(220, textW(name, 49))
	whoRow.Size = UDim2.fromOffset(w, 44)
	prevB.Position = UDim2.new(0.5, -(w / 2 + 42), 1, 562 - 720)
	nextB.Position = UDim2.new(0.5, w / 2 + 42, 1, 562 - 720)
end
local function paintDemo()
	local n, a, b = demoWho()
	layoutWho(n)
	setTraits(a, b)
	setBar("Health", math.random(5, 100), math.random(), true)
	local hu, th = math.random(0, 100), math.random(0, 100)
	setBar("Hunger", hu, hu / 100, true)
	setBar("Thirst", th, th / 100, true)
	setLung(math.random())
end
local function paintWho(instant)
	local p = state.watching
	if not p then
		return
	end
	layoutWho(p.DisplayName)
	setTraits(p:GetAttribute("Trait1"), p:GetAttribute("Trait2"))
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

local EYE_OPEN = {
	{ 0, 0 }, { 0.03, 0.003 }, { 0.1, 0.008 }, { 0.163, 0.025 }, { 0.23, 0.046 }, { 0.297, 0.077 }, { 0.363, 0.107 },
	{ 0.43, 0.136 }, { 0.497, 0.157 }, { 0.563, 0.175 }, { 0.63, 0.187 }, { 0.697, 0.196 }, { 0.763, 0.202 }, { 0.83, 0.206 },
	{ 0.897, 0.208 }, { 1.03, 0.211 }, { 1.097, 0.221 }, { 1.163, 0.237 }, { 1.23, 0.26 }, { 1.297, 0.284 }, { 1.363, 0.329 },
	{ 1.43, 0.39 }, { 1.497, 0.468 }, { 1.563, 0.56 }, { 1.63, 0.68 }, { 1.7, 0.8 },
}
local LIDS_END, NOTE_AT, WAKE_END = 1.7, 3, 3.4
local function eyeOpen(t)
	if t <= 0 then
		return 0
	end
	for i = 2, #EYE_OPEN do
		local b = EYE_OPEN[i]
		if t <= b[1] then
			local a = EYE_OPEN[i - 1]
			return a[2] + (b[2] - a[2]) * (t - a[1]) / (b[1] - a[1])
		end
	end
	return EYE_OPEN[#EYE_OPEN][2]
end
local lidW, lidH, lidPanel = -1, -1, 1
local function lidLayout(t)
	local lift = eyeOpen(t)
	local span = 1.8
	local w = math.max(1, lids.AbsoluteSize.X)
	local h = math.max(1, lids.AbsoluteSize.Y)
	if w ~= lidW or h ~= lidH then
		lidW, lidH = w, h
		local diag = math.sqrt(w * w + h * h)
		lidPanel = diag * 2
		local feather = math.max(30, h * 0.12)
		for _, sg in ipairs(lidSegs) do
			sg.top.Size = UDim2.fromOffset(diag * 4, lidPanel)
			sg.bottom.Size = UDim2.fromOffset(diag * 4, lidPanel)
			sg.topEdge.Size = UDim2.new(1, 0, 0, feather + 1)
			sg.bottomEdge.Size = UDim2.new(1, 0, 0, feather + 1)
		end
	end
	local half = lidPanel * 0.5
	local slope = 2 * h / w
	for _, sg in ipairs(lidSegs) do
		local x = sg.cx * span
		local ua = math.atan(lift * sg.cx / (span * sg.cy) * slope)
		local uy = 0.5 - lift * sg.cy
		local ly = 0.5 + lift * sg.cy
		sg.top.Rotation = math.deg(ua)
		sg.top.Position = UDim2.fromOffset((x + 1) * w * 0.5 + math.sin(ua) * half, uy * h - math.cos(ua) * half)
		sg.bottom.Rotation = -math.deg(ua)
		sg.bottom.Position = UDim2.fromOffset((x + 1) * w * 0.5 + math.sin(ua) * half, ly * h + math.cos(ua) * half)
	end
end
local function easeOut(x)
	return 1 - (1 - x) * (1 - x)
end
local function wakeLook(t)
	local blur, bright
	if t < WAKE_END / 2 then
		local e = easeOut(t / (WAKE_END / 2))
		blur, bright = 24 - 13 * e, 0.5 + 0.3 * e
	else
		local e = easeOut(math.clamp((t - WAKE_END / 2) / (WAKE_END / 2), 0, 1))
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

local function openMenu(ft, still)
	ft = ft or 0.5
	state.screen = "menu"
	local hasBed = player:GetAttribute("HasBed") == true
	local c = player:GetAttribute("DeathCause")
	cause.Text = type(c) == "string" and c ~= "" and c or "Killed by a Tiger"
	respawnL.Text = hasBed and "Respawn at bed" or "Respawn"
	tipText.Text = hasBed and "Sleep in a different bed to move your respawn point." or "Make a bed to set your respawn point."
	lobbyBg.Visible = true
	TweenService:Create(lobbyBg, TweenInfo.new(ft, QUAD, OUT), { ImageTransparency = 0, BackgroundTransparency = 0 }):Play()
	TweenService:Create(lobbyShade, TweenInfo.new(ft, QUAD, OUT), { BackgroundTransparency = 0.65 }):Play()
	setShade(1, ft)
	showGroup(gMenu, menu, true, not still)
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
		local ds = snd.death
		local w0 = os.clock()
		local wc
		local function showDied()
			if diedTw then
				diedTw:Cancel()
			end
			diedCG.GroupTransparency = 0
			newStains()
			paintBlood(0)
			local b0 = os.clock()
			local bc
			bc = RunService.RenderStepped:Connect(function()
				local t = os.clock() - b0
				if my ~= state.seq or t > 3 then
					bc:Disconnect()
					return
				end
				paintBlood(t)
			end)
			diedRoot.Visible = true
			fadeTo(gDied, 1, 0)
			task.delay(2.5, function()
				if my ~= state.seq then
					return
				end
				diedTw = TweenService:Create(diedCG, TweenInfo.new(0.45, QUAD, IN), { GroupTransparency = 1 })
				diedTw:Play()
			end)
			task.delay(3.25, function()
				if my ~= state.seq then
					return
				end
				diedRoot.Visible = false
				openMenu(0.4, true)
			end)
		end
		wc = RunService.Heartbeat:Connect(function()
			if my ~= state.seq then
				wc:Disconnect()
				return
			end
			if ds.TimePosition >= 0.03 or os.clock() - w0 > 0.35 then
				wc:Disconnect()
				showDied()
			end
		end)
	end)
end
local function muteDied(sd)
	if sd:IsA("Sound") and sd.Name == "Died" then
		sd.Volume = 0
		sd:GetPropertyChangedSignal("Volume"):Connect(function()
			if sd.Volume ~= 0 then
				sd.Volume = 0
			end
		end)
	end
end
local function muteChar(char)
	for _, d in ipairs(char:GetDescendants()) do
		muteDied(d)
	end
	char.DescendantAdded:Connect(muteDied)
end
local function mutePlayer(p)
	if p.Character then
		muteChar(p.Character)
	end
	p.CharacterAdded:Connect(muteChar)
end
for _, p in ipairs(Players:GetPlayers()) do
	mutePlayer(p)
end
Players.PlayerAdded:Connect(mutePlayer)
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
			if my ~= state.seq then
				step:Disconnect()
				lids.Visible = false
				clearFx()
				return
			end
			if t < LIDS_END then
				lidLayout(t)
			elseif lids.Visible then
				lids.Visible = false
			end
			wakeLook(math.min(t, WAKE_END))
			if t >= NOTE_AT and not noted then
				noted = true
				notify("Back on your feet")
			end
			if t >= WAKE_END then
				step:Disconnect()
				lids.Visible = false
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
	if #l == 0 and not CFG.DemoSpectate then
		sfx("error")
		notify("No one to spectate")
		return
	end
	state.screen = "spec"
	showGroup(gMenu, menu, false)
	setShade(0.9, 0.4)
	TweenService:Create(lobbyBg, TweenInfo.new(0.4, QUAD, OUT), { ImageTransparency = 1, BackgroundTransparency = 1 }):Play()
	TweenService:Create(lobbyShade, TweenInfo.new(0.4, QUAD, OUT), { BackgroundTransparency = 1 }):Play()
	if #l > 0 then
		watch(l[1])
	else
		state.watching = nil
		paintDemo()
	end
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
		if CFG.DemoSpectate then
			paintDemo()
			showGroup(gWho, whoRow, true, true)
		end
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
task.spawn(function()
	local seen, list = {}, {}
	local function add(id)
		if type(id) == "string" and id ~= "" and not seen[id] then
			seen[id] = true
			table.insert(list, id)
		end
	end
	for _, id in pairs(CFG.Icons) do
		add(id)
	end
	for _, d in pairs(CFG.Sounds) do
		if d[1] ~= 0 then
			add("rbxassetid://" .. d[1])
		end
	end
	for _, a in pairs(ASSETS) do
		add("rbxassetid://" .. a.Id)
	end
	for _, t in pairs(TRAITS) do
		add(t[3])
	end
	for _, rootObj in ipairs({ playerGui, SoundService }) do
		for _, d in ipairs(rootObj:GetDescendants()) do
			if d:IsA("ImageLabel") or d:IsA("ImageButton") then
				add(d.Image)
			elseif d:IsA("Sound") then
				add(d.SoundId)
			end
		end
	end
	for _ = 1, 3 do
		local failed = {}
		pcall(ContentProvider.PreloadAsync, ContentProvider, list, function(id, status)
			if status ~= Enum.AssetFetchStatus.Success then
				table.insert(failed, id)
			end
		end)
		if #failed == 0 then
			break
		end
		list = failed
		task.wait(2)
	end
end)
if CFG.ShowTuner and script:FindFirstChild("Tuner") then
	local function hideAll()
		state.screen = "none"
		diedRoot.Visible = false
		diedCG.GroupTransparency = 1
		menu.Visible = false
		spec.Visible = false
		hudGui.Enabled = false
		lobbyBg.Visible = false
		setShade(1)
		shade.Visible = false
	end
	task.spawn(require(script.Tuner).start, { gui, hudGui }, {
		EquipmentIcons = {},
		Preview = {
			died = function()
				local on = not diedRoot.Visible
				hideAll()
				if on then
					setShade(0)
					newStains()
					paintBlood(1.6)
					diedCG.GroupTransparency = 0
					diedRoot.Visible = true
					fadeTo(gDied, 1, 0)
				end
			end,
			menu = function()
				local on = not menu.Visible
				hideAll()
				if on then
					openMenu(0, true)
				end
			end,
			spectate = function()
				hideAll()
				paintDemo()
				hudGui.Enabled = true
				spec.Visible = true
				whoRow.Visible = true
				fadeTo(gSpec, 1, 0)
				fadeTo(gWho, 1, 0)
			end,
			hide = hideAll,
			notify = function()
				notify("Back on your feet")
			end,
		},
	}, {})
end
