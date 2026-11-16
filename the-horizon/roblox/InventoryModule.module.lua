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

function Motion:toast(id, message)
	if not self.toastFrame then
		local frame = new("Frame", {
			Name = "Toast",
			AnchorPoint = Vector2.new(0.5, 0),
			Size = UDim2.fromOffset(0, 34),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundColor3 = Color3.fromRGB(16, 21, 19),
			BackgroundTransparency = 1,
			Visible = false,
			ZIndex = 101,
		}, self.layer)
		new("UICorner", { CornerRadius = UDim.new(0, 17) }, frame)
		local border = new("UIStroke", { Color = self.CONFIG.Text, Thickness = 1, Transparency = 1, ApplyStrokeMode = Enum.ApplyStrokeMode.Border }, frame)
		new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 14) }, frame)
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8),
		}, frame)
		local icon = new("ImageLabel", { LayoutOrder = 1, Size = UDim2.fromOffset(24, 24), BackgroundTransparency = 1, ScaleType = Enum.ScaleType.Fit, ZIndex = 102 }, frame)
		local label = new("TextLabel", {
			LayoutOrder = 2,
			Size = UDim2.fromOffset(0, 34),
			AutomaticSize = Enum.AutomaticSize.X,
			BackgroundTransparency = 1,
			FontFace = Font.fromEnum(self.CONFIG.FontEnum),
			TextSize = math.floor(18 * self.CONFIG.FontScale + 0.5),
			TextColor3 = self.CONFIG.Text,
			ZIndex = 102,
		}, frame)
		local alpha = new("NumberValue", { Value = 0 }, frame)
		alpha.Changed:Connect(function(a)
			frame.BackgroundTransparency = 1 - 0.9 * a
			border.Transparency = 1 - 0.14 * a
			label.TextTransparency = 1 - a
			icon.ImageTransparency = 1 - a
		end)
		self.toastFrame = frame
		self.toastParts = { icon = icon, label = label, alpha = alpha, scale = new("UIScale", {}, frame), token = 0 }
	end
	local parts = self.toastParts
	local item = self.ITEMS[id]
	parts.icon.Image = item and item.Image or ""
	parts.label.Text = message
	local sc = self.getScale()
	parts.scale.Scale = sc
	self.toastFrame.Position = UDim2.new(0.5, 0, 0, 18 * sc)
	self.toastFrame.Visible = true
	parts.token += 1
	local token = parts.token
	tween(parts.alpha, 0.15, { Value = 1 }, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	task.delay(1.9, function()
		if token ~= parts.token then
			return
		end
		local out = tween(parts.alpha, 0.3, { Value = 0 }, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
		out.Completed:Once(function(state)
			if state == Enum.PlaybackState.Completed and token == parts.token then
				self.toastFrame.Visible = false
			end
		end)
	end)
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

function Motion:attachPC(api)
	local UserInputService = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	local GuiService = game:GetService("GuiService")
	local ITEMS = self.ITEMS
	local motion = self
	local pc = { marks = {} }
	local cursor = nil
	local cursorPic = nil
	local mousePos = Vector2.zero
	local spread = nil
	local lastPick, lastPickId = 0, nil

	local function updateMouse()
		mousePos = UserInputService:GetMouseLocation() - GuiService:GetGuiInset()
	end

	local function placeCursorPic()
		if cursorPic then
			local p = motion:toLocal(mousePos)
			cursorPic.Position = UDim2.fromOffset(p.X, p.Y)
		end
	end

	local function setCursor(id, n)
		if cursorPic then
			cursorPic:Destroy()
			cursorPic = nil
		end
		cursor = (id and n and n > 0) and { id = id, n = n } or nil
		if cursor then
			cursorPic = motion:picture(cursor.id, api.backpackSlots[1].Icon.Image.AbsoluteSize, 0, cursor.n)
			placeCursorPic()
		end
	end

	local function hoverTarget()
		return motion:hit(mousePos, api.slotLookup, api.gui)
	end

	local function placeOne(i, button)
		local entry = api.bp[i]
		if button == "left" then
			if not entry then
				api.bp[i] = cursor
				setCursor(nil)
			elseif entry.id == cursor.id then
				entry.n += cursor.n
				setCursor(nil)
			else
				api.bp[i] = cursor
				setCursor(entry.id, entry.n)
			end
		else
			if not entry then
				api.bp[i] = { id = cursor.id, n = 1 }
			elseif entry.id == cursor.id then
				entry.n += 1
			else
				return
			end
			setCursor(cursor.id, cursor.n - 1)
		end
	end

	local function finishSpread()
		local s = spread
		spread = nil
		pc.marks = {}
		if not cursor then
			api.changed()
			return
		end
		if #s.slots == 1 then
			placeOne(s.slots[1], s.button)
		else
			local valid = {}
			for _, i in ipairs(s.slots) do
				local entry = api.bp[i]
				if not entry or entry.id == cursor.id then
					table.insert(valid, i)
				end
			end
			local per = s.button == "left" and math.floor(cursor.n / math.max(#valid, 1)) or 1
			local left = cursor.n
			for _, i in ipairs(valid) do
				if left < per or per < 1 then
					break
				end
				local entry = api.bp[i]
				if entry then
					entry.n += per
				else
					api.bp[i] = { id = cursor.id, n = per }
				end
				left -= per
			end
			setCursor(cursor.id, left)
		end
		api.changed()
	end

	local function gather()
		for i, entry in pairs(api.bp) do
			if entry and entry.id == cursor.id then
				cursor.n += entry.n
				api.bp[i] = nil
			end
		end
		setCursor(cursor.id, cursor.n)
		api.changed()
	end

	local function equipClick(slotName, shift)
		local worn = api.worn[slotName]
		if shift then
			if not cursor and worn then
				api.unequip(slotName)
			end
			return true
		end
		if cursor then
			if ITEMS[cursor.id].Wear ~= slotName then
				return true
			end
			if not worn then
				api.worn[slotName] = { id = cursor.id, n = 1 }
				setCursor(cursor.id, cursor.n - 1)
			elseif cursor.n == 1 then
				api.worn[slotName] = { id = cursor.id, n = 1 }
				setCursor(worn.id, worn.n)
			end
		elseif worn then
			api.worn[slotName] = nil
			setCursor(worn.id, worn.n)
		end
		api.changed()
		return true
	end

	function pc.holding()
		return cursor ~= nil
	end

	function pc.press(target, button, input)
		if not api.isOpen() then
			return false
		end
		updateMouse()
		local shift = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) or UserInputService:IsKeyDown(Enum.KeyCode.RightShift)
		if target.equip then
			return equipClick(target.equip, shift)
		end
		if target.area == "hb" then
			return cursor ~= nil or button == "right"
		end
		local i = target.i
		local entry = api.bp[i]
		if shift and not cursor then
			if entry and ITEMS[entry.id].Wear then
				api.equip(i)
			end
			return true
		end
		if cursor then
			if button == "left" and lastPickId == cursor.id and os.clock() - lastPick < 0.35 then
				lastPick = 0
				gather()
				return true
			end
			spread = { button = button, slots = { i }, set = { [i] = true } }
			pc.marks = { ["bp" .. i] = true }
			api.refresh()
			return true
		end
		if button == "right" then
			if entry then
				local half = math.ceil(entry.n / 2)
				entry.n -= half
				if entry.n <= 0 then
					api.bp[i] = nil
				end
				setCursor(entry.id, half)
				api.changed()
			end
			return true
		end
		return false
	end

	function pc.click(area, i)
		if area ~= "bp" or cursor then
			return
		end
		local entry = api.bp[i]
		if not entry then
			return
		end
		updateMouse()
		api.bp[i] = nil
		setCursor(entry.id, entry.n)
		lastPick, lastPickId = os.clock(), entry.id
		api.changed()
	end

	function pc.close()
		spread = nil
		pc.marks = {}
		if cursor then
			local id, n = cursor.id, cursor.n
			setCursor(nil)
			api.addItem(id, n)
		end
	end

	api.dim.InputBegan:Connect(function(input)
		if not cursor or not api.isOpen() then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			setCursor(nil)
			api.changed()
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			setCursor(cursor.id, cursor.n - 1)
			api.changed()
		end
	end)

	UserInputService.InputBegan:Connect(function(input, processed)
		if input.KeyCode ~= Enum.KeyCode.Q or not api.isOpen() or cursor or UserInputService:GetFocusedTextBox() then
			return
		end
		updateMouse()
		local target = hoverTarget()
		if not target or target.equip then
			return
		end
		local list = target.area == "bp" and api.bp or api.hb
		local entry = list[target.i]
		if not entry then
			return
		end
		local ctrl = UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) or UserInputService:IsKeyDown(Enum.KeyCode.RightControl)
		local n = ctrl and entry.n or 1
		entry.n -= n
		if entry.n <= 0 then
			list[target.i] = nil
		end
		api.changed()
	end)

	UserInputService.InputEnded:Connect(function(input)
		if not spread then
			return
		end
		local t = input.UserInputType
		if (spread.button == "left" and t == Enum.UserInputType.MouseButton1) or (spread.button == "right" and t == Enum.UserInputType.MouseButton2) then
			finishSpread()
		end
	end)

	RunService.RenderStepped:Connect(function()
		if not cursor and not spread then
			if pc.hovering then
				pc.hovering = false
				api.setHover(nil)
			end
			return
		end
		pc.hovering = true
		updateMouse()
		placeCursorPic()
		local target = hoverTarget()
		local key = nil
		if target then
			if target.equip then
				if cursor and ITEMS[cursor.id].Wear == target.equip then
					key = "eq" .. target.equip
				end
			elseif target.area == "bp" then
				key = "bp" .. target.i
			end
		end
		api.setHover(key)
		if spread and cursor and target and target.area == "bp" and not spread.set[target.i] then
			local entry = api.bp[target.i]
			if (not entry or entry.id == cursor.id) and #spread.slots < cursor.n then
				spread.set[target.i] = true
				table.insert(spread.slots, target.i)
				pc.marks["bp" .. target.i] = true
				api.refresh()
			end
		end
	end)

	return pc
end

return Motion
