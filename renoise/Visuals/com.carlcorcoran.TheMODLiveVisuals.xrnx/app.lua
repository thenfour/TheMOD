
require("Config")
require("utility")
require("LaunchpadMini")
require("oscClient")


class 'TheMODLiveVisuals'



function TheMODLiveVisuals:shutdown()
	if self.lp then self.lp:shutdown() end
	self.lp = nil
end


function TheMODLiveVisuals:__init()
	self:refreshConfig()
end



function TheMODLiveVisuals:refreshConfig()
	log("reloading configuration.")

	self:shutdown()

	self.radioSelections = {}-- maps lowercase radio group ID to lowercase button name.
	self.buttonsDown = {}-- array of button names that are currently pressed. key is lowercase button name.

	self.config = LoadMapping()
	self.lp = LaunchpadMini(self.config.device, function(button) self:handleButtonDown(button) end, function(button) self:handleButtonUp(button) end)
	self.lp:Clear()

	self.oscClient = ModOscClient(self.config.osc.host, self.config.osc.port, self.config.osc.protocol)

	self:applyState()
end


function TheMODLiveVisuals:getMappingForButton(btn)
	return self.config.mapping[string.lower(btn.name)]
end

-- takes a mapping, returns an object filled with ModColor objects for all color states.
function TheMODLiveVisuals:getColorSchemeForMapping(m)
	local ret = {
		normal="%11",
		active="%22",
		pressed="%33"
	}

	if m.colorScheme then
		if m.colorScheme.normal then ret.normal = m.colorScheme.normal end
		if m.colorScheme.active then ret.active = m.colorScheme.active end
		if m.colorScheme.pressed then ret.pressed = m.colorScheme.pressed end
	end

	-- convert strings to ModColor
	return {
		normal = ModColor(ret.normal),
		active = ModColor(ret.active),
		pressed = ModColor(ret.pressed),
	}
end


-- the only state is actually just the LED colors.
function TheMODLiveVisuals:applyState()
	self.lp:BeginFrame()
	for k,v in pairs(self.config.mapping) do
		local btn = LaunchpadMiniButton(k)
		assert(btn:isValid())

		local cs = self:getColorSchemeForMapping(v)
		local color = cs.normal

		if self.buttonsDown[string.lower(btn.name)] then
			color = cs.pressed
		elseif v.radioGroup and self.radioSelections[string.lower(v.radioGroup)] == string.lower(btn.name) then
			color = cs.active
		else
			color = cs.normal
		end

		self.lp:SetButtonLED(btn, color)
	end
	self.lp:PresentFrame()
end

function TheMODLiveVisuals:handleButtonDown(btn)
	self.buttonsDown[string.lower(btn.name)] = 1

	-- find the mapping for this button.
	local mapping = self:getMappingForButton(btn)
	if not mapping then
		log(" -> button not mapped")
		return
	end

	if mapping.osc then
		for _,v in pairs(mapping.osc) do
			--log(" -> send OSC: '".. v.."'")
			self.oscClient:send(v)
		end
	end

	if mapping.onButtonDown then
		mapping.onButtonDown(self)
	end

	-- radio group selection
	if mapping.radioGroup then
		self.radioSelections[string.lower(mapping.radioGroup)] = string.lower(btn.name)
	end

	self:applyState()
end



function TheMODLiveVisuals:handleButtonUp(btn)
	self.buttonsDown[string.lower(btn.name)] = nil

	self:applyState()
end

