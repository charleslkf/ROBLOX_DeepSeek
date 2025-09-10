--!strict
--[=[
	@class MemoryMachine
	Implements the memory puzzle minigame.
	The player must recall and replicate a pattern.
]=]
local MemoryMachine = {}
MemoryMachine.__index = MemoryMachine

--[=[
	Creates a new MemoryMachine instance.
]=]
function MemoryMachine.new(puzzleData: {PatternSize: number, PatternLength: number})
	local self = setmetatable({}, MemoryMachine)

	self.PatternSize = puzzleData.PatternSize or 3 -- 3x3 grid
	self.PatternLength = puzzleData.PatternLength or 5 -- 5 steps in the pattern
	self.IsCompleted = false
	self.CorrectPattern = {}

	return self
end

--[=[
	Generates a new random pattern for this machine instance.
	@returns table The generated pattern.
]=]
function MemoryMachine:GeneratePattern()
	self.CorrectPattern = {} -- Clear previous pattern
	for i = 1, self.PatternLength do
		local randomX = math.random(1, self.PatternSize)
		local randomY = math.random(1, self.PatternSize)
		table.insert(self.CorrectPattern, {X = randomX, Y = randomY})
	end
	print("Generated new memory pattern for machine:", self.CorrectPattern)
	return self.CorrectPattern
end

--[=[
	Validates a solution provided by a player against the stored pattern.
]=]
function MemoryMachine:ValidateSolution(solution: {{X: number, Y: number}}): boolean
	if #solution ~= #self.CorrectPattern then
		return false -- Incorrect length
	end

	for i, step in ipairs(solution) do
		local correctStep = self.CorrectPattern[i]
		if step.X ~= correctStep.X or step.Y ~= correctStep.Y then
			return false -- Mismatch found
		end
	end

	-- If we get through the whole loop, the solution is correct
	print("Memory Machine solution validated as correct.")
	self.IsCompleted = true
	return true
end

--[=[
	Resets the machine to its initial state.
]=]
function MemoryMachine:Reset()
	self.IsCompleted = false
	self.CorrectPattern = {}
	print("Memory Machine has been reset.")
end

return MemoryMachine
