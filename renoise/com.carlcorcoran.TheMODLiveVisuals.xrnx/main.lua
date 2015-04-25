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
--CC.animationSpeed = tonumber(CC.mapping["Settings"]["AnimationSpeed"])
--CC.overlayBitmap = StringToBitmap(CC.mapping["Settings"]["AnimationOverlay"])
--CC.overlayWidth = tonumber(CC.mapping["Settings"]["AnimationOverlayWidth"])


------------------------------------------------------------------------------
function OnDisplayColorSample()
	LaunchpadDoubleBufferBegin(CC.outputDevice, CC)
  for x = 0, 3 do
  	for y = 0, 3 do
	  	SetButtonLED(CC.outputDevice, x + 2, y + 3, x, y, CC)
		end
  end
	LaunchpadDoubleBufferEnd(CC.outputDevice, CC, true)
end

------------------------------------------------------------------------------
function GetCurrentButtonColor(x, y)
	local info = GetButtonInfo(CC.mapping, x, y)
	if not info then
		return 0,0
	end

	-- default color
	local r,g = ParseLaunchpadColor(CC.mapping, info["Color"])

	local radioGroup = info["RadioGroup"]
	if not radioGroup then
		--print("not in a radio group")
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
	--print(("IncBusy for %u %u"):format(x,y))
	local k = XYToKey(x,y)
	if not CC.busyButtons[k] then
		CC.busyButtons[k] = 1
		return
	end
	CC.busyButtons[k] = CC.busyButtons[k] + 1
end

function DecBusy(x, y)
	--print(("DecBusy for %u %u"):format(x,y))
	local k = XYToKey(x,y)
	if not CC.busyButtons[k] or CC.busyButtons[k] == 1 then
		CC.busyButtons[k] = nil
		return
	end
	CC.busyButtons[k] = CC.busyButtons[k] - 1
end

function RenderDisplay()
	if not CC.outputDevice then
		return
	end
	LaunchpadDoubleBufferBegin(CC.outputDevice, CC)
	for x = 0,8 do
		for y = 0,8 do
			if not CC.busyButtons[XYToKey(x,y)] then
				local r, g = GetCurrentButtonColor(x, y)
				SetButtonLED(CC.outputDevice, x, y, r, g, CC)
			end
		end
	end
	LaunchpadDoubleBufferEnd(CC.outputDevice, CC, false)
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

	LaunchpadDoubleBufferBegin(CC.outputDevice, CC)

	-- highlight it because you pressed it.
	if on then
		local r, g = ParseLaunchpadColor(CC.mapping, "[Highlight]")
		IncBusy(x, y)
		SetButtonLED(CC.outputDevice, x, y, r, g, CC)

		local radioGroup = info["RadioGroup"]
		if radioGroup then
			local oldButtonKey = CC.radioGroups[radioGroup]
			CC.radioGroups[radioGroup] = XYToKey(x,y)
			--print(("-> new: %s"):format(CC.radioGroups[radioGroup]))
			if oldButtonKey then
				--print(("old button in radio group %s: %s"):format(radioGroup, oldButtonKey))
				local otherx, othery = KeyToXY(oldButtonKey)
				if not CC.busyButtons[oldButtonKey] then -- don't do this if the button is currently "busy" being highlighted
					local otherr, otherg = GetCurrentButtonColor(otherx, othery)
					SetButtonLED(CC.outputDevice, otherx, othery, otherr, otherg, CC)
				end
			end

		end
	else
		local proc = nil
		proc = function()
			--print(("removing timer for %u, %u"):format(x, y))
			DecBusy(x, y)
			local r, g = GetCurrentButtonColor(x, y)
			SetButtonLED(CC.outputDevice, x, y, r, g, CC)
			renoise.tool():remove_timer(proc)
		end

		renoise.tool():add_timer(proc, tonumber(CC.mapping["Settings"]["HighlightDuration"]))
	end

	LaunchpadDoubleBufferEnd(CC.outputDevice, CC, false)

	-- send OSC actions if needed.
	if on then
		for k,v in pairs(info["OSC"]) do
			print("sending osc action: " .. v)
			CC.oscClient:send(renoise.Osc.Message(v))
		end
	end
end


function Dist(x1,y1,x2,y2)
	local dx = math.abs(x1-x2)
	local dy = math.abs(y1-y2)
	return math.sqrt(dx*dx+dy*dy)
end

