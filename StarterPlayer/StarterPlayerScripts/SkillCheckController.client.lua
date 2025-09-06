--[[
    SkillCheckController.client.lua

    This script runs on the client and manages the entire skill check minigame,
    including its UI and logic. This version uses Frames instead of Images
    to be more reliable.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- =============================================================================
-- Create Skill Check UI (Asset-Free)
-- =============================================================================
local skillCheckGui = Instance.new("ScreenGui")
skillCheckGui.Name = "SkillCheckGui"
skillCheckGui.Enabled = false -- Start disabled
skillCheckGui.ResetOnSpawn = false
skillCheckGui.Parent = playerGui

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 200, 0, 200)
mainFrame.Position = UDim2.new(0.5, -100, 0.5, -100)
mainFrame.BackgroundTransparency = 1
mainFrame.Parent = skillCheckGui

-- Create a circular background using a frame and UICorner
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

-- Create the success zone using a clipping frame and a rotated inner frame
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
successZone.Size = UDim2.new(1, 0, 0.5, 0) -- Covers half the circle
successZone.Position = UDim2.new(0, 0, 0.5, 0)
successZone.AnchorPoint = Vector2.new(0, 1) -- Rotate from bottom-left
successZone.Parent = successZoneContainer

-- Create the needle
local needle = Instance.new("Frame")
needle.Name = "Needle"
needle.Size = UDim2.new(0.05, 0, 0.5, 0)
needle.Position = UDim2.new(0.5, 0, 0.5, 0)
needle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
needle.BorderSizePixel = 0
needle.AnchorPoint = Vector2.new(0.5, 1) -- Set anchor to bottom-center for rotation
needle.Parent = mainFrame

print("SkillCheckController: Asset-free UI created and ready.")

-- =============================================================================
-- Minigame Logic
-- =============================================================================
local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local startSkillCheckEvent = EventsFolder:WaitForChild("StartSkillCheckEvent")
local skillCheckResultEvent = EventsFolder:WaitForChild("SkillCheckResultEvent")

local isSkillCheckActive = false
local SUCCESS_ZONE_DEGREES = 45 -- The size of the success zone in degrees

local function runSkillCheck()
    if isSkillCheckActive then return end
    isSkillCheckActive = true

    -- Randomize success zone position
    local randomRotation = math.random(0, 360 - SUCCESS_ZONE_DEGREES)
    successZoneContainer.Rotation = randomRotation

    -- Make UI visible
    skillCheckGui.Enabled = true

    -- Animate the needle
    needle.Rotation = 0
    local rotationSpeed = 300 -- degrees per second
    local heartbeatConnection = nil
    heartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime)
        needle.Rotation = (needle.Rotation + rotationSpeed * deltaTime) % 360
    end)

    -- Listen for input
    local inputConnection = nil
    inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then return end

        if input.KeyCode == Enum.KeyCode.E then
            heartbeatConnection:Disconnect()
            inputConnection:Disconnect()

            -- Check for success
            local successZoneStart = randomRotation
            local successZoneEnd = successZoneStart + SUCCESS_ZONE_DEGREES
            local isSuccess = (needle.Rotation >= successZoneStart and needle.Rotation <= successZoneEnd)

            if isSuccess then
                print("Skill check SUCCESS!")
            else
                print("Skill check FAILED.")
            end

            -- Send result to the server
            skillCheckResultEvent:FireServer(isSuccess)

            skillCheckGui.Enabled = false -- Hide UI
            isSkillCheckActive = false
        end
    end)
end

startSkillCheckEvent.OnClientEvent:Connect(runSkillCheck)
