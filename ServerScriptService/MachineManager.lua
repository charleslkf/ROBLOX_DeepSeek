--!strict
--[=[
	@class MachineManager
	Acts as a controller to load, create, and manage all machine minigame instances.
]=]
local MachineManager = {}
MachineManager.__index = MachineManager

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local MinigamesFolder = ServerScriptService:WaitForChild("MachineMinigames")

-- Get specific events this manager needs
local SubmitClassicMachineSolution = EventsFolder:WaitForChild("SubmitClassicMachineSolution")
local SubmitMemoryMachineSolution = EventsFolder:WaitForChild("SubmitMemoryMachineSolution")
local ReportSkillCheckResult = EventsFolder:WaitForChild("ReportSkillCheckResult")
local StartSkillCheck = EventsFolder:WaitForChild("StartSkillCheck")
local ShowMachineUI = EventsFolder:WaitForChild("ShowMachineUI")
local ShowMemoryMachinePattern = EventsFolder:WaitForChild("ShowMemoryMachinePattern")
local MachineFeedback = EventsFolder:WaitForChild("MachineFeedback")

-- A dictionary to hold the loaded minigame modules
local MinigameModules = {}

-- A dictionary to store active machines by a unique ID
local activeMachines: {[string]: table} = {}
local machineIdCounter = 0

-- A BindableEvent that fires when any machine is completed
MachineManager.MachineCompleted = Instance.new("BindableEvent")

-- Load all minigame modules immediately when this script is required
for _, moduleScript in ipairs(MinigamesFolder:GetChildren()) do
	if moduleScript:IsA("ModuleScript") then
		local moduleName = moduleScript.Name
		local success, module = pcall(require, moduleScript)
		if success and module then
			MinigameModules[moduleName] = module
			print("Loaded minigame module: " .. moduleName)
		else
			warn("Failed to load minigame module: " .. moduleName, module)
		end
	end
end

--[=[
	Sets up event listeners. This should be called once from a main server script.
]=]
function MachineManager:Init()
	-- Listener for the Classic Machine
	SubmitClassicMachineSolution.OnServerEvent:Connect(function(player, machineID: string, solution: table)
		local machineInstance = activeMachines[machineID]
		if not machineInstance or machineInstance.IsCompleted then return end

		local success = machineInstance:ValidateSolution(solution)
		MachineFeedback:FireClient(player, machineID, success)
		if success then
			machineInstance.IsCompleted = true
			MachineManager.MachineCompleted:Fire(machineInstance)
		end
	end)

	-- Listener for the Memory Machine
	SubmitMemoryMachineSolution.OnServerEvent:Connect(function(player, machineID: string, solution: table)
		local machineInstance = activeMachines[machineID]
		if not machineInstance or machineInstance.IsCompleted then return end

		if machineInstance:ValidateSolution(solution) then
			machineInstance.IsCompleted = true
			MachineManager.MachineCompleted:Fire(machineInstance)
		end
	end)

	-- Listener for the Skill Check Machine
	ReportSkillCheckResult.OnServerEvent:Connect(function(player, machineID: string, success: boolean)
		local machineInstance = activeMachines[machineID]
		if not machineInstance or machineInstance.IsCompleted then return end

		local isNowComplete = machineInstance:ProcessCheck(success)
		if isNowComplete then
			MachineManager.MachineCompleted:Fire(machineInstance)
		else
			-- If not complete, trigger another skill check for the player
			task.wait(0.5) -- Small delay before the next check
			if not machineInstance.IsCompleted then
				StartSkillCheck:FireClient(player, machineID, machineInstance.Part)
			end
		end
	end)
end

--[=[
	Creates a new instance of a specific machine minigame.
]=]
function MachineManager:CreateMachine(machineType: string, puzzleData: table)
	local module = MinigameModules[machineType]
	if not module then
		warn("Attempted to create an invalid or not-loaded machine type: " .. machineType)
		return nil
	end

	local newMachine = module.new(puzzleData)

	machineIdCounter += 1
	local machineID = "Machine" .. tostring(machineIdCounter)
	newMachine.ID = machineID

	activeMachines[machineID] = newMachine

	self:_CreateMachinePart(newMachine, machineType)

	return newMachine
end

--[=[
	Creates and configures the physical part for a machine.
]=]
function MachineManager:_CreateMachinePart(machineInstance: table, machineType: string)
	print("Creating physical machine part of type: " .. machineType)
	local part = Instance.new("Part")
	part.Size = Vector3.new(5, 5, 5)
	part.Anchored = true
	part.Position = Vector3.new(math.random(-50, 50), 2.5, math.random(-50, 50))
	part.BrickColor = BrickColor.random()
	part.Name = machineType .. " (" .. machineInstance.ID .. ")"
	part.Parent = workspace

	machineInstance.Part = part

	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Repair Machine"
	prompt.ObjectText = machineType
	prompt.HoldDuration = 0
	prompt.Parent = part

	prompt.Triggered:Connect(function(player)
		print(player.Name .. " interacted with a " .. machineType .. " (" .. machineInstance.ID .. ")")

		if machineType == "ClassicMachine" or machineType == "MemoryMachine" then
			ShowMachineUI:FireClient(player, machineType, machineInstance.ID, machineInstance.Part)
			if machineType == "MemoryMachine" then
				local pattern = machineInstance:GeneratePattern()
				task.wait(0.1)
				ShowMemoryMachinePattern:FireClient(player, machineInstance.ID, pattern, machineInstance.PatternLength)
			end
		elseif machineType == "SkillCheckMachine" then
			StartSkillCheck:FireClient(player, machineInstance.ID, machineInstance.Part)
		else
			print("Default interaction: auto-completing machine.")
			machineInstance.IsCompleted = true
			MachineManager.MachineCompleted:Fire(machineInstance)
		end
	end)
end

--[=[
	Gets all the active machine instances.
]=]
function MachineManager:GetActiveMachines()
	return activeMachines
end

--[=[
	Resets all active machines to their initial state.
]=]
function MachineManager:ResetAllMachines()
	for id, machineInstance in pairs(activeMachines) do
		if machineInstance.Reset then
			machineInstance:Reset()
		end
		if machineInstance.Part then
			machineInstance.Part:Destroy()
			machineInstance.Part = nil
		end
	end
	activeMachines = {}
	print("All active machines have been reset and their parts destroyed.")
end

return MachineManager
