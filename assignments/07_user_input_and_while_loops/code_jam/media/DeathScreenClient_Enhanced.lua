--[[
	DeathScreenClient (LocalScript, put in StarterPlayer > StarterPlayerScripts)

	ONE death screen for every death, styled after the DESCENT shop menu, now with a pile of VFX:

	  IMPACT (when "YOU DIED" lands): cream flash, screen shake, quick camera FOV punch, two shockwave rings,
	    radial speed lines, a confetti burst, and a rain of dice that bounce and pile up at the bottom
	  AMBIENT: ransom-note paper scraps drifting down, floating diamond confetti, title letters wobbling,
	    cave spikes dropping in, pulsing SPECTATE button
	  RIGHT SIDE: a dice card with a tumbling die and a rubber STAMP that slams on, Level / Survived / Place
	    cards with taped corners and count-up numbers, and a typewriter tip bar
	  Everything is built in code. Hides on respawn or when you press the button.

	Needs DeathScreenServer, which fires the "DeathScreenEvent" remote (payload: Level, Survived, Placement, Total).
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local Debris = game:GetService("Debris")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local event = ReplicatedStorage:WaitForChild("DeathScreenEvent")

-- ===== CONFIG =====
local TITLE = "YOU DIED"
local HEADER = "ELIMINATED"
local BUTTON_TEXT = "SPECTATE"
local STAMP_TEXT = "OUT!"
local BLUR_SIZE = 10
local SHOW_DELAY = 0.5          -- seconds after dying before the screen appears
local CAMERA_PUNCH = true       -- quick FOV kick on impact. Turn off if your movement kit fights over FieldOfView.

-- paste rbxassetid://... ids in here (empty = silent)
local SOUNDS = {
	Death = "",   -- plays when the screen appears
	Impact = "",  -- plays when the title lands
	Stamp = "",   -- plays when the stamp slams
	Click = "",   -- plays when you press the button
}

local LINES = {
	"Better luck next round.",
	"That one's on the floor.",
	"Shake it off.",
	"The floor always wins.",
	"Nothing personal. Probably.",
	"It was always watching.",
}
local TIPS = { -- placeholders, swap in real tips for your game
	"Tiles that shake are about to drop. Move!",
	"A wall jump gives your double jump back.",
	"Stay off the edges when other players are close.",
	"Every level rolls a different die. Make it count.",
	"Slow and steady loses to a collapsing floor.",
}

-- palette (matched to the shop menu, tweak freely)
local C = {
	cream = Color3.fromRGB(243, 233, 207),
	gold = Color3.fromRGB(226, 165, 58),
	lime = Color3.fromRGB(143, 212, 74),
	green = Color3.fromRGB(28, 61, 42),
	greenTile = Color3.fromRGB(96, 160, 62),
	brown = Color3.fromRGB(88, 56, 42),
	tileBrown = Color3.fromRGB(150, 100, 72),
	dark = Color3.fromRGB(22, 12, 10),
	bg = Color3.fromRGB(42, 24, 17),
	purple = Color3.fromRGB(70, 40, 135),
	rust = Color3.fromRGB(205, 78, 42),
}

-- ransom-note tile colors (bg + text) and fonts
local PALETTE = {
	{ bg = C.cream, fg = C.dark },
	{ bg = C.gold, fg = C.dark },
	{ bg = C.greenTile, fg = C.cream },
	{ bg = C.tileBrown, fg = C.cream },
	{ bg = C.dark, fg = C.cream },
	{ bg = C.dark, fg = C.gold },
	{ bg = C.cream, fg = C.greenTile },
}
local PALETTE_NOGOLD = {} -- for the gold button so letters don't blend into it
for _, p in ipairs(PALETTE) do
	if p.bg ~= C.gold then table.insert(PALETTE_NOGOLD, p) end
end
local FONTS = {
	Enum.Font.GothamBlack, Enum.Font.SpecialElite, Enum.Font.Bodoni, Enum.Font.Garamond, Enum.Font.Cartoon,
	Enum.Font.LuckiestGuy, Enum.Font.Oswald, Enum.Font.Antique, Enum.Font.FredokaOne, Enum.Font.Merriweather,
}

local PIPS = {
	[1] = { { 0.5, 0.5 } },
	[2] = { { 0.27, 0.27 }, { 0.73, 0.73 } },
	[3] = { { 0.27, 0.27 }, { 0.5, 0.5 }, { 0.73, 0.73 } },
	[4] = { { 0.27, 0.27 }, { 0.73, 0.27 }, { 0.27, 0.73 }, { 0.73, 0.73 } },
	[5] = { { 0.27, 0.27 }, { 0.73, 0.27 }, { 0.5, 0.5 }, { 0.27, 0.73 }, { 0.73, 0.73 } },
	[6] = { { 0.27, 0.27 }, { 0.73, 0.27 }, { 0.27, 0.5 }, { 0.73, 0.5 }, { 0.27, 0.73 }, { 0.73, 0.73 } },
}

-- ===== HELPERS =====
local session = 0   -- bumped on every show/hide so old delayed callbacks and loops stop themselves
local currentGui = nil
local hide          -- forward declaration

local function tween(obj, time, props, style, dir)
	local t = TweenService:Create(obj, TweenInfo.new(time, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props)
	t:Play()
	return t
end

local function make(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do o[k] = v end
	o.Parent = parent
	return o
end

local function pick(list) return list[math.random(#list)] end

local function fmtTime(s)
	s = math.floor(s)
	return string.format("%d:%02d", s // 60, s % 60)
end

local function sfx(id, vol)
	if id and id ~= "" then
		local s = make("Sound", { SoundId = id, Volume = vol or 0.8 }, SoundService)
		s:Play()
		Debris:AddItem(s, 8)
	end
end

local function destroyNow()
	if currentGui then currentGui:Destroy() currentGui = nil end
	for _, name in ipairs({ "DeathBlur", "DeathCC" }) do
		local o = Lighting:FindFirstChild(name)
		if o then o:Destroy() end
	end
end

-- Ransom-note text: one little cut-out tile per letter.
-- Returns the row, a list of UIScales (to pop the letters in) and the tiles themselves.
local function ransomRow(parent, text, size, order, palette)
	palette = palette or PALETTE
	local row = make("Frame", {
		LayoutOrder = order, BackgroundTransparency = 1, AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, math.floor(size * 1.2)),
	}, parent)
	make("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal, VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, math.max(2, math.floor(size * 0.04))),
	}, row)
	local scales, tiles, last = {}, {}, 0
	for i = 1, #text do
		local ch = text:sub(i, i)
		if ch == " " then
			make("Frame", { LayoutOrder = i, BackgroundTransparency = 1, Size = UDim2.fromOffset(math.floor(size * 0.4), 1) }, row)
		else
			local idx = math.random(#palette)
			if idx == last then idx = idx % #palette + 1 end
			last = idx
			local p = palette[idx]
			if math.random() < 0.25 then ch = ch:lower() end
			local tile = make("TextLabel", {
				LayoutOrder = i, AutomaticSize = Enum.AutomaticSize.X,
				Size = UDim2.fromOffset(0, math.floor(size * math.random(92, 112) / 100)),
				BackgroundColor3 = p.bg, BorderSizePixel = 0, Text = ch, TextColor3 = p.fg,
				Font = pick(FONTS), TextSize = math.floor(size * 0.78),
				Rotation = math.random(-50, 50) / 10,
			}, row)
			make("UIPadding", { PaddingLeft = UDim.new(0, math.floor(size * 0.1)), PaddingRight = UDim.new(0, math.floor(size * 0.1)) }, tile)
			table.insert(scales, make("UIScale", { Scale = 0 }, tile))
			table.insert(tiles, tile)
		end
	end
	return row, scales, tiles
end

local function pop(scales, delay, my, step)
	for i, sc in ipairs(scales) do
		task.delay(delay + (i - 1) * (step or 0.045), function()
			if session == my then tween(sc, 0.3, { Scale = 1 }, Enum.EasingStyle.Back) end
		end)
	end
end

-- A die: purple rounded square, gold outline, cream pips.
local function makeDie(parent, size, face, props)
	local die = make("Frame", { Size = UDim2.fromOffset(size, size), BackgroundColor3 = C.purple, BorderSizePixel = 0 }, parent)
	make("UICorner", { CornerRadius = UDim.new(0, math.floor(size * 0.18)) }, die)
	make("UIStroke", { Color = C.gold, Thickness = math.max(2, math.floor(size * 0.04)) }, die)
	local pipSize = math.max(4, math.floor(size * 0.17))
	for _, pp in ipairs(PIPS[face]) do
		local pip = make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(pp[1], pp[2]),
			Size = UDim2.fromOffset(pipSize, pipSize), BackgroundColor3 = C.cream, BorderSizePixel = 0,
		}, die)
		make("UICorner", { CornerRadius = UDim.new(1, 0) }, pip)
	end
	for k, v in pairs(props or {}) do die[k] = v end
	return die
end

-- A tilted brown card like the shop's item cards: shadow, outline, corner triangle, bottom accent line, tape.
local function card(parent, pos, size, rot, accent)
	local holder = make("Frame", { Position = pos, Size = size, Rotation = rot, BackgroundTransparency = 1 }, parent)
	local shadow = make("Frame", {
		Position = UDim2.fromOffset(6, 8), Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.dark,
		BackgroundTransparency = 0.25, BorderSizePixel = 0,
	}, holder)
	make("UICorner", { CornerRadius = UDim.new(0, 14) }, shadow)
	local body = make("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.brown, BorderSizePixel = 0 }, holder)
	make("UICorner", { CornerRadius = UDim.new(0, 14) }, body)
	make("UIStroke", { Color = C.dark, Thickness = 3 }, body)
	-- corner triangle (a square with a hard diagonal cut via gradient)
	local tri = make("Frame", { Size = UDim2.fromOffset(60, 60), BackgroundColor3 = accent, BorderSizePixel = 0 }, body)
	make("UICorner", { CornerRadius = UDim.new(0, 14) }, tri)
	make("UIGradient", {
		Rotation = 45,
		Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.499, 0),
			NumberSequenceKeypoint.new(0.5, 1), NumberSequenceKeypoint.new(1, 1),
		}),
	}, tri)
	make("Frame", {
		AnchorPoint = Vector2.new(0.5, 1), Position = UDim2.new(0.5, 0, 1, -10), Size = UDim2.new(0.92, 0, 0, 3),
		BackgroundColor3 = accent, BorderSizePixel = 0,
	}, body)
	-- strip of tape on the top edge
	make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.74, 0, 0, 2), Size = UDim2.fromOffset(72, 22),
		Rotation = math.random(-9, 9), BackgroundColor3 = C.cream, BackgroundTransparency = 0.3, BorderSizePixel = 0,
	}, holder)
	return body, holder
