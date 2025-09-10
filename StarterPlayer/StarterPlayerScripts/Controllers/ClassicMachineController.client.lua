--!strict
--[=[
    @client
    This controller manages the UI and client-side logic for the Classic Machine minigame.
]=]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")

print("ClassicMachineController.client.lua loaded.")

-- Get remote events folder
local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local ShowMachineUIEvent = EventsFolder:WaitForChild("ShowMachineUI")
local SubmitClassicMachineSolution = EventsFolder:WaitForChild("SubmitClassicMachineSolution")

-- Get UI module
local ClassicMachineGuiModule = require(script.Parent.Parent:WaitForChild("UI"):WaitForChild("MachineUIs"):WaitForChild("ClassicMachineGui"))

-- Create the GUI instance
local guiInstance = ClassicMachineGuiModule()
guiInstance.Parent = PlayerGui
print("ClassicMachineController: GUI instance created.")

local gridContainer = guiInstance.MainFrame.GridContainer
local submitButton = guiInstance.MainFrame.SubmitButton

local activeMachineID: string?
local activeMachinePart: Part?
local distanceCheckConnection: RBXScriptConnection?
local MAX_DISTANCE = 20 -- Max distance in studs before UI closes

-- --- Functions to control the GUI ---

local function hideGui()
    if not guiInstance.Enabled then return end
	guiInstance.Enabled = false
	activeMachineID = nil
	activeMachinePart = nil
	if distanceCheckConnection then
		distanceCheckConnection:Disconnect()
		distanceCheckConnection = nil
	end
	print("ClassicMachineController: GUI hidden.")
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

local function showGui(machineID: string, machinePart: Part)
	activeMachineID = machineID
	activeMachinePart = machinePart

    -- Randomize tile rotations when showing the GUI
    for _, tile in ipairs(gridContainer:GetChildren()) do
        if tile:IsA("TextButton") then
            local randomRotations = {0, 90, 180, 270}
            tile.Rotation = randomRotations[math.random(1, #randomRotations)]
        end
    end
    guiInstance.Enabled = true

	-- Start monitoring distance
	if distanceCheckConnection then distanceCheckConnection:Disconnect() end
	distanceCheckConnection = RunService.Heartbeat:Connect(monitorDistance)

    print("ClassicMachineController: GUI shown for machine: " .. machineID)
end

-- --- Event Connections ---

ShowMachineUIEvent.OnClientEvent:Connect(function(machineType: string, machineID: string, machinePart: Part)
    if machineType == "ClassicMachine" then
        showGui(machineID, machinePart)
    end
end)

-- Connect click-to-rotate for each interactive tile
for _, tile in ipairs(gridContainer:GetChildren()) do
    if tile:IsA("TextButton") then
        tile.MouseButton1Click:Connect(function()
            tile.Rotation += 90
        end)
    end
end

-- Connect the submit button to send the solution to the server
submitButton.MouseButton1Click:Connect(function()
    print("Submit button clicked! Sending solution to server.")

    local solution = {}
    local children = gridContainer:GetChildren()

    for y = 1, 5 do solution[y] = {} end

    for _, tile in ipairs(children) do
        local pipeType = tile:GetAttribute("PipeType")
        local gridX = tile:GetAttribute("GridX")
        local gridY = tile:GetAttribute("GridY")

        if pipeType and gridX and gridY then
            solution[gridY][gridX] = {
                Type = pipeType,
                Rotation = tile.Rotation,
            }
        end
    end

    if activeMachineID then
        SubmitClassicMachineSolution:FireServer(activeMachineID, solution)
    else
        warn("No active machine ID found when submitting solution!")
    end

    hideGui()
end)

print("ClassicMachineController: Event listeners connected.")
