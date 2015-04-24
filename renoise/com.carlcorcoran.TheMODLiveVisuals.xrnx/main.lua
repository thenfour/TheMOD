local CC = require('namespace')
require("renoise/http/json")
require("utility")

-- if this tool is a class, these are the members. :(
CC.mapping = nil
CC.outputDevice = nil
CC.inputDevice = nil
CC.oscClient = nil
CC.radioGroups = {}-- maps radiogroup to active button {x,y}
CC.busyButtons = {}-- maps button to ref count of timers for it

-- in order to use (x,y) as table keys...
function XYToKey(x, y)
	return tostring(x) .. "," .. tostring(y)
end

function KeyToXY(k)
	local comma = string.find(k, ",")
	return tonumber(k:sub(1, comma - 1)), tonumber(k:sub(comma + 1))
end

------------------------------------------------------------------------------
function OnDisplayColorSample()
  LaunchpadClear(CC.outputDevice)
  for x = 0, 3 do
  	for y = 0, 3 do
	  	SetButtonLED(CC.outputDevice, x + 2, y + 3, x, y)
		end
  end
end

------------------------------------------------------------------------------
function GetCurrentButtonColor(x, y)
	local info = GetButtonInfo(CC.mapping, x, y)
	if not info then
		return nil
	end

	-- default color
	local r,g = ParseLaunchpadColor(CC.mapping, info["Color"])

	local radioGroup = info["RadioGroup"]
	if not radioGroup then
		print("not in a radio group")
		return r, g
	end

	-- highlight color
	local activeButtonForThisGroup = CC.radioGroups[radioGroup]
	if not activeButtonForThisGroup then
		return r, g-- no active button for this radio group
	end

	--print(("currently active button for group %s: %s"):format(radioGroup, activeButtonForThisGroup))
	if activeButtonForThisGroup ~= XYToKey(x, y) then
		return r, g-- active button is not this one.
	end

	return ParseLaunchpadColor(CC.mapping, "[Active]")
end

------------------------------------------------------------------------------
function IncBusy(x, y)
	local k = XYToKey(x,y)
	if not CC.busyButtons[k] then
		CC.busyButtons[k] = 1
		return
	end
	CC.busyButtons[k] = CC.busyButtons[k] + 1
end
function DecBusy(x, y)
	local k = XYToKey(x,y)
	if CC.busyButtons[k] == 1 then
		CC.busyButtons[k] = nil
		return
	end
	CC.busyButtons[k] = CC.busyButtons[k] - 1
end

------------------------------------------------------------------------------
function OnMidiMessage(message)
	--print(("dumpMIDI %X %X %X"):format(message[1], message[2], message[3]))
	local x, y, on = LaunchpadMidiToCoords(message)
	if not x then
		return
	end
	local info = GetButtonInfo(CC.mapping, x, y)
	if not info then
		return -- nothing configured for this button.
	end
	--print((" -> %u %u %s"):format(x, y, tostring(on)))

	-- highlight it because you pressed it.
	if on then
		local r, g = ParseLaunchpadColor(CC.mapping, "[Highlight]")
		IncBusy(x, y)
		SetButtonLED(CC.outputDevice, x, y, r, g)

		local radioGroup = info["RadioGroup"]
		if radioGroup then
			local oldButtonKey = CC.radioGroups[radioGroup]
			CC.radioGroups[radioGroup] = XYToKey(x,y)
			print(("-> new: %s"):format(CC.radioGroups[radioGroup]))
			if oldButtonKey then
				print(("old button in radio group %s: %s"):format(radioGroup, oldButtonKey))
				local otherx, othery = KeyToXY(oldButtonKey)
				if not CC.busyButtons[oldButtonKey] then -- don't do this if the button is currently "busy" being highlighted
					local otherr, otherg = GetCurrentButtonColor(otherx, othery)
					SetButtonLED(CC.outputDevice, otherx, othery, otherr, otherg)
				end
			end

		end
	else
		local proc = nil
		proc = function()
			DecBusy(x, y)
			local r, g = GetCurrentButtonColor(x, y)
			SetButtonLED(CC.outputDevice, x, y, r, g)
			renoise.tool():remove_timer(proc)
			print(("removing timer for %u, %u"):format(x, y))
		end

		renoise.tool():add_timer(proc, tonumber(CC.mapping["Settings"]["HighlightDuration"]))
	end

	-- send OSC actions if needed.
	if on then
		for k,v in pairs(info["OSC"]) do
			print("sending osc action: " .. v)
			CC.oscClient:send(renoise.Osc.Message(v))
		end
	end
end

------------------------------------------------------------------------------
function OnTheMODLiveVisualsStop()
	CC.radioGroups = {}
	CC.busyButtons = {}
	if CC.outputDevice then
		LaunchpadClear(CC.outputDevice)
	  CC.outputDevice:close()
	end
	CC.outputDevice = nil

	if CC.inputDevice then
	  CC.inputDevice:close()
	end
	CC.inputDevice = nil

	CC.oscClient = nil

	CC.mapping = nil
end


------------------------------------------------------------------------------
function OnTheMODLiveVisualsStart()
	OnTheMODLiveVisualsStop()
	CC.mapping = LoadMapping()
	CC.inputDevice = renoise.Midi.create_input_device(CC.mapping["Settings"]["Device"], OnMidiMessage)
	CC.outputDevice = renoise.Midi.create_output_device(CC.mapping["Settings"]["Device"])

  if not CC.inputDevice then
  	renoise.app():show_warning('Input device not available')
  	return
  end

  if not CC.outputDevice then
  	renoise.app():show_warning('Output device not available')
  	return
  end

	LaunchpadClear(CC.outputDevice)

	-- set initial button colors
	local x, y
	for x = 0, tonumber(CC.mapping["Settings"]["DeviceColumns"]) - 1 do
		for y = 0, tonumber(CC.mapping["Settings"]["DeviceRows"]) - 1 do
			local r, g = GetCurrentButtonColor(x, y)
			if r then
				SetButtonLED(CC.outputDevice, x, y, r, g)
			end
		end
	end

	-- open a socket connection to the OSC server
	local err
	CC.oscClient, err = renoise.Socket.create_client(
		CC.mapping["Settings"]["OSCHost"],
		tonumber(CC.mapping["Settings"]["OSCPort"]),
		renoise.Socket.PROTOCOL_UDP)

	if err then 
	  renoise.app():show_warning(("Failed to start the OSC client. Error: '%s'"):format(err))
	  return
	end

	renoise.app():show_warning('The MOD Live Visuals ready to rock')
end


------------------------------------------------------------------------------
-- midi mappings & menu items. Note that these are separate from the configurable ones in your JSON.
-- these are like, fundamental app things.
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:The MOD Live Visuals:Show Color Sample",
  invoke = OnDisplayColorSample
}


renoise.tool():add_midi_mapping {
  name = "TheMODLiveVisuals:Start",
  invoke = OnTheMODLiveVisualsStart
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:The MOD Live Visuals - (re)start",
  invoke = OnTheMODLiveVisualsStart
}


renoise.tool():add_midi_mapping {
  name = "TheMODLiveVisuals:Stop",
  invoke = OnTheMODLiveVisualsStop
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:The MOD Live Visuals - stop",
  invoke = OnTheMODLiveVisualsStop
}

