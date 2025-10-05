print("lua version: " .. _VERSION)

local bit32 = require("bit32")

local tests = {

	function()
		-- Check that numbers are properly converted to unsigned 32bit ints.
		local values = {
			{0, 0},
			{1, 1},
			{1.5, 1},
			{0xFFFFFFFF, 0xFFFFFFFF},
			{-1, 0xFFFFFFFF},
			{-2, 0xFFFFFFFF - 1},
			{-1.5, 0xFFFFFFFF - 1}
		}
		local x, result, actual
		for _, test in ipairs(values) do
			x = test[1]
			result = bit32.force(x)
			actual = test[2]
			assert(result == actual, "Expected " .. actual .. ", got " .. result)
		end
	end,

	function()
		-- check that the bits/tostring function outputs strings correctly.
		local values = {
			"0000", "0001", "0010", "0011",
			"0100", "0101", "0110", "0111",
			"1000", "1001", "1010", "1011",
			"1100", "1101", "1110", "1111"
		}
		local result, actual
		for i, s in ipairs(values) do
			result = bit32.tostring(i - 1)
			actual = string.rep("0", 28) .. s
			assert(result == actual, "Expected " .. actual .. ", got " .. result)
		end
	end,

	function()
		-- bnot
		local values = {
			{0, 0xFFFFFFFF},
			{0xFFFFFFFF, 0},
			{0xF0F0F0F0, 0x0F0F0F0F},
			{0xAAAAAAAA, 0x55555555}
		}
		local result
		for _, test in ipairs(values) do
			result = bit32.bnot(test[1])
			assert(result == test[2],
				string.format("Failed not %d. Expected %d, got %d.", test[1], test[2], result))
		end
	end,

	function()
		-- band
		local values = {
			{0, 0, 0},
			{0, 1, 0},
			{1, 0, 0},
			{1, 1, 1},
			{3, 5, 1}
		}
		local result
		for _, test in ipairs(values) do
			result = bit32.band(test[1], test[2])
			assert(result == test[3],
				string.format("Failed and %d and %d. Expected %d, got %d.", test[1], test[2], test[3], result))
		end
		assert(bit32.btest(3, 5), "Failed btest 0011 and 0101.")
		assert(not bit32.btest(2, 5), "Failed btest 0010 and 0101.")
	end,

	function()
		-- bor
		local values = {
			{0, 0, 0},
			{0, 1, 1},
			{1, 0, 1},
			{1, 1, 1},
			{3, 5, 7}
		}
		local result
		for _, test in ipairs(values) do
			result = bit32.bor(test[1], test[2])
			assert(result == test[3],
				string.format("Failed or %d and %d. Expected %d, got %d.", test[1], test[2], test[3], result))
		end
	end,

	function()
		-- bxor
		local values = {
			{0, 0, 0},
			{0, 1, 1},
			{1, 0, 1},
			{1, 1, 0},
			{3, 5, 6}
		}
		local result
		for _, test in ipairs(values) do
			result = bit32.bxor(test[1], test[2])
			assert(result == test[3],
				string.format("Failed xor %d and %d. Expected %d, got %d.", test[1], test[2], test[3], result))
		end
	end,

	function()
		-- left shift
		local values = {
			{10, 1, 20},
			{10, 2, 40},
			{10, -1, 5},
			{10, -2, 2},
			{10, 0, 10}
		}
		local result
		for _, test in ipairs(values) do
			result = bit32.lshift(test[1], test[2])
			assert(result == test[3],
				string.format("Failed left shift %d by %d. Expected %d, got %d.", test[1], test[2], test[3], result))
		end
	end,

	function()
		-- right shift
		local values = {
			{10, 1, 5},
			{10, 2, 2},
			{10, -1, 20},
			{10, -2, 40},
			{10, 0, 10}
		}
		local result
		for _, test in ipairs(values) do
			result = bit32.rshift(test[1], test[2])
			assert(result == test[3],
				string.format("Failed right shift %d by %d. Expected %d, got %d.", test[1], test[2], test[3], result))
		end
	end,

	function()
		-- arithmetic right shift
		local values = {
			{10, 1, 5},
			{10, 2, 2},
			{10, -1, 20},
			{10, -2, 40},
			{10, 0, 10},
			{0x8000000A, 1, 0xC0000005},
			{0x8000000A, 2, 0xE0000002},
			{0x8000000A, -1, 20},
			{0x8000000A, -2, 40}
		}
		local result
		for _, test in ipairs(values) do
			result = bit32.arshift(test[1], test[2])
			assert(result == test[3],
				string.format("Failed ar. right shift %d by %d. Expected %d, got %d.", test[1], test[2], test[3], result))
		end
	end,

	function()
		-- extract
		local values = {
			{0x00009D00, 8, 8, 157},
			{0x00009D00, 10, 4, 7}
		}
		local result
		for _, test in ipairs(values) do
			result = bit32.extract(test[1], test[2], test[3])
			assert(result == test[4],
				string.format("Failed extract from %d %d bits at %d. Expected %d, got %d.", test[1], test[3], test[2], test[4], result))
		end
	end,

	function()
		-- replace
		local values = {
			{0xFFFFFFFF, 0, 16, 4, 0xFFF0FFFF},
			{0xABCDEF01, 0, 0, 32, 0}
		}
		local result
		for _, test in ipairs(values) do
			result = bit32.replace(test[1], test[2], test[3], test[4])
			assert(result == test[5],
				string.format("Failed replace %d with %d %d bits at %d. Expected %d, got %d.", test[1], test[2], test[4], test[3], test[5], result))
		end
	end,

	function()
		-- left rotate
		local values = {
			{0xAA000000, 4, 0xA000000A},
			{0xAA000000, -4, 0x0AA00000},
			{0x000000AA, 4, 0x00000AA0},
			{0x000000AA, -4, 0xA000000A},
			{0x89ABCDEF, 32, 0x89ABCDEF},
			{0x89ABCDEF, -32, 0x89ABCDEF}
		}
		local result
		for _, test in ipairs(values) do
			result = bit32.lrotate(test[1], test[2])
			assert(result == test[3],
				string.format("Failed left rotate %d by %d. Expected %d, got %d.", test[1], test[2], test[3], result))
		end
	end,

	function()
		-- right rotate
		local values = {
			{0x000000AA, 4, 0xA000000A},
			{0x000000AA, -4, 0x00000AA0},
			{0xAA000000, 4, 0x0AA00000},
			{0xAA000000, -4, 0xA000000A},
			{0x89ABCDEF, 32, 0x89ABCDEF},
			{0x89ABCDEF, -32, 0x89ABCDEF}
		}
		local result
		for _, test in ipairs(values) do
			result = bit32.rrotate(test[1], test[2])
			assert(result == test[3],
				string.format("Failed right rotate %d by %d. Expected %d, got %d.", test[1], test[2], test[3], result))
		end
	end
}

local failed = 0
for i, test in ipairs(tests) do
	local success, err = pcall(test)
	if (not success) then
		failed = failed + 1
		print(string.format("Test %d: %s", i, err))
	end
end

if (failed == 0) then
	print(string.format("All %d tests completed successfully.", #tests))
else
	print(string.format("%d out of %d tests failed.", failed, #tests))
end