--[[
    LobbyUI.client.lua

    This script creates a simple "Ready" button for the lobby.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- Get the RemoteEvent for player readiness
local playerReadyEvent = ReplicatedStorage:WaitForChild("PlayerReadyEvent")

-- Create the ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LobbyUI"
screenGui.Parent = PlayerGui

-- Create the Ready button
local readyButton = Instance.new("TextButton")
readyButton.Name = "ReadyButton"
readyButton.Text = "Ready"
readyButton.Size = UDim2.new(0, 200, 0, 50)
readyButton.Position = UDim2.new(0.5, -100, 0.8, 0) -- Positioned at the bottom-center
readyButton.Parent = screenGui

-- Handle Ready button click
readyButton.MouseButton1Click:Connect(function()
    print("Ready button clicked. Notifying server.")
    playerReadyEvent:FireServer()
    readyButton.Text = "Waiting for other players..."
    readyButton.Active = false -- Disable the button after clicking
end)

-- A server script should destroy this UI when the game starts.
-- game.ReplicatedStorage.StartGameEvent.OnClientEvent:Connect(function()
--     screenGui:Destroy()
-- end)
