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
local specW = 27 + math.ceil(textW("SPECTATING", 35))
local specTag = frame(spec, { Name = "Label", AnchorPoint = V2(0.5, 0), Position = UDim2.new(0.5, 0, 0, -10), Size = UDim2.fromOffset(specW, 35) })
round(frame(specTag, { Position = UDim2.fromOffset(0, 10), Size = UDim2.fromOffset(15, 15), BackgroundTransparency = 0, BackgroundColor3 = ACCENT }), 3)
shadow(text(specTag, "SPECTATING", 35, { Position = UDim2.fromOffset(27, 0), Size = UDim2.fromOffset(specW, 35), TextTransparency = 0.1 }))
local gWho = newGroup()
building = gWho
local whoRow = frame(spec, { Name = "Player", AnchorPoint = V2(0.5, 0), Position = UDim2.new(0.5, 0, 1, 562 - 720), Size = UDim2.fromOffset(400, 44) })
local whoName = shadow(text(whoRow, "", 49, { AnchorPoint = V2(0.5, 0.5), Position = UDim2.new(0.5, 0, 0.5, 16), Size = UDim2.fromOffset(600, 49), TextXAlignment = Enum.TextXAlignment.Center, TextColor3 = WHITE }))
building = gSpec
local prevB = new("TextButton", { Parent = spec, Name = "Previous", Text = "", AutoButtonColor = false, AnchorPoint = V2(0.5, 0), Size = UDim2.fromOffset(44, 44), BackgroundTransparency = 1 })
icon(prevB, CFG.Icons.chevron, 26, CREAM, { AnchorPoint = V2(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Rotation = 180 })
local nextB = new("TextButton", { Parent = spec, Name = "Next", Text = "", AutoButtonColor = false, AnchorPoint = V2(0.5, 0), Size = UDim2.fromOffset(44, 44), BackgroundTransparency = 1 })
icon(nextB, CFG.Icons.chevron, 26, CREAM, { AnchorPoint = V2(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5) })
local specBack = new("TextButton", { Parent = spec, Name = "BackButton", Text = "", AutoButtonColor = false, AnchorPoint = V2(0.5, 0), Position = UDim2.new(0.5, 0, 1, -82), Size = UDim2.fromOffset(106, 48), BackgroundColor3 = PANEL, BackgroundTransparency = PANEL_T })
round(specBack, 10)
new("UIStroke", { Parent = specBack, Color = CREAM, Thickness = 1, Transparency = 0.86, ApplyStrokeMode = Enum.ApplyStrokeMode.Border })
icon(specBack, CFG.Icons.back, 19, CREAM, { AnchorPoint = V2(0, 0.5), Position = UDim2.new(0, 10, 0.5, 0) })
text(specBack, "Back", 30, { Position = UDim2.fromOffset(37, -1), Size = UDim2.new(1, -35, 1, 0) })

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
local traitRow = frame(spec, { Name = "Traits", AnchorPoint = V2(0.5, 0), Position = UDim2.new(0.5, 0, 1, -214.5), Size = UDim2.fromOffset(0, 49), AutomaticSize = Enum.AutomaticSize.X })
local trl = Instance.new("UIListLayout")
trl.FillDirection = Enum.FillDirection.Horizontal
trl.HorizontalAlignment = Enum.HorizontalAlignment.Center
trl.VerticalAlignment = Enum.VerticalAlignment.Center
trl.SortOrder = Enum.SortOrder.LayoutOrder
trl.Padding = UDim.new(0, 40)
trl.Parent = traitRow
local pills = {}
for i = 1, 2 do
	local pf = frame(traitRow, { Name = "Trait" .. i, Size = UDim2.fromOffset(49, 49), LayoutOrder = i, Visible = false })
	local glow = new("ImageLabel", { Parent = pf, Name = "Glow", AnchorPoint = V2(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5), Size = UDim2.fromOffset(96, 96), BackgroundTransparency = 1, Image = "rbxassetid://122287453864385", ImageColor3 = CREAM, ImageTransparency = 0.6, ZIndex = 1 })
	local ic = icon(pf, "", 49, CREAM, { Name = "Icon", ZIndex = 2 })
	pills[i] = { f = pf, glow = glow, ic = ic }
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
			pl.ic.Image = t[3]
			pl.ic.ImageColor3 = c
			pl.glow.ImageColor3 = c
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
	Health = { Plus = true },
	Hunger = { Id = "96663414336154", Plain = true },
	Thirst = { Id = "101658142884052", Canvas = 1024, X = 296, Y = 274, Width = 426, Height = 476 },
}
pcall(function()
	hudGui.ClipToDeviceSafeArea = false
end)
local HUD_COLORS = { Health = Color3.fromRGB(224, 122, 110), Hunger = Color3.fromRGB(235, 170, 106), Thirst = Color3.fromRGB(128, 185, 221) }
local HUD_MARKS = {
	Health = { { -1.5, -0.5, 0.95 }, { -3.6, 0.1, 0.91 }, { -3.7, 0.0, 0.87 }, { -0.6, -0.6, 0.87 }, { -0.6, 0.5, 0.88 }, { -2.3, 0.2, 0.99 }, { 0.6, -0.1, 1.00 }, { -3.8, 0.5, 0.90 }, { -3.0, -0.6, 0.90 }, { 2.7, -0.5, 0.94 } },
	Hunger = { { 1.2, -0.2, 0.94 }, { -3.7, -0.6, 0.89 }, { 1.5, -0.1, 0.90 }, { 0.7, -0.1, 0.90 }, { 2.5, 0.3, 0.89 }, { 0.6, 0.0, 0.98 }, { 1.9, -0.3, 1.00 }, { -3.2, -0.1, 0.97 }, { -2.9, 0.0, 0.87 }, { 1.4, 0.4, 0.94 } },
	Thirst = { { 3.2, -0.3, 0.96 }, { 0.8, 0.1, 0.92 }, { 2.9, 0.6, 0.93 }, { 1.4, -0.6, 0.96 }, { 1.2, 0.7, 0.98 }, { -1.8, -0.2, 0.95 }, { -4.0, -0.1, 0.88 }, { -3.2, -0.6, 0.97 }, { -3.1, -0.4, 0.91 }, { 3.1, -0.6, 0.92 } },
}
local STROKE = "rbxassetid://75405977088659"
local SFW, SFH, SFRAMES = 48, 144, 20
local HUD_FILL = TweenInfo.new(0.3, QUAD, OUT)
local HUD_PULSE = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
local hud = Instance.new("Frame")
hud.Name = "SurvivalStats"
hud.AnchorPoint = V2(0, 1)
hud.Position = UDim2.new(0, 11, 1, -8)
hud.Size = UDim2.fromOffset(140, 63)
hud.BackgroundTransparency = 1
hud.Parent = hudGui
local hudScale = Instance.new("UIScale")
hudScale.Parent = hud
local hudHaze = Instance.new("ImageLabel")
hudHaze.Name = "Haze"
hudHaze.AnchorPoint = V2(0.5, 0.5)
hudHaze.Position = UDim2.fromScale(0.5, 0.5)
hudHaze.Size = UDim2.new(1, 60, 1, 46)
hudHaze.BackgroundTransparency = 1
hudHaze.Image = "rbxassetid://130881451468251"
hudHaze.ImageColor3 = BLACK
hudHaze.ImageTransparency = 0.82
hudHaze.ZIndex = 0
hudHaze.Parent = hud
local hudRows = Instance.new("Frame")
hudRows.Name = "Rows"
hudRows.Size = UDim2.fromScale(1, 1)
hudRows.BackgroundTransparency = 1
hudRows.ZIndex = 1
hudRows.Parent = hud
local hrl = Instance.new("UIListLayout")
hrl.FillDirection = Enum.FillDirection.Vertical
hrl.Padding = UDim.new(0, 6)
hrl.SortOrder = Enum.SortOrder.LayoutOrder
hrl.Parent = hudRows
local function hudIcon(parent, asset, color)
	local box = Instance.new("Frame")
	box.Name = "Icon"
	box.Size = UDim2.fromOffset(15, 15)
	box.BackgroundTransparency = 1
	box.ClipsDescendants = not asset.Plus
	box.LayoutOrder = 1
	box.Parent = parent
	if asset.Plus then
		local plus = Instance.new("Frame")
		plus.Name = "Plus"
		plus.Position = UDim2.fromOffset(-0.5, -0.5)
		plus.Size = UDim2.fromOffset(16, 16)
		plus.BackgroundTransparency = 1
		plus.Parent = box
		for _, d in ipairs({ { 0, 6, 16, 4 }, { 6, 0, 4, 16 } }) do
			local f = Instance.new("Frame")
			f.BorderSizePixel = 0
			f.Position = UDim2.fromOffset(d[1], d[2])
			f.Size = UDim2.fromOffset(d[3], d[4])
			f.BackgroundColor3 = color
			f.Parent = plus
		end
		return plus
	end
	local image = Instance.new("ImageLabel")
	image.BackgroundTransparency = 1
	image.Image = "rbxassetid://" .. asset.Id
	image.ImageColor3 = color
	if asset.Plain then
		image.ScaleType = Enum.ScaleType.Fit
		image.Size = UDim2.fromScale(1, 1)
	else
		local fit = math.min(15 / asset.Width, 15 / asset.Height)
		image.Size = UDim2.fromOffset(asset.Canvas * fit, asset.Canvas * fit)
		image.Position = UDim2.fromOffset(7.5 - (asset.X + asset.Width / 2) * fit, 7.5 - (asset.Y + asset.Height / 2) * fit)
	end
	image.Parent = box
	return image
