--[[ UIController: Handles all menu openings/closings, stat updates, and UI creation ]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Constants = require(ReplicatedStorage:WaitForChild("MonsterMash"):WaitForChild("Modules"):WaitForChild("Constants"))
local Types = require(ReplicatedStorage:WaitForChild("MonsterMash"):WaitForChild("Modules"):WaitForChild("Types"))

local UIController = {}

-- References
local screenGui = nil
local player = nil
local hudFrame = nil
local currentMenu = nil

-- Color scheme
local COLORS = {
	background = Color3.fromRGB(30, 30, 40),
	panel = Color3.fromRGB(45, 45, 55),
	accent = Color3.fromRGB(255, 200, 50),
	energy = Color3.fromRGB(255, 220, 50),
	essence = Color3.fromRGB(100, 200, 255),
	text = Color3.fromRGB(255, 255, 255),
	textDim = Color3.fromRGB(180, 180, 180),
	rarityCommon = Color3.fromRGB(144, 238, 144),
	rarityRare = Color3.fromRGB(65, 105, 225),
	rarityEpic = Color3.fromRGB(147, 112, 219),
	rarityLegendary = Color3.fromRGB(255, 165, 0),
	rarityMythical = Color3.fromRGB(255, 50, 50),
	button = Color3.fromRGB(60, 60, 80),
	buttonHover = Color3.fromRGB(80, 80, 110),
	danger = Color3.fromRGB(255, 80, 80),
	success = Color3.fromRGB(80, 255, 80),
}

local RARITY_COLORS = {
	Common = COLORS.rarityCommon,
	Rare = COLORS.rarityRare,
	Epic = COLORS.rarityEpic,
	Legendary = COLORS.rarityLegendary,
	Mythical = COLORS.rarityMythical,
}

--[[ Helper: create a UI object ]]
local function new(class, props)
	local obj = Instance.new(class)
	for k, v in pairs(props) do
		obj[k] = v
	end
	return obj
end

--[[ Helper: create rounded frame ]]
local function RoundedFrame(name, size, position, color, parent)
	local frame = new("Frame", {
		Name = name,
		Size = size,
		Position = position,
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Parent = parent,
	})
	local uicorner = new("UICorner", { CornerRadius = UDim.new(0, 8), Parent = frame })
	return frame
end

--[[ Helper: create text label ]]
local function TextLabel(name, size, position, text, textColor, textSize, font, parent)
	return new("TextLabel", {
		Name = name,
		Size = size,
		Position = position,
		BackgroundTransparency = 1,
		Text = text,
		TextColor3 = textColor or COLORS.text,
		TextSize = textSize or 18,
		Font = font or Enum.Font.GothamBold,
		TextScaled = true,
		TextWrapped = true,
		Parent = parent,
	})
end

--[[ Helper: create a text button ]]
local function TextButton(name, size, position, text, color, parent, callback)
	local btn = new("TextButton", {
		Name = name,
		Size = size,
		Position = position,
		BackgroundColor3 = color or COLORS.button,
		BorderSizePixel = 0,
		Text = text,
		TextColor3 = COLORS.text,
		TextSize = 18,
		Font = Enum.Font.GothamBold,
		TextScaled = true,
		AutoButtonColor = false,
		Parent = parent,
	})
	local uicorner = new("UICorner", { CornerRadius = UDim.new(0, 6), Parent = btn })

	-- Hover effects
	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = COLORS.buttonHover }):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = color or COLORS.button }):Play()
	end)
	if callback then
		btn.MouseButton1Click:Connect(callback)
	end
	return btn
end

