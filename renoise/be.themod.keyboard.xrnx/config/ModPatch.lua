-- themod keyboard
-- 2015-10-22
require('utility')


--------------------------------------------------------------------------------------------
class 'ModPatch'

function ModPatch:__init(config, raw, nameContext)
	if type(raw) == "ModPatch" then
		-- copy construct
		self.config = raw.config
		self.raw = raw.raw
		self.name = raw.name
		self.nameContext = raw.nameContext

		self.layers = {}
		for k,v in pairs(raw.layers) do
			table.insert(self.layers, ModPatchLayer(self.config, self, v, self.nameContext))
		end
	else
		-- from json
		self.config = config
		self.raw = raw
		assert(nameContext)
		self.name, self.nameContext = config:parseObjectName(raw.Name, nameContext, "Patch")

		self.layers = {}
		if raw.Layers then
			for k, v in pairs(raw.Layers) do
				self.layers[k] = ModPatchLayer(config, self, v, self.nameContext)
			end
		end

		-- the patch object also IS a layer.
		local selfLayer = ModPatchLayer(config, self, raw, self.nameContext)
		if selfLayer.instrumentName then
			--log("self sample layer registered for " .. self.nameContext)
			table.insert(self.layers, selfLayer)
		else
			--log("self sample layer not viable for " .. self.nameContext)
		end
	end
end

function ModPatch:validate()
	if table.count(self.layers) < 1 then log("! no layers defined for "..self.nameContext) end
	for k, v in pairs(self.layers) do
		v:validate()
	end
end


function ModPatch:dump(depth)
	printWithDepth(depth, "name: "..self.name)
	printWithDepth(depth+1, "layers: {")
	for k,v in pairs(self.layers) do
		v:dump(depth+2)
	end
	printWithDepth(depth+1, "}")
end


function ModPatch:mergeWithPatch(rhs)
	-- just move their layers in here.
	for _,v in pairs(rhs.layers) do
		table.insert(self.layers, v)
	end
end



class 'ModPatchLayer'

function ModPatchLayer:__init(config, patch, raw, nameContext)
	if type(raw) == "ModPatchLayer" then
		-- copy construct
		self.config = raw.config
		self.name = raw.name
		self.nameContext = raw.nameContext
		self.raw = raw.raw
		self.patch = patch
		self.instrumentName = raw.instrumentName
		self.channel = raw.channel
		self.transpose = raw.transpose
		self.keyRange = { raw.keyRange[1], raw.keyRange[2] }
		self.gain = raw.gain
	else
		-- from json
		self.config = config
		self.raw = raw
		self.patch = patch

		self.instrumentName = config:substituteAliases(raw.Instrument)
		self.channel = tonumber(config:substituteAliases(raw.Channel))
		if not self.channel then self.channel = 0 end
		self.transpose = tonumber(config:substituteAliases(raw.Transpose))
		if not self.transpose then self.transpose = 0 end
		self.keyRange = ParseKeyRange(config:substituteAliases(raw.KeyRange)) or { 0, 119 }

		assert(nameContext)
		self.nameContext = nameContext..":PatchLayer[inst="..coalesceToString(self.instrumentName).."]"

		self.gain = tonumber(config:substituteAliases(raw.Gain))
		if not self.gain then self.gain = 0.0 end
	end
end


function ModPatchLayer:validate()
	if not self.instrumentName then log("! no instrument name for "..self.nameContext) end
	if self.gain > 6.0 then log("! gain cannot be greater than 6db for "..self.nameContext) end
end



function ModPatchLayer:dump(depth)
	printWithDepth(depth, "(layers don't have names)")
	printWithDepth(depth+1, "instrumentName: "..coalesceToString(self.instrumentName))
	printWithDepth(depth+1, "channel: "..coalesceToString(self.channel))
	printWithDepth(depth+1, "transpose: "..coalesceToString(self.transpose))
	printWithDepth(depth+1, "gain: "..coalesceToString(self.gain))
	printWithDepth(depth+1, "keyRange[1]: "..coalesceToString(self.keyRange[1]))
	printWithDepth(depth+1, "keyRange[2]: "..coalesceToString(self.keyRange[2]))
end


