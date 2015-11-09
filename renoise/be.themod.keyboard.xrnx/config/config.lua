-- themod keyboard
-- 2015-10-22
require('../utility')
require('config/ModSong')
require('config/ModPatch')
require('config/ModSample')


-- make songs un-selectable like base songs, then don't validate un-selectable songs

--------------------------------------------------------------------------------------------
class 'ModConfig'

function ModConfig:__init(raw, selectedSongName)
	local sw = Stopwatch()

	resetObjectIDs()
	
	self.raw = raw

	self.aliases = self:parseAliases(raw.Aliases)

	-- find selected song aliases
	if selectedSongName and raw.Songs then
		for k,rawSong in pairs(raw.Songs) do
			if rawSong.Name and string.lower(rawSong.Name) == string.lower(selectedSongName) then
				if rawSong.Aliases then
					local songAliases = self:parseAliases(rawSong.Aliases)
					-- now override self.aliases with songAliases
					for songAliasName,songAliasValue in pairs(songAliases) do
						--log("overriding with song alias. "..songAliasName.."="..songAliasValue)
						self.aliases[songAliasName] = songAliasValue
					end
				end
			end
		end
	end

	-- now do recursion on aliases
	for d = 1, 10 do
		local newAliases = { }
		local didAnySubstitutions = false
		for k,v in pairs(self.aliases) do
			local newValue = self:substituteAliases(v)
			newAliases[k] = newValue
			if newValue ~= v then didAnySubstitutions = true end
		end
		self.aliases = newAliases
		if not didAnySubstitutions then break end
	end

	self.settings = {}
	if raw.Settings then
		for k, v in pairs(raw.Settings) do
			self.settings[k] = self:substituteAliases(v)
		end
	end

	self.colorSchemes = { }
	if raw.ColorSchemes then
		for k, v in pairs(raw.ColorSchemes) do
			self.colorSchemes[k] = ModColorScheme(self, v, "root")
		end
	end

	self.hotkeyAssignments = {}
	if raw.HotkeyAssignments then
		for k, v in pairs(raw.HotkeyAssignments) do
			self.hotkeyAssignments[k] = ModHotkeyAssignment(self, v, "root")-- self:substituteAliases(v)
		end
	end

	self.deviceDefs = {}
	if raw.DeviceDefs then
		for k, v in pairs(raw.DeviceDefs) do
			table.insert(self.deviceDefs, ModDeviceDef(self, v, "root"))
		end
	end

	self.patches = {}
	if raw.Patches then
		for k, v in pairs(raw.Patches) do
			self.patches[k] = ModPatch(self, v, "root")
		end
	end

	self.samples = {}
	if raw.Samples then
		for k, v in pairs(raw.Samples) do
			self.samples[k] = ModSample(self, v, "root")
			--log("inserted sample "..self.samples[k].name.." / nameContext:"..self.samples[k].nameContext)
		end
	end

	self.songs = {}
	if raw.Songs then
		for k, v in pairs(raw.Songs) do
			table.insert(self.songs, ModSong(self, v, "root"))
		end
	end

  --log("ModConfig:__init currently @ "..sw:tostring().." seconds. (cs inh)")

	-- fix up inheritance of color schemes
	local newColorSchemes = { }
	for k,cs in pairs(self.colorSchemes) do
		newColorSchemes[k] = self:performColorSchemeInheritance(self.colorSchemes, cs.name, 0)
	end
	self.colorSchemes = newColorSchemes

  --log("ModConfig:__init currently @ "..sw:tostring().." seconds. (song inh)")

	-- fix up inheritance of songs
	local newSongs = { }
	for k,song in pairs(self.songs) do
		--log("performing song inheritance for song "..song.name)
		newSongs[k] = self:performSongInheritance(self.songs, song.name, 0)
	end
	self.songs = newSongs

  --log("ModConfig:__init currently @ "..sw:tostring().." seconds. (sample inh)")

	-- fix up inheritance of samples
	local newSamples = { }
	--log("CLEARING ALL SAMPLES")
	for k,sample in pairs(self.samples) do
		--log("performing sample inheritance for "..sample.name)
		newSamples[k] = self:performSampleInheritance(self.samples, sample.name, 0)
		--log("inserted sample "..newSamples[k].name.." / nameContext:"..newSamples[k].nameContext)
	end
	self.samples = newSamples

  --log("ModConfig:__init currently @ "..sw:tostring().." seconds.")

