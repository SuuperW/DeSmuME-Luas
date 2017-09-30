local displayCoinList = false;
local beginListAtCoin = 0;
local displayNearestCoin = true;

local objectArrayPointer = 0x021A7884;
local objectArrayOffset = 0x2C;
local oaCoinCountOffset = 0x14;

local coinDataLength = 0x104;

local objectDataLengthOffset = 0x4;
local objectNextOffset = 0xC;
local coinXOffset = 0x14;
local coinYOffset = 0x18;
local coinZOffset = 0x1C;
local coinCollectedOffset = 0x12;

local playerDataPointer = 0x0217ACF8;
local playerXOffset = 0x1B8;
local playerYOffset = 0x1BC;
local playerZOffset = 0x1C0;

function displayCoins()
	local address = memory.readdword(objectArrayPointer) + objectArrayOffset;
	local coinCount = memory.readdword(address + oaCoinCountOffset);
	if (coinCount > 50) then
		return;
	end
	gui.text(4, 2, "Coins: " .. coinCount);
	
	local nearestCoin = {dist = 999999999, id = -1};
	local renderY = 20;
	for i = 0, coinCount - 1, 1 do
		address = memory.readdword(address + objectNextOffset);
		local loopCount = 0;
		while (memory.readdword(address + objectDataLengthOffset) ~= coinDataLength) do
			address = memory.readdword(address + objectNextOffset);
			loopCount = loopCount + 1;
			if (loopCount > 20) then gui.text(80, 2, "fail " .. i); return; end
		end

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
			coinDistance.dist = coinDistance.dist - 81920; -- 20 units, radius of coin
			coinDistance.dist = math.floor(coinDistance.dist * 10) / 10;
			if (coinDistance.dist < nearestCoin.dist) then
				nearestCoin = coinDistance;
				nearestCoin.id = i;
			end
		end
		
		--displayString = displayString .. ", " ..
		--  string.format("%x", address + 0x12e3fe0);
		if (displayCoinList and beginListAtCoin <= i and renderY < 150) then
			gui.text(4, renderY, displayString);
			renderY = renderY + 12;
		end
	end
	
	if (displayNearestCoin and nearestCoin.id ~= -1) then
		gui.text(4, 158, "-- Nearest coin --");
		if (not string.find(nearestCoin.dist, "%.")) then
			nearestCoin.dist = nearestCoin.dist .. ".0";
		end
		gui.text(4, 170, "ID: " .. nearestCoin.id .. ", " ..
		  "Distance: " .. nearestCoin.dist .. " to collect");
		gui.text(4, 182, "XYZ dist: " .. nearestCoin.x .. ", " .. 
		  nearestCoin.y .. ", " .. nearestCoin.z);
	end
end

gui.register(displayCoins);