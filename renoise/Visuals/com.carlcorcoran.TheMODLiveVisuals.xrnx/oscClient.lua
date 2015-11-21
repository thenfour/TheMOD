
require("utility")



class 'ModOscClient'

function ModOscClient:__init(host, port, protocol)
	local err

	local correctedProtocol = renoise.Socket.PROTOCOL_UDP
	if string.lower(protocol) == "tcp" then correctedProtocol = renoise.Socket.PROTOCOL_TCP end

	self.oscClient, err = renoise.Socket.create_client(tostring(host), tonumber(port), correctedProtocol)

	if err then
	  error(("Failed to start the OSC client. Error: '%s'"):format(err))
	  return
	end
end

-- msg is a string. it's the one non-generic thing about this class. args are embedded there.
-- /TheMod/LogoMute[16, 1.0, "dude yo"]
-- /TheMod/TriggerSomething

-- local msg = renoise.Osc.Message("/renoise/trigger/note_off", {
-- 	{ tag = "i", value = instrumentIndex },
-- 	{ tag = "i", value = -1 },
-- 	{ tag = "i", value = note }
-- 	})

-- self.oscClient:send(renoise.Osc.Message(msg))

-- http://opensoundcontrol.org/spec-1_0
-- i = int32
-- f = float32
-- s = string

-- i'm not sure AteBit cares about other datatypes, even if they seem usable.
-- b = blob
-- T = true
-- F = false
function ModOscClient:parseMessage(s)
	local id, args = string.match(s, "(.*)%[(.*)%]")
	if id == nil or args == nil then
		return { id=s, args={ } }
	end
	local ret = { id=id, args={} }
	local argStrings = { }
	-- parse args. currently it's like 1,2,3,4. just delimit by comma, don't bother with escapes and shiz
	for arg in string.gmatch(args, "[^,]+") do
		table.insert(argStrings, arg)
	end
	-- now I have args but i need datatypes.
	for _,v in pairs(argStrings) do
		local arg = trim(v)
		-- support only i, f, s tags
		if #arg > 2 and (string.sub(arg, 1, 1) == "\"" or string.sub(arg, 1, 1) == "'") then
			--print("-> it's a string...")
			table.insert(ret.args, { tag="string", value=string.sub(arg,2,#arg-1) })
		else
			-- discern between integer or float.
			if string.find(arg, ".", 1, true) then
				table.insert(ret.args, { tag="float", value=tonumber(arg) })
			else
				table.insert(ret.args, { tag="int", value=tonumber(arg) })
			end
		end
	end
	return ret
end


function ModOscClient:send(command)
	assert(self.oscClient)
	local cmd = self:parseMessage(command)

	log("OSC ID " ..cmd.id)
	for _,v in pairs(cmd.args) do
		log("  - ("..v.tag..") "..v.value)
	end

	local msg = renoise.Osc.Message(cmd.id, cmd.args)
	self.oscClient:send(msg)
end




