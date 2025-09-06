--[[
    GameManager

    This module is the central authority for the game. It manages the game state,
    player roles, and win/loss conditions.
]]

local GameManager = {}

-- Game State Enum
GameManager.GameState = {
    PreGame = "PreGame",
    InGame = "InGame",
    PostGame = "PostGame"
}

-- Constants
GameManager.MIN_PLAYERS = 5
GameManager.MAX_PLAYERS = 5

-- Game Data
GameManager.CurrentState = GameManager.GameState.PreGame
GameManager.Players = {} -- { [player] = "Survivor" or "Killer" }
GameManager.GeneratorsLeft = 5

--[[
    Assigns roles to the players in the game.
    One player is randomly chosen as the Killer from the provided list.
]]
function GameManager:AssignRoles(playerList)
    self.Players = {}

    -- Helper function to tag a character with their role
    local function tagCharacter(player, role)
        local character = player.Character
        if character then
            -- Remove old tag if it exists
            local oldTag = character:FindFirstChild("Role")
            if oldTag then oldTag:Destroy() end

            local roleValue = Instance.new("StringValue")
            roleValue.Name = "Role"
            roleValue.Value = role
            roleValue.Parent = character
        end
    end

    -- Select a random killer
    local killerIndex = math.random(1, #playerList)
    local killerPlayer = playerList[killerIndex]
    self.Players[killerPlayer] = "Killer"
    tagCharacter(killerPlayer, "Killer")
    print(killerPlayer.Name .. " has been chosen as the Killer!")

    -- Enable the Killer's input script
    local killerCharacter = killerPlayer.Character
    if killerCharacter then
        -- The script name might not have the .lua extension in the explorer
        local killerInputScript = killerCharacter:WaitForChild("KillerInput.client", 5)
        if killerInputScript then
            killerInputScript.Disabled = false
            print("KillerInput script enabled for " .. killerPlayer.Name)
        else
            warn("Could not find KillerInput script for " .. killerPlayer.Name)
        end
    end

    -- Assign the rest as survivors
    for i, player in ipairs(playerList) do
        if i ~= killerIndex then
            self.Players[player] = "Survivor"
            tagCharacter(player, "Survivor")
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
        -- More logic to come here (e.g., teleporting players)
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
        -- More logic to come here (e.g., showing end-game screen)
    end
end

--[[
    Checks the win conditions.
]]
function GameManager:CheckWinConditions()
    if self.CurrentState == self.GameState.InGame then
        -- Killer win condition: All survivors are sacrificed.
        -- Survivor win condition: At least one survivor escapes.

        -- This will be implemented in a later task.
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
            -- Logic to power the exit gates will go here.
        end
    end
end

return GameManager
