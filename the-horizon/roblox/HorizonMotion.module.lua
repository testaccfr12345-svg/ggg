local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Motion = {}
Motion.__index = Motion

local function new(className, props, parent)
	local object = Instance.new(className)
	for key, value in pairs(props) do
		object[key] = value
	end
	object.Parent = parent
	return object
end

local function tween(object, duration, props, style, direction)
	local t = TweenService:Create(object, TweenInfo.new(duration, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

function Motion.new(gui, CONFIG, ITEMS, settings, getScale)
	local self = setmetatable({}, Motion)
	self.CONFIG = CONFIG
	self.ITEMS = ITEMS
	self.S = settings
	self.getScale = getScale
	self.playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	self.flyers = {}
	self.layer = new("Frame", {
		Name = "Motion",
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Active = false,
		ZIndex = 100,
	}, gui)

	local coral = Color3.fromRGB(244, 164, 124)
	self.pill = new("Frame", {
		Name = "DropPill",
		AnchorPoint = Vector2.new(0.5, 0),
		Size = UDim2.fromOffset(0, 34),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = Color3.fromRGB(16, 21, 19),
		BackgroundTransparency = 0.1,
		Visible = false,
		ZIndex = 101,
	}, self.layer)
	new("UICorner", { CornerRadius = UDim.new(0, 17) }, self.pill)
	local border = new("UIStroke", { Color = coral, Thickness = 1.5, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, self.pill)
	local keys = {}
	for dash = 0, 4 do
		local start = dash / 5
		table.insert(keys, NumberSequenceKeypoint.new(start, 0))
		table.insert(keys, NumberSequenceKeypoint.new(start + 0.099, 0))
		table.insert(keys, NumberSequenceKeypoint.new(start + 0.1, 1))
		table.insert(keys, NumberSequenceKeypoint.new(dash == 4 and 1 or start + 0.199, 1))
	end
	new("UIGradient", { Transparency = NumberSequence.new(keys) }, border)
	new("UIPadding", { PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16) }, self.pill)
	self.pillText = new("TextLabel", {
		Size = UDim2.fromScale(0, 1),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundTransparency = 1,
		FontFace = Font.fromEnum(CONFIG.FontEnum),
		TextSize = math.floor(18 * CONFIG.FontScale + 0.5),
		TextColor3 = coral,
		Text = "",
		ZIndex = 102,
	}, self.pill)
	self.pillScale = new("UIScale", {}, self.pill)
	return self
end

function Motion:toLocal(absolute)
	return absolute - self.layer.AbsolutePosition
end

function Motion:picture(id, size, transparency, count)
	local item = self.ITEMS[id]
	local holder = new("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromOffset(size.X, size.Y),
		BackgroundTransparency = 1,
		Active = false,
		ZIndex = 110,
	}, self.layer)
	if item and item.Image ~= "" then
		new("ImageLabel", {
			Name = "Shadow",
			Position = UDim2.new(0, 0, 0, 4),
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Image = item.Image,
			ImageColor3 = Color3.new(0, 0, 0),
			ImageTransparency = 0.7,
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = 110,
		}, holder)
		new("ImageLabel", {
			Name = "Picture",
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			Image = item.Image,
			ImageTransparency = transparency or 0,
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = 111,
		}, holder)
	else
		new("TextLabel", {
			Size = UDim2.fromScale(1, 1),
			BackgroundTransparency = 1,
			FontFace = Font.fromEnum(self.CONFIG.FontEnum),
			TextScaled = true,
			TextColor3 = self.CONFIG.Text,
			Text = item and item.Name or "",
			ZIndex = 111,
		}, holder)
	end
	if count and count > 1 then
		new("TextLabel", {
			Name = "Count",
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.fromScale(1, 1),
			Size = UDim2.fromScale(0.6, 0.35),
			BackgroundTransparency = 1,
			FontFace = Font.fromEnum(self.CONFIG.FontEnum),
			TextScaled = true,
			TextColor3 = self.CONFIG.Text,
			TextStrokeTransparency = 0.6,
			TextXAlignment = Enum.TextXAlignment.Right,
			Text = tostring(count),
			ZIndex = 112,
		}, holder)
	end
	return holder
end

function Motion:animate(holder, toCenter, toSize, duration, onLand, extra)
	local entry = { holder = holder, onLand = onLand, done = false }
	local props = { Position = UDim2.fromOffset(toCenter.X, toCenter.Y), Size = UDim2.fromOffset(toSize.X, toSize.Y) }
	entry.tween = tween(holder, duration, props)
	entry.extra = extra
	entry.fades = {}
	local shadow = holder:FindFirstChild("Shadow")
	if shadow then
		table.insert(entry.fades, tween(shadow, duration * 0.8, { ImageTransparency = 1 }, Enum.EasingStyle.Sine, Enum.EasingDirection.Out))
	end
	local count = holder:FindFirstChild("Count")
	if count then
		table.insert(entry.fades, tween(count, duration * 0.6, { TextTransparency = 1, TextStrokeTransparency = 1 }, Enum.EasingStyle.Sine, Enum.EasingDirection.Out))
	end
	table.insert(self.flyers, entry)
	entry.tween.Completed:Once(function(state)
		if state == Enum.PlaybackState.Completed then
			self:land(entry, false)
		end
	end)
	return entry
end

function Motion:land(entry, snap)
	if entry.done then
		return
	end
	entry.done = true
	entry.tween:Cancel()
	for _, t in ipairs(entry.fades) do
		t:Cancel()
	end
	if entry.extra then
		entry.extra:Cancel()
	end
	entry.holder:Destroy()
	local index = table.find(self.flyers, entry)
	if index then
		table.remove(self.flyers, index)
	end
	if entry.onLand then
		entry.onLand(snap)
	end
end

function Motion:finishAll()
	for _, entry in ipairs(table.clone(self.flyers)) do
		self:land(entry, true)
	end
end

function Motion:fly(id, fromAbs, toAbs, size, onLand)
	local from = self:toLocal(fromAbs)
	local to = self:toLocal(toAbs)
	local holder = self:picture(id, size * self.S.FLY_START)
	holder.Position = UDim2.fromOffset(from.X, from.Y)
	self:animate(holder, to, size, self.S.FLY_TIME, onLand)
end

function Motion:pop(scale)
	local k = self.S.POP_SCALE
	scale.Scale = 1 - 0.14 * k
	local up = tween(scale, self.S.POP_TIME * 0.5, { Scale = 1 + 0.08 * k }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	up.Completed:Once(function(state)
		if state == Enum.PlaybackState.Completed then
			tween(scale, self.S.POP_TIME * 0.5, { Scale = 1 }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
		end
	end)
end

function Motion:ghostStart(id, size, count)
	self:ghostCancel()
	self.ghostSize = size * self.S.DRAG_SCALE
	self.ghost = self:picture(id, self.ghostSize, 0.1, count)
	for _, child in ipairs(self.ghost:GetChildren()) do
		if child:IsA("ImageLabel") then
			local target = child.ImageTransparency
			child.ImageTransparency = 1
			tween(child, 0.12, { ImageTransparency = target }, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		elseif child:IsA("TextLabel") then
			local target, strokeTarget = child.TextTransparency, child.TextStrokeTransparency
			child.TextTransparency = 1
			child.TextStrokeTransparency = 1
			tween(child, 0.12, { TextTransparency = target, TextStrokeTransparency = strokeTarget }, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		end
	end
end

function Motion:ghostMove(absolute, touch)
	if not self.ghost then
		return
	end
	local p = self:toLocal(absolute)
	if touch then
		p -= Vector2.new(0, self.S.DRAG_TOUCH_UP * self.getScale())
	end
	self.ghost.Position = UDim2.fromOffset(p.X, p.Y)
end

function Motion:ghostCancel()
	if self.ghost then
		self.ghost:Destroy()
		self.ghost = nil
	end
end

function Motion:ghostTo(toAbs, size, duration, onLand)
	local holder = self.ghost
	self.ghost = nil
	if not holder then
		if onLand then
			onLand(true)
		end
		return
	end
	self:animate(holder, self:toLocal(toAbs), size, duration, onLand)
end

function Motion:ghostDrop()
	local holder = self.ghost
	self.ghost = nil
	if not holder then
		return
	end
	local fades = {}
	for _, child in ipairs(holder:GetChildren()) do
		if child:IsA("ImageLabel") then
			table.insert(fades, tween(child, 0.15, { ImageTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
		elseif child:IsA("TextLabel") then
			table.insert(fades, tween(child, 0.15, { TextTransparency = 1, TextStrokeTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.Out))
		end
	end
	local size = holder.Size
	local center = Vector2.new(holder.Position.X.Offset, holder.Position.Y.Offset)
	local entry = self:animate(holder, center, Vector2.new(size.X.Offset, size.Y.Offset) * 0.6, 0.15, nil)
	entry.extra = { Cancel = function()
		for _, t in ipairs(fades) do
			t:Cancel()
		end
	end }
end

function Motion:pillShow(text)
	self.pillText.Text = text
	local sc = self.getScale()
	self.pillScale.Scale = sc
	self.pill.Position = UDim2.new(0.5, 0, 0, 18 * sc)
	self.pill.Visible = true
end

function Motion:pillHide()
	self.pill.Visible = false
end

function Motion:hit(absolute, lookup, root)
	for _, object in ipairs(self.playerGui:GetGuiObjectsAtPosition(absolute.X, absolute.Y)) do
		local current = object
		while current and current ~= root do
			if lookup[current] then
				return lookup[current]
			end
			current = current.Parent
		end
	end
	return nil
end

return Motion
