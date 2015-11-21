-- this is closely dependent on the routes definition file, TheMod.xml.

local logoOff = { normal="%11", active="%30", pressed="%33" }
local logoOn = { normal="%01", active="%30", pressed="%33" }

local songOff = { normal="%11", active="%30", pressed="%33" }
local songOn = { normal="%01", active="%30", pressed="%33" }

local alt = { normal="%01", active="%03", pressed="%33" }

local fn = { normal="%11", active="%33", pressed="%33" }

-- when the "next module" is set, it also needs a trigger to tell it to GO.
-- by default this is on measure boundary (4 beats). But here we will just do it instantly.
-- this requires of course the proper routing for the "AdvanceToNextModule" trigger.
local triggerModule = "/TheMOD/AdvanceToNextModule"

return {
  device = "Launchpad Mini",
  osc = { host="localhost", port=12000, protocol="UDP"},
  mapping = 
  {
    -- SONGS
    a3 = { colorScheme=logoOff, radioGroup="BigTruffle", osc = { triggerModule, "/TheMOD/BigTruffleCredits[0]", "/TheMOD/BigTruffleBG[0]" } },
    b3 = { colorScheme=logoOn, radioGroup="BigTruffle", osc = { triggerModule, "/TheMOD/BigTruffleCredits[1]", "/TheMOD/BigTruffleBG[1]" } },

    a4 = { colorScheme=logoOff, radioGroup="MegabitsPerSecond", osc = { triggerModule, "/TheMOD/MegabitsPerSecondCredits[0]", "/TheMOD/MegabitsPerSecondBG[0]" } },
    b4 = { colorScheme=logoOn, radioGroup="MegabitsPerSecond", osc = { triggerModule, "/TheMOD/MegabitsPerSecondCredits[1]", "/TheMOD/MegabitsPerSecondBG[1]" } },



    -- GLOBAL
    a0 = { colorScheme=logoOff, radioGroup="logo", osc = { triggerModule, "/TheMOD/Logo[0]" } },
    b0 = { colorScheme=logoOn, radioGroup="logo", osc = { triggerModule, "/TheMOD/Logo[1]" } },

    -- FUNCTIONS
    i8 = { colorScheme=fn, onButtonDown = function(app) app:refreshConfig() end },
    i7 = { colorScheme=fn, osc = { "/AteBitVJInternal/Keyboard/FunctionKeyTrigger[10,1]" } },-- go full screen.

    -- PALETTE
    E5 = { colorScheme={ normal="%00" }},
    F5 = { colorScheme={ normal="%01" }},
    G5 = { colorScheme={ normal="%02" }},
    H5 = { colorScheme={ normal="%03" }},

    E6 = { colorScheme={ normal="%10" }},
    F6 = { colorScheme={ normal="%11" }},
    G6 = { colorScheme={ normal="%12" }},
    H6 = { colorScheme={ normal="%13" }},

    E7 = { colorScheme={ normal="%20" }},
    F7 = { colorScheme={ normal="%21" }},
    G7 = { colorScheme={ normal="%22" }},
    H7 = { colorScheme={ normal="%23" }},

    E8 = { colorScheme={ normal="%30" }},
    F8 = { colorScheme={ normal="%31" }},
    G8 = { colorScheme={ normal="%32" }},
    H8 = { colorScheme={ normal="%33" }},
  }
}
