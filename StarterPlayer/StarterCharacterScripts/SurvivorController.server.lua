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

-- Main execution starts here.
-- We must safely wait for all components before proceeding.

-- Wait for all required instances with timeouts to prevent infinite yields.
local player = Players:GetPlayerFromCharacter(character)
local humanoid = character:WaitForChild("Humanoid", 20)
local roleValue = character:WaitForChild("Role", 20)

-- First, verify that all essential components exist.
if not (player and humanoid and roleValue) then
    warn("SurvivorController for " .. character.Name .. " failed to initialize: a core component (Player, Humanoid, or Role) is missing.")
    script:Destroy()
    return
end

-- Second, check the role. If it's Killer, we're done here.
if roleValue.Value == "Killer" then
    script:Destroy()
    return
end

-- Third, if the role isn't "Survivor" yet, wait a moment for it to be assigned.
-- This handles race conditions where the script runs before GameManager sets the role.
if roleValue.Value ~= "Survivor" then
    local success = pcall(function()
        roleValue.Changed:Wait()
    end)
    -- If the wait fails or the role is still not Survivor, then exit.
    if not success or roleValue.Value ~= "Survivor" then
        warn("SurvivorController for " .. character.Name .. " timed out or role was not set to Survivor.")
        script:Destroy()
        return
    end
end

-- If we've made it this far, the role is "Survivor" and all components are present.
-- The controller creates its own event to be self-contained and avoid race conditions.
local damageEvent = Instance.new("BindableEvent")
damageEvent.Name = "DamageEvent"
damageEvent.Parent = character

InitializeSurvivor(player, humanoid, roleValue, damageEvent)
