--[[
    GameManager

    This module is the central authority for the game. It manages the game state,
    player roles, and win/loss conditions.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local activateClientControllerEvent = EventsFolder:WaitForChild("ActivateClientControllerEvent")

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

-- Game Data
GameManager.CurrentState = GameManager.GameState.PreGame
GameManager.Players = {} -- { [player] = "Survivor" or "Killer" }
GameManager.GeneratorsLeft = 5

--[[
    Assigns roles to the players in the game.
    This function now uses a RemoteEvent to reliably activate client-side scripts.
]]
function GameManager:AssignRoles(playerList)
    self.Players = {}

    local function setupCharacter(player, role)
        local character = player.Character
        if not character then
            -- If character doesn't exist, wait for it to be added.
            -- This is a fallback; InitServer should ideally wait for characters.
            character = player.CharacterAdded:Wait()
        end

        -- Create Role tag
        local roleValue = Instance.new("StringValue")
        roleValue.Name = "Role"
        roleValue.Value = role
        roleValue.Parent = character
        print("GameManager: Tagged " .. player.Name .. " as " .. role)

        if role == "Killer" then
            -- Set Killer's walk speed
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                local SURVIVOR_SPEED = 16
                humanoid.WalkSpeed = SURVIVOR_SPEED * 1.2 -- 20% faster
            end
            -- Activate the client-side controller
            activateClientControllerEvent:FireClient(player, "KillerInput")

        elseif role == "Survivor" then
            -- Create a DamageEvent for the survivor
            local damageEvent = Instance.new("BindableEvent")
            damageEvent.Name = "DamageEvent"
            damageEvent.Parent = character

            -- Activate the server-side controller directly
            local survivorScript = character:FindFirstChild("SurvivorController", true)
            if survivorScript then
                survivorScript.Disabled = false
            end
            -- Activate the client-side controller via the dispatcher
            activateClientControllerEvent:FireClient(player, "InteractionController")
        end
    end

    -- Select a random killer
    local killerIndex = math.random(1, #playerList)
    local killerPlayer = playerList[killerIndex]
    self.Players[killerPlayer] = "Killer"
    setupCharacter(killerPlayer, "Killer")
    print(killerPlayer.Name .. " has been chosen as the Killer!")

    -- Assign the rest as survivors
    for i, player in ipairs(playerList) do
        if i ~= killerIndex then
            self.Players[player] = "Survivor"
            setupCharacter(player, "Survivor")
            print(player.Name .. " is a Survivor.")
        end
    end
end

--[[
    Starts the game with a given set of players.
]]
function GameManager:StartGame(players)
    if self.CurrentState == self.GameState.PreGame and #players >= self.MIN_PLAYERS then
        print("Starting game with " .. #players .. " players...")
        self:AssignRoles(players)
        self.CurrentState = self.GameState.InGame
        print("The game has started!")
    else
        warn("GameManager:StartGame - Could not start game. State: " .. self.CurrentState .. ", Players: " .. #players)
    end
end

--[[
    Ends the game.
]]
function GameManager:EndGame(winner)
    if self.CurrentState == self.GameState.InGame then
        self.CurrentState = self.GameState.PostGame
        print(winner .. " wins!")
    end
end

--[[
    Checks the win conditions.
]]
function GameManager:CheckWinConditions()
    -- To be implemented
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
        end
    end
end

return GameManager
