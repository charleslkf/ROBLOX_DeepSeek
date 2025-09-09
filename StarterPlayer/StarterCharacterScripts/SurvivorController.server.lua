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
local initialized = false

local function onRoleChanged(newRole)
    if newRole == "Survivor" and not initialized then
        initialized = true

        -- All components are guaranteed to exist at this point.
        local player = Players:GetPlayerFromCharacter(character)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local roleValue = character:FindFirstChild("Role")

        -- Now that we know we are a survivor, wait for the DamageEvent created by the GameManager
        local damageEvent = character:WaitForChild("DamageEvent")
        if not damageEvent then
            warn("SurvivorController for " .. character.Name .. " could not find DamageEvent.")
            script:Destroy()
            return
        end

        InitializeSurvivor(player, humanoid, roleValue, damageEvent)

    elseif newRole == "Killer" then
        -- If the role is Killer, this script is not needed.
        script:Destroy()
    end
end

-- More robust role-checking to prevent infinite yield.
-- Wait a maximum of 10 seconds for the Role value to be assigned by the GameManager.
local roleValue = character:WaitForChild("Role", 10)

if roleValue then
    onRoleChanged(roleValue.Value) -- Initial check
    roleValue.Changed:Connect(onRoleChanged)
else
    -- If the Role value never appears, print a warning and self-destruct.
    -- This can happen if a player joins but the game never starts.
    warn("SurvivorController on " .. character.Name .. " could not find Role value after 10 seconds. Destroying script.")
    script:Destroy()
end
