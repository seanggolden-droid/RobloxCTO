--[[ WorldBuilder: Auto-constructs the entire Monster Mash Simulator 3D world from code.
All parts anchored + collision-enabled. Each zone wrapped in pcall() for resilience.
Folder structure: Workspace > Zones > [ZoneName] > [Structure folders] ]]

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local WorldBuilder = {}

-- Reference to CollectEnergy remote event for ClickDetectors
local CollectEnergyRemote = nil

-- Zone positions (x-axis linear progression)
local ZONES = {
	spawn = Vector3.new(0, 0, 0),
	desert = Vector3.new(1000, 0, 0),
	cyber = Vector3.new(2000, 0, 0),
}

-- Helper: create a part with common props
local function NewPart(name, size, position, color, material, transparency, canCollide, parent)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Position = position
	p.Color = color
	p.Material = material or Enum.Material.Plastic
	p.Transparency = transparency or 0
	p.Anchored = true
	p.CanCollide = canCollide ~= false
	p.Parent = parent
	return p
end

local function NewFolder(name, parent)
	local f = Instance.new("Folder")
	f.Name = name
	f.Parent = parent
	return f
end

--[[ 1. Base Terrain (2000x500 total) ]]
function WorldBuilder.BuildTerrain()
	local zonesFolder = NewFolder("Zones", Workspace)

	-- Overall baseplate
	NewPart("Baseplate", Vector3.new(2100, 1, 600), Vector3.new(1000, -0.5, 0),
		Color3.fromRGB(100, 180, 60), Enum.Material.Grass, 0, true, zonesFolder)

	-- Spawn marble floor
	NewPart("SpawnFloor", Vector3.new(400, 1, 500), ZONES.spawn + Vector3.new(0, 0.5, 0),
		Color3.fromRGB(210, 200, 190), Enum.Material.Marble, 0, true, zonesFolder)

	-- Desert sand floor
	NewPart("DesertFloor", Vector3.new(400, 1, 500), ZONES.desert + Vector3.new(0, 0.5, 0),
		Color3.fromRGB(194, 150, 80), Enum.Material.Sand, 0, true, zonesFolder)

	-- Cyber metal floor
	NewPart("CyberFloor", Vector3.new(400, 1, 500), ZONES.cyber + Vector3.new(0, 0.5, 0),
		Color3.fromRGB(15, 15, 35), Enum.Material.Metal, 0, true, zonesFolder)

	-- Connecting paths between zones
	for _, z in ipairs({ 200, 300, 700, 800, 1200, 1300, 1700, 1800 }) do
		NewPart("Path", Vector3.new(15, 1, 50), Vector3.new(z, 0.5, 0),
			Color3.fromRGB(160, 140, 110), Enum.Material.Slate, 0, true, zonesFolder)
	end
end