-- 	local depth = 1
-- 	printWithDepth(depth, "ColorSchemes {")
-- 	for k,v in pairs(self.colorSchemes) do
-- --		v:dump(depth + 1)
-- 	end
-- 	printWithDepth(depth, "} ColorSchemes")

  --log("ModConfig:__init took "..sw:tostring().." seconds.")

end

function ModConfig:validate()
	-- validate everything.
	log("{ performing validation")
	for k, v in pairs(self.colorSchemes) do
		v:validate()
	end

	for k, v in pairs(self.hotkeyAssignments) do
		v:validate()
	end

	for k, v in pairs(self.deviceDefs) do
		v:validate()
	end

	for k, v in pairs(self.patches) do
		v:validate()
	end

	for k, v in pairs(self.samples) do
		v:validate()
	end

	for k, v in pairs(self.songs) do
		v:validate()
	end
	log("} performing validation")
end

function ModConfig:dump(depth)
	if not depth then depth = 0 end
	printWithDepth(depth, "ModConfig {")
	depth = depth + 1

	printWithDepth(depth, "Aliases {")
	for k,v in pairs(self.aliases) do
		printWithDepth(depth + 1, k.."="..v)
	end
	printWithDepth(depth, "} Aliases")

	printWithDepth(depth, "Settings {")
	for k,v in pairs(self.settings) do
		printWithDepth(depth + 1, k.."="..v)
	end
	printWithDepth(depth, "} Settings")

	printWithDepth(depth, "ColorSchemes {")
	for k,v in pairs(self.colorSchemes) do
		v:dump(depth + 1)
	end
	printWithDepth(depth, "} ColorSchemes")

	printWithDepth(depth, "hotkeyAssignments {")
	for _,hk in pairs(self.hotkeyAssignments) do
		hk:dump(depth + 1)
	end
	printWithDepth(depth, "} hotkeyAssignments")

	printWithDepth(depth, "deviceDefs {")
	for _,v in pairs(self.deviceDefs) do
		v:dump(depth + 1)
	end
	printWithDepth(depth, "} deviceDefs")

	printWithDepth(depth, "patches {")
	for _,v in pairs(self.patches) do
		v:dump(depth + 1)
	end
	printWithDepth(depth, "} patches")

	printWithDepth(depth, "samples {")
	for _,v in pairs(self.samples) do
		v:dump(depth + 1)
	end
	printWithDepth(depth, "} samples")

	printWithDepth(depth, "songs {")
	for _,v in pairs(self.songs) do
		v:dump(depth + 1)
	end
	printWithDepth(depth, "} songs")


	depth = depth - 1
	printWithDepth(depth, "} ModConfig")
end




function ModConfig:performColorSchemeInheritance(rawColorSchemes, colorSchemeName, depth)

	local colorScheme = nil
	for k,v in pairs(rawColorSchemes) do
		if string.lower(v.name) == string.lower(colorSchemeName) then
			colorScheme = v
			break
		end
	end

	assert(colorScheme, "  color scheme not found: "..colorSchemeName)
	--printWithDepth(depth, "{ fixing  inheritance for : "..colorScheme.name)

	if depth > 10 then
		error("  infinite loop in color scheme inheritance detected.")
		--printWithDepth(depth, "}")
		return colorScheme:cloneWithParent(nil)
	end
	if colorScheme.isInternalDefault then
		--printWithDepth(depth, "  this is the internal default color scheme...")
		return colorScheme:cloneWithParent(nil)
	end
	local parent = nil
	if colorScheme.inherits then
		--printWithDepth(depth, "  finding parent.")
		parent = self:performColorSchemeInheritance(rawColorSchemes, colorScheme.inherits, depth + 1)
	else
		--printWithDepth(depth, "  no inheritance specified; defaults being applied...")
		-- inherit the interanl default color scheme
		parent = ModColorScheme(self.config, nil, nil)
	end

	if not parent then
		error("  unable to find parent colorScheme "..colorScheme.inherits)
		--printWithDepth(depth, "}")
		return colorScheme:cloneWithParent(nil)
	end
	-- ok we have valid parent and this. merge them.
	--printWithDepth(depth, "  merging with parent: "..parent.name)
	local ret = colorScheme:cloneWithParent(parent)
	--printWithDepth(depth, "  dumping:")
	--ret:dump(depth + 2)
	--printWithDepth(depth, "}")
	return ret
end




