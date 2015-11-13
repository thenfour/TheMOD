
local actualHeldNotes = {}-- physically held notes
local heldNotes = {}-- accounting for sustain pedal

local hangoverMS = 1

local sustainPedalCC = 64
local sustainONValue = 127
local sustainOFFValue = 0

PhraserResolutions = {2., 1.5, 4./3., 1., 0.75, 2./3., 0.5, 0.375, 1./3., 0.25, 0.1875, 0.5/3., 0.125}
local resolutionNames = {"1/2", "1/4d", "1/2t", "1/4", "1/8d", "1/4t", "1/8", "1/16d", "1/8t", "1/16", "1/32d", "1/16t", "1/32"}
PhraserResolution = Menu{"Resolution", resolutionNames, selected=10, tooltip = "Phraser resolution"}

--local lowNote = 40 + 12
--local highNote = 66 + 12

local lowNote = Knob("LowNote", 52, 20, 100, true)
local highNote = Knob("HighNote", 78, 20, 100, true)

------------------------------------------------------------------------------------
function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

------------------------------------------------------------------------------------
--[[function GenerateSequence2(heldNotes)
	local octaveSpan = 1

	local heldNotesCopy = deepcopy(heldNotes)
	if #heldNotesCopy == 0 then
		return {}
	end

	-- sort heldNotesCopy
	local sorted = deepcopy(heldNotesCopy)
	table.sort(sorted, function(a,b) return a.note<b.note end)
	local rsorted = deepcopy(heldNotesCopy)
	table.sort(rsorted, function(a,b) return a.note>=b.note end)

	-- repeat over octaves
	local seq = {}
	for octave = 0, octaveSpan do
		for i, v in ipairs(sorted) do
			local vo = deepcopy(v)-- copy this note
			vo.note = vo.note + (12 * octave)
			--print('  inserting note: ' .. vo.note)
			table.insert(seq, vo)
		end
	end
	for octave = octaveSpan, 0 do
		for i, v in ipairs(rsorted) do
			local vo = deepcopy(v)-- copy this note to manipulate it
			vo.note = vo.note + (12 * octave)
			table.insert(seq, vo)
		end
	end
	return seq
end]]

------------------------------------------------------------------------------------
function GenerateSequence(heldNotes)
	local heldNotesCopy = deepcopy(heldNotes)
	if #heldNotesCopy == 0 then
		return {}
	end

	local seq = {}
	local rseq = {}
	for n = lowNote.value, highNote.value do
		for i,v in ipairs(heldNotesCopy) do
			if v.note % 12 == n % 12 then
				-- this note, regardless of octave, exists in the played chord; use it.
				local e = deepcopy(v)
				e.note = n
				table.insert(seq, e)
				table.insert(rseq, 1, e)
				break
			end
		end
	end

	-- in the reverse sequence, remove the first and last elements because they are redundant.
	if #rseq > 0 then
		table.remove(rseq, 1)
	end
	if #rseq > 0 then
		table.remove(rseq, #rseq)
	end

	for i,v in ipairs(rseq) do
		table.insert(seq, v)
	end

	return seq

end

------------------------------------------------------------------------------------
function startArp()
	local seqIndex = 0

	while true do
		local seq = GenerateSequence(heldNotes)
		if #seq == 0 then
			break
		end
		seqIndex = seqIndex % #seq
		local e = seq[seqIndex + 1]

		local stepDurationBeats = PhraserResolutions[PhraserResolution.value]

		--print("playing a note for ms: " .. (beat2ms(stepDurationBeats) + hangoverMS))
		--playNote(e.note, e.velocity, beat2ms(stepDurationBeats) + hangoverMS)
		playNote(e.note, 120, beat2ms(stepDurationBeats) + hangoverMS)
		waitBeat(stepDurationBeats)
		seqIndex = seqIndex + 1
	end
end



------------------------------------------------------------------------------------
function AddIfNotExists(t, e)
	-- is this note in heldNotes?
	local existsAlready = false
	for i,v in ipairs(t) do
	  if v.note == e.note then
	  	existsAlready = true
	    break
	  end
	end
	if not existsAlready then
		table.insert(t, e)
	end
end

------------------------------------------------------------------------------------
function EraseAll(t, e)
	-- is this note in heldNotes?
	while true do
		local wasErased = false
	  for i,v in ipairs(t) do
	    if v.note == e.note then
	      table.remove(t, i)
	      wasErased = true
	      break
	    end
	  end
	  if wasErased then break end
	end
end

------------------------------------------------------------------------------------
function onNote(e)
	--print("onNote {" .. e.note)
	AddIfNotExists(actualHeldNotes, e)
	AddIfNotExists(heldNotes, e)
	if #heldNotes == 1 then
		startArp()-- start the arp when going from 0 to 1 notes. After this the arp will change dynamically to what you're playing.
	end
	--print("}")
end

------------------------------------------------------------------------------------
function onRelease(e)
	EraseAll(actualHeldNotes, e)
	if getCC(sustainPedalCC) == sustainOFFValue then
		heldNotes = deepcopy(actualHeldNotes)
	end
end

------------------------------------------------------------------------------------
function onController(e)
--  print("CC:", e.controller, "Value:", e.value)
  if e.controller == sustainPedalCC then
  	if e.value == sustainOFFValue then
			heldNotes = deepcopy(actualHeldNotes)-- delete all the sustained notes, only saving what is actually physically held down atm.
		end
	else
	  postEvent(e)
  end
end



