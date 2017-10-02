-- Checkpoint viewer bottom screen
-- By MKDasher, edited by Suuper
local showNonKeyCheckpoints = true;

local lastInput = {};

local pntCheckNum = memory.readdword(0x021661B0) -- Checkpoint number
local pntPlayerData = memory.readdword(0x0217ACF8) -- X, Y, Z, speed
local pntCheckData = memory.readdword(0x02175600) -- Checkpoint data

local angle = 0
local angle2 = 0
local pAng1, pAng2 = 0,0
local anglerad = 0

local checkpoint, keycheckpoint, checkpointghost, keycheckpointghost = 0,0,0,0
local xpos, ypos, zpos, speed = 0,0,0,0

local chkdistance = 0x24
local chkAddr = memory.readdword(pntCheckData + 0x44)
-- + chkdistance + (0,4,8,12)

local totalcheckpoints = 0
-- centro = (127.5,97)

local xaux, yaux, x1aux, y1aux, x2aux, y2aux = 0,0,0,0,0,0

local zoomFactor = 24000

function fn()
   pntCheckNum = memory.readdword(0x021661B0)
   pntPlayerData = memory.readdword(0x0217ACF8)
   pntCheckData = memory.readdword(0x02175600)

   --angle = memory.readwordsigned(pntPlayerData + 0x236)
   checkpoint = memory.readbytesigned(pntCheckNum + 0xDAE)
   keycheckpoint = memory.readbytesigned(pntCheckNum + 0xDB0)
   checkpointghost = memory.readbytesigned(pntCheckNum + 0xE3A)
   --keycheckpointghost = memory.readbytesigned(pntCheckNum + 0xE3C)
   totalcheckpoints = memory.readword(pntCheckData + 0x48)
   
   pAng2 = pAng1
   pAng1 = angle2
   angle2 = memory.readwordsigned(0x0217B64C) / 4096
   angle2 = math.asin(angle2) * -2

   xpos = memory.readdwordsigned(pntPlayerData + 0x80)
   zpos = memory.readdwordsigned(pntPlayerData + 0x80 + 4)
   ypos = memory.readdwordsigned(pntPlayerData + 0x80 + 8)
   speed = memory.readbytesigned(pntPlayerData + 0x45E)

   chkAddr = memory.readdword(pntCheckData + 0x44)
   
   -- Default value of this address is 134, for which zoomFactor should be 24,000.
    local zoomAddress = memory.readdword(0x217B330) + 0x854;
    zoomFactor = 134 / memory.readdword(zoomAddress);
    zoomFactor = zoomFactor * 24000;
   
    local currentInput = input.get();
    if (currentInput.T and not lastInput.T) then
        showNonKeyCheckpoints = not showNonKeyCheckpoints;
    end
    lastInput = currentInput;
end

function fm()
  if (totalcheckpoints < 1 or totalcheckpoints > 80) then
    totalcheckpoints = 0
  end
  if (totalcheckpoints > 0) then
    gui.text(0,180,"Cur. checkpoint = " .. checkpoint .. "(" .. keycheckpoint .. ")")
  
    gui.text(12,5, "Start line", "red")
    gui.box(2,5,8,11, "red", "black")
    gui.text(12,15, "Key checkpoint", "cyan")
    gui.box(2,15,8,21, "cyan", "black")
	if (showNonKeyCheckpoints) then
      gui.text(12,25, "Normal checkpoint", "yellow")
      gui.box(2,25,8,31, "yellow", "black")
	end
  end
  for i = 0, totalcheckpoints - 1 do
    local cp1x = memory.readdwordsigned(chkAddr + i * chkdistance + 0x0) / zoomFactor
    local cp1y = memory.readdwordsigned(chkAddr + i * chkdistance + 0x4) / zoomFactor
    local cp2x = memory.readdwordsigned(chkAddr + i * chkdistance + 0x8) / zoomFactor
    local cp2y = memory.readdwordsigned(chkAddr + i * chkdistance + 0xC) / zoomFactor
    xaux = xpos / zoomFactor
    yaux = ypos / zoomFactor
	
	--gui.text(100, 60, xaux .. ", " .. yaux)
	--gui.text(100, 70, xaux - cp1x)

	anglerad = pAng2
    x1aux = 128 + (xaux - cp1x) * math.cos(anglerad) - (yaux - cp1y) * math.sin(anglerad)
    y1aux = 97 + (yaux - cp1y) * math.cos(anglerad) + (xaux - cp1x) * math.sin(anglerad)
    x2aux = 128 + (xaux - cp2x) * math.cos(anglerad) - (yaux - cp2y) * math.sin(anglerad)
    y2aux = 97 + (yaux - cp2y) * math.cos(anglerad) + (xaux - cp2x) * math.sin(anglerad)
	--gui.text(100, 90, x1aux .. ", " .. y1aux)
	--gui.text(100, 105, x2aux .. ", " .. y2aux)
	--gui.text(100, 120, math.cos(anglerad))
 
	local color = ""
    if (i == 0) then
      color = "red"
    elseif (memory.readwordsigned(chkAddr + i * chkdistance + 0x20) >= 0) then
      color = "cyan"
    else
	  if (showNonKeyCheckpoints) then
        color = "yellow"
	  end
    end
	
	cp1x = x1aux;
	cp1y = y1aux;
	cp2x = x2aux;
	cp2y = y2aux;
    if (y1aux >= 0 and y2aux >= 0) then
	  -- nothing
    elseif(y1aux > 0) then
      distauxy = y1aux - y2aux
      distauxx = x1aux - x2aux
      cp2x = x1aux - (y1aux * distauxx / distauxy)
	  cp2y = 0
    elseif(y2aux > 0) then
      distauxy = y2aux - y1aux
      distauxx = x2aux - x1aux
      cp1x = x2aux - (y2aux * distauxx / distauxy)
	  cp1y = 0
    end
	
	if (color ~= "") then
	  if (cp1y >= 0 or cp2y >= 0) then
        gui.line(cp1x, cp1y, cp2x, cp2y, color)
      end
		
      if (y1aux > 0) then
        gui.text(x1aux,y1aux, i, color)
      end
      if (y2aux > 0) then
        gui.text(x2aux,y2aux, i, color)
      end
	end
	
  end -- for
end

emu.registerbefore(fn)
gui.register(fm)