--[[ 2. Spawn Zone Structures ]]
function WorldBuilder.BuildSpawnZone()
	local spawnFolder = NewFolder("Spawn", Workspace:FindFirstChild("Zones") or Workspace)

	-- Spawn Location
	local spawnLoc = Instance.new("SpawnLocation")
	spawnLoc.Name = "PlayerSpawn"
	spawnLoc.Size = Vector3.new(10, 0.5, 10)
	spawnLoc.Position = ZONES.spawn + Vector3.new(0, 0.25, 0)
	spawnLoc.BrickColor = BrickColor.new("Bright yellow")
	spawnLoc.Anchored = true
	spawnLoc.CanCollide = true
	spawnLoc.Transparency = 0.3
	spawnLoc.Parent = spawnFolder

	-- Great Incubator (octagonal tiered platform)
	local incFolder = NewFolder("GreatIncubator", spawnFolder)
	for i = 1, 4 do
		local size = 40 - (i - 1) * 6
		NewPart("Tier" .. i, Vector3.new(size, 2.5, size), ZONES.spawn + Vector3.new(0, 1.5 + (i - 1) * 3, 0),
			Color3.fromRGB(210 + i * 10, 190, 150), Enum.Material.Marble, 0, true, incFolder)
	end

	-- Floating glass egg
	local egg = NewPart("FloatingEgg", Vector3.new(20, 25, 20), ZONES.spawn + Vector3.new(0, 16, 0),
		Color3.fromRGB(180, 220, 255), Enum.Material.Glass, 0.3, false, incFolder)
	egg.Shape = Enum.PartType.Ball
	local eggAtt = Instance.new("Attachment", egg)
	Instance.new("ParticleEmitter", eggAtt)
	eggAtt.ParticleEmitter.Rate = 20
	eggAtt.ParticleEmitter.Lifetime = NumberRange.new(0.5, 1)
	eggAtt.ParticleEmitter.Speed = NumberRange.new(2, 5)
	eggAtt.ParticleEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0))
	eggAtt.ParticleEmitter.SpreadAngle = NumberRange.new(0, 360)
	eggAtt.ParticleEmitter.Size = NumberSequence.new({NumberKeypoint.new(0, 0.5), NumberKeypoint.new(1, 0)})
	eggAtt.ParticleEmitter.Transparency = NumberSequence.new(0.3)
	eggAtt.ParticleEmitter.Enabled = true

	-- Gold edging ring
	NewPart("GoldRing", Vector3.new(42, 0.5, 42), ZONES.spawn + Vector3.new(0, 1, 0),
		Color3.fromRGB(255, 200, 50), Enum.Material.Neon, 0.5, true, incFolder)

	-- 3 Hatching pedestals around base
	for i = 1, 3 do
		local a = (i - 1) * (math.pi * 2 / 3)
		local px = math.cos(a) * 26
		local pz = math.sin(a) * 26
		NewPart("Pedestal" .. i, Vector3.new(3, 4, 3), ZONES.spawn + Vector3.new(px, 2, pz),
			Color3.fromRGB(180, 160, 100), Enum.Material.Marble, 0, true, incFolder)
		NewPart("PedestalGlow" .. i, Vector3.new(1, 0.5, 1), ZONES.spawn + Vector3.new(px, 4.5, pz),
			Color3.fromRGB(255, 200, 50), Enum.Material.Neon, 0, false, incFolder)
	end

	-- Portal Plaza (3 arches, north side)
	local portalFolder = NewFolder("PortalPlaza", spawnFolder)
	for i, data in ipairs({
		{ name = "ForestPortal", color = Color3.fromRGB(0, 200, 0) },
		{ name = "DesertPortal", color = Color3.fromRGB(255, 150, 0) },
		{ name = "CyberPortal", color = Color3.fromRGB(0, 200, 255) },
	}) do
		local arch = NewPart(data.name, Vector3.new(15, 20, 5), ZONES.spawn + Vector3.new(-30 + (i - 1) * 30, 10, 185),
			Color3.fromRGB(160, 140, 120), Enum.Material.Stone, 0, true, portalFolder)
		NewPart(data.name .. "Barrier", Vector3.new(10, 15, 0.5), ZONES.spawn + Vector3.new(-30 + (i - 1) * 30, 10, 188),
			data.color, Enum.Material.Neon, 0.3, false, portalFolder)
	end

	-- Shop NPC Stalls
	local shopFolder = NewFolder("Shops", spawnFolder)
	for i = 1, 2 do
		local sx = -40 + (i - 1) * 80
		local stall = NewPart("Stall" .. i, Vector3.new(15, 12, 10), ZONES.spawn + Vector3.new(sx, 6, -130),
			i == 1 and Color3.fromRGB(140, 100, 60) or Color3.fromRGB(200, 200, 200),
			i == 1 and Enum.Material.Wood or Enum.Material.Marble, 0, true, shopFolder)
		NewPart("Counter" .. i, Vector3.new(15, 2, 3), ZONES.spawn + Vector3.new(sx, 7, -126),
			Color3.fromRGB(100, 80, 50), Enum.Material.Wood, 0, true, shopFolder)
		NewPart("Banner" .. i, Vector3.new(6, 8, 0.5), ZONES.spawn + Vector3.new(sx, 10, -135),
			Color3.fromRGB(200, 50, 50), Enum.Material.Fabric, 0, false, shopFolder)
	end
end

