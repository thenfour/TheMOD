
local CC = require('namespace')
require("globals")
require("figlet")

function ClearLog()
  if not CC.txtStatus then
    return
  end
  CC.txtStatus:clear()
end

function LogMessage(m)
  m = m:gsub("\\n","")
  if CC.enableTerminalOutput then print(m) end
  if not CC.txtStatus then
    return
  end
  -- here i truncate the column, because otherwise it will wrap and look terrible. I wish renoise could horizontally scroll
  CC.txtStatus:add_line(string.sub(m, 1, CC.logTruncateColumn))
end

function LogMessageH1(m)
  readfont (CC.H1Font .. ".flf")
  local t2 = ascii_art (m, true, true)
  for _, line in ipairs (t2) do
    LogMessage (" "..line)
  end
end

function LogMessageH2(m)
  readfont (CC.H2Font .. ".flf")
  local t2 = ascii_art (m, true, false)
  for _, line in ipairs (t2) do
    LogMessage ("    "..line)
  end
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



function DeviceNameExists(name)
  local availableDevices = renoise.Midi.available_input_devices()
  for adi = 1, #availableDevices do
    if availableDevices[adi] == name then
      return true
    end
  end
  return false
end

function InstrumentNameExists(name)
  for _,ri in pairs(renoise.song().instruments) do
    if ri.name == name then
      return true
    end
  end
  return false
end


-- string.len() returns BYTES; we need characters. counting characters in UTF-8 is easy: http://lua-users.org/wiki/LuaUnicode
function CharacterCount(str)
 local _, count = string.gsub(str, "[^\128-\193]", "")
 return count
end

function string.starts(String,Start)
  return string.sub(String,1,string.len(Start))==Start
end


-- DSP utilities
function dbToRatio(db)
    return 10 ^ (db/20)
end

function ratioToDB(ratio)
	return math.log10(ratio) * 20
end


function volumeToString(ratio)
	local db = ratioToDB(ratio)
	if db < 0 then
		return string.format("%.04f", db)
	end
	if db == 0 then
		return "±0"
	end
	return string.format("+%.04f", db)
end

