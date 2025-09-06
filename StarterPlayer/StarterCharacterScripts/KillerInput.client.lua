--[[
    KillerInput.client.lua

    This script runs on the client for the Killer's character.
    It is responsible for handling the Killer's input, such as attacking.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Get local player and character
local localPlayer = Players.LocalPlayer
local character = script.Parent

-- =============================================================================
-- Role Check
-- =============================================================================
-- Wait for the server to assign a role to this character
local roleValue = character:WaitForChild("Role", 15)

-- If no role is assigned or the role is not Killer, destroy this script.
if not roleValue or roleValue.Value ~= "Killer" then
    script:Destroy()
    return
end

print("KillerInput.client.lua: Initialized for Killer " .. localPlayer.Name)

-- =============================================================================
-- Attack Logic
-- =============================================================================
local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local killerAttackEvent = EventsFolder:WaitForChild("KillerAttackEvent")
local attackCooldown = 1 -- seconds
local canAttack = true

-- Built-in Roblox sound ID for a sword slash
local ATTACK_SOUND_ID = "rbxassetid://122226379"

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 and canAttack then
        canAttack = false

        -- Play local sound effect
        local sound = Instance.new("Sound")
        sound.SoundId = ATTACK_SOUND_ID
        sound.Parent = character:WaitForChild("Head")
        sound:Play()
        game.Debris:AddItem(sound, 1) -- Clean up sound after 1 second

        -- TODO: Add a simple visual effect

        -- Fire event to server
        killerAttackEvent:FireServer()

        -- Cooldown
        wait(attackCooldown)
        canAttack = true
    end
end)
