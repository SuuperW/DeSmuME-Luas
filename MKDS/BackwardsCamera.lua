local pointer = memory.readdword(0x0217AA5C);
pointer = pointer + 0xC0;
local value = memory.readdwordsigned(pointer);
memory.writedword(pointer, value * -1);
