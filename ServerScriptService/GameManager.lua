--[[
    GameManager

    This module is the central authority for the game. It manages the game state,
    player roles, and win/loss conditions.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local activateClientControllerEvent = EventsFolder:WaitForChild("ActivateClientControllerEvent")

-- Require the new MachineManager
local MachineManager = require(ServerScriptService.MachineManager)

local GameManager = {}

-- Game State Enum
GameManager.GameState = {
    PreGame = "PreGame",
    InGame = "InGame",
    PostGame = "PostGame"
}

-- Constants
GameManager.MIN_PLAYERS = 2
GameManager.MAX_PLAYERS = 2
GameManager.GENERATORS_TO_REPAIR = 5

-- Game Data
GameManager.CurrentState = GameManager.GameState.PreGame
GameManager.Players = {} -- { [player] = "Survivor" or "Killer" }
GameManager.GeneratorsLeft = GameManager.GENERATORS_TO_REPAIR

--[[
    Assigns roles to the players in the game.
]]
function GameManager:AssignRoles(playerList)
    self.Players = {}

    local function setupCharacter(player, role)
        local character = player.Character
        if not character then
            character = player.CharacterAdded:Wait()
        end

        -- Create Role tag
        local roleValue = Instance.new("StringValue")
        roleValue.Name = "Role"
        roleValue.Value = role
        roleValue.Parent = character
        print("GameManager: Tagged " .. player.Name .. " as " .. role)

        if role == "Killer" then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = 16 * 1.2
            end
            activateClientControllerEvent:FireClient(player, "KillerInput")
        elseif role == "Survivor" then
            local damageEvent = Instance.new("BindableEvent")
            damageEvent.Name = "DamageEvent"
            damageEvent.Parent = character

            local survivorScript = character:FindFirstChild("SurvivorController", true)
            if survivorScript then
                local activateSignal = survivorScript:FindFirstChild("Activate")
                if activateSignal then activateSignal:Fire() end
            end
            activateClientControllerEvent:FireClient(player, "InteractionController")
        end
    end

    -- Assign roles
    local killerIndex = math.random(1, #playerList)
    for i, player in ipairs(playerList) do
        if i == killerIndex then
            self.Players[player] = "Killer"
            setupCharacter(player, "Killer")
            print(player.Name .. " has been chosen as the Killer!")
        else
            self.Players[player] = "Survivor"
            setupCharacter(player, "Survivor")
            print(player.Name .. " is a Survivor.")
        end
    end
end

--[[
    Called when a generator is completed.
]]
function GameManager:GeneratorCompleted()
    if self.CurrentState == self.GameState.InGame then
        self.GeneratorsLeft = self.GeneratorsLeft - 1
        print("A generator has been repaired! " .. self.GeneratorsLeft .. " remaining.")

        if self.GeneratorsLeft <= 0 then
            print("All generators have been repaired! The exit gates are now powered.")
            -- TODO: Logic to power the exit gates will go here.
        end
    end
end

--[[
    Starts the game with a given set of players.
]]
function GameManager:StartGame(players)
    if self.CurrentState == self.GameState.PreGame and #players >= self.MIN_PLAYERS then
        print("Starting game with " .. #players .. " players...")
        self.CurrentState = self.GameState.InGame
        self.GeneratorsLeft = self.GENERATORS_TO_REPAIR

        -- Initialize the Machine Manager
        MachineManager:Init()
        MachineManager.MachineCompleted.Event:Connect(function()
            self:GeneratorCompleted()
        end)

        -- Create the required number of machines
        print("GameManager: Creating machines...")
        MachineManager:CreateMachine("SkillCheckMachine", {ChecksRequired = 3})
        MachineManager:CreateMachine("SkillCheckMachine", {ChecksRequired = 4})
        MachineManager:CreateMachine("ClassicMachine", {GridSize = 5})
        MachineManager:CreateMachine("MemoryMachine", {PatternSize = 3, PatternLength = 4})
        MachineManager:CreateMachine("MemoryMachine", {PatternSize = 4, PatternLength = 5})

        -- Assign roles after setting up the map and managers
        self:AssignRoles(players)

        print("The game has started!")
    else
        warn("GameManager:StartGame - Could not start game. State: " .. self.CurrentState .. ", Players: " .. #players)
    end
end

function GameManager:EndGame(winner)
    if self.CurrentState == self.GameState.InGame then
        self.CurrentState = self.GameState.PostGame
        print(winner .. " wins!")
        MachineManager:ResetAllMachines() -- Clean up machines
    end
end

function GameManager:CheckWinConditions()
    -- To be implemented
end

return GameManager
