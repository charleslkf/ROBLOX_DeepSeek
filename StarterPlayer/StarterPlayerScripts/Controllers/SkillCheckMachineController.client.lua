--!strict
--[=[
    @client
    This controller manages the UI and client-side logic for the Skill Check minigame.
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

print("SkillCheckMachineController.client.lua loaded.")

-- Get remote events
local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local StartSkillCheckEvent = EventsFolder:WaitForChild("StartSkillCheck")
local ReportSkillCheckResult = EventsFolder:WaitForChild("ReportSkillCheckResult")

-- Get UI module
local SkillCheckGuiModule = require(script.Parent.Parent:WaitForChild("UI"):WaitForChild("MachineUIs"):WaitForChild("SkillCheckMachineGui"))

-- Create the GUI instance
local guiInstance = SkillCheckGuiModule()
guiInstance.Parent = PlayerGui
print("SkillCheckMachineController: GUI instance created.")

local backgroundBar = guiInstance.MainFrame.BackgroundBar
local successZone = backgroundBar.SuccessZone
local cursor = backgroundBar.Cursor

local activeMachineID: string?
local activeMachinePart: Part?
local distanceCheckConnection: RBXScriptConnection?
local currentTween: Tween?
local isStopped = false
local MAX_DISTANCE = 20

-- --- Functions ---

local function hideGui()
	if not guiInstance.Enabled then return end
	guiInstance.Enabled = false
	activeMachineID = nil
	activeMachinePart = nil
	if distanceCheckConnection then
		distanceCheckConnection:Disconnect()
		distanceCheckConnection = nil
	end
	if currentTween then
		currentTween:Cancel()
		currentTween = nil
	end
end

local function monitorDistance()
	local character = Player.Character
	if not character or not activeMachinePart then
		hideGui()
		return
	end

	local distance = (character:GetPrimaryPartCFrame().Position - activeMachinePart.Position).Magnitude
	if distance > MAX_DISTANCE then
		hideGui()
	end
end

local function onInputBegan(input, gameProcessedEvent)
	if gameProcessedEvent then return end

	if input.KeyCode == Enum.KeyCode.Space then
		if guiInstance.Enabled and currentTween then
			isStopped = true
			currentTween:Cancel()
			currentTween = nil

			local cursorPos = cursor.Position.X.Scale
			local zoneStart = successZone.Position.X.Scale - (successZone.Size.X.Scale / 2)
			local zoneEnd = successZone.Position.X.Scale + (successZone.Size.X.Scale / 2)
			local success = (cursorPos >= zoneStart and cursorPos <= zoneEnd)

			print("Skill check result: " .. tostring(success))
			if activeMachineID then
				ReportSkillCheckResult:FireServer(activeMachineID, success)
			end

			task.wait(0.5)
			hideGui()
		end
	end
end

local function startSkillCheck(machineID: string, machinePart: Part)
	if guiInstance.Enabled then return end

	activeMachineID = machineID
	activeMachinePart = machinePart
	isStopped = false
	guiInstance.Enabled = true
	cursor.Position = UDim2.fromScale(0, 0.5)

	if distanceCheckConnection then distanceCheckConnection:Disconnect() end
	distanceCheckConnection = RunService.Heartbeat:Connect(monitorDistance)

	local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Linear)
	currentTween = TweenService:Create(cursor, tweenInfo, {Position = UDim2.fromScale(1, 0.5)})

	currentTween.Completed:Connect(function()
		if not isStopped then
			print("Skill check failed (timed out)")
			if activeMachineID then
				ReportSkillCheckResult:FireServer(activeMachineID, false)
			end
			hideGui()
		end
	end)

	currentTween:Play()
end


-- --- Event Connections ---

StartSkillCheckEvent.OnClientEvent:Connect(function(machineID: string, machinePart: Part)
	startSkillCheck(machineID, machinePart)
end)

UserInputService.InputBegan:Connect(onInputBegan)

print("SkillCheckMachineController: Event listeners connected.")
