-- themod keyboard
-- 2015-10-22
require('utility')


--------------------------------------------------------------------------------------------
class 'ModSample'

function ModSample:__init(config, raw, nameContext)
	assert(config)
	self.config = config

	if type(raw) == 'ModSample' then
		-- copy construct
		self.raw = raw.raw
		self.nameContext = raw.nameContext
		self.name = raw.name
		self.inherits = raw.inherits
		self.layers = { }
		for k, v in pairs(raw.layers) do
			self.layers[k] = ModSampleLayer(config, self, v, self.nameContext)
		end
	else
		-- from json
		self.raw = raw
		assert(nameContext)
		self.name, self.nameContext = config:parseObjectName(raw.Name, nameContext, "Sample")

		self.inherits = config:substituteAliases(raw.Inherits)

		self.layers = {}
		if raw.Layers then
			for k, v in pairs(raw.Layers) do
				local layer = ModSampleLayer(config, self, v, self.nameContext)
				self.layers[k] = layer
			end
		end

		-- the sample object also IS a layer.
		local selfLayer = ModSampleLayer(config, self, raw, self.nameContext)
		if selfLayer.instrumentName or selfLayer.note or selfLayer.velocity then
			log("self sample layer registered for " .. self.nameContext)
			table.insert(self.layers, selfLayer)
		else
			log("self sample layer not viable for " .. self.nameContext)
		end
	end
end

function ModSample:validate()
	if table.count(self.layers) < 1 then log("! no layers defined for sample "..self.nameContext)	end
	for k, v in pairs(self.layers) do
		v:validate()
	end
end

function ModSample:dump(depth)
	printWithDepth(depth, "name: "..self.name)
	printWithDepth(depth+1, "inherits: "..coalesceToString(self.inherits))
	printWithDepth(depth+1, "layers: {")
	for k,v in pairs(self.layers) do
		v:dump(depth+2)
	end
	printWithDepth(depth+1, "}")
end

function ModSample:applyParent(parent)
	assert(self.config)
	assert(parent.config)

	-- if both have 1 layer, merge them. otherwise, concat.
	if table.count(parent.layers) == 1 and table.count(self.layers) == 1 then
		self.layers[1]:applyParent(parent.layers[1])
	else
		for k, parentLayer in pairs(parent.layers) do
			-- tro to find a suitable layer to merge with in ourself.
			local found = false
			for myk, myLayer in pairs(self.layers) do
				if myLayer.isEqualTo(parentLayer) then
					myLayer.applyParent(parentLayer)
					found = true
					break
				end
			end

			if not found then
				-- add a new copy.
				table.insert(self.layers, ModSampleLayer(self.config, self, parentLayer, self.nameContext..":ParentLayer["..parentLayer.nameContext.."]"))
			end
		end
	end
end

function ModSample:cloneWithParent(parent)
	local ret = ModSample(self.config, self, self.nameContext.."-cloneWithParent")
	if parent then
		ret:applyParent(parent)
	end
	return ret
end






class 'ModSampleLayer'

function ModSampleLayer:__init(config, sample, raw, nameContext)
	if type(raw) == 'ModSampleLayer' then
		-- copy construct
		self.config = raw.config
		self.sample = raw.sample
		self.raw = raw.raw
		self.nameContext = raw.nameContext

		self.instrumentName = raw.instrumentName
		self.note = raw.note
		self.velocity = raw.velocity
	else
		-- from json
		self.config = config
		self.sample = sample
		self.raw = raw

		self.instrumentName = config:substituteAliases(raw.Instrument)
		log("sample layer parsed instrument name: "..coalesceToString(self.instrumentName).." for "..nameContext)
		self.note = KeyRangeStringToValue(config:substituteAliases(raw.Note))
		self.velocity = tonumber(config:substituteAliases(raw.Velocity))
		-- track?

		assert(nameContext)
		self.nameContext = nameContext..":SampleLayer[inst="..coalesceToString(self.instrumentName)..", note="..coalesceToString(self.note).."]"
	end
end

function ModSampleLayer:validate()
	if not self.instrumentName then log("! no instrument name for "..self.nameContext) end
end


function ModSampleLayer:dump(depth)
	printWithDepth(depth, "(ModSampleLayer)")
	printWithDepth(depth+1, "instrumentName: "..coalesceToString(self.instrumentName))
	printWithDepth(depth+1, "note: "..coalesceToString(self.note))
	printWithDepth(depth+1, "velocity: "..coalesceToString(self.velocity))
end


function ModSampleLayer:applyParent(parent)
	if not self.instrumentName then self.instrumentName = parent.instrumentName end
	if not self.note then self.note = parent.note end
	if not self.velocity then self.velocity = parent.velocity end
end


function ModSampleLayer:isEqualTo(rhs)
	if not self.instrumentName then return false end
	if not rhs.instrumentName then return false end
	if string.lower(rhs.instrumentName) ~= string.lower(self.instrumentName) then return false end
	return (self.note ~= nil) and (self.note == rhs.note)
end


