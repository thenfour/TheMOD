-- themod keyboard
-- 2015-10-22

-- TODO:
-- - play samples (just get reload config to play that sample)
--   - support keyup event
-- - support song inheritance
-- - support "active" patch state.
-- - support pressed state
-- - support animations (fade in?)
-- - support default song-button-assignment device

require("renoise/http/json")
require("utility")
require("config/config")
require("launchpadpro")
require("samplePlayer")


class 'TheMODApp'

-- after calling this, object state can be fucked. that's why ReloadConfiguration() re-sets all members.
function TheMODApp:shutdown()

	logOutput = nil
  if self.mainDialog and self.mainDialog.visible then
    self.mainDialog:close()
  end

  if self.lppMap then
  	for k, v in pairs(self.lppMap) do
  		v:shutdown()
  	end
  end

  if self.samplePlayer then
  	self.samplePlayer:shutdown()
  end

end


------------------------------------------------------------------------------
-- re-creates UI and initializes state based on config.
function TheMODApp:ReloadConfiguration(why)
	local oldSelectedSongIndex = self.selectedSongIndex

	self:shutdown()

	-- required to stabilize object state here.
	self.rawConfig = nil
  self.selectedDeviceMap = nil-- maps user device name to live device name
	self.lppMap = nil-- maps user device name to LaunchpadPro object

	self.selectedSongIndex = nil-- index into config.songs
	self.devicePatchMap = nil-- maps user device name to patch object (ModPatch)

	self.txtStatus = nil-- UI element
	self.songBitmap = nil-- UI element
  self.devicePopups = nil-- maps user device name to output device popup UI element
	self.mainDialog = nil-- UI element
	self.samplePlayer = nil-- ModSamplePlayer object for triggering samples directly from script

	-- so if your song file name is hithere.xrns
	-- your config is               hithere.xrns.json
  local mappingFileName = renoise.song().file_name .. ".json"
  local fileContents = readTextFile(mappingFileName)
  if not fileContents then
  	return nil
  end

  local src = RemoveComments(fileContents)
  local ok, decodedJSON = pcall(json.decode, src)
  if not ok then
    error("Your json (" .. mappingFileName .. ") failed to parse.")
    return nil
  end

  -- parse all config objects
  self.rawConfig = decodedJSON
  local config = ModConfig(self.rawConfig)

	-- make an array of all available devices to select
	local allAvailableDevices = {}
	for _, dn in ipairs(renoise.Midi.available_output_devices()) do
		table.insert(allAvailableDevices, dn)
	end
	for _, dn in ipairs(renoise.Midi.available_input_devices()) do
		local found = false
		for _, existing in ipairs(allAvailableDevices) do
			if existing == dn then found = true end
		end
		if not found then
			table.insert(allAvailableDevices, dn)
		end
	end

	-- correct selected device names
	self.selectedDeviceMap = {}-- maps user device name to live device name
	for _, dd in ipairs(config.deviceDefs) do
		if dd.deviceName then
	  	for _, dn in ipairs(allAvailableDevices) do
	  		if string.lower(dn) == string.lower(dd.deviceName) then
	  			self.selectedDeviceMap[string.lower(dd.name)] = dn
	  		end
	  	end
	  end

  end

  -- create launchpad devices
	self.lppMap = { }
  for _, dd in pairs(config.deviceDefs) do
  	if dd.isLaunchpadPro then
  		self.lppMap[dd.name] = LaunchpadPro(self.selectedDeviceMap[string.lower(dd.name)])
  	end
  end

  -- create UI -----------------------------------
  local vb = renoise.ViewBuilder()

  local textWidth = tonumber(config.settings["LogWindowWidth"])
  if not textWidth then textWidth = 400 end

  local textHeight = tonumber(config.settings["LogWindowHeight"])
  if not textHeight then textHeight = 400 end

  self.txtStatus = vb:multiline_textfield {
    edit_mode = false,
    width = textWidth,
    height = textHeight,
    font = "mono",
    text = "The MOD live keyboard app"
  }

  self.songBitmap = vb:bitmap {
  	bitmap = "emptySong.png"
  };

  local popupRow = vb:row { }
  --popupRow.margin = 0
  popupRow.spacing = 10

  self.devicePopups = {}
  for k, deviceDef in pairs(config.deviceDefs) do

  	local iorow = vb:row { }
  	local mainCol = vb:column {
  		vb:row { vb:text { text = deviceDef.name, font="bold" } },
  		iorow
  	}

  	mainCol.style = "group"

	  -- device popups ----------------------------------------------
  	local choices = { "(disabled)" }
  	local selected = nil
  	for i, d in ipairs(allAvailableDevices) do
			table.insert(choices, d)
		end
  	for i, choice in ipairs(choices) do
			if deviceDef.deviceName and (string.upper(choice) == string.upper(deviceDef.deviceName)) then
				selected = i
			end
  	end
  	if selected == nil then
  		selected = 1
  	end

  	local popup = vb:popup {
			items = choices,
			value = selected,
			notifier = function(i)
				self:selectDevice(deviceDef, i)
			end
		}

		local col = vb:column {
			vb:text {
				text = "output"
			},
			popup
		}

	  iorow:add_child(col)

  	self.devicePopups[deviceDef.name] = popup

	  popupRow:add_child(mainCol)
  end

  -- create the dialog ----------------------------------------------
  local dialogContent = vb:column {
		id = "sdcompoLiveDialog",
		margin = renoise.ViewBuilder.DEFAULT_CONTROL_MARGIN,
		popupRow,
		vb:row {
			self.songBitmap
		},
		vb:row {
			self.txtStatus
		}
	}

  self.mainDialog = renoise.app():show_custom_dialog("The MOD info", dialogContent)
  logOutput = self.txtStatus

  self.samplePlayer = ModSamplePlayer(
  	config:findSetting("OscHost", "localhost"),
  	tonumber(config:findSetting("OscPort", "8000")),
  	config:findSetting("OscProtocol", "UDP"))

 	self:selectSong(config, oldSelectedSongIndex, why.."->ReloadConfiguration selecting old song")
