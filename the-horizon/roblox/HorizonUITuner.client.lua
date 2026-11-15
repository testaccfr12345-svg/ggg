local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local target = playerGui:WaitForChild("HorizonInventoryUI")

local old = playerGui:FindFirstChild("HorizonUITuner")
if old then
	old:Destroy()
end

local ACCENT = Color3.fromRGB(233, 185, 73)
local TEXT = Color3.fromRGB(237, 232, 220)
local BG = Color3.fromRGB(16, 21, 19)
local FONT = Enum.Font.GothamMedium
local STEPS = { 1, 2, 5, 10 }

local gui = Instance.new("ScreenGui")
gui.Name = "HorizonUITuner"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 1000
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local function make(className, props, parent)
	local o = Instance.new(className)
	for k, v in pairs(props) do
		o[k] = v
	end
	o.Parent = parent
	return o
end

local function round(parent, r)
	make("UICorner", { CornerRadius = UDim.new(0, r) }, parent)
end

local catcher = make("TextButton", {
	Name = "Catcher",
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Text = "",
	AutoButtonColor = false,
	Visible = false,
	ZIndex = 1,
}, gui)

local highlight = make("Frame", {
	Name = "Highlight",
	BackgroundTransparency = 1,
	Visible = false,
	ZIndex = 2,
}, gui)
make("UIStroke", { Color = ACCENT, Thickness = 2 }, highlight)

local panel = make("Frame", {
	Name = "Panel",
	Position = UDim2.fromOffset(12, 70),
	Size = UDim2.fromOffset(232, 262),
	BackgroundColor3 = BG,
	BackgroundTransparency = 0.05,
	ZIndex = 10,
}, gui)
round(panel, 8)
make("UIStroke", { Color = ACCENT, Thickness = 1, Transparency = 0.4 }, panel)

local function label(parent, text, x, y, w, h, size)
	return make("TextLabel", {
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(w, h),
		BackgroundTransparency = 1,
		Font = FONT,
		Text = text,
		TextSize = size or 12,
		TextColor3 = TEXT,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextTruncate = Enum.TextTruncate.AtEnd,
		ZIndex = 11,
	}, parent)
end

local function button(parent, text, x, y, w, h)
	local b = make("TextButton", {
		Position = UDim2.fromOffset(x, y),
		Size = UDim2.fromOffset(w, h),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.88,
		AutoButtonColor = true,
		Font = FONT,
		Text = text,
		TextSize = 12,
		TextColor3 = TEXT,
		ZIndex = 11,
	}, parent)
	round(b, 5)
	return b
end

local titleBar = make("Frame", {
	Size = UDim2.new(1, 0, 0, 24),
	BackgroundTransparency = 1,
	ZIndex = 11,
}, panel)
label(titleBar, "UI Tuner  (drag here)", 8, 0, 170, 24, 12).TextColor3 = ACCENT
local minButton = button(titleBar, "–", 204, 3, 22, 18)

local body = make("Frame", {
	Position = UDim2.fromOffset(0, 24),
	Size = UDim2.new(1, 0, 1, -24),
	BackgroundTransparency = 1,
	ZIndex = 11,
}, panel)

local selectedLabel = label(body, "Nothing selected", 8, 0, 216, 16, 11)
local infoLabel = label(body, "", 8, 16, 216, 14, 10)
infoLabel.TextTransparency = 0.35

local pickButton = button(body, "Pick", 8, 34, 50, 24)
local dragButton = button(body, "Drag", 62, 34, 50, 24)
local upButton = button(body, "Parent", 116, 34, 54, 24)
local stepButton = button(body, "Step 1", 174, 34, 50, 24)

local selected = nil
local originals = {}
local stepIndex = 1
local mode = "none"

local function step()
	return STEPS[stepIndex]
end

