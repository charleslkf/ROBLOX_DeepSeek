--[[
    KillerInput.client.lua

    This script handles the Killer's attack input.
    It starts as DISABLED and is enabled by the server's GameManager
    only for the player who is chosen as the Killer.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

-- Get local player and character
local localPlayer = Players.LocalPlayer
local character = script.Parent
local head = character:WaitForChild("Head")

-- Get RemoteEvent
-- Get RemoteEvents
local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local killerAttackEvent = EventsFolder:WaitForChild("KillerAttackEvent")
local carryRequestEvent = EventsFolder:WaitForChild("CarryRequestEvent")
local hookRequestEvent = EventsFolder:WaitForChild("HookRequestEvent")

-- State
local attackCooldown = 1 -- seconds
local canAttack = true
local interactionCooldown = 0.5 -- seconds
local canInteract = true
local interactionRange = 8 -- studs
local isKiller = false

-- Sound

-- Role-based activation
local roleValue = character:WaitForChild("Role")

local function updateRole()
    isKiller = (roleValue.Value == "Killer")
    print("KillerInput.client.lua: Role is now " .. roleValue.Value .. ". IsKiller set to: " .. tostring(isKiller))
end

updateRole() -- Initial check
roleValue.Changed:Connect(updateRole)


print("KillerInput.client.lua: Script loaded and running. Waiting for role assignment.")

-- Helper function to find the nearest hook
local function findNearestHook()
    local killerRoot = character:FindFirstChild("HumanoidRootPart")
    if not killerRoot then return nil end

    local nearestHook = nil
    local minDistance = interactionRange

    local taggedHooks = CollectionService:GetTagged("SacrificialHook")
    for _, hookModel in ipairs(taggedHooks) do
        if hookModel:IsA("Model") and hookModel.PrimaryPart then
            local distance = (killerRoot.Position - hookModel.PrimaryPart.Position).Magnitude
            if distance < minDistance then
                minDistance = distance
                nearestHook = hookModel
            end
        end
    end
    return nearestHook
end

-- Helper function to find the nearest downed survivor
local function findNearestDownedSurvivor()
    local killerRoot = character:FindFirstChild("HumanoidRootPart")
    if not killerRoot then return nil end

    local nearestSurvivor = nil
    local minDistance = interactionRange

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= localPlayer and player.Character then
            local survivorChar = player.Character
            local roleVal = survivorChar:FindFirstChild("Role")
            local humanoid = survivorChar:FindFirstChildOfClass("Humanoid")

            -- Check if the character is a downed survivor
            if roleVal and roleVal.Value == "Survivor" and humanoid and humanoid.Health > 0 and humanoid.WalkSpeed == 0 then
                local survivorRoot = survivorChar:FindFirstChild("HumanoidRootPart")
                if survivorRoot then
                    local distance = (killerRoot.Position - survivorRoot.Position).Magnitude
                    if distance < minDistance then
                        minDistance = distance
                        nearestSurvivor = player
                    end
                end
            end
        end
    end
    return nearestSurvivor
end

-- Listen for input
UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if not isKiller or gameProcessedEvent then return end

    -- Attack Input
    if input.UserInputType == Enum.UserInputType.MouseButton1 and canAttack then
        canAttack = false
        killerAttackEvent:FireServer()
        task.wait(attackCooldown)
        canAttack = true
    end

-- Interaction Input (Pickup or Hook)
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.E and canInteract then
        canInteract = false

        local isCarrying = character:FindFirstChild("IsCarrying")

        if isCarrying and isCarrying.Value == true then
            -- If carrying, try to hook
            local targetHook = findNearestHook()
            if targetHook then
                print("Found hook: " .. targetHook.Name .. ". Requesting hook.")
                hookRequestEvent:FireServer(targetHook)
            end
        else
            -- If not carrying, try to pick up
            local targetSurvivor = findNearestDownedSurvivor()
            if targetSurvivor then
                print("Found downed survivor: " .. targetSurvivor.Name .. ". Requesting carry.")
                carryRequestEvent:FireServer(targetSurvivor)
            end
        end

        task.wait(interactionCooldown)
        canInteract = true
    end
end)
