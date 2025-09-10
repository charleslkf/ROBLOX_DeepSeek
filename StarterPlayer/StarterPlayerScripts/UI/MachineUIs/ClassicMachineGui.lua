--!strict
--[=[
	This module script programmatically creates and returns the ScreenGui
	for the Classic Machine minigame.
]=]

local function createGui(): ScreenGui
	-- Main ScreenGui container
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "ClassicMachineGui"
	screenGui.ResetOnSpawn = false
	screenGui.Enabled = false

	-- Main Frame for the puzzle window
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0.5, 0, 0.7, 0)
	mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	mainFrame.BorderSizePixel = 2
	mainFrame.BorderColor3 = Color3.fromRGB(150, 150, 150)
	mainFrame.Parent = screenGui

	-- Title Label
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, 0, 0, 50)
	titleLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.Text = "Connect the Pipes"
	titleLabel.Font = Enum.Font.SourceSansBold
	titleLabel.TextSize = 24
	titleLabel.Parent = mainFrame

	-- Frame to hold the puzzle grid
	local gridContainer = Instance.new("Frame")
	gridContainer.Name = "GridContainer"
	gridContainer.Size = UDim2.new(0.9, 0, 1, -110)
	gridContainer.Position = UDim2.new(0.5, 0, 0.5, 25)
	gridContainer.AnchorPoint = Vector2.new(0.5, 0.5)
	gridContainer.BackgroundTransparency = 1
	gridContainer.Parent = mainFrame

	-- AspectRatioConstraint to keep the grid square
	local aspectRatio = Instance.new("UIAspectRatioConstraint")
	aspectRatio.AspectRatio = 1
	aspectRatio.DominantAxis = Enum.DominantAxis.Width
	aspectRatio.Parent = gridContainer

	-- Define the puzzle layout
	local puzzleLayout = {
		{"S", "L", "_", "_", "_"},
		{"_", "I", "_", "_", "_"},
		{"_", "L", "I", "L", "_"},
		{"_", "_", "_", "E", "_"},
		{"_", "_", "_", "_", "_"},
	}

	-- FIX: Manually calculate grid positions instead of using UIGridLayout
	local NUM_CELLS = 5
	local PADDING_SCALE = 0.02 -- 2% of the container's width
	local totalPadding = PADDING_SCALE * (NUM_CELLS - 1)
	local totalCellScale = 1.0 - totalPadding
	local cellScale = totalCellScale / NUM_CELLS

	-- Create the grid tiles
	for y = 1, NUM_CELLS do
		for x = 1, NUM_CELLS do
			local tileData = puzzleLayout[y][x]
			local isInteractive = (tileData == "I" or tileData == "L")

			local tileInstance
			if isInteractive then
				tileInstance = Instance.new("TextButton")
				tileInstance.Text = ""
				tileInstance.AutoButtonColor = false
				tileInstance.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
				tileInstance.BorderSizePixel = 1
			else
				tileInstance = Instance.new("Frame")
			end

			tileInstance.Name = `Tile_{y}_{x}`
			-- Set manual Size and Position
			tileInstance.Size = UDim2.fromScale(cellScale, cellScale)
			local xPos = (x - 1) * (cellScale + PADDING_SCALE)
			local yPos = (y - 1) * (cellScale + PADDING_SCALE)
			tileInstance.Position = UDim2.fromScale(xPos, yPos)

			tileInstance.Parent = gridContainer
			tileInstance:SetAttribute("GridX", x)
			tileInstance:SetAttribute("GridY", y)
			tileInstance:SetAttribute("PipeType", tileData)

			if tileData ~= "_" then
				if not isInteractive then
					tileInstance.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
					tileInstance.BorderSizePixel = 1
				end

				if tileData == "I" then
					local bar = Instance.new("TextLabel")
					bar.Text = ""
					bar.Name = "Bar"
					bar.Size = UDim2.new(0.3, 0, 1, 0)
					bar.Position = UDim2.new(0.5, 0, 0.5, 0)
					bar.AnchorPoint = Vector2.new(0.5, 0.5)
					bar.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
					bar.BorderSizePixel = 0
					bar.Interactable = false
					bar.Parent = tileInstance
				elseif tileData == "L" then
					-- Correctly draw an L-shape that meets at the center without overlapping.
					local vertBar = Instance.new("TextLabel")
					vertBar.Text = ""
					vertBar.Name = "VertBar"
					vertBar.Size = UDim2.new(0.3, 0, 0.5, 0) -- Half height
					vertBar.Position = UDim2.new(0.5, 0, 0.25, 0) -- Positioned in top half
					vertBar.AnchorPoint = Vector2.new(0.5, 0.5)
					vertBar.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
					vertBar.BorderSizePixel = 0
					vertBar.Interactable = false
					vertBar.Parent = tileInstance

					local horizBar = Instance.new("TextLabel")
					horizBar.Text = ""
					horizBar.Name = "HorizBar"
					horizBar.Size = UDim2.new(0.5, 0, 0.3, 0) -- Half width
					horizBar.Position = UDim2.new(0.75, 0, 0.5, 0) -- Positioned in right half
					horizBar.AnchorPoint = Vector2.new(0.5, 0.5)
					horizBar.BackgroundColor3 = Color3.fromRGB(255, 150, 0)
					horizBar.BorderSizePixel = 0
					horizBar.Interactable = false
					horizBar.Parent = tileInstance
				elseif tileData == "S" or tileData == "E" then
					local indicator = Instance.new("TextLabel")
					indicator.Text = ""
					indicator.Size = UDim2.new(1, 0, 1, 0)
					indicator.BackgroundColor3 = if tileData == "S" then Color3.fromRGB(0, 255, 0) else Color3.fromRGB(255, 0, 0)
					indicator.Interactable = false
					indicator.Parent = tileInstance
				end
			else
				tileInstance.BackgroundTransparency = 1
			end
		end
	end

	-- Submit Button
	local submitButton = Instance.new("TextButton")
	submitButton.Name = "SubmitButton"
	submitButton.Size = UDim2.new(0.4, 0, 0, 40)
	submitButton.Position = UDim2.new(0.5, 0, 1, -10)
	submitButton.AnchorPoint = Vector2.new(0.5, 1)
	submitButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
	submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	submitButton.Text = "Submit"
	submitButton.Font = Enum.Font.SourceSansBold
	submitButton.TextSize = 20
	submitButton.Parent = mainFrame

	-- Feedback Label
	local feedbackLabel = Instance.new("TextLabel")
	feedbackLabel.Name = "FeedbackLabel"
	feedbackLabel.Size = UDim2.new(1, 0, 0, 30)
	feedbackLabel.Position = UDim2.new(0.5, 0, 0, 55)
	feedbackLabel.AnchorPoint = Vector2.new(0.5, 0)
	feedbackLabel.BackgroundTransparency = 1
	feedbackLabel.Font = Enum.Font.SourceSansBold
	feedbackLabel.TextSize = 18
	feedbackLabel.TextColor3 = Color3.new(1, 1, 1)
	feedbackLabel.Visible = false
	feedbackLabel.Parent = mainFrame

	return screenGui
end

return createGui
