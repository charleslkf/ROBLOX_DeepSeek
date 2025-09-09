--[[
    InitServer.server.lua

    This script handles the initial server-side setup, manages the pre-game
    lobby state, and starts the game when enough players have joined.

    MODIFIED FOR TESTING: Game starts automatically when MIN_PLAYERS join.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

-- Require the GameManager module
local GameManager = require(ServerScriptService.GameManager)

local gameStarted = false

-- Get references to the pre-defined RemoteEvents
local EventsFolder = ReplicatedStorage:WaitForChild("Events")
local gameStartEvent = EventsFolder:WaitForChild("GameStartEvent")

-- Function to check if the game can start
local function tryStartGame()
    -- Prevent starting more than once
    if gameStarted then return end

    local playersInGame = Players:GetPlayers()
    print(#playersInGame .. "/" .. GameManager.MIN_PLAYERS .. " players have joined.")

    -- If we have enough players, start the game
    if #playersInGame >= GameManager.MIN_PLAYERS then
        gameStarted = true
        print("Enough players have joined! Starting the match...")

        GameManager:StartGame(playersInGame)

        -- Tell all clients to clean up their lobby UI
        gameStartEvent:FireAllClients()
    end
end

-- Listen for a player joining
Players.PlayerAdded:Connect(function(player)
    print(player.Name .. " has joined the server.")
    -- A small delay to ensure the player is fully loaded in
    task.wait(1)
    tryStartGame()
end)

-- Handle players leaving (optional, but good practice for testing)
Players.PlayerRemoving:Connect(function(player)
    if gameStarted then
        -- In a real game, you might handle this, but for testing, we don't need to.
        print(player.Name .. " has left after the game started.")
    end
end)

print("Server initialization complete. Waiting for players to join.")

-- =============================================================================
-- Handle Player Interactions (Copied from original file)
-- =============================================================================
local CollectionService = game:GetService("CollectionService")
local interactionEvent = EventsFolder:WaitForChild("InteractionEvent")
local startSkillCheckEvent = EventsFolder:WaitForChild("StartSkillCheckEvent")
local stopInteractionEvent = EventsFolder:WaitForChild("StopInteractionEvent")
local repairingPlayers = {}

interactionEvent.OnServerEvent:Connect(function(player, interactableObject)
    if not (interactableObject and interactableObject.Parent) then
        warn("Interaction request received from " .. player.Name .. " for a missing object.")
        return
    end

    -- For now, we only handle generators
    if not CollectionService:HasTag(interactableObject, "Generator") then return end

    -- Check if player is already repairing something
    if repairingPlayers[player] then
        print(player.Name .. " is already repairing.")
        return
    end

    print(player.Name .. " started repairing " .. interactableObject.Name)
    repairingPlayers[player] = interactableObject

    -- Tell the client to start the skill check minigame
    startSkillCheckEvent:FireClient(player)
end)

local skillCheckResultEvent = EventsFolder:WaitForChild("SkillCheckResultEvent")
skillCheckResultEvent.OnServerEvent:Connect(function(player, isSuccess)
    print("Received skill check result from " .. player.Name .. ": " .. tostring(isSuccess))
    -- TODO: Handle generator progress based on result

    -- For now, assume the interaction is over after one skill check.
    repairingPlayers[player] = nil

    -- Tell the client they are no longer interacting
    stopInteractionEvent:FireClient(player)
end)
