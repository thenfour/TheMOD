-- themod keyboard
-- 2015-10-22
require('utility')

--------------------------------------------------------------------------------------------
class 'ModSong'

function ModSong:__init(config, raw)
	self.config = config
	self.raw = raw
	self.name = config:parseObjectName(raw.Name, "Song")
	self.inherits = config:substituteAliases(raw.Inherits)

	self.image = config:substituteAliases(raw.Image)
	self.buttonMap = {}-- array
	if raw.ButtonMap then
		for k, v in pairs(raw.ButtonMap) do
			self.buttonMap[k] = ModSongButtonMapping(config, self, v)
		end
	end

	local parent = config:findSong(self.inherits)
	if parent then
		-- merge
	end

end














class 'ModSongButtonMapping'

function ModSongButtonMapping:__init(config, song, raw)
	self.config = config
	self.raw = raw
	self.song = song

	self.buttonName = config:substituteAliases(raw.Button)
	self.colorScheme = config:getColorSchemeName(raw.ColorScheme)

	self.patchAssignments = {}
	if raw.PatchAssignments then
		for k, v in pairs(raw.PatchAssignments) do
			self.patchAssignments[k] = ModSongButtonPatchAssignment(config, self, song, v)
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
				local sample = ModSample(self.config, v)
				table.insert(self.config.samples, sample)
				sampleName = sample.name
				--log("created unnamed sample "..sampleName)
			end

			self.sampleTriggers[k] = sampleName
		end
	end

	-- setVariable

end

class 'ModSongButtonPatchAssignment'

function ModSongButtonPatchAssignment:__init(config, mapping, song, raw)
	self.config = config
	self.raw = raw
	self.mapping = mapping
	self.song = song

	self.outputDeviceName = config:substituteAliases(raw.OutputDevice)

	if type(raw.Patch) == "string" then
		self.patchName = config:substituteAliases(raw.Patch)
	else
		local patch = ModPatch(config, raw.Patch)
		table.insert(config.patches, patch)
		self.patchName = patch.name
	end
end


