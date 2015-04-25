local CC = require('namespace')
require("renoise/http/json")
require("utility")

-- global settings
CC.deviceName = "Launchpad Mini"
CC.AppMode_PaletteSelect = "select"
CC.AppMode_Paint = "paint"
CC.paletteBitmap = {}
CC.viewMarginTop = 1-- to allow mapping the first row of buttons and not interfering
CC.viewMarginBottom = 0
CC.viewMarginRight = 1
CC.viewMarginLeft = 0
CC.userBitmapWidth = 48
CC.userBitmapHeight = 8
CC.deviceDisplayWidth = 9
CC.deviceDisplayHeight = 9

CC.animationSpeed = 10-- ms per frame

-- calculated
CC.viewportWidth = CC.deviceDisplayWidth - CC.viewMarginRight - CC.viewMarginLeft
CC.viewportHeight = CC.deviceDisplayHeight - CC.viewMarginTop - CC.viewMarginBottom

-- if this tool is a class, these are the members. :(
CC.outputDevice = nil
CC.inputDevice = nil
CC.userBitmap = {}-- current bitmap maps (x,y) to (r,g)
CC.selectedColor = nil
CC.appMode = CC.AppMode_Paint
CC.dialog = nil
CC.txtBitmap = nil
CC.scrollX = 0
CC.scrollY = 0
CC.launchpadDisplayBuffer = 0
CC.animationRunning = false

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
    width = 400,
    height = 300,
    font = "mono",-- http://xrnx.googlecode.com/svn-history/r706/trunk/Documentation/Renoise.ViewBuilder.API.lua
    --style = "body",
    text = "the mod paint ..."
  }

  CC.dialog = renoise.app():show_custom_dialog("The MOD Paint Exporter", vb:column {
    id = "theMODDialog",
    margin = renoise.ViewBuilder.DEFAULT_CONTROL_MARGIN,
    vb:row {
      CC.txtBitmap
    },
    vb:row {
    	vb:button
    	{
    		text = "Copy All",
    		notifier = function()
    			renoise.app():show_message("this is where i'd copy the text, if renoise COULD.")
    		end
    	}
  	}
  })
end


------------------------------------------------------------------------------
-- returns bool, bitmapX, bitmapY
function IsOnCanvas(deviceX, deviceY)
		local isOnCanvas = true
		if deviceX < CC.viewMarginLeft then
			return false
		elseif deviceY < CC.viewMarginTop then
			return false
		elseif deviceX >= CC.viewMarginLeft + CC.viewportWidth then
			return false
		elseif deviceY >= CC.viewMarginTop + CC.viewportHeight then
			return false
		end

		return
			true,
			deviceX - CC.viewMarginLeft + CC.scrollX,
			deviceY - CC.viewMarginTop + CC.scrollY
end

------------------------------------------------------------------------------
function RefreshDisplay()

	LaunchpadDoubleBufferBegin(CC.outputDevice, CC)

	if CC.appMode == CC.AppMode_PaletteSelect then
		for k,v in pairs(CC.paletteBitmap) do
			local x, y = KeyToXY(k)
			local r, g = KeyToXY(v)
			SetButtonLED(CC.outputDevice, x, y, r, g, CC)
		end
	elseif CC.appMode == CC.AppMode_Paint then
		for k,v in pairs(CC.userBitmap) do
			local bitmapX, bitmapY = KeyToXY(k)
			local viewX = bitmapX - CC.scrollX + CC.viewMarginLeft
			local viewY = bitmapY - CC.scrollY + CC.viewMarginTop
			local isInView = IsOnCanvas(viewX, viewY)
			if isInView then
				local r, g = KeyToXY(v)
				SetButtonLED(CC.outputDevice, viewX, viewY, r, g, CC)
			end
		end
	end

	-- because this is how i have my midi mapping set up, for fun highlight them.
	SetButtonLED(CC.outputDevice, 0, 0, 3, 3, CC)
	SetButtonLED(CC.outputDevice, 1, 0, 3, 0, CC)
	SetButtonLED(CC.outputDevice, 2, 0, 0, 3, CC)

	SetButtonLED(CC.outputDevice, 6, 0, 0, 3, CC)
	SetButtonLED(CC.outputDevice, 7, 0, 0, 3, CC)

	SetButtonLED(CC.outputDevice, 8, 1, 0, 3, CC)-- scroll up
	SetButtonLED(CC.outputDevice, 8, 2, 0, 3, CC)-- scroll down

	SetButtonLED(CC.outputDevice, 8, 7, 0, 3, CC)-- animate
	SetButtonLED(CC.outputDevice, 8, 8, 3, 0, CC)-- animate stop

	LaunchpadDoubleBufferEnd(CC.outputDevice, CC, true)
