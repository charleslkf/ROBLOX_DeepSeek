--[[
    SurvivorController.server.lua

    This script runs on the server for each Survivor character.
    It manages the survivor's health state, movement speed, and other
    core mechanics.
]]

local Players = game:GetService("Players")
local character = script.Parent

-- Function to initialize the survivor's mechanics.
-- This will only be called once all necessary components are ready.
local function InitializeSurvivor(player, humanoid, roleValue, damageEvent)
    print("SurvivorController: All components found for " .. player.Name .. ". Initializing health system.")

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

-- Main execution starts here.
-- We must safely wait for all components before proceeding.
local player = Players:GetPlayerFromCharacter(character)
if not player then
    -- If the player doesn't exist yet, wait for them to be added.
    -- This can happen in rare cases.
    local playerAddedConnection
    playerAddedConnection = Players.PlayerAdded:Connect(function(addedPlayer)
        if addedPlayer.Character == character then
            player = addedPlayer
            playerAddedConnection:Disconnect()
        end
    end)
    -- Wait a reasonable amount of time for the player to be associated
    local success, result = pcall(function()
        while not player do
            task.wait(0.1)
        end
    end)
    if not success or not player then
        warn("SurvivorController for " .. character.Name .. " could not find a matching Player object.")
        return
    end
end

-- Wait for all required instances with timeouts to prevent infinite yields.
local humanoid = character:WaitForChild("Humanoid", 20)
local roleValue = character:WaitForChild("Role", 20)
local damageEvent = character:WaitForChild("DamageEvent", 20)

-- Check if all components were found and the role is correct.
if humanoid and roleValue and damageEvent and roleValue.Value == "Survivor" then
    -- Everything is ready, call the main initialization function.
    InitializeSurvivor(player, humanoid, roleValue, damageEvent)
else
    -- If something is missing or the role is wrong, log a warning and stop.
    warn("SurvivorController for " .. character.Name .. " failed to initialize. Components might be missing or role is incorrect.")
    script:Destroy()
end