end
local bars = {}
for order, name in ipairs({ "Health", "Hunger", "Thirst" }) do
	local col = HUD_COLORS[name]
	local row = Instance.new("Frame")
	row.Name = name
	row.Size = UDim2.fromOffset(0, 17)
	row.AutomaticSize = Enum.AutomaticSize.X
	row.BackgroundTransparency = 1
	row.LayoutOrder = order
	row.Parent = hudRows
	local rl = Instance.new("UIListLayout")
	rl.FillDirection = Enum.FillDirection.Horizontal
	rl.VerticalAlignment = Enum.VerticalAlignment.Center
	rl.Padding = UDim.new(0, 9)
	rl.SortOrder = Enum.SortOrder.LayoutOrder
	rl.Parent = row
	local ic = hudIcon(row, ASSETS[name], col)
	local marks = Instance.new("Frame")
	marks.Name = "Marks"
	marks.Size = UDim2.fromOffset(81.75, 17)
	marks.BackgroundTransparency = 1
	marks.LayoutOrder = 2
	marks.Parent = row
	local strokes = {}
	for i = 0, 9 do
		local m = HUD_MARKS[name][i + 1]
		local holder = Instance.new("Frame")
		holder.AnchorPoint = V2(0.5, 0.5)
		holder.Position = UDim2.fromOffset(7.5 * i + 3.75 + m[2] + (i >= 5 and 6.75 or 0), 8.5)
		holder.Size = UDim2.fromOffset(8, 24 * m[3])
		holder.Rotation = m[1]
		holder.BackgroundTransparency = 1
		holder.Parent = marks
		for li = 1, 2 do
			local img = Instance.new("ImageLabel")
			img.Size = UDim2.fromScale(1, 1)
			img.BackgroundTransparency = 1
			img.Image = STROKE
			img.ImageRectSize = Vector2.new(SFW, SFH)
			img.ImageColor3 = col
			img.ScaleType = Enum.ScaleType.Stretch
			img.ZIndex = li
			if li == 1 then
				img.ImageRectOffset = Vector2.new(SFRAMES * SFW, 0)
				img.ImageTransparency = 0.78
			else
				img.ImageRectOffset = Vector2.new(0, 0)
				img.Visible = false
				strokes[i + 1] = { fill = img, frame = -1 }
			end
			img.Parent = holder
		end
	end
	local val = Instance.new("TextLabel")
	val.Name = "Value"
	val.Size = UDim2.fromOffset(18, 17)
	val.AutomaticSize = Enum.AutomaticSize.X
	val.BackgroundTransparency = 1
	val.Font = FONT
	val.TextSize = 19
	val.TextColor3 = CREAM
	val.TextXAlignment = Enum.TextXAlignment.Left
	val.Text = ""
	val.LayoutOrder = 3
	val.Parent = row
	local b = { name = name, icon = ic, val = val, strokes = strokes, pct = Instance.new("NumberValue"), pulse = Instance.new("NumberValue"), low = false }
	b.pct.Changed:Connect(function(v)
		for i, st in ipairs(strokes) do
			local k = math.floor(math.clamp(v / 10 - (i - 1), 0, 1) * SFRAMES + 0.5)
			if k ~= st.frame then
				st.frame = k
				st.fill.Visible = k > 0
				st.fill.ImageRectOffset = Vector2.new(k * SFW, 0)
			end
		end
	end)
	b.pulse.Changed:Connect(function(t)
		val.TextTransparency = t
	end)
	bars[name] = b
