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

-- Game Data
GameManager.CurrentState = GameManager.GameState.PreGame
GameManager.Players = {} -- { [player] = "Survivor" or "Killer" }
GameManager.GeneratorsLeft = 5

--[[
    Starts the game.
]]
function GameManager:StartGame()
    if self.CurrentState == self.GameState.PreGame then
        self.CurrentState = self.GameState.InGame
        print("The game has started!")
        -- More logic to come here (e.g., teleporting players)
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
    Assigns a role to a player.
]]
function GameManager:SelectRole(player, role)
    if self.CurrentState == self.GameState.PreGame then
        if role == "Survivor" or role == "Killer" then
            self.Players[player] = role
            print(player.Name .. " has selected the role of " .. role)
        else
            warn("Invalid role selected: " .. tostring(role))
        end
    else
        warn("Cannot select a role while the game is in progress.")
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
