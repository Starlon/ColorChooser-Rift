Library = Library or {}
Library.ColorChooser = {}

local DEFAULT_PIXEL = 5

--- Return RGB values from HSV colorspace values.
-- @usage HSV2RGB(h, s, v)
-- @param h Hue value, ranging from 0 to 1
-- @param s Satration value, ranging from 0 to 1
-- @param v Value value, ranging from 0 to 1
-- @return Red, green, and blue values from the HSV values provided.
local floor = math.floor
local function HSV2RGB(h, s, v)
	local i
	local f, w, q, t
	local hue
	
	if s == 0.0 then
		r = v
		g = v
		b = v
	else
		hue = h
		if hue == 1.0 then
			hue = 0.0
		end
		hue = hue * 6.0
		
		i = floor(hue)
		f = hue - i
		w = v * (1.0 - s)
		q = v * (1.0 - (s * f))
		t = v * (1.0 - (s * (1.0 - f)))
		if i == 0 then
			r = v
			g = t
			b = w
		elseif i == 1 then
			r = q
			g = v
			b = w
		elseif i == 2 then
			r = w
			g = v
			b = t
		elseif i == 3 then
			r = w
			g = q
			b = v
		elseif i == 4 then
			r = t
			g = w
			b = v
		elseif i == 5 then
			r = v
			g = w
			b = q
		end
	end
	
	return r, g, b
end

local widget
Library.ColorChooser.CreateWidget = function(frame, handler, pixel)
	local r, g, b, a = 0, 0, 0, 1
	local pixel = pixel or 5
	frame.textures = frame.textures or {}

	local x, y = 0, 0
	local count = 5
	local draw = function(pixel)
		for h = 0, 360, 360/33 do
			for v = 99, 0, -(100/8) do
				local s = 100
				y = count * pixel
				count = count + 1
					
				local texture = select(2, table.remove(frame.textures)) or UI.CreateFrame("Frame", "Pixel", frame)
				texture:ClearAll()
				texture:SetMouseMasking("full")	
				texture:SetPoint("TOPLEFT", frame, "TOPLEFT", x, y)
			
				local r, g, b = HSV2RGB(h/360, s/100, v/100)
				texture:SetBackgroundColor(r, g, b)
				texture:SetWidth(pixel)
				texture:SetHeight(pixel)
		
				texture.Event.LeftClick = function()
					handler(r, g, b)
				end
				table.insert(frame.textures, texture)
			end
			x = x + pixel
			count = 0
		end
		count = 0
		for v = 99, 0, -(100/8)  do
			local h, s, v = 0, 0, v
	
			y = count * pixel
			count = count + 1
	
			local texture = select(2, table.remove(frame.textures)) or UI.CreateFrame("Frame", "Pixel", frame)
			texture:ClearAll()
			texture:SetMouseMasking("full")
			texture:SetPoint("TOPLEFT", frame, "TOPLEFT", x, y)
			
			local r, g, b = HSV2RGB(h/360, s/100, v/100)
			texture:SetBackgroundColor(r, g, b)
			texture:SetWidth(pixel)
			texture:SetHeight(pixel)
	
			texture.Event.LeftClick = function()
				handler(r, g, b)
			end
			table.insert(frame.textures, texture)
		end
	end
	frame.ResizePixel = function(self, pixel)
		pixel = pixel or DEFAULT_PIXEL
		count, x, y = pixel, 0, 0
		draw(pixel)
	end
	frame:ResizePixel(DEFAULT_PIXEL)
	return frame
end

local ctx = UI.CreateContext("ColorChooser")
local frame
table.insert(Command.Slash.Register("colorchooser"), {function (commands)	

	local show = commands:match("^show")
	local resize = commands:match("^resize (%d+)")
	if show then
		frame = UI.CreateFrame("Frame", "ColorChooser", ctx)
		frame:SetPoint("CENTER", UIParent, "CENTER")
		frame:SetVisible(true)
		local pixel = 8
		local handler = function(r, g, b)
			print(string.format("%02x%02x%02x", r*256, g*256, b*256))
		end
		local cc = Library.ColorChooser.CreateWidget(frame, handler, pixel)
	elseif resize then
		if frame then 
			frame:SetVisible(false)
			frame:ResizePixel(tonumber(resize))
		end
	end

end, "ColorChooser", "Slash"})

