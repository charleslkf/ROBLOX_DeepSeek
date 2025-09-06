--[[
    InteractionController.client.lua

    This script runs on the client for the local player's character.
    It is responsible for detecting nearby interactable objects and managing
    the UI prompts for them.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local character = script.Parent

local CollectionService = game:GetService("CollectionService")
local UserInputService = game:GetService("UserInputService")
local characterRoot = character:WaitForChild("HumanoidRootPart")
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Get RemoteEvent
local EventsFolder = game:GetService("ReplicatedStorage"):WaitForChild("Events")
local interactionEvent = EventsFolder:WaitForChild("InteractionEvent")

-- Configuration
local INTERACTION_DISTANCE = 10
local closestInteractable = nil

-- Create Interaction UI
local interactionGui = Instance.new("ScreenGui")
interactionGui.Name = "InteractionGui"
interactionGui.ResetOnSpawn = false
interactionGui.Parent = playerGui

local interactionLabel = Instance.new("TextLabel")
interactionLabel.Name = "InteractionLabel"
interactionLabel.Size = UDim2.new(0, 300, 0, 50)
interactionLabel.Position = UDim2.new(0.5, -150, 0.6, 0)
interactionLabel.BackgroundTransparency = 1
interactionLabel.TextColor3 = Color3.new(1, 1, 1)
interactionLabel.TextSize = 24
interactionLabel.TextStrokeTransparency = 0
interactionLabel.Text = "Press [E] to Interact"
interactionLabel.Visible = false
interactionLabel.Parent = interactionGui

print("InteractionController initialized for " .. localPlayer.Name)

-- =============================================================================
-- Services and Logic
-- =============================================================================

-- Proximity Detection Loop
RunService.Heartbeat:Connect(function(deltaTime)
    local closestDistance = INTERACTION_DISTANCE
    local target = nil

    -- Find the closest interactable object
    for _, part in ipairs(CollectionService:GetTagged("Interactable")) do
        local distance = (characterRoot.Position - part.Position).Magnitude
        if distance < closestDistance then
            closestDistance = distance
            target = part
        end
    end

    if target ~= closestInteractable then
        closestInteractable = target
        if closestInteractable then
            -- Found a new target, show and update UI
            local tags = CollectionService:GetTags(closestInteractable)
            local objectType = "Object" -- Default
            for _, tag in ipairs(tags) do
                if tag ~= "Interactable" then
                    objectType = tag
                    break
                end
            end
            interactionLabel.Text = "Press [E] to repair " .. objectType
            interactionLabel.Visible = true
        else
            -- No target in range, hide UI
            interactionLabel.Visible = false
        end
    end
end)

-- Input Handling
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    -- Ignore input if typing in a textbox, etc.
    if gameProcessedEvent then return end

    if input.KeyCode == Enum.KeyCode.E then
        -- Check if we are close to an interactable object
        if closestInteractable then
            print("Player pressed E near " .. closestInteractable.Name .. ". Firing event to server.")
            interactionEvent:FireServer(closestInteractable)
        end
    end
end)
