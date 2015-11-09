-- themod keyboard
-- 2015-10-22


logOutput = nil

local serialNumber = 0
function resetObjectIDs()
	serialNumber = 0
end

function getUniqueObjectID()
	serialNumber = serialNumber + 1
	return serialNumber
end

function getDirectoryName(s)
	local withoutLastSlash = s:match(".*[^/\\]") or ""
	--return withoutLastSlash or ""
	return withoutLastSlash:match("(.*)[/\\]") or ""
end

-- tests for above:
-- print(getDirectoryName("this:\\omg"))
-- print(getDirectoryName("c:\\this\\omg"))
-- print(getDirectoryName("omg"))
-- print(getDirectoryName(""))
-- print(getDirectoryName("\\this\\omg"))
-- print(getDirectoryName("\\omg"))
-- print(getDirectoryName("c:/this/omg"))
-- print(getDirectoryName("/usr/this/omg"))
-- print(getDirectoryName("/usr/this/omg/"))-- last slash ignored
	




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


function toBoolean(o)
	if o == nil then return false end
	local s = tostring(o)
	s = string.lower(s)
	if s == "" then return false end
	if s == "0" then return false end
	if s == "false" then return false end
	if s == "no" then return false end
	return true
end


function StringEndsWith2(str, match)
	return match == '' or string.sub(str,-string.len(match)) == match
end


------------------------------------------------------------------------------
-- renoise.song().instruments[].midi_input_properties.note_range, _observable 
--  -> [table with two numbers (0-119, c-4=48)]
function KeyRangeStringToValue(inp)
	if inp == nil then return nil end
	if tonumber(inp) ~= nil then
		return tonumber(inp)
	end
	-- inp is "G#3"
	inp = inp:upper();
	local octave = inp:sub(-1)
	local noteStr = inp:sub(1, #inp - 1)
	local note = 0

	if noteStr == "C" then note = 0
	elseif noteStr == "C#" then note = 1
	elseif noteStr == "D" then note = 2
	elseif noteStr == "D#" then note = 3
	elseif noteStr == "E" then note = 4
	elseif noteStr == "F" then note = 5
	elseif noteStr == "F#" then note = 6
	elseif noteStr == "G" then note = 7
	elseif noteStr == "G#" then note = 8
	elseif noteStr == "A" then note = 9
	elseif noteStr == "A#" then note = 10
	elseif noteStr == "B" then note = 11
	end

	local ret = note + (octave * 12)-- this results in C0 = 0, C1 = 12, C2 = 24, C3 = 36, C4=48, so no offset necessary.
	return ret
end

-- input = "C4-G#8"
-- output = { 48, 72 }
function ParseKeyRange(inp)
	if not inp then
		--print("missing key range")
		--renoise.app():show_error(string.format("!!!! Referenced device %s not found.", m["Devices"][deviceIndex]["Name"]))
		--print("Key range NULL")
		return {0, 119}
	end
	local dashR = inp:find("-")
	if not dashR then
		print("Key range " .. inp .. " invalid. Should be like 'C3-C4'. No spaces, only 1 dash, no flats.")
		return {0, 119}
	end
	--print("Key range " .. inp)
	local startKey = KeyRangeStringToValue(inp:sub(1, dashR - 1))
	local endKey = KeyRangeStringToValue(inp:sub(dashR + 1))
	return { startKey, endKey }
end




--------------------------------------------------------------------------------------------
function StringStartsWith2(str, match)
   return string.sub(str,1,string.len(match))==match
end

-- str = input string
-- i = position in str
-- find = query
function StringStartsWith(str, i, find)
	local ret = str:sub(i, i + #find - 1) == find
	--print("StringStartsWith(" .. i .. ", " .. find .. ") => " .. tostring(ret))
	return ret
end

function SkipStringLiteral(str, i, quote)
	for i = i, #str do
		-- find first non-escaped quote. return after it.
		local c = str:sub(i,i)
		if c == "\\" then
			i = i + 1
		elseif c == quote then
			return i --+ 1
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



--------------------------------------------------------------------------------------------
function readTextFile(file)
    local f = io.open(file, "r")
    if not f then
    	error("there was an error opening " .. file)
    	return nil
    end
    local content = f:read("*all")
    f:close()
    return content
end

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
	if s:sub(1,1) ~= '#' then return end
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



