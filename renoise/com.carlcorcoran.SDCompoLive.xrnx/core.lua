local CC = require('namespace')
require("renoise/http/json")
require("utility")
require("globals")
require("instrument")


------------------------------------------------------------------------------
function readTextFile(file)
    local f = io.open(file, "r")
    local content = f:read("*all")
    f:close()
    return content
end

------------------------------------------------------------------------------
function ValidateMapping(m)
  local availableDevices = renoise.Midi.available_input_devices()
  
  for deviceIndex = 1, #m["Devices"] do
    if not DeviceNameExists(m["Devices"][deviceIndex]["Name"]) then
      LogMessage(string.format("!!!! Referenced device %s not found.", m["Devices"][deviceIndex]["Name"]))
      --renoise.app():show_error(string.format("!!!! Referenced device %s not found.", m["Devices"][deviceIndex]["Name"]))
    end
  end

  for songIndex = 1, #m["Songs"] do
    local song = m["Songs"][songIndex]
    if #song["Devices"] > #m["Devices"] then
      LogMessage("!!!! The number of referenced devices is too darn high!")
      renoise.app():show_status("!!!! The number of referenced devices is too darn high!")
      return
    end
    for deviceIndex = 1, #song["Devices"] do
      local songDevice = song["Devices"][deviceIndex]
      for deviceInstrumentIndex = 1, #songDevice do

        -- make sure the instrument is the correct object.
        songDevice[deviceInstrumentIndex] = EnsureProgramObject(songDevice[deviceInstrumentIndex])

        if not songDevice[deviceInstrumentIndex].layers[1].keyRange then
          renoise.app():show_error(string.format("um that didnt work."))
        end
--        print("created song instrument with layer1 keyrange " .. songDevice[deviceInstrumentIndex].layers[1].keyRange[1])

        local inst = songDevice[deviceInstrumentIndex]

        for layerIndex = 1, #inst.layers do
          local layer = inst.layers[layerIndex];
          if not InstrumentNameExists(layer.instrument) then
            LogMessage(string.format("!!!! Referenced instrument %s not found.", layer.instrument))
            --renoise.app():show_status(string.format("!!!! Referenced instrument %s not found.", layer.instrument))
          end
        end

      end
    end
  end  
end



------------------------------------------------------------------------------
-- returns a table containing the entire mapping. for each song, for each device, a list of instruments.
function GetMapping_()
  -- doing this allows me to use C-style comments in JSON.
  -- song comments are a table of lines.
  --local src = RemoveComments(table.concat(renoise.song().comments, '\n'))
  
  local mappingFileName = renoise.song().file_name .. ".themod.js"
  local src = RemoveComments(readTextFile());

  local ok, m = pcall(json.decode, src)
  if not ok then
    LogMessage("Your json failed to parse.")
    renoise.app():show_status("Your json failed to parse.")
    return nil
  end
  
  if not pcall(ValidateMapping, m) then
    LogMessage("JSON Syntax is OK but there was an error validating it for sdcompo live. Make sure it's in the right schema.")
    renoise.app():show_error("JSON Syntax is OK but there was an error validating it for sdcompo live. Make sure it's in the right schema.")
    return nil
  end
  
  return m
end

------------------------------------------------------------------------------
function getCurrentMapping()
  if not CC.currentMapping then
    CC.currentMapping = GetMapping_()
    if CC.currentMapping then
      local settings = CC.currentMapping["Settings"]
      if settings then
        if settings["logWidth"] then CC.logWidth = tonumber(settings["logWidth"]) end
        if settings["logHeight"] then CC.logHeight = tonumber(settings["logHeight"]) end
        if settings["logTruncateColumn"] then CC.logTruncateColumn = tonumber(settings["logTruncateColumn"]) end
        if settings["mappingCellWidth"] then CC.mappingCellWidth = tonumber(settings["mappingCellWidth"]) end
        if settings["H1Font"] then CC.H1Font = settings["H1Font"] end
        if settings["H2Font"] then CC.H2Font = settings["H2Font"] end
        if settings["enableTerminalOutput"] then CC.enableTerminalOutput = settings["enableTerminalOutput"] end
      end
    end
  end
  return CC.currentMapping
end


------------------------------------------------------------------------------
-- gets the program
function GetCurrentInstrument(deviceIndex)
  if CC.currentDeviceInstrument[deviceIndex] == nil then
    return 1
  end
  return CC.currentDeviceInstrument[deviceIndex];