--[[ 3. VIP Lounge (40x40, checks VIP status) ]]
function WorldBuilder.BuildVIPLounge()
	local parent = Workspace:FindFirstChild("Zones") or Workspace
	local vipFolder = NewFolder("VIPLounge", parent)

	-- Lounge floor (gold/marble)
	NewPart("VIPFloor", Vector3.new(40, 1, 40), ZONES.spawn + Vector3.new(180, 0.5, 0),
		Color3.fromRGB(200, 180, 100), Enum.Material.Marble, 0, true, vipFolder)

	-- Walls (glass with gold trim)
	for _, wall in ipairs({
		{ s = Vector3.new(40, 12, 1), p = ZONES.spawn + Vector3.new(180, 6, 20.5) },
		{ s = Vector3.new(40, 12, 1), p = ZONES.spawn + Vector3.new(180, 6, -20.5) },
		{ s = Vector3.new(1, 12, 40), p = ZONES.spawn + Vector3.new(200.5, 6, 0) },
		{ s = Vector3.new(1, 12, 40), p = ZONES.spawn + Vector3.new(159.5, 6, 0) },
	}) do
		NewPart("VIPWall", wall.s, wall.p, Color3.fromRGB(180, 170, 120), Enum.Material.Glass, 0.4, true, vipFolder)
	end

	-- Entry barrier gate (checks VIP status via ClickDetector)
	local gate = NewPart("VIPGate", Vector3.new(5, 12, 1), ZONES.spawn + Vector3.new(159.5, 6, 0),
		Color3.fromRGB(255, 200, 0), Enum.Material.Neon, 0.3, true, vipFolder)
	local cd = Instance.new("ClickDetector", gate)
	cd.MaxActivationDistance = 10

	-- Golden crystal (3x energy)
	local gCrystal = NewPart("VIPEnergyCrystal", Vector3.new(4, 8, 4), ZONES.spawn + Vector3.new(180, 5, 0),
		Color3.fromRGB(255, 215, 0), Enum.Material.Neon, 0, true, vipFolder)
	local crystalCD = Instance.new("ClickDetector", gCrystal)
	crystalCD.MaxActivationDistance = 8

	-- Purple/gold furniture
	NewPart("VIPThrone", Vector3.new(6, 6, 6), ZONES.spawn + Vector3.new(190, 3, 10),
		Color3.fromRGB(128, 0, 128), Enum.Material.SmoothPlastic, 0, true, vipFolder)
	NewPart("VIPTable", Vector3.new(8, 1, 4), ZONES.spawn + Vector3.new(170, 1.5, -10),
		Color3.fromRGB(255, 200, 50), Enum.Material.Marble, 0, true, vipFolder)

	-- VIP Incubator (smaller, gold)
	NewPart("VIPIncubatorBase", Vector3.new(8, 2, 8), ZONES.spawn + Vector3.new(195, 2, -5),
		Color3.fromRGB(255, 200, 50), Enum.Material.Marble, 0, true, vipFolder)
	NewPart("VIPIncubatorCrystal", Vector3.new(3, 5, 3), ZONES.spawn + Vector3.new(195, 5.5, -5),
		Color3.fromRGB(200, 0, 200), Enum.Material.Neon, 0, false, vipFolder)
end

--[[ 4. Premium Shop (The Gilded Vault) ]]
function WorldBuilder.BuildPremiumShop()
	local parent = Workspace:FindFirstChild("Zones") or Workspace
	local shopFolder = NewFolder("PremiumShop", parent)

	-- Building structure (30x25x20 glass+gold)
	NewPart("ShopFloor", Vector3.new(30, 1, 25), ZONES.spawn + Vector3.new(-180, 0.5, 100),
		Color3.fromRGB(200, 180, 100), Enum.Material.Marble, 0, true, shopFolder)
	NewPart("ShopRoof", Vector3.new(30, 1, 25), ZONES.spawn + Vector3.new(-180, 20, 100),
		Color3.fromRGB(200, 180, 100), Enum.Material.Marble, 0, true, shopFolder)

	-- 4 glass walls
	for _, w in ipairs({
		{ s = Vector3.new(30, 20, 1), p = ZONES.spawn + Vector3.new(-180, 10, 112.5) },
		{ s = Vector3.new(30, 20, 1), p = ZONES.spawn + Vector3.new(-180, 10, 87.5) },
		{ s = Vector3.new(1, 20, 25), p = ZONES.spawn + Vector3.new(-165.5, 10, 100) },
		{ s = Vector3.new(1, 20, 25), p = ZONES.spawn + Vector3.new(-194.5, 10, 100) },
	}) do
		NewPart("ShopWall", w.s, w.p, Color3.fromRGB(180, 170, 120), Enum.Material.Glass, 0.3, true, shopFolder)
	end

	-- Gold trim pillars at corners
	for _, c in ipairs({
		Vector3.new(-165.5, 10, 112.5), Vector3.new(-194.5, 10, 112.5),
		Vector3.new(-165.5, 10, 87.5), Vector3.new(-194.5, 10, 87.5),
	}) do
		NewPart("GoldPillar", Vector3.new(2, 20, 2), c, Color3.fromRGB(255, 200, 50),
			Enum.Material.Neon, 0, true, shopFolder)
	end

	-- Display shelves
	for i = 1, 3 do
		NewPart("Shelf" .. i, Vector3.new(6, 3, 3), ZONES.spawn + Vector3.new(-175 + (i - 1) * 10, 5, 105),
			Color3.fromRGB(180, 140, 60), Enum.Material.Wood, 0, true, shopFolder)
		-- Item on shelf (glowing orb)
		NewPart("DisplayItem" .. i, Vector3.new(1.5, 1.5, 1.5), ZONES.spawn + Vector3.new(-175 + (i - 1) * 10, 7, 105),
			Color3.fromRGB(255, 50 + i * 50, 0), Enum.Material.Neon, 0, false, shopFolder)
	end