function ModConfig:performSongInheritance(rawSongs, songName, depth)
	--log("performSongInheritance("..songName..")")
	local song = nil
	for k,v in pairs(rawSongs) do
		--log("  ? "..songName.." == "..v.name)
		if string.lower(v.name) == string.lower(songName) then
			song = v
			break
		end
	end

	assert(song, "  song not found: "..songName)

	if depth > 10 then
		error("  infinite loop in song inheritance detected.")
		return song:cloneWithParent(nil)
	end
	if not song.inherits then
		return song:cloneWithParent(nil)
	end
	--log("  looking for parent: " .. song.inherits)
	local parent = self:performSongInheritance(rawSongs, song.inherits, depth + 1)
	if not parent then
		error("  unable to find parent song "..song.inherits)
		return song:cloneWithParent(nil)
	end
	-- ok we have valid parent and this. merge them.
	return song:cloneWithParent(parent)
end


function ModConfig:performSampleInheritance(rawSamples, sampleName, depth)
	local sample = nil
	for k,v in pairs(rawSamples) do
		--log("  ? "..sampleName.." == "..v.name)
		if string.lower(v.name) == string.lower(sampleName) then
			sample = v
			break
		end
	end

	if sample == nil then
		-- it's possible for samples to just not be found, in the case of for example a base class inherits "@mysample", and songs are supposed to set "@mysample" variable, and no song is selected.
		return nil
	end
	--assert(sample, "  sample not found: "..sampleName)

	if depth > 10 then
		error("  infinite loop in sample inheritance detected.")
		return sample:cloneWithParent(nil)
	end
	if not sample.inherits then
		return sample:cloneWithParent(nil)
	end
	--log("  looking for parent sample: " .. sample.inherits)
	local parent = self:performSampleInheritance(rawSamples, sample.inherits, depth + 1)
	if not parent then
		--error("  unable to find parent sample "..sample.inherits)
		return sample:cloneWithParent(nil)
	end
	-- ok we have valid parent and this. merge them.
	return sample:cloneWithParent(parent)
end


-- returns aliases array. aliases not preprocessed.
function ModConfig:parseAliases(raw)
	if not raw then return { } end
	local ret = { }
	for k, v in pairs(raw) do
		local k2 = string.lower(k)
		if StringStartsWith2(k2, "@") then k2 = string.sub(k2, 2) end-- remove leading "@"
		ret[k2] = v
		--self:setAliasIn(ret, k, v)
	end
	return ret
end


-- converts @Key to the value associated with the alias "Key". If anything goes wrong, returns "#Key"
-- returns value, didSubstitute
function ModConfig:substituteAliases(s)
	if s == nil then return nil end
	if #s < 3 then return s end
	if not StringStartsWith2(s, "@") then return s end
	local requestedKey = string.sub(s, 2)
	for k,v in pairs(self.aliases) do
		if string.lower(k) == string.lower(requestedKey) then
			--log(" substituteAliases replacing "..s.."->"..v)
			return v
		end
	end
	return s
end


-- returns name, nameContext
function ModConfig:parseObjectName(rawName, nameContext, objType)
	if rawName then
		rawName = self:substituteAliases(rawName)
		return rawName, nameContext..":"..objType.."["..rawName.."]"
	else
		local id = tostring(getUniqueObjectID())
		rawName = nameContext..":"..objType.."[__auto_"..id.."]"
		return rawName, rawName
	end
end


function ModConfig:findSong(name)
	for _,v in pairs(self.songs) do
		if string.lower(v.name) == string.lower(name) then
			return v
		end
	end
	return nil
end


function ModConfig:findButtonDef(buttonName)
	for _, dd in pairs(self.deviceDefs) do
		for _, b in pairs(dd.buttonDefs) do
			if string.lower(b.name) == string.lower(buttonName) then return b end
		end
	end
	return nil
end


function ModConfig:findHotkeyAssignment(hkName)
	--log("you are searchingf or  a hotkey: ".. hkName)
	for _,hk in pairs(self.hotkeyAssignments) do
		--log("hk.name = "..hk.name..", hkName = "..hkName)
		if string.lower(hk.name) == string.lower(hkName) then
			return hk
		end
	end
	return nil
end


function ModConfig:findAllHotkeyAssignments(hkName)
	local ret = {}
	for _,hk in pairs(self.hotkeyAssignments) do
		if string.lower(hk.name) == string.lower(hkName) then
			table.insert(ret, hk)
		end
	end
	return ret
end

-- guaranteed to return a valid object unless allowNil is true
function ModConfig:findColorScheme(csName, allowNil)
	for _,cs in pairs(self.colorSchemes) do
		if string.lower(cs.name) == string.lower(csName) then
			return cs
		end
	end
	if allowNil then return nil end
	-- return default color scheme.
	return ModColorScheme(self, nil, "defaultColorScheme")
end

function ModConfig:getBaseColorSchemeName()
	return self:findSetting("BaseColorScheme", "__base")
