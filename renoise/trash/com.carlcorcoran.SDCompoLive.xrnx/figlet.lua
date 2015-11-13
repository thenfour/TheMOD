
-- Lua Figlet

--[[
  Based on figlet.

  FIGlet Copyright 1991, 1993, 1994 Glenn Chappell and Ian Chai
  FIGlet Copyright 1996, 1997 John Cowan
  Portions written by Paul Burton
  Internet: <ianchai@usa.net>
  FIGlet, along with the various FIGlet fonts and documentation, is
    copyrighted under the provisions of the Artistic License (as listed
    in the file "artistic.license" which is included in this package.

--]]

-- Converted to Lua by Nick Gammon
-- 23 November 2010

--[[
   Latin-1 codes for German letters, respectively:
     LATIN CAPITAL LETTER A WITH DIAERESIS = A-umlaut
     LATIN CAPITAL LETTER O WITH DIAERESIS = O-umlaut
     LATIN CAPITAL LETTER U WITH DIAERESIS = U-umlaut
     LATIN SMALL LETTER A WITH DIAERESIS = a-umlaut
     LATIN SMALL LETTER O WITH DIAERESIS = o-umlaut
     LATIN SMALL LETTER U WITH DIAERESIS = u-umlaut
     LATIN SMALL LETTER SHARP S = ess-zed
--]]

local deutsch = {196, 214, 220, 228, 246, 252, 223}
local fcharlist = nil
local magic, hardblank, charheight, maxlen, smush, cmtlines, ffright2left, smush2

local function readfontchar (fontfile, theord, fcharlist, charheight, fileLine)

  local t = {}
  fcharlist [theord] = t
  
  -- read each character line
  
  --[[
  
  eg.
  
  __  __ @
 |  \/  |@
 | \  / |@
 | |\/| |@
 | |  | |@
 |_|  |_|@
         @
         @@
--]]
           
  for i = 1, charheight do
  --if theord == 223 then
    --oprint(fontfile)
 -- end
  local line = fontfile:read ("*l")
    --local line = assert (fontfile:read ("*l"), "Not enough character lines for character " .. theord .. " char line:" .. i .. " file line:" .. fileLine)
    --print(line)
--    assert (line, "Not enough character lines for character " .. theord .. " char line:" .. i .. " file line:" .. fileLine)
    if not line then
      return
    end
    local line = string.gsub (line, "%s+$", "")  -- remove trailing spaces
    assert (line ~= "", "Unexpected empty line")
    
    fileLine = fileLine + 1
    
    -- find the last character (eg. @)
    local endchar = line:sub (-1) -- last character
    
    -- trim one or more of the last character from the end
    while line:sub (-1) == endchar do
      line = line:sub (1, #line - 1)
    end -- while line ends with endchar
    
    table.insert (t, line)
    
  end -- for each line

end -- readfontchar

-- read font file into memory (into table fcharlist)

function readfont (filename)
  local fontfile = assert (io.open (filename, "r"))
  local s
  local fileLine = 1
  
  fcharlist = {}

  -- header line
  s = assert (fontfile:read ("*l"), "Empty FIGlet file")
  fileLine = fileLine + 1
 -- print(s)
  -- eg.  flf2a$ 8 6          59     15     10        0             24463   153
  --      magic  charheight  maxlen  smush  cmtlines  ffright2left  smush2  ??
  
  -- configuration line
  magic, hardblank, charheight, maxlen, smush, cmtlines, ffright2left, smush2 =
      string.match (s, "^(flf2).(.) (-?%d+) %d+ (-?%d+) (-?%d+) (-?%d+) ?(-?%d*) ?(-?%d*) ?(-?%d*)")
           
--[[print(magic)
print(hardblank)
print(charheight)
print(maxlen)
print(smush)
print(cmtlines)
print(ffright2left)
print(smush2)]]

  assert (magic, "Not a FIGlet 2 font file")
  
  -- convert to numbers
  charheight = tonumber (charheight) 
  maxlen = tonumber (maxlen) 
  smush = tonumber (smush) 
  cmtlines = tonumber (cmtlines)
  
  -- sanity check
  if charheight < 1 then
    charheight = 1
  end -- if

  -- skip comment lines      
  for i = 1, cmtlines do
    assert (fontfile:read ("*l"), "Not enough comment lines")
    fileLine = fileLine + 1
  end -- for
  
  -- get characters space to tilde
  for theord = string.byte (' '), string.byte ('~') do
    readfontchar (fontfile, theord, fcharlist, charheight, fileLine)
  end -- for
    
  -- get 7 German characters
  for theord = 1, 7 do
    readfontchar(fontfile, deutsch[theord], fcharlist, charheight, fileLine)
  end -- for
      
  -- get extra ones like:
  -- 0x0395  GREEK CAPITAL LETTER EPSILON
  -- 246  LATIN SMALL LETTER O WITH DIAERESIS

  repeat
    local extra = fontfile:read ("*l")
    if not extra then
      break
    end -- if eof
    fileLine = fileLine + 1
  
    local negative, theord = string.match (extra, "^(%-?)0[xX](%x+)")
    if theord then
      theord = tonumber (theord, 16)
      if negative == "-" then
        theord = - theord
      end -- if negative
    else
      theord = string.match (extra, "^%d+")
      assert (theord, "Unexpected line:" .. extra)
      theord = tonumber (theord)
    end -- if

    readfontchar(fontfile,theord, fcharlist, charheight, fileLine)
    
  until false
      
  fontfile:close ()

  -- remove leading/trailing spaces
  
  for k, v in pairs (fcharlist) do
  
     -- first see if all lines have a leading space or a trailing space
     local leading_space = true
     local trailing_space = true
     for _, line in ipairs (v) do
       if line:sub (1, 1) ~= " " then
         leading_space = false
       end -- if
       if line:sub (-1, -1) ~= " " then
         trailing_space = false
       end -- if
     end -- for each line
     
     -- now remove them if necessary
     for i, line in ipairs (v) do
       if leading_space then
         v [i] = line:sub (2)
       end -- removing leading space
       if trailing_space then
         v [i] = line:sub (1, -2)
       end -- removing trailing space
     end -- for each line
  end -- for each character
  
end -- readfont

-- add one character to output lines
local function addchar (which, output, kern, smush)
  local c = fcharlist [string.byte (which)]
  if not c then
    return
  end -- if doesn't exist
  
  for i = 1, charheight do
  
    if smush and output [i]~= "" and which ~= " " then 
      local lhc = output [i]:sub (-1)
      local rhc = c [i]:sub (1, 1)
      output [i] = output [i]:sub (1, -2)  -- remove last character
      if rhc ~= " " then
        output [i] = output [i] .. rhc
      else
        output [i] = output [i] .. lhc
      end       
      output [i] = output [i] .. c [i]:sub (2)
      
    else 
      output [i] = output [i] .. c [i]
    end -- if 
    
    if not (kern or smush) or which == " "  then
      output [i] = output [i] .. " "
    end -- if
  end -- for
  
end -- addchar

function ascii_art (s, kern, smush)

  assert (fcharlist)
  assert (charheight > 0)
  
  -- make table of output lines
  local output = {}
  for i = 1, charheight do
    output [i] = ""
  end -- for
  
  for i = 1, #s do
    local c = s:sub (i, i)

    if c >= " " and c < "\127" then
      addchar (c, output, kern, smush)
    end -- if in range
   
  end -- for

  -- fix up blank character so we can do a string.gsub on it
  local fixedblank = string.gsub (hardblank, "[%%%]%^%-$().[*+?]", "%%%1")

  for i, line in ipairs (output) do
    output [i] = string.gsub (line, fixedblank, " ")
  end -- for

  return output
end -- function ascii_art

