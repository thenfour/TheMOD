

local red = "#ff0000"
local green = "#0f0"


return {
  device = "Launchpad Mini",
  mapping = 
  {
    A2 = { color=red, pressed = {"TheMODVisuals/ChannelAStart"} },
    B2 = { color=green, pressed = {"TheMODVisuals/ChannelAStart"} },
  }
}


-- /*

-- TODO: reset other radio groups along with the multi OSC

-- colors:

--    off         red
--      00 10 20 30
-- dkgr 01 11 21 31 orange
--      02 12 22 32
--      03 13 23 33
--  green yellow    amber


-- */

-- {
--   "Settings":
--   {
--     "Device" : "Launchpad Mini",
--     "DeviceRows" : "9",
--     "DeviceColumns" : "9",
--     "HighlightDuration" : "250",
--     "OSCHost" : "localhost",
--     "OSCPort" : "12000",
--     "AnimationSpeed" : "8",
--     //"AnimationOverlay" : "26,4:3,0 34,6:3,0 23,2:3,0 17,1:3,0 35,3:3,0 25,3:3,0 14,1:3,0 34,1:3,0 13,2:3,0 26,3:3,0 2,3:3,0 5,7:3,0 33,6:3,0 5,3:3,0 6,3:3,0 23,6:3,0 9,3:3,0 5,6:3,0 6,6:3,0 9,7:3,0 34,2:3,0 28,1:3,0 14,5:3,0 13,1:3,0 9,6:3,0 23,1:3,0 34,5:3,0 9,4:3,0 32,6:3,0 22,6:3,0 34,4:3,0 17,3:3,0 25,2:3,0 18,5:3,0 28,5:3,0 31,5:3,0 35,2:3,0 17,4:3,0 28,3:3,0 18,3:3,0 6,5:3,0 5,5:3,0 26,1:3,0 2,5:3,0 5,4:3,0 6,4:3,0 3,4:3,0 9,5:3,0 8,5:3,0 29,3:3,0 18,6:3,0 28,6:3,0 22,4:3,0 12,4:3,0 32,4:3,0 19,3:3,0 10,6:3,0 23,5:3,0 21,3:3,0 17,2:3,0 26,5:3,0 27,6:3,0 17,6:3,0 35,4:3,0 25,4:3,0 32,3:3,0 28,2:3,0 18,2:3,0 10,5:3,0 22,3:3,0 28,4:3,0 18,4:3,0 26,6:3,0 2,1:3,0 10,4:3,0 31,6:3,0 22,1:3,0 21,2:3,0 20,3:3,0 19,2:3,0 18,1:3,0 20,4:3,0 2,4:3,0 3,1:3,0 25,5:3,0 15,5:3,0 29,2:3,0 32,1:3,0 23,3:3,0 12,1:3,0 27,1:3,0 13,5:3,0 10,7:3,0 15,3:3,0 34,3:3,0 35,5:3,0 31,3:3,0 32,2:3,0 29,4:3,0 33,1:3,0 6,7:3,0 3,3:3,0 31,4:3,0 29,5:3,0 31,2:3,0 13,4:3,0 23,4:3,0 3,2:3,0 2,2:3,0 31,1:3,0 7,5:3,0 26,2:3,0 1,1:3,0 17,5:3,0 22,5:3,0 0,1:3,0 22,2:3,0 14,3:3,0 3,5:3,0 4,1:3,0 5,1:3,0 15,1:3,0 13,3:3,0 12,3:3,0 12,5:3,0 12,2:3,0 32,5:3,0 10,3:3,0",
--     //"AnimationOverlay" : "16,4:3,0 36,4:3,0 12,4:3,0 23,2:3,0 17,1:3,0 11,3:3,0 20,1:3,0 25,3:3,0 15,3:3,0 24,1:3,0 34,1:3,0 16,5:3,0 36,1:3,0 36,5:3,0 30,1:3,0 30,4:3,0 8,1:3,0 13,2:3,0 37,2:3,0 36,3:3,0 8,2:3,0 3,3:3,0 4,3:3,0 35,1:3,0 33,1:3,0 28,4:3,0 8,3:3,0 9,3:3,0 15,4:3,0 25,4:3,0 34,3:3,0 34,2:3,0 21,4:3,0 16,3:3,0 18,1:3,0 24,2:3,0 28,2:3,0 24,5:3,0 13,1:3,0 29,5:3,0 12,3:3,0 22,3:1,1 33,5:3,0 33,4:3,0 33,3:3,0 33,2:3,0 34,5:3,0 31,4:3,0 31,3:3,0 31,2:3,0 37,3:3,0 27,3:3,0 30,3:3,0 30,2:3,0 9,4:3,0 30,5:3,0 29,1:3,0 8,4:3,0 27,2:3,0 34,4:3,0 24,4:3,0 28,3:3,0 28,1:3,0 20,2:3,0 17,3:3,0 20,4:3,0 15,2:3,0 25,2:3,0 21,2:3,0 18,5:3,0 28,5:3,0 25,5:3,0 23,3:1,1 12,1:3,0 25,1:3,0 24,3:3,0 13,5:3,0 22,2:3,0 21,5:3,0 35,5:3,0 21,3:3,0 9,1:3,0 20,5:3,0 20,3:3,0 27,4:3,0 37,4:3,0 15,5:3,0 13,3:3,0 15,1:3,0 17,5:3,0 13,4:3,0 18,3:3,0 3,2:3,0 10,3:3,0 16,2:3,0 4,2:3,0 16,1:3,0 12,5:3,0 9,2:3,0 3,1:3,0 4,5:3,0 3,5:3,0 6,1:3,0 21,1:3,0 4,1:3,0 5,1:3,0 2,1:3,0 1,1:3,0 3,4:3,0 4,4:3,0 12,2:3,0 9,5:3,0 8,5:3,0 36,2:3,0 ",
--     "AnimationOverlay" : "16,4:3,0 36,4:3,0 26,4:3,0 33,2:3,0 43,2:3,0 15,3:3,0 34,1:3,0 13,2:3,0 26,3:3,0 36,3:3,0 3,3:3,0 4,3:3,0 8,3:3,0 9,3:3,0 31,4:3,0 34,2:3,0 13,1:3,0 34,5:3,0 37,3:3,0 27,3:3,0 9,4:3,0 8,4:3,0 34,4:3,0 17,3:3,0 15,2:3,0 18,5:3,0 31,5:3,0 41,5:3,0 28,3:1,1 37,4:3,0 18,3:3,0 36,1:3,0 30,3:3,0 16,1:3,0 10,3:3,0 40,3:3,0 3,4:3,0 4,4:3,0 9,5:3,0 8,5:3,0 36,2:3,0 39,3:3,0 29,3:1,1 12,4:3,0 42,4:3,0 31,3:3,0 13,5:3,0 11,3:3,0 27,2:3,0 26,5:3,0 36,5:3,0 30,1:3,0 40,1:3,0 15,4:3,0 42,3:3,0 28,2:3,0 30,5:3,0 40,5:3,0 26,2:3,0 26,1:3,0 27,5:3,0 27,1:3,0 31,1:3,0 9,2:3,0 16,5:3,0 42,2:3,0 41,1:3,0 3,5:3,0 13,3:3,0 40,2:3,0 39,5:3,0 39,4:3,0 15,5:3,0 40,4:3,0 30,4:3,0 43,3:3,0 33,3:3,0 31,2:3,0 29,2:3,0 39,2:3,0 12,1:3,0 39,1:3,0 18,1:3,0 42,1:3,0 12,3:3,0 35,1:3,0 35,5:3,0 37,2:3,0 1,1:3,0 2,1:3,0 17,1:3,0 30,2:3,0 16,3:3,0 4,5:3,0 13,4:3,0 3,1:3,0 33,4:3,0 43,4:3,0 12,5:3,0 4,2:3,0 16,2:3,0 3,2:3,0 17,5:3,0 8,2:3,0 34,3:3,0 6,1:3,0 4,1:3,0 5,1:3,0 15,1:3,0 8,1:3,0 9,1:3,0 12,2:3,0 27,4:3,0 42,5:3,0 ",
--     "AnimationOverlayWidth" : "84",
--     "Colors" : {
--       // refer to the chart above, and use the "show color sample" menu item to see them on the device
--       "[Inactive]" : "02",
--       "[Inactive2]" : "01",
--       "[Active]" : "31",
--       "[Highlight]" : "30",
--       "[EmptyModuleInactive]" : "13"
--     }
--   },
--   "Mappings":
--   {
--     "Row 0" : 
--     {
--       "Column 1" : { "RadioGroup" : "ChannelA", "Color" : "[Inactive]", "OSC" : [ "TheMODVisuals/ChannelAStart" ] },
--       "Column 2" : { "RadioGroup" : "ChannelA", "Color" : "[Inactive]", "OSC" : [ "TheMODVisuals/ChannelAEnd" ] },
--       "Column 3" : { "RadioGroup" : "ChannelB", "Color" : "[Inactive2]", "OSC" : [ "TheMODVisuals/ChannelBStart" ] },
--       "Column 4" : { "RadioGroup" : "ChannelB", "Color" : "[Inactive2]", "OSC" : [ "TheMODVisuals/ChannelBEnd" ] },
--       "Column 5" : { "RadioGroup" : "ChannelC", "Color" : "[Inactive]", "OSC" : [ "TheMODVisuals/ChannelCStart" ] },
--       "Column 6" : { "RadioGroup" : "ChannelC", "Color" : "[Inactive]", "OSC" : [ "TheMODVisuals/ChannelCEnd" ] },
--       "Column 7" : { "RadioGroup" : "ChannelD", "Color" : "[Inactive2]", "OSC" : [ "TheMODVisuals/ChannelDStart" ] },
--       "Column 8" : { "RadioGroup" : "ChannelD", "Color" : "[Inactive2]", "OSC" : [ "TheMODVisuals/ChannelDEnd" ] }
--     },
--     "Row A" : 
--     {
--       "Column 1" : { "RadioGroup" : "Layer0", "Color" : "[EmptyModuleInactive]", "OSC" : [
--         "TheMODVisuals/Layer0Module0Start"
--         ] },
--       "Column 2" : { "RadioGroup" : "Layer0", "Color" : "[Inactive]", "OSC" : [
--         "TheMODVisuals/Layer0Module1Start"
--         ] },
--       "Column 3" : { "RadioGroup" : "Layer0", "Color" : "[Inactive]", "OSC" : [
--         "TheMODVisuals/Layer0Module2Start"
--         ] },
--       "Column 4" : { "RadioGroup" : "Layer0", "Color" : "[Inactive]", "OSC" : [
--         "TheMODVisuals/Layer0Module3Start"
--         ] },
--       "Column 5" : { "RadioGroup" : "Layer0", "Color" : "[Inactive]", "OSC" : [
--         "TheMODVisuals/Layer0Module4Start"
--         ] },
--       "Column 6" : { "RadioGroup" : "Layer0", "Color" : "[Inactive]", "OSC" : [
--         "TheMODVisuals/Layer0Module5Start"
--         ] },
--       "Column 7" : { "RadioGroup" : "Layer0", "Color" : "[Inactive]", "OSC" : [
--         "TheMODVisuals/Layer0Module6Start"
--         ] }
--     },
--     "Row B" : 
--     {
--       "Column 1" : { "RadioGroup" : "Layer1", "Color" : "[EmptyModuleInactive]", "OSC" : [
--         "TheMODVisuals/Layer1Module0Start"
--         ] },
--       "Column 2" : { "RadioGroup" : "Layer1", "Color" : "[Inactive]", "OSC" : [
--         "TheMODVisuals/Layer1Module1Start"
--         ] },
--       "Column 3" : { "RadioGroup" : "Layer1", "Color" : "[Inactive]", "OSC" : [
--         "TheMODVisuals/Layer1Module2Start"
--         ] },
--       "Column 4" : { "RadioGroup" : "Layer1", "Color" : "[Inactive]", "OSC" : [
--         "TheMODVisuals/Layer1Module3Start"
--         ] },
--       "Column 5" : { "RadioGroup" : "Layer1", "Color" : "[Inactive]", "OSC" : [
--         "TheMODVisuals/Layer1Module4Start"
--         ] },
--       "Column 6" : { "RadioGroup" : "Layer1", "Color" : "[Inactive]", "OSC" : [
--         "TheMODVisuals/Layer1Module5Start"
--         ] },
--       "Column 7" : { "RadioGroup" : "Layer1", "Color" : "[Inactive]", "OSC" : [
--         "TheMODVisuals/Layer1Module6Start"
--         ] }
--     },

--     "Row E" : 
--     {
--       "Column 9" : { "Color" : "33", "OSC" : [] }
--     },

--     "Row F" : 
--     {
--       "Column 9" : { "Color" : "03", "OSC" : [] }
--     },

--     "Row G" : 
--     {
--       "Column 9" : { "Color" : "03", "OSC" : [] }
--     },

--     "Row H" : 
--     {
--       "Column 9" : { "Color" : "30", "OSC" : [] }
--     }
--   }
-- }
