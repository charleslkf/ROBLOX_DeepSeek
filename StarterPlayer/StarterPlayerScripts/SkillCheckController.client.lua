--[[
    SkillCheckController.client.lua

    This script runs on the client and manages the entire skill check minigame,
    including its UI and logic.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- =============================================================================
-- Create Skill Check UI
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

-- NOTE: These are placeholder asset IDs. They would need to be replaced with
-- actual image assets uploaded to Roblox.
local CIRCLE_IMAGE = "rbxassetid://0" -- Placeholder for a white circle image
local WEDGE_IMAGE = "rbxassetid://0"  -- Placeholder for a wedge/slice image

local circleBg = Instance.new("ImageLabel")
circleBg.Name = "CircleBackground"
circleBg.Image = CIRCLE_IMAGE
circleBg.ImageColor3 = Color3.fromRGB(0, 0, 0)
circleBg.ImageTransparency = 0.5
circleBg.Size = UDim2.new(1, 0, 1, 0)
circleBg.BackgroundTransparency = 1
circleBg.Parent = mainFrame

local successZone = Instance.new("ImageLabel")
successZone.Name = "SuccessZone"
successZone.Image = WEDGE_IMAGE
successZone.ImageColor3 = Color3.fromRGB(255, 255, 255)
successZone.Size = UDim2.new(1, 0, 1, 0)
successZone.BackgroundTransparency = 1
successZone.Rotation = 45 -- Example position
successZone.Parent = mainFrame

local needle = Instance.new("Frame")
needle.Name = "Needle"
needle.Size = UDim2.new(0.05, 0, 0.4, 0)
needle.Position = UDim2.new(0.5, -needle.Size.X.Offset / 2, 0.1, 0)
needle.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
needle.BorderSizePixel = 0
needle.AnchorPoint = Vector2.new(0.5, 1) -- Set anchor to bottom-center for rotation
needle.Parent = mainFrame

print("SkillCheckController: UI created and ready.")

-- =============================================================================
-- Minigame Logic
-- =============================================================================
local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local startSkillCheckEvent = EventsFolder:WaitForChild("StartSkillCheckEvent")
local skillCheckResultEvent = EventsFolder:WaitForChild("SkillCheckResultEvent")

local isSkillCheckActive = false

local function runSkillCheck()
    if isSkillCheckActive then return end
    isSkillCheckActive = true

    -- Randomize success zone position and size
    successZone.Rotation = math.random(0, 330)
    -- Placeholder for variable size, using a fixed size for now
    -- successZone.Size = UDim2.new(1, 0, 1, 0) -- This depends on the wedge image used

    -- Make UI visible
    skillCheckGui.Enabled = true

    -- Animate the needle
    needle.Rotation = 0
    local rotationSpeed = 300 -- degrees per second
    local heartbeatConnection = nil
    heartbeatConnection = RunService.Heartbeat:Connect(function(deltaTime)
        needle.Rotation = (needle.Rotation + rotationSpeed * deltaTime) % 360
    end)

    -- Listen for spacebar press
    local inputConnection = nil
    inputConnection = UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then return end

        -- Using E key for now to avoid conflict with jumping
        if input.KeyCode == Enum.KeyCode.E then
            heartbeatConnection:Disconnect()
            inputConnection:Disconnect()

            -- Check for success
            local successZoneStart = successZone.Rotation
            local successZoneEnd = successZoneStart + 30 -- Assuming a 30 degree wedge for the image
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
