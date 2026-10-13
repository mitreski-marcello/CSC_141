--[[
	DeathScreenServer (Script, put in ServerScriptService)

	When ANY player dies (boss, player, falling, reset, whatever) it tells that player's client to show the death screen.
	No hooks needed in your other scripts.
]]
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- ===== CONFIG =====
-- Players below this Y get killed (so falling off the map counts as a death while the character still exists).
-- Put it under your lowest tile but ABOVE workspace.FallenPartsDestroyHeight (default -500). Set to nil to turn off.
local KILL_Y = -200

-- Level number shown on the screen. Return nil to hide it. Change this to match your round system.
local function getLevel(player)
	return workspace:GetAttribute("Level") or player:GetAttribute("Level")
end

local event = ReplicatedStorage:FindFirstChild("DeathScreenEvent")
if not event then
	event = Instance.new("RemoteEvent")
	event.Name = "DeathScreenEvent"
	event.Parent = ReplicatedStorage
end

local spawnedAt = {}

local function onCharacter(player, char)
	spawnedAt[player] = os.clock()
	local hum = char:WaitForChild("Humanoid", 10)
	if not hum then return end
	hum.Died:Once(function()
		event:FireClient(player, "Show", {
			Level = getLevel(player),
			Survived = spawnedAt[player] and (os.clock() - spawnedAt[player]) or nil,
		})
	end)
end

local function setup(player)
	player.CharacterAdded:Connect(function(char) onCharacter(player, char) end)
	if player.Character then task.spawn(onCharacter, player, player.Character) end
end
Players.PlayerAdded:Connect(setup)
for _, p in ipairs(Players:GetPlayers()) do setup(p) end
Players.PlayerRemoving:Connect(function(p) spawnedAt[p] = nil end)

if KILL_Y then
	RunService.Heartbeat:Connect(function()
		for _, plr in ipairs(Players:GetPlayers()) do
			local char = plr.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if root and hum and hum.Health > 0 and root.Position.Y < KILL_Y then
				hum.Health = 0
			end
		end
	end)
end
