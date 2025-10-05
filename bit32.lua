--[[
An recreation of the bit32 library from version 5.2
This library does not rely on the bitwise operators introduced in version 5.3, meaning this library should in theory also work in 5.1.
Last edit 10-5-25
]]

local bit32 = {}

local MAX_INT = 0xffffffff -- all ones, equal to 2^32 - 1
local MSB_MASK = 0x80000000 -- all zeros except the first bit

--[[
Convert a number into an unsigned 32 bit integer.
]]
function bit32.force(x)
	return math.floor(x % (MAX_INT + 1))
end

--[[
Extract every bit into an array, starting from the most significant bit.
Using table.concat(), a number's bits can be displayed as a string.
]]
function bit32.bits(x)
	local s = {}
	for i = 0, 31 do
		s[32 - i] = bit32.extract(x, i, 1)
	end
	return s
end

--[[
Shorthand way of geting the binary string of a number.
]]
function bit32.tostring(x)
	return table.concat(bit32.bits(x))
end

--[[
Get the one's complement negation of [x].
]]
function bit32.bnot(x)
	return bit32.force(MAX_INT - x)
end

--[[
Get the bitwise AND of any number of arguments.
If only one argument is passed, returns that argument (as an unsigned 32bit int).
If no arguments are passed, returns the max unsigned int (4294967295).
Not in any way efficient, but accomplishes this without using bitwise operators, making it work in Lua versions that don't have them.
]]
function bit32.band(...)
	local result = bit32.bits(MAX_INT)
	for _, n in ipairs(table.pack(...)) do
		for i, digit in ipairs(bit32.bits(n)) do
			result[i] = ((result[i] == 1) and (digit == 1)) and 1 or 0
		end
	end
	local output = 0
	for i = 0, 31 do
		output = output + result[32 - i] * (2 ^ i)
	end
	return output
end

--[[
Returns true if the passed arguments have any bits in common.
]]
function bit32.btest(...)
	return bit32.band(...) ~= 0
end

--[[
Get the bitwise OR of any number of arguments.
If only one argument is passed, returns that argument (as an unsigned 32bit int).
If no arguments are passed, returns zero.
]]
function bit32.bor(...)
	local result = bit32.bits(0)
	for _, n in ipairs(table.pack(...)) do
		for i, digit in ipairs(bit32.bits(n)) do
			result[i] = ((result[i] == 1) or (digit == 1)) and 1 or 0
		end
	end
	local output = 0
	for i = 0, 31 do
		output = output + result[32 - i] * (2 ^ i)
	end
	return output
end

--[[
Get the exclusive OR of its arguments.
]]
function bit32.bxor(...)
	return bit32.band(bit32.bor(...), bit32.bnot(bit32.band(...)))
end

--[[
Left shift [x] by [disp] bits.
]]
function bit32.lshift(x, disp)
	return bit32.force(x * 2 ^ disp)
end

--[[
Logical right shift [x] by [disp] bits.
]]
function bit32.rshift(x, disp)
	return bit32.lshift(x, -disp)
end

--[[
Arithmetic right shift [x] by [disp] bits.
Can be used to simulate operations on signed 32 bit integers.
The most significant bit is duplicated at the end, rather than being filled with zeros.
Arithmetic left shift is identical to logical left shift so it is not implemented here.
]]
function bit32.arshift(x, disp)
	if (disp > 0) then
		local mask = (x >= MSB_MASK) and bit32.lshift(2 ^ disp - 1, 32 - disp) or 0
		return bit32.bor(bit32.rshift(x, disp), mask)
	else
		return bit32.lshift(x, -disp)
	end
end

--[[
Extract [width] bits from [x], starting at [field] bits from the least significant bit.
]]
function bit32.extract(x, field, width)
	local left = bit32.lshift(x, 32 - field - width)
	return bit32.rshift(left, 32 - width)
end

--[[
Replace the bits in [n] at the position specified by [width] and [field], with the first [width] bits of [v].
]]
function bit32.replace(n, v, field, width)
	local rmask = bit32.lshift(bit32.extract(v, 0, width), field)
	local zmask = bit32.bnot(bit32.lshift(2 ^ width - 1, field))
	return bit32.bor(bit32.band(n, zmask), rmask)
end

--[[
Rotating left shift of [x] by [disp] bits.
For each shift the most significant bit is moved to the least significant bit, rather than being thrown out.
]]
function bit32.lrotate(x, disp)
	if (disp > 0) then
		local lead = bit32.extract(x, 32 - disp, disp)
		return bit32.replace(bit32.lshift(x, disp), lead, 0, disp)
	else
		local trail = bit32.extract(x, 0, -disp)
		return bit32.replace(bit32.rshift(x, -disp), trail, 32 + disp, -disp)
	end
end

--[[
Rotating right shift of [x] by [disp] bits.
For each shift the least significant bit is moved to the most significant bit, rather than being thrown out.
]]
function bit32.rrotate(x, disp)
	return bit32.lrotate(x, -disp)
end

return bit32