end


------------------------------------------------------------------------------
function DisplayMappingHeader(m, song)
  LogMessageH1(song["Name"])

  for deviceIndex = 1, #m["Devices"] do
    local programIndex = GetCurrentInstrument(deviceIndex)
    local program = nil
    -- local instrumentName
    if song["Devices"][deviceIndex] then
      program = song["Devices"][deviceIndex][programIndex]
    end
    if not program then
      program = CC.nullProgram
    end
    LogMessageH2(deviceIndex .. ": " .. program.name)
    -- output volume.--
    -- |############################################--------| vol: 1.99

    for layerIndex = 1, #program.layers do
      local layer = program.layers[layerIndex]
      local instrumentName = layer.instrument
      if instrumentName and string.len(instrumentName) > 1 then
        for _,ri in pairs(renoise.song().instruments) do
          if ri.name == instrumentName then
            local totalChars = 45
            local volumeMax = 1.99526
            local filledCharCount = totalChars * (ri.volume / volumeMax)
            local unfilledCharCount = totalChars - filledCharCount
            local filledChar = "#"
            local unfilledChar = "."
            local filledStr = ""
            local unfilledStr = ""
            for i = 1, filledCharCount do
              filledStr = filledStr .. filledChar
            end
            for i = 1, unfilledCharCount do
              unfilledStr = unfilledStr .. unfilledChar
            end
            LogMessage(string.format("%s%s vol:%0.4f keyRange:%d-%d <- %s", filledStr, unfilledStr, ri.volume, layer.keyRange[1], layer.keyRange[2], ri.name))
          end-- if
        end-- for renoise.instruments
      end-- if instrumentName
    end-- for each program.layers          
  end
end


------------------------------------------------------------------------------
function DisplayMappingDeviceProgramGrid(m, song)
  -- output a table of device instrument mappings showing selected
  local const_topLeft = "+"
  local const_top = "-"
  local const_topTee = "+"
  local const_topRight = "+"
  local const_bottomLeft = "+"
  local const_bottom = "-"
  local const_bottomTee = "+"
  local const_bottomRight = "+"
  local const_left = "|"
  local const_right = "|"
  local const_between = "|"
  local const_selectedFillerSpace = "#"
  local const_unselectedFillerSpace = " "
  local const_selectedTextSpace = " "
  local const_unselectedTextSpace = " "
  local const_selectedMarginLeft = "# "
  local const_selectedMarginRight = " #"
  local const_unselectedMarginLeft = "  "
  local const_unselectedMarginRight = "  "

  for deviceIndex = 1, #m["Devices"] do
    local songDevice = song["Devices"][deviceIndex]
    local configDevice = m["Devices"][deviceIndex]
    local currentInstrumentIndex = GetCurrentInstrument(deviceIndex)

