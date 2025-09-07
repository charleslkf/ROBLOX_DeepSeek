--[[
    KillerInput.client.lua

    This script handles the Killer's attack input.
    It starts as DISABLED and is enabled by the server's GameManager
    only for the player who is chosen as the Killer.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get local player and character
local localPlayer = Players.LocalPlayer
local character = script.Parent
local head = character:WaitForChild("Head")

-- Get RemoteEvent
local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local killerAttackEvent = EventsFolder:WaitForChild("KillerAttackEvent")

-- State
local attackCooldown = 1 -- seconds
local canAttack = true
local isKiller = false

-- Sound

-- Role-based activation
local roleValue = character:WaitForChild("Role")

local function updateRole()
    isKiller = (roleValue.Value == "Killer")
    print("KillerInput.client.lua: Role is now " .. roleValue.Value .. ". IsKiller set to: " .. tostring(isKiller))
end

updateRole() -- Initial check
roleValue.Changed:Connect(updateRole)


print("KillerInput.client.lua: Script loaded and running. Waiting for role assignment.")

-- Listen for input
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if not isKiller or gameProcessedEvent then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 and canAttack then
        canAttack = false


        -- Fire event to server
        killerAttackEvent:FireServer()

        -- Cooldown
        task.wait(attackCooldown)
        canAttack = true
    end
end)
