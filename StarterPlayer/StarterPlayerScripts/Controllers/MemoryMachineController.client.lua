--!strict
--[=[
    @client
    This controller manages the UI and client-side logic for the Memory Machine minigame.
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

print("MemoryMachineController.client.lua loaded.")

-- Get remote events
local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local ShowMachineUIEvent = EventsFolder:WaitForChild("ShowMachineUI")
local SubmitMemoryMachineSolution = EventsFolder:WaitForChild("SubmitMemoryMachineSolution")
local ShowMemoryMachinePattern = EventsFolder:WaitForChild("ShowMemoryMachinePattern")

-- Get UI module
local MemoryMachineGuiModule = require(script.Parent.Parent:WaitForChild("UI"):WaitForChild("MachineUIs"):WaitForChild("MemoryMachineGui"))

-- Create the GUI instance
local guiInstance = MemoryMachineGuiModule()
guiInstance.Parent = PlayerGui
print("MemoryMachineController: GUI instance created.")

local mainFrame = guiInstance.MainFrame
local gridContainer = mainFrame.GridContainer
local statusLabel = mainFrame.StatusLabel

local activeMachineID: string?
local activeMachinePart: Part?
local distanceCheckConnection: RBXScriptConnection?
local playerSequence = {}
local isPlayerTurn = false
local requiredPatternLength = 0
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
	print("MemoryMachineController: GUI hidden.")
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

local function flashButton(button: TextButton)
	local originalColor = button.BackgroundColor3
	button.BackgroundColor3 = Color3.new(1, 1, 1)
	task.wait(0.4)
	button.BackgroundColor3 = originalColor
	task.wait(0.2)
end

local function playPattern(pattern: {{X: number, Y: number}})
	isPlayerTurn = false
	statusLabel.Text = "Watch the pattern..."
	task.wait(1)

	for i, step in ipairs(pattern) do
		print("Playing pattern step " .. i) -- DEBUG
		if not guiInstance.Enabled then return end -- Stop if player walked away
		local buttonName = `Tile_{step.Y}_{step.X}`
		local button = gridContainer:FindFirstChild(buttonName)
		if button and button:IsA("TextButton") then
			flashButton(button)
		end
	end

	statusLabel.Text = `Your turn... (0/${requiredPatternLength})`
	isPlayerTurn = true
end

local function showGui(machineID: string, machinePart: Part)
	playerSequence = {}
	isPlayerTurn = false
	requiredPatternLength = 0
	statusLabel.Text = "Watch the pattern..."
	guiInstance.Enabled = true
	activeMachineID = machineID
	activeMachinePart = machinePart

	if distanceCheckConnection then distanceCheckConnection:Disconnect() end
	distanceCheckConnection = RunService.Heartbeat:Connect(monitorDistance)

	print("MemoryMachineController: GUI shown for machine: " .. machineID)
end

-- --- Event Connections ---

ShowMachineUIEvent.OnClientEvent:Connect(function(machineType: string, machineID: string, machinePart: Part)
	if machineType == "MemoryMachine" then
		showGui(machineID, machinePart)
	end
end)

ShowMemoryMachinePattern.OnClientEvent:Connect(function(machineID: string, pattern: table, patternLength: number)
	if guiInstance.Enabled and activeMachineID == machineID then
		print("Client received pattern of length: " .. #pattern) -- DEBUG
		requiredPatternLength = patternLength
		playPattern(pattern)
	end
end)

for _, tileButton in ipairs(gridContainer:GetChildren()) do
	if tileButton:IsA("TextButton") then
		tileButton.MouseButton1Click:Connect(function()
			if not isPlayerTurn then return end
			if #playerSequence >= requiredPatternLength then return end

			local gridX = tileButton:GetAttribute("GridX")
			local gridY = tileButton:GetAttribute("GridY")
			table.insert(playerSequence, {X = gridX, Y = gridY})
			statusLabel.Text = `Input recorded (${#playerSequence}/${requiredPatternLength})`

			flashButton(tileButton)

			if #playerSequence == requiredPatternLength then
				isPlayerTurn = false
				task.wait(0.5)

				print("Submitting final sequence...")
				if activeMachineID then
					SubmitMemoryMachineSolution:FireServer(activeMachineID, playerSequence)
				end
				hideGui()
			end
		end)
	end
end

print("MemoryMachineController: Event listeners connected.")
