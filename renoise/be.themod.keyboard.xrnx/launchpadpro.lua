-- themod keyboard
-- 2015-10-22

-- http://global.novationmusic.com/sites/default/files/novation/downloads/10598/launchpad-pro-programmers-reference-guide_0.pdf



---------------------------------------------------------------------------------------------------
class 'LaunchpadProButton'

-- enter:
--    LaunchpadProButton(x, y)
-- or LaunchpadProButton(index)
-- or LaunchpadProButton("C4")
function LaunchpadProButton:__init(x, y)
	if type(x) == "string" then
		-- user passed a string
		local rowLetter, col = string.match(string.lower(x), "(%a+)(%d+)")
		col = 9 - col-- flip the coordinates upside down
		self.name = x
		self.x = string.byte(rowLetter) - string.byte("a")
		self.y = col
		self.index = self.y * 10 + self.x
		return
	end

	if y == nil then
		-- you entered an index.
		self.index = x
		self.y = math.floor(self.index / 10)
  	self.x = self.index - self.y * 10
  else
  	-- you entered x & y coords
		self.x = x
		self.y = y
		self.index = self.y * 10 + self.x
	end

	self.name = string.char(self.x + string.byte("A")) .. tostring(self.y)
end


---------------------------------------------------------------------------------------------------
class 'LaunchpadPro'

function LaunchpadPro:shutdown()
	if self.inputDevice and self.inputDevice.is_open then
		self.inputDevice:close()
	end
	if self.outputDevice and self.outputDevice.is_open then
		self.outputDevice:close()
	end
end

function LaunchpadPro:__init(inputDeviceName, outputDeviceName)

	-- member overview
	self.inputDevice = nil-- renoise input device
	self.outputDevice = nil-- renoise output device
	self.keyBindings = nil-- maps button index to function
	self.frameBufferRefs = 0-- frame ref count 0 means no frame is being drawn. each beginFrame() increases ref count; presentFrame decreases.

	-- ops per frame
	self.LEDops = {}-- maps button index to color

	---------------------

	if inputDeviceName then
		self.inputDevice = renoise.Midi.create_input_device(inputDeviceName,
			{ self, LaunchpadPro.MidiCallback },
			{ self, LaunchpadPro.SysexCallback }
		)
	end

	if outputDeviceName then
		self.outputDevice = renoise.Midi.create_output_device(outputDeviceName)
	end

	self.keyBindings = { }

	self:setProgrammerLayout()
	local sideButton = LaunchpadProButton(99)
	self:adHocUpdateLEDs({{sideButton, string_to_rgb("#303")}})
end


function LaunchpadPro:MidiCallback(message)
  --print(("-- got MIDI %X %X %X"):format(message[1], message[2], message[3]))
  -- for programmer layout,
  -- #1: message type. 0xB0 = CC, 0x90 with non-zero #3 = note on (note off is 0 velocity)
  -- #2: note or CC (button). same as setting LEDs; this is #0 at the bottom-left, then goes to the right, then next row up.
  -- #3: data (velocity / CC value). this behaves the same as note on (non-zero = button down, zero = button up)
  if message[1] == 0xb0 or message[1] == 0x90 then
  	if message[3] == 0 then
  		-- note off; for now since i don't support "pressed" state, just ignore.
  		return
  	end
  else
  	-- don't care about any other messages.
  	return
  end

  -- at this point we know it's a button press. message[2] is which button was pressed
	local pressedButton = LaunchpadProButton(message[2])

  --local y = math.floor(message[2] / 10)
  --local x = message[2] - y * 10
  -- now check if this key is bound.
  local binding = self.keyBindings[pressedButton.index]
  if not binding then
  	log("button ("..pressedButton.x..","..pressedButton.y..") is not bound; ignoring.")
  	return
  end

  -- call the binding
  local velocity = 65-- TODO
  binding[1](velocity)-- key down
  -- binding[2]() -- key up

end

function LaunchpadPro:SysexCallback(message)
  --print(("-- got SYSEX with %d bytes"):format(#message))
end


-- button is {row,col}
function LaunchpadPro:addKeyBinding(button, funcUp, funcDown)
	--log("add key binding for ("..button[1]..","..button[2]..")")
	self.keyBindings[button.index] = { funcUp, funcDown }
end

function LaunchpadPro:clearKeyBindings()
	self.keyBindings = { }
end

function LaunchpadPro:setProgrammerLayout()
	if not self.outputDevice then return end
	-- F0h 00h 20h 29h 02h 10h 2Ch <Layout> F7h
  self.outputDevice:send { 240, 0, 32, 41, 2, 16, 44, 3, 247 }
end

function LaunchpadPro:beginFrame(why)
	if not self.outputDevice then return end
	--log("begin frame because "..why)
	self.frameBufferRefs = self.frameBufferRefs + 1
end

function LaunchpadPro:presentFrame(why)
	if not self.outputDevice then return end
	--log("present frame because "..why)
	if self.frameBufferRefs < 1 then
		error("mismatched call to presentFrame()")
		return
	end
	self.frameBufferRefs = self.frameBufferRefs - 1

	--self.LEDops
	local bytes = { 240,0,32,41,2,16,15,0 }

	for y = 0, 9 do
		for x = 0, 9 do
			local btn = LaunchpadProButton(x, y)
			local c = self.LEDops[btn.index]
			if c then
				table.insert(bytes, c[1] * 63.0)
				table.insert(bytes, c[2] * 63.0)
				table.insert(bytes, c[3] * 63.0)
			else
				table.insert(bytes, 0)
				table.insert(bytes, 0)
				table.insert(bytes, 0)
			end
		end
	end	

	table.insert(bytes, 247)
	self.outputDevice:send { unpack(bytes) }
end


-- color is {r,g,b}
function LaunchpadPro:clearAllLEDs(color)
	if not self.outputDevice then return end
	if self.frameBufferRefs < 1 then
		error("attempt to clear all LEDs outside of a frame")
		return
	end

	self.LEDops = {}

	for y = 0, 9 do
		for x = 0, 9 do
			self:updateLED(LaunchpadProButton(x,y), color)
		end
	end
end

-- button is {row,col}
-- color is {r,g,b}
function LaunchpadPro:updateLED(button, color)
	if not self.outputDevice then return end
	if self.frameBufferRefs < 1 then
		error("attempt to set a LED outside of a frame")
		return
	end
	self.LEDops[button.index] = color
end



-- assignments is an array; each element is {button, color}
function LaunchpadPro:adHocUpdateLEDs(assignments)
	if not self.outputDevice then return end

	local bytes = { 240,0,32,41,2,16,11 }

	for _, v in ipairs(assignments) do
		--print(v[1])
		local button = v[1]-- of type LaunchpadProButton
		local color = v[2]
		table.insert(bytes, button.index)
		table.insert(bytes, color[1] * 63.0)
		table.insert(bytes, color[2] * 63.0)
		table.insert(bytes, color[3] * 63.0)
	end

	table.insert(bytes, 247)
	self.outputDevice:send { unpack(bytes) }
end






