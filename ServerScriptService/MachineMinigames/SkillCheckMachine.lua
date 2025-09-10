--!strict
--[=[
	@class SkillCheckMachine
	Implements the skill check minigame.
	The player must press a key at the right time.
]=]
local SkillCheckMachine = {}
SkillCheckMachine.__index = SkillCheckMachine

--[=[
	Creates a new SkillCheckMachine instance.
]=]
function SkillCheckMachine.new(puzzleData: {ChecksRequired: number})
	local self = setmetatable({}, SkillCheckMachine)

	self.ChecksRequired = puzzleData.ChecksRequired or 3 -- Default to 3 successful checks
	self.Successes = 0
	self.IsCompleted = false

	return self
end

--[=[
	Processes the result of a single skill check from the client.
	@param success boolean Whether the player succeeded the skill check.
	@return boolean Whether the entire machine is now complete.
]=]
function SkillCheckMachine:ProcessCheck(success: boolean)
	if self.IsCompleted then return false end

	if success then
		self.Successes += 1
		print("Skill check success! Progress: " .. self.Successes .. "/" .. self.ChecksRequired)
	else
		-- Reset progress on failure to make it more challenging
		self.Successes = 0
		print("Skill check failed! Progress reset.")
	end

	if self.Successes >= self.ChecksRequired then
		print("Skill Check Machine completed!")
		self.IsCompleted = true
		return true
	end

	return false
end


--[=[
	Resets the machine to its initial state.
]=]
function SkillCheckMachine:Reset()
	self.Successes = 0
	self.IsCompleted = false
	print("Skill Check Machine has been reset.")
end

return SkillCheckMachine
