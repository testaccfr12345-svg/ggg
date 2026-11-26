local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local function escapeRich(str)
	return (str:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;"))
end

local function spacedRich(raw, px)
	px = math.max(0, px or 0)
	local chars = {}
	for _, code in utf8.codes(raw) do
		table.insert(chars, escapeRich(utf8.char(code)))
	end
	if px <= 0 or #chars < 2 then
		return table.concat(chars)
	end
	local unit = px * 5
	local out = { chars[1] }
	for i = 2, #chars do
		local g = math.floor((i - 1) * unit + 0.5) - math.floor((i - 2) * unit + 0.5)
		if g > 0 then
			table.insert(out, '<font size="' .. g .. '"> </font>')
		end
		table.insert(out, chars[i])
	end
	return table.concat(out)
end

local function renderSpacing(label)
	local out = spacedRich(label:GetAttribute("RawText") or "", label:GetAttribute("LetterSpacing") or 0)
	label:SetAttribute("RenderedText", out)
	label.Text = out
end

local function letterSpacing(label, px)
	if label:GetAttribute("RawText") == nil then
		label:SetAttribute("RawText", label.Text)
		label.RichText = true
		label:GetPropertyChangedSignal("Text"):Connect(function()
			if label.Text ~= label:GetAttribute("RenderedText") then
				label:SetAttribute("RawText", label.Text)
				renderSpacing(label)
			end
		end)
	end
	label:SetAttribute("LetterSpacing", math.max(0, math.floor(px * 10 + 0.5) / 10))
	renderSpacing(label)
end

local function startTuner(gui, CONFIG, ITEMS)
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local targets = typeof(gui) == "Instance" and { gui } or gui
	local function isTarget(x)
		for _, t in ipairs(targets) do
			if x == t then
				return true
			end
		end
		return false
	end
	local function ownerOf(o)
		for _, t in ipairs(targets) do
			if o:IsDescendantOf(t) then
				return t
			end
		end
		return nil
	end
	local oldTuner = playerGui:FindFirstChild("HorizonUITuner")
	if oldTuner then
		oldTuner:Destroy()
	end

	local T_ACCENT = Color3.fromRGB(233, 185, 73)
	local T_TEXT = Color3.fromRGB(237, 232, 220)
	local T_BG = Color3.fromRGB(16, 21, 19)
	local T_FONT = Enum.Font.GothamMedium
	local T_STEPS = { 1, 0.1, 2, 5, 10 }
	local W = 236

	local tunerGui = Instance.new("ScreenGui")
	tunerGui.Name = "HorizonUITuner"
	tunerGui.ResetOnSpawn = false
	tunerGui.IgnoreGuiInset = true
	tunerGui.DisplayOrder = 1000
	tunerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	tunerGui.Parent = playerGui

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
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		Visible = false,
		ZIndex = 1,
	}, tunerGui)
	local highlight = make("Frame", { BackgroundTransparency = 1, Visible = false, ZIndex = 2 }, tunerGui)
	make("UIStroke", { Color = T_ACCENT, Thickness = 2 }, highlight)

	local panel = make("Frame", {
		Position = UDim2.fromOffset(12, 60),
		Size = UDim2.fromOffset(W, 316),
		BackgroundColor3 = T_BG,
		BackgroundTransparency = 0.05,
		ZIndex = 10,
	}, tunerGui)
	round(panel, 8)
	make("UIStroke", { Color = T_ACCENT, Thickness = 1, Transparency = 0.4 }, panel)

	local function label(parent, text, x, y, w, h, size)
		return make("TextLabel", {
			Position = UDim2.fromOffset(x, y),
			Size = UDim2.fromOffset(w, h),
			BackgroundTransparency = 1,
			Font = T_FONT,
			Text = text,
			TextSize = size or 12,
			TextColor3 = T_TEXT,
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
			Font = T_FONT,
			Text = text,
			TextSize = 12,
			TextColor3 = T_TEXT,
			ZIndex = 11,
		}, parent)
		round(b, 5)
		return b
	end

	local titleBar = make("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, ZIndex = 11 }, panel)
	label(titleBar, "UI Tuner  (drag here)", 8, 0, 170, 24, 12).TextColor3 = T_ACCENT
	local minButton = button(titleBar, "–", W - 28, 3, 22, 18)

	local body = make("Frame", {
		Position = UDim2.fromOffset(0, 24),
		Size = UDim2.new(1, 0, 1, -24),
		BackgroundTransparency = 1,
		ZIndex = 11,
	}, panel)

	local pickButton = button(body, "Pick", 8, 0, 52, 24)
	local dragButton = button(body, "Drag", 64, 0, 52, 24)
	local upButton = button(body, "Bigger part", 120, 0, 74, 24)
	local stepButton = button(body, "x1", 198, 0, 30, 24)

	local nameLabel = label(body, "Tap Pick, then tap something", 8, 28, W - 16, 16, 12)
	nameLabel.TextColor3 = T_ACCENT
	local changeLabel = label(body, "", 8, 44, W - 16, 30, 11)
	changeLabel.TextWrapped = true
	changeLabel.TextTruncate = Enum.TextTruncate.None
	changeLabel.TextYAlignment = Enum.TextYAlignment.Top

	local selected = nil
	local originals = {}
	local stepIndex = 1
	local mode = "none"

	local function step()
		return T_STEPS[stepIndex]
	end
	local function isText(o)
		return o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox")
	end

	local SLOT_NAMES = { Helmet = true, Chest = true, Gloves = true, Legs = true, Boots = true }
	local NAMED = {
		Holder = "YOU DIED",
		Tip = "Tip",
		Notification = "Notification",
		RespawnButton = "Respawn button",
		SpectateButton = "Spectate button",
		LobbyButton = "Return to lobby button",
		Menu = "Whole menu",
		Panels = "Both panels",
		InventoryPanel = "Inventory panel",
		CraftingPanel = "Crafting panel",
		Close = "Close (X) button",
		ItemStrip = "Recipe tile row",
		Preview = "Item preview box",
		Requirements = "Materials column",
		HotbarGroup = "Hotbar + bag button",
		Hotbar = "Hotbar",
		OpenInventory = "Bag button",
		HeldItemName = "Held item name",
		CraftingProgress = "Crafting progress",
		Dashes = "Dashed outline",
		Crosshair = "Crosshair",
	}

	local friendly
	friendly = function(o)
		if not o or isTarget(o) then
			return "UI"
		end
		local n = o.Name
		if NAMED[n] then
			return NAMED[n]
		end
		local slotName = n:match("^(%a+)Slot$")
		if slotName and SLOT_NAMES[slotName] then
			return slotName .. " slot"
		end
		local num = n:match("^Slot(%d+)$")
		if num then
			return "Backpack slot " .. num
		end
		num = n:match("^Hotbar(%d+)$")
		if num then
			return "Hotbar slot " .. num
		end
		local tab = n:match("^(%a+)Tab$")
		if tab then
			return tab .. " tab"
		end
		if ITEMS[n] and o:IsA("GuiButton") then
			return ITEMS[n].Name .. " recipe tile"
		end
		if o:IsA("ImageLabel") or o:IsA("ImageButton") then
			for slot, img in pairs(CONFIG.EquipmentIcons) do
				if img ~= "" and o.Image == img then
					return slot .. " icon"
				end
			end
			for _, item in pairs(ITEMS) do
				if item.Image ~= "" and o.Image == item.Image then
					return item.Name .. " icon (" .. friendly(o.Parent) .. ")"
				end
			end
			return "Picture in " .. friendly(o.Parent)
		end
		if isText(o) and o.Text ~= "" then
			local t = o.Text
			if #t > 22 then
				t = t:sub(1, 20) .. "…"
			end
			return '"' .. t .. '" ' .. (o:IsA("TextButton") and "button" or "text")
		end
		if isText(o) then
			return "Empty text in " .. friendly(o.Parent)
		end
		return "Part of " .. friendly(o.Parent)
	end

	local function textScale(o)
		local sc = o:FindFirstChild("TextScale")
		return sc and sc:IsA("UIScale") and sc.Scale or 1
	end
	local function inAutoRow(o)
		local p = o.Parent
		return p ~= nil and (p:FindFirstChildOfClass("UIListLayout") ~= nil or p:FindFirstChildOfClass("UIGridLayout") ~= nil)
	end

	local function remember(o)
		if originals[o] then
			return
		end
		local entry = { Position = o.Position, Size = o.Size, compX = 0, compY = 0, Spacing = o:GetAttribute("LetterSpacing") or 0 }
		if isText(o) then
			entry.TextSize = o.TextSize
			entry.TextScale = textScale(o)
		end
		entry.FontPx = o:GetAttribute("FontPx")
		originals[o] = entry
	end

	local function changes(o)
		local orig = originals[o]
		if not orig then
			return {}
		end
		local list = {}
		local dx = math.floor((o.Position.X.Offset - orig.Position.X.Offset - orig.compX) * 10 + 0.5) / 10
		local dy = math.floor((o.Position.Y.Offset - orig.Position.Y.Offset - orig.compY) * 10 + 0.5) / 10
		if dx ~= 0 then
			table.insert(list, "moved " .. math.abs(dx) .. (dx < 0 and " left" or " right"))
		end
		if dy ~= 0 then
			table.insert(list, "moved " .. math.abs(dy) .. (dy < 0 and " up" or " down"))
		end
		local dw = math.floor((o.Size.X.Offset - orig.Size.X.Offset) * 10 + 0.5) / 10
		local dh = math.floor((o.Size.Y.Offset - orig.Size.Y.Offset) * 10 + 0.5) / 10
		if dw ~= 0 then
			table.insert(list, (dw < 0 and "narrower " or "wider ") .. math.abs(dw))
		end
		if dh ~= 0 then
			table.insert(list, (dh < 0 and "shorter " or "taller ") .. math.abs(dh))
		end
		local ds = math.floor(((o:GetAttribute("LetterSpacing") or 0) - orig.Spacing) * 10 + 0.5) / 10
		if ds ~= 0 then
			table.insert(list, "letters " .. (ds < 0 and "closer " or "wider ") .. math.abs(ds))
		end
		local nowT = orig.TextSize and o.TextSize * textScale(o)
		local wasT = orig.TextSize and orig.TextSize * (orig.TextScale or 1)
		if orig.FontPx then
			nowT, wasT = o:GetAttribute("FontPx") or orig.FontPx, orig.FontPx
		end
		if (orig.TextSize or orig.FontPx) and math.abs(nowT - wasT) > 0.05 then
			local dt = math.floor((nowT - wasT) * 10 + 0.5) / 10
			table.insert(list, "text " .. (dt < 0 and "smaller " or "bigger ") .. math.abs(dt))
		end
		return list
	end

	local function refreshInfo()
		if not selected or not selected.Parent then
			selected = nil
			nameLabel.Text = "Tap Pick, then tap something"
			changeLabel.Text = ""
			return
		end
		nameLabel.Text = friendly(selected)
		local list = changes(selected)
		local info = #list > 0 and table.concat(list, ", ") or "No changes yet"
		if inAutoRow(selected) then
			info ..= ". Sits in an auto row, so it can't move alone: tap Bigger part to move the row"
		end
		changeLabel.Text = info
	end

	local function selectObject(o)
		selected = o
		refreshInfo()
	end

	local function setMode(m)
		mode = mode == m and "none" or m
		catcher.Visible = mode ~= "none"
		pickButton.TextColor3 = mode == "pick" and T_ACCENT or T_TEXT
		dragButton.TextColor3 = mode == "drag" and T_ACCENT or T_TEXT
		pickButton.BackgroundTransparency = mode == "pick" and 0.6 or 0.88
		dragButton.BackgroundTransparency = mode == "drag" and 0.6 or 0.88
	end

	local function effectiveScale(o)
		local sc = 1
		local cur = o.Parent
		while cur and not isTarget(cur) do
			local u = cur:FindFirstChildOfClass("UIScale")
			if u then
				sc *= u.Scale
			end
			cur = cur.Parent
		end
		return sc
	end

	local function apply(kind, a, b)
		local o = selected
		if not o then
			return
		end
		if kind == "move" and inAutoRow(o) then
			refreshInfo()
			return
		end
		remember(o)
		local n = step()
		if kind == "move" then
			local p = o.Position
			o.Position = UDim2.new(p.X.Scale, p.X.Offset + a * n, p.Y.Scale, p.Y.Offset + b * n)
		elseif kind == "size" and isText(o) and b == 0 and a ~= 0 then
			letterSpacing(o, (o:GetAttribute("LetterSpacing") or 0) + a * n)
		elseif kind == "size" then
			local sz = o.Size
			local dw, dh = a * n, b * n
			o.Size = UDim2.new(sz.X.Scale, sz.X.Offset + dw, sz.Y.Scale, sz.Y.Offset + dh)
			local shiftX = -dw * (0.5 - o.AnchorPoint.X)
			local shiftY = -dh * (0.5 - o.AnchorPoint.Y)
			if shiftX ~= 0 or shiftY ~= 0 then
				local p = o.Position
				o.Position = UDim2.new(p.X.Scale, p.X.Offset + shiftX, p.Y.Scale, p.Y.Offset + shiftY)
				local orig = originals[o]
				orig.compX += shiftX
				orig.compY += shiftY
			end
		elseif kind == "text" and o:GetAttribute("FontPx") then
			o:SetAttribute("FontPx", math.max(1, math.floor((o:GetAttribute("FontPx") + a * n) * 10 + 0.5) / 10))
		elseif kind == "text" and isText(o) then
			local sc = o:FindFirstChild("TextScale")
			local want = o.TextSize * textScale(o) + a * n
			if want > 100 then
				if not (sc and sc:IsA("UIScale")) then
					sc = Instance.new("UIScale")
					sc.Name = "TextScale"
					sc.Parent = o
				end
				o.TextSize = 100
				sc.Scale = math.floor(want / 100 * 1000 + 0.5) / 1000
			else
				if sc and sc:IsA("UIScale") then
					sc.Scale = 1
				end
				o.TextSize = math.clamp(want, 1, 100)
			end
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
					task.wait(0.07)
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

	local sections = {
		{ "Move", { { "Left", "move", -1, 0 }, { "Right", "move", 1, 0 }, { "Up", "move", 0, -1 }, { "Down", "move", 0, 1 } } },
		{ "Size", { { "Smaller", "size", -1, -1 }, { "Bigger", "size", 1, 1 } } },
		{ "Text", { { "Smaller", "text", -1, 0 }, { "Bigger", "text", 1, 0 } } },
		{ "Width", { { "Narrower", "size", -1, 0 }, { "Wider", "size", 1, 0 } } },
		{ "Height", { { "Shorter", "size", 0, -1 }, { "Taller", "size", 0, 1 } } },
	}
	local y = 78
	for _, section in ipairs(sections) do
		label(body, section[1], 8, y, 50, 24, 12).TextTransparency = 0.25
		local count = #section[2]
		local x0, total = 58, W - 58 - 8
		local bw = (total - (count - 1) * 4) / count
		for i, spec in ipairs(section[2]) do
			local b = button(body, spec[1], x0 + (i - 1) * (bw + 4), y, bw, 24)
			holdButton(b, function()
				apply(spec[2], spec[3], spec[4])
			end)
		end
		y += 30
	end

	local resetButton = button(body, "Undo this", 8, y + 2, 70, 22)
	local resetAllButton = button(body, "Undo all", 82, y + 2, 64, 22)
	local copyButton = button(body, "Copy all", 150, y + 2, W - 158, 22)
	copyButton.BackgroundColor3 = T_ACCENT
	copyButton.BackgroundTransparency = 0
	copyButton.TextColor3 = Color3.fromRGB(27, 26, 20)
	panel.Size = UDim2.fromOffset(W, 24 + y + 30)
	local fullHeight = 24 + y + 30

	local exportFrame = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0.96, 0, 0.92, 0),
		BackgroundColor3 = T_BG,
		BackgroundTransparency = 0,
		Visible = false,
		ZIndex = 20,
	}, tunerGui)
	round(exportFrame, 8)
	make("UIStroke", { Color = T_ACCENT, Thickness = 1 }, exportFrame)
	label(exportFrame, "Screenshot this (scroll for more) and send it", 10, 4, 400, 22, 13).ZIndex = 21
	local closeExport = button(exportFrame, "Close", 0, 4, 60, 22)
	closeExport.AnchorPoint = Vector2.new(1, 0)
	closeExport.Position = UDim2.new(1, -8, 0, 4)
	closeExport.ZIndex = 21
	local exportScroll = make("ScrollingFrame", {
		Position = UDim2.fromOffset(8, 30),
		Size = UDim2.new(1, -16, 1, -84),
		BackgroundTransparency = 1,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 6,
		ZIndex = 21,
	}, exportFrame)
	local copyHint = label(exportFrame, "Tap the box below, hold, Select All, Copy, then send it:", 10, 0, 600, 18, 12)
	copyHint.AnchorPoint = Vector2.new(0, 1)
	copyHint.Position = UDim2.new(0, 10, 1, -46)
	copyHint.TextColor3 = T_ACCENT
	copyHint.ZIndex = 21
	local copyBox = make("TextBox", {
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 8, 1, -8),
		Size = UDim2.new(1, -16, 0, 34),
		BackgroundColor3 = Color3.new(1, 1, 1),
		BackgroundTransparency = 0.9,
		ClearTextOnFocus = false,
		TextEditable = true,
		MultiLine = false,
		TextWrapped = false,
		ClipsDescendants = true,
		Font = Enum.Font.Code,
		TextSize = 13,
		TextColor3 = T_TEXT,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "",
		ZIndex = 21,
	}, exportFrame)
	round(copyBox, 6)
	local copyCode = ""
	local copyParts = {}
	local copyIndex = 1
	local partButton = button(exportFrame, "Next part", 0, 0, 120, 22)
	partButton.BackgroundColor3 = T_ACCENT
	partButton.BackgroundTransparency = 0
	partButton.TextColor3 = Color3.fromRGB(27, 26, 20)
	partButton.AnchorPoint = Vector2.new(1, 1)
	partButton.Position = UDim2.new(1, -8, 1, -46)
	partButton.ZIndex = 21
	partButton.Visible = false
	local function showPart()
		copyCode = copyParts[copyIndex] or ""
		partButton.Text = copyIndex < #copyParts and ("Next part (" .. copyIndex + 1 .. "/" .. #copyParts .. ")") or "Back to part 1"
		copyBox.Text = copyCode
		if #copyParts > 1 then
			copyHint.Text = "PART " .. copyIndex .. " OF " .. #copyParts .. "  (send ALL " .. #copyParts .. " parts): tap box, hold, Select All, Copy. Then Next part."
		else
			copyHint.Text = "Tap the box below, hold, Select All, Copy, then send it:"
		end
		partButton.Visible = #copyParts > 1
	end
	partButton.Activated:Connect(function()
		copyBox:ReleaseFocus()
		copyIndex = copyIndex % math.max(#copyParts, 1) + 1
		showPart()
	end)
	copyBox.Focused:Connect(function()
		if copyBox.Text ~= copyCode then
			copyBox:ReleaseFocus()
			copyBox.Text = copyCode
			return
		end
		task.defer(function()
			copyBox.SelectionStart = 1
			copyBox.CursorPosition = #copyCode + 1
		end)
	end)
	copyBox.FocusLost:Connect(function()
		copyBox.Text = copyCode
	end)
	copyBox:GetPropertyChangedSignal("Text"):Connect(function()
		if copyBox.Text ~= copyCode and not copyBox:IsFocused() then
			copyBox.Text = copyCode
		end
	end)
	local exportBox = make("TextLabel", {
		Size = UDim2.new(1, -8, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		TextWrapped = true,
		Font = Enum.Font.Code,
		TextSize = 14,
		TextColor3 = T_TEXT,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		Text = "",
		ZIndex = 21,
	}, exportScroll)

	local function pathOf(o)
		local parts = {}
		local cur = o
		while cur and not isTarget(cur) do
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
		local owner = ownerOf(o)
		local prefix = owner and owner ~= targets[1] and owner.Name .. ":" or ""
		return prefix .. (table.concat(parts, "/"):gsub("^Menu/Panels/", ""))
	end
	local function udim2(u)
		return string.format("%g,%g,%g,%g", u.X.Scale, u.X.Offset, u.Y.Scale, u.Y.Offset)
	end

	local function buildCode()
		local parts = {}
		for o, orig in pairs(originals) do
			if o.Parent and #changes(o) > 0 then
				local entry = pathOf(o) .. "=P" .. udim2(o.Position) .. "/S" .. udim2(o.Size)
				if orig.FontPx then
					entry ..= "/T" .. tostring(o:GetAttribute("FontPx"))
				end
				if orig.TextSize then
					entry ..= "/T" .. o.TextSize
					if textScale(o) ~= 1 then
						entry ..= "/U" .. textScale(o)
					end
				end
				if (o:GetAttribute("LetterSpacing") or 0) ~= 0 then
					entry ..= "/L" .. tostring(math.floor((o:GetAttribute("LetterSpacing") or 0) * 10 + 0.5) / 10)
				end
				table.insert(parts, entry)
			end
		end
		table.sort(parts)
		return "HZT " .. table.concat(parts, " ; ") .. " ; COUNT=" .. #parts
	end

	local function buildExport()
		local lines = {}
		for o, orig in pairs(originals) do
			if o.Parent then
				local list = changes(o)
				if #list > 0 then
					local exact = "P " .. udim2(o.Position) .. "  S " .. udim2(o.Size)
					if orig.FontPx then
						exact ..= "  T " .. tostring(o:GetAttribute("FontPx"))
					end
					if orig.TextSize then
						exact ..= "  T " .. o.TextSize
						if textScale(o) ~= 1 then
							exact ..= "  U " .. textScale(o)
						end
					end
					table.insert(lines, "• " .. friendly(o) .. ": " .. table.concat(list, ", ") .. "\n   " .. pathOf(o) .. "  " .. exact)
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

	local SKIP_NAMES = { Dim = true, PopupDim = true, MouseUnlock = true, CelebrationDim = true, Shown = true }
	local function isShown(o)
		local cur = o
		while cur and not isTarget(cur) do
			if cur:IsA("GuiObject") and not cur.Visible then
				return false
			end
			cur = cur.Parent
		end
		return true
	end
	local function isEmptyBox(o)
		if not (o.ClassName == "Frame" or o.ClassName == "ScrollingFrame") then
			return false
		end
		if o.BackgroundTransparency < 0.99 then
			return false
		end
		local s = o:FindFirstChildOfClass("UIStroke")
		return not (s and s.Transparency < 0.99)
	end
	local function pickAt(pos)
		for _, o in ipairs(playerGui:GetGuiObjectsAtPosition(pos.X, pos.Y)) do
			local owner = ownerOf(o)
			local background = owner and owner:FindFirstChild("Background")
			if owner
				and not SKIP_NAMES[o.Name]
				and not (background and (o == background or o:IsDescendantOf(background)))
				and not isEmptyBox(o)
				and isShown(o)
			then
				while o:GetAttribute("TunerPickParent") and o.Parent and not isTarget(o.Parent) do
					o = o.Parent
				end
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
		elseif mode == "drag" and selected and inAutoRow(selected) then
			refreshInfo()
		elseif mode == "drag" and selected then
			remember(selected)
			dragging = { start = input.Position, pos = selected.Position, scale = effectiveScale(selected) }
		end
	end)

	local panelDrag = nil
	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			panelDrag = { start = input.Position, pos = panel.Position }
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		if panelDrag then
			local d = input.Position - panelDrag.start
			panel.Position = UDim2.fromOffset(panelDrag.pos.X.Offset + d.X, panelDrag.pos.Y.Offset + d.Y)
		elseif dragging and selected then
			local d = (input.Position - dragging.start) / math.max(dragging.scale, 0.01)
			local p = dragging.pos
			selected.Position = UDim2.new(p.X.Scale, p.X.Offset + math.floor(d.X + 0.5), p.Y.Scale, p.Y.Offset + math.floor(d.Y + 0.5))
			refreshInfo()
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = nil
			panelDrag = nil
		end
	end)

	pickButton.Activated:Connect(function()
		setMode("pick")
	end)
	dragButton.Activated:Connect(function()
		setMode("drag")
	end)
	upButton.Activated:Connect(function()
		if selected and selected.Parent and not isTarget(selected.Parent) then
			selectObject(selected.Parent)
		end
	end)
	stepButton.Activated:Connect(function()
		stepIndex = stepIndex % #T_STEPS + 1
		stepButton.Text = "x" .. step()
	end)

	local function restore(o)
		local orig = originals[o]
		if not orig then
			return
		end
		o.Position = orig.Position
		o.Size = orig.Size
		if orig.FontPx then
			o:SetAttribute("FontPx", orig.FontPx)
		end
		if orig.TextSize then
			o.TextSize = orig.TextSize
			local sc = o:FindFirstChild("TextScale")
			if sc and sc:IsA("UIScale") then
				sc.Scale = orig.TextScale or 1
			end
		end
		if (o:GetAttribute("LetterSpacing") or 0) ~= orig.Spacing then
			letterSpacing(o, orig.Spacing)
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
	local exportNumber = 0
	copyButton.Activated:Connect(function()
		copyBox:ReleaseFocus()
		exportNumber += 1
		exportBox.Text = "Export #" .. exportNumber .. "\n" .. buildExport()
		local all = buildCode()
		table.clear(copyParts)
		table.insert(copyParts, (all:gsub("^HZT ", "HZT#" .. exportNumber .. " ")))
		copyIndex = 1
		showPart()
		exportFrame.Visible = true
	end)
	closeExport.Activated:Connect(function()
		copyBox:ReleaseFocus()
		exportFrame.Visible = false
	end)

	local minimized = false
	minButton.Activated:Connect(function()
		minimized = not minimized
		body.Visible = not minimized
		panel.Size = UDim2.fromOffset(W, minimized and 24 or fullHeight)
		minButton.Text = minimized and "+" or "–"
	end)

	RunService.RenderStepped:Connect(function()
		local shown = selected ~= nil and selected.Parent ~= nil and selected:IsA("GuiObject")
		local current = selected
		while shown and current and current ~= game do
			if (current:IsA("GuiObject") and not current.Visible) or (current:IsA("ScreenGui") and not current.Enabled) then
				shown = false
			end
			current = current.Parent
		end
		if shown then
			highlight.Visible = true
			local origin = tunerGui.AbsolutePosition
			highlight.Position = UDim2.fromOffset(selected.AbsolutePosition.X - origin.X, selected.AbsolutePosition.Y - origin.Y)
			highlight.Size = UDim2.fromOffset(selected.AbsoluteSize.X, selected.AbsoluteSize.Y)
		else
			highlight.Visible = false
		end
	end)

	targets[1].Destroying:Connect(function()
		tunerGui:Destroy()
	end)
end

return { start = startTuner }
