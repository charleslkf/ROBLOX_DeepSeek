--[[
    SurvivorController.server.lua

    This script runs on the server for each Survivor character.
    It manages the survivor's health state, movement speed, and other
    core mechanics.
]]

local Players = game:GetService("Players")

-- Get the character and player this script belongs to
local character = script.Parent
local player = Players:GetPlayerFromCharacter(character)

-- Wait for the player to exist, just in case
if not player then
    return
end

-- Wait for the server to assign a role to this character
local roleValue = character:WaitForChild("Role", 15) -- Wait up to 15 seconds

-- If no role is assigned or the role is not Survivor, destroy this script.
if not roleValue or roleValue.Value ~= "Survivor" then
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
    Injured = DEFAULT_WALKSPEED * 0.5, -- 50% slower
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

-- The DamageEvent is now created by the GameManager. We just need to find it.
local damageEvent = character:WaitForChild("DamageEvent")

-- This event is fired by other server scripts (e.g., KillerController)
damageEvent.Event:Connect(function()
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