--[[ Create the HUD ]]
function UIController.CreateHUD()
	-- Main HUD container
	hudFrame = new("Frame", {
		Name = "HUD",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		Parent = screenGui,
	})

	-- Top bar with stats
	local topBar = RoundedFrame("TopBar", UDim2.new(0.5, 0, 0, 50), UDim2.new(0.5, -200, 0, 10), COLORS.panel, hudFrame)
	topBar.BackgroundTransparency = 0.8

	-- Energy counter
	local energyIcon = TextLabel("EnergyIcon", UDim2.new(0, 30, 0, 30), UDim2.new(0, 10, 0, 10), "⚡", COLORS.energy, 20, Enum.Font.GothamBold, topBar)
	local energyLabel = TextLabel("EnergyLabel", UDim2.new(0, 100, 0, 30), UDim2.new(0, 40, 0, 10), "0", COLORS.energy, 20, Enum.Font.GothamBold, topBar)

	-- Essence counter
	local essenceIcon = TextLabel("EssenceIcon", UDim2.new(0, 30, 0, 30), UDim2.new(0, 160, 0, 10), "💎", COLORS.essence, 20, Enum.Font.GothamBold, topBar)
	local essenceLabel = TextLabel("EssenceLabel", UDim2.new(0, 100, 0, 30), UDim2.new(0, 190, 0, 10), "0", COLORS.essence, 20, Enum.Font.GothamBold, topBar)

	-- Rank display
	local rankLabel = TextLabel("RankLabel", UDim2.new(0, 120, 0, 30), UDim2.new(0, 300, 0, 10), "Rank: 0", COLORS.accent, 16, Enum.Font.GothamBold, topBar)

	-- Left side buttons
	local leftButtons = RoundedFrame("LeftButtons", UDim2.new(0, 120, 0, 140), UDim2.new(0, 10, 0.5, -70), Color3.new(0, 0, 0), hudFrame)
	leftButtons.BackgroundTransparency = 0.7

	TextButton("ShopBtn", UDim2.new(0, 100, 0, 35), UDim2.new(0, 10, 0, 10), "🛒 Shop", nil, leftButtons, function()
		UIController.OpenShop()
	end)
	TextButton("InventoryBtn", UDim2.new(0, 100, 0, 35), UDim2.new(0, 10, 0, 52), "📦 Inventory", nil, leftButtons, function()
		UIController.OpenInventory()
	end)
	TextButton("WorldBtn", UDim2.new(0, 100, 0, 35), UDim2.new(0, 10, 0, 94), "🌍 Worlds", nil, leftButtons, function()
		UIController.OpenWorldSelect()
	end)

	-- Right side buttons
	local rightButtons = RoundedFrame("RightButtons", UDim2.new(0, 100, 0, 80), UDim2.new(1, -110, 0.5, -40), Color3.new(0, 0, 0), hudFrame)
	rightButtons.BackgroundTransparency = 0.7

	TextButton("BattleBtn", UDim2.new(0, 80, 0, 35), UDim2.new(0, 10, 0, 10), "⚔️ Battle", COLORS.danger, rightButtons, function()
		UIController.OpenBattleArena()
	end)
	TextButton("HatchBtn", UDim2.new(0, 80, 0, 35), UDim2.new(0, 10, 0, 52), "🥚 Hatch", COLORS.success, rightButtons, function()
		UIController.OpenHatching()
	end)

	-- Bottom — equipped monsters bar
	local bottomBar = RoundedFrame("BottomBar", UDim2.new(0.6, 0, 0, 80), UDim2.new(0.2, 0, 1, -90), Color3.new(0, 0, 0), hudFrame)
	bottomBar.BackgroundTransparency = 0.6

	local equippedTitle = TextLabel("EquippedTitle", UDim2.new(0, 200, 0, 20), UDim2.new(0, 10, 0, 5), "Equipped Monsters", COLORS.textDim, 14, Enum.Font.Gotham, bottomBar)

	-- Equipped slots (4 slots)
	for i = 1, 4 do
		local slot = RoundedFrame("Slot" .. i, UDim2.new(0, 80, 0, 50), UDim2.new(0, 10 + (i - 1) * 90, 0, 25), COLORS.panel, bottomBar)
		local slotLabel = TextLabel("Label", UDim2.new(1, 0, 1, 0), UDim2.new(0, 0, 0, 0), "Empty", COLORS.textDim, 10, Enum.Font.Gotham, slot)
	end

	-- Large click/tap button
	local clickBtn = TextButton("ClickBtn", UDim2.new(0, 80, 0, 80), UDim2.new(1, -100, 1, -100), "⚡", COLORS.accent, hudFrame, nil)
	clickBtn.TextSize = 30
	clickBtn.Position = UDim2.new(1, -100, 1, -100) -- Will be repositioned

	-- Store references for updates
	UIController.refs = {
		energyLabel = energyLabel,
		essenceLabel = essenceLabel,
		rankLabel = rankLabel,
		bottomBar = bottomBar,
	}