end


-- constructor. should never be called otherwise.
function TheMODApp:__init()
	log("---------------------------------------------------------")
	log("TheMODApp:__init")
	self:ReloadConfiguration("__init")
end


function TheMODApp:selectDevice(deviceDef, selectedIndex)
	local dn = nil
	if selectedIndex ~= 1 then
		dn = self.devicePopups[deviceDef.name].items[selectedIndex]
	end

	self.selectedDeviceMap[deviceDef.name] = dn
	
	-- if it's a launchpad, re-initialize
	local lp = self.lppMap[deviceDef.name]
	if lp then
		lp:shutdown()
 		self.lppMap[deviceDef.name] = LaunchpadPro(self.selectedDeviceMap[string.lower(deviceDef.name)])
	end
end


------------------------------------------------------------------------------
function TheMODApp:BindHotkey(config, hotkeyName, func)
	--log("you are binding a hotkey: ".. hotkeyName)
  local hk = config:findHotkeyAssignment(hotkeyName)
  if not hk then return end

	local b = config:findButtonDef(hk.buttonName)
	if not b then
		error("You assigned hotkey " .. hotkeyName .. " to missing button def")
		return
	end

	-- find the launchpad obj
	local lp = self.lppMap[b.deviceDef.name]
	if not lp then
		error("Only Launchpad Pro is supported for hotkeys (while processing hotkey " .. hotkeyName)
		return
	end

	lp:addKeyBinding(b.LPPKey,
		function(vel)
			-- todo: pressed
			func()
		end,
		function()
			-- note off; color scheme
		end
		)
	lp:updateLED(b.LPPKey, config:findColorScheme(hk.colorScheme).normal)
end

