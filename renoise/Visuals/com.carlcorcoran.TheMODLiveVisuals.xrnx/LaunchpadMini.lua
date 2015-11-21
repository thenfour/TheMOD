-- http://d19ulaff0trnck.cloudfront.net/sites/default/files/novation/downloads/4080/launchpad-programmers-reference.pdf
require("utility")


------------------------------------------------------------------------------
class 'LaunchpadMiniButton'

-- coords are 0-based.

-- construct from either:
-- string: "A4"
-- number: x,y coords
-- midimessage from midiinput
-- when constructing from midi message, we also receive up/down indication. bonus.
function LaunchpadMiniButton:__init(x, y)
	if type(x) == 'string' then
		-- user passed a string
		local rowLetter, col = string.match(string.lower(x), "(%a+)(%d+)")
		self.x = string.byte(rowLetter) - string.byte("a")
		self.y = tonumber(col)
		self.isPressed = nil
	elseif type(x) == 'table' and #x == 3 then
		-- midi message
		if x[1] == 0xb0 then
			self.x = (x[2] - 0x68)
			self.y = 0
			self.isPressed = (x[3] == 0x7f)
		elseif x[1] == 0x90 then
			self.y = math.floor(x[2] / 0x10)
			self.x = x[2] - (self.y * 0x10)
			self.y = self.y + 1
			self.isPressed = x[3] == 0x7f
		else
			-- just make an invalid state
			self.x = -1
			self.y = -1
			self.isPressed = nil
		end
	elseif type(x) == 'number' and type(y) == 'number' then
		self.x = x
		self.y = y
		self.isPressed = nil
	end

	self.name = string.char(self.x + string.byte("A")) .. tostring(self.y)
end

function LaunchpadMiniButton:isValid()
	if self.x == 8 and self.y == 0 then return false end-- the one nonexistant button on the device.
	if self.x < 0 then return false end
	if self.y < 0 then return false end
	if self.x > 8 then return false end
	if self.y > 8 then return false end
	return true
end






------------------------------------------------------------------------------
-- class 'LaunchpadMiniColor'
-- -- stores the colors in range 0-3 (0,1,2,3 valid)

-- function LaunchpadMiniColor:__init(s)
-- 	if type(s) == "string" then
-- 		self.name = string.lower(s)
-- 		local rg = self:fromCSS(s)
-- 		self.r = math.floor(rg[1] * 4 + 0.5)
-- 		self.g = math.floor(rg[2] * 4 + 0.5)
-- 	elseif type(s) == "ModColor" then
-- 		self.name = string.lower(s.name)
-- 		self.r = math.floor(s.r * 4 + 0.5)
-- 		self.g = math.floor(s.g * 4 + 0.5)
-- 		-- discard b
-- 	else
-- 		assert(false, "unknown color format datatype: "..type(s))
-- 	end

-- 	-- clamp
-- 	if self.r < 0 then self.r = 0 end
-- 	if self.g < 0 then self.g = 0 end
-- 	if self.r > 3 then self.r = 3 end
-- 	if self.g > 3 then self.g = 3 end
-- end

-- function LaunchpadMiniColor:fromCSS(s)
-- 	if s == nil then return nil end
-- 	if s:sub(1,1) ~= '#' then return end
-- 	if #s == 3 or #s == 4 then-- #01 or #011 (b is discarded)
-- 		local r = tonumber(s:sub(2, 2), 16)
-- 		local g = tonumber(s:sub(3, 3), 16)
-- 		r = (r * 16) + r
-- 		g = (g * 16) + g
-- 		return {r/255.0, g/255.0 }
-- 	end
-- 	-- #0011 or #001111 where b is discarded
-- 	local r = tonumber(s:sub(2, 3), 16)
-- 	local g = tonumber(s:sub(4, 5), 16)
-- 	return { r/255.0, g/255.0 }
-- end

-- function LaunchpadMiniColor:tostring()
-- 	return self.name
-- end





------------------------------------------------------------------------------
class 'LaunchpadMini'

function LaunchpadMini:__init(deviceName, handleButtonDownFn, handleButtonUpFn)
	self.ID = getUniqueID()
	self.handleButtonDownFn = handleButtonDownFn
	self.handleButtonUpFn = handleButtonUpFn
	self.inputDevice = renoise.Midi.create_input_device(deviceName, function(msg) self:OnMidiMessage(msg) end)
	self.outputDevice = renoise.Midi.create_output_device(deviceName)
	self.launchpadDisplayBuffer = 0-- just toggles 0 - 1 - 0 -1
	self.bufferCallDepth = 0-- prevents nested calls to BeginFrame; when this reaches 0, we actually present the frame.
	--self.launchpadUpdatedLEDs = {}
end

function LaunchpadMini:shutdown()
	if self.inputDevice then self.inputDevice:close() end
	self.inputDevice = nil
	if self.outputDevice then self.outputDevice:close() end
	self.outputDevice = nil
end

function LaunchpadMini:OnMidiMessage(message)
	local btn = LaunchpadMiniButton(message)
	if not btn:isValid() then return end
	if btn.isPressed then
		self.handleButtonDownFn(btn)
	else
		self.handleButtonUpFn(btn)
	end
end


