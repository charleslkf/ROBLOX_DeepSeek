--!strict
--[=[
    @class ClassicMachine
    Handles the server-side logic for the "Classic" pipe-connecting machine minigame.
]=]
local ClassicMachine = {}
ClassicMachine.__index = ClassicMachine

-- Constants for the puzzle
local GRID_SIZE = 5
local START_POS = {X = 1, Y = 1}
local END_POS = {X = 4, Y = 4}

-- Defines the connections for each pipe type at different rotations.
-- A rotation of 0 is considered the "default" orientation.
local PIPE_CONNECTIONS = {
	S = { [0] = {"right"} }, -- Start pipe only connects to the right
	E = { [0] = {"up"} },    -- End pipe only accepts a connection from above
	I = {
		[0] = {"up", "down"},
		[90] = {"left", "right"},
		[180] = {"up", "down"},
		[270] = {"left", "right"},
	},
	L = {
		[0] = {"up", "right"},
		[90] = {"right", "down"},
		[180] = {"down", "left"},
		[270] = {"left", "up"},
	},
}

-- Maps a direction to its opposite
local OPPOSITE_DIRECTION = {
	up = "down",
	down = "up",
	left = "right",
	right = "left",
}

-- Maps a direction to its coordinate offset
local DIRECTION_VECTORS = {
	up = {X = 0, Y = -1},
	down = {X = 0, Y = 1},
	left = {X = -1, Y = 0},
	right = {X = 1, Y = 0},
}

--[=[
	Creates a new ClassicMachine instance.
]=]
function ClassicMachine.new(puzzleData: {GridSize: number})
	local self = setmetatable({}, ClassicMachine)
	self.GridSize = puzzleData.GridSize or GRID_SIZE
	self.IsCompleted = false
	return self
end

--[=[
	A helper to get the connections for a given pipe.
]=]
local function getPipeConnections(pipeType: string, rotation: number): {string}
	local normalizedRotation = (rotation % 360 + 360) % 360 -- Ensure rotation is 0, 90, 180, 270
	local connections = PIPE_CONNECTIONS[pipeType]
	if connections then
		return connections[normalizedRotation] or {}
	end
	return {}
end

--[=[
	Validates a solution using Breadth-First Search (BFS).
]=]
function ClassicMachine:ValidateSolution(solution: table): boolean
	-- 1. --- SETUP ---
	local queue = {START_POS} -- Queue of {X, Y} coordinates to visit
	local visited = {[START_POS.Y .. "," .. START_POS.X] = true} -- Set of "y,x" strings

	-- 2. --- BFS TRAVERSAL ---
	while #queue > 0 do
		local currentPos = table.remove(queue, 1) -- Dequeue
		local currentTile = solution[currentPos.Y][currentPos.X]

		-- 2a. --- GOAL CHECK ---
		if currentPos.X == END_POS.X and currentPos.Y == END_POS.Y then
			-- We have reached the end. Now check if the end pipe is correctly oriented.
			local endConnections = getPipeConnections(currentTile.Type, currentTile.Rotation)
			-- For our puzzle, the final connection must come from "up".
			local endPipe = solution[END_POS.Y][END_POS.X]
			if endPipe.Type == "E" then
				print("ClassicMachine: Path reached the end tile.")
				self.IsCompleted = true
				return true
			end
		end

		-- 2b. --- EXPLORE NEIGHBORS ---
		local currentConnections = getPipeConnections(currentTile.Type, currentTile.Rotation)

		for _, direction in ipairs(currentConnections) do
			local offset = DIRECTION_VECTORS[direction]
			local neighborPos = {X = currentPos.X + offset.X, Y = currentPos.Y + offset.Y}

			-- Check if neighbor is valid and not visited
			if neighborPos.X >= 1 and neighborPos.X <= GRID_SIZE and neighborPos.Y >= 1 and neighborPos.Y <= GRID_SIZE then
				local visitedKey = neighborPos.Y .. "," .. neighborPos.X
				if not visited[visitedKey] then
					local neighborTile = solution[neighborPos.Y][neighborPos.X]

					-- 2c. --- TWO-WAY CONNECTION CHECK ---
					-- The neighbor pipe must have an opening facing back to the current pipe.
					local requiredConnection = OPPOSITE_DIRECTION[direction]
					local neighborConnections = getPipeConnections(neighborTile.Type, neighborTile.Rotation)

					if table.find(neighborConnections, requiredConnection) then
						-- Connection is valid, add to queue
						visited[visitedKey] = true
						table.insert(queue, neighborPos)
					end
				end
			end
		end
	end

	-- 3. --- NO PATH FOUND ---
	-- If the queue is empty and we haven't returned true, there's no valid path.
	print("ClassicMachine: No valid path found to the end tile.")
	return false
end

--[=[
	Resets the machine to its initial state.
]=]
function ClassicMachine:Reset()
	self.IsCompleted = false
	print("Classic Machine has been reset.")
end

return ClassicMachine