end

-- raw is either:
-- * color scheme name
-- * color scheme object to be parsed, inserted, and we return the autogenerated name.
-- * nil, then we return the base color scheme.
function ModConfig:getColorSchemeName(raw, nameContext)
	assert(nameContext)
	if type(raw) == "string" then
		return self:substituteAliases(raw)
	end
	if raw == nil then
		return self:getBaseColorSchemeName()
	end
	local cs = ModColorScheme(self, raw, nameContext)
	table.insert(self.colorSchemes, cs)
	return cs.name
end


function ModConfig:findPatch(patchName)
	if not patchName then return nil end-- nil patches are the same as silence; no error
	for _,p in pairs(self.patches) do
		if string.lower(p.name) == string.lower(patchName) then
			return p
		end
	end
	return nil
end

function ModConfig:findSetting(settingName, default)
	for k,v in pairs(self.settings) do
		if string.lower(k) == string.lower(settingName) then
			return v
		end
	end
	return default
end

function ModConfig:findSample(sampleName)
	for k,v in pairs(self.samples) do
		--log("finding sample / "..sampleName.." / ?"..v.name)
		if string.lower(v.name) == string.lower(sampleName) then
			--log("found! " .. v.name)
			return v
		end
	end
	return nil
end


--------------------------------------------------------------------------------------------
class 'ModColorScheme'

function ModColorScheme:__init(config, raw, nameContext)
	if raw == nil then
		-- return internal default
		self.config = config
		self.isInternalDefault = true
		self.name = "defaultColorScheme"
		self.nameContext = ":DefaultColorScheme"
		self.normal = ModColor("#011")
		self.active = ModColor("#0F0")
		self.pressed = ModColor("#00f")
		return
	elseif type(raw) == 'ModColorScheme' then
		-- copy constructor
		self.config = config
		self.raw = raw.raw
		self.isInternalDefault = raw.isInternalDefault
		self.name = raw.name
		self.nameContext = raw.nameContext
		self.normal = raw.normal
		self.active = raw.active
		self.pressed = raw.pressed
	else
		-- from json
		self.raw = raw
		self.isInternalDefault = false
		self.config = config
		self.name, self.nameContext = config:parseObjectName(raw.Name, nameContext, "ColorScheme")
		self.inherits = config:substituteAliases(raw.Inherits)
		if not self.inherits then
			local base = config:getBaseColorSchemeName()
			if string.lower(self.name) ~= string.lower(base) then
				self.inherits = base
			end
		end
		if raw.Normal then self.normal = ModColor(config:substituteAliases(raw.Normal)) end
		if raw.Active then self.active = ModColor(config:substituteAliases(raw.Active)) end
		if raw.Pressed then self.pressed = ModColor(config:substituteAliases(raw.Pressed)) end
	end
end


function ModColorScheme:applyParent(parent)
	--log("applying parent. self.pressed = "..type(self.pressed))
	--log("parent.pressed="..type(parent.pressed))
	if not self.normal and parent.normal then self.normal = ModColor(parent.normal) end
	if not self.active and parent.active then self.active = ModColor(parent.active) end
	if not self.pressed and parent.pressed then
		self.pressed = ModColor(parent.pressed)
	--	log("self.pressed has been set.")
	end
	--log("applied parent. dumping: {")
	--self:dump(1)
	--log("}")
end

function ModColorScheme:cloneWithParent(parent)
	local ret = ModColorScheme(self.config, self, nil)
	--log("545 self.pressed = "..type(ret.pressed))
	if parent then
		ret:applyParent(parent)
		--log("548 self.pressed = "..type(ret.pressed))
	end
	return ret
end

function ModColorScheme:validate()
	-- nothing really to validate.
end

function ModColorScheme:dump(depth)
	local t
	printWithDepth(depth, "name: "..self.name)
	if self.normal then t = self.normal:tostring() else t = "nil" end
	printWithDepth(depth+1, "normal: "..t)
	if self.active then t = self.active:tostring() else t = "nil" end
	printWithDepth(depth+1, "active: "..t)
	if self.pressed then t = self.pressed:tostring() else t = "nil" end
	printWithDepth(depth+1, "pressed: "..t)
end


--------------------------------------------------------------------------------------------
class 'ModHotkeyAssignment'

function ModHotkeyAssignment:__init(config, raw, nameContext)
	self.config = config
	self.raw = raw
	assert(nameContext)
	self.name, self.nameContext = config:parseObjectName(raw.Name, nameContext, "Hotkey")

	assert(raw.ButtonName, "hotkey ButtonName is nil wat?")

	self.buttonName = config:substituteAliases(raw.ButtonName)
	self.colorScheme = config:getColorSchemeName(raw.ColorScheme, nameContext..":Hotkey["..self.name.."]")