end

-- numbers that tick up (or down) to their final value
local function countUp(label, from, to, dur, fmt, my)
	task.spawn(function()
		local t0 = os.clock()
		while session == my and label.Parent do
			local a = math.min((os.clock() - t0) / dur, 1)
			local e = 1 - (1 - a) ^ 3
			label.Text = fmt(math.floor(from + (to - from) * e + 0.5))
			if a >= 1 then break end
			task.wait()
		end
		if label.Parent then label.Text = fmt(to) end
	end)
end

-- ===== BUILD =====
local function build(payload, my)
	destroyNow()
	sfx(SOUNDS.Death)

	-- screen effects
	local blur = make("BlurEffect", { Name = "DeathBlur", Size = 0 }, Lighting)
	local cc = make("ColorCorrectionEffect", { Name = "DeathCC", Saturation = 0 }, Lighting)
	tween(blur, 0.8, { Size = BLUR_SIZE })
	tween(cc, 0.8, { Saturation = -0.2, Brightness = -0.03 })

	local gui = make("ScreenGui", {
		Name = "DeathScreen", ResetOnSpawn = false, IgnoreGuiInset = true, DisplayOrder = 100,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, playerGui)
	currentGui = gui

	local root = make("CanvasGroup", { Name = "Root", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, BorderSizePixel = 0 }, gui)
	local cam = workspace.CurrentCamera
	local vp = cam.ViewportSize

	-- brown backdrop
	local backdrop = make("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = C.bg, BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 1 }, root)
	tween(backdrop, 0.5, { BackgroundTransparency = 0.08 })

	-- content column (everything scales together to fit the screen)
	local content = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(1200, 560), BackgroundTransparency = 1, ZIndex = 5,
	}, root)
	local contentBase = content.Position
	local uiScale = make("UIScale", {}, content)
	local function fit()
		local v = cam.ViewportSize
		uiScale.Scale = math.clamp(math.min(v.X / 1240, v.Y / 620), 0.4, 1.3)
	end
	fit()
	local conn = cam:GetPropertyChangedSignal("ViewportSize"):Connect(fit)
	gui.Destroying:Connect(function() conn:Disconnect() end)
	local function K() return uiScale.Scale end

	-- slanted green panel with lime + gold stripes (slides in from the left)
	local band = make("Frame", {
		AnchorPoint = Vector2.new(1, 0.5), Position = UDim2.new(0, -200, 0.5, 0), Size = UDim2.fromOffset(1800, 3000),
		BackgroundColor3 = C.green, BorderSizePixel = 0, Rotation = 7, ZIndex = 1,
	}, content)
	make("Frame", { Position = UDim2.new(1, 0, 0, 0), Size = UDim2.new(0, 14, 1, 0), BackgroundColor3 = C.lime, BorderSizePixel = 0 }, band)
	make("Frame", { Position = UDim2.new(1, 26, 0, 0), Size = UDim2.new(0, 4, 1, 0), BackgroundColor3 = C.gold, BorderSizePixel = 0 }, band)
	tween(band, 0.6, { Position = UDim2.new(0, 560, 0.5, 0) }, Enum.EasingStyle.Quint)

	-- ===== effect helpers (all draw straight onto the screen, in pixels) =====
	local function flash(color, startTransparency)
		local f = make("Frame", { Size = UDim2.fromScale(1, 1), BackgroundColor3 = color, BackgroundTransparency = startTransparency, BorderSizePixel = 0, ZIndex = 10 }, root)
		tween(f, 0.45, { BackgroundTransparency = 1 })
		Debris:AddItem(f, 0.5)
	end

	local function shake(dur, mag)
		task.spawn(function()
			local start = os.clock()
			while session == my and content.Parent and os.clock() - start < dur do
				local k = 1 - (os.clock() - start) / dur
				content.Position = contentBase + UDim2.fromOffset(math.random(-mag, mag) * k, math.random(-mag, mag) * k)
				task.wait()
			end
			if content.Parent then content.Position = contentBase end
		end)
	end

	local function punch(amount)
		if not CAMERA_PUNCH then return end
		local c = workspace.CurrentCamera
		if not c then return end
		local base = c.FieldOfView
		tween(c, 0.06, { FieldOfView = base - amount })
		task.delay(0.06, function()
			if workspace.CurrentCamera == c then tween(c, 0.4, { FieldOfView = base }) end
		end)
	end

	local function ring(cx, cy, color, startSize, endSize)
		local k = K()
		local r = make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(cx, cy),
			Size = UDim2.fromOffset(startSize * k, startSize * k), BackgroundTransparency = 1, ZIndex = 8,
		}, root)
		make("UICorner", { CornerRadius = UDim.new(1, 0) }, r)
		local st = make("UIStroke", { Color = color, Thickness = 8, Transparency = 0 }, r)
		tween(r, 0.7, { Size = UDim2.fromOffset(endSize * k, endSize * k) }, Enum.EasingStyle.Quint)
		tween(st, 0.7, { Transparency = 1, Thickness = 1 })
		Debris:AddItem(r, 0.8)
	end

	local function speedLines(cx, cy)
		local k = K()
		for i = 1, 18 do
			-- a zero-size rotated holder, with the line pushed outward along its length
			local holder = make("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(cx, cy), Size = UDim2.fromOffset(0, 0),
				BackgroundTransparency = 1, Rotation = (i / 18) * 360 + math.random(-6, 6), ZIndex = 8,
			}, root)
			local line = make("Frame", {
				AnchorPoint = Vector2.new(0.5, 0), Position = UDim2.fromOffset(0, 40 * k), Size = UDim2.fromOffset(4 * k, 10 * k),
				BackgroundColor3 = (i % 2 == 0) and C.gold or C.cream, BorderSizePixel = 0,
			}, holder)
			tween(line, 0.45, {
				Position = UDim2.fromOffset(0, math.random(220, 420) * k),
				Size = UDim2.fromOffset(2 * k, math.random(60, 140) * k),
				BackgroundTransparency = 1,
			})
			Debris:AddItem(holder, 0.55)
		end
	end

	local confettiColors = { C.lime, C.gold, C.cream, C.rust }
	local function burst(cx, cy, n)
		local k = K()
		for _ = 1, n do
			local s = math.floor(math.random(8, 16) * k)
			local d = make("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromOffset(cx, cy), Size = UDim2.fromOffset(s, math.random() < 0.5 and s or s * 2),
				Rotation = math.random(0, 90), BackgroundColor3 = pick(confettiColors), BorderSizePixel = 0, ZIndex = 9,
			}, root)
			local ang = math.random() * math.pi * 2
			local dist = math.random(120, 420) * k
			local tx, ty = cx + math.cos(ang) * dist, cy + math.sin(ang) * dist - 80 * k
			tween(d, 0.45, { Position = UDim2.fromOffset(tx, ty), Rotation = d.Rotation + math.random(-360, 360) })
			task.delay(0.45, function()
				if d.Parent then
					tween(d, 0.9 + math.random(), { Position = UDim2.fromOffset(tx + math.random(-60, 60), ty + 500 * k), BackgroundTransparency = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
				end
			end)
			Debris:AddItem(d, 2.6)
		end
	end

	local diceColors = { C.purple, C.green, Color3.fromRGB(150, 60, 40) }
	local function diceRain()
		local k = K()
		local n = math.clamp(math.floor(vp.X / 170), 5, 12)
		for i = 1, n do
			local sz = math.floor(math.random(34, 64) * k)
			local xs = (i - 0.5) / n + (math.random() - 0.5) * 0.05
			local d = makeDie(root, sz, math.random(1, 6), {
				AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(xs, 0, 0, -sz), Rotation = math.random(0, 360),
				ZIndex = 6, BackgroundColor3 = pick(diceColors),
			})
			task.delay(math.random() * 0.6, function()
				if session ~= my or not d.Parent then return end
				local dur = 0.9 + math.random() * 0.5
				tween(d, dur, { Position = UDim2.new(xs, 0, 1, -math.floor(sz * 0.5) - math.random(0, 12)) }, Enum.EasingStyle.Bounce, Enum.EasingDirection.Out)
				tween(d, dur, { Rotation = math.random(-40, 40) + 360 * math.random(1, 2) })
			end)
		end
	end

	-- ===== left column =====
	local left = make("Frame", { Position = UDim2.fromOffset(0, 0), Size = UDim2.fromOffset(540, 560), BackgroundTransparency = 1, ZIndex = 2 }, content)
	make("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical, HorizontalAlignment = Enum.HorizontalAlignment.Center,
		VerticalAlignment = Enum.VerticalAlignment.Center, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12),
	}, left)

	local _, headerTiles = ransomRow(left, HEADER, 30, 1)
	pop(headerTiles, 0.2, my)

	local underline = make("Frame", { LayoutOrder = 2, Size = UDim2.fromOffset(0, 4), BackgroundColor3 = C.lime, BorderSizePixel = 0 }, left)
	task.delay(0.4, function() if session == my then tween(underline, 0.5, { Size = UDim2.fromOffset(220, 4) }) end end)

	local titleRow, titleScales, titleTiles = ransomRow(left, TITLE, 72, 3)
	pop(titleScales, 0.35, my)

	local sub = make("TextLabel", {
		LayoutOrder = 4, Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Text = pick(LINES),
		Font = Enum.Font.GothamMedium, TextSize = 18, TextColor3 = C.cream, TextTransparency = 1,
	}, left)
	task.delay(0.9, function() if session == my then tween(sub, 0.5, { TextTransparency = 0 }) end end)

	-- gold pill button (like the highlighted menu entry)
	local btn = make("TextButton", {
		LayoutOrder = 5, Size = UDim2.fromOffset(300, 64), BackgroundColor3 = C.gold, AutoButtonColor = false,
		Text = "", BorderSizePixel = 0,
	}, left)
	make("UICorner", { CornerRadius = UDim.new(0, 16) }, btn)
	make("UIStroke", { Color = C.dark, Thickness = 3 }, btn)
	local btnScale = make("UIScale", { Scale = 0 }, btn)
	local btnRow, _, btnScales = nil, nil, nil
	do
		local row, scales = ransomRow(btn, BUTTON_TEXT, 30, 1, PALETTE_NOGOLD)
		btnRow, btnScales = row, scales
	end
	btnRow.AnchorPoint = Vector2.new(0.5, 0.5)
	btnRow.Position = UDim2.fromScale(0.5, 0.5)
	task.delay(0.85, function() if session == my then tween(btnScale, 0.35, { Scale = 1 }, Enum.EasingStyle.Back) end end)
	pop(btnScales, 0.95, my)
	task.delay(1.5, function() -- gentle pulse so the button keeps drawing the eye
		if session == my then
			TweenService:Create(btnScale, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), { Scale = 1.05 }):Play()
		end
	end)
	local hoverCol = C.gold:Lerp(Color3.new(1, 1, 1), 0.25)
	btn.MouseEnter:Connect(function() tween(btn, 0.12, { BackgroundColor3 = hoverCol, Rotation = -1.5 }) end)
	btn.MouseLeave:Connect(function() tween(btn, 0.12, { BackgroundColor3 = C.gold, Rotation = 0 }) end)
	btn.MouseButton1Click:Connect(function()
		sfx(SOUNDS.Click)
		hide()
	end)

	-- ===== right panel: dice card + stat cards + tip bar =====
	local panel = make("CanvasGroup", {
		Position = UDim2.fromOffset(650, 20), Size = UDim2.fromOffset(530, 520), BackgroundTransparency = 1,
		GroupTransparency = 1, ZIndex = 2,
	}, content)

	local big = card(panel, UDim2.fromOffset(20, 20), UDim2.fromOffset(490, 250), -1.2, C.gold)
	local die = makeDie(big, 110, math.random(1, 6), {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.5, 0, 0, 98), Rotation = 372,
	})
	local dieScale = make("UIScale", { Scale = 0.2 }, die)
	make("TextLabel", {
		Position = UDim2.fromOffset(16, 166), Size = UDim2.new(1, -32, 0, 28), BackgroundTransparency = 1, Text = "FINAL ROLL",
		Font = Enum.Font.GothamBlack, TextSize = 22, TextColor3 = C.cream, TextXAlignment = Enum.TextXAlignment.Left,
	}, big)
	make("TextLabel", {
		Position = UDim2.fromOffset(16, 196), Size = UDim2.new(1, -32, 0, 18), BackgroundTransparency = 1,
		Text = payload.Level and ("Reached level " .. tostring(payload.Level)) or "Your run is over",
		Font = Enum.Font.GothamMedium, TextSize = 14, TextColor3 = Color3.fromRGB(190, 165, 140), TextXAlignment = Enum.TextXAlignment.Left,
	}, big)

	-- rubber stamp (slams onto the dice card)
	local stamp = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(0.8, 0, 0, 70), Size = UDim2.fromOffset(150, 64),
		BackgroundTransparency = 1, Rotation = -14, ZIndex = 5,
	}, big)
	make("UICorner", { CornerRadius = UDim.new(0, 10) }, stamp)
	local stampStroke = make("UIStroke", { Color = C.rust, Thickness = 5, Transparency = 1 }, stamp)
	local stampText = make("TextLabel", {
		Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Text = STAMP_TEXT, Font = Enum.Font.GothamBlack,
		TextSize = 40, TextColor3 = C.rust, TextTransparency = 1,
	}, stamp)
	local stampScale = make("UIScale", { Scale = 3 }, stamp)

	-- stat cards
	local stats = {}
	if payload.Level then
		local lv = tonumber(payload.Level)
		table.insert(stats, {
			label = "LEVEL", value = tostring(payload.Level), from = lv and 0 or nil, to = lv, fmt = tostring, rot = 1.5,
		})
	end
	if payload.Survived then
		table.insert(stats, { label = "SURVIVED", value = fmtTime(payload.Survived), from = 0, to = payload.Survived, fmt = fmtTime, rot = -1 })
	end
	if payload.Placement then
		table.insert(stats, {
			label = payload.Total and string.format("PLACE (OF %d)", payload.Total) or "PLACE",
			value = "#" .. payload.Placement, from = payload.Total or payload.Placement, to = payload.Placement,
			fmt = function(n) return "#" .. n end, rot = 1,
		})
	end
	local n = #stats
	local gap = 17
	local cardW = n > 0 and math.floor((490 - (n - 1) * gap) / n) or 0
	local countLabels = {}
	for i, st in ipairs(stats) do
		local body = card(panel, UDim2.fromOffset(20 + (i - 1) * (cardW + gap), 295), UDim2.fromOffset(cardW, 170), st.rot, C.lime)
		local val = make("TextLabel", {
			Position = UDim2.fromOffset(16, 52), Size = UDim2.new(1, -32, 0, 60), BackgroundTransparency = 1, Text = st.value,
			Font = Enum.Font.GothamBlack, TextScaled = true, TextColor3 = C.cream, TextXAlignment = Enum.TextXAlignment.Left,
		}, body)
		make("UITextSizeConstraint", { MaxTextSize = 48, MinTextSize = 16 }, val)
		make("TextLabel", {
			Position = UDim2.new(0, 16, 1, -42), Size = UDim2.new(1, -32, 0, 22), BackgroundTransparency = 1, Text = st.label,
			Font = Enum.Font.GothamBold, TextSize = 15, TextColor3 = C.cream, TextXAlignment = Enum.TextXAlignment.Left,
		}, body)
		if st.to then table.insert(countLabels, { label = val, st = st }) end
	end

	-- tip bar with a typewriter effect
	local tipBar = make("Frame", {
		Position = UDim2.fromOffset(20, 480), Size = UDim2.fromOffset(490, 34), BackgroundColor3 = C.dark, BackgroundTransparency = 0.3,
		BorderSizePixel = 0,
	}, panel)
	make("UICorner", { CornerRadius = UDim.new(0, 10) }, tipBar)
	local tipText = make("TextLabel", {
		Position = UDim2.fromOffset(12, 0), Size = UDim2.new(1, -24, 1, 0), BackgroundTransparency = 1, RichText = true,
		Text = '<font color="#8FD44A"><b>TIP</b></font>   ' .. pick(TIPS), Font = Enum.Font.GothamMedium, TextSize = 14,
		TextColor3 = C.cream, TextXAlignment = Enum.TextXAlignment.Left, MaxVisibleGraphemes = 0,
	}, tipBar)

	-- panel slides in, die tumbles, numbers tick, tip types out
	task.delay(0.55, function()
		if session ~= my then return end
		tween(panel, 0.6, { GroupTransparency = 0, Position = UDim2.fromOffset(590, 20) }, Enum.EasingStyle.Quint)
		tween(die, 0.9, { Rotation = 12 }, Enum.EasingStyle.Quint)
		tween(dieScale, 0.7, { Scale = 1 }, Enum.EasingStyle.Back)
	end)
	task.delay(0.95, function()
		if session ~= my then return end
		for _, e in ipairs(countLabels) do
			countUp(e.label, e.st.from, e.st.to, 0.9, e.st.fmt, my)
		end
	end)
	task.delay(1.3, function()
		if session ~= my then return end
		task.spawn(function()
			for g = 0, 140, 2 do
				if session ~= my or not tipText.Parent then return end
				tipText.MaxVisibleGraphemes = g
				task.wait(0.02)
			end
			if tipText.Parent then tipText.MaxVisibleGraphemes = -1 end
		end)
	end)

	-- stamp slam
	task.delay(1.15, function()
		if session ~= my then return end
		tween(stampScale, 0.16, { Scale = 1 }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		tween(stampText, 0.12, { TextTransparency = 0.05 })
		tween(stampStroke, 0.12, { Transparency = 0.05 })
		task.delay(0.16, function()
			if session ~= my then return end
			sfx(SOUNDS.Stamp)
			shake(0.25, 9)
			punch(4)
			local c = stamp.AbsolutePosition + stamp.AbsoluteSize * 0.5
			ring(c.X, c.Y, C.rust, 30, 360)
			burst(c.X, c.Y, 14)
		end)
	end)

	-- ===== ambient decoration =====
	-- cave spikes
	local function spike(xScale, size, top)
		local y = top and 0 or 1
		local f = make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.new(xScale, 0, y, top and -size or size),
			Size = UDim2.fromOffset(size, size), Rotation = 45, BackgroundColor3 = C.dark, BorderSizePixel = 0, ZIndex = 6,
		}, root)
		task.delay(math.random() * 0.25, function()
			if session == my then tween(f, 0.5, { Position = UDim2.new(xScale, 0, y, 0) }, Enum.EasingStyle.Back) end
		end)
	end
	for i = 0, 13 do
		spike((i + math.random()) / 14, math.floor(vp.Y * math.random(5, 11) / 100), true)
		if math.random() < 0.7 then
			spike((i + math.random()) / 14, math.floor(vp.Y * math.random(4, 9) / 100), false)
		end
	end

	-- floating diamond confetti
	local diamondColors = { C.lime, C.gold, C.cream }
	for _ = 1, 16 do
		local s = math.random(7, 15)
		local d = make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Position = UDim2.fromScale(math.random(), math.random()), Size = UDim2.fromOffset(s, s),
			Rotation = 45, BackgroundColor3 = pick(diamondColors), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 6,
		}, root)
		tween(d, 0.8, { BackgroundTransparency = math.random(10, 45) / 100 })
		TweenService:Create(d, TweenInfo.new(math.random(20, 40) / 10, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
			{ Position = d.Position + UDim2.fromScale(0, (math.random() - 0.5) * 0.08) }):Play()
	end

	-- ransom-note paper scraps drifting down forever
	local scrapColors = { C.cream, C.gold, C.greenTile, C.tileBrown }
	for _ = 1, 14 do
		local fall = math.random(45, 85) / 10
		local holder = make("Frame", {
			Position = UDim2.new(math.random(), 0, 0, -40), Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1, ZIndex = 6,
		}, root)
		local scrap = make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5), Size = UDim2.fromOffset(math.random(10, 22), math.random(14, 30)),
			Rotation = math.random(0, 360), BackgroundColor3 = pick(scrapColors), BackgroundTransparency = 0.15, BorderSizePixel = 0,
		}, holder)
		task.delay(0.3 + math.random() * fall, function()
			if session ~= my or not holder.Parent then return end
			TweenService:Create(holder, TweenInfo.new(fall, Enum.EasingStyle.Linear, Enum.EasingDirection.In, -1),
				{ Position = UDim2.new(holder.Position.X.Scale, 0, 1, 40) }):Play()
			TweenService:Create(scrap, TweenInfo.new(math.random(8, 16) / 10, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
				{ Position = UDim2.fromOffset(math.random(-35, 35), 0), Rotation = scrap.Rotation + math.random(60, 140) }):Play()
		end)
	end

	-- dark vignette on the sides
	local function edge(anchor, pos, size, rot)
		local f = make("Frame", { AnchorPoint = anchor, Position = pos, Size = size, BackgroundColor3 = Color3.fromRGB(10, 5, 4), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 7 }, root)
		make("UIGradient", {
			Rotation = rot,
			Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.4), NumberSequenceKeypoint.new(1, 1) }),
		}, f)
		tween(f, 0.8, { BackgroundTransparency = 0.2 })
	end
	edge(Vector2.new(0, 0), UDim2.fromScale(0, 0), UDim2.fromScale(0.2, 1), 0)
	edge(Vector2.new(1, 0), UDim2.fromScale(1, 0), UDim2.fromScale(0.2, 1), 180)


	-- ===== EXTRA VFX PASS: scanlines, ember motes, glitch slices and corner HUD =====
	-- Lightweight UI-only effects, so these work without particle assets or emitters.
	local vfxLayer = make("Frame", {
		Name = "VFXLayer", Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 8,
	}, root)

	-- Fine cinematic scanlines. Keep them subtle so the text stays readable.
	for i = 1, 32 do
		local line = make("Frame", {
			Position = UDim2.new(0, 0, (i - 1) / 32, 0),
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = C.cream, BackgroundTransparency = 0.94,
			BorderSizePixel = 0, ZIndex = 8,
		}, vfxLayer)
	end

	-- Four angular corner marks make the screen feel like a designed game HUD.
	local function cornerMark(x, y, flipX, flipY)
		local holder = make("Frame", {
			AnchorPoint = Vector2.new(x, y), Position = UDim2.new(x, flipX and -28 or 28, y, flipY and -28 or 28),
			Size = UDim2.fromOffset(54, 54), BackgroundTransparency = 1, ZIndex = 9,
		}, vfxLayer)
		local horizontal = make("Frame", {
			Position = UDim2.fromOffset(flipX and 0 or 10, flipY and 0 or 10),
			Size = UDim2.fromOffset(44, 3), BackgroundColor3 = C.gold,
			BorderSizePixel = 0, ZIndex = 9,
		}, holder)
		local vertical = make("Frame", {
			Position = UDim2.fromOffset(flipX and 0 or 10, flipY and 0 or 10),
			Size = UDim2.fromOffset(3, 44), BackgroundColor3 = C.lime,
			BorderSizePixel = 0, ZIndex = 9,
		}, holder)
		TweenService:Create(holder, TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
			Rotation = flipX and -4 or 4,
		}):Play()
	end
	cornerMark(0, 0, false, false)
	cornerMark(1, 0, true, false)
	cornerMark(0, 1, false, true)
	cornerMark(1, 1, true, true)

	-- Warm ember motes rise behind the interface and fade away.
	local emberColors = { C.gold, C.rust, C.lime, C.cream }
	for i = 1, 26 do
		local size = math.random(3, 8)
		local x = math.random(3, 97) / 100
		local y = math.random(45, 105) / 100
		local ember = make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(x, y),
			Size = UDim2.fromOffset(size, size),
			BackgroundColor3 = pick(emberColors),
			BackgroundTransparency = math.random(15, 45) / 100,
			BorderSizePixel = 0, ZIndex = 8,
		}, vfxLayer)
		make("UICorner", { CornerRadius = UDim.new(1, 0) }, ember)
		local drift = math.random(80, 240)
		tween(ember, math.random(18, 36) / 10, {
			Position = UDim2.new(x, math.random(-45, 45), y, -drift),
			BackgroundTransparency = 1,
			Rotation = math.random(-180, 180),
		}, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
		Debris:AddItem(ember, 4)
	end

	-- Short horizontal chromatic glitch bars fire on impact.
	local function glitchBurst()
		for i = 1, 12 do
			local h = math.random(3, 13)
			local y = math.random(12, 88) / 100
			local bar = make("Frame", {
				Position = UDim2.new(0, -vp.X * 0.2, y, 0),
				Size = UDim2.new(0, math.random(70, 280), 0, h),
				BackgroundColor3 = (i % 3 == 0) and C.rust or ((i % 2 == 0) and C.lime or C.gold),
				BackgroundTransparency = 0.18, BorderSizePixel = 0, ZIndex = 10,
			}, vfxLayer)
			tween(bar, math.random(12, 25) / 100, {
				Position = UDim2.new(0, math.random(0, math.max(0, vp.X - 100)), y, math.random(-12, 12)),
				BackgroundTransparency = 1,
			}, Enum.EasingStyle.Linear)
			Debris:AddItem(bar, 0.35)
		end
	end

	-- A rotating seal behind the title, revealed briefly when the impact lands.
	local seal = make("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.31, 0.48),
		Size = UDim2.fromOffset(220, 220),
		BackgroundTransparency = 1, ZIndex = 3,
	}, root)
	make("UICorner", { CornerRadius = UDim.new(1, 0) }, seal)
	local sealStroke = make("UIStroke", {
		Color = C.gold, Thickness = 2, Transparency = 1,
	}, seal)
	local sealScale = make("UIScale", { Scale = 0.45 }, seal)
	for i = 1, 8 do
		local tick = make("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 0),
			Size = UDim2.fromOffset(3, 14),
			BackgroundColor3 = (i % 2 == 0) and C.lime or C.gold,
			BackgroundTransparency = 0.2, BorderSizePixel = 0,
			Rotation = (i - 1) * 45, ZIndex = 3,
		}, seal)
	end

	-- ===== THE IMPACT: fires right after the title letters finish popping in =====
	local impactAt = 0.35 + #titleScales * 0.045 + 0.1
	task.delay(impactAt, function()
		if session ~= my then return end
		sfx(SOUNDS.Impact)
		local p = titleRow.AbsolutePosition + titleRow.AbsoluteSize * 0.5
		flash(C.cream, 0.5)
		glitchBurst()
		tween(sealScale, 0.45, { Scale = 1.35 }, Enum.EasingStyle.Back)
		tween(sealStroke, 0.55, { Transparency = 0.15, Thickness = 4 })
		tween(seal, 0.75, { Rotation = 180 }, Enum.EasingStyle.Quint)
		task.delay(0.55, function() if seal.Parent then tween(sealStroke, 0.35, { Transparency = 1 }) end end)
		shake(0.45, 16)
		punch(9)
		ring(p.X, p.Y, C.gold, 60, 900)
		task.delay(0.08, function()
			if session == my then ring(p.X, p.Y, C.lime, 40, 700) end
		end)
		speedLines(p.X, p.Y)
		burst(p.X, p.Y, 44)
		task.delay(0.12, function()
			if session == my then
				burst(p.X + math.random(-35, 35), p.Y + math.random(-25, 25), 18)
				glitchBurst()
			end
		end)
		task.delay(0.1, function()
			if session == my then diceRain() end
		end)
		-- title letters keep wobbling
		for _, t in ipairs(titleTiles) do
			TweenService:Create(t, TweenInfo.new(0.5 + math.random() * 0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
				{ Rotation = t.Rotation + math.random(-30, 30) / 10 }):Play()
		end
	end)
end

-- ===== HIDE =====
function hide()
	session += 1
	local gui = currentGui
	currentGui = nil
	local blur = Lighting:FindFirstChild("DeathBlur")
	local cc = Lighting:FindFirstChild("DeathCC")
	if blur then tween(blur, 0.4, { Size = 0 }) end
	if cc then tween(cc, 0.4, { Saturation = 0, Brightness = 0 }) end
	if gui then
		local root = gui:FindFirstChild("Root")
		if root then tween(root, 0.35, { GroupTransparency = 1 }) end
		task.delay(0.4, function() gui:Destroy() end)
	end
	task.delay(0.5, function()
		if blur then blur:Destroy() end
		if cc then cc:Destroy() end
	end)
end

-- ===== WIRING =====
event.OnClientEvent:Connect(function(action, payload)
	if action == "Show" and typeof(payload) == "table" then
		session += 1
		local my = session
		task.delay(SHOW_DELAY, function()
			if session == my then build(payload, my) end
		end)
	elseif action == "Hide" then
		hide()
	end
end)

player.CharacterAdded:Connect(function() hide() end)