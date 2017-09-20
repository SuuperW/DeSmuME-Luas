-- Checkpoint viewer bottom screen
local verUSA = true -- set to false if using a EUR ROM
local exactSine = true -- set to true to read sine/cosine as int (no rounding means no rounding errors)
local playerID = 0 -- set to 1 to watch your ghost's values
--------------------------

local pntCheckNum -- Checkpoint number
local pntPlayerData -- X, Y, Z, speed
local pntCheckData -- Checkpoint data

local lap_f = 0

local checkpoint, keycheckpoint, checkpointghost, keycheckpointghost = 0,0,0,0,0
local lap = 0
local xPos, zPos, yPos, speed, boostall, boostmt, mttime = 0,0,0,0,0,0,0
local spPrev = 0;

local realspeed, xPosPrev, zPosPrev = 0.0,0,0
local maxspeed = 0

local angle, yAngle, driftAngle = 0,0,0
local pAng, pDAng = 0,0
local turnLoss = 0
local grip = 0
local air = "Ground"
local spawnpoint = 0

local tSine, tCosi = 0,0
local targSine, targCosi = 0,0

function time(secs)
	t_sec = math.floor(secs) % 60
	if (t_sec < 10) then t_secaux = "0" else t_secaux = "" end
	t_min = math.floor(secs / 60)
	t_mili = math.floor(secs * 1000) % 1000
	if (t_mili < 10) then t_miliaux = "00" elseif (t_mili < 100) then t_miliaux = "0" else t_miliaux = "" end
	return (t_min .. ":" .. t_secaux .. t_sec .. ":" .. t_miliaux .. t_mili)
end
function padLeft(str,pad,len)
	for i = #str, len - 1, 1 do
	str = pad .. str end
	return str
end
function prettyFloat(value, neg)
	value = math.floor(value * 10000) / 10000
	local ret
	if (not (value == 1 or value == -1)) then
		if (value >= 0) then
			value = " " .. value end
		ret = string.sub(value .. "000000", 0, 6)
	else
		if (value == 1) then
			ret = " 1    "
		else
			ret = "-1    "
		end
	end
	if (not neg) then
		ret = string.sub(ret, 2, 6)
	end
	
	return ret
end

function fn()
	-- Read pointer values
	pntCheckNum = memory.readdword(0x021661B0)
	pntCheckData = memory.readdword(0x02175600)
	if (verUSA) then
		pntPlayerData = memory.readdword(0x217ACF8)
	else
		pntPlayerData = memory.readdword(0x217D028)
	end
	pntPlayerData = playerID * 0x5A8 + pntPlayerData

	-- Read checkpoint values
	checkpoint = memory.readbytesigned(pntCheckNum + 0xDAE)
	keycheckpoint = memory.readbytesigned(pntCheckNum + 0xDB0)
	checkpointghost = memory.readbytesigned(pntCheckNum + 0xE3A)
	keycheckpointghost = memory.readbytesigned(pntCheckNum + 0xE3C)
	lap = memory.readbytesigned(pntCheckNum + 0xD9E)
	
	-- Lap time
	lap_f = memory.readdword(pntCheckNum + 0xD80) * 1.0 / 60 - 0.05
	if (lap_f < 0) then lap_f = 0 end

	-- Read positions and speed
	xPosPrev = xPos
	zPosPrev = zPos
	xPos = memory.readdwordsigned(pntPlayerData + 0x80)
	yPos = memory.readdwordsigned(pntPlayerData + 0x80 + 4)
	zPos = memory.readdwordsigned(pntPlayerData + 0x80 + 8)
	spPrev = speed
	speed = memory.readdwordsigned(pntPlayerData + 0x2A8)
	boostall = memory.readbytesigned(pntPlayerData + 0x238)
	boostmt = memory.readbytesigned(pntPlayerData + 0x23C)
	mttime = memory.readdwordsigned(pntPlayerData + 0x30C)
	maxspeed = memory.readdwordsigned(pntPlayerData + 0xD0)
	-- Real speed
	realspeed = math.sqrt(math.abs(zPosPrev - zPos) * math.abs(zPosPrev - zPos) + math.abs(xPosPrev - xPos) * math.abs(xPosPrev - xPos))
	realspeed = math.floor(realspeed * 10) / 10
	
	-- Read angles, more stuff
	pAng = angle
	pDAng = driftAngle
	angle = memory.readwordsigned(pntPlayerData + 0x236)
	yAngle = memory.readwordsigned(pntPlayerData + 0x234)
	driftAngle = memory.readwordsigned(pntPlayerData + 0x388)
	turnLoss = memory.readdwordsigned(pntPlayerData + 0x2D4)
	grip = memory.readdwordsigned(pntPlayerData + 0x240)
	if (memory.readbyte(pntPlayerData + 0x3DD) == 0) then
		air = "Ground"
	else
		air = "Air"
	end
	spawnpoint = memory.readdwordsigned(pntPlayerData + 0x3C4)
	
	-- Travel info
	tSine = memory.readdwordsigned(pntPlayerData + 0x68)
	tCosi = memory.readdwordsigned(pntPlayerData + 0x70)
	targSine = memory.readdwordsigned(pntPlayerData + 0x50)
	targCosi = memory.readdwordsigned(pntPlayerData + 0x58)