end

function ModHotkeyAssignment:validate()
	if not self.buttonName then log("! buttonName empty for "..self.nameContext) end
	if not self.colorScheme then log("! colorScheme empty for "..self.nameContext) end
end


function ModHotkeyAssignment:dump(depth)
	printWithDepth(depth, "name: "..self.name)
	printWithDepth(depth+1, "buttonName: "..self.buttonName)
	printWithDepth(depth+1, "colorScheme: "..self.colorScheme)
end


--------------------------------------------------------------------------------------------
class 'ModDeviceDef'

function ModDeviceDef:__init(config, raw, nameContext)
	self.config = config
	self.raw = raw
	assert(nameContext)
	self.name, self.nameContext = config:parseObjectName(raw.Name, nameContext, "DeviceDef")

	self.deviceName = raw.DeviceName
	self.isLaunchpadPro = toBoolean(raw.IsLaunchpadPro)

	self.buttonDefs = {}

	if self.isLaunchpadPro then
		for x = 0, 9 do
			for y = 0, 9 do
				local btn = LaunchpadProButton(x, y)
				self.buttonDefs[btn.name] = ModButtonDef(config, self, { Name = btn.name, LPPKey = btn.name }, self.nameContext, true)
			end
		end
	end

	if raw.ButtonDefs then
		for k, v in pairs(raw.ButtonDefs) do
			self.buttonDefs[k] = ModButtonDef(config, self, v, self.nameContext)
		end
	end
end

function ModDeviceDef:validate()
	if not self.deviceName then log("! buttonName empty for "..self.nameContext) end
	for k, v in pairs(self.buttonDefs) do
		v:validate()
	end
end


function ModDeviceDef:dump(depth)
	printWithDepth(depth, "name: "..self.name)
	printWithDepth(depth+1, "deviceName: "..coalesceToString(self.deviceName))
	printWithDepth(depth+1, "isLaunchpadPro: "..coalesceToString(self.isLaunchpadPro))
	printWithDepth(depth+1, "buttonDefs: {")
	for k,v in pairs(self.buttonDefs) do
		v:dump(depth+2)
	end
	printWithDepth(depth+1, "}")
end




class 'ModButtonDef'

function ModButtonDef:__init(config, deviceDef, raw, nameContext, isAutoAdded)
	self.config = config
	self.raw = raw
	self.deviceDef = deviceDef
	self.isAutoAdded = (isAutoAdded == true)
	assert(nameContext)
	self.name, self.nameContext = config:parseObjectName(raw.Name, nameContext, "Button")

	if raw.LPPKey then
		local proc = config:substituteAliases(raw.LPPKey)
		self.LPPKey = LaunchpadProButton(proc)
		--log("LPPKEY: " .. self.LPPKey)
	end

	if raw.CC then
		self.MidiCC = tonumber(config:substituteAliases(raw.CC))
	end

	if raw.Note then
		self.MidiNote = KeyRangeStringToValue(config:substituteAliases(raw.Note))
	end
	if raw.Channel then
		self.MidiChannel = tonumber(config:substituteAliases(raw.Channel))
	end
end

function ModButtonDef:validate()
	if not self.LPPKey and not self.MidiCC and not self.MidiChannel and not self.MidiNote then
		log("! nothing defined for button "..self.nameContext)
	end
end




function ModButtonDef:dump(depth)
	if self.isAutoAdded then return end
	printWithDepth(depth, "name: "..self.name)
	--if self.LPPKey then printWithDepth(depth+1, "LPPKey: "..self.LPPKey:tostring()) else printWithDepth(depth+1, "LPPKey: nil") end
	printWithDepth(depth+1, "LPPKey: "..coalesceToString(self.LPPKey, function(x) return x:tostring() end))
	printWithDepth(depth+1, "MidiCC: "..coalesceToString(self.MidiCC))
	printWithDepth(depth+1, "MidiNote: "..coalesceToString(self.MidiNote))
	printWithDepth(depth+1, "MidiChannel: "..coalesceToString(self.MidiChannel))
end


function ModButtonDef:isEqualTo(rhs)
	assert(rhs)
	assert(rhs.LPPKey, "only launchpad buttons currently supported.")
	assert(self.LPPKey, "only launchpad buttons currently supported.")
	if self.LPPKey and rhs.LPPKey and string.lower(self.LPPKey.name) == string.lower(rhs.LPPKey.name) then return true end
	return false
end