end
local function setLung() end
local hudBase = {}
for _, d in ipairs(hud:GetDescendants()) do
	if d:IsA("ImageLabel") then
		hudBase[d] = { "ImageTransparency", d.ImageTransparency }
	elseif d:IsA("TextLabel") then
		hudBase[d] = { "TextTransparency", d.TextTransparency }
	elseif d:IsA("Frame") and d.BackgroundTransparency < 1 then
		hudBase[d] = { "BackgroundTransparency", d.BackgroundTransparency }
	end
end
local hudFadeV = Instance.new("NumberValue")
local hudFadeTw
local function hudFade(a)
	for d, b in pairs(hudBase) do
		d[b[1]] = 1 - (1 - b[2]) * a
	end
end
hudFadeV.Changed:Connect(hudFade)
local function setBar(name, value, frac, instant)
	local b = bars[name]
	local pct = math.clamp(frac, 0, 1) * 100
	b.val.Text = tostring(math.floor(value + 0.5))
	if b.tw then
		b.tw:Cancel()
		b.tw = nil
	end
	if instant then
		b.pct.Value = pct
	else
		b.tw = TweenService:Create(b.pct, HUD_FILL, { Value = pct })
		b.tw:Play()
	end
	b.val.TextColor3 = pct < 15 and CREAM:Lerp(HUD_COLORS[b.name], 0.7) or CREAM
	local low = pct < 15
	if low ~= b.low then
		b.low = low
		if b.ptw then
			b.ptw:Cancel()
			b.ptw = nil
		end
		b.pulse.Value = 0
		if low then
			b.ptw = TweenService:Create(b.pulse, HUD_PULSE, { Value = 0.6 })
			b.ptw:Play()
		end
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
	prevB.Position = UDim2.new(0.5, -152, 1, -142)
	nextB.Position = UDim2.new(0.5, 152, 1, -142)
