--[[
    MapBuilder.server.lua

    This script programmatically generates the entire map layout at runtime.
    This version uses explicit property tables for each part to avoid any
    potential bugs related to table reuse.
]]

local Workspace = game:GetService("Workspace")

-- Main container for all map elements
local map = Instance.new("Folder")
map.Name = "Map"
map.Parent = Workspace

-- Sub-folders for organization
local spawns = Instance.new("Folder")
spawns.Name = "Spawns"
spawns.Parent = map

local objectives = Instance.new("Folder")
objectives.Name = "Objectives"
objectives.Parent = map

local interactables = Instance.new("Folder")
interactables.Name = "Interactables"
interactables.Parent = map

-- =============================================================================
-- Helper function to create a basic part
-- =============================================================================
local function createPart(name, parent, properties)
    local part = Instance.new("Part")
    part.Name = name
    -- Set properties first
    for prop, value in pairs(properties) do
        part[prop] = value
    end
    -- Set parent last
    part.Parent = parent
    return part
end

-- =============================================================================
-- Create Baseplate
-- =============================================================================
createPart("Baseplate", Workspace, {
    Anchored = true,
    Color = Color3.fromRGB(99, 95, 99),
    Locked = true,
    Position = Vector3.new(0, -10, 0),
    Size = Vector3.new(2048, 20, 2048)
})

-- =============================================================================
-- Create Simple Walls
-- =============================================================================
local walls = Instance.new("Folder")
walls.Name = "Walls"
walls.Parent = map

createPart("Wall1", walls, {
    Anchored = true,
    Color = Color3.fromRGB(128, 128, 128),
    Material = Enum.Material.Concrete,
    TopSurface = Enum.SurfaceType.Smooth,
    BottomSurface = Enum.SurfaceType.Smooth,
    Size = Vector3.new(100, 20, 4),
    Position = Vector3.new(0, 10, 50)
})

createPart("Wall2", walls, {
    Anchored = true,
    Color = Color3.fromRGB(128, 128, 128),
    Material = Enum.Material.Concrete,
    TopSurface = Enum.SurfaceType.Smooth,
    BottomSurface = Enum.SurfaceType.Smooth,
    Size = Vector3.new(4, 20, 50),
    Position = Vector3.new(-50, 10, 0)
})

createPart("Wall3", walls, {
    Anchored = true,
    Color = Color3.fromRGB(128, 128, 128),
    Material = Enum.Material.Concrete,
    TopSurface = Enum.SurfaceType.Smooth,
    BottomSurface = Enum.SurfaceType.Smooth,
    Size = Vector3.new(4, 20, 50),
    Position = Vector3.new(50, 10, 0)
})

-- =============================================================================
-- Create Vaultable Window
-- =============================================================================
local windowModel = Instance.new("Model")
windowModel.Name = "WindowVault1"
windowModel.Parent = interactables

createPart("WallLeft", windowModel, {
    Anchored = true,
    Color = Color3.fromRGB(128, 128, 128),
    Material = Enum.Material.Concrete,
    TopSurface = Enum.SurfaceType.Smooth,
    BottomSurface = Enum.SurfaceType.Smooth,
    Size = Vector3.new(5, 20, 2),
    Position = Vector3.new(-45.5, 10, 80)
})

createPart("WallRight", windowModel, {
    Anchored = true,
    Color = Color3.fromRGB(128, 128, 128),
    Material = Enum.Material.Concrete,
    TopSurface = Enum.SurfaceType.Smooth,
    BottomSurface = Enum.SurfaceType.Smooth,
    Size = Vector3.new(5, 20, 2),
    Position = Vector3.new(-34.5, 10, 80)
})

createPart("WallTop", windowModel, {
    Anchored = true,
    Color = Color3.fromRGB(128, 128, 128),
    Material = Enum.Material.Concrete,
    TopSurface = Enum.SurfaceType.Smooth,
    BottomSurface = Enum.SurfaceType.Smooth,
    Size = Vector3.new(6, 4, 2),
    Position = Vector3.new(-40, 18, 80)
})

-- =============================================================================
-- Create Droppable Pallet
-- =============================================================================
local palletModel = Instance.new("Model")
palletModel.Name = "Pallet1"
palletModel.Parent = interactables

createPart("PostLeft", palletModel, {
    Anchored = true,
    Color = Color3.fromRGB(153, 102, 51),
    Material = Enum.Material.Wood,
    Shape = Enum.PartType.Cylinder,
    Size = Vector3.new(2, 10, 2),
    TopSurface = Enum.SurfaceType.Smooth,
    BottomSurface = Enum.SurfaceType.Smooth,
    Position = Vector3.new(-36, 5, 0)
})

createPart("PostRight", palletModel, {
    Anchored = true,
    Color = Color3.fromRGB(153, 102, 51),
    Material = Enum.Material.Wood,
    Shape = Enum.PartType.Cylinder,
    Size = Vector3.new(2, 10, 2),
    TopSurface = Enum.SurfaceType.Smooth,
    BottomSurface = Enum.SurfaceType.Smooth,
    Position = Vector3.new(-24, 5, 0)
})

createPart("Pallet", palletModel, {
    Anchored = true, -- Start anchored, will be unanchored by script
    Color = Color3.fromRGB(178, 127, 76),
    Material = Enum.Material.Wood,
    Size = Vector3.new(10, 8, 1),
    Position = Vector3.new(-30, 4, 0)
})

-- =============================================================================
-- Create Spawn Locations
-- =============================================================================
local CollectionService = game:GetService("CollectionService")

-- Player Spawns
local playerSpawns = Instance.new("Folder")
playerSpawns.Name = "PlayerSpawns"
playerSpawns.Parent = spawns
local playerSpawnPositions = {
    Vector3.new(-20, 0.5, -20), Vector3.new(20, 0.5, -20), Vector3.new(0, 0.5, 0),
    Vector3.new(-20, 0.5, 20), Vector3.new(20, 0.5, 20)
}
for i, pos in ipairs(playerSpawnPositions) do
    local spawn = Instance.new("SpawnLocation")
    spawn.Name = "PlayerSpawn" .. i
    spawn.Position = pos
    spawn.Parent = playerSpawns
    spawn.Anchored = true
    spawn.Size = Vector3.new(4, 1, 4)
    spawn.Transparency = 0.5
end

-- Generator Spawns
local generatorSpawns = Instance.new("Folder")
generatorSpawns.Name = "GeneratorSpawns"
generatorSpawns.Parent = objectives
local generatorSpawnPositions = {
    Vector3.new(-40, 1, 40), Vector3.new(40, 1, 40), Vector3.new(-40, 1, -40),
    Vector3.new(40, 1, -40), Vector3.new(0, 1, -60)
}
for i, pos in ipairs(generatorSpawnPositions) do
    local genSpawn = createPart("Generator" .. i, generatorSpawns, {
        Anchored = true,
        CanCollide = false,
        Size = Vector3.new(2, 2, 2),
        Position = pos,
        Transparency = 1,
        Color = Color3.fromRGB(255, 255, 0) -- Yellow to see them for now
    })
    CollectionService:AddTag(genSpawn, "Interactable")
    CollectionService:AddTag(genSpawn, "Generator")
end

print("MapBuilder.server.lua: Map generation complete (v2).")