local function remember(o)
	if originals[o] then
		return
	end
	local entry = { Position = o.Position, Size = o.Size }
	if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then
		entry.TextSize = o.TextSize
	end
	local scale = o:FindFirstChildOfClass("UIScale")
	if scale then
		entry.Scale = scale.Scale
	end
	originals[o] = entry
end

local function pathOf(o)
	local parts = {}
	local cur = o
	while cur and cur ~= target do
		local name = cur.Name
		local parent = cur.Parent
		if parent then
			local same, index = 0, 0
			for _, c in ipairs(parent:GetChildren()) do
				if c.Name == name then
					same += 1
					if c == cur then
						index = same
					end
				end
			end
			if same > 1 then
				name = name .. "#" .. index
			end
		end
		table.insert(parts, 1, name)
		cur = parent
	end
	return table.concat(parts, "/")
end

local function udim2(u)
	return string.format("{%g,%g},{%g,%g}", u.X.Scale, u.X.Offset, u.Y.Scale, u.Y.Offset)
end

local function textOf(o)
	if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then
		if o.Text ~= "" then
			return o.Text
		end
	end
	return nil
end

local function refreshInfo()
	if not selected or not selected.Parent then
		selected = nil
		selectedLabel.Text = "Nothing selected"
		infoLabel.Text = ""
		return
	end
	local t = textOf(selected)
	selectedLabel.Text = selected.Name .. (t and (' "' .. t .. '"') or "")
	local pos, size = selected.Position, selected.Size
	local extra = ""
	if selected:IsA("TextLabel") or selected:IsA("TextButton") or selected:IsA("TextBox") then
		extra = "  T" .. selected.TextSize
	end
	infoLabel.Text = string.format("P %g,%g  S %g,%g%s", pos.X.Offset, pos.Y.Offset, size.X.Offset, size.Y.Offset, extra)
end

local function selectObject(o)
	selected = o
	refreshInfo()
end

local function setMode(m)
	mode = mode == m and "none" or m
	catcher.Visible = mode ~= "none"
	pickButton.BackgroundTransparency = mode == "pick" and 0.6 or 0.88
	dragButton.BackgroundTransparency = mode == "drag" and 0.6 or 0.88
	pickButton.TextColor3 = mode == "pick" and ACCENT or TEXT
	dragButton.TextColor3 = mode == "drag" and ACCENT or TEXT
end

local function effectiveScale(o)
	local s = 1
	local cur = o.Parent
	while cur and cur ~= target do
		local u = cur:FindFirstChildOfClass("UIScale")
		if u then
			s *= u.Scale
		end
		cur = cur.Parent
	end
	return s
end

local function nudge(kind, dx, dy)
	local o = selected
	if not o then
		return
	end
	remember(o)
	if kind == "pos" then
		local p = o.Position
		o.Position = UDim2.new(p.X.Scale, p.X.Offset + dx, p.Y.Scale, p.Y.Offset + dy)
	elseif kind == "size" then
		local s = o.Size
		o.Size = UDim2.new(s.X.Scale, s.X.Offset + dx, s.Y.Scale, s.Y.Offset + dy)
	elseif kind == "text" then
		if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then
			o.TextSize = math.clamp(o.TextSize + dx, 1, 100)
		end
	elseif kind == "scale" then
		local u = o:FindFirstChildOfClass("UIScale")
		if not u then
			u = Instance.new("UIScale")
			u.Parent = o
		end
		u.Scale = math.max(0.05, math.floor((u.Scale + dx * 0.01) * 100 + 0.5) / 100)
	end
	refreshInfo()
end

local function holdButton(b, fn)
	local holding = false
	b.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		holding = true
		fn()
		task.delay(0.35, function()
			while holding do
				fn()
				task.wait(0.06)
			end
		end)
	end)
	b.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			holding = false
		end
	end)
	b.MouseLeave:Connect(function()
		holding = false
	end)
end

