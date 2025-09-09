--[[InteractionController.client.lua

    This single script manages all client-side interaction logic:
    - Proximity detection for interactable objects.
    - Displaying interaction UI prompts.
    - Handling input to start/perform interactions.
    - Creating and managing the Skill Check minigame UI and logic.
    - Cancelling interactions if the player moves away.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local localPlayer = Players.LocalPlayer
local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local characterRoot = character:WaitForChild("HumanoidRootPart")
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- =============================================================================
-- UI Creation
-- =============================================================================

-- Interaction Prompt UI
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

-- Skill Check UI (Asset-Free)
local skillCheckGui = Instance.new("ScreenGui")
skillCheckGui.Name = "SkillCheckGui"
skillCheckGui.Enabled = false
skillCheckGui.ResetOnSpawn = false
skillCheckGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 200, 0, 200)
mainFrame.Position = UDim2.new(0.5, -100, 0.5, -100)
mainFrame.BackgroundTransparency = 1
mainFrame.Parent = skillCheckGui

local circleBg = Instance.new("Frame")
circleBg.Name = "CircleBackground"
circleBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
circleBg.BackgroundTransparency = 0.5
circleBg.Size = UDim2.new(1, 0, 1, 0)
circleBg.BorderSizePixel = 0
circleBg.Parent = mainFrame
local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1, 0)
circleCorner.Parent = circleBg

local successZoneContainer = Instance.new("Frame")
successZoneContainer.Name = "SuccessZoneContainer"
successZoneContainer.Size = UDim2.new(1, 0, 1, 0)
successZoneContainer.BackgroundTransparency = 1
successZoneContainer.ClipsDescendants = true
successZoneContainer.Parent = circleBg

local successZone = Instance.new("Frame")
successZone.Name = "SuccessZone"
successZone.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
successZone.BorderSizePixel = 0
successZone.Size = UDim2.new(1, 0, 0.5, 0)
successZone.Position = UDim2.new(0, 0, 0.5, 0)
successZone.AnchorPoint = Vector2.new(0, 1)
successZone.Parent = successZoneContainer

local needle = Instance.new("Frame")
needle.Name = "Needle"
needle.Size = UDim2.new(0.05, 0, 0.5, 0)
needle.Position = UDim2.new(0.5, 0, 0.5, 0)
needle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
needle.BorderSizePixel = 0
needle.AnchorPoint = Vector2.new(0.5, 1)
needle.Parent = mainFrame

-- =============================================================================
-- Role Check
-- =============================================================================
-- This controller should ONLY run for Survivors.
-- More robust role-checking to prevent infinite yield on client.
local roleValue = character:WaitForChild("Role", 10)

local function onRoleChanged(newRole)
    if newRole == "Killer" then
        -- If we are the killer, this controller is not needed.
        -- Destroy all UI elements and the script itself.
        interactionGui:Destroy()
        skillCheckGui:Destroy()
        script:Destroy()
    end
end

if roleValue then
    onRoleChanged(roleValue.Value) -- Initial check
    roleValue.Changed:Connect(onRoleChanged)
else
    -- If the Role value never appears, we can't know our role.
    -- The safe assumption is to destroy the script.
    warn("InteractionController on " .. character.Name .. " could not find Role value after 10 seconds. Destroying script.")
    script:Destroy()
end

-- =============================================================================
-- Services and Events
-- =============================================================================
local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local interactionEvent = EventsFolder:WaitForChild("InteractionEvent")
local startSkillCheckEvent = EventsFolder:WaitForChild("StartSkillCheckEvent")
local skillCheckResultEvent = EventsFolder:WaitForChild("SkillCheckResultEvent")
local stopInteractionEvent = EventsFolder:WaitForChild("StopInteractionEvent")

-- =============================================================================
-- State and Configuration
-- =============================================================================
local INTERACTION_DISTANCE = 10
local currentInteractionTarget = nil
local isInteracting = false
local isSkillCheckActive = false
local skillCheckHeartbeatConnection = nil
local skillCheckInputConnection = nil

-- =============================================================================
-- Functions
-- =============================================================================

-- Function to stop the current interaction and skill check
local function cancelInteraction()
    if skillCheckHeartbeatConnection then skillCheckHeartbeatConnection:Disconnect() end
    if skillCheckInputConnection then skillCheckInputConnection:Disconnect() end
    skillCheckGui.Enabled = false
    isSkillCheckActive = false
    -- We don't reset isInteracting here, the server will tell us when to do that.
end

-- Function to run the skill check minigame
local function runSkillCheck()
    if isSkillCheckActive then return end
    isSkillCheckActive = true

    local SUCCESS_ZONE_DEGREES = 45
    local randomRotation = math.random(0, 360 - SUCCESS_ZONE_DEGREES)
    successZoneContainer.Rotation = randomRotation
    skillCheckGui.Enabled = true

    needle.Rotation = 0
    local rotationSpeed = 300

    skillCheckHeartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime)
        needle.Rotation = (needle.Rotation + rotationSpeed * deltaTime) % 360
    end)

    skillCheckInputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then return end
        if input.KeyCode == Enum.KeyCode.E then
            local successZoneStart = randomRotation
            local successZoneEnd = successZoneStart + SUCCESS_ZONE_DEGREES
            local isSuccess = (needle.Rotation >= successZoneStart and needle.Rotation <= successZoneEnd)

            skillCheckResultEvent:FireServer(isSuccess)
            cancelInteraction()
        end
    end)
end

-- =============================================================================
-- Event Listeners
-- =============================================================================

-- Listen for the server to tell us to start a skill check
startSkillCheckEvent.OnClientEvent:Connect(runSkillCheck)

-- Listen for the server to tell us the interaction is fully over
stopInteractionEvent.OnClientEvent:Connect(function()
    isInteracting = false
end)

-- Handle player input to start an interaction
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent then return end
    if input.KeyCode == Enum.KeyCode.E then
        if currentInteractionTarget and not isInteracting then
            isInteracting = true
            interactionLabel.Visible = false
            interactionEvent:FireServer(currentInteractionTarget)
        end
    end
end)

-- Main proximity detection loop
RunService.Heartbeat:Connect(function(deltaTime)
    if isInteracting then
        -- NEW: If we are interacting, check if we've moved too far away
        if currentInteractionTarget then
            local distance = (characterRoot.Position - currentInteractionTarget.Position).Magnitude
            if distance > INTERACTION_DISTANCE + 2 then -- Add a buffer
                skillCheckResultEvent:FireServer(false) -- Moving away counts as failure
                cancelInteraction()
            end
        end
        return
    end

    -- Find the closest interactable object
    local closestDistance = INTERACTION_DISTANCE
    local target = nil
    for _, part in ipairs(CollectionService:GetTagged("Interactable")) do
        local distance = (characterRoot.Position - part.Position).Magnitude
        if distance < closestDistance then
            closestDistance = distance
            target = part
        end
    end

    if target ~= currentInteractionTarget then
        currentInteractionTarget = target
        if currentInteractionTarget then
            local tags = CollectionService:GetTags(currentInteractionTarget)
            local objectType = "Object"
            for _, tag in ipairs(tags) do
                if tag ~= "Interactable" then objectType = tag; break; end
            end
            interactionLabel.Text = "Press [E] to repair " .. objectType
            interactionLabel.Visible = true
        else
            interactionLabel.Visible = false
        end
    end
end)

print("Unified InteractionController initialized.")