------------------------------------------------------------------------------
function AnimFrame()
	local animTime = os.clock() - CC.animationStartTime

	-- find some theoretical point.
	local ang = animTime / 1.5 -- seconds per revolution
	ang = ang * 2 * math.pi
	local radius = (math.sin(animTime * 2) + 1.5) / 2 * 5
	local ptX = math.cos(ang) * radius
	local ptY = math.sin(ang) * radius

	ptX = ptX + 4
	ptY = ptY + 4

	local bmpOffsetX = animTime * 7

	LaunchpadDoubleBufferBegin(CC.outputDevice, CC)
	for x=0,7 do
		for y=0,7 do
			-- plasma or bitmap?
			local bmpX = x + bmpOffsetX
			bmpX = bmpX % CC.overlayWidth
			bmpX = math.floor(bmpX)
			local bmp = CC.overlayBitmap[XYToKey(bmpX,y)]
			if bmp then
				local r,g = KeyToXY(bmp)
				SetButtonLED(CC.outputDevice, x, y + 1, r,g, CC)
			else
				local sinArg1 = (Dist(x,y,ptX,ptY) / 13)-- assuming pt is always in the grid, max distance is sqrt(8*8)=11
				local sinArg2 = ((x * animTime) / 3) + ((y * animTime) / 4)
				SetButtonLED(CC.outputDevice, x, y + 1,
					sinArg1 * 2,
					(math.sin(sinArg2) + 1) / 2 * 2,
					CC)
			end
		end
	end
	LaunchpadDoubleBufferEnd(CC.outputDevice, CC, false)

	-- this makes certain that we're not overloading things. we care about things running smoothly and happy, not about smooth animation.
	renoise.tool():remove_timer(AnimFrame)
	renoise.tool():add_timer(AnimFrame, CC.animationSpeed)
end


------------------------------------------------------------------------------
function OnTheMODAnimateStop()
	if renoise.tool():has_timer(AnimFrame) then
		renoise.tool():remove_timer(AnimFrame)
	end
	CC.animationRunning = false
	RenderDisplay()
end

------------------------------------------------------------------------------
function OnTheMODAnimate()
	OnTheMODAnimateStop()

	CC.animationRunning = true
	CC.animationStartTime = os.clock()

	renoise.tool():add_timer(AnimFrame, CC.animationSpeed)
end


------------------------------------------------------------------------------
function OnTheMODLiveVisualsStop()

	OnTheMODAnimateStop()

	CC.radioGroups = {}
	CC.busyButtons = {}
	if CC.outputDevice then
		LaunchpadClear(CC.outputDevice, CC)
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

	CC.animationSpeed = tonumber(CC.mapping["Settings"]["AnimationSpeed"])
	CC.overlayBitmap = StringToBitmap(CC.mapping["Settings"]["AnimationOverlay"])
	CC.overlayWidth = tonumber(CC.mapping["Settings"]["AnimationOverlayWidth"])

  if not CC.inputDevice then
  	renoise.app():show_warning('Input device not available')
  	return
  end

  if not CC.outputDevice then
  	renoise.app():show_warning('Output device not available')
  	return
  end

	LaunchpadDoubleBufferBegin(CC.outputDevice, CC)
--	LaunchpadClear(CC.outputDevice, CC)

	-- set initial button colors
	local x, y
	for x = 0, tonumber(CC.mapping["Settings"]["DeviceColumns"]) - 1 do
		for y = 0, tonumber(CC.mapping["Settings"]["DeviceRows"]) - 1 do
			local r, g = GetCurrentButtonColor(x, y)
			if r then
				SetButtonLED(CC.outputDevice, x, y, r, g, CC)
			end
		end
	end

	LaunchpadDoubleBufferEnd(CC.outputDevice, CC, true)

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

	--renoise.app():show_warning('The MOD Live Visuals ready to rock')
end



------------------------------------------------------------------------------
function IsTrigger(m)
	if m:is_switch() then
		return m.boolean_value
	end
	return m.int_value > 62
end


-- midi mappings & menu items. Note that these are separate from the configurable ones in your JSON.
-- these are like, fundamental app things.
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:The MOD Live Visuals - Show Color Sample",
  invoke = OnDisplayColorSample
}


renoise.tool():add_midi_mapping {
  name = "TheMODLiveVisuals:Start",
  invoke = function(m) if IsTrigger(m) then OnTheMODLiveVisualsStart() end end
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:The MOD Live Visuals - (re)start",
  invoke = OnTheMODLiveVisualsStart
}


renoise.tool():add_midi_mapping {
  name = "TheMODLiveVisuals:Stop",
  invoke = function(m) if IsTrigger(m) then OnTheMODLiveVisualsStop() end end
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:The MOD Live Visuals - stop",
  invoke = OnTheMODLiveVisualsStop
}


renoise.tool():add_midi_mapping {
  name = "TheMODLiveVisuals:Animate",
  invoke = function(m) if IsTrigger(m) then OnTheMODAnimate() end end
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:The MOD Live Visuals - animate!",
  invoke = OnTheMODAnimate
}

renoise.tool():add_midi_mapping {
  name = "TheMODLiveVisuals:AnimateStop",
  invoke = function(m) if IsTrigger(m) then OnTheMODAnimateStop() end end
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:The MOD Live Visuals - animate stop",
  invoke = OnTheMODAnimateStop
}

