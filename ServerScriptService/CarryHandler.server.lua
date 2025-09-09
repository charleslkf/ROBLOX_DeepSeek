--[[
    CarryHandler.server.lua

    This script handles the server-side logic for a Killer carrying
    and hooking a Survivor.
]]

-- Singleton pattern to prevent multiple executions
if _G.CarryHandlerLoaded then
    return
end
_G.CarryHandlerLoaded = true

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local carryRequestEvent = EventsFolder:WaitForChild("CarryRequestEvent")
local hookRequestEvent = EventsFolder:WaitForChild("HookRequestEvent")

local CARRY_DISTANCE_THRESHOLD = 10 -- Max distance the killer can be to pickup

-- =============================================================================
-- Event Handlers
-- =============================================================================

local function onCarryRequest(killerPlayer, survivorPlayer)
    -- 1. Get characters and root parts
    local killerChar = killerPlayer.Character
    local survivorChar = survivorPlayer.Character
    if not killerChar or not survivorChar then return end

    local killerRoot = killerChar:FindFirstChild("HumanoidRootPart")
    local survivorRoot = survivorChar:FindFirstChild("HumanoidRootPart")
    local survivorHumanoid = survivorChar:FindFirstChildOfClass("Humanoid")
    if not killerRoot or not survivorRoot or not survivorHumanoid then return end

    -- 2. Validate the request
    -- Check distance
    local distance = (killerRoot.Position - survivorRoot.Position).Magnitude
    if distance > CARRY_DISTANCE_THRESHOLD then
        warn(string.format("Carry request denied: %s and %s are too far apart (%.2f studs)", killerPlayer.Name, survivorPlayer.Name, distance))
        return
    end

    -- Check if survivor is downed (WalkSpeed is 0 is the proxy)
    if survivorHumanoid.WalkSpeed > 0 then
        warn(string.format("Carry request denied: %s is not downed.", survivorPlayer.Name))
        return
    end

    -- Check if killer is already carrying someone
    if killerChar:FindFirstChild("IsCarrying") and killerChar.IsCarrying.Value == true then
        warn(string.format("Carry request denied: %s is already carrying someone.", killerPlayer.Name))
        return
    end

    print(string.format("Carry request validated for %s picking up %s", killerPlayer.Name, survivorPlayer.Name))

    -- 3. Create IsCarrying attribute
    local isCarrying = Instance.new("BoolValue")
    isCarrying.Name = "IsCarrying"
    isCarrying.Value = true
    isCarrying.Parent = killerChar

    -- 4. Create Weld
    -- Create an attachment point on the killer's back
    local carryAttachment = Instance.new("Attachment")
    carryAttachment.Name = "CarryAttachment"
    carryAttachment.Position = Vector3.new(0, 2, -1.5) -- Position on the killer's back
    carryAttachment.Parent = killerRoot

    -- Weld the survivor to the attachment point
    local weld = Instance.new("WeldConstraint")
    weld.Name = "CarryWeld"
    weld.Part0 = survivorRoot
    weld.Part1 = carryAttachment
    weld.Parent = survivorRoot

    -- 5. Disable survivor's ability to move on their own
    survivorHumanoid.WalkSpeed = 0
    survivorHumanoid.JumpPower = 0

    -- 6. Store a reference to the carried survivor
    local carriedSurvivorVal = Instance.new("ObjectValue")
    carriedSurvivorVal.Name = "CarriedSurvivor"
    carriedSurvivorVal.Value = survivorChar
    carriedSurvivorVal.Parent = killerChar

    print(string.format("%s is now carrying %s.", killerPlayer.Name, survivorPlayer.Name))
end

local function onHookRequest(killerPlayer, targetHook)
    -- 1. Get killer character and validate state
    local killerChar = killerPlayer.Character
    if not killerChar then return end

    local isCarryingValue = killerChar:FindFirstChild("IsCarrying")
    local carriedSurvivorValue = killerChar:FindFirstChild("CarriedSurvivor")

    if not isCarryingValue or not carriedSurvivorValue or not carriedSurvivorValue.Value then
        warn(killerPlayer.Name .. " sent hook request in an invalid state (not carrying).")
        return
    end

    -- 2. Validate the hook and distance
    if not targetHook or not targetHook.PrimaryPart then
        warn(killerPlayer.Name .. " sent a hook request with an invalid hook target.")
        return
    end

    local killerRoot = killerChar:FindFirstChild("HumanoidRootPart")
    if not killerRoot then return end

    local distance = (killerRoot.Position - targetHook.PrimaryPart.Position).Magnitude
    if distance > CARRY_DISTANCE_THRESHOLD then
        warn(string.format("Hook request denied: %s is too far from hook (%.2f studs).", killerPlayer.Name, distance))
        return
    end

    -- 3. Get the survivor from the reference
    local survivorChar = carriedSurvivorValue.Value
    local survivorRoot = survivorChar and survivorChar:FindFirstChild("HumanoidRootPart")
    if not survivorRoot then
        warn("Hook logic error: CarriedSurvivor reference is invalid.")
        return
    end

    local survivorPlayer = Players:GetPlayerFromCharacter(survivorChar)
    print(string.format("Hook request validated. %s is hooking %s on %s", killerPlayer.Name, survivorPlayer.Name, targetHook.Name))

    -- 4. Un-weld from killer and clean up
    local carryWeld = survivorRoot:FindFirstChild("CarryWeld")
    if carryWeld then carryWeld:Destroy() end

    local carryAttachment = killerRoot:FindFirstChild("CarryAttachment")
    if carryAttachment then carryAttachment:Destroy() end

    isCarryingValue:Destroy()
    carriedSurvivorValue:Destroy()

    -- 5. Weld to hook
    local hookPoint = targetHook:FindFirstChild("HookPoint")
    if not hookPoint then
        warn("Hook model is missing 'HookPoint' part!")
        return
    end

    local hookWeld = Instance.new("WeldConstraint")
    hookWeld.Name = "HookWeld"
    hookWeld.Part0 = survivorRoot
    hookWeld.Part1 = hookPoint
    hookWeld.Parent = survivorRoot

    -- The survivor is now on the hook.
    print(string.format("%s has been successfully hooked.", survivorPlayer.Name))
end


-- =============================================================================
-- Connections
-- =============================================================================

carryRequestEvent.OnServerEvent:Connect(onCarryRequest)
hookRequestEvent.OnServerEvent:Connect(onHookRequest)

print("CarryHandler.server.lua loaded.")