end

--[[ 5. Billboard Frames (4 around spawn) ]]
function WorldBuilder.BuildBillboardFrames()
	local parent = Workspace:FindFirstChild("Zones") or Workspace
	local bbFolder = NewFolder("BillboardFrames", parent)

	local positions = {
		Vector3.new(150, 8, -120),
		Vector3.new(-150, 8, -120),
		Vector3.new(150, 8, 120),
		Vector3.new(-150, 8, 120),
	}

	for i, pos in ipairs(positions) do
		local frame = NewPart("Billboard_" .. i, Vector3.new(15, 10, 2), pos,
			Color3.fromRGB(50, 50, 70), Enum.Material.Metal, 0, true, bbFolder)
		-- Neon border
		NewPart("BillboardBorder_" .. i, Vector3.new(15.5, 10.5, 0.5), pos,
			Color3.fromRGB(255, 200, 50), Enum.Material.Neon, 0.5, false, bbFolder)
		-- SurfaceGui for ad display
		local sg = Instance.new("SurfaceGui")
		sg.Face = Enum.NormalId.Front
		sg.Parent = frame
		Instance.new("TextLabel", sg)
		sg.TextLabel.Size = UDim2.new(1, 0, 1, 0)
		sg.TextLabel.BackgroundTransparency = 1
		sg.TextLabel.Text = "✨ AD SPACE ✨"
		sg.TextLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
		sg.TextLabel.TextScaled = true
		sg.TextLabel.Font = Enum.Font.GothamBold
		sg.TextLabel.TextStrokeTransparency = 0.3
	end
end

--[[ 6. Zone 2: Scorched Desert (x=1000) ]]
function WorldBuilder.BuildDesertZone()
	local parent = Workspace:FindFirstChild("Zones") or Workspace
	local dFolder = NewFolder("ScorchedDesert", parent)

	-- Sand dunes
	for i = 1, 6 do
		NewPart("Dune" .. i, Vector3.new(50 + math.random(30), 6 + math.random(14), 50 + math.random(30)),
			ZONES.desert + Vector3.new(math.random(-160, 160), 3 + math.random(5), math.random(-160, 160)),
			Color3.fromRGB(194, 150, 80), Enum.Material.Sand, 0, true, dFolder)
	end

	-- Sandstone Incubator
	NewPart("DesertIncubator", Vector3.new(20, 4, 20), ZONES.desert + Vector3.new(0, 2, 100),
		Color3.fromRGB(180, 130, 70), Enum.Material.Sandstone, 0, true, dFolder)
	NewPart("DesertIncubatorCrystal", Vector3.new(3, 7, 3), ZONES.desert + Vector3.new(0, 7.5, 100),
		Color3.fromRGB(255, 100, 0), Enum.Material.Neon, 0, false, dFolder)

	-- The Great Pyramid
	NewPart("PyramidBase", Vector3.new(80, 12, 80), ZONES.desert + Vector3.new(0, 6, -50),
		Color3.fromRGB(180, 140, 80), Enum.Material.Sandstone, 0, true, dFolder)
	NewPart("PyramidMid", Vector3.new(50, 20, 50), ZONES.desert + Vector3.new(0, 22, -50),
		Color3.fromRGB(190, 150, 90), Enum.Material.Sandstone, 0, true, dFolder)
	NewPart("PyramidTop", Vector3.new(25, 25, 25), ZONES.desert + Vector3.new(0, 44.5, -50),
		Color3.fromRGB(200, 160, 100), Enum.Material.Sandstone, 0, true, dFolder)
	NewPart("PyramidApex", Vector3.new(4, 8, 4), ZONES.desert + Vector3.new(0, 61, -50),
		Color3.fromRGB(255, 50, 0), Enum.Material.Neon, 0, false, dFolder)

	-- Bone arena pit
	NewPart("ArenaPit", Vector3.new(50, 1, 50), ZONES.desert + Vector3.new(0, 0.5, -150),
		Color3.fromRGB(150, 120, 80), Enum.Material.Sand, 0, true, dFolder)
	for i = 1, 4 do
		NewPart("BoneDecor" .. i, Vector3.new(2, 2 + math.random(4), 2), ZONES.desert + Vector3.new(-15 + (i - 1) * 10, 1.5 + math.random(2), -150),
			Color3.fromRGB(200, 180, 150), Enum.Material.Marble, 0, true, dFolder)
	end

	-- Cacti
	for i = 1, 5 do
		NewPart("Cactus" .. i, Vector3.new(2 + math.random(2), 6 + math.random(10), 2 + math.random(2)),
			ZONES.desert + Vector3.new(math.random(-160, 160), 3, math.random(-160, 160)),
			Color3.fromRGB(40, 140, 20), Enum.Material.SmoothPlastic, 0, true, dFolder)
	end

	-- Orange Energy Crystals (with ClickDetectors)
	for i = 1, 10 do
		local sz = 2 + math.random() * 4
		local x = math.random(-160, 160)
		local z = math.random(-160, 160)
		local crystal = NewPart("DesertCrystal_" .. i, Vector3.new(sz, sz * 1.5, sz), ZONES.desert + Vector3.new(x, sz * 0.75, z),
			Color3.fromRGB(255, 100, 0), Enum.Material.Neon, 0, true, dFolder)
		crystal.Orientation = Vector3.new(math.random(-30, 30), math.random(0, 360), math.random(-30, 30))
		local cd = Instance.new("ClickDetector", crystal)
		cd.MaxActivationDistance = 12
	end

	-- NPC spawn markers
	for i = 1, 8 do
		NewPart("NPCSpawn_" .. i, Vector3.new(5, 0.5, 5), ZONES.desert + Vector3.new(math.random(-160, 160), 0.25, math.random(-160, 160)),
			Color3.fromRGB(255, 0, 0), Enum.Material.Neon, 1, false, dFolder)
	end
