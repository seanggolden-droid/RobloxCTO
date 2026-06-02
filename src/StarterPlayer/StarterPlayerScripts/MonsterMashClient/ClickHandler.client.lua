--[[ ClickHandler: Handles debounced click/tap energy collection ]]

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClickHandler = {}

local DEBOUNCE_TIME = 0.15
local lastClickTime = 0
local clickPower = 1

--[[ Initialize the click handler ]]
function ClickHandler.Initialize(collectEnergyRemote)
	-- Mouse click (desktop)
	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then return end
		
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			ClickHandler.DoClick(collectEnergyRemote)
		end
	end)
	
	-- Touch tap (mobile)
	UserInputService.TouchStarted:Connect(function(touch, gameProcessedEvent)
		if gameProcessedEvent then return end
		
		ClickHandler.DoClick(collectEnergyRemote)
	end)
	
	-- Also support keyboard spacebar
	UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
		if gameProcessedEvent then return end
		
		if input.KeyCode == Enum.KeyCode.Space then
			ClickHandler.DoClick(collectEnergyRemote)
		end
	end)
end

--[[ Performs a click: checks debounce, fires remote ]]
function ClickHandler.DoClick(collectEnergyRemote)
	local now = os.clock()
	if now - lastClickTime < DEBOUNCE_TIME then
		return
	end
	lastClickTime = now
	
	-- Fire remote to server with click power
	collectEnergyRemote:FireServer(clickPower)
end

--[[ Update click power based on upgrades (called externally) ]]
function ClickHandler.SetClickPower(power)
	clickPower = math.max(1, power)
end

--[[ Get current click power ]]
function ClickHandler.GetClickPower()
	return clickPower
end

return ClickHandler