-- themod keyboard
-- 2015-10-22

-- TODO:
-- - get rid of two separate dropdowns
-- - play samples (just get reload config to play that sample)
--   - support keyup event
--   - launchpad support keyup + velocity
-- - support "active" patch state.
-- - support pressed state
-- - support animations (fade in?)
-- - support default song-button-assignment device

require("renoise/http/json")
require("utility")
require("config")
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
  self.selectedInputDeviceMap = nil-- maps user device name to live device name
  self.selectedOutputDeviceMap = nil-- maps user device name to live device name
	self.lppMap = nil-- maps user device name to LaunchpadPro object

	self.selectedSongIndex = nil-- index into config.songs
	self.devicePatchMap = nil-- maps user device name to patch object (ModPatch)

	self.txtStatus = nil-- UI element
	self.songBitmap = nil-- UI element
  self.inputDevicePopups = nil-- maps user device name to input device popup UI element
  self.outputDevicePopups = nil-- maps user device name to output device popup UI element
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

  -- correct selected device names
  self.selectedInputDeviceMap = {}-- maps user device name to live device name
  self.selectedOutputDeviceMap = {}-- maps user device name to live device name
  for _, dd in ipairs(config.deviceDefs) do

  	-- input devices
  	if dd.inputDeviceName then
	  	for _, dn in ipairs(renoise.Midi.available_input_devices()) do
	  		if string.lower(dn) == string.lower(dd.inputDeviceName) then
	  			-- select it.
	  			self.selectedInputDeviceMap[dd.name] = dn
	  		end
	  	end
	  end

  	-- output devices
  	if dd.outputDeviceName then
	  	for _, dn in ipairs(renoise.Midi.available_output_devices()) do
	  		if string.lower(dn) == string.lower(dd.outputDeviceName) then
	  			--log("setting output device mapping ["..dd.name.."] to ["..dn.."]")
	  			self.selectedOutputDeviceMap[string.lower(dd.name)] = dn
	  		end
	  	end
	  end

  end

  -- create launchpad devices
	self.lppMap = { }
  for _, dd in pairs(config.deviceDefs) do
  	if dd.isLaunchpadPro then
  		--log("launchpad pro detected...")
  		self.lppMap[dd.name] = LaunchpadPro(self.selectedInputDeviceMap[dd.name], self.selectedOutputDeviceMap[string.lower(dd.name)])
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

  self.outputDevicePopups = {}
  self.inputDevicePopups = {}
  for k, deviceDef in pairs(config.deviceDefs) do

  	local iorow = vb:row { }
  	local mainCol = vb:column {
  		vb:row { vb:text { text = deviceDef.name, font="bold" } },
  		iorow
  	}

  	mainCol.style = "group"

	  -- INPUT device popups ----------------------------------------------
  	local choices = { "(disabled)" }
  	local selected = nil
  	for i, d in ipairs(renoise.Midi.available_input_devices()) do
  		table.insert(choices, d)
  	end
  	for i, choice in ipairs(choices) do
  		if deviceDef.inputDeviceName and (string.upper(choice) == string.upper(deviceDef.inputDeviceName)) then
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
				self:selectInputDevice(deviceDef, i)
			end
		}
  	self.inputDevicePopups[deviceDef.name] = popup

  	local col = vb:column {
			vb:text {
				text = "input"
			},
			popup
		}

	  iorow:add_child(col)

	  -- OUTPUT device popups ----------------------------------------------
  	local choices = { "(disabled)" }
  	local selected = nil
  	for i, d in ipairs(renoise.Midi.available_output_devices()) do
  		table.insert(choices, d)
  	end
  	for i, choice in ipairs(choices) do
  		if deviceDef.outputDeviceName and (string.upper(choice) == string.upper(deviceDef.outputDeviceName)) then
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
				self:selectOutputDevice(deviceDef, i)
			end
		}

  	local col = vb:column {
			vb:text {
				text = "output"
			},
			popup
		}

	  iorow:add_child(col)

  	self.outputDevicePopups[deviceDef.name] = popup

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

 	self:selectSong(oldSelectedSongIndex, why.."->ReloadConfiguration selecting old song")
end


-- constructor. should never be called otherwise.
function TheMODApp:__init()
	log("---------------------------------------------------------")
	log("TheMODApp:__init")
	self:ReloadConfiguration("__init")
end


function TheMODApp:selectInputDevice(deviceDef, selectedIndex)
	local dn = nil
	if selectedIndex ~= 1 then
		dn = self.inputDevicePopups[deviceDef.name].items[selectedIndex]
	end

	self.selectedInputDeviceMap[deviceDef.name] = dn

	-- if it's a launchpad, re-initialize
	local lp = self.lppMap[deviceDef.name]
	if lp then
		lp:shutdown()
 		self.lppMap[deviceDef.name] = LaunchpadPro(self.selectedInputDeviceMap[deviceDef.name], self.selectedOutputDeviceMap[string.lower(deviceDef.name)])
	end
end

