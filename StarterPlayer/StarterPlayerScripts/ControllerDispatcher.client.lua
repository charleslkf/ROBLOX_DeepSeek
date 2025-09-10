--[[
    ControllerDispatcher.client.lua

    This client-side script's only job is to listen for a signal from the
    server (via ActivateClientControllerEvent) and activate the correct
    controller script inside the player's character by firing its
    internal 'Activate' event.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer

local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local activateEvent = EventsFolder:WaitForChild("ActivateClientControllerEvent")

activateEvent.OnClientEvent:Connect(function(scriptName)
    if not scriptName then return end

    -- The server has told us to activate a specific controller.
    -- Find it in our character.
    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local controllerScript = character:FindFirstChild(scriptName, true)

    if controllerScript then
        -- Find the 'Activate' event inside the script and fire it.
        local activateSignal = controllerScript:FindFirstChild("Activate")
        if activateSignal and activateSignal:IsA("BindableEvent") then
            print("ControllerDispatcher: Firing Activate for " .. scriptName)
            activateSignal:Fire()
        else
            warn("ControllerDispatcher: Could not find Activate event in " .. scriptName)
        end
    else
        warn("ControllerDispatcher: Server tried to activate script '" .. scriptName .. "' but it was not found.")
    end
end)

print("ControllerDispatcher.client.lua initialized and listening.")