end


------------------------------------------------------------------------------
function OnExport()
	ensureUICreated()
	CC.appMode = CC.AppMode_Paint
	--RefreshDisplay()
	CC.txtBitmap.text = BitmapToString(CC.userBitmap)
end

------------------------------------------------------------------------------
function OnImport()
	ensureUICreated()
	CC.userBitmap = StringToBitmap(CC.txtBitmap.text)
	CC.appMode = CC.AppMode_Paint
	RefreshDisplay()
end


------------------------------------------------------------------------------
function OnTheMODScrollLeft()
	CC.scrollX = CC.scrollX - 1
	if CC.scrollX < 0 then
		CC.scrollX = 0
	end
	RefreshDisplay()
end

function OnTheMODScrollRight()
	CC.scrollX = CC.scrollX + 1
	if CC.scrollX > (CC.userBitmapWidth - CC.viewportWidth) then
		CC.scrollX = CC.userBitmapWidth - CC.viewportWidth
	end
	RefreshDisplay()
end

function OnTheMODScrollUp()
	CC.scrollY = CC.scrollY - 1
	if CC.scrollY < 0 then
		CC.scrollY = 0
	end
	RefreshDisplay()
end

function OnTheMODScrollDown()
	CC.scrollY = CC.scrollY + 1
	if CC.scrollY > (CC.userBitmapHeight - CC.viewportHeight) then
		CC.scrollY = CC.userBitmapHeight - CC.viewportHeight
	end
	RefreshDisplay()
end

------------------------------------------------------------------------------
function OnDisplayPalette()
	if CC.appMode == CC.AppMode_PaletteSelect then
		print ("on display palette - return to paint")
		CC.appMode = CC.AppMode_Paint
	else
		print ("on display palette")
		CC.appMode = CC.AppMode_PaletteSelect
	end
	RefreshDisplay()
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

	local isOnCanvas, bitmapX, bitmapY = IsOnCanvas(x, y)
	if not isOnCanvas then
		return
	end

	if CC.appMode == CC.AppMode_PaletteSelect then
		-- palette ignores margins
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
		-- convert "world" coord to user bitmap coord.
		CC.userBitmap[XYToKey(bitmapX,bitmapY)] = CC.selectedColor
		local r, g = 0, 0
		if CC.selectedColor then
			r, g = KeyToXY(CC.selectedColor)
		end
		LaunchpadDoubleBufferBegin(CC.outputDevice, CC)
		SetButtonLED(CC.outputDevice, x, y, r, g, CC)
		LaunchpadDoubleBufferEnd(CC.outputDevice, CC, false)

		OnExport()
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
			bmpX = bmpX % CC.userBitmapWidth
			bmpX = math.floor(bmpX)
			local bmp = CC.userBitmap[XYToKey(bmpX,y)]
			if bmp then
				local r,g = KeyToXY(bmp)
				SetButtonLED(CC.outputDevice, x, y + 1, r,g,CC)
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
end

------------------------------------------------------------------------------
function OnTheMODAnimate()
	OnTheMODAnimateStop()

	CC.animationRunning = true
	CC.animationStartTime = os.clock()

	renoise.tool():add_timer(AnimFrame, CC.animationSpeed)
