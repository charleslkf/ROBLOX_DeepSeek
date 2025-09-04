--[[
    LobbyUI.client.lua

    This script creates the lobby UI and handles player input for role selection.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")

-- Get the RemoteEvent for role selection
local selectRoleEvent = ReplicatedStorage:WaitForChild("SelectRoleEvent")

-- Create the ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "LobbyUI"
screenGui.Parent = PlayerGui

-- Create the Survivor button
local survivorButton = Instance.new("TextButton")
survivorButton.Name = "SurvivorButton"
survivorButton.Text = "Play as Survivor"
survivorButton.Size = UDim2.new(0, 200, 0, 50)
survivorButton.Position = UDim2.new(0.5, -210, 0.5, -25)
survivorButton.Parent = screenGui

-- Create the Killer button
local killerButton = Instance.new("TextButton")
killerButton.Name = "KillerButton"
killerButton.Text = "Play as Killer"
killerButton.Size = UDim2.new(0, 200, 0, 50)
killerButton.Position = UDim2.new(0.5, 10, 0.5, -25)
killerButton.Parent = screenGui

-- Handle Survivor button click
survivorButton.MouseButton1Click:Connect(function()
    print("Survivor button clicked")
    selectRoleEvent:FireServer("Survivor")
    screenGui:Destroy() -- Hide the UI after selection
end)

-- Handle Killer button click
killerButton.MouseButton1Click:Connect(function()
    print("Killer button clicked")
    selectRoleEvent:FireServer("Killer")
    screenGui:Destroy() -- Hide the UI after selection
end)
