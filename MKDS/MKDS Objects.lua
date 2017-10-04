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
			if (objectDistance.dist < nearestObject.dist) then -- and objectDistance.dist > -100000) then
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
		local objectType = "0x" .. string.format("%x", nearestObject.type);
		if (nearestObject.type == 0x0068) then
			objectType = "coin";
		elseif (nearestObject.type == 0x0130) then
			objectType = "wumpa-fruit tree";
		elseif (nearestObject.type == 0x0065) then
			objectType = "item box";
		elseif (nearestObject.type == 0x006e) then
			objectType = "gate trigger";
		elseif (nearestObject.type == 0x0066) then
			objectType = "post";
		elseif (nearestObject.type == 0x019b) then
			objectType = "cheep cheep";
		elseif (nearestObject.type == 0x012e) then
			objectType = "coconut tree";
		elseif (nearestObject.type == 0x012f) then
			objectType = "pipe";
		elseif (nearestObject.type == 0x0199) then
			objectType = "mole";
		elseif (nearestObject.type == 0x000b) then
			objectType = "STOP! signage";
		elseif (nearestObject.type == 0x01b2) then
			objectType = "pokey";
		elseif (nearestObject.type == 0x0148) then
			objectType = "palm tree";
		elseif (nearestObject.type == 0x00c9) then
			objectType = "moving item box";
		elseif (nearestObject.type == 0x0067) then
			objectType = "wooden crate";
		elseif (nearestObject.type == 0x0145) then
			objectType = "autumn tree";
		elseif (nearestObject.type == 0x01f5) then
			objectType = "bully";
		elseif (nearestObject.type == 0x01fb) then
			objectType = "Eyerock";
		elseif (nearestObject.type == 0x0196) then
			objectType = "chain chomp";
		elseif (nearestObject.type == 0x0197) then
			objectType = "chain chomp post";
		elseif (nearestObject.type == 0x0191) then
			objectType = "goomba";
		elseif (nearestObject.type == 0x019d) then
			objectType = "snowman";
		elseif (nearestObject.type == 0x0192) then
			objectType = "giant snowball";
		elseif (nearestObject.type == 0x01ac) then
			objectType = "crab";
		elseif (nearestObject.type == 0x019a) then
			objectType = "car";
		elseif (nearestObject.type == 0x019a) then
			objectType = "car";
		elseif (nearestObject.type == 0x019c) then
			objectType = "truck";
		elseif (nearestObject.type == 0x0195) then
			objectType = "bus";
		elseif (nearestObject.type == 0x0193) then
			objectType = "thwomp";
		elseif (nearestObject.type == 0x01b1) then
			objectType = "boulder";
		elseif (nearestObject.type == 0x01a8) then
			objectType = "bumper";
		elseif (nearestObject.type == 0x01b0) then
			objectType = "pinball";
		elseif (nearestObject.type == 0x01a9) then
			objectType = "flipper";
		elseif (nearestObject.type == 0x01fd) then
			objectType = "King Boo";
		elseif (nearestObject.type == 0x01a5) then
			objectType = "stray chain chomp";
		elseif (nearestObject.type == 0x0138) then
			objectType = "striped tree";
		elseif (nearestObject.type == 0x01f8) then
			objectType = "King Bomb-omb";
		elseif (nearestObject.type == 0x01a7) then
			objectType = "rocky wrench";
		elseif (nearestObject.type == 0x01f6) then
			objectType = "Chief Chilly";
		elseif (nearestObject.type == 0x01a4) then
			objectType = "flamethrower";
		elseif (nearestObject.type == 0x01fe) then
			objectType = "Wiggler";
		elseif (nearestObject.type == 0x01a3) then
			objectType = "walking tree";
		elseif (nearestObject.type == 0x0156) then
			objectType = "N64 winter tree";
		elseif (nearestObject.type == 0x0198) then
			objectType = "leaping fireball";
		elseif (nearestObject.type == 0x01af) then
			objectType = "fireballs";
		elseif (nearestObject.type == 0x0146) then
			objectType = "winter tree";
		elseif (nearestObject.type == 0x00cd) then
			objectType = "clock";
		elseif (nearestObject.type == 0x00cf) then
			objectType = "pendulum";
		elseif (nearestObject.type == 0x01a2) then
			objectType = "bullet bill";
		elseif (nearestObject.type == 0x014f) then
			objectType = "pinecone tree";
		elseif (nearestObject.type == 0x000d) then
			objectType = "puddle";
		elseif (nearestObject.type == 0x01a6) then
			objectType = "pirahna plant";
		elseif (nearestObject.type == 0x019e) then
			objectType = "coffin";
		elseif (nearestObject.type == 0x019f) then
			objectType = "bats";
		elseif (nearestObject.type == 0x0150) then
			objectType = "beanstalk";
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