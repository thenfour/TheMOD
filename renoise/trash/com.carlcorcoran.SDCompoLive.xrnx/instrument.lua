
local CC = require('namespace')
require("utility")
require("globals")

-- {
-- 	"name" : "wtf+lol",
-- 	"layers" :
-- 	[
-- 		{ "instrument" : "wtf", "transpose" : "12", "keyRange" : "C3-C5", "gain" : "0" },
-- 		{ "instrument" : "lol", "transpose" : "12", "keyRange" : "C3-C5" }
-- 	]
-- }
--
-- or, can just be the name of a renoise instrument. like olde tymes.
-- 


------------------------------------------------------------------------------
-- renoise.song().instruments[].midi_input_properties.note_range, _observable 
--  -> [table with two numbers (0-119, c-4=48)]
function KeyRangeStringToValue(inp)
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
		return {0, 119}
	end
	local dashR = inp:find("-")
	if not dashR then
		print("Key range " .. inp .. " invalid. Should be like 'C3-C4'. No spaces, only 1 dash, no flats.")
		return {0, 119}
	end
	local startKey = KeyRangeStringToValue(inp:sub(1, dashR - 1))
	local endKey = KeyRangeStringToValue(inp:sub(dashR + 1))
	return { startKey, endKey }
end


------------------------------------------------------------------------------
function EnsureProgramObject(inp)
	if inp.theModProgram then-- detect our program object. this is messy but whatevs
		--print("CREATE PROGRAM (existing): " .. inp.name)
		return inp
	end

	if type(inp) == "string" then
		--print("CREATE PROGRAM (string): " .. inp)
		-- create a basic program with an untransposed whole-keyboard single layer instrument.
		return {
			name = inp,
			theModProgram = true,
			layers = { { instrument = inp, transpose = 0, keyRange = { 0, 119 }, gain = 0 } }
		}
	end

	--print("CREATE PROGRAM (json)")

	-- convert json-deserialized object to instrument table
	local ret = {
		name = inp["name"],
		theModProgram = true,
		layers = {}
	}

	--print(" -> layer count: " .. #inp["layers"])

	for layerIndex = 1, #inp["layers"] do
		local jsonLayer = inp["layers"][layerIndex]

		local keyRange = ParseKeyRange(jsonLayer["keyRange"])
		
		local gain = jsonLayer["gain"]
		if not gain then
			gain = 0.0
		end
		gain = tonumber(gain)

		--print(jsonLayer["instrument"] .. " gain: " .. tostring(gain))

		if gain > 6 then
			renoise.app():show_error(string.format("!!!! Gain can't be greater than 6db. %s", jsonLayer["instrument"]))
		end
		local transpose = 0
		if jsonLayer["transpose"] then
			transpose = tonumber(jsonLayer["transpose"])
		end
		--print("transpose -> " .. transpose)

		--for w in keyRange do LogMessage(w) end
		--print(" -> jsonLayer[\"keyRange\"]" .. jsonLayer["keyRange"])
		--print(" -> keyRange[1]: " .. keyRange[1])
		--print(" -> keyRange[2]: " .. keyRange[2])

		local newLayer = {
			instrument = jsonLayer["instrument"],
			transpose = transpose,
			keyRange = keyRange,
			gain = gain
		}

		table.insert(ret.layers, newLayer)

		--print(" -> #ret.layers: " .. #ret.layers)
	end

	return ret
end


------------------------------------------------------------------------------
-- used to represent a blank instrument, makes some code simpler
CC.nullProgram = {
	name = "(nil)",
	theModProgram = true,
	layers = { { instrument = "(none)", transpose = 0, keyRange = { 0, 119 }, gain = 0 } }
}


