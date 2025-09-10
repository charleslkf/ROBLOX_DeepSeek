-- This script waits for an 'Activate' event before running its logic.
-- The event is fired by the ControllerDispatcher after receiving a signal
-- from the server.

local activateEvent = Instance.new("BindableEvent")
activateEvent.Name = "Activate"
activateEvent.Parent = script

local function Initialize()
    --[[
        KillerInput.client.lua

        This script handles the Killer's attack input.
    ]]

    local Players = game:GetService("Players")
    local UserInputService = game:GetService("UserInputService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local CollectionService = game:GetService("CollectionService")

    -- Get local player and character
    local localPlayer = Players.LocalPlayer
    local character = script.Parent

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

    -- =============================================================================
    -- Helper Functions
    -- =============================================================================

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

    -- =============================================================================
    -- Main Logic
    -- =============================================================================

    print("KillerInput.client.lua: Activated and initializing input.")

    -- Listen for input
    UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
        if gameProcessedEvent then return end

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
                local targetHook = findNearestHook()
                if targetHook then
                    print("Found hook: " .. targetHook.Name .. ". Requesting hook.")
                    hookRequestEvent:FireServer(targetHook)
                end
            else
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
end

-- Wait for the activate signal
activateEvent.Event:Connect(Initialize)