function TheMODApp:selectOutputDevice(deviceDef, selectedIndex)
	local dn = nil
	if selectedIndex ~= 1 then
		dn = self.outputDevicePopups[deviceDef.name].items[selectedIndex]
	end

	self.selectedOutputDeviceMap[deviceDef.name] = dn
	
	-- if it's a launchpad, re-initialize
	local lp = self.lppMap[deviceDef.name]
	if lp then
		lp:shutdown()
 		self.lppMap[deviceDef.name] = LaunchpadPro(self.selectedInputDeviceMap[deviceDef.name], self.selectedOutputDeviceMap[string.lower(deviceDef.name)])
	end
end



------------------------------------------------------------------------------
-- always return a valid color scheme
function TheMODApp:getColorScheme(config, name)
	local defaultColorScheme = ModColorScheme(config, {
		Name = "(default)",
		Normal = "#ff0",
		Pressed = "#0f0",
		Active = "#00f"
	})

	if not name then return defaultColorScheme end
	local ret = config:findColorScheme(name)
	if not ret then return defaultColorScheme end
	return ret
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

	lp:addKeyBinding(b.LPPKey, func)
	lp:updateLED(b.LPPKey, self:getColorScheme(config, hk.colorScheme).normal)
end

------------------------------------------------------------------------------
function TheMODApp:applyCurrentState(config, why)
	--log("applying status {"..why)
  for _, lp in pairs(self.lppMap) do
  	lp:beginFrame(why.."->applyCurrentState")
  end

	local song = config.songs[self.selectedSongIndex]

  for _, lp in pairs(self.lppMap) do
  	lp:clearKeyBindings()
  	lp:clearAllLEDs(string_to_rgb("#000"))
  end

  -- register listeners for hotkeys and song-buttons
	self:BindHotkey(config, "SelectNextSong", function()
		--log("Select Next Song hotkey pressed...")
		self:selectSong(config, self.selectedSongIndex + 1, "handleHotkey")
	end)

	self:BindHotkey(config, "SelectPreviousSong", function()
		--log("Previous song hotkey pressed ...")
		self:selectSong(config, self.selectedSongIndex - 1, "handleHotkey")
	end)

	self:BindHotkey(config, "SelectNoSong", function()
		--log("No song hotkey pressed ...")
		self:selectSong(config, nil, "handleHotkey")
	end)

	self:BindHotkey(config, "ReloadConfiguration", function()
		--log("Reload config hotkey pressed ...")
		self:ReloadConfiguration("handleHotkey")
	end)

	self:BindHotkey(config, "ReapplyStatus", function()
		--log("Reapply status hotkey pressed ...")
		self:applyCurrentState(config, "handleHotkey")
	end)

  -- set up key bindings for song
  if song then
  	for _, songButtonMapItem in pairs(song.buttonMap) do
			local buttonDef = config:findButtonDef(songButtonMapItem.buttonName)
			if not buttonDef then
				error("You assigned a song mapping to a nonexistent button def")
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
					--log("key binding activated")
					self:executeButtonDown(config, vel, songButtonMapItem, "handle_launchpad_button_down")
				end,
				function()
					-- log("key up")
					self:executeButtonUp(config, songButtonMapItem, "handle_launchpad_button_up")
				end)
			lp:updateLED(buttonDef.LPPKey, self:getColorScheme(config, songButtonMapItem.colorScheme).normal)
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
		--log("Analyzing; device "..deviceUserName.." is assigned to patch " .. patch.name)
		local realDeviceName = self.selectedOutputDeviceMap[string.lower(deviceUserName)]
		if not realDeviceName then
			-- maybe device is disabled ? anyway ignore.
			--log("couldn't find the device ["..deviceUserName.."] to assign to, so ignore this patch change.")
			--rprint(self.selectedOutputDeviceMap)
		else
			for _, layer in pairs(patch.layers) do
				--log("ideally set instrument "..layer.instrumentName.." to device "..realDeviceName)
				instrumentIdeals[layer.instrumentName] = { realDeviceName = realDeviceName, layer = layer }
			end
		end
	end

  for _,ri in pairs(renoise.song().instruments) do
  	local idealData = instrumentIdeals[ri.name]
  	if idealData == nil then
  		-- unassign.
  		--log("Unassigning instrument " ..ri.name)
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

	--log("} applying statu"..why)
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
			self.devicePatchMap[patchAssignment.outputDeviceName] = patch
			log("Selecting patch: "..patchAssignment.patchName.." for device "..patchAssignment.outputDeviceName)
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
				self.samplePlayer.noteOn(layer.instrumentName, layer.note, velocity)
			end
		end
	end

	if didPatchChange then
		self:applyCurrentState(config, why)
	end

end



------------------------------------------------------------------------------
function TheMODApp:executeButtonUp(config, songButtonMapItem, why)
	-- listen for note-off for samples
end

------------------------------------------------------------------------------
function TheMODApp:findFirstPatchChangeForDevice(config, deviceUserName, song)
	-- just iterate over all patch changes in sequence until you find the device name in question.
	for _,buttonMapItem in pairs(song.buttonMap) do
		for _,patchAssignment in pairs(buttonMapItem.patchAssignments) do
			if string.lower(patchAssignment.outputDeviceName) == string.lower(deviceUserName) then
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
	if songIndex ~= nil then
		return ((songIndex - 1) % table.count(config.songs)) + 1
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
