--!strict
--[=[
	This module script programmatically creates and returns the ScreenGui
	for the Memory Machine minigame.
]=]

local function createMemoryMachineGui(): ScreenGui
	-- Main ScreenGui container
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "MemoryMachineGui"
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = false

	-- Main Frame for the puzzle window
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0.4, 0, 0.7, 0) -- Made taller for new elements
	mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	mainFrame.BorderSizePixel = 2
	mainFrame.BorderColor3 = Color3.fromRGB(160, 160, 160)
	mainFrame.Parent = screenGui

	-- Title Label
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, 0, 0, 50)
	titleLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.Text = "Repeat the Pattern"
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.TextSize = 24
	titleLabel.Parent = mainFrame

	-- Frame to hold the puzzle grid
	local gridContainer = Instance.new("Frame")
	gridContainer.Name = "GridContainer"
	gridContainer.Size = UDim2.new(0.9, 0, 1, -150) -- Adjusted size for new elements
	gridContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
	gridContainer.AnchorPoint = Vector2.new(0.5, 0.5)
	gridContainer.BackgroundTransparency = 1
	gridContainer.Parent = mainFrame

	local aspectRatio = Instance.new("UIAspectRatioConstraint")
	aspectRatio.AspectRatio = 1
	aspectRatio.DominantAxis = Enum.DominantAxis.Width
	aspectRatio.Parent = gridContainer

	-- Manually calculate grid positions for a 3x3 grid
	local NUM_CELLS = 3
	local PADDING_SCALE = 0.05
	local totalPadding = PADDING_SCALE * (NUM_CELLS - 1)
	local totalCellScale = 1.0 - totalPadding
	local cellScale = totalCellScale / NUM_CELLS

	-- Create the grid of buttons
	for y = 1, NUM_CELLS do
		for x = 1, NUM_CELLS do
			local tileButton = Instance.new("TextButton")
			tileButton.Name = `Tile_{y}_{x}`
			tileButton.Text = ""
			tileButton.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
			tileButton.BorderSizePixel = 1

			tileButton.Size = UDim2.fromScale(cellScale, cellScale)
			local xPos = (x - 1) * (cellScale + PADDING_SCALE)
			local yPos = (y - 1) * (cellScale + PADDING_SCALE)
			tileButton.Position = UDim2.fromScale(xPos, yPos)

			tileButton.Parent = gridContainer
			tileButton:SetAttribute("GridX", x)
			tileButton:SetAttribute("GridY", y)
		end
	end

	-- Status label to give instructions
	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLabel"
	statusLabel.Size = UDim2.new(0.8, 0, 0, 30)
	statusLabel.Position = UDim2.new(0.5, 0, 1, -55)
	statusLabel.AnchorPoint = Vector2.new(0.5, 1)
	statusLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	statusLabel.Text = "Watch the pattern..."
	statusLabel.Font = Enum.Font.SourceSans
	statusLabel.TextSize = 18
	statusLabel.Parent = mainFrame

	return screenGui
end

return createMemoryMachineGui
