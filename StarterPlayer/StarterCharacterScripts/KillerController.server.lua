--[[
    KillerController.server.lua

    This script runs on the server for the Killer's character.
    It manages the killer's movement speed, attacks, and other abilities.
]]

local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

-- Get the GameManager module
local GameManager = require(ServerScriptService.GameManager)

-- Get the character and player this script belongs to
local character = script.Parent
local player = Players:GetPlayerFromCharacter(character)

-- Wait for the player to exist, just in case
if not player then
    return
end

-- Loop until the game starts and a role is assigned.
while GameManager.CurrentState == GameManager.GameState.PreGame do
    wait(1)
end

local role = GameManager.Players[player]
if role ~= "Killer" then
    -- This character is a survivor, so this script is not needed.
    script:Destroy()
    return
end

-- If we've reached here, this character belongs to the Killer.
print("KillerController: " .. player.Name .. " is the Killer. Applying attributes.")

local humanoid = character:WaitForChild("Humanoid")
if humanoid then
    -- Make the killer slightly faster than survivors
    local SURVIVOR_SPEED = 16
    humanoid.WalkSpeed = SURVIVOR_SPEED * 1.2 -- 20% faster
    print("KillerController: " .. player.Name .. "'s speed set to " .. humanoid.WalkSpeed)
end
