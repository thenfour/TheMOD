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
  return red + (green * 16) + 0xC
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

-- red / green are 0-3.
-- brightness is 0-1 floating
function SetButtonLED(device, x, y, red, green)
  -- http://d19ulaff0trnck.cloudfront.net/sites/default/files/novation/downloads/4080/launchpad-programmers-reference.pdf
  device:send { CalculateMessage(x, y, red, green), CalculateData(x, y, red, green), CalculateVelocity(red, green) }
end

function LaunchpadClear(device)
  device:send { 0xb0, 0, 0 }
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
function LoadMapping()
  local mappingFileName = renoise.song().file_name .. ".themod.json"
  local src = RemoveComments(readTextFile(mappingFileName));

  local ok, m = pcall(json.decode, src)
  if not ok then
    renoise.app():show_message("Your json failed to parse.")
    return nil
  end
  
  return m
end

------------------------------------------------------------------------------
-- parses our simple 2-digit launchpad colors from a mapping. like "00" or "32" or whatever.
-- also will follow references if you enclose it in [].
-- returns r,g for red/green components. each component is 0-3
function ParseLaunchpadColor(mapping, colorStr, recursionDepth)
	if not recursionDepth then
		recursionDepth = 0
	end
	if recursionDepth > 10 then
		return 0, 0
	end

	local refColor = mapping["Settings"]["Colors"][colorStr]

	if refColor then
		return ParseLaunchpadColor(mapping, refColor, recursionDepth + 1)
	end

	-- seems that we have a literal color. parse it.
  return tonumber(colorStr:sub(1, 1)), tonumber(colorStr:sub(2, 2))
end


-- Row 0 / Row A-H
-- Column 1-8
function GetButtonInfo(mapping, x, y)
	local rowID = "Row " .. ("0ABCDEFGH"):sub(y+1,y+1)
	local columnID = "Column " .. tostring(x + 1)
	if not mapping["Mappings"][rowID] then
		return nil
	end
	return mapping["Mappings"][rowID][columnID]
end


