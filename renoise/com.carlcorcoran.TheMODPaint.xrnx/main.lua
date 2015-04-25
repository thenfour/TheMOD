local CC = require('namespace')
require("renoise/http/json")
require("utility")

-- global settings
CC.deviceName = "Launchpad Mini"
CC.AppMode_PaletteSelect = "select"
CC.AppMode_Paint = "paint"
CC.paletteBitmap = {}
CC.paddingTop = 1-- to allow mapping the first row of buttons and not interfering

-- if this tool is a class, these are the members. :(
CC.outputDevice = nil
CC.inputDevice = nil
CC.userBitmap = {}-- current bitmap maps (x,y) to (r,g)
CC.selectedColor = nil
CC.appMode = CC.AppMode_Paint
CC.dialog = nil
CC.txtBitmap = nil


------------------------------------------------------------------------------
function destroyGUI()
  if not CC.dialog then
    CC.txtBitmap = nil
    return
  end
  if CC.dialog.visible then
    CC.dialog:close()
  end
  CC.txtBitmap = nil
end

------------------------------------------------------------------------------
-- create our GUI.
function ensureUICreated()
  if CC.dialog and CC.dialog.visible then
    CC.dialog:show()
    return
  end
  
  local vb = renoise.ViewBuilder()

  CC.txtBitmap = vb:multiline_textfield {
    edit_mode = true,
    width = 800,
    height = 600,
    font = "mono",-- http://xrnx.googlecode.com/svn-history/r706/trunk/Documentation/Renoise.ViewBuilder.API.lua
    --style = "body",
    text = "the mod paint ..."
  }

  CC.dialog = renoise.app():show_custom_dialog("The MOD Paint", vb:column {
    id = "theMODDialog",
    margin = renoise.ViewBuilder.DEFAULT_CONTROL_MARGIN,
    vb:row {
      CC.txtBitmap
    }
  })
end



------------------------------------------------------------------------------
function RefreshDisplay()
	local bmp = CC.userBitmap
	if CC.appMode == CC.AppMode_PaletteSelect then
		bmp = CC.paletteBitmap
	end

	LaunchpadClear(CC.outputDevice)
	for k,v in pairs(bmp) do
		local x, y = KeyToXY(k)
		local r, g = KeyToXY(v)
		SetButtonLED(CC.outputDevice, x, y, r, g)
	end

	-- because this is how i have my midi mapping set up, for fun highlight them.
	SetButtonLED(CC.outputDevice, 0, 0, 3, 3)
	SetButtonLED(CC.outputDevice, 1, 0, 3, 0)
	SetButtonLED(CC.outputDevice, 2, 0, 0, 3)
end


------------------------------------------------------------------------------
function OnExport()
	ensureUICreated()
	CC.txtBitmap.text = BitmapToString(CC.userBitmap)
end

------------------------------------------------------------------------------
function OnImport()
	ensureUICreated()
	CC.userBitmap = StringToBitmap(CC.txtBitmap.text)
	RefreshDisplay()
end


------------------------------------------------------------------------------
function OnDisplayPalette()
  LaunchpadClear(CC.outputDevice)
	CC.appMode = CC.AppMode_PaletteSelect
	RefreshDisplay()
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
function OnMidiMessage(message)
	local x, y, on = LaunchpadMidiToCoords(message)
	if not x then
		return
	end
	if not on then
		return
	end
	if y < CC.paddingTop then
		return
	end

	if CC.appMode == CC.AppMode_PaletteSelect then
		CC.selectedColor = CC.paletteBitmap[XYToKey(x,y)]
		if CC.selectedColor then
			local r,g = KeyToXY(CC.selectedColor)
			if r == 0 and g == 0 then
				CC.selectedColor = nil
			end
		end
		CC.appMode = CC.AppMode_Paint
		RefreshDisplay()
	elseif CC.appMode == CC.AppMode_Paint then
		CC.userBitmap[XYToKey(x,y)] = CC.selectedColor
		local r, g = 0, 0
		if CC.selectedColor then
			r, g = KeyToXY(CC.selectedColor)
		end
		SetButtonLED(CC.outputDevice, x, y, r, g)
		OnExport()
	end

end

------------------------------------------------------------------------------
function OnTheMODPaintStop()
	destroyGUI()

	CC.userBitmap = {}
	CC.selectedColor = "3,3"
	CC.appMode = CC.AppMode_Paint

	if CC.outputDevice then
		LaunchpadClear(CC.outputDevice)
	  CC.outputDevice:close()
	end
	CC.outputDevice = nil

	if CC.inputDevice then
	  CC.inputDevice:close()
	end
	CC.inputDevice = nil
end


------------------------------------------------------------------------------
function OnTheMODPaintStart()
	OnTheMODPaintStop()
	CC.inputDevice = renoise.Midi.create_input_device(CC.deviceName, OnMidiMessage)
	CC.outputDevice = renoise.Midi.create_output_device(CC.deviceName)

  if not CC.inputDevice then
  	renoise.app():show_warning('Input device not available')
  	return
  end

  if not CC.outputDevice then
  	renoise.app():show_warning('Output device not available')
  	return
  end

  CC.paletteBitmap = StringToBitmap(
  	"2,3:0,0 3,3:0,1 4,3:0,2 5,3:0,3 " ..
  	"2,4:1,0 3,4:1,1 4,4:1,2 5,4:1,3 " ..
  	"2,5:2,0 3,5:2,1 4,5:2,2 5,5:2,3 " ..
  	"2,6:3,0 3,6:3,1 4,6:3,2 5,6:3,3 "
  	)

	ensureUICreated()
	RefreshDisplay()
end



------------------------------------------------------------------------------
-- midi mappings & menu items. Note that these are separate from the configurable ones in your JSON.
-- these are like, fundamental app things.
renoise.tool():add_midi_mapping {
  name = "TheMODPaint:ShowPalette",
  invoke = OnDisplayPalette
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:The MOD Paint - Show Palette",
  invoke = OnDisplayPalette
}

renoise.tool():add_midi_mapping {
  name = "TheMODPaint:Export",
  invoke = OnExport
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:The MOD Paint - Export...",
  invoke = OnExport
}

renoise.tool():add_midi_mapping {
  name = "TheMODPaint:Import",
  invoke = OnImport
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:The MOD Paint - Import...",
  invoke = OnImport
}


renoise.tool():add_midi_mapping {
  name = "TheMODPaint:Start",
  invoke = OnTheMODPaintStart
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:The MOD Paint - (re)start",
  invoke = OnTheMODPaintStart
}


renoise.tool():add_midi_mapping {
  name = "TheMODPaint:Stop",
  invoke = OnTheMODPaintStop
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:The MOD Paint - stop",
  invoke = OnTheMODPaintStop
}