end

--[[ Update stat displays ]]
function UIController.UpdateStats(energy, essence, rank, rebirthMultiplier)
	if UIController.refs then
		if energy then
			UIController.refs.energyLabel.Text = tostring(math.floor(energy))
		end
		if essence then
			UIController.refs.essenceLabel.Text = tostring(math.floor(essence))
		end
		if rank then
			local rankTitle = Constants.RANK_TITLES[rank + 1] or "Monster God"
			UIController.refs.rankLabel.Text = "Rank " .. tostring(rank) .. ": " .. rankTitle
		end
	end
end

--[[ Close current menu ]]
function UIController.CloseMenu()
	if currentMenu and currentMenu.Parent then
		currentMenu:Destroy()
		currentMenu = nil
	end
end

--[[ Create overlay (semi-transparent background) ]]
function UIController.CreateOverlay()
	local overlay = new("Frame", {
		Name = "MenuOverlay",
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = Color3.new(0, 0, 0),
		BackgroundTransparency = 0.6,
		Parent = screenGui,
	})
	overlay.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			-- Close on overlay tap
		end
	end)
	return overlay
end

--[[ Open Inventory Menu ]]
function UIController.OpenInventory()
	UIController.CloseMenu()
	local overlay = UIController.CreateOverlay()

	local menu = RoundedFrame("InventoryMenu", UDim2.new(0, 600, 0, 450), UDim2.new(0.5, -300, 0.5, -225), COLORS.background, screenGui)
	currentMenu = menu

	-- Title bar
	local titleBar = RoundedFrame("TitleBar", UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 0), COLORS.panel, menu)
	TextLabel("Title", UDim2.new(0, 200, 1, 0), UDim2.new(0, 10, 0, 0), "📦 Inventory", COLORS.text, 22, Enum.Font.GothamBold, titleBar)

	-- Close button
	TextButton("CloseBtn", UDim2.new(0, 30, 0, 30), UDim2.new(1, -35, 0, 5), "✕", COLORS.danger, titleBar, function()
		UIController.CloseMenu()
		if overlay then overlay:Destroy() end
	end)

	-- Tabs: Monsters | Items
	local tabBar = RoundedFrame("TabBar", UDim2.new(1, 0, 0, 35), UDim2.new(0, 0, 0, 40), COLORS.panel, menu)
	local monsterTab = TextButton("MonsterTab", UDim2.new(0, 120, 0, 30), UDim2.new(0, 10, 0, 2), "Monsters", COLORS.accent, tabBar, function() end)
	local itemsTab = TextButton("ItemsTab", UDim2.new(0, 120, 0, 30), UDim2.new(0, 140, 0, 2), "Items", COLORS.button, tabBar, function() end)

	-- Scrollable monster list area
	local scrollFrame = new("ScrollingFrame", {
		Name = "MonsterList",
		Size = UDim2.new(1, 0, 1, -85),
		Position = UDim2.new(0, 0, 0, 80),
		BackgroundTransparency = 1,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 6,
		ScrollBarImageColor3 = COLORS.panel,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		Parent = menu,
	})

	local grid = new("UIGridLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
		CellSize = UDim2.new(0, 550, 0, 60),
		CellPadding = UDim2.new(0, 5, 0, 5),
		Parent = scrollFrame,
	})

	-- Fetch player inventory from server
	local playerManager = require(script.Parent.PlayerManager)
	-- For now, we'll create placeholder monster cards
	-- In a real implementation, the server sends inventory data via remote events

	-- Placeholder: Request inventory
	local function RefreshInventory()
		-- Clear existing items
		for _, child in ipairs(scrollFrame:GetChildren()) do
			if child:IsA("Frame") then
				child:Destroy()
			end
		end

		-- We need the server to send inventory. For now, request via remote.
		-- Placeholder inventory UI
		local placeholder = TextLabel("Placeholder", UDim2.new(1, -10, 0, 40), UDim2.new(0, 5, 0, 10), "Loading inventory...", COLORS.textDim, 16, Enum.Font.Gotham, scrollFrame)
	end

	RefreshInventory()

	-- Close overlay on backdrop click
	overlay.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			UIController.CloseMenu()
			overlay:Destroy()
		end
	end)
end

