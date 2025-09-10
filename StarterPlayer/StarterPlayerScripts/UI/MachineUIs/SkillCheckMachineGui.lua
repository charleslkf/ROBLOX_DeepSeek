--!strict
--[=[
	This module script programmatically creates and returns the ScreenGui
	for the Skill Check minigame.
]=]

local function createSkillCheckGui(): ScreenGui
	-- Main ScreenGui container
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SkillCheckMachineGui"
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = false

	-- Main Frame for the puzzle window
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0.4, 0, 0.25, 0) -- Small, wide window
	mainFrame.Position = UDim2.new(0.5, 0, 0.75, 0) -- Positioned towards the bottom
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	mainFrame.BorderSizePixel = 2
	mainFrame.BorderColor3 = Color3.fromRGB(160, 160, 160)
	mainFrame.Parent = screenGui

	-- Title Label
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, 0, 0, 40)
	titleLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.Text = "Skill Check"
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.TextSize = 20
	titleLabel.Parent = mainFrame

	-- Background bar for the skill check
	local backgroundBar = Instance.new("Frame")
	backgroundBar.Name = "BackgroundBar"
	backgroundBar.Size = UDim2.new(0.8, 0, 0, 20) -- 80% of window width
	backgroundBar.Position = UDim2.new(0.5, 0, 0.6, 0) -- Positioned in the bottom half
	backgroundBar.AnchorPoint = Vector2.new(0.5, 0.5)
	backgroundBar.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	backgroundBar.BorderSizePixel = 2
	backgroundBar.BorderColor3 = Color3.new(0, 0, 0)
	backgroundBar.Parent = mainFrame

	-- Success Zone frame inside the background bar
	local successZone = Instance.new("Frame")
	successZone.Name = "SuccessZone"
	successZone.Size = UDim2.new(0.2, 0, 1, 0)
	successZone.Position = UDim2.fromScale(0.7, 0.5)
	successZone.AnchorPoint = Vector2.new(0.5, 0.5)
	successZone.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
	successZone.BorderSizePixel = 0
	successZone.Parent = backgroundBar

	-- Moving cursor that travels across the bar
	local cursor = Instance.new("Frame")
	cursor.Name = "Cursor"
	cursor.Size = UDim2.new(0, 4, 1.2, 0)
	cursor.Position = UDim2.fromScale(0, 0.5)
	cursor.AnchorPoint = Vector2.new(0.5, 0.5)
	cursor.BackgroundColor3 = Color3.new(1, 1, 1)
	cursor.BorderSizePixel = 0
	cursor.Parent = backgroundBar

	return screenGui
end

return createSkillCheckGui
