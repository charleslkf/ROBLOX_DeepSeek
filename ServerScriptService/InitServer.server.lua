--[[
    InitServer.server.lua

    This script handles the initial server-side setup. It creates RemoteEvents
    and connects them to the appropriate game logic.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

-- Require the GameManager module
local GameManager = require(ServerScriptService.GameManager)

-- Create the RemoteEvent for role selection
local selectRoleEvent = Instance.new("RemoteEvent")
selectRoleEvent.Name = "SelectRoleEvent"
selectRoleEvent.Parent = ReplicatedStorage

-- Connect the event to the GameManager's SelectRole function
selectRoleEvent.OnServerEvent:Connect(function(player, role)
    GameManager:SelectRole(player, role)
end)

print("Server initialization complete. Role selection event is ready.")
