--[[
    KillerController.server.lua

    This script runs on the server for the Killer's character.
    It manages the killer's movement speed, attacks, and other abilities.
]]

local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

-- Get the GameManager module
-- Get the character and player this script belongs to
local character = script.Parent
local player = Players:GetPlayerFromCharacter(character)

-- Wait for the player to exist, just in case
if not player then
    return
end

-- Wait for the server to assign a role to this character
local roleValue = character:WaitForChild("Role", 15)

-- If no role is assigned or the role is not Killer, destroy this script.
if not roleValue or roleValue.Value ~= "Killer" then
    script:Destroy()
    return
end

-- If we've reached here, this character belongs to the Killer.
print("KillerController: " .. player.Name .. " is the Killer. Applying attributes.")

local humanoid = character:WaitForChild("Humanoid")
if humanoid then
    -- Make the killer slightly faster than survivors
    local SURVIVOR_SPEED = 16
    humanoid.WalkSpeed = SURVIVOR_SPEED * 1.2 -- 20% faster
    print("KillerController: " .. player.Name .. "'s speed set to " .. humanoid.WalkSpeed)
end

-- =============================================================================
-- Attack Handling
-- =============================================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local killerAttackEvent = EventsFolder:WaitForChild("KillerAttackEvent")

local ATTACK_RANGE = 8 -- studs
local HIT_SOUND_ID = "rbxassetid://130632152" -- A concrete hit sound

killerAttackEvent.OnServerEvent:Connect(function(eventPlayer)
    -- Security check: ensure the player firing the event is the one this script controls
    if eventPlayer ~= player then return end

    local rootPart = character:WaitForChild("HumanoidRootPart")
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
            local roleValue = hitCharacter:FindFirstChild("Role")

            -- Check if we hit a survivor
            if roleValue and roleValue.Value == "Survivor" then
                local hitPlayer = game.Players:GetPlayerFromCharacter(hitCharacter)
                print("Killer " .. player.Name .. " hit survivor " .. hitPlayer.Name)

                -- Fire the survivor's damage event
                local damageEvent = hitCharacter:FindFirstChild("DamageEvent")
                if damageEvent then
                    damageEvent:Fire() -- Fire the BindableEvent
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