function LaunchpadMini:BeginFrame(why)
	if self.bufferCallDepth > 0 then
		self.bufferCallDepth = self.bufferCallDepth + 1
		--log("beginFrame["..why.."] subsequent call; self.bufferCallDepth="..self.bufferCallDepth.." self="..self.ID)
		return
	end

	self.bufferCallDepth = 1
	--log("beginFrame["..why.."] first call; self.bufferCallDepth="..self.bufferCallDepth.." self="..self.ID)

	local newUpdateBuffer = 1
	if self.launchpadDisplayBuffer == 1 then
		newUpdateBuffer = 0
	else
		self.launchpadDisplayBuffer = 0
	end

	--self.launchpadUpdatedLEDs = {}

	-- basically we only want to create a copy of the display buffer to the back buffer,
	-- and start updating to the back buffer. this does that in 1 shot:
  self.outputDevice:send { 0xb0, 0, self:CalculateDBParam(1, newUpdateBuffer, self.launchpadDisplayBuffer) }
end


-- if clearUnsetButtons is true, then all buttons that were not set since LaunchpadDoubleBufferBegin will be cleared.
--function LaunchpadDoubleBufferEnd(device, lpstate, clearUnsetButtons)
function LaunchpadMini:PresentFrame(why)

	--	assert(self.bufferCallDepth > 0)

	self.bufferCallDepth = self.bufferCallDepth - 1

	-- it's possible that you reset your device object in the middle of a frame. in that case just be cool with it and let it go. keep presenting.
	if self.bufferCallDepth < 0 then self.bufferCallDepth = 0 end

	if self.bufferCallDepth > 0 then
		--log("not presenting frame ["..why.."]; self.bufferCallDepth="..self.bufferCallDepth.." self="..self.ID)
		return
	end
	-- bufferCallDepth reached 0.
	--log("presenting frame ["..why.."]; self.bufferCallDepth="..self.bufferCallDepth.." self="..self.ID)

	local newDisplayBuffer = 1
	if self.launchpadDisplayBuffer == 1 then
		newDisplayBuffer = 0
	end

	-- if clearUnsetButtons then
	--   for x = 0, 8 do
	--   	for y = 0, 8 do
	--   		--print(x, y)
	--   		if not lpstate.launchpadUpdatedLEDs[XYToKey(x,y)] then
	--   			self:SetButtonLED(LaunchpadMiniButton(x, y), LaunchpadMiniColor())
	--   		end
	--   	end
	--   end
	-- end

	-- just present it. so, no copy and just present the new display buffer.
  self.outputDevice:send { 0xb0, 0, self:CalculateDBParam(1, newDisplayBuffer, newDisplayBuffer) }
	self.launchpadDisplayBuffer = newDisplayBuffer
end


-- color is a ModColor
function LaunchpadMini:CalculateVelocity(color)
	-- mask:
  -- 0x30 bit 4-5: green LED brightness (0, 1, 2, 3)
  -- 0x08 bit 3  : clear the other buffer's copy of this LED (for double buffer support)
  -- 0x04 bit 2  : copy. if 1, write to both buffers.
  -- 0x03 bit 0-1: red LED brightness.
  local lpmc = color:toLaunchpadMiniColor()

  return lpmc.r + (lpmc.g * 16) + 0xC
end

function LaunchpadMini:CalculateMessage(btn, color)
  -- - 0x90 = on
  -- - 0x80 = off
  -- - 0xb0 = CC change
  if btn.y == 0 then
  	return 0xb0
  end
  local lpmc = color:toLaunchpadMiniColor()
  if lpmc.r == 0 and lpmc.g == 0 then
  	return 0x80
  end
  return 0x90
end

function LaunchpadMini:CalculateData(btn, color)
  -- - top row (round buttons) are CC from 0x68 - 0x6f
  -- - each row is 9 buttons long, starting at 0x10 boundaries. So,
  -- - 1st row is 0x00 - 0x08
  -- - 2nd row is 0x10 - 0x18
  -- - ...
  if btn.y == 0 then
  	return 0x68 + btn.x
  end
  return ((btn.y - 1) * 0x10) + btn.x
end

-- params are bits 0 or 1
-- http://d19ulaff0trnck.cloudfront.net/sites/default/files/novation/downloads/4080/launchpad-programmers-reference.pdf
-- 4 Copy    : If 1: copy the LED states from the new ‘displayed’ buffer to the new ‘updating’ buffer.
-- 3 Flash   : If 1: continually flip ‘displayed’ buffers to make selected LEDs flash.
-- 2 Update  : Set buffer 0 or buffer 1 as the new ‘updating’ buffer.
-- 0 Display : Set buffer 0 or buffer 1 as the new ‘displaying’ buffer.
function LaunchpadMini:CalculateDBParam(copy, update, display)
	return 0x20 + (copy * 0x10) + (update * 4) + display
end



-- color is ModColor
function LaunchpadMini:SetButtonLED(button, color)
	-- this is an empty spot on the grid; don't send messages for it.
	if not button:isValid() then return end

  -- http://d19ulaff0trnck.cloudfront.net/sites/default/files/novation/downloads/4080/launchpad-programmers-reference.pdf
  self.outputDevice:send { self:CalculateMessage(button, color), self:CalculateData(button, color), self:CalculateVelocity(color) }
  --self.launchpadUpdatedLEDs[XYToKey(x,y)] = true
end


function LaunchpadMini:Clear()
  self.outputDevice:send { 0xb0, 0, 0 }
  --return
  --for x = 0, 8 do
  --	for y = 0, 8 do
  --		SetButtonLED(device, x, y, 0, 0)
  --	end
  --end
end



