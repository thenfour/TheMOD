-- http://d19ulaff0trnck.cloudfront.net/sites/default/files/novation/downloads/4080/launchpad-programmers-reference.pdf
logOutput = nil

--don't forget about 
--renoise.app():show_message(message)
--renoise.app():show_error(message)
--renoise.app():show_warning(message)
--renoise.app():show_status(message)
function error(message)
	print(message)
	renoise.app():show_error(message)
end


function alert(message)
	print(message)
	renoise.app():show_message(message)
end

function message(m)
	return alert(m)
end

function log(m)
	print(m)
	if logOutput then
  	--logOutput:add_line(string.sub(m, 1, CC.logTruncateColumn))
  	logOutput:add_line(m)
		logOutput:scroll_to_last_line()
	end
end


function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end


function StringStartsWith2(str, match)
   return string.sub(str,1,string.len(match))==match
end

function StringStartsWith(str, i, find)
	local ret = str:sub(i, i + #find - 1) == find
	--print("StringStartsWith(" .. i .. ", " .. find .. ") => " .. tostring(ret))
	return ret;
end

function SkipStringLiteral(str, i, quote)
	for i = i, #str do
		-- find first non-escaped quote. return after it.
		local c = str:sub(i,i)
		if c == "\\" then
			i = i + 1
		elseif c == quote then
			return i + 1
		end
	end
end

function SkipLineComment(str, i, quote)
	for i = i, #str do
		-- find newline
		local c = str:sub(i,i)
		if (c == "\r") or (c == "\n") then
			return i
		end
	end
end

function SkipBlockComment(str, i, quote)
	for i = i, #str do
		-- find "*/"; return after it.
		if StringStartsWith(str, i, "*/") then
			return i + 2
		end
	end
	return i
end

function RemoveComments(str)
	local r = ""

	--print("INPUT:")
	--rint(str)
	local i = 1

	while true do
		if i > #str then
			break
		end

		local c = str:sub(i,i)
		if (c == "\"") or (c == "\'") then
			r = r .. c
			local i2 = SkipStringLiteral(str, i + 1, c)
			r = r .. str:sub(i + 1, i2)
			i = i2 + 1
		elseif StringStartsWith(str, i, "//") then
			i = SkipLineComment(str, i)
		elseif StringStartsWith(str, i, "/*") then
			i = SkipBlockComment(str, i)
		else
			r = r .. c
			i = i + 1
		end
	end

	--print("OUTPUT:")
	--print(r)

	return r
end



------------------------------------------------------------------------------
function readTextFile(file)
    local f = io.open(file, "r")
    local content = f:read("*all")
    f:close()
    return content
end






------------------------------------------------------------------------------
-- LAUNCHPAD STUFF

-- -- red / green are 0-3.
-- function CalculateVelocity(red, green)
-- 	-- mask:
--   -- 0x30 bit 4-5: green LED brightness (0, 1, 2, 3)
--   -- 0x08 bit 3  : clear the other buffer's copy of this LED (for double buffer support)
--   -- 0x04 bit 2  : copy. if 1, write to both buffers.
--   -- 0x03 bit 0-1: red LED brightness.
--   return red + (green * 16) + 0xC
-- end

-- function CalculateMessage(x, y, red, green)
--   -- - 0x90 = on
--   -- - 0x80 = off
--   -- - 0xb0 = CC change
--   if y == 0 then
--   	return 0xb0
--   end
--   if red == 0 and green == 0 then
--   	return 0x80
--   end
--   return 0x90
-- end

-- function CalculateData(x, y, red, green)
--   -- - top row (round buttons) are CC from 0x68 - 0x6f
--   -- - each row is 9 buttons long, starting at 0x10 boundaries. So,
--   -- - 1st row is 0x00 - 0x08
--   -- - 2nd row is 0x10 - 0x18
--   -- - ...
--   if y == 0 then
--   	return 0x68 + x
--   end
--   return ((y - 1) * 0x10) + x
-- end

-- ------------------------------------------------------------------------------
-- function LoadMapping()
--   local mappingFileName = renoise.song().file_name .. ".themod.json"
--   local src = RemoveComments(readTextFile(mappingFileName));

--   local ok, m = pcall(json.decode, src)
--   if not ok then
--     renoise.app():show_message("Your json failed to parse.")
--     return nil
--   end

--   return m
-- end

-- ------------------------------------------------------------------------------
-- -- parses our simple 2-digit launchpad colors from a mapping. like "00" or "32" or whatever.
-- -- also will follow references if you enclose it in [].
-- -- returns r,g for red/green components. each component is 0-3
-- function ParseLaunchpadColor(mapping, colorStr, recursionDepth)
-- 	if not recursionDepth then
-- 		recursionDepth = 0
-- 	end
-- 	if recursionDepth > 10 then
-- 		return 0, 0
-- 	end

-- 	local refColor = mapping["Settings"]["Colors"][colorStr]

-- 	if refColor then
-- 		return ParseLaunchpadColor(mapping, refColor, recursionDepth + 1)
-- 	end

-- 	-- seems that we have a literal color. parse it.
--   return tonumber(colorStr:sub(1, 1)), tonumber(colorStr:sub(2, 2))
-- end


-- -- Row 0 / Row A-H
-- -- Column 1-8
-- function GetButtonInfo(mapping, x, y)
-- 	local rowID = "Row " .. ("0ABCDEFGH"):sub(y+1,y+1)
-- 	local columnID = "Column " .. tostring(x + 1)
-- 	if not mapping["Mappings"][rowID] then
-- 		return nil
-- 	end
-- 	return mapping["Mappings"][rowID][columnID]
-- end



-- ------------------------------------------------------------------------------
-- -- in order to use (x,y) as table keys...
-- function XYToKey(x, y)
-- 	return tostring(x) .. "," .. tostring(y)
-- end

-- function KeyToXY(k)
-- 	local comma = string.find(k, ",")
-- 	return tonumber(k:sub(1, comma - 1)), tonumber(k:sub(comma + 1))
-- end


-- ------------------------------------------------------------------------------
-- -- red / green are 0-3.
-- -- brightness is 0-1 floating
-- function SetButtonLED(device, x, y, red, green, lpstate)
-- 	-- this is an empty spot on the grid; don't send messages for it.
-- 	if x == 8 and y == 0 then
-- 		return
-- 	end

-- 	-- sanitize r/g
-- 	red = math.floor(red + 0.5)
-- 	green = math.floor(green + 0.5)
-- 	if red < 0 then red = 0 end
-- 	if green < 0 then green = 0 end
-- 	if red > 3 then red = 3 end
-- 	if green > 3 then green = 3 end

--   -- http://d19ulaff0trnck.cloudfront.net/sites/default/files/novation/downloads/4080/launchpad-programmers-reference.pdf
--   device:send { CalculateMessage(x, y, red, green), CalculateData(x, y, red, green), CalculateVelocity(red, green) }
--   lpstate.launchpadUpdatedLEDs[XYToKey(x,y)] = true
-- end

-- ------------------------------------------------------------------------------
-- function LaunchpadClear(device, lpstate)
--   device:send { 0xb0, 0, 0 }
--   --return
--   --for x = 0, 8 do
--   --	for y = 0, 8 do
--   --		SetButtonLED(device, x, y, 0, 0)
--   --	end
--   --end
-- end

-- ------------------------------------------------------------------------------
-- -- returns x,y,onoff where x/y are 0-based, and onoff is either true or false indicating if it's a note on or off.
-- function LaunchpadMidiToCoords(message)
-- 	-- figures out the x/y coords of a given message, or nil
-- 	-- message[1], message[2], message[3]
-- 	if message[1] == 0xb0 then
-- 		return (message[2] - 0x68), 0, (message[3] == 0x7f)
-- 	end
-- 	if message[1] == 0x90 then
-- 		local y = math.floor(message[2] / 0x10)
-- 		return message[2] - (y * 0x10), y + 1, message[3] == 0x7f
-- 	end
-- 	return nil
-- end

-- ------------------------------------------------------------------------------
-- -- parses our simple 2-digit launchpad colors from a mapping. like "00" or "32" or whatever.
-- -- returns r,g for red/green components. each component is 0-3
-- --function ParseLaunchpadColor(colorStr)
-- --  return tonumber(colorStr:sub(1, 1)), tonumber(colorStr:sub(2, 2))
-- --end


-- ------------------------------------------------------------------------------
-- function BitmapToString(bmp)
-- 	local ret = ""
-- 	for k,v in pairs(bmp) do
-- 		ret = ret .. ("%s:%s "):format(k,v)
-- 	end
-- 	return ret
-- end

-- -- 1,2:3,4
-- function StringToBitmap(str)
-- 	local ret = {}
-- 	for xy,rg in str:gmatch("(%d+,%d+):(%d+,%d+)") do
-- 		ret[xy] = rg
-- 	end
-- 	return ret
-- end


-- ------------------------------------------------------------------------------
-- -- params are bits 0 or 1
-- -- http://d19ulaff0trnck.cloudfront.net/sites/default/files/novation/downloads/4080/launchpad-programmers-reference.pdf
-- -- 4 Copy    : If 1: copy the LED states from the new ‘displayed’ buffer to the new ‘updating’ buffer.
-- -- 3 Flash   : If 1: continually flip ‘displayed’ buffers to make selected LEDs flash.
-- -- 2 Update  : Set buffer 0 or buffer 1 as the new ‘updating’ buffer.
-- -- 0 Display : Set buffer 0 or buffer 1 as the new ‘displaying’ buffer.
-- function CalculateDBParam(copy, update, display)
-- 	return 0x20 + (copy * 0x10) + (update * 4) + display
-- end

-- ------------------------------------------------------------------------------
-- function LaunchpadDoubleBufferBegin(device, lpstate)
-- 	local newUpdateBuffer = 1
-- 	if lpstate.launchpadDisplayBuffer == 1 then
-- 		newUpdateBuffer = 0
-- 	else
-- 		lpstate.launchpadDisplayBuffer = 0
-- 	end

-- 	lpstate.launchpadUpdatedLEDs = {}

-- 	-- basically we only want to create a copy of the display buffer to the back buffer,
-- 	-- and start updating to the back buffer. this does that in 1 shot:
--   device:send { 0xb0, 0, CalculateDBParam(1, newUpdateBuffer, lpstate.launchpadDisplayBuffer) }
-- end


-- ------------------------------------------------------------------------------
-- -- if clearUnsetButtons is true, then all buttons that were not set since LaunchpadDoubleBufferBegin will be cleared.
-- function LaunchpadDoubleBufferEnd(device, lpstate, clearUnsetButtons)
-- 	local newDisplayBuffer = 1
-- 	if lpstate.launchpadDisplayBuffer == 1 then
-- 		newDisplayBuffer = 0
-- 	end

-- 	if clearUnsetButtons then
-- 	  for x = 0, 8 do
-- 	  	for y = 0, 8 do
-- 	  		--print(x, y)
-- 	  		if not lpstate.launchpadUpdatedLEDs[XYToKey(x,y)] then
-- 	  			SetButtonLED(device, x, y, 0, 0, lpstate)
-- 	  		end
-- 	  	end
-- 	  end
-- 	end

-- 	-- just present it. so, no copy and just present the new display buffer.
--   device:send { 0xb0, 0, CalculateDBParam(1, newDisplayBuffer, newDisplayBuffer) }
-- 	lpstate.launchpadDisplayBuffer = newDisplayBuffer
-- end





--------------------------------------------------------------------------------------------
class "ModColor"

function ModColor:__init(s)
	if type(s) == "string" then
		self.name = s
		self.rgb = self:fromCSS(s)
		self.r = self.rgb[1]
		self.g = self.rgb[2]
		self.b = self.rgb[3]
	elseif type(s) == "ModColor" then
		self.name = s.name
		self.rgb = s.rgb
		self.r = s.r
		self.g = s.g
		self.b = s.b
	else
		assert(false, "unknown color format datatype: "..type(s))
	end
end


-- adapted from https://code.google.com/p/lua-files/source/browse/color.lua
-- returns in range of 0-1
function ModColor:fromCSS(s)
	if s == nil then return nil end
	if s:sub(1,1) == '#' then
		if #s < 4 then return end
		if #s == 4 then
			local r = tonumber(s:sub(2, 2), 16)
			local g = tonumber(s:sub(3, 3), 16)
			local b = tonumber(s:sub(4, 4), 16)
			if not r or not g or not b then return end
			r = (r * 16) + r
			g = (g * 16) + g
			b = (b * 16) + b
			return {r/255.0, g/255.0, b/255.0}
		end
		local r = tonumber(s:sub(2, 3), 16)
		local g = tonumber(s:sub(4, 5), 16)
		local b = tonumber(s:sub(6, 7), 16)
		if not r or not g or not b then return end

		return { r/255.0, g/255.0, b/255.0 }
	end
	if s:sub(1,1) == '%' then
		-- like %01
		local r = tonumber(s:sub(2,2))
		local g = tonumber(s:sub(3,3))
		assert(r ~= nil)
		assert(g ~= nil)
		assert(r < 4)
		assert(g < 4)
		-- input range is 0-3, and we want 3 to be 1.0 and 0 to be 0.0.
		-- so the resulting internal values will be 0.0, 0.33, 0.66, 1.0
		return { r / 3.0, g / 3.0, 0.0}
	end
end

function ModColor:toLaunchpadMiniColor()
	return {
		r = math.floor(self.r * 3. + .5),
		g = math.floor(self.g * 3. + .5),
		b = 0.0
	}
end

function ModColor:tostring()
	return self.name
end


function printWithDepth(depth, msg)
	log(string.rep("  ", depth)..msg)
end

function coalesce(o, ifnull)
	if o == nil then return ifnull end
	return o
end

-- function to convert an object to string, and you provide a function if the object is not null to do the conversion
function coalesceToString(obj, toStringFnIfNotNull)
	if obj == nil then return "nil" end
	if toStringFnIfNotNull then
		return toStringFnIfNotNull(obj)
	end
	return tostring(obj)
end





--------------------------------------------------------------------------------------------


class 'Stopwatch'
-- local s = Stopwatch()
-- s:tostring()

function Stopwatch:__init()
	self.startTime = os.clock()
	--log("starting stopwatch @ "..self.startTime)
end


function Stopwatch:tostring()
	local elapsed = os.clock() - self.startTime-- already in seconds.
	--log("stopwatch reporting @ "..os.clock())
	return string.format("%.1f", elapsed)
end






--------------------------------------------------------------------------------------------
-- linq-ish stuff. these all operate only on values, not keys.
function table.where(t, fn)
	local ret = { }
	for _,v in pairs(t) do
		if fn(v) then table.insert(v) end
	end
	return ret
end

function table.firstOrDefault(t, def, fn)
	for _,v in pairs(t) do
		if fn(v) then return v end
	end
	return def
end

function table.first(t, fn)
	return table.firstOrDefault(t, nil, fn)
end

function table.any(t, fn)
	for _,v in pairs(t) do
		if fn(v) then return true end
	end
	return false
end

function table.select(t, fn)
	local ret = { }
	for _,v in pairs(t) do
		table.insert(ret, fn(v))
	end
	return ret
end


