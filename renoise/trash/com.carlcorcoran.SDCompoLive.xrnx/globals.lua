
local CC = require('namespace')

-- these are hard-coded because we need to know how many midi mappings to create
CC.maxDevices = 4
CC.maxInstrumentsAtATime = 16-- more like "max instruments per song/device"


-- specifies the current status of things. Given this all you need to do is call ApplyMapping() and it's good.
CC.currentMapping = nil
CC.currentSongIndex = 1-- 1-based
CC.currentDeviceInstrument = {}-- maps device index to json instrument index; all 1-based

-- gui status stuff
CC.txtStatus = nil
CC.dialog = nil
CC.logWidth = 800
CC.logHeight = 600
CC.mappingCellWidth = 22
CC.logTruncateColumn = 122
CC.H1Font = "Georgia11"
CC.H2Font = "small"
CC.enableTerminalOutput = false