--[[ Open Shop Menu ]]
function UIController.OpenShop()
	UIController.CloseMenu()
	local overlay = UIController.CreateOverlay()

	local menu = RoundedFrame("ShopMenu", UDim2.new(0, 500, 0, 400), UDim2.new(0.5, -250, 0.5, -200), COLORS.background, screenGui)
	currentMenu = menu

	local titleBar = RoundedFrame("TitleBar", UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 0), COLORS.panel, menu)
	TextLabel("Title", UDim2.new(0, 200, 1, 0), UDim2.new(0, 10, 0, 0), "🛒 Shop", COLORS.text, 22, Enum.Font.GothamBold, titleBar)
	TextButton("CloseBtn", UDim2.new(0, 30, 0, 30), UDim2.new(1, -35, 0, 5), "✕", COLORS.danger, titleBar, function()
		UIController.CloseMenu()
		if overlay then overlay:Destroy() end
	end)

	-- Shop categories
	local categories = RoundedFrame("Categories", UDim2.new(0, 160, 1, -45), UDim2.new(0, 0, 0, 45), COLORS.panel, menu)
	TextButton("GamePasses", UDim2.new(0, 140, 0, 35), UDim2.new(0, 10, 0, 10), "Game Passes", COLORS.button, categories, function() end)
	TextButton("Currency", UDim2.new(0, 140, 0, 35), UDim2.new(0, 10, 0, 50), "Currency", COLORS.button, categories, function() end)
	TextButton("Boosts", UDim2.new(0, 140, 0, 35), UDim2.new(0, 10, 0, 90), "Boosts", COLORS.button, categories, function() end)

	-- Items display area
	local itemsArea = RoundedFrame("ItemsArea", UDim2.new(0, 330, 1, -45), UDim2.new(0, 165, 0, 45), COLORS.background, menu)

	TextLabel("ItemsTitle", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 10), "Game Passes", COLORS.text, 20, Enum.Font.GothamBold, itemsArea)

	-- Sample game pass items
	local passes = {
		{ name = "Double Energy", price = "400 Robux", desc = "2x Energy collection" },
		{ name = "Auto-Hatch", price = "250 Robux", desc = "Auto-hatches eggs" },
		{ name = "Extra Equip", price = "350 Robux", desc = "+2 monster slots" },
		{ name = "VIP", price = "500 Robux", desc = "1.5x Essence + VIP Slime" },
	}

	for i, pass in ipairs(passes) do
		local itemFrame = RoundedFrame("Item" .. i, UDim2.new(0, 300, 0, 50), UDim2.new(0, 10, 0, 45 + (i - 1) * 60), COLORS.panel, itemsArea)
		TextLabel("Name", UDim2.new(0, 180, 0, 25), UDim2.new(0, 10, 0, 2), pass.name, COLORS.accent, 16, Enum.Font.GothamBold, itemFrame)
		TextLabel("Desc", UDim2.new(0, 180, 0, 20), UDim2.new(0, 10, 0, 27), pass.desc, COLORS.textDim, 12, Enum.Font.Gotham, itemFrame)
		TextButton("Buy", UDim2.new(0, 80, 0, 35), UDim2.new(0, 210, 0, 8), pass.price, COLORS.success, itemFrame, function() end)
	end

	overlay.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			UIController.CloseMenu()
			overlay:Destroy()
		end
	end)
end

