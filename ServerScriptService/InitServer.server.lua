--[[
    InitServer.server.lua

    This script handles the initial server-side setup, manages the pre-game
    lobby state, and starts the game when enough players are ready.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

-- Require the GameManager module
local GameManager = require(ServerScriptService.GameManager)

-- Table to keep track of players who are ready
local readyPlayers = {}
local gameStarted = false

-- Create the RemoteEvent for player readiness
-- Get references to the pre-defined RemoteEvents
local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local playerReadyEvent = EventsFolder:WaitForChild("PlayerReadyEvent")
local gameStartEvent = EventsFolder:WaitForChild("GameStartEvent")

-- Function to check if the game can start
local function tryStartGame()
    -- Prevent starting more than once
    if gameStarted then return end

    local playersInGame = Players:GetPlayers()
    local readyCount = 0
    for _, player in ipairs(playersInGame) do
        if readyPlayers[player] then
            readyCount = readyCount + 1
        end
    end

    print(readyCount .. "/" .. GameManager.MIN_PLAYERS .. " players are ready.")

    -- If we have enough players, start the game
    if readyCount >= GameManager.MIN_PLAYERS then
        gameStarted = true
        print("Enough players are ready! Starting the match...")

        -- We need to get the actual player objects that are ready
        local playersForGame = {}
        for player, _ in pairs(readyPlayers) do
            -- Ensure player is still in the game
            if player.Parent then
                table.insert(playersForGame, player)
            end
        end

        -- Only start if we still have enough players after the final check
        if #playersForGame >= GameManager.MIN_PLAYERS then
            GameManager:StartGame(playersForGame)

            -- Tell all clients to clean up their lobby UI
            gameStartEvent:FireAllClients()
        else
            -- Not enough players, reset
            gameStarted = false
            print("A player left at the last second. Resetting ready count.")
        end
    end
end

-- Listen for a player clicking the "Ready" button
playerReadyEvent.OnServerEvent:Connect(function(player)
    if not readyPlayers[player] then
        print(player.Name .. " has readied up.")
        readyPlayers[player] = true
        tryStartGame()
    end
end)

-- Handle players leaving
Players.PlayerRemoving:Connect(function(player)
    if readyPlayers[player] then
        readyPlayers[player] = nil
        print(player.Name .. " has left, removing from ready list.")
        -- In a real game, you might want to update the player count here.
        -- For now, the check in tryStartGame is sufficient.
    end
end)

print("Server initialization complete. Waiting for players to ready up.")

-- =============================================================================
-- Handle Player Interactions
-- =============================================================================
local interactionEvent = EventsFolder:WaitForChild("InteractionEvent")

interactionEvent.OnServerEvent:Connect(function(player, interactableObject)
    if interactableObject and interactableObject.Parent then
        print("Received interaction request from " .. player.Name .. " for object " .. interactableObject.Name)
        -- Later, this will trigger a channeled action or minigame.
    else
        warn("Interaction request received from " .. player.Name .. " for a missing object.")
    end
end)
