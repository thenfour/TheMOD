-- themod keyboard
-- 2015-10-22
--local CC = require('namespace')
require("themodapp")

local TheMODAppSingleton = nil

local function Shutdown()
	if TheMODAppSingleton then 
		TheMODAppSingleton:shutdown()
	end
	TheMODAppSingleton = nil
end




local function ModInit()
  Shutdown()
  TheMODAppSingleton = TheMODApp()
end

-- create a midimapping that loads config and everything
renoise.tool():add_midi_mapping {
  name = "TheMOD:The MOD Keyboard Init",
  invoke = ModInit
}

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:The MOD Keyboard Init",
  invoke = ModInit
}

-- renoise.tool():add_menu_entry {
--   name = "Main Menu:Tools:The MOD Keyboard Play Sample",
--   invoke = PlaySample
-- }