------------------------------------------------------------------------------
function TheMODApp:applyCurrentState(config, why)
  for _, lp in pairs(self.lppMap) do
  	lp:beginFrame(why.."->applyCurrentState")
  end

	local song = config.songs[self.selectedSongIndex]

  for _, lp in pairs(self.lppMap) do
  	lp:clearKeyBindings()
  	lp:clearAllLEDs(ModColor("#000"))
  end

  -- register listeners for hotkeys and song-buttons
	self:BindHotkey(config, "SelectNextSong", function()
		local i = 1
		if self.selectedSongIndex then i = self.selectedSongIndex + 1 end
		self:selectSong(config, i, "handleHotkey")
	end)

	self:BindHotkey(config, "SelectPreviousSong", function()
		local i = 0
		if self.selectedSongIndex then i = self.selectedSongIndex - 1 end
		self:selectSong(config, i, "handleHotkey")
	end)

	self:BindHotkey(config, "SelectNoSong", function()
		self:selectSong(config, nil, "handleHotkey")
	end)

	self:BindHotkey(config, "ReloadConfiguration", function()
		self:ReloadConfiguration("handleHotkey")
	end)

	self:BindHotkey(config, "ReapplyStatus", function()
		self:applyCurrentState(config, "handleHotkey")
	end)

  -- set up key bindings for song
  if song then
  	for _, songButtonMapItem in pairs(song.buttonMap) do
  		--log("processing song button")
			local buttonDef = config:findButtonDef(songButtonMapItem.buttonName)
			if not buttonDef then
				error("You assigned a song mapping to a nonexistent button def / " .. songButtonMapItem.buttonName)
				return
			end

			-- find the launchpad obj
			local lp = self.lppMap[buttonDef.deviceDef.name]
			if not lp then
				error("Only Launchpad Pro is supported for button mappings")
				return
			end

			lp:addKeyBinding(
				buttonDef.LPPKey,
				function(vel)
					--log("launchpad button down with velocity "..vel)
					self:executeButtonDown(config, vel, songButtonMapItem, "handle_launchpad_button_down")
				end,
				function()
					self:executeButtonUp(config, songButtonMapItem, "handle_launchpad_button_up")
				end)

			lp:updateLED(buttonDef.LPPKey, config:findColorScheme(songButtonMapItem.colorScheme).normal)

  	end
  end

  for _, lp in pairs(self.lppMap) do
  	lp:presentFrame(why.."->applyCurrentState")
  end

  if song and song.image then
  	local dir = getDirectoryName(renoise.song().file_name)
  	local sep = "\\"
  	if dir:find("/") then sep = "/" end
	  local bitmapFileName = dir .. sep .. song.image
		self.songBitmap.bitmap = bitmapFileName
	else
	  local filename = config.settings["NoSongImage"]
	  if filename then
	  	local dir = getDirectoryName(renoise.song().file_name)
	  	local sep = "\\"
	  	if dir:find("/") then sep = "/" end
		  local bitmapFileName = dir .. sep .. filename
			self.songBitmap.bitmap = bitmapFileName
	  else
		  self.songBitmap.bitmap = "emptySong.png"
	  end

	end

  -- instrument assignments
	local instrumentIdeals = {}-- maps renoise instrument name to { realDeviceName=(string), layer=ModPatchLayer }
	for deviceUserName, patch in pairs(self.devicePatchMap) do
		local realDeviceName = self.selectedDeviceMap[string.lower(deviceUserName)]
		if not realDeviceName then
			-- maybe device is disabled ? anyway ignore.
		else
			for _, layer in pairs(patch.layers) do
				instrumentIdeals[layer.instrumentName] = { realDeviceName = realDeviceName, layer = layer }
			end
		end
	end

  for _,ri in pairs(renoise.song().instruments) do
  	local idealData = instrumentIdeals[ri.name]
  	if idealData == nil then
  		-- unassign.
      if ri.midi_input_properties.device_name ~= "" then ri.midi_input_properties.device_name = "" end
      if ri.midi_input_properties.channel ~= 0 then ri.midi_input_properties.channel = 0 end
  	else
  		-- assign to layer.
			if ri.midi_input_properties.device_name ~= idealData.realDeviceName then ri.midi_input_properties.device_name = idealData.realDeviceName end
			if ri.midi_input_properties.channel ~= idealData.layer.channel then ri.midi_input_properties.channel = idealData.layer.channel end
			if ri.transpose ~= idealData.layer.transpose then ri.transpose = idealData.layer.transpose end
			if ri.volume ~= math.db2lin(idealData.layer.gain) then ri.volume = math.db2lin(idealData.layer.gain) end
			if ri.midi_input_properties.note_range ~= idealData.layer.keyRange then ri.midi_input_properties.note_range = idealData.layer.keyRange end
  	end
  end
