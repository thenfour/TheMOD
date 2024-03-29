-- http://d19ulaff0trnck.cloudfront.net/sites/default/files/novation/downloads/4080/launchpad-programmers-reference.pdf

local CC = require('namespace')

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

-- red / green are 0-3.
function CalculateVelocity(red, green)
	-- mask:
  -- 0x30 bit 4-5: green LED brightness (0, 1, 2, 3)
  -- 0x08 bit 3  : clear the other buffer's copy of this LED (for double buffer support)
  -- 0x04 bit 2  : copy. if 1, write to both buffers.
  -- 0x03 bit 0-1: red LED brightness.
  return red + (green * 16) + 0x0
end

function CalculateMessage(x, y, red, green)
  -- - 0x90 = on
  -- - 0x80 = off
  -- - 0xb0 = CC change
  if y == 0 then
  	return 0xb0
  end
  if red == 0 and green == 0 then
  	return 0x80
  end
  return 0x90
end

function CalculateData(x, y, red, green)
  -- - top row (round buttons) are CC from 0x68 - 0x6f
  -- - each row is 9 buttons long, starting at 0x10 boundaries. So,
  -- - 1st row is 0x00 - 0x08
  -- - 2nd row is 0x10 - 0x18
  -- - ...
  if y == 0 then
  	return 0x68 + x
  end
  return ((y - 1) * 0x10) + x
end


------------------------------------------------------------------------------
-- in order to use (x,y) as table keys...
function XYToKey(x, y)
	return tostring(x) .. "," .. tostring(y)
end

function KeyToXY(k)
	local comma = string.find(k, ",")
	return tonumber(k:sub(1, comma - 1)), tonumber(k:sub(comma + 1))
end


------------------------------------------------------------------------------
-- red / green are 0-3.
-- brightness is 0-1 floating
function SetButtonLED(device, x, y, red, green, lpstate)
	-- this is an empty spot on the grid; don't send messages for it.
	if x == 8 and y == 0 then
		return
	end

	-- sanitize r/g
	red = math.floor(red + 0.5)
	green = math.floor(green + 0.5)
	if red < 0 then red = 0 end
	if green < 0 then green = 0 end
	if red > 3 then red = 3 end
	if green > 3 then green = 3 end

  -- http://d19ulaff0trnck.cloudfront.net/sites/default/files/novation/downloads/4080/launchpad-programmers-reference.pdf
  device:send { CalculateMessage(x, y, red, green), CalculateData(x, y, red, green), CalculateVelocity(red, green) }
  lpstate.launchpadUpdatedLEDs[XYToKey(x,y)] = true
end

------------------------------------------------------------------------------
function LaunchpadClear(device, lpstate)
  device:send { 0xb0, 0, 0 }
  --return
  --for x = 0, 8 do
  --	for y = 0, 8 do
  --		SetButtonLED(device, x, y, 0, 0)
  --	end
  --end
end

------------------------------------------------------------------------------
-- returns x,y,onoff where x/y are 0-based, and onoff is either true or false indicating if it's a note on or off.
function LaunchpadMidiToCoords(message)
	-- figures out the x/y coords of a given message, or nil
	-- message[1], message[2], message[3]
	if message[1] == 0xb0 then
		return (message[2] - 0x68), 0, (message[3] == 0x7f)
	end
	if message[1] == 0x90 then
		local y = math.floor(message[2] / 0x10)
		return message[2] - (y * 0x10), y + 1, message[3] == 0x7f
	end
	return nil
end

------------------------------------------------------------------------------
-- parses our simple 2-digit launchpad colors from a mapping. like "00" or "32" or whatever.
-- returns r,g for red/green components. each component is 0-3
--function ParseLaunchpadColor(colorStr)
--  return tonumber(colorStr:sub(1, 1)), tonumber(colorStr:sub(2, 2))
--end


------------------------------------------------------------------------------
function BitmapToString(bmp)
	local ret = ""
	for k,v in pairs(bmp) do
		ret = ret .. ("%s:%s "):format(k,v)
	end
	return ret
end

-- 1,2:3,4
function StringToBitmap(str)
	local ret = {}
	for xy,rg in str:gmatch("(%d+,%d+):(%d+,%d+)") do
		ret[xy] = rg
	end
	return ret
end


------------------------------------------------------------------------------
-- params are bits 0 or 1
-- http://d19ulaff0trnck.cloudfront.net/sites/default/files/novation/downloads/4080/launchpad-programmers-reference.pdf
-- 4 Copy    : If 1: copy the LED states from the new ‘displayed’ buffer to the new ‘updating’ buffer.
-- 3 Flash   : If 1: continually flip ‘displayed’ buffers to make selected LEDs flash.
-- 2 Update  : Set buffer 0 or buffer 1 as the new ‘updating’ buffer.
-- 0 Display : Set buffer 0 or buffer 1 as the new ‘displaying’ buffer.
function CalculateDBParam(copy, update, display)
	return 0x20 + (copy * 0x10) + (update * 4) + display
end

------------------------------------------------------------------------------
function LaunchpadDoubleBufferBegin(device, lpstate)
	local newUpdateBuffer = 1
	if lpstate.launchpadDisplayBuffer == 1 then
		newUpdateBuffer = 0
	end

	lpstate.launchpadUpdatedLEDs = {}

	-- basically we only want to create a copy of the display buffer to the back buffer,
	-- and start updating to the back buffer. this does that in 1 shot:
  device:send { 0xb0, 0, CalculateDBParam(1, newUpdateBuffer, lpstate.launchpadDisplayBuffer) }
end


------------------------------------------------------------------------------
-- if clearUnsetButtons is true, then all buttons that were not set since LaunchpadDoubleBufferBegin will be cleared.
function LaunchpadDoubleBufferEnd(device, lpstate, clearUnsetButtons)
	local newDisplayBuffer = 1
	if lpstate.launchpadDisplayBuffer == 1 then
		newDisplayBuffer = 0
	end

	if clearUnsetButtons then
	  for x = 0, 8 do
	  	for y = 0, 8 do
	  		--print(x, y)
	  		if not lpstate.launchpadUpdatedLEDs[XYToKey(x,y)] then
	  			SetButtonLED(device, x, y, 0, 0, lpstate)
	  		end
	  	end
	  end
	end

	-- just present it. so, no copy and just present the new display buffer.
  device:send { 0xb0, 0, CalculateDBParam(1, newDisplayBuffer, newDisplayBuffer) }
	lpstate.launchpadDisplayBuffer = newDisplayBuffer
end