end

--[[ 7. Zone 3: Cyber City (x=2000) ]]
function WorldBuilder.BuildCyberZone()
	local parent = Workspace:FindFirstChild("Zones") or Workspace
	local cFolder = NewFolder("CyberCity", parent)

	-- Neon grid lines
	for i = -3, 3 do
		NewPart("GridH_" .. i, Vector3.new(350, 0.2, 1), ZONES.cyber + Vector3.new(0, 0.5, i * 50),
			Color3.fromRGB(0, 200, 255), Enum.Material.Neon, 0.5, false, cFolder)
		NewPart("GridV_" .. i, Vector3.new(1, 0.2, 350), ZONES.cyber + Vector3.new(i * 50, 0.5, 0),
			Color3.fromRGB(255, 0, 200), Enum.Material.Neon, 0.5, false, cFolder)
	end

	-- Digital Citadel (tower)
	NewPart("CitadelBase", Vector3.new(60, 15, 60), ZONES.cyber + Vector3.new(0, 7.5, 0),
		Color3.fromRGB(10, 10, 35), Enum.Material.Metal, 0, true, cFolder)
	NewPart("CitadelMid", Vector3.new(40, 30, 40), ZONES.cyber + Vector3.new(0, 30, 0),
		Color3.fromRGB(20, 20, 55), Enum.Material.Glass, 0.2, true, cFolder)
	NewPart("CitadelSpire", Vector3.new(15, 40, 15), ZONES.cyber + Vector3.new(0, 65, 0),
		Color3.fromRGB(30, 30, 75), Enum.Material.Glass, 0.1, true, cFolder)
	-- Neon rings on citadel
	NewPart("NeonRingBottom", Vector3.new(65, 1, 65), ZONES.cyber + Vector3.new(0, 15, 0),
		Color3.fromRGB(255, 0, 255), Enum.Material.Neon, 0.3, false, cFolder)
	NewPart("NeonRingMid", Vector3.new(50, 1, 50), ZONES.cyber + Vector3.new(0, 35, 0),
		Color3.fromRGB(0, 255, 255), Enum.Material.Neon, 0.3, false, cFolder)
	NewPart("NeonRingTop", Vector3.new(25, 1, 25), ZONES.cyber + Vector3.new(0, 55, 0),
		Color3.fromRGB(255, 200, 0), Enum.Material.Neon, 0.3, false, cFolder)
	-- Neon rings are cylinders
	for _, r in ipairs({ cFolder:GetChildren() }) do
		if r.Name:find("NeonRing") then
			r.Shape = Enum.PartType.Cylinder
		end
	end

	-- Tech Lab Incubator (glass capsule)
	NewPart("TechIncubatorBase", Vector3.new(12, 2, 12), ZONES.cyber + Vector3.new(80, 1, 80),
		Color3.fromRGB(30, 30, 55), Enum.Material.Metal, 0, true, cFolder)
	local techGlass = NewPart("TechIncubatorGlass", Vector3.new(8, 10, 8), ZONES.cyber + Vector3.new(80, 7, 80),
		Color3.fromRGB(0, 200, 255), Enum.Material.Glass, 0.4, false, cFolder)
	local techCD = Instance.new("ClickDetector", techGlass)
	techCD.MaxActivationDistance = 10

	-- Holographic arena
	NewPart("HoloArenaFloor", Vector3.new(50, 1, 50), ZONES.cyber + Vector3.new(0, 0.5, -150),
		Color3.fromRGB(0, 100, 200), Enum.Material.Neon, 0.3, true, cFolder)
	for i = 1, 8 do
		local a = (i - 1) * (math.pi * 2 / 8)
		NewPart("HoloPillar_" .. i, Vector3.new(1, 10, 1), ZONES.cyber + Vector3.new(math.cos(a) * 25, 5, -150 + math.sin(a) * 25),
			Color3.fromRGB(0, 200, 255), Enum.Material.Neon, 0.2, false, cFolder)
	end

	-- Blue Energy Crystals (with ClickDetectors)
	for i = 1, 10 do
		local sz = 2 + math.random() * 4
		local x = math.random(-160, 160)
		local z = math.random(-160, 160)
		local crystal = NewPart("CyberCrystal_" .. i, Vector3.new(sz, sz * 1.5, sz), ZONES.cyber + Vector3.new(x, sz * 0.75, z),
			Color3.fromRGB(0, 200, 255), Enum.Material.Neon, 0, true, cFolder)
		crystal.Orientation = Vector3.new(math.random(-30, 30), math.random(0, 360), math.random(-30, 30))
		-- Square/cuboid shape for cyber
		local cd = Instance.new("ClickDetector", crystal)
		cd.MaxActivationDistance = 12
	end

	-- Floating screens
	for i = 1, 4 do
		local screen = NewPart("FloatingScreen_" .. i, Vector3.new(8, 5, 0.5), ZONES.cyber + Vector3.new(math.random(-140, 140), 8 + math.random(8), math.random(-140, 140)),
			Color3.fromRGB(0, 100, 200), Enum.Material.Neon, 0, false, cFolder)
		local sg = Instance.new("SurfaceGui", screen)
		sg.Face = Enum.NormalId.Front
		Instance.new("TextLabel", sg)
		sg.TextLabel.Size = UDim2.new(1, 0, 1, 0)
		sg.TextLabel.BackgroundTransparency = 1
		sg.TextLabel.Text = "MONSTER DATA"
		sg.TextLabel.TextColor3 = Color3.fromRGB(0, 255, 255)
		sg.TextLabel.TextScaled = true
		sg.TextLabel.Font = Enum.Font.GothamBold
	end

	-- Cables
	for i = 1, 4 do
		NewPart("Cable_" .. i, Vector3.new(2 + math.random(2), 1, 60 + math.random(40)), ZONES.cyber + Vector3.new(math.random(-140, 140), 0.5, math.random(-140, 140)),
			Color3.fromRGB(20, 20, 20), Enum.Material.Metal, 0, true, cFolder)
	end

	-- NPC spawn platforms
	for i = 1, 10 do
		NewPart("NPCSpawn_" .. i, Vector3.new(20, 4, 20), ZONES.cyber + Vector3.new(math.random(-140, 140), 2, math.random(-140, 140)),
			Color3.fromRGB(30, 30, 55), Enum.Material.Metal, 0, true, cFolder)
		NewPart("NPCSpawnGlow_" .. i, Vector3.new(18, 0.5, 18), ZONES.cyber + Vector3.new(math.random(-140, 140), 4.25, math.random(-140, 140)),
			Color3.fromRGB(0, 200, 255), Enum.Material.Neon, 0.5, false, cFolder)
	end