end

------------------------------------------------------------------------------
function OnTheMODPaintStop()
	OnTheMODAnimateStop()

	CC.userBitmap = {}
	CC.selectedColor = "3,3"
	CC.appMode = CC.AppMode_Paint

	if CC.outputDevice then
		LaunchpadClear(CC.outputDevice, CC)
	  CC.outputDevice:close()
	end
	CC.outputDevice = nil

	if CC.inputDevice then
	  CC.inputDevice:close()
	end
	CC.inputDevice = nil

	destroyGUI()
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
	
	CC.scrollX = 0
	CC.scrollY = 0

	ensureUICreated()
	RefreshDisplay()
end


------------------------------------------------------------------------------
-- midi mappings & menu items. Note that these are separate from the configurable ones in your JSON.
-- these are like, fundamental app things.
function IsTrigger(m)
	if m:is_switch() then
		return m.boolean_value
	end
	return m.int_value > 62
end


renoise.tool():add_midi_mapping {
  name = "TheMODPaint:ShowPalette",
  invoke = function(m)
  	if IsTrigger(m) then OnDisplayPalette() end
  end
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:The MOD Paint - Show Palette",
  invoke = OnDisplayPalette
}

renoise.tool():add_midi_mapping {
  name = "TheMODPaint:Export",
  invoke = function(m) if IsTrigger(m) then OnExport() end end
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:The MOD Paint - Export...",
  invoke = OnExport
}

renoise.tool():add_midi_mapping {
  name = "TheMODPaint:Import",
  invoke = function(m) if IsTrigger(m) then OnImport() end end
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:The MOD Paint - Import...",
  invoke = OnImport
}


renoise.tool():add_midi_mapping {
  name = "TheMODPaint:Start",
  invoke = function(m) if IsTrigger(m) then OnTheMODPaintStart() end end
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:The MOD Paint - (re)start",
  invoke = OnTheMODPaintStart
}


renoise.tool():add_midi_mapping {
  name = "TheMODPaint:Stop",
  invoke = function(m) if IsTrigger(m) then OnTheMODPaintStop() end end
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:The MOD Paint - stop",
  invoke = OnTheMODPaintStop
}


renoise.tool():add_midi_mapping {
  name = "TheMODPaint:ScrollLeft",
  invoke = function(m) if IsTrigger(m) then OnTheMODScrollLeft() end end
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:The MOD Paint - scroll left",
  invoke = OnTheMODScrollLeft
}

renoise.tool():add_midi_mapping {
  name = "TheMODPaint:ScrollRight",
  invoke = function(m) if IsTrigger(m) then OnTheMODScrollRight() end end
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:The MOD Paint - scroll right",
  invoke = OnTheMODScrollRight
}

renoise.tool():add_midi_mapping {
  name = "TheMODPaint:ScrollUp",
  invoke = function(m) if IsTrigger(m) then OnTheMODScrollUp() end end
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:The MOD Paint - scroll up",
  invoke = OnTheMODScrollUp
}

renoise.tool():add_midi_mapping {
  name = "TheMODPaint:ScrollDown",
  invoke = function(m) if IsTrigger(m) then OnTheMODScrollDown() end end
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:The MOD Paint - scroll down",
  invoke = OnTheMODScrollDown
}


renoise.tool():add_midi_mapping {
  name = "TheMODPaint:Animate",
  invoke = function(m) if IsTrigger(m) then OnTheMODAnimate() end end
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:The MOD Paint - animate!",
  invoke = OnTheMODAnimate
}

renoise.tool():add_midi_mapping {
  name = "TheMODPaint:AnimateStop",
  invoke = function(m) if IsTrigger(m) then OnTheMODAnimateStop() end end
}
renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:The MOD Paint - animate stop",
  invoke = OnTheMODAnimateStop
}


