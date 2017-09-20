local previousZoom = 0;
local zoomFactor1 = 1.0;
local zoomFactor2 = 0x28000;

local camUp1 = 40000;
local camUp2 = 4000;

function fn()
	local camPointer = memory.readdword(0x0217AA5C);
	
	local zoomPointer = camPointer + 0x34;
	local zoom = memory.readdword(zoomPointer);
	if (zoom ~= previousZoom) then
		zoom = zoom * zoomFactor1;
		if (previousZoom == 0) then
			zoom = 5500 * zoomFactor1;
		end
		zoom = math.floor(zoom);
		previousZoom = zoom;
		memory.writedword(zoomPointer, zoom);
	end
	
	memory.writedword(camPointer + 0x7C, camUp1);
	memory.writedword(camPointer + 0x144, camUp2);
	
	memory.writedword(camPointer + 0x148, zoomFactor2);
end


emu.registerbefore(fn)