local rows = {
	{ "Move X", "pos", 1, 0 },
	{ "Move Y", "pos", 0, 1 },
	{ "Width", "size", 1, 0 },
	{ "Height", "size", 0, 1 },
	{ "Both size", "size", 1, 1 },
	{ "Text size", "text", 1, 0 },
	{ "Scale %", "scale", 1, 0 },
}
for i, r in ipairs(rows) do
	local y = 62 + (i - 1) * 22
	label(body, r[1], 8, y, 90, 20, 12)
	local minus = button(body, "–", 120, y, 50, 20)
	local plus = button(body, "+", 174, y, 50, 20)
	holdButton(minus, function()
		nudge(r[2], -r[3] * step(), -r[4] * step())
	end)
	holdButton(plus, function()
		nudge(r[2], r[3] * step(), r[4] * step())
	end)
end

local resetButton = button(body, "Reset this", 8, 216, 70, 18)
local resetAllButton = button(body, "Reset all", 82, 216, 64, 18)
local copyButton = button(body, "Copy all", 150, 216, 74, 18)
copyButton.BackgroundColor3 = ACCENT
copyButton.BackgroundTransparency = 0
copyButton.TextColor3 = Color3.fromRGB(27, 26, 20)

local exportFrame = make("Frame", {
	Name = "Export",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.new(0.8, 0, 0.75, 0),
	BackgroundColor3 = BG,
	BackgroundTransparency = 0.02,
	Visible = false,
	ZIndex = 20,
}, gui)
round(exportFrame, 8)
make("UIStroke", { Color = ACCENT, Thickness = 1 }, exportFrame)
local exportTitle = label(exportFrame, "Select all of this text, copy it, and send it", 10, 4, 400, 22, 12)
exportTitle.ZIndex = 21
local closeExport = button(exportFrame, "Close", 0, 4, 60, 22)
closeExport.AnchorPoint = Vector2.new(1, 0)
closeExport.Position = UDim2.new(1, -8, 0, 4)
closeExport.ZIndex = 21
local exportScroll = make("ScrollingFrame", {
	Position = UDim2.fromOffset(8, 30),
	Size = UDim2.new(1, -16, 1, -38),
	BackgroundTransparency = 1,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
	ScrollBarThickness = 6,
	ZIndex = 21,
}, exportFrame)
local exportBox = make("TextBox", {
	Size = UDim2.new(1, -8, 0, 0),
	AutomaticSize = Enum.AutomaticSize.Y,
	BackgroundTransparency = 1,
	ClearTextOnFocus = false,
	TextEditable = true,
	MultiLine = true,
	TextWrapped = true,
	Font = Enum.Font.Code,
	TextSize = 12,
	TextColor3 = TEXT,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
	Text = "",
	ZIndex = 21,
}, exportScroll)

local function buildExport()
	local lines = {}
	for o, orig in pairs(originals) do
		if o.Parent then
			local parts = {}
			if o.Position ~= orig.Position then
				table.insert(parts, "Position " .. udim2(orig.Position) .. " -> " .. udim2(o.Position))
			end
			if o.Size ~= orig.Size then
				table.insert(parts, "Size " .. udim2(orig.Size) .. " -> " .. udim2(o.Size))
			end
			if orig.TextSize and o.TextSize ~= orig.TextSize then
				table.insert(parts, "TextSize " .. orig.TextSize .. " -> " .. o.TextSize)
			end
			local u = o:FindFirstChildOfClass("UIScale")
			local nowScale = u and u.Scale or 1
			if (orig.Scale or 1) ~= nowScale then
				table.insert(parts, "Scale " .. (orig.Scale or 1) .. " -> " .. nowScale)
			end
			if #parts > 0 then
				local t = textOf(o)
				table.insert(lines, pathOf(o) .. (t and (' "' .. t .. '"') or "") .. " | " .. table.concat(parts, " | "))
			end
		end
	end
	table.sort(lines)
	if #lines == 0 then
		return "No changes yet"
	end
	local cam = workspace.CurrentCamera
	local vp = cam and cam.ViewportSize or Vector2.zero
	table.insert(lines, 1, string.format("HorizonUITuner export, screen %dx%d", vp.X, vp.Y))
	return table.concat(lines, "\n")
