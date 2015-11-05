-- themod keyboard
-- 2015-10-22
require('utility')

--------------------------------------------------------------------------------------------
class 'ModSong'

function ModSong:__init(config, raw, nameContext)
	assert(config)
	self.config = config

	if type(raw) == 'ModSong' then
		-- like a copy constructor
		self.raw = raw.raw
		self.name = raw.name
		self.inherits = raw.inherits
		self.image = raw.image
		self.nameContext = raw.nameContext
		self.buttonMap = {}
		for k, v in pairs(raw.buttonMap) do
			self.buttonMap[k] = ModSongButtonMapping(config, self, v, self.nameContext)
		end
	else
		-- from json-deserialized object
		assert(nameContext)
		self.raw = raw
		self.name, self.nameContext = config:parseObjectName(raw.Name, nameContext, "Song")
		self.inherits = config:substituteAliases(raw.Inherits)
		self.image = config:substituteAliases(raw.Image)
		self.buttonMap = {}-- array
		if raw.ButtonMap then
			for k, v in pairs(raw.ButtonMap) do
				self.buttonMap[k] = ModSongButtonMapping(config, self, v, self.nameContext)
			end
		end
	end
end


function ModSong:validate()
	if table.count(self.buttonMap) < 1 then log("! no buttons defined for "..self.nameContext) end
	for k, v in pairs(self.buttonMap) do
		v:validate()
	end
end

function ModSong:dump(depth)
	printWithDepth(depth, "name: "..self.name)
	printWithDepth(depth+1, "inherits: "..coalesceToString(self.inherits))
	printWithDepth(depth+1, "image: "..coalesceToString(self.image))
	printWithDepth(depth+1, "buttonMap: {")
	for k,v in pairs(self.buttonMap) do
		v:dump(depth+2)
	end
	printWithDepth(depth+1, "}")
end



function ModSong:findButtonMapping(buttonName)
	for k, v in pairs(self.buttonMap) do
		if string.lower(v.buttonName) == string.lower(buttonName) then return v end
	end
	return nil
end

function ModSong:applyParent(parent)
	if not self.image then self.image = parent.image end

	for k,v in pairs(parent.buttonMap) do
		local myMapping = self:findButtonMapping(v.buttonName)
		if not myMapping then
			self.buttonMap[k] = ModSongButtonMapping(self.config, self, v, nil)-- add a copy of parent's mapping for ourself
		end
	end

end

function ModSong:cloneWithParent(parent)
	assert(self.config)
	--print("  CloneWithParent / " .. type(self.config))
	local ret = ModSong(self.config, self, nil)
	--print("  ... did we make it?")
	if parent then
		ret:applyParent(parent)
	end
	--print("  done with clonewithparent")
	return ret
end



--------------------------------------------------------------------------------------------
class 'ModSongButtonMapping'

function ModSongButtonMapping:__init(config, song, raw, nameContext)
	self.config = config
	self.song = song

	if type(raw) == 'ModSongButtonMapping' then
		-- copy constructor
		self.raw = raw.raw
		self.buttonName = raw.buttonName
		self.colorScheme = raw.colorScheme
		self.nameContext = raw.nameContext
		self.patchAssignments = {}
		for k, v in pairs(raw.patchAssignments) do
			self.patchAssignments[k] = ModSongButtonPatchAssignment(config, self, song, v, self.nameContext)
		end

		self.sampleTriggers = {}
		for k, v in pairs(raw.sampleTriggers) do
			self.sampleTriggers[k] = v-- simple string; no special copy
		end

	else
		-- from json
		self.raw = raw
		self.buttonName = config:substituteAliases(raw.Button)
		assert(nameContext)
		self.nameContext = nameContext..":SongButtonMapping["..coalesceToString(self.buttonName).."]"
		self.colorScheme = config:getColorSchemeName(raw.ColorScheme, self.nameContext)

		self.patchAssignments = {}
		if raw.PatchAssignments then
			for k, v in pairs(raw.PatchAssignments) do
				self.patchAssignments[k] = ModSongButtonPatchAssignment(config, self, song, v, self.nameContext)
			end
		end

		self.sampleTriggers = {}-- always sample names
		--log("parsing sample triggers..." .. tostring(raw.SampleTriggers))
		if raw.SampleTriggers then
			for k, v in pairs(raw.SampleTriggers) do
				local sampleName = nil
				if type(v) == "string" then
					sampleName = config:substituteAliases(v)
					--log("song sample trigger parsed: "..sampleName)
				else
					local sample = ModSample(self.config, v, self.nameContext)
					table.insert(self.config.samples, sample)
					sampleName = sample.name
					--log("created unnamed sample "..sampleName)
				end

				self.sampleTriggers[k] = sampleName
			end
		end
	end

end


function ModSongButtonMapping:validate()
	if not self.buttonName then log("! button name not set for "..self.nameContext) end
	if not self.colorScheme then log("! color scheme not set for "..self.nameContext) end
	if table.count(self.patchAssignments) < 1 and table.count(self.sampleTriggers) < 1 then log("! no buttons defined for "..self.nameContext) end
	for k, v in pairs(self.patchAssignments) do
		v:validate()
	end
	-- for k, v in pairs(self.sampleTriggers) do
	-- 	v:validate()
	-- end
end


function ModSongButtonMapping:dump(depth)
	printWithDepth(depth, "(ModSongButtonMapping): ")
	printWithDepth(depth+1, "buttonName: "..coalesceToString(self.buttonName))
	printWithDepth(depth+1, "colorScheme: "..coalesceToString(self.colorScheme))
	printWithDepth(depth+1, "patchAssignments: {")
	for k,v in pairs(self.patchAssignments) do
		v:dump(depth+2)
	end
	printWithDepth(depth+1, "}")
	printWithDepth(depth+1, "sampleTriggers: {")
	for k,v in pairs(self.sampleTriggers) do
		printWithDepth(depth+2, ""..k.."="..v)
	end
	printWithDepth(depth+1, "}")
end



--------------------------------------------------------------------------------------------
class 'ModSongButtonPatchAssignment'

function ModSongButtonPatchAssignment:__init(config, mapping, song, raw, nameContext)
	self.config = config
	self.mapping = mapping
	self.song = song

	if type(raw) == 'ModSongButtonPatchAssignment' then
		-- copy constructor
		self.raw = raw.raw
		self.deviceName = raw.deviceName
		self.nameContext = raw.nameContext
		self.patchName = raw.patchName
	else
		-- from json
		assert(nameContext)
		self.nameContext = nameContext..":PatchAssignment[dn="..coalesceToString(self.deviceName).."]"
		self.raw = raw
		self.deviceName = config:substituteAliases(raw.Device)
		assert(self.deviceName)

		if type(raw.Patch) == "string" then
			self.patchName = config:substituteAliases(raw.Patch)
		else
			local patch = ModPatch(config, raw.Patch, self.nameContext)
			table.insert(config.patches, patch)
			self.patchName = patch.name
		end
	end
end



function ModSongButtonPatchAssignment:validate()
	if not self.deviceName then log("! deviceName not set for "..self.nameContext) end
	if not self.patchName then log("! patchName not set for "..self.nameContext) end
end


function ModSongButtonPatchAssignment:dump(depth)
	printWithDepth(depth, "(ModSongButtonPatchAssignment): ")
	printWithDepth(depth+1, "deviceName: "..coalesceToString(self.deviceName))
	printWithDepth(depth+1, "patchName: "..coalesceToString(self.patchName))
end



--------------------------------------------------------------------------------------------


