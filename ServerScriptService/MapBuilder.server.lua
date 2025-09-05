--[[
    MapBuilder.server.lua

    This script programmatically generates the entire map layout at runtime.
    This version uses explicit property tables for each part and sets
    position explicitly to ensure correctness.
]]

local Workspace = game:GetService("Workspace")
local CollectionService = game:GetService("CollectionService")

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
local baseplate = createPart("Baseplate", Workspace, {
    Anchored = true,
    Color = Color3.fromRGB(99, 95, 99),
    Locked = true,
    Size = Vector3.new(2048, 20, 2048)
})
baseplate.Position = Vector3.new(0, -10, 0)

-- =============================================================================
-- Create Simple Walls
-- =============================================================================
local walls = Instance.new("Folder")
walls.Name = "Walls"
walls.Parent = map

local wall1 = createPart("Wall1", walls, {
    Anchored = true,
    Color = Color3.fromRGB(128, 128, 128),
    Material = Enum.Material.Concrete,
    TopSurface = Enum.SurfaceType.Smooth,
    BottomSurface = Enum.SurfaceType.Smooth,
    Size = Vector3.new(100, 20, 4)
})
wall1.Position = Vector3.new(0, 10, 50)

local wall2 = createPart("Wall2", walls, {
    Anchored = true,
    Color = Color3.fromRGB(128, 128, 128),
    Material = Enum.Material.Concrete,
    TopSurface = Enum.SurfaceType.Smooth,
    BottomSurface = Enum.SurfaceType.Smooth,
    Size = Vector3.new(4, 20, 50)
})
wall2.Position = Vector3.new(-50, 10, 0)

local wall3 = createPart("Wall3", walls, {
    Anchored = true,
    Color = Color3.fromRGB(128, 128, 128),
    Material = Enum.Material.Concrete,
    TopSurface = Enum.SurfaceType.Smooth,
    BottomSurface = Enum.SurfaceType.Smooth,
    Size = Vector3.new(4, 20, 50)
})
wall3.Position = Vector3.new(50, 10, 0)


-- =============================================================================
-- Create Vaultable Window
-- =============================================================================
local windowModel = Instance.new("Model")
windowModel.Name = "WindowVault1"
windowModel.Parent = interactables

local wallLeft = createPart("WallLeft", windowModel, {
    Anchored = true,
    Color = Color3.fromRGB(128, 128, 128),
    Material = Enum.Material.Concrete,
    TopSurface = Enum.SurfaceType.Smooth,
    BottomSurface = Enum.SurfaceType.Smooth,
    Size = Vector3.new(5, 20, 2)
})
wallLeft.Position = Vector3.new(-45.5, 10, 80)

local wallRight = createPart("WallRight", windowModel, {
    Anchored = true,
    Color = Color3.fromRGB(128, 128, 128),
    Material = Enum.Material.Concrete,
    TopSurface = Enum.SurfaceType.Smooth,
    BottomSurface = Enum.SurfaceType.Smooth,
    Size = Vector3.new(5, 20, 2)
})
wallRight.Position = Vector3.new(-34.5, 10, 80)

local wallTop = createPart("WallTop", windowModel, {
    Anchored = true,
    Color = Color3.fromRGB(128, 128, 128),
    Material = Enum.Material.Concrete,
    TopSurface = Enum.SurfaceType.Smooth,
    BottomSurface = Enum.SurfaceType.Smooth,
    Size = Vector3.new(6, 4, 2)
})
wallTop.Position = Vector3.new(-40, 18, 80)

-- =============================================================================
-- Create Droppable Pallet
-- =============================================================================
local palletModel = Instance.new("Model")
palletModel.Name = "Pallet1"
palletModel.Parent = interactables

local postLeft = createPart("PostLeft", palletModel, {
    Anchored = true,
    Color = Color3.fromRGB(153, 102, 51),
    Material = Enum.Material.Wood,
    Shape = Enum.PartType.Cylinder,
    Size = Vector3.new(2, 10, 2),
    TopSurface = Enum.SurfaceType.Smooth,
    BottomSurface = Enum.SurfaceType.Smooth
})
postLeft.Position = Vector3.new(-36, 5, 0)

local postRight = createPart("PostRight", palletModel, {
    Anchored = true,
    Color = Color3.fromRGB(153, 102, 51),
    Material = Enum.Material.Wood,
    Shape = Enum.PartType.Cylinder,
    Size = Vector3.new(2, 10, 2),
    TopSurface = Enum.SurfaceType.Smooth,
    BottomSurface = Enum.SurfaceType.Smooth
})
postRight.Position = Vector3.new(-24, 5, 0)

local pallet = createPart("Pallet", palletModel, {
    Anchored = true,
    Color = Color3.fromRGB(178, 127, 76),
    Material = Enum.Material.Wood,
    Size = Vector3.new(10, 8, 1)
})
pallet.Position = Vector3.new(-30, 4, 0)

-- =============================================================================
-- Create Spawn Locations
-- =============================================================================
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
    spawn.Anchored = true
    spawn.Size = Vector3.new(4, 1, 4)
    spawn.Transparency = 0.5
    spawn.Parent = playerSpawns
    spawn.Position = pos
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
        Transparency = 0.5,
        Color = Color3.fromRGB(255, 255, 0)
    })
    genSpawn.Position = pos
    CollectionService:AddTag(genSpawn, "Interactable")
    CollectionService:AddTag(genSpawn, "Generator")
end

print("MapBuilder.server.lua: Map generation complete (v3).")
