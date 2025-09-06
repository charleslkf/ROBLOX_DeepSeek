--[[
    KillerManager.server.lua

    This centralized script manages all server-side logic related to the Killer's actions,
    primarily handling the attack event and hit detection.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

-- Get the GameManager module to check roles
local GameManager = require(ServerScriptService.GameManager)

-- Get the RemoteEvent for the killer's attack
local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local killerAttackEvent = EventsFolder:WaitForChild("KillerAttackEvent")

-- Constants for the attack
local ATTACK_RANGE = 8 -- studs
local HIT_SOUND_ID = "rbxassetid://17733314210" -- Placeholder, using attack swoosh sound

-- Listen for a killer attacking
killerAttackEvent.OnServerEvent:Connect(function(eventPlayer)
    -- Security Check 1: Ensure the player who fired the event has the Killer role.
    if GameManager.Players[eventPlayer] ~= "Killer" then
        warn("A non-killer player (" .. eventPlayer.Name .. ") tried to fire KillerAttackEvent.")
        return
    end

    -- Security Check 2: Ensure the player's character exists.
    local character = eventPlayer.Character
    if not character then return end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    -- Perform the raycast to detect a hit
    local raycastParams = RaycastParams.new()
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
    raycastParams.FilterDescendantsInstances = {character} -- Ignore the killer's own character

    local origin = rootPart.Position
    local direction = rootPart.CFrame.LookVector * ATTACK_RANGE
    local result = workspace:Raycast(origin, direction, raycastParams)

    if result and result.Instance then
        local hitPart = result.Instance
        local hitCharacter = hitPart:FindFirstAncestorWhichIsA("Model")

        if hitCharacter then
            local hitPlayer = Players:GetPlayerFromCharacter(hitCharacter)

            -- Check if we hit a survivor
            if hitPlayer and GameManager.Players[hitPlayer] == "Survivor" then
                print("Killer " .. eventPlayer.Name .. " hit survivor " .. hitPlayer.Name)

                -- Fire the survivor's damage event
                local damageEvent = hitCharacter:FindFirstChild("DamageEvent")
                if damageEvent then
                    print("KillerManager: Found DamageEvent on " .. hitPlayer.Name .. ". Firing.")
                    damageEvent:Fire() -- Fire the BindableEvent
                else
                    warn("KillerManager: CRITICAL - Could not find DamageEvent on survivor " .. hitPlayer.Name)
                end

                -- Play a server-wide hit sound
                local sound = Instance.new("Sound")
                sound.SoundId = HIT_SOUND_ID
                sound.Parent = hitPart
                sound:Play()
                game.Debris:AddItem(sound, 1)
            end
        end
    end
end)

print("KillerManager.server.lua loaded and listening for attacks.")
