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
  onStartup = function(app)
    app:pressAndReleaseButton("b0")
    --pressAndReleaseButton("a1")
    --pressAndReleaseButton("a2")
    app:pressAndReleaseButton("a3")
    -- pressAndReleaseButton("a4")
    -- pressAndReleaseButton("a5")
    app:pressAndReleaseButton("a6")
    -- pressAndReleaseButton("a7")
    -- pressAndReleaseButton("a8")
  end,
  mapping = 
  {
    -- SONGS
    --b2 = { delayFunctions={{ 1000, function(app) app:pressAndReleaseButton("b3") end }} },
    --c2 = { delayFunctions={{ 1000, function(app) app:pressAndReleaseButton("c3") end }} },

    a2 = { colorScheme=songOff, radioGroup="L1", osc = { triggerModule, "/TheMOD/Layer1Module[0]" } },
    b2 = { colorScheme=songOn, radioGroup="L1", osc = { triggerModule, "/TheMOD/Layer1Module[1]" } },
    c2 = { colorScheme=songOn, radioGroup="L1", osc = { triggerModule, "/TheMOD/Layer1Module[2]" } },
    d2 = { colorScheme=songOn, radioGroup="L1", osc = { triggerModule, "/TheMOD/Layer1Module[3]" } },
    e2 = { colorScheme=songOn, radioGroup="L1", osc = { triggerModule, "/TheMOD/Layer1Module[4]" } },
    f2 = { colorScheme=songOn, radioGroup="L1", osc = { triggerModule, "/TheMOD/Layer1Module[5]" } },
    g2 = { colorScheme=songOn, radioGroup="L1", osc = { triggerModule, "/TheMOD/Layer1Module[6]" } },

    a3 = { colorScheme=songOff, radioGroup="L2", osc = { triggerModule, "/TheMOD/Layer2Module[0]" } },
    b3 = { colorScheme=songOn, radioGroup="L2", osc = { triggerModule, "/TheMOD/Layer2Module[1]" } },
    c3 = { colorScheme=songOn, radioGroup="L2", osc = { triggerModule, "/TheMOD/Layer2Module[2]" } },
    d3 = { colorScheme=songOn, radioGroup="L2", osc = { triggerModule, "/TheMOD/Layer2Module[3]" } },
    e3 = { colorScheme=songOn, radioGroup="L2", osc = { triggerModule, "/TheMOD/Layer2Module[4]" } },
    f3 = { colorScheme=songOn, radioGroup="L2", osc = { triggerModule, "/TheMOD/Layer2Module[5]" } },
    g3 = { colorScheme=songOn, radioGroup="L2", osc = { triggerModule, "/TheMOD/Layer2Module[6]" } },

    a4 = { colorScheme=songOff, radioGroup="L3", osc = { triggerModule, "/TheMOD/Layer3Module[0]" } },
    b4 = { colorScheme=songOn, radioGroup="L3", osc = { triggerModule, "/TheMOD/Layer3Module[1]" } },
    c4 = { colorScheme=songOn, radioGroup="L3", osc = { triggerModule, "/TheMOD/Layer3Module[2]" } },
    d4 = { colorScheme=songOn, radioGroup="L3", osc = { triggerModule, "/TheMOD/Layer3Module[3]" } },
    e4 = { colorScheme=songOn, radioGroup="L3", osc = { triggerModule, "/TheMOD/Layer3Module[4]" } },
    f4 = { colorScheme=songOn, radioGroup="L3", osc = { triggerModule, "/TheMOD/Layer3Module[5]" } },
    g4 = { colorScheme=songOn, radioGroup="L3", osc = { triggerModule, "/TheMOD/Layer3Module[6]" } },

    a5 = { colorScheme=songOff, radioGroup="L4", osc = { triggerModule, "/TheMOD/Layer4Module[0]" } },
    b5 = { colorScheme=songOn, radioGroup="L4", osc = { triggerModule, "/TheMOD/Layer4Module[1]" } },
    c5 = { colorScheme=songOn, radioGroup="L4", osc = { triggerModule, "/TheMOD/Layer4Module[2]" } },
    d5 = { colorScheme=songOn, radioGroup="L4", osc = { triggerModule, "/TheMOD/Layer4Module[3]" } },
    e5 = { colorScheme=songOn, radioGroup="L4", osc = { triggerModule, "/TheMOD/Layer4Module[4]" } },
    f5 = { colorScheme=songOn, radioGroup="L4", osc = { triggerModule, "/TheMOD/Layer4Module[5]" } },
    g5 = { colorScheme=songOn, radioGroup="L4", osc = { triggerModule, "/TheMOD/Layer4Module[6]" } },

    a6 = { colorScheme=songOff, radioGroup="L5", osc = { triggerModule, "/TheMOD/Layer5Module[0]" } },
    b6 = { colorScheme=songOn, radioGroup="L5", osc = { triggerModule, "/TheMOD/Layer5Module[1]" } },
    c6 = { colorScheme=songOn, radioGroup="L5", osc = { triggerModule, "/TheMOD/Layer5Module[2]" } },
    d6 = { colorScheme=songOn, radioGroup="L5", osc = { triggerModule, "/TheMOD/Layer5Module[3]" } },
    e6 = { colorScheme=songOn, radioGroup="L5", osc = { triggerModule, "/TheMOD/Layer5Module[4]" } },
    f6 = { colorScheme=songOn, radioGroup="L5", osc = { triggerModule, "/TheMOD/Layer5Module[5]" } },
    g6 = { colorScheme=songOn, radioGroup="L5", osc = { triggerModule, "/TheMOD/Layer5Module[6]" } },


    -- FUNCTIONS
    i8 = { colorScheme=fn, onButtonDown = function(app) app:refreshConfig("user button") end },
    i7 = { colorScheme=fn, osc = { "/AteBitVJInternal/Keyboard/FunctionKeyTrigger[10,1]" } },-- go full screen.

    -- PALETTE
    -- E5 = { colorScheme={ normal="%00" }},
    -- F5 = { colorScheme={ normal="%01" }},
    -- G5 = { colorScheme={ normal="%02" }},
    -- H5 = { colorScheme={ normal="%03" }},

    -- E6 = { colorScheme={ normal="%10" }},
    -- F6 = { colorScheme={ normal="%11" }},
    -- G6 = { colorScheme={ normal="%12" }},
    -- H6 = { colorScheme={ normal="%13" }},

    -- E7 = { colorScheme={ normal="%20" }},
    -- F7 = { colorScheme={ normal="%21" }},
    -- G7 = { colorScheme={ normal="%22" }},
    -- H7 = { colorScheme={ normal="%23" }},

    -- E8 = { colorScheme={ normal="%30" }},
    -- F8 = { colorScheme={ normal="%31" }},
    -- G8 = { colorScheme={ normal="%32" }},
    -- H8 = { colorScheme={ normal="%33" }},
  }
}