end

--[[ 8. Battle Arenas (one per zone) ]]
function WorldBuilder.BuildBattleArenas()
	local parent = Workspace:FindFirstChild("Zones") or Workspace
	local arenaFolder = NewFolder("BattleArenas", parent)

	local arenaData = {
		{ name = "ForestArena", pos = Vector3.new(0, 0, 200) },
		{ name = "DesertArena", pos = ZONES.desert + Vector3.new(0, 0, 200) },
		{ name = "CyberArena", pos = ZONES.cyber + Vector3.new(0, 0, 200) },
	}

	for _, data in ipairs(arenaData) do
		local af = NewFolder(data.name, arenaFolder)

		-- Circular floor
		NewPart("Floor", Vector3.new(100, 1, 100), data.pos + Vector3.new(0, 0.5, 0),
			Color3.fromRGB(60, 60, 80), Enum.Material.Slate, 0, true, af)

		-- Wave barrier pillars (circular placement)
		for i = 1, 12 do
			local a = (i - 1) * (math.pi * 2 / 12)
			NewPart("BarrierPillar_" .. i, Vector3.new(2, 15, 2), data.pos + Vector3.new(math.cos(a) * 48, 7.5, math.sin(a) * 48),
				Color3.fromRGB(50, 150, 255), Enum.Material.Neon, 0.3, false, af)
		end

		-- Entrance gate
		NewPart("EntranceGate", Vector3.new(10, 15, 1), data.pos + Vector3.new(0, 7.5, 50),
			Color3.fromRGB(50, 150, 255), Enum.Material.Neon, 0.2, true, af)

		-- Central NPC spawn
		NewPart("CenterNPCSpawn", Vector3.new(5, 0.5, 5), data.pos + Vector3.new(0, 0.25, 0),
			Color3.fromRGB(255, 50, 50), Enum.Material.Neon, 0.5, false, af)

		-- Timer BillboardGui
		local bb = Instance.new("BillboardGui")
		bb.Name = "TimerDisplay"
		bb.Size = UDim2.new(0, 120, 0, 50)
		bb.StudsOffset = Vector3.new(0, 25, 0)
		bb.Parent = af
		Instance.new("TextLabel", bb)
		bb.TextLabel.Size = UDim2.new(1, 0, 1, 0)
		bb.TextLabel.BackgroundTransparency = 1
		bb.TextLabel.Text = "Wave 1/10"
		bb.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		bb.TextLabel.TextScaled = true
		bb.TextLabel.Font = Enum.Font.GothamBold
		bb.TextLabel.TextStrokeTransparency = 0.3
	end