end

local function pickAt(pos)
	local list = playerGui:GetGuiObjectsAtPosition(pos.X, pos.Y)
	for _, o in ipairs(list) do
		if o:IsDescendantOf(target) and o.Name ~= "Dim" and o.Name ~= "MouseUnlock" then
			return o
		end
	end
	return nil
end

local dragging = nil
catcher.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	if mode == "pick" then
		local o = pickAt(input.Position)
		if o then
			selectObject(o)
		end
	elseif mode == "drag" and selected then
		remember(selected)
		dragging = { start = input.Position, pos = selected.Position, scale = effectiveScale(selected) }
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if not dragging or not selected then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	local d = (input.Position - dragging.start) / math.max(dragging.scale, 0.01)
	local p = dragging.pos
	selected.Position = UDim2.new(p.X.Scale, p.X.Offset + math.floor(d.X + 0.5), p.Y.Scale, p.Y.Offset + math.floor(d.Y + 0.5))
	refreshInfo()
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = nil
	end
end)

local panelDrag = nil
titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		panelDrag = { start = input.Position, pos = panel.Position }
		local c
		c = input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				panelDrag = nil
				c:Disconnect()
			end
		end)
	end
end)
UserInputService.InputChanged:Connect(function(input)
	if not panelDrag then
		return
	end
	if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end
	local d = input.Position - panelDrag.start
	panel.Position = UDim2.new(panelDrag.pos.X.Scale, panelDrag.pos.X.Offset + d.X, panelDrag.pos.Y.Scale, panelDrag.pos.Y.Offset + d.Y)
end)

pickButton.Activated:Connect(function()
	setMode("pick")
end)
dragButton.Activated:Connect(function()
	setMode("drag")
end)
upButton.Activated:Connect(function()
	if selected and selected.Parent and selected.Parent ~= target then
		selectObject(selected.Parent)
	end
end)
stepButton.Activated:Connect(function()
	stepIndex = stepIndex % #STEPS + 1
	stepButton.Text = "Step " .. step()
end)

local function restore(o)
	local orig = originals[o]
	if not orig then
		return
	end
	o.Position = orig.Position
	o.Size = orig.Size
	if orig.TextSize then
		o.TextSize = orig.TextSize
	end
	local u = o:FindFirstChildOfClass("UIScale")
	if u then
		if orig.Scale then
			u.Scale = orig.Scale
		else
			u:Destroy()
		end
	end
	originals[o] = nil
end

resetButton.Activated:Connect(function()
	if selected then
		restore(selected)
		refreshInfo()
	end
end)
resetAllButton.Activated:Connect(function()
	for o in pairs(originals) do
		if o.Parent then
			restore(o)
		end
	end
	table.clear(originals)
	refreshInfo()
end)
copyButton.Activated:Connect(function()
	exportBox.Text = buildExport()
	exportFrame.Visible = true
end)
closeExport.Activated:Connect(function()
	exportFrame.Visible = false
end)

local minimized = false
minButton.Activated:Connect(function()
	minimized = not minimized
	body.Visible = not minimized
	panel.Size = UDim2.fromOffset(232, minimized and 24 or 262)
	minButton.Text = minimized and "+" or "–"
end)

RunService.RenderStepped:Connect(function()
	if selected and selected.Parent and selected:IsA("GuiObject") and selected.Visible then
		highlight.Visible = true
		highlight.Position = UDim2.fromOffset(selected.AbsolutePosition.X, selected.AbsolutePosition.Y)
		highlight.Size = UDim2.fromOffset(selected.AbsoluteSize.X, selected.AbsoluteSize.Y)
	else
		highlight.Visible = false
	end
end)