--print("deviceIndex: " .. deviceIndex)
--for x, y in pairs(song["Devices"][deviceIndex]) do
--   print(y)
-- end
    local instrumentCount = 0
    if configDevice and songDevice then
      instrumentCount = #songDevice
    end

    if instrumentCount == 0 then
      LogMessage(const_topLeft .. const_top .. const_topRight)
      LogMessage(const_left .. const_unselectedTextSpace .. const_right)
      LogMessage(const_left .. const_unselectedTextSpace .. const_right)
      LogMessage(const_left .. const_unselectedTextSpace .. const_right)
      LogMessage(const_bottomLeft .. const_bottom .. const_bottomRight)
    else

      local topRow = const_topLeft
      local fillerRow = const_left
      local textRow = const_left
      local bottomRow = const_bottomLeft

      --    ╭───────────────────┬───────────────────╮
      --    │░░░░░░░░░░░░░░░░░░░│                   │
      --    │░ go-lead         ░│  sca-horn+sectio  │
      --    │░░░░░░░░░░░░░░░░░░░│                   │
      --    ╰───────────────────┴───────────────────╯
      for deviceInstrumentIndex = 1, instrumentCount do
        local filledString = "";
        local unfilledString = "";
        local selectedTextSpace = "";
        local unselectedTextSpace = "";

        for c = 1, CC.mappingCellWidth do
          topRow = topRow .. const_top
          filledString = filledString .. const_selectedFillerSpace
          unfilledString = unfilledString .. const_unselectedFillerSpace
          selectedTextSpace = selectedTextSpace .. const_selectedTextSpace
          unselectedTextSpace = unselectedTextSpace .. const_unselectedTextSpace
          bottomRow = bottomRow .. const_bottom
        end

        if deviceInstrumentIndex == currentInstrumentIndex then
          fillerRow = fillerRow .. filledString
        else
          fillerRow = fillerRow .. unfilledString
        end

        -- text row is harder because it has a margin / truncated / padded text inside.
        local marginLeft = ""
        local marginRight = ""
        local instName = songDevice[deviceInstrumentIndex].name

        if song["Prefix"] then
          if string.starts(instName, song["Prefix"]) then
            instName = string.sub(instName, 1 + string.len(song["Prefix"]))
          end
        end

        if deviceInstrumentIndex == currentInstrumentIndex then
          marginLeft = const_selectedMarginLeft
          marginRight = const_selectedMarginRight
          instName = instName .. selectedTextSpace
        else
          marginLeft = const_unselectedMarginLeft
          marginRight = const_unselectedMarginRight
          instName = instName .. unselectedTextSpace
        end

        -- truncate instname to fit perfectly in mappingCellWidth
        instName = string.sub(instName, 1, CC.mappingCellWidth - CharacterCount(marginLeft) - CharacterCount(marginLeft))
        textRow = textRow .. marginLeft .. instName .. marginRight

        if deviceInstrumentIndex == instrumentCount then
          -- end cap
          fillerRow = fillerRow .. const_right
          textRow = textRow .. const_right
          topRow = topRow .. const_topRight
          bottomRow = bottomRow .. const_bottomRight
        else
          -- divider
          fillerRow = fillerRow .. const_between
          textRow = textRow .. const_between
          topRow = topRow .. const_topTee
          bottomRow = bottomRow .. const_bottomTee
        end

      end-- for each instrument (cell)

      --if deviceIndex == 1 then
      LogMessage(topRow)
      --end
      LogMessage(fillerRow)
      LogMessage(textRow)
      LogMessage(fillerRow)
      LogMessage(bottomRow)

    end-- if instrument count > 0
  end
end

------------------------------------------------------------------------------
function ApplyMapping(m)
  if not m then
    return
  end

  ClearLog()
  
  local song = m["Songs"][CC.currentSongIndex];
  if not song then
    return
  end

  DisplayMappingHeader(m, song)
  
  DisplayMappingDeviceProgramGrid(m, song)

  LogMessage("")

  if song["bpm"] then
    renoise.song().transport.bpm = song["bpm"]
  end
 
  local availableDevices = renoise.Midi.available_input_devices()
  LogMessage("Available device names:")
  for adi = 1,#availableDevices do
    LogMessage(string.format("  %s", availableDevices[adi]))
  end

  LogMessage("")
    
  for _,ri in pairs(renoise.song().instruments) do
    -- is it mapped to any device? if so, set it.
    local wasSelected = false
    for sdi = 1, #song["Devices"] do
      local selectedProgramIndex = GetCurrentInstrument(sdi)
      local configDevice = m["Devices"][sdi]
      local program = song["Devices"][sdi][selectedProgramIndex]
      --local selectedInstrumentName = song["Devices"][sdi][selectedInstrumentIndex]
      if program then
        for layerIndex = 1, #program.layers do
          local layer = program.layers[layerIndex]
          if ri.name == layer.instrument then
            if DeviceNameExists(configDevice["Name"]) then
              ri.midi_input_properties.device_name = m["Devices"][sdi]["Name"]
              ri.midi_input_properties.channel = tonumber(m["Devices"][sdi]["Channel"])
              ri.transpose = layer.transpose
              ri.midi_input_properties.note_range = layer.keyRange

              LogMessage(string.format("Assigning instrument  : %s (%s : %s)", ri.name, m["Devices"][sdi]["Name"], m["Devices"][sdi]["Channel"]))
              wasSelected = true
              break
            else
              -- device doesn't exist ......
              LogMessage(string.format("!!! Would assign instrument  : %s (%s : %s)", ri.name, m["Devices"][sdi]["Name"], m["Devices"][sdi]["Channel"]))
            end
          end
        end
      end

    end
    if not wasSelected then
      LogMessage(string.format("Unassigning instrument: %s", ri.name))
      ri.midi_input_properties.device_name = ""
      ri.midi_input_properties.channel = 0
    end
  end
  
