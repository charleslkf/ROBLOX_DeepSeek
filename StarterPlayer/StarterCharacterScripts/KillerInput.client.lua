--[[
    KillerInput.client.lua

    This script handles the Killer's attack input.
    It starts as DISABLED and is enabled by the server's GameManager
    only for the player who is chosen as the Killer.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

script.Disabled = true -- Start disabled

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

-- Sound
local ATTACK_SOUND_ID = "rbxassetid://122226379"

print("KillerInput.client.lua: Script created and waiting to be enabled.")

-- Listen for input
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    -- The script's Disabled property will prevent this from running until enabled
    if gameProcessedEvent then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 and canAttack then
        canAttack = false

        -- Play local sound effect
        local sound = Instance.new("Sound")
        sound.SoundId = ATTACK_SOUND_ID
        sound.Parent = head
        sound:Play()
        game.Debris:AddItem(sound, 1)

        -- Fire event to server
        killerAttackEvent:FireServer()

        -- Cooldown
        wait(attackCooldown)
        canAttack = true
    end
end)