end
local function paintDemo(smooth)
	local n, a, b = demoWho()
	layoutWho(n)
	setTraits(a, b)
	local he, hu, th = math.random(5, 100), math.random(0, 100), math.random(0, 100)
	setBar("Health", he, he / 100, not smooth)
	setBar("Hunger", hu, hu / 100, not smooth)
	setBar("Thirst", th, th / 100, not smooth)
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
local function watch(p, smooth)
	state.watching = p
	local hum = p and p.Character and p.Character:FindFirstChildOfClass("Humanoid")
	if hum then
		workspace.CurrentCamera.CameraSubject = hum
	end
	paintWho(not smooth)
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
	task.spawn(pcall, ContentProvider.PreloadAsync, ContentProvider, { diedImg, snd.death })
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
	fadeTo(gMenu, 0, 0)
	menu.Visible = false
	setShade(0.9, 0.4)
	TweenService:Create(lobbyBg, TweenInfo.new(0.4, QUAD, OUT), { ImageTransparency = 1, BackgroundTransparency = 1 }):Play()
	TweenService:Create(lobbyShade, TweenInfo.new(0.4, QUAD, OUT), { BackgroundTransparency = 1 }):Play()
	if #l > 0 then
		watch(l[1])
	else
		state.watching = nil
		paintDemo()
	end
	if hudFadeTw then
		hudFadeTw:Cancel()
	end
	hudFadeV.Value = 0
	hudFade(0)
	hudGui.Enabled = true
	hudFadeTw = TweenService:Create(hudFadeV, TweenInfo.new(0.4, QUINT, OUT), { Value = 1 })
	hudFadeTw:Play()
	showGroup(gSpec, spec, true, false)
	showGroup(gWho, whoRow, true, false)