--[[ Open Hatching UI ]]
function UIController.OpenHatching()
	UIController.CloseMenu()
	local overlay = UIController.CreateOverlay()

	local menu = RoundedFrame("HatchMenu", UDim2.new(0, 400, 0, 350), UDim2.new(0.5, -200, 0.5, -175), COLORS.background, screenGui)
	currentMenu = menu

	local titleBar = RoundedFrame("TitleBar", UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 0), COLORS.panel, menu)
	TextLabel("Title", UDim2.new(0, 200, 1, 0), UDim2.new(0, 10, 0, 0), "🥚 Incubator", COLORS.text, 22, Enum.Font.GothamBold, titleBar)
	TextButton("CloseBtn", UDim2.new(0, 30, 0, 30), UDim2.new(1, -35, 0, 5), "✕", COLORS.danger, titleBar, function()
		UIController.CloseMenu()
		if overlay then overlay:Destroy() end
	end)

	-- Egg selection
	local eggs = { "Common", "Rare", "Epic", "Legendary", "Mythical" }
	local costs = { "100 Energy", "500 Energy", "2,500 Energy", "10,000 Energy", "50,000 Energy" }

	TextLabel("SelectEgg", UDim2.new(1, -20, 0, 25), UDim2.new(0, 10, 0, 50), "Choose an Egg:", COLORS.text, 18, Enum.Font.GothamBold, menu)

	for i, eggName in ipairs(eggs) do
		local cost = costs[i]
		local color = RARITY_COLORS[eggName] or COLORS.text

		local eggFrame = RoundedFrame("Egg" .. eggName, UDim2.new(0, 360, 0, 40), UDim2.new(0, 20, 0, 85 + (i - 1) * 48), COLORS.panel, menu)
		local eggIcon = TextLabel("Icon", UDim2.new(0, 30, 0, 30), UDim2.new(0, 5, 0, 5), "🥚", color, 16, Enum.Font.GothamBold, eggFrame)
		local eggNameLabel = TextLabel("Name", UDim2.new(0, 120, 1, 0), UDim2.new(0, 40, 0, 0), eggName, color, 16, Enum.Font.GothamBold, eggFrame)
		local costLabel = TextLabel("Cost", UDim2.new(0, 120, 1, 0), UDim2.new(0, 160, 0, 0), cost, COLORS.energy, 14, Enum.Font.Gotham, eggFrame)

		TextButton("HatchBtn", UDim2.new(0, 60, 0, 30), UDim2.new(0, 290, 0, 5), "Hatch", COLORS.success, eggFrame, function()
			-- Fire HatchEgg remote function to server
			local HatchEgg = ReplicatedStorage:FindFirstChild("MonsterMash"):FindFirstChild("RemoteEvents"):FindFirstChild("HatchEgg")
			if HatchEgg then
				local result = HatchEgg:InvokeServer(eggName, "zone1_forest")
				if result and result.success then
					UIController.ShowHatchedMonster(result.monster)
				end
			end
		end)
	end

	overlay.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			UIController.CloseMenu()
			overlay:Destroy()
		end
	end)
end

--[[ Show hatched monster reveal ]]
function UIController.ShowHatchedMonster(monster)
	-- Create a full-screen reveal overlay
	local reveal = RoundedFrame("HatchReveal", UDim2.new(0, 350, 0, 250), UDim2.new(0.5, -175, 0.5, -125), COLORS.background, screenGui)
	reveal.BackgroundTransparency = 0.1
	reveal.ZIndex = 10

	local rarityColor = RARITY_COLORS[monster.rarity] or COLORS.text

	local titleText = monster.shiny and "✨ SHINY HATCH! ✨" or "★ New Monster! ★"
	TextLabel("Title", UDim2.new(1, -20, 0, 35), UDim2.new(0, 10, 0, 10), titleText, COLORS.accent, 24, Enum.Font.GothamBold, reveal)

	TextLabel("Rarity", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 50), monster.rarity, rarityColor, 20, Enum.Font.GothamBold, reveal)
	TextLabel("Name", UDim2.new(1, -20, 0, 35), UDim2.new(0, 10, 0, 85), monster.name, COLORS.text, 22, Enum.Font.GothamBold, reveal)
	TextLabel("EPS", UDim2.new(0, 150, 0, 25), UDim2.new(0, 10, 0, 130), "EPS: " .. tostring(monster.eps), COLORS.essence, 16, Enum.Font.Gotham, reveal)

	if monster.shiny then
		TextLabel("Shiny", UDim2.new(0, 150, 0, 25), UDim2.new(0, 160, 0, 130), "✨ 2x Stats!", COLORS.accent, 16, Enum.Font.GothamBold, reveal)
	end

	TextButton("Okay", UDim2.new(0, 100, 0, 35), UDim2.new(0.5, -50, 1, -50), "Collect!", COLORS.success, reveal, function()
		reveal:Destroy()
	end)
end

