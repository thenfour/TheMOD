
require("Config")
require("utility")
require("LaunchpadMini")
require("oscClient")


class 'TheMODLiveVisuals'


-- GLOBAL. set later on to a real function
pressAndReleaseButton = nil



function TheMODLiveVisuals:shutdown()

	if self.currentDelayFunctions then
		for _,fn in pairs(self.currentDelayFunctions) do
			renoise.tool():remove_timer(fn)
		end
	end

	if self.lp then self.lp:shutdown() end
	self.lp = nil
end


function TheMODLiveVisuals:__init()
	self:refreshConfig("__init")
end



function TheMODLiveVisuals:refreshConfig(why)
	log("reloading configuration because "..why)

	self:shutdown()

	pressAndReleaseButton = function(btn)
		self:pressAndReleaseButton(btn)
	end

	self.currentDelayFunctions = {}-- maps key to functions currently pending execution via timer
	self.radioSelections = {}-- maps lowercase radio group ID to lowercase button name.
	self.buttonsDown = {}-- array of button names that are currently pressed. key is lowercase button name.

	self.config = LoadMapping()
	-- ideally you would pass off / adapt state from previous, in case we're replacing it. that will help deal with the situation where you refresh config in the middle of a frame.
	self.lp = LaunchpadMini(self.config.device, function(button) self:handleButtonDown(button) end, function(button) self:handleButtonUp(button) end)
	self.lp:Clear()

	self.oscClient = ModOscClient(self.config.osc.host, self.config.osc.port, self.config.osc.protocol)

	self.lp:BeginFrame("refreshConfig["..why.."] completion")
	self:applyState("refreshConfig-"..why)

	if self.config.onStartup then
		self.config.onStartup(self)
	end
	self.lp:PresentFrame("refreshConfig["..why.."] completion")
end

function TheMODLiveVisuals:pressAndReleaseButton(btn)
	if type(btn) == "string" then btn = LaunchpadMiniButton(btn) end
	self:handleButtonDown(btn)
	self:handleButtonUp(btn)
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
function TheMODLiveVisuals:applyState(why)
	self.lp:BeginFrame("applyState-"..why)
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
	self.lp:PresentFrame("applyState-"..why)
end

function TheMODLiveVisuals:handleButtonDown(btn)
	self.buttonsDown[string.lower(btn.name)] = 1

	-- find the mapping for this button.
	local mapping = self:getMappingForButton(btn)
	if not mapping then
		log(" -> button not mapped")
		return
	end

	self.lp:BeginFrame("buttonDown")

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

	if mapping.delayFunctions then
		for _,v in pairs(mapping.delayFunctions) do
			local userFn = v[2]
			local procKey = getUniqueID()

			local proc = function()
				local yeaProc = self.currentDelayFunctions[procKey]

				--log("{ in proc, and removing "..tostring(procKey).." = "..tostring(self.currentDelayFunctions[procKey]).." == "..tostring(yeaProc))
				self.currentDelayFunctions[procKey] = nil

				assert(renoise.tool():has_timer(yeaProc))

				--log("  -> calling user fn")
				userFn(self)
				--log("  -> has_timer? =  "..tostring(renoise.tool():has_timer(yeaProc)))
				renoise.tool():remove_timer(yeaProc)
				--log("}")
			end

			self.currentDelayFunctions[procKey] = proc
			log("inserting proc "..tostring(procKey).." = "..tostring(self.currentDelayFunctions[procKey]))
			renoise.tool():add_timer(proc, v[1])
		end
	end

	self:applyState("buttonDown")
	self.lp:PresentFrame("buttonDown")
end



function TheMODLiveVisuals:handleButtonUp(btn)
	self.buttonsDown[string.lower(btn.name)] = nil

	self.lp:BeginFrame("buttonUp")
	self:applyState("buttonUp")
	self.lp:PresentFrame("buttonUp")
end

