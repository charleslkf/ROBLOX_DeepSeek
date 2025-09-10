-- This script is disabled by default. It will be enabled by the GameManager
-- after the 'Survivor' role has been assigned.
script.Disabled = true

local function Initialize()
    --[[
        SurvivorController.server.lua

        This script runs on the server for each Survivor character.
        It manages the survivor's health state, movement speed, and other
        core mechanics.
    ]]

    local Players = game:GetService("Players")
    local character = script.Parent

    -- Get components. We can use WaitForChild here because the GameManager
    -- guarantees they exist before enabling this script.
    local player = Players:GetPlayerFromCharacter(character)
    local humanoid = character:WaitForChild("Humanoid")
    local damageEvent = character:WaitForChild("DamageEvent")

    print("SurvivorController: Initializing for " .. player.Name)

    -- Health State Management
    local DEFAULT_WALKSPEED = humanoid.WalkSpeed
    local healthStateSpeeds = {
        Healthy = DEFAULT_WALKSPEED,
        Injured = DEFAULT_WALKSPEED * 0.5, -- 50% slower
        Downed = 0
    }

    local healthState = Instance.new("StringValue")
    healthState.Name = "HealthState"
    healthState.Value = "Healthy"
    healthState.Parent = character

    healthState.Changed:Connect(function(newValue)
        print(player.Name .. " health state changed to: " .. newValue)
        local newSpeed = healthStateSpeeds[newValue]
        if newSpeed ~= nil then
            humanoid.WalkSpeed = newSpeed
            -- Add visual state for being downed
            if newValue == "Downed" then
                humanoid.PlatformStand = true
            else
                humanoid.PlatformStand = false
            end
        else
            warn("Unknown health state: " .. tostring(newValue))
        end
    end)

    -- Damage Handling
    damageEvent.Event:Connect(function()
        local currentState = healthState.Value
        if currentState == "Healthy" then
            healthState.Value = "Injured"
        elseif currentState == "Injured" then
            healthState.Value = "Downed"
        elseif currentState == "Downed" then
            print(player.Name .. " is already downed.")
        end
    end)

    print("SurvivorController: Health and damage systems initialized for " .. player.Name)
end

-- Wait until the script is enabled by the GameManager
while script.Disabled do
    task.wait(0.1)
end

-- Run the main logic
Initialize()
