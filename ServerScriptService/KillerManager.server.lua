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
-- Get RemoteEvents
local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local killerAttackEvent = EventsFolder:WaitForChild("KillerAttackEvent")
local carryRequestEvent = EventsFolder:WaitForChild("CarryRequestEvent")
local hookRequestEvent = EventsFolder:WaitForChild("HookRequestEvent")

-- Constants
local ATTACK_RANGE = 8 -- studs
local INTERACTION_RANGE = 9 -- studs (slight buffer over client)
local HIT_SOUND_ID = "rbxassetid://17733314210"

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

-- Listen for a killer carrying a survivor
carryRequestEvent.OnServerEvent:Connect(function(killerPlayer, survivorPlayer)
    -- Security Check 1: Validate roles
    if GameManager.Players[killerPlayer] ~= "Killer" or GameManager.Players[survivorPlayer] ~= "Survivor" then
        warn("Carry request with invalid roles. Requester: " .. killerPlayer.Name .. ", Target: " .. survivorPlayer.Name)
        return
    end

    -- Security Check 2: Validate character existence
    local killerChar = killerPlayer.Character
    local survivorChar = survivorPlayer.Character
    if not killerChar or not survivorChar then return end

    local killerRoot = killerChar:FindFirstChild("HumanoidRootPart")
    local survivorRoot = survivorChar:FindFirstChild("HumanoidRootPart")
    local survivorHumanoid = survivorChar:FindFirstChildOfClass("Humanoid")
    if not killerRoot or not survivorRoot or not survivorHumanoid then return end

    -- State Check 1: Make sure killer isn't already carrying someone
    local isCarrying = killerChar:FindFirstChild("IsCarrying")
    if not isCarrying then
        isCarrying = Instance.new("BoolValue")
        isCarrying.Name = "IsCarrying"
        isCarrying.Parent = killerChar
    end
    if isCarrying.Value then
        warn("Killer " .. killerPlayer.Name .. " tried to carry while already carrying someone.")
        return
    end

    -- State Check 2: Make sure survivor is actually downed (WalkSpeed is 0)
    if survivorHumanoid.WalkSpeed > 0 then
        warn("Killer " .. killerPlayer.Name .. " tried to carry a survivor who is not downed.")
        return
    end

    -- Validation Check: Distance
    if (killerRoot.Position - survivorRoot.Position).Magnitude > INTERACTION_RANGE then
        warn("Killer " .. killerPlayer.Name .. " tried to carry a survivor from too far away.")
        return
    end

    -- All checks passed, proceed to carry
    print("Carry request validated. Killer " .. killerPlayer.Name .. " is now carrying " .. survivorPlayer.Name)
    isCarrying.Value = true

    -- Store a reference to the survivor being carried
    local carriedSurvivorVal = killerChar:FindFirstChild("CarriedSurvivor")
    if not carriedSurvivorVal then
        carriedSurvivorVal = Instance.new("ObjectValue")
        carriedSurvivorVal.Name = "CarriedSurvivor"
        carriedSurvivorVal.Parent = killerChar
    end
    carriedSurvivorVal.Value = survivorChar

    -- Animate survivor and make them massless to prevent killer slowdown
    survivorHumanoid:ChangeState(Enum.HumanoidStateType.PlatformStanding)
    for _, part in ipairs(survivorChar:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Massless = true
        end
    end

    -- Weld the survivor to the killer's back
    local weld = Instance.new("Weld")
    weld.Name = "CarryWeld"
    weld.Part0 = killerRoot
    weld.Part1 = survivorRoot
    weld.C1 = CFrame.new(0, -2, 1.5) * CFrame.Angles(0, math.rad(180), 0)
    weld.Parent = killerRoot
end)

-- Listen for a killer hooking a survivor
hookRequestEvent.OnServerEvent:Connect(function(killerPlayer, hookModel)
    -- Security Check 1: Validate role
    if GameManager.Players[killerPlayer] ~= "Killer" then return end

    -- Security Check 2: Validate character and hook
    local killerChar = killerPlayer.Character
    if not killerChar or not (hookModel and hookModel:IsA("Model") and hookModel:FindFirstChild("HookPoint")) then return end

    -- State Check: Make sure killer is actually carrying someone
    local isCarrying = killerChar:FindFirstChild("IsCarrying")
    local carriedSurvivorVal = killerChar:FindFirstChild("CarriedSurvivor")
    if not (isCarrying and isCarrying.Value == true and carriedSurvivorVal and carriedSurvivorVal.Value) then
        warn("Killer " .. killerPlayer.Name .. " tried to hook when not carrying.")
        return
    end

    local survivorChar = carriedSurvivorVal.Value
    local survivorRoot = survivorChar:FindFirstChild("HumanoidRootPart")
    local killerRoot = killerChar:FindFirstChild("HumanoidRootPart")
    if not survivorRoot or not killerRoot then return end

    -- Validation Check: Distance to hook
    if (killerRoot.Position - hookModel.PrimaryPart.Position).Magnitude > INTERACTION_RANGE then
        warn("Killer " .. killerPlayer.Name .. " tried to hook from too far away.")
        return
    end

    -- All checks passed, proceed to hook
    print("Hook request validated. Killer " .. killerPlayer.Name .. " hooked " .. survivorChar.Name)

    -- Destroy the carry weld
    local carryWeld = killerRoot:FindFirstChild("CarryWeld")
    if carryWeld then carryWeld:Destroy() end

    -- Update killer's state
    isCarrying.Value = false
    carriedSurvivorVal.Value = nil

    -- Restore survivor's mass
    for _, part in ipairs(survivorChar:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Massless = false
        end
    end

    -- Move survivor to the hook and weld them
    local hookPoint = hookModel:FindFirstChild("HookPoint")
    survivorRoot.CFrame = hookPoint.CFrame

    local hookWeld = Instance.new("Weld")
    hookWeld.Name = "HookWeld"
    hookWeld.Part0 = hookPoint
    hookWeld.Part1 = survivorRoot
    hookWeld.Parent = hookPoint
end)

print("KillerManager.server.lua loaded and listening for events.")
