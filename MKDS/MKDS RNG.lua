-- Set how many changes the script will check up to.
local maxChanges = 16;

local mVal = 1812433253;
local aVal = 2531011;
--local m2Val = 1566083941;

local prevR1 = 0;

function RNGStep(iRNG)
	--return (mVal * iRNG + aVal) % 4294967296;
	
	local High1 = math.floor(iRNG / 65536); --iRNG's first 2 bytes
	local Low1 = math.floor(iRNG % 65536); --iRNG's last 2 bytes
	local High2 = math.floor(mVal / 65536); --xR's first 2 bytes
	local Low2 = math.floor(mVal % 65536); --xR's last 2 bytes
	 
	local NewHigh = (High1 * Low2 + High2 * Low1) % 65536; --Add high-low multiples (high-high restult is irrelevant; it's completely ignored by mod 0xFFFFFFF)
	local NewLow = Low1 * Low2 --last 2 bytes of iRNG times xR
	 
	 --Mod of NewHigh, with the multiplicaiton here, essentially floors the value to just
	 --the two high-end bytes
	return (NewHigh * 65536 + NewLow + aVal) % 4294967296;
end

function fn()
	local pointer = memory.readdword(0x21755FC);
	local rng1 = memory.readdword(pointer + 0x47C);
	--local rng2 = memory.readdword(pointer + 0x480);

	local changes = 0;
	if (rng1 ~= prevR1) then
	
		local newR1 = prevR1;
		for i = 0, maxChanges, 1 do
			newR1 = RNGStep(newR1);
			changes = changes + 1;
			if (newR1 == rng1) then
				break;
			end
		end
		
	end	
	
	print(rng1 .. " (" .. changes .. ")");
	
	prevR1 = rng1;
end

emu.registerafter(fn);