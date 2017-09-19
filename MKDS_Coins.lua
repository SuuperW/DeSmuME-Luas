local displayAllCoins = true;
local displayNearestCoin = true;

local coinArrayPointer = 0x021A7884;
local coinArrayOffset = 0x2C;
local coinArrayLengthOffset = 0x14;
local firstCoinOffset = 0x38;

local coinStructureLength = 0x114;
local coinXOffset = 0x14;
local coinYOffset = 0x18;
local coinZOffset = 0x1C;
local coinCollectedOffset = 0x12;

local playerDataPointer = 0x0217ACF8;
local playerXOffset = 0x80;
local playerYOffset = 0x84;
local playerZOffset = 0x88;

function displayCoins()
	local address = memory.readdword(coinArrayPointer) + coinArrayOffset;
	local coinCount = memory.readdword(address + coinArrayLengthOffset);
	if (coinCount > 50) then
		return;
	end
	
	address = address + firstCoinOffset;
	gui.text(4, 2, "Coins: " .. coinCount);
	
	local nearestCoin = {dist = 999999999, id = -1};
	for i = 0, coinCount - 1, 1 do
		local coinX = memory.readdwordsigned(address + coinXOffset);
		local coinY = memory.readdwordsigned(address + coinYOffset);
		local coinZ = memory.readdwordsigned(address + coinZOffset);
		
		local collected = memory.readbyte(address + coinCollectedOffset);
		collected = math.floor(collected / 2) ~= collected / 2; -- 0x01 bit
		
		local displayString;
		if (collected) then 
			displayString = "Coin " .. i .. ": collected";
		else
			displayString = "Coin " .. i .. ": " ..
			  coinX .. ", " .. coinY .. ", " .. coinZ;
			  
			local playerAddress = memory.readdword(playerDataPointer);
			local playerX = memory.readdwordsigned(playerAddress + playerXOffset);
			local playerY = memory.readdwordsigned(playerAddress + playerYOffset);
			local playerZ = memory.readdwordsigned(playerAddress + playerZOffset);
			
			local coinDistance = {};
			coinDistance.x = playerX - coinX;
			coinDistance.y = playerY - coinY;
			coinDistance.z = playerZ - coinZ;
			coinDistance.dist = math.sqrt(coinDistance.x ^ 2 +
			  coinDistance.y ^ 2 + coinDistance.z ^ 2);
			coinDistance.dist = math.floor(coinDistance.dist * 10) / 10;
			if (coinDistance.dist < nearestCoin.dist) then
				nearestCoin = coinDistance;
				nearestCoin.id = i;
			end
		end
		
		if (displayAllCoins) then
			gui.text(4, 20 + i * 12, displayString);
		end
		
		address = address + coinStructureLength;
	end
	
	if (displayNearestCoin and nearestCoin.id ~= -1) then
		gui.text(4, 158, "-- Nearest coin --");
		gui.text(4, 170, "ID: " .. nearestCoin.id .. ", Distance: " .. nearestCoin.dist);
		gui.text(4, 182, "XYZ dist: " .. nearestCoin.x .. ", " .. 
		  nearestCoin.y .. " " .. nearestCoin.z);
	end
end

gui.register(displayCoins);