--[[ Open Battle Arena UI ]]
function UIController.OpenBattleArena()
	UIController.CloseMenu()
	local overlay = UIController.CreateOverlay()

	local menu = RoundedFrame("BattleMenu", UDim2.new(0, 450, 0, 300), UDim2.new(0.5, -225, 0.5, -150), COLORS.background, screenGui)
	currentMenu = menu

	local titleBar = RoundedFrame("TitleBar", UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 0), COLORS.panel, menu)
	TextLabel("Title", UDim2.new(0, 200, 1, 0), UDim2.new(0, 10, 0, 0), "⚔️ Battle Arena", COLORS.text, 22, Enum.Font.GothamBold, titleBar)
	TextButton("CloseBtn", UDim2.new(0, 30, 0, 30), UDim2.new(1, -35, 0, 5), "✕", COLORS.danger, titleBar, function()
		UIController.CloseMenu()
		if overlay then overlay:Destroy() end
	end)

	TextLabel("Info", UDim2.new(1, -20, 0, 40), UDim2.new(0, 10, 0, 50), "Battle 10 waves of NPC monsters!", COLORS.text, 16, Enum.Font.Gotham, menu)
	TextLabel("Rewards", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 100), "Rewards: Essence + Monster XP", COLORS.essence, 14, Enum.Font.Gotham, menu)

	-- Battle stats area (shown during battle)
	local battleInfo = RoundedFrame("BattleInfo", UDim2.new(0, 400, 0, 60), UDim2.new(0, 25, 0, 140), COLORS.panel, menu)
	battleInfo.Visible = false

	local waveLabel = TextLabel("WaveLabel", UDim2.new(0, 200, 0, 25), UDim2.new(0, 10, 0, 5), "Wave 1/10", COLORS.text, 16, Enum.Font.GothamBold, battleInfo)
	local npcHPLabel = TextLabel("NPCHP", UDim2.new(0, 200, 0, 25), UDim2.new(0, 10, 0, 30), "HP: 50/50", COLORS.danger, 14, Enum.Font.Gotham, battleInfo)
	local playerHPLabel = TextLabel("PlayerHP", UDim2.new(0, 200, 0, 25), UDim2.new(0, 220, 0, 30), "HP: 100/100", COLORS.success, 14, Enum.Font.Gotham, battleInfo)

	-- Attack button (during battle)
	local attackBtn = TextButton("AttackBtn", UDim2.new(0, 100, 0, 40), UDim2.new(0.5, -50, 1, -60), "⚔️ Attack", COLORS.danger, menu, function()
		-- Send attack to server
		local BattleSystem = require(script.Parent.BattleSystem)
		-- Fire CollectEnergy with special attack flag — actually we need a dedicated attack remote
		-- For now use StartBattle and a separate remote
	end)
	attackBtn.Visible = false

	-- Start battle button
	TextButton("StartBattle", UDim2.new(0, 150, 0, 45), UDim2.new(0.5, -75, 1, -60), "⚔️ Start Battle!", COLORS.accent, menu, function()
		local StartBattle = ReplicatedStorage:FindFirstChild("MonsterMash"):FindFirstChild("RemoteEvents"):FindFirstChild("StartBattle")
		if StartBattle then
			StartBattle:FireServer()
			menu:Destroy()
			if overlay then overlay:Destroy() end
		end
	end)

	overlay.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			UIController.CloseMenu()
			overlay:Destroy()
		end
	end)
end