end


------------------------------------------------------------------------------
function SongSelect(_, s)
  --LogMessage(string.format("SDCompo Live Song Select: %d", s))
  local m = getCurrentMapping()
  if not m then
    return
  end
  
  if s < 1 then s = 1 end
  if s > #m["Songs"] then s = #m["Songs"] end
  
  if CC.currentSongIndex ~= s then
    -- rebuild the UI.
    ensureUICreated()
    CC.currentDeviceInstrument = {}-- reset all device instruments to index 1
  end

  CC.currentSongIndex = s
  ApplyMapping(m)
end

------------------------------------------------------------------------------
function InstrumentSelect(_, d, i)
  --LogMessage(string.format("SDCompo Live Instrument Select: %d, %d", d, i))
  local m = getCurrentMapping()
  if not m then
    return
  end
  CC.currentDeviceInstrument[d] = i
  ensureUICreated()
  ApplyMapping(m)
end


------------------------------------------------------------------------------
-- DONE: adapt for instrument object
function InstrumentVolumeChange(mm, d)
  --print(string.format("Song CC: %d", mm.int_value))
  local gainDelta = 0.05
  
  if mm.int_value == 65 then gainDelta = gainDelta
  elseif mm.int_value == 63 then gainDelta = -gainDelta
  else gainDelta = 0.0
  end
  
  local m = getCurrentMapping()
  if not m then return end

  local instrumentName = nil
  
  local song = m["Songs"][CC.currentSongIndex];
  if song then
    local instrumentIndex = GetCurrentInstrument(d)
    if song["Devices"][d] then
      local inst = song["Devices"][d][instrumentIndex]
      if #inst.layers > 1 then
        LogMessage("Unable to set volume on multi-layer programs.")
        return
      end
      instrumentName = inst.layers[1].instrument
    end
  end

  if not instrumentName then return end

  for _,ri in pairs(renoise.song().instruments) do
    if ri.name == instrumentName then
      print(string.format("gain change instrument %s %f %f", ri.name, ri.volume, gainDelta))
      
      local newVolume = ri.volume + gainDelta
      -- *** std::logic_error: 'invalid volume value '2'. valid values are (0 to 1.99526).'
      if newVolume >= 0 and newVolume < 1.99526 then
        ri.volume = ri.volume + gainDelta
      end
    end
  end

  -- update the display showing the volume.
  ensureUICreated()
  ApplyMapping(m)
  
end




------------------------------------------------------------------------------
function ShowSongList(mm)
  local m = getCurrentMapping()
  ensureUICreated()
  if not m then
    return
  end
  
  ClearLog()
  for i = 1,#m["Songs"] do
    LogMessageH2(i .. ": " .. m["Songs"][i]["Name"])
  end
end


------------------------------------------------------------------------------
function destroyGUI()
  if not CC.dialog then
    CC.txtStatus = nil
    return
  end
  if CC.dialog.visible then
    CC.dialog:close()
  end
  CC.txtStatus = nil
end

------------------------------------------------------------------------------
-- create our GUI.
function ensureUICreated()
  if CC.dialog and CC.dialog.visible then
    CC.dialog:show()
    return
  end
  
  local vb = renoise.ViewBuilder()

  CC.txtStatus = vb:multiline_textfield {
    edit_mode = false,
    width = CC.logWidth, --800,
    height = CC.logHeight, --600,
    font = "mono",-- http://xrnx.googlecode.com/svn-history/r706/trunk/Documentation/Renoise.ViewBuilder.API.lua
    --style = "body",
    text = "SDCompo Live Midi Instrument selector."
  }

  CC.dialog = renoise.app():show_custom_dialog("SDCompo Live Status", vb:column {
    id = "sdcompoLiveDialog",
    margin = renoise.ViewBuilder.DEFAULT_CONTROL_MARGIN,
    vb:row {
      CC.txtStatus
    }
  })
  
  SongSelect(nil, CC.currentSongIndex)  
end

------------------------------------------------------------------------------
_AUTO_RELOAD_DEBUG = function()
  renoise.app():show_status("Reloaded SDCompo Live")
  if CC.enableTerminalOutput then print ("Reloaded SDCompo Live") end
end