end

--[[ 9. Progression Gates (between zones) ]]
function WorldBuilder.BuildProgressionGates()
	local parent = Workspace:FindFirstChild("Zones") or Workspace
	local gateFolder = NewFolder("ProgressionGates", parent)

	local gates = {
		{ name = "GateToDesert", pos = Vector3.new(500, 10, 0), cost = 5000, color = Color3.fromRGB(255, 150, 0), zoneId = "zone2_desert" },
		{ name = "GateToCyber", pos = Vector3.new(1500, 10, 0), cost = 50000, color = Color3.fromRGB(0, 200, 255), zoneId = "zone3_cyber" },
	}

	for _, gate in ipairs(gates) do
		local gf = NewFolder(gate.name, gateFolder)

		local barrier = NewPart("Barrier", Vector3.new(50, 100, 10), gate.pos,
			gate.color, Enum.Material.Neon, 0.4, true, gf)

		-- Side pillars
		for _, x in ipairs({ -28, 28 }) do
			NewPart("Pillar", Vector3.new(4, 100, 10), gate.pos + Vector3.new(x, 0, 0),
				Color3.fromRGB(80, 80, 100), Enum.Material.Stone, 0, true, gf)
		end

		-- BillboardGui cost display
		local bb = Instance.new("BillboardGui")
		bb.Name = "CostDisplay"
		bb.Size = UDim2.new(0, 150, 0, 50)
		bb.StudsOffset = Vector3.new(0, 60, 0)
		bb.Adornee = barrier
		bb.Parent = gf
		Instance.new("TextLabel", bb)
		bb.TextLabel.Size = UDim2.new(1, 0, 1, 0)
		bb.TextLabel.BackgroundTransparency = 1
		bb.TextLabel.Text = "🔒 " .. tostring(gate.cost) .. " Essence"
		bb.TextLabel.TextColor3 = gate.color
		bb.TextLabel.TextScaled = true
		bb.TextLabel.Font = Enum.Font.GothamBold
		bb.TextLabel.TextStrokeTransparency = 0.3

		-- ClickDetector for gate interaction
		local cd = Instance.new("ClickDetector", barrier)
		cd.MaxActivationDistance = 15
	end
end

