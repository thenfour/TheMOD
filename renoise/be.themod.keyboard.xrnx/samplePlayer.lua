-- themod keyboard
-- 2015-10-22
--local CC = require('namespace')


class("ModSamplePlayer")

-- protocol is a string "UDP" or "TCP"
function ModSamplePlayer:__init(host, port, protocol)

	self:shutdown()

	local socket_error
	local protocol = renoise.Socket.PROTOCOL_UDP
	if string.lower(protocol) == "tcp" then
		protocol = renoise.Socket.PROTOCOL_TCP
	end
	self.client, socket_error = renoise.Socket.create_client(host, tonumber(port), protocol)

	if socket_error then 
		error("Couldn't start sample player OSC client. Connection issue or some shit.")
	  return
	end

	--alert("connected fine."..tostring(self.client.is_open))

end


function ModSamplePlayer:shutdown()
	if self.client then
		self.client:close()
	end
end

function ModSamplePlayer:findInstrumentIndex(name)
  for i,inst in ipairs(renoise.song().instruments) do
  	if string.lower(name) == string.lower(inst.name) then
  		return i, inst-- needs to be 0-based for OSC
  	end
  end
  return nil
end

function ModSamplePlayer:noteOn(instrumentName, note, velocity)

	-- https://github.com/renoise/xrnx/blob/master/GlobalOscActions.lua#L21
	-- http://forum.renoise.com/index.php/topic/45404-solved-osc-renoisetriggernote-on/

	-- /renoise/trigger/note_on(
	-- * instr(int32/64)
	-- * track(int32/64) -- -1 for current track (default)
	-- * note(int32/64)
	-- * velocity(int32/64))

	local instrumentIndex, instrument = self:findInstrumentIndex(instrumentName)
	if not instrumentIndex then
		error("samplePlayer:instrument not found:"..instrumentName)
	end

	local track = -1

	if instrument.midi_input_properties.assigned_track > 0 then
		track = instrument.midi_input_properties.assigned_track
	end

	--log("playing sample. Instrument #"..instrumentIndex.." ("..instrumentName.."), note "..note..", velocity "..velocity)
	local msg = renoise.Osc.Message("/renoise/trigger/note_on", {
		{ tag = "i", value = instrumentIndex },
		{ tag = "i", value = track },
		{ tag = "i", value = note },
		{ tag = "i", value = velocity }
		})

	self.client:send(msg)

end

function ModSamplePlayer:noteOff(instrumentName, note)

	local instrumentIndex = self:findInstrumentIndex(instrumentName)
	if not instrumentIndex then
		error("samplePlayer:instrument not found:"..instrumentName)
	end

	-- /renoise/trigger/note_off(
	-- * instr(int32/64)
	-- * track(int32/64)
	-- * note(int32/64))

	log("sending note off.")
	local msg = renoise.Osc.Message("/renoise/trigger/note_off", {
		{ tag = "i", value = instrumentIndex },
		{ tag = "i", value = -1 },
		{ tag = "i", value = note }
		})

	self.client:send(msg)

end

