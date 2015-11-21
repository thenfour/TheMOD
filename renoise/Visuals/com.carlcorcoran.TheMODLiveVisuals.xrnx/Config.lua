
require("utility")

------------------------------------------------------------------------------
function LoadMapping()
  local mappingFileName = renoise.song().file_name .. ".themod.lua"
  local cfg = dofile(mappingFileName)

  -- fix things up.

  -- make all button names lowercase
  local newMapping = {}
  for k,v in pairs(cfg.mapping) do
  	local tmp = v
  	newMapping[string.lower(k)] = v
  end
  cfg.mapping = newMapping

  return cfg
end