--[[ 10. Energy Crystals (spawn zone only, green) ]]
function WorldBuilder.BuildSpawnCrystals()
	local parent = Workspace:FindFirstChild("Zones") or Workspace
	local crystalFolder = NewFolder("SpawnCrystals", parent)

	-- 5 crystals around spawn
	local positions = {
		Vector3.new(100, 0, -100), Vector3.new(-100, 0, -100),
		Vector3.new(100, 0, 100), Vector3.new(-100, 0, 100),
		Vector3.new(0, 0, -150),
	}
	for i, pos in ipairs(positions) do
		local sz = 2 + (i % 3) * 2 -- 2, 4, 6, 2, 4
		local crystal = NewPart("SpawnCrystal_" .. i, Vector3.new(sz, sz * 1.5, sz), ZONES.spawn + Vector3.new(pos.X, sz * 0.75, pos.Z),
			Color3.fromRGB(0, 255, 0), Enum.Material.Neon, 0, true, crystalFolder)
		crystal.Orientation = Vector3.new(math.random(-30, 30), math.random(0, 360), math.random(-30, 30))

		local cd = Instance.new("ClickDetector", crystal)
		cd.MaxActivationDistance = 12
	end
end

--[[ 11. Setup Lighting & Atmosphere ]]
function WorldBuilder.SetupLighting()
	local lighting = game:GetService("Lighting")
	lighting.ClockTime = 14
	lighting.Brightness = 2
	lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
	lighting.GlobalShadows = true
	lighting.Ambient = Color3.fromRGB(80, 80, 100)
	lighting.FogEnd = 800
	lighting.FogColor = Color3.fromRGB(150, 170, 200)
end

--[[ Wire ClickDetectors to game systems ]]
function WorldBuilder.WireClickDetectors()
	local crystalFolder = Workspace:FindFirstChild("Zones")
	if not crystalFolder then return end

	local CollectEnergy = ReplicatedStorage:FindFirstChild("MonsterMash"):FindFirstChild("RemoteEvents"):FindFirstChild("CollectEnergy")
	if not CollectEnergy then return end

	local function wireCrystalClick(crystalPart)
		local cd = crystalPart:FindFirstChildOfClass("ClickDetector")
		if cd then
			cd.MouseClick:Connect(function(player)
				local size = crystalPart.Size.Magnitude
				local energyAmount = math.floor(size * 2)
				CollectEnergy:FireServer(energyAmount)
			end)
		end
	end

	-- Walk all crystal parts and wire them
	local function walkAndWire(folder)
		for _, child in ipairs(folder:GetChildren()) do
			if child:IsA("Part") and (child.Name:find("Crystal") or child.Name:find("Crystal_")) then
				wireCrystalClick(child)
			elseif child:IsA("Folder") then
				walkAndWire(child)
			end
		end
	end
	walkAndWire(crystalFolder)
end

--[[ Master build function (wrapped in pcall) ]]
function WorldBuilder.BuildAll()
	print("[WorldBuilder] Building world...")

	-- Clear built world but keep Camera, Terrain
	for _, child in ipairs(Workspace:GetChildren()) do
		if child:IsA("Folder") or child:IsA("Model") or (child:IsA("Part") and child.Name ~= "Camera" and not child:IsA("Terrain")) then
			child:Destroy()
		end
	end

	local buildSteps = {
		{ "Lighting", function() WorldBuilder.SetupLighting() end },
		{ "Terrain", function() WorldBuilder.BuildTerrain() end },
		{ "SpawnZone", function() WorldBuilder.BuildSpawnZone() end },
		{ "DesertZone", function() WorldBuilder.BuildDesertZone() end },
		{ "CyberZone", function() WorldBuilder.BuildCyberZone() end },
		{ "SpawnCrystals", function() WorldBuilder.BuildSpawnCrystals() end },
		{ "BattleArenas", function() WorldBuilder.BuildBattleArenas() end },
		{ "ProgressionGates", function() WorldBuilder.BuildProgressionGates() end },
		{ "VIPLounge", function() WorldBuilder.BuildVIPLounge() end },
		{ "PremiumShop", function() WorldBuilder.BuildPremiumShop() end },
		{ "BillboardFrames", function() WorldBuilder.BuildBillboardFrames() end },
	}

	local successes = 0
	local failures = 0

	for _, step in ipairs(buildSteps) do
		local ok, err = pcall(step[2])
		if ok then
			successes += 1
			print(string.format("[WorldBuilder] ✅ Built %s", step[1]))
		else
			failures += 1
			warn(string.format("[WorldBuilder] ❌ Failed to build %s: %s", step[1], tostring(err)))
		end
	end

	-- Wire ClickDetectors after all parts exist
	pcall(function() WorldBuilder.WireClickDetectors() end)

	print(string.format("[WorldBuilder] Build complete: %d succeeded, %d failed", successes, failures))
end

return WorldBuilder