end

function fm()
	-- Display lap time
	gui.text(160,22,"Lap = " .. time(lap_f))
	-- Display speed
	gui.text(1, 10, "Speed      = " .. speed)
	gui.text(1, 20, "Max Speed  = " .. maxspeed)
	-- Display position
	gui.text(1, 37, "X, Z, Y = " .. xPos .. ", " .. zPos .. ", " .. yPos)
	gui.text(1, 47, "Real speed = " .. realspeed)
	-- Display boost time
	gui.text(1, 63, "Boost Timer = " .. boostall .. " (" .. boostmt .. ")")
	gui.text(150, 63, "MT Time = " .. mttime)
	-- Display angles
	local sAng = padLeft("" .. angle," ",6);
	local sDAng = padLeft("" .. driftAngle," ",6);
	local sTAng = padLeft("" .. (angle + driftAngle)," ",6);
	gui.text(1,80,"Angle = " .. sAng .. " + " .. sDAng .. " = " .. sTAng)
	local dAng = padLeft("" .. (angle - pAng)," ",6);
	local dDAng = padLeft("" .. (driftAngle - pDAng)," ",6);
	local dTAng = padLeft("" .. (angle + driftAngle - pAng - pDAng)," ",6);
	gui.text(1, 90, "Diff. = " .. dAng .. " + " .. dDAng .. " = " .. dTAng)
	gui.text(1, 100, "yAngle = " .. yAngle)
	gui.text(96, 100, air)
	-- More stuff
	gui.text(1, 115, "turnLoss = " .. turnLoss)
	local displayGrip = grip
	if (not exactSine) then
		displayGrip = prettyFloat(grip / 4096, false)
	end
	gui.text(1, 130, "grip = " .. displayGrip)
	-- Travel info
	local displayDir = tSine
	local displayTarg = targSine
	if (not exactSine) then
		displayDir = prettyFloat(tSine / 4096, true)
		displayTarg = prettyFloat(targSine / 4096, true)
	end
	gui.text(1, 145, "Sine = " .. displayDir .. " (" .. displayTarg .. ")")
	displayDir = tCosi
	displayTarg = targCosi
	if (not exactSine) then
		displayDir = prettyFloat(tCosi / 4096, true)
		displayTarg = prettyFloat(targCosi / 4096, true)
	end
	gui.text(1, 155, "Cosi = " .. displayDir .. " (" .. displayTarg .. ")")
	displayDir = math.sqrt((tSine / 4096) ^ 2 + (tCosi / 4096) ^ 2)
	displayTarg = math.sqrt((targSine / 4096) ^ 2 + (targCosi / 4096) ^ 2)
	-- These numbers aren't in the game's memory, thus rounding will always happen.
	displayDir = prettyFloat(displayDir, false)
	displayTarg = prettyFloat(displayTarg, false)
	gui.text(140, 145, "Total: " .. displayDir)
	gui.text(176, 155, "(" .. displayTarg .. ")")

	-- Display checkpoints
	if (spawnpoint > -1) then gui.text(1, 170, "Spawn Point: " .. spawnpoint) end
	
	gui.text(1, 180, "Checkpoint number (player) = " .. checkpoint .. " (" .. keycheckpoint .. ")")
	-- gui.text(100, 170, "Lap: " .. lap) Lap var is wrong.
end

function refresh()
	fn()
	fm()
end

emu.registerafter(fn)
gui.register(fm)
