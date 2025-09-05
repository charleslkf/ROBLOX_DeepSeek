--[[
    SurvivorController.server.lua

    This script runs on the server for each Survivor character.
    It manages the survivor's health state, movement speed, and other
    core mechanics.
]]

local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

-- Get the GameManager module
local GameManager = require(ServerScriptService.GameManager)

-- Get the character and player this script belongs to
local character = script.Parent
local player = Players:GetPlayerFromCharacter(character)

-- Wait for the player to exist, just in case
if not player then
    return
end

-- =============================================================================
-- This is a placeholder check. In a running game, the GameManager.Players
-- table would be populated. For now, we need a way to ensure this runs.
-- A better method would be to have GameManager tag players.
-- For now, we'll assume if the role is not "Killer", it's a survivor.
-- =============================================================================
-- Loop until the game starts and a role is assigned.
while GameManager.CurrentState == GameManager.GameState.PreGame do
    wait(1)
end

local role = GameManager.Players[player]
if role ~= "Survivor" then
    -- If this character does not belong to a Survivor, do nothing.
    print("SurvivorController: " .. player.Name .. " is not a Survivor (" .. tostring(role) .. "). Destroying script.")
    script:Destroy()
    return
end

print("SurvivorController: Verified role for " .. player.Name .. ". Initializing.")

-- The rest of the logic for health states and events will be added here
-- =============================================================================
-- Health State Management
-- =============================================================================

local humanoid = character:WaitForChild("Humanoid")
local DEFAULT_WALKSPEED = humanoid.WalkSpeed -- Store the default speed

-- Define health states and their corresponding walk speeds
local healthStateSpeeds = {
    Healthy = DEFAULT_WALKSPEED,
    Injured = DEFAULT_WALKSPEED * 0.9, -- 10% slower
    Downed = 0
}

-- Create the HealthState value object
local healthState = Instance.new("StringValue")
healthState.Name = "HealthState"
healthState.Value = "Healthy"
healthState.Parent = character

-- Listen for changes to the health state
healthState.Changed:Connect(function(newValue)
    print(player.Name .. " health state changed to: " .. newValue)

    local newSpeed = healthStateSpeeds[newValue]
    if newSpeed ~= nil then
        humanoid.WalkSpeed = newSpeed
    else
        warn("Unknown health state: " .. tostring(newValue))
    end
end)

print("SurvivorController: Health system initialized for " .. player.Name)

-- =============================================================================
-- Damage Handling
-- =============================================================================

local damageEvent = Instance.new("BindableEvent")
damageEvent.Name = "DamageEvent"
damageEvent.Parent = character

damageEvent.Event:Connect(function()
    print("DEBUG: DamageEvent fired for " .. player.Name)
    local currentState = healthState.Value

    if currentState == "Healthy" then
        healthState.Value = "Injured"
    elseif currentState == "Injured" then
        healthState.Value = "Downed"
    elseif currentState == "Downed" then
        -- Already downed, do nothing.
        print(player.Name .. " is already downed.")
    end
end)

print("DEBUG: DamageEvent connection set up for " .. player.Name)