end

------------------------------------------------------------------------------
-- user pushed a button; do stuff stuff
function TheMODApp:executeButtonDown(config, vel, songButtonMapItem, why)

	local didPatchChange = false

	for _, patchAssignment in pairs(songButtonMapItem.patchAssignments) do
		local patch = config:findPatch(patchAssignment.patchName)
		if patch == nil then
			--log("Patch not found: "..patchAssignment.patchName)
		else
			self.devicePatchMap[patchAssignment.deviceName] = patch
			log("Selecting patch: "..patchAssignment.patchName.." for device "..patchAssignment.deviceName)
			didPatchChange = true
		end
	end

	for k,sampleName in pairs(songButtonMapItem.sampleTriggers) do
		local sample = config:findSample(sampleName)
		if not sample then
			error("sample not found: "..sampleName)
		else
			for k,layer in pairs(sample.layers) do
				local velocity = vel
				if layer.velocity then velocity = layer.velocity end
				self.samplePlayer:noteOn(layer.instrumentName, layer.note, velocity)
			end
		end
	end

	if didPatchChange then
		self:applyCurrentState(config, why)
	end

end



------------------------------------------------------------------------------
function TheMODApp:executeButtonUp(config, songButtonMapItem, why)
	for k,sampleName in pairs(songButtonMapItem.sampleTriggers) do
		local sample = config:findSample(sampleName)
		if not sample then
			error("sample not found: "..sampleName)
		else
			for k,layer in pairs(sample.layers) do
				self.samplePlayer:noteOff(layer.instrumentName, layer.note)
			end
		end
	end

end

------------------------------------------------------------------------------
function TheMODApp:findFirstPatchChangeForDevice(config, deviceUserName, song)
	assert(type(config) == "ModConfig")
	assert(song)
	assert(deviceUserName)

	-- just iterate over all patch changes in sequence until you find the device name in question.
	for _,buttonMapItem in pairs(song.buttonMap) do
		for _,patchAssignment in pairs(buttonMapItem.patchAssignments) do
			if string.lower(patchAssignment.deviceName) == string.lower(deviceUserName) then
				local patch = config.patches[patchAssignment.patchName]
				return patch
			end
		end
	end

	return nil
end


------------------------------------------------------------------------------
function TheMODApp:selectSong(config, songIndex, why)
	assert(type(config) == "ModConfig")
	assert(type(why) == "string")

	-- clamp / wrap
	if table.count(config.songs) == 0 then
		songIndex = nil
	end
	if songIndex ~= nil then
		songIndex = ((songIndex - 1) % table.count(config.songs)) + 1
	end

	self.selectedSongIndex = songIndex
	self.devicePatchMap = { }

	-- attempt to set all devices to the first patch the song maps to.
	if self.selectedSongIndex == nil then
		log("Un-selecting song because: "..why)
	else
		local song = config.songs[self.selectedSongIndex]
		if not song then
			log("Couldn't find song song index " .. tostring(songIndex) .. " because: "..why)
		else
			log("Selecting song "..song.name..", index " .. tostring(songIndex) .. " because: "..why)
			for _, deviceDef in pairs(config.deviceDefs) do
				local patch = self:findFirstPatchChangeForDevice(config, deviceDef.name, song)
				if patch ~= nil then
					self.devicePatchMap[deviceDef.name] = patch
				end
			end
		end
	end

	self:applyCurrentState(config, why.."->selectSong")
end
