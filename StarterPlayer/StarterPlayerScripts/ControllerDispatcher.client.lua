--[[
    ControllerDispatcher.client.lua

    This client-side script's only job is to listen for a signal from the
    server (via ActivateClientControllerEvent) and enable the correct
    controller script inside the player's character.

    This architecture solves the server-to-client replication issue with
    a script's 'Disabled' property.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer
local playerScripts = localPlayer:WaitForChild("PlayerScripts")

local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local activateEvent = EventsFolder:WaitForChild("ActivateClientControllerEvent")

activateEvent.OnClientEvent:Connect(function(scriptName)
    if not scriptName then return end

    -- The server has told us to activate a specific controller.
    -- Find it in our character and enable it.
    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local controllerScript = character:FindFirstChild(scriptName, true)

    if controllerScript then
        print("ControllerDispatcher: Received signal to activate " .. scriptName)
        controllerScript.Disabled = false
        print("ControllerDispatcher: Set " .. scriptName .. ".Disabled to " .. tostring(controllerScript.Disabled))
    else
        warn("ControllerDispatcher: Server tried to activate script '" .. scriptName .. "' but it was not found.")
    end
end)

print("ControllerDispatcher.client.lua initialized and listening.")
