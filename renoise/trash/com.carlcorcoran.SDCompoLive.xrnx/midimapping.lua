

local CC = require('namespace')
require("globals")
require("core")


function SongControllerChange(mm)
  --LogMessage(string.format("Song CC: %d", mm.int_value))
  SongSelect(mm, mm.int_value)
end


function InstrumentControllerChange(mm, d)
  --LogMessage(string.format("Instrument CC. Device %d, Instrument %d", d, mm.int_value))
  InstrumentSelect(mm, d, mm.int_value)
end

-- add midi bindings. there are a dynamic number of bindings, depending how many devices and instruments you want to support.
renoise.tool():add_midi_mapping {
  name = "SDCompoLive:Song Select",
  invoke = SongControllerChange
}
renoise.tool():add_midi_mapping {
  name = "SDCompoLive:Previous Song",
  invoke = function()
    SongSelect(nil, CC.currentSongIndex - 1)
  end
}
renoise.tool():add_midi_mapping {
  name = "SDCompoLive:Next Song",
  invoke = function()
    SongSelect(nil, CC.currentSongIndex + 1)
  end
}
renoise.tool():add_midi_mapping {
  name = "SDCompoLive:All notes off",
  invoke = function()
    renoise.song().transport:panic()
  end
}
renoise.tool():add_midi_mapping {
  name = "SDCompoLive:Refresh configuration",
  invoke = function()
    destroyGUI()
    CC.currentMapping = nil
    ensureUICreated()
  end
}


renoise.tool():add_midi_mapping {
  name = "SDCompoLive:Show Song List",
  invoke = ShowSongList
}

for d=1,CC.maxDevices do
  renoise.tool():add_midi_mapping {
    name = string.format("SDCompoLive:Device #%02d:Instrument Select", d),
    invoke = function(mm) return InstrumentControllerChange(mm, d) end
  }
  renoise.tool():add_midi_mapping {
    name = string.format("SDCompoLive:Device #%02d:Instrument Volume (rel)", d),
    invoke = function(mm) return InstrumentVolumeChange(mm, d) end
  }
  renoise.tool():add_midi_mapping {
    name = string.format("SDCompoLive:Device #%02d:Previous Instrument", d),
    invoke = function()
      InstrumentSelect(nil, d, GetCurrentInstrument(d) - 1)
    end
  }
  renoise.tool():add_midi_mapping {
    name = string.format("SDCompoLive:Device #%02d:Next Instrument", d),
    invoke = function()
      InstrumentSelect(nil, d, GetCurrentInstrument(d) + 1)
    end
  }
  for i=1,CC.maxInstrumentsAtATime do
    renoise.tool():add_midi_mapping {
      name = string.format("SDCompoLive:Device #%02d:Select Instrument #%02d", d, i),
      invoke = function (mm) return InstrumentSelect(mm, d, i) end
    }
  end
end

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:SDCompo Live:Previous Song",
  invoke = function()
    SongSelect(nil, CC.currentSongIndex - 1)
  end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:SDCompo Live:Next Song",
  invoke = function()
    SongSelect(nil, CC.currentSongIndex + 1)
  end
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:SDCompo Live:Refresh configuration",
  invoke = function()
    destroyGUI()
    CC.currentMapping = nil
    ensureUICreated()
  end,
  midi_mapping = "SDCompoLive:Refresh configuration"
}


