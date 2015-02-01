--[[

Layer Cycler,
2013-08-17, carl corcoran

This script will between part layers.
The intention is to be able to use layers as sample variations. So this script will automatically
route notes to specific layers.

We cycle through layers sequentially.
In order to accommodate playing chords (and not cycling for each note of the chord), there is a
"ignore delay". If you play sequential notes within this delay, the cycle will not continue (all
those notes will play on the same layer).

You can reset the cycle by waiting for the reset delay amount (in ms). The idea here is that when you
start playing a phrase of music, you are beginning a phrase.

]]

CycleResetDelay = Knob("ResetDly", 700, 0, 5000)
CycleIgnoreDelay = Knob("ChordIgnore", 100, 0, 5000)
CycleWrap = OnOffButton("CycleWrap", true)
--autoLayers = OnOffButton("autoLayers", true)
--minLayer = NumBox("minLayer", 1, 1, 32, true)
--minLabel = Label("..")
--maxLayer = NumBox("maxLayer", 2, 1, 32, true)
--maxLabel = Label("..")

local activeVoices = 0
local timeOfLastNotePlayed = 0
local timeOfLastSilence = 0

local currentLayer = 1

--[[
function InitLayerName(layerIndex, label)
	if layerIndex < 1 then
		--label.textColor = "#ff00cc"
		label.text = "Error"
		return
	end

	for i, layer in pairs(Program.layers) do
		if i == layerIndex then
			--label.textColor = "#ffffff"
			label.text = layer.displayName
			return
		end
	end

	--label.textColor = "#ff00cc"
	label.text = "Error"
end
]]

function onInit()
	CycleResetDelay.tooltip = "Duration (ms) of all-notes-off before the cycle resets."
	CycleIgnoreDelay.tooltip = "Does not move to next cycle for notes played within this interval, in milliseconds (useful for playing chords)"
	CycleWrap.tooltip = "If on, wraps the cycle to the beginning after it's completed. If off, holds the last layer until cycle is reset."
	--autoLayers.tooltip = "Automatically cycles across all layers in the program. Otherwise select the min / max layer manually."
	--minLayer.tooltop = "When autoLayers is off, specifies the first layer to cycle through in the sequence. Otherwise ignored."
	--maxLayer.tooltop = "When autoLayers is off, specifies the last layer to cycle through in the sequence. Otherwise ignored."
--[[ -- for some reason these cause machfive to crash... i think it's setting the label color that does it.
	minLayer.changed = function(self)
		InitLayerName(self.value, minLabel)
	end

	maxLayer.changed = function(self)
		InitLayerName(self.value, maxLabel)
	end
--]]
end



function NeedsCycleReset()
	if activeVoices > 0 then
		return false
	end

	if (getTime() - timeOfLastSilence) >= CycleResetDelay.value then
		print ("Resetting cycle because of too long silence (" .. tostring(getTime() - timeOfLastSilence) .. ")")
		return true
	end

	return false
end

function NeedsCycleStep()
	if (timeOfLastNotePlayed == 0) or ((getTime() - timeOfLastNotePlayed) < CycleIgnoreDelay.value) then
		print("ignoring; lastnoteplayed=" .. tostring(timeOfLastNotePlayed) .. ", ignoreDelay=" .. CycleIgnoreDelay.value)
		return false-- ignore it because it was too quick
	end
	return true
end

function tablelength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function GetMinLayer()
	--if autoLayers.value then
		return 1
	--else
	--	return minLayer.value
	--end
end
function GetMaxLayer()
	--if autoLayers.value then
		return tablelength(Program.layers)-- TODO: optimize this out
	--else
	--	return maxLayer.value
	--end
end

function CycleToNextLayer()
	local newLayer = currentLayer + 1

	--local layerCount = tablelength(Program.layers)-- TODO: optimize this out
	local localMaxLayer = GetMaxLayer()
  if newLayer > localMaxLayer then
  	if CycleWrap.value then
	  	newLayer = GetMinLayer()
	  else
	  	newLayer = localMaxLayer
	  end
  end
  currentLayer = newLayer;
end


function onNote(e)
	if NeedsCycleReset(e) then
		currentLayer = GetMinLayer()
	elseif NeedsCycleStep(e) then
		CycleToNextLayer()
	end

	-- clamp new layer to avoid crashes
	if currentLayer < 1 then
		currentLayer = 1
	else
		local layerCount = tablelength(Program.layers)-- TODO: optimize this out
		if currentLayer > layerCount then
			currentLayer = layerCount
		end
	end

	-- send note to specific layer
	print("Sending note to layer " .. tostring(currentLayer))
  playNote(e.note, e.velocity, -1, currentLayer, e.channel)
  timeOfLastNotePlayed = getTime()
  timeOfLastSilence = 0
  activeVoices = activeVoices + 1
end


function onRelease(e)
  activeVoices = activeVoices - 1
  if activeVoices == 0 then
  	timeOfLastSilence = getTime()
  end
end