end)
local function cycle(d)
	if state.screen ~= "spec" then
		return
	end
	local l = watchList()
	if #l == 0 then
		if CFG.DemoSpectate then
			paintDemo(true)
		end
		return
	end
	local i = table.find(l, state.watching) or 0
	watch(l[(i - 1 + d) % #l + 1], true)
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
	fadeTo(gSpec, 0, 0)
	fadeTo(gWho, 0, 0)
	spec.Visible = false
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
	for _, q in ipairs({ { "RETURNING TO", 27, 535, ACCENT, 0 }, { "The Lobby", 81, 557, WHITE, 0 } }) do
		local l = Instance.new("TextLabel")
		l.BackgroundTransparency = 1
		l.Font = FONT
		l.Text = q[1]
		l.TextSize = q[2]
		l.TextColor3 = q[4]
		l.TextTransparency = 1
		l.AnchorPoint = V2(0.5, 0)
		l.Position = UDim2.new(0.5, 0, 0, q[3] + 14)
		l.Size = UDim2.new(1, 0, 0, q[2])
		l.Parent = c
		local st = Instance.new("UIStroke")
		st.Color = BLACK
		st.Thickness = q[2] >= 40 and 3 or 2
		st.Transparency = 1
		st.Parent = l
		task.delay(q[2] > 50 and 0.37 or 0.25, function()
			if l.Parent then
				local ti = TweenInfo.new(0.6, QUINT, OUT)
				TweenService:Create(l, ti, { TextTransparency = q[5], Position = UDim2.new(0.5, 0, 0, q[3]) }):Play()
				TweenService:Create(st, ti, { Transparency = 0.55 }):Play()
			end
		end)
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
		if a.Id then
			add("rbxassetid://" .. a.Id)
		end
	end
	add(STROKE)
	add("rbxassetid://122287453864385")
	add("rbxassetid://130881451468251")
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
	local inst = {}
	for _, rootObj in ipairs({ playerGui, SoundService }) do
		for _, d in ipairs(rootObj:GetDescendants()) do
			if d:IsA("ImageLabel") or d:IsA("ImageButton") or d:IsA("Sound") then
				table.insert(inst, d)
			end
		end
	end
	pcall(ContentProvider.PreloadAsync, ContentProvider, inst)
	local warm = Instance.new("ScreenGui")
	warm.Name = "HorizonWarmup"
	warm.DisplayOrder = -100
	warm.IgnoreGuiInset = true
	warm.ResetOnSpawn = false
	warm.Parent = playerGui
	for _, d in ipairs(inst) do
		if d:IsA("Sound") then
			local c = d:Clone()
			c.Volume = 0
			c.Looped = false
			c.Parent = SoundService
			c:Play()
			task.delay(1, function()
				c:Destroy()
			end)
		elseif d.Image ~= "" then
			local w = Instance.new("ImageLabel")
			w.BackgroundTransparency = 1
			w.Image = d.Image
			w.ImageTransparency = 0.99
			w.AnchorPoint = V2(1, 1)
			w.Position = UDim2.fromOffset(-20, -20)
			w.Size = UDim2.fromOffset(128, 128)
			w.Parent = warm
		end
	end
	task.delay(3, function()
		warm:Destroy()
	end)
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
