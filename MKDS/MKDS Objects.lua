local displayObjectList = false;
local beginListAtObject = 0;
local displayNearestObject = true;

local objectArrayPointer = 0x0217B598;
local firstObjectOffset = 0x38;
local objectDataLength = 0x1C;
local objectDetailsPointerOffset = 0x18;

local objectXOffset = 0x4;
local objectYOffset = 0x8;
local objectZOffset = 0xC;
local objectCollectedOffset = 0x2;
local objectSizeOffset = 0x58;

local playerDataPointer = 0x0217ACF8;
local playerXOffset = 0x1B8;
local playerYOffset = 0x1BC;
local playerZOffset = 0x1C0;

local objectTypes = { };
objectTypes[0x000b] = "STOP! signage";
objectTypes[0x000d] = "puddle";
objectTypes[0x0065] = "item box";
objectTypes[0x0066] = "post";
objectTypes[0x0067] = "wooden crate";
objectTypes[0x0068] = "coin";
objectTypes[0x006e] = "gate trigger";
objectTypes[0x00c9] = "moving item box";
objectTypes[0x00cd] = "clock";
objectTypes[0x00cf] = "pendulumn";
objectTypes[0x012e] = "coconut tree";
objectTypes[0x012f] = "pipe";
objectTypes[0x0130] = "wumpa-fruit tree";
objectTypes[0x0138] = "striped tree";
objectTypes[0x0145] = "autumn tree";
objectTypes[0x0146] = "winter tree";
objectTypes[0x0148] = "palm tree";
objectTypes[0x014f] = "pinecone tree";
objectTypes[0x0150] = "beanstalk";
objectTypes[0x0156] = "N64 winter tree";
objectTypes[0x0191] = "goomba";
objectTypes[0x0192] = "giant snowball";
objectTypes[0x0193] = "thwomp";
objectTypes[0x0195] = "bus";
objectTypes[0x0196] = "chain chomp";
objectTypes[0x0197] = "chain chomp post";
objectTypes[0x0198] = "leaping fireball";
objectTypes[0x0199] = "mole";
objectTypes[0x019a] = "car";
objectTypes[0x019b] = "cheep cheep";
objectTypes[0x019c] = "truck";
objectTypes[0x019d] = "snowman";
objectTypes[0x019e] = "coffin";
objectTypes[0x019f] = "bats";
objectTypes[0x01a2] = "bullet bill";
objectTypes[0x01a3] = "walking tree";
objectTypes[0x01a4] = "flamethrower";
objectTypes[0x01a5] = "stray chain chomp";
objectTypes[0x01ac] = "crab";
objectTypes[0x01a6] = "pirahna plant";
objectTypes[0x01a7] = "rocky wrench";
objectTypes[0x01a8] = "bumper";
objectTypes[0x01a9] = "flipper";
objectTypes[0x01af] = "fireballs";
objectTypes[0x01b0] = "pinball";
objectTypes[0x01b1] = "boulder";
objectTypes[0x01b2] = "pokey";
objectTypes[0x01f5] = "bully";
objectTypes[0x01f6] = "Chief Chilly";
objectTypes[0x01f8] = "King Bomb-omb";
objectTypes[0x01fb] = "Eyerock";
objectTypes[0x01fd] = "King Boo";
objectTypes[0x01fe] = "Wiggler";


function displayItemBoxes()
	local address = memory.readdword(objectArrayPointer) + firstObjectOffset;
	local itemBoxCount = 0;
	if (address == 0) then -- useless?
		return;
	end
	
	local nearestObject = {dist = 9999999999, id = -1};
	local renderY = 20;
	local objectDetailsAddress = memory.readdword(address + objectDetailsPointerOffset);
	while (objectDetailsAddress ~= 0 and itemBoxCount < 100) do
		local objectX = memory.readdwordsigned(objectDetailsAddress + objectXOffset);
		local objectY = memory.readdwordsigned(objectDetailsAddress + objectYOffset);
		local objectZ = memory.readdwordsigned(objectDetailsAddress + objectZOffset);
		
		local collected = memory.readbyte(objectDetailsAddress + objectCollectedOffset);
		collected = math.floor(collected / 2) ~= collected / 2; -- 0x01 bit
		
		local displayString;
		if (collected) then 
			displayString = "Obj " .. itemBoxCount .. ": collected";
		else
			displayString = "Obj " .. itemBoxCount .. ": " ..
			  objectX .. ", " .. objectY .. ", " .. objectZ;
			  
			local playerAddress = memory.readdword(playerDataPointer);
			local playerX = memory.readdwordsigned(playerAddress + playerXOffset);
			local playerY = memory.readdwordsigned(playerAddress + playerYOffset);
			local playerZ = memory.readdwordsigned(playerAddress + playerZOffset);
			
			local objectDistance = {};
			objectDistance.x = playerX - objectX;
			objectDistance.y = playerY - objectY;
			objectDistance.z = playerZ - objectZ;
			objectDistance.dist = math.sqrt(objectDistance.x ^ 2 +
			  objectDistance.y ^ 2 + objectDistance.z ^ 2);
			local ibSize = memory.readdword(objectDetailsAddress + objectSizeOffset) + 32768;
			objectDistance.dist = objectDistance.dist - ibSize;
			objectDistance.dist = math.floor(objectDistance.dist * 10) / 10;
			if (objectDistance.dist < nearestObject.dist) then
				local objType = memory.readword(objectDetailsAddress);
				if (objType ~= 0) then
					nearestObject = objectDistance;
					nearestObject.id = itemBoxCount;
					nearestObject.type = objType;
				end
			end
		end
		
		displayString = displayString .. ", " ..
		  string.format("%x", objectDetailsAddress + 0x12e3fe0);
		if (displayObjectList and beginListAtObject <= itemBoxCount and renderY < 150) then
			gui.text(4, renderY, displayString);
			renderY = renderY + 12;
		end
		
		itemBoxCount = itemBoxCount + 1;
		address = address + objectDataLength;
		objectDetailsAddress = memory.readdword(address + objectDetailsPointerOffset);
	end -- do while
	
	if (displayNearestObject and nearestObject.id ~= -1) then
		local objectType = objectTypes[nearestObject.type];
		if (objectType == nil) then
			objectType = "0x" .. string.format("%x", nearestObject.type);
		end
		
		gui.text(4, 158, "-- Nearest object (" .. objectType .. ") --");
		if (not string.find(nearestObject.dist, "%.")) then
			nearestObject.dist = nearestObject.dist .. ".0";
		end
		gui.text(4, 170, "ID: " .. nearestObject.id .. ", " ..
		  "Distance: " .. nearestObject.dist .. " to collect");
		gui.text(4, 182, "XYZ dist: " .. nearestObject.x .. ", " .. 
		  nearestObject.y .. ", " .. nearestObject.z);
	end
	
	gui.text(4, 2, "Objects: " .. itemBoxCount);
end

gui.register(displayItemBoxes);