--[[ Update battle UI with real-time data ]]
function UIController.UpdateBattleUI(data)
	if not data then return end

	-- Check if we need to create/update battle HUD
	local battleHUD = screenGui:FindFirstChild("BattleHUD")
	if not battleHUD and data.battleActive then
		battleHUD = RoundedFrame("BattleHUD", UDim2.new(0.5, 0, 0, 100), UDim2.new(0.25, 0, 0.35, -50), Color3.new(0, 0, 0), screenGui)
		battleHUD.BackgroundTransparency = 0.7
		UIController.battleHUD = battleHUD

		TextLabel("WaveInfo", UDim2.new(0, 200, 0, 25), UDim2.new(0, 10, 0, 5), "Wave 1/10", COLORS.text, 16, Enum.Font.GothamBold, battleHUD)
		TextLabel("NPCHPInfo", UDim2.new(0, 200, 0, 25), UDim2.new(0, 10, 0, 35), "NPC HP: 50", COLORS.danger, 14, Enum.Font.Gotham, battleHUD)
		TextLabel("PlayerHPInfo", UDim2.new(0, 200, 0, 25), UDim2.new(0, 10, 0, 60), "Your HP: 100", COLORS.success, 14, Enum.Font.Gotham, battleHUD)
	end

	if battleHUD then
		local waveInfo = battleHUD:FindFirstChild("WaveInfo")
		local npcHPInfo = battleHUD:FindFirstChild("NPCHPInfo")
		local playerHPInfo = battleHUD:FindFirstChild("PlayerHPInfo")

		if waveInfo and data.wave then
			waveInfo.Text = "Wave " .. tostring(data.wave) .. "/10"
		end
		if npcHPInfo and data.npcHP then
			local maxHP = data.npcMaxHP or data.npcHP
			npcHPInfo.Text = "NPC HP: " .. tostring(math.floor(data.npcHP)) .. "/" .. tostring(maxHP)
		end
		if playerHPInfo and data.playerHP then
			local maxHP = data.playerMaxHP or data.playerHP
			playerHPInfo.Text = "Your HP: " .. tostring(math.floor(data.playerHP)) .. "/" .. tostring(maxHP)
		end

		if data.damageDealt then
			-- Show damage popup
			local player = Players.LocalPlayer
			local character = player.Character
			if character and character:FindFirstChild("HumanoidRootPart") then
				local EffMgr = require(script.Parent.EffectManager)
				EffMgr.ShowDamageNumber(data.damageDealt, character.HumanoidRootPart.Position)
			end
		end
	end
end

--[[ Show battle results ]]
function UIController.ShowBattleResults(data)
	local battleHUD = screenGui:FindFirstChild("BattleHUD")
	if battleHUD then battleHUD:Destroy() end

	local resultFrame = RoundedFrame("BattleResults", UDim2.new(0, 350, 0, 200), UDim2.new(0.5, -175, 0.5, -100), COLORS.background, screenGui)
	resultFrame.ZIndex = 10

	local title = data.defeated and "💀 Defeated!" or "🏆 Victory!"
	local color = data.defeated and COLORS.danger or COLORS.success

	TextLabel("Title", UDim2.new(1, -20, 0, 35), UDim2.new(0, 10, 0, 15), title, color, 24, Enum.Font.GothamBold, resultFrame)
	TextLabel("WavesCleared", UDim2.new(1, -20, 0, 25), UDim2.new(0, 10, 0, 55), "Waves: " .. tostring(data.wavesCleared) .. "/10", COLORS.text, 16, Enum.Font.Gotham, resultFrame)
	TextLabel("Essence", UDim2.new(1, -20, 0, 25), UDim2.new(0, 10, 0, 85), "+" .. tostring(data.essenceReward) .. " Essence", COLORS.essence, 16, Enum.Font.Gotham, resultFrame)
	if data.xpReward and data.xpReward > 0 then
		TextLabel("XP", UDim2.new(1, -20, 0, 25), UDim2.new(0, 10, 0, 115), "+" .. tostring(data.xpReward) .. " Monster XP", COLORS.success, 14, Enum.Font.Gotham, resultFrame)
	end

	TextButton("Okay", UDim2.new(0, 100, 0, 35), UDim2.new(0.5, -50, 1, -50), "Okay", COLORS.button, resultFrame, function()
		resultFrame:Destroy()
	end)
end

--[[ Open World Select/Zone Unlock UI ]]
function UIController.OpenWorldSelect()
	UIController.CloseMenu()
	local overlay = UIController.CreateOverlay()

	local menu = RoundedFrame("WorldMenu", UDim2.new(0, 450, 0, 350), UDim2.new(0.5, -225, 0.5, -175), COLORS.background, screenGui)
	currentMenu = menu

	local titleBar = RoundedFrame("TitleBar", UDim2.new(1, 0, 0, 40), UDim2.new(0, 0, 0, 0), COLORS.panel, menu)
	TextLabel("Title", UDim2.new(0, 200, 1, 0), UDim2.new(0, 10, 0, 0), "🌍 Worlds", COLORS.text, 22, Enum.Font.GothamBold, titleBar)
	TextButton("CloseBtn", UDim2.new(0, 30, 0, 30), UDim2.new(1, -35, 0, 5), "✕", COLORS.danger, titleBar, function()
		UIController.CloseMenu()
		if overlay then overlay:Destroy() end
	end)

	-- Zone list
	for i, zone in ipairs(Constants.ZONES) do
		local isUnlocked = zone.isUnlocked -- Will need server data in real implementation
		local zoneColor = isUnlocked and COLORS.success or COLORS.danger
		local statusText = isUnlocked and "✅" or "🔒"

		local zoneFrame = RoundedFrame("Zone" .. i, UDim2.new(0, 410, 0, 60), UDim2.new(0, 20, 0, 50 + (i - 1) * 70), COLORS.panel, menu)
		TextLabel("Icon", UDim2.new(0, 30, 0, 30), UDim2.new(0, 5, 0, 15), statusText, zoneColor, 20, Enum.Font.GothamBold, zoneFrame)
		TextLabel("Name", UDim2.new(0, 180, 0, 25), UDim2.new(0, 40, 0, 5), zone.displayName, COLORS.text, 18, Enum.Font.GothamBold, zoneFrame)
		TextLabel("Multiplier", UDim2.new(0, 180, 0, 20), UDim2.new(0, 40, 0, 30), "Energy x" .. tostring(zone.energyMultiplier), COLORS.textDim, 12, Enum.Font.Gotham, zoneFrame)

		if isUnlocked then
			TextButton("Teleport", UDim2.new(0, 80, 0, 35), UDim2.new(0, 320, 0, 12), "Travel", COLORS.success, zoneFrame, function()
				-- Teleport to zone via server
				-- Would need a teleport remote
				UIController.CloseMenu()
				if overlay then overlay:Destroy() end
			end)
		else
			TextButton("Unlock", UDim2.new(0, 100, 0, 35), UDim2.new(0, 300, 0, 12), tostring(zone.unlockCost) .. " Essence", COLORS.button, zoneFrame, function()
				-- Would send unlock request to server
			end)
		end
	end

	overlay.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			UIController.CloseMenu()
			overlay:Destroy()
		end
	end)
end

--[[ Show evolution result ]]
function UIController.ShowEvolutionResult(shinyMonster)
	local resultFrame = RoundedFrame("EvolutionResult", UDim2.new(0, 350, 0, 200), UDim2.new(0.5, -175, 0.5, -100), COLORS.background, screenGui)
	resultFrame.ZIndex = 10

	TextLabel("Title", UDim2.new(1, -20, 0, 35), UDim2.new(0, 10, 0, 15), "✨ Evolution Complete! ✨", COLORS.accent, 22, Enum.Font.GothamBold, resultFrame)
	TextLabel("Name", UDim2.new(1, -20, 0, 30), UDim2.new(0, 10, 0, 55), shinyMonster.name, COLORS.text, 20, Enum.Font.GothamBold, resultFrame)
	TextLabel("Rarity", UDim2.new(1, -20, 0, 25), UDim2.new(0, 10, 0, 90), shinyMonster.rarity .. " (Shiny)", COLORS.accent, 16, Enum.Font.Gotham, resultFrame)
	TextLabel("EPS", UDim2.new(1, -20, 0, 25), UDim2.new(0, 10, 0, 120), "EPS: " .. tostring(shinyMonster.eps) .. " (2x!)", COLORS.essence, 16, Enum.Font.Gotham, resultFrame)

	TextButton("Okay", UDim2.new(0, 100, 0, 35), UDim2.new(0.5, -50, 1, -50), "Amazing!", COLORS.success, resultFrame, function()
		resultFrame:Destroy()
	end)
end

--[[ Show zone unlocked notification ]]
function UIController.ShowZoneUnlocked(data)
	local notif = RoundedFrame("ZoneUnlocked", UDim2.new(0, 300, 0, 80), UDim2.new(0.5, -150, 0.5, -40), COLORS.background, screenGui)
	notif.ZIndex = 10

	TextLabel("Title", UDim2.new(1, -20, 1, 0), UDim2.new(0, 10, 0, 0), "🌍 " .. data.zoneName .. " Unlocked!", COLORS.success, 22, Enum.Font.GothamBold, notif)

	task.delay(3, function()
		notif:Destroy()
	end)
end

--[[ Initialize UI controller ]]
function UIController.Initialize(gui, plr)
	screenGui = gui
	player = plr
	UIController.CreateHUD()
end

return UIController