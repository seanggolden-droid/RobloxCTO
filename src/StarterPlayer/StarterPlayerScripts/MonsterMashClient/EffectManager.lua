--[[ EffectManager: Handles local visual effects for hatching, evolution, battle, etc. ]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local EffectManager = {}

--[[ Plays a hatching effect (egg shake + burst) ]]
function EffectManager.PlayHatchEffect()
	local player = Players.LocalPlayer
	local character = player.Character
	if not character then return end
	
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end
	
	-- Create a simple particle effect at the player's position
	local attachment = Instance.new("Attachment")
	attachment.Parent = rootPart
	
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "HatchEffect"
	particleEmitter.Rate = 50
	particleEmitter.Lifetime = NumberRange.new(0.5, 1)
	particleEmitter.Speed = NumberRange.new(5, 15)
	particleEmitter.SpreadAngle = NumberRange.new(0, 360)
	particleEmitter.Texture = "rbxassetid://0" -- Will need a real texture
	particleEmitter.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0)) -- Gold
	particleEmitter.Transparency = NumberSequence.new(0)
	particleEmitter.Size = NumberSequence.new(NumberKeypoint.new(0, 0.5), NumberKeypoint.new(1, 0))
	particleEmitter.Acceleration = Vector3.new(0, 10, 0)
	particleEmitter.Drag = 2
	particleEmitter.Enabled = true
	particleEmitter.Parent = attachment
	
	-- Stop after a short burst
	task.delay(0.3, function()
		particleEmitter.Enabled = false
		task.delay(2, function()
			particleEmitter:Destroy()
			attachment:Destroy()
		end)
	end)
end

--[[ Plays evolution effect (bright flash + sparkles) ]]
function EffectManager.PlayEvolutionEffect()
	local player = Players.LocalPlayer
	local character = player.Character
	if not character then return end
	
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end
	
	-- Flash the character
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		-- Brief glow (using BillboardGui or just visual hint)
		humanoid.WalkSpeed = 0
		task.delay(0.5, function()
			if humanoid then
				humanoid.WalkSpeed = 16
			end
		end)
	end
	
	-- Spawn particles around player
	local attachment = Instance.new("Attachment")
	attachment.Parent = rootPart
	
	local particle = Instance.new("ParticleEmitter")
	particle.Name = "EvolutionEffect"
	particle.Rate = 100
	particle.Lifetime = NumberRange.new(0.8, 1.5)
	particle.Speed = NumberRange.new(8, 20)
	particle.SpreadAngle = NumberRange.new(0, 360)
	particle.Texture = "rbxassetid://0"
	particle.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 215, 0)),
	})
	particle.Transparency = NumberSequence.new(NumberKeypoint.new(0, 0), NumberKeypoint.new(1, 1))
	particle.Size = NumberSequence.new(NumberKeypoint.new(0, 0.8), NumberKeypoint.new(1, 0.1))
	particle.Acceleration = Vector3.new(0, 5, 0)
	particle.Drag = 1
	particle.Enabled = true
	particle.Parent = attachment
	
	task.delay(0.5, function()
		particle.Enabled = false
		task.delay(2, function()
			particle:Destroy()
			attachment:Destroy()
		end)
	end)
end

--[[ Plays battle complete effect ]]
function EffectManager.PlayBattleCompleteEffect(success)
	local player = Players.LocalPlayer
	local character = player.Character
	if not character then return end
	
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then return end
	
	local color = success and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(255, 0, 0)
	
	local attachment = Instance.new("Attachment")
	attachment.Parent = rootPart
	
	local particle = Instance.new("ParticleEmitter")
	particle.Name = "BattleEffect"
	particle.Rate = 30
	particle.Lifetime = NumberRange.new(0.5, 1)
	particle.Speed = NumberRange.new(5, 10)
	particle.SpreadAngle = NumberRange.new(0, 360)
	particle.Texture = "rbxassetid://0"
	particle.Color = ColorSequence.new(color)
	particle.Transparency = NumberSequence.new(NumberKeypoint.new(0, 0), NumberKeypoint.new(1, 1))
	particle.Size = NumberSequence.new(NumberKeypoint.new(0, 0.5), NumberKeypoint.new(1, 0))
	particle.Acceleration = Vector3.new(0, -5, 0)
	particle.Enabled = true
	particle.Parent = attachment
	
	task.delay(0.5, function()
		particle.Enabled = false
		task.delay(2, function()
			particle:Destroy()
			attachment:Destroy()
		end)
	end)
end

--[[ Creates a damage number popup (floating text) ]]
function EffectManager.ShowDamageNumber(damage, position)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "DamageNumber"
	billboard.Size = UDim2.new(0, 100, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.Adornee = nil
	billboard.Parent = game:GetService("Workspace").CurrentCamera
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = tostring(damage)
	label.TextColor3 = Color3.fromRGB(255, 255, 0)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.TextStrokeTransparency = 0.5
	label.Parent = billboard
	
	-- Animate upward and fade
	coroutine.wrap(function()
		for i = 1, 30 do
			billboard.StudsOffset = billboard.StudsOffset + Vector3.new(0, 0.1, 0)
			label.TextTransparency = i / 30
			task.wait(0.03)
		end
		billboard:Destroy()
	end)()
end

return EffectManager