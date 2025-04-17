-- DevRY:Hub v0.0.1a

if _G.ObsidianUI then
	_G.ObsidianUI:Unload()
end

local PlayerService = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = PlayerService.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
if not PlayerGui then
	return
end

local ObsidianUI = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(ObsidianUI .. "Library.lua"))()
_G.ObsidianUI = Library
local ThemeManager = loadstring(game:HttpGet(ObsidianUI .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(ObsidianUI .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
	Title = "DevRY:Hub",
	Footer = "version: 0.0.1a",
	NotifySide = "Right",
	ShowCustomCursor = true,
	Center = true,
	AutoShow = true,
	Resizable = false,
	MobileButtonsSide = "Right",
	CornerRadius = 10,
	Size = UDim2.fromOffset(480, 360),
	Font = Enum.Font.BuilderSans,
})

local Tabs = {
	Main = Window:AddTab("Main", "user"),
	Farming = Window:AddTab("Farming", "sword"),
	Dungeon = Window:AddTab("Dungeon", "crown"),
	Castle = Window:AddTab("Infernal Castle", "castle"),
	["UI Settings"] = Window:AddTab("Settings", "settings"),
}

local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local EnemiesFolder = workspace:WaitForChild("__Main"):WaitForChild("__Enemies"):WaitForChild("Client")
local DataRemoteEvent = ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
	Character = newCharacter
	HumanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
end)

-- Add teleport here


local AFNearGroupBox = Tabs.Farming:AddLeftGroupbox("Island Farming")

local IsAutoFarming = false
local IsTweening = false
local CurrentTarget = nil
local MaxDistance = 100000
local TweenSpeed = 100
local FarmingMode = "Tween"
local FarmingDelay = 1

local IsAutoFarmingBoss = false
local MaxBossDistance = 100000
local BossSizeTarget = Vector3.new(8, 12, 2.5)

local IsAutoFarmingZiru = false
local ZiruSizeTargets = { Vector3.new(10, 15, 3.15), Vector3.new(14, 21, 4.375), Vector3.new(11.4, 17.1, 3.562) }

local function IsEnemyAlive(enemy)
	local healthLabel = enemy:FindFirstChild("HealthBar")
		and enemy.HealthBar:FindFirstChild("Main")
		and enemy.HealthBar.Main:FindFirstChild("Bar")
		and enemy.HealthBar.Main.Bar:FindFirstChild("Amount")

	if healthLabel and healthLabel:IsA("TextLabel") then
		local healthText = healthLabel.Text
		return not (healthText == "" or healthText == "0" or healthText:find("0 HP"))
	end

	return false
end

local function FindNearestEnemy()
	local nearest, nearestDist = nil, math.huge

	for _, enemy in pairs(EnemiesFolder:GetChildren()) do
		if enemy:IsA("Model") and enemy:FindFirstChild("HumanoidRootPart") and IsEnemyAlive(enemy) then
			local distance = (enemy.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
			if distance < nearestDist and distance <= MaxDistance then
				nearestDist = distance
				nearest = enemy
			end
		end
	end

	return nearest
end

local function TweenToPosition(position)
	local distance = (HumanoidRootPart.Position - position).Magnitude
	local duration = distance / TweenSpeed
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
	local tween = TweenService:Create(HumanoidRootPart, tweenInfo, { CFrame = CFrame.new(position) })

	IsTweening = true
	tween:Play()
	tween.Completed:Wait()
	IsTweening = false
end

local function AttackEnemy(enemy)
	local args = {
		[1] = {
			[1] = {
				["Event"] = "PunchAttack",
				["Enemy"] = enemy.Name,
			},
			[2] = "\4",
		},
	}

	DataRemoteEvent:FireServer(unpack(args))
end

task.spawn(function()
	while true do
		if IsAutoFarming and CurrentTarget and IsEnemyAlive(CurrentTarget) then
			AttackEnemy(CurrentTarget)
		end
		task.wait(0.01)
	end
end)

task.spawn(function()
	while true do
		if IsAutoFarming and HumanoidRootPart and not IsTweening then
			local enemy = FindNearestEnemy()

			if enemy and enemy:FindFirstChild("HumanoidRootPart") then
				CurrentTarget = enemy
				local targetPosition = enemy.HumanoidRootPart.Position + Vector3.new(0, -2, 3)

				if FarmingMode == "Tween" then
					TweenToPosition(targetPosition)
				elseif FarmingMode == "Teleport" then
					for i = 1, 3 do
						HumanoidRootPart.CFrame = CFrame.new(targetPosition)
						task.wait(0.01)
					end
				end
			end

			task.wait(FarmingDelay)
		else
			CurrentTarget = nil
			task.wait(0.1)
		end
	end
end)

local function FindEnemyBoss()
	local nearest, nearestDist = nil, math.huge

	for _, enemy in pairs(EnemiesFolder:GetChildren()) do
		local hitbox = enemy:FindFirstChild("Hitbox")

		if enemy:IsA("Model") and hitbox and IsEnemyAlive(enemy) and hitbox.Size == BossSizeTarget then
			local distance = (hitbox.Position - HumanoidRootPart.Position).Magnitude

			if distance < nearestDist and distance <= MaxBossDistance then
				nearestDist = distance
				nearest = enemy
			end
		end
	end

	return nearest
end

task.spawn(function()
	while task.wait(0.01) do
		if IsAutoFarmingBoss and HumanoidRootPart then
			local boss = FindEnemyBoss()

			if boss then
				local hitbox = boss:FindFirstChild("Hitbox")

				if hitbox then
					for i = 1, 6 do
						HumanoidRootPart.CFrame = CFrame.new(hitbox.Position + Vector3.new(0, -3, 3))
						AttackEnemy(boss)
						task.wait(0.01)
					end
				end
			end
			task.wait(FarmingDelay)
		else
			task.wait(0.1)
		end
	end
end)

local function FindEnemyZiru()
	for _, targetSize in ipairs(ZiruSizeTargets) do
		for _, enemy in pairs(EnemiesFolder:GetChildren()) do
			if enemy:IsA("Model") and enemy:FindFirstChild("Hitbox") and IsEnemyAlive(enemy) then
				local hitbox = enemy:FindFirstChild("Hitbox")

				if hitbox and (hitbox.Size - targetSize).Magnitude < 0.1 then
					return enemy
				end
			end
		end
	end

	return nil
end

task.spawn(function()
	while task.wait(0.01) do
		if IsAutoFarmingZiru and HumanoidRootPart then
			local ziru = FindEnemyZiru()

			if ziru and ziru:FindFirstChild("Hitbox") then
				for i = 1, 5 do
					HumanoidRootPart.CFrame = CFrame.new(ziru.Hitbox.Position + Vector3.new(0, -5, 3))
					AttackEnemy(ziru)
					task.wait(0.1)
				end
			else
				HumanoidRootPart.CFrame = CFrame.new(3877.32227, 60.1332474, 3074.55664)
			end
		end
	end
end)

AFNearGroupBox:AddToggle("AFNearToggle", {
	Text = "Farm Nearest",
	Default = false,
	Callback = function(state)
		IsAutoFarming = state
	end,
})
Toggles.AFNearToggle:OnChanged(function(state)
	IsAutoFarming = state
end)

AFNearGroupBox:AddToggle("AFBossToggle", {
	Text = "Farm Boss",
	Default = false,
	Callback = function(state)
		IsAutoFarmingBoss = state
	end,
})
Toggles.AFBossToggle:OnChanged(function(state)
	IsAutoFarmingBoss = state
end)

AFNearGroupBox:AddToggle("AFZiruToggle", {
	Text = "Farm Ziru",
	Default = false,
	Callback = function(state)
		IsAutoFarmingZiru = state
	end,
})
Toggles.AFZiruToggle:OnChanged(function(state)
	IsAutoFarmingZiru = state
end)

AFNearGroupBox:AddDivider()

AFNearGroupBox:AddSlider("AFTweenSpeed", {
	Text = "Tween Speed",
	Default = 100,
	Min = 100,
	Max = 450,
	Rounding = 1,
	Compact = false,
	Disabled = false,
	Visible = true,
	HideMax = true,
	Callback = function(Value)
		TweenSpeed = Value
	end,
})
Options.AFTweenSpeed:OnChanged(function()
	TweenSpeed = Options.AFTweenSpeed.Value
end)

AFNearGroupBox:AddSlider("AFKillDelay", {
	Text = "Kill Delay",
	Default = 1,
	Min = 0.1,
	Max = 5,
	Rounding = 2,
	Compact = false,
	Disabled = false,
	Visible = true,
	HideMax = true,
	Callback = function(Value)
		FarmingDelay = Value
	end,
})
Options.AFKillDelay:OnChanged(function()
	FarmingDelay = Options.AFKillDelay.Value
end)

AFNearGroupBox:AddDropdown("AFModeDropdown", {
	Values = { "Tween", "Teleport" },
	Default = 1,
	Multi = false,
	Text = "Farm Mode",
	Searchable = false,
	Callback = function(Value)
		FarmingMode = Value
	end,
})
Options.AFModeDropdown:OnChanged(function()
	FarmingMode = Options.AFModeDropdown.Value
end)

local IsAutoPunching = false
local IsAutoArising = false
local IsAutoDestroying = false
local IsAutoAttackEnabled = false

task.spawn(function()
	while task.wait(0.01) do
		if IsAutoPunching and HumanoidRootPart then
			local nearestEnemy = FindNearestEnemy()

			if nearestEnemy then
				AttackEnemy(nearestEnemy)
				print("Punching: ", nearestEnemy.Name)
			end
		end
	end
end)

local function CaptureEnemy(enemy)
	local args = {
		[1] = {
			[1] = {
				["Event"] = "EnemyCapture",
				["Enemy"] = enemy.Name,
			},
			[2] = "\4",
		},
	}
	DataRemoteEvent:FireServer(unpack(args))
end

task.spawn(function()
	while task.wait(0.01) do
		if IsAutoArising and HumanoidRootPart then
			local nearestEnemy = FindNearestEnemy()

			if nearestEnemy then
				CaptureEnemy(nearestEnemy)
			end
		end
	end
end)

ConfigGroupBox = Tabs.Farming:AddRightGroupbox("Game Pass")

ConfigGroupBox:AddToggle("AutoPunchToggle", {
	Text = "Auto Punch",
	Default = false,
	Callback = function(state)
		IsAutoPunching = state
	end,
})
Toggles.AutoPunchToggle:OnChanged(function(state)
	IsAutoPunching = state
end)

ConfigGroupBox:AddToggle("AutoAriseToggle", {
	Text = "Auto Arise",
	Default = false,
	Callback = function(state)
		IsAutoArising = state
	end,
})
Toggles.AutoAriseToggle:OnChanged(function(state)
	IsAutoArising = state
end)

local function DestroyEnemy(enemy)
	local args = {
		[1] = {
			[1] = {
				["Event"] = "EnemyDestroy",
				["Enemy"] = enemy.Name,
			},
			[2] = "\4",
		},
	}
	DataRemoteEvent:FireServer(unpack(args))
end

task.spawn(function()
	while task.wait(0.01) do
		if IsAutoDestroying and HumanoidRootPart then
			local nearestEnemy = FindNearestEnemy()

			if nearestEnemy then
				DestroyEnemy(nearestEnemy)
			end
		end
	end
end)

ConfigGroupBox:AddToggle("AutoDestroyToggle", {
	Text = "Auto Destroy",
	Default = false,
	Callback = function(state)
		IsAutoDestroying = state
	end,
})

DungeonGroupBox = Tabs.Dungeon:AddLeftGroupbox("Dungeon")

local WorldFolder = workspace:WaitForChild("__Main"):WaitForChild("__World")

local IsDungeonFarming = false
local IsDungeonTweening = false
local MaxDungeonDistance = 100000
local DungeonTweenSpeed = 130
local CurrentRoom = 1
local DungeonMovementMode = "Tween"
local DungeonActionDelay = 0.5
local CurrentDungeonTarget = nil

local function DungeonTweenToPosition(position)
	local distance = (HumanoidRootPart.Position - position).Magnitude
	local duration = distance / DungeonTweenSpeed
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
	local tween = TweenService:Create(HumanoidRootPart, tweenInfo, { CFrame = CFrame.new(position) })

	IsDungeonTweening = true
	tween:Play()
	tween.Completed:Wait()
	IsDungeonTweening = false
end

local function FindNextRoomEntrance()
	local nextRoom = WorldFolder:FindFirstChild("Room_" .. tostring(CurrentRoom + 1))
	if nextRoom then
		local entrance = nextRoom:FindFirstChild("Entrace")
		if entrance and entrance:IsA("BasePart") then
			return entrance.Position, CurrentRoom + 1
		end
	end

	return nil, nil
end

local function DetermineCurrentRoom()
	for i = 1, 100 do
		local room = WorldFolder:FindFirstChild("Room_" .. tostring(i))
		if room and (HumanoidRootPart.Position - room.Position).Magnitude <= 80 then
			return i
		end
	end

	return nil
end

task.spawn(function()
	while true do
		if IsDungeonFarming and HumanoidRootPart and not IsDungeonTweening then
			local enemy = FindNearestEnemy()

			if enemy and enemy:FindFirstChild("HumanoidRootPart") then
				CurrentDungeonTarget = enemy
				local targetPosition = enemy.HumanoidRootPart.Position + Vector3.new(0, 0, 3)

				if DungeonMovementMode == "Tween" then
					DungeonTweenToPosition(targetPosition)
				elseif DungeonMovementMode == "Teleport" then
					for i = 1, 3 do
						HumanoidRootPart.CFrame = CFrame.new(targetPosition)
						task.wait(0.01)
					end
				end

				task.wait(DungeonActionDelay)
			else
				CurrentDungeonTarget = nil
				local nextRoomPos, nextRoomNum = FindNextRoomEntrance()

				if nextRoomPos then
					for i = 1, 5 do
						HumanoidRootPart.CFrame = CFrame.new(nextRoomPos)
						task.wait(0.01)
					end

					CurrentRoom = nextRoomNum
				end

				task.wait(0.1)
			end
		else
			CurrentDungeonTarget = nil
			task.wait(0.1)
		end
	end
end)

task.spawn(function()
	while true do
		if IsDungeonFarming and CurrentDungeonTarget and IsEnemyAlive(CurrentDungeonTarget) then
			AttackEnemy(CurrentDungeonTarget)
		end

		task.wait(0.01)
	end
end)

task.spawn(function()
	while task.wait(1) do
		if HumanoidRootPart then
			local detectedRoom = DetermineCurrentRoom()
			if detectedRoom then
				CurrentRoom = detectedRoom
			end
		end
	end
end)

ConfigGroupBox:AddToggle("AutoAttackToggle", {
	Text = "Auto Attack",
	Default = false,
	Callback = function(state)
		if state then
			IsAutoAttackEnabled = true

			local args = {
				[1] = {
					[1] = {
						["Event"] = "SettingsChange",
						["Setting"] = "AutoAttack",
					},
					[2] = "\n",
				},
			}
			DataRemoteEvent:FireServer(unpack(args))
		else
			IsAutoAttackEnabled = false

			local args = {
				[1] = {
					[1] = {
						["Event"] = "SettingsChange",
						["Setting"] = "AutoAttack",
					},
					[2] = "\n",
				},
			}
			DataRemoteEvent:FireServer(unpack(args))
		end
	end,
})

DungeonGroupBox:AddToggle("AutoFarmDungeonToggle", {
	Text = "Auto Farm Dungeon",
	Default = false,
	Callback = function(state)
		IsDungeonFarming = state
	end,
})
Toggles.AutoFarmDungeonToggle:OnChanged(function(state)
	IsDungeonFarming = state
end)

local DungeonPlaceId = 128336380114944
local SelectedDungeon = 1

local function BuyDungeonTicket()
	local args = {
		[1] = {
			[1] = {
				["Type"] = "Gems",
				["Event"] = "DungeonAction",
				["Action"] = "BuyTicket",
			},
			[2] = "\n",
		},
	}
	DataRemoteEvent:FireServer(unpack(args))
end

local function CreateDungeon()
	local args = {
		[1] = {
			[1] = {
				["Event"] = "DungeonAction",
				["Action"] = "Create",
			},
			[2] = "\n",
		},
	}
	DataRemoteEvent:FireServer(unpack(args))
end

local function StartDungeon()
	local args = {
		[1] = {
			[1] = {
				["Dungeon"] = tonumber(selectedDungeon),
				["Event"] = "DungeonAction",
				["Action"] = "Start",
			},
			[2] = "\n",
		},
	}
	DataRemoteEvent:FireServer(unpack(args))
end

DungeonGroupBox:AddToggle("AutoStartDungeon", {
	Text = "Auto Start Dungeon",
	Default = false,
	Callback = function(state)
		if state then
			if game.PlaceId ~= DungeonPlaceId then
				task.spawn(function()
					BuyDungeonTicket()
					task.wait(0.5)
					CreateDungeon()
					task.wait(0.01)
					StartDungeon()
				end)
			else
				Library:Notify("Already in Dungeon, Auto Dungeon disabled")
			end
		end
	end,
})
Toggles.AutoStartDungeon:OnChanged(function(state)
	if state then
		if game.PlaceId ~= DungeonPlaceId then
			BuyDungeonTicket()
			task.wait(0.5)
			CreateDungeon()
			task.wait(0.01)
			StartDungeon()
		else
			Library:Notify("Already in Dungeon, Auto Dungeon disabled")
		end
	end
end)

DungeonGroupBox:AddToggle("AutoRestartDungeon", {
	Text = "Quick Restart",
	Default = false,
	Callback = function(state)
		getgenv().instantLeave = state

		if state then
			task.spawn(function()
				while getgenv().instantLeave do
					task.wait(0.1)

					local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
					local hudGui = playerGui and playerGui:FindFirstChild("Hud")
					local upContainer = hudGui and hudGui:FindFirstChild("UpContanier")
					local dungeonInfo = upContainer and upContainer:FindFirstChild("DungeonInfo")

					if dungeonInfo and dungeonInfo:IsA("TextLabel") then
						local infoText = dungeonInfo.Text

						if string.find(infoText, "Dungeon Ends in 18") then
							warn("Auto start next dungeon...")
							BuyDungeonTicket()
							task.wait(0.1)
							CreateDungeon()
							task.wait(0.01)
							StartDungeon()
							break
						end
					end
				end
			end)
		end
	end,
})
Toggles.AutoRestartDungeon:OnChanged(function(state)
	getgenv().instantLeave = state

	if state then
		task.spawn(function()
			while getgenv().instantLeave do
				task.wait(0.1)

				local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
				local hudGui = playerGui and playerGui:FindFirstChild("Hud")
				local upContainer = hudGui and hudGui:FindFirstChild("UpContanier")
				local dungeonInfo = upContainer and upContainer:FindFirstChild("DungeonInfo")

				if dungeonInfo and dungeonInfo:IsA("TextLabel") then
					local infoText = dungeonInfo.Text

					if string.find(infoText, "Dungeon Ends in 18") then
						warn("Auto start next dungeon...")
						BuyDungeonTicket()
						task.wait(0.1)
						CreateDungeon()
						task.wait(0.01)
						StartDungeon()
						break
					end
				end
			end
		end)
	end
end)

DungeonGroupBox:AddDivider()

DungeonGroupBox:AddSlider("DungeonTweenSpeed", {
	Text = "Tween Speed",
	Default = 100,
	Min = 100,
	Max = 450,
	Rounding = 1,
	Callback = function(Value)
		DungeonTweenSpeed = Value
	end,
})
Options.DungeonTweenSpeed:OnChanged(function()
	DungeonTweenSpeed = Options.DungeonTweenSpeed.Value
end)

DungeonGroupBox:AddSlider("DungeonKillDelay", {
	Text = "Kill Delay",
	Default = 0.5,
	Min = 0.1,
	Max = 5,
	Rounding = 2,
	Callback = function(Value)
		DungeonActionDelay = Value
	end,
})
Options.DungeonKillDelay:OnChanged(function()
	DungeonActionDelay = Options.DungeonKillDelay.Value
end)

DungeonGroupBox:AddDropdown("DungeonModeDropdown", {
	Values = { "Tween", "Teleport" },
	Default = 1,
	Multi = false,
	Text = "Farm Mode",
	Callback = function(value)
		DungeonMovementMode = value
	end,
})
Options.DungeonModeDropdown:OnChanged(function()
	DungeonMovementMode = Options.DungeonModeDropdown.Value
end)

local IsInfernalFarming = false
local MaxInfernalDistance = 1e9
local InfernalTweenSpeed = 160
local InfernalCurrentRoom = 1

local function InfernalTweenToPosition(position)
	local distance = (HumanoidRootPart.Position - position).Magnitude
	local duration = distance / InfernalTweenSpeed
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
	local tween = TweenService:Create(HumanoidRootPart, tweenInfo, { CFrame = CFrame.new(position) })

	IsInfernalTweening = true
	tween:Play()
	tween.Completed:Wait()
	IsInfernalTweening = false
end

task.spawn(function()
	while task.wait(0.05) do
		if IsInfernalFarming then
			local currentRoom = WorldFolder:FindFirstChild("Room_" .. tostring(InfernalCurrentRoom))

			if
				currentRoom
				and currentRoom:FindFirstChild("FirePortal")
				and currentRoom.FirePortal:FindFirstChild("ProximityPrompt")
			then
				local portalPosition = currentRoom.FirePortal.Position

				if HumanoidRootPart then
					HumanoidRootPart.CFrame =
						CFrame.new(portalPosition + Vector3.new(math.random(-2, 2), -3, math.random(-2, 2)))
				end

				DataRemoteEvent:FireServer({
					[1] = {
						["Event"] = "Promote",
					},
					[2] = "\4",
				})
			else
				InfernalCurrentRoom = InfernalCurrentRoom + 1
			end

			if not IsInfernalTweening and HumanoidRootPart then
				local enemy = FindNearestEnemy()

				if enemy and enemy:FindFirstChild("HumanoidRootPart") then
					InfernalTweenToPosition(enemy.HumanoidRootPart.Position + Vector3.new(0, 0, 3))
					AttackEnemy(enemy)
				end
			end
		end
	end
end)

CastleGroupBox = Tabs.Castle:AddLeftGroupbox("Castle")

CastleGroupBox:AddToggle("AutoInfernoFarm", {
	Text = "Auto Farm Castle",
	Default = false,
	Callback = function(state)
		IsInfernalFarming = state
	end,
})
Toggles.AutoInfernoFarm:OnChanged(function(state)
	IsInfernalFarming = state
end)

local IsAutoJoiningCastle = false
local IsAutoJoinnigCastleCheckpoint = false

task.spawn(function()
	while task.wait(1) do
		if IsAutoJoiningCastle and game.PlaceId ~= dungeonPlaceId then
			local args = {
				[1] = {
					[1] = {
						["Event"] = "JoinCastle",
					},
					[2] = "\n",
				},
			}
			DataRemoteEvent:FireServer(unpack(args))
		end
	end
end)

task.spawn(function()
	while task.wait(1) do
		if IsAutoJoiningCastleCheckpoint and game.PlaceId ~= dungeonPlaceId then
			local args = {
				[1] = {
					[1] = {
						["Event"] = "JoinCastle",
						["Check"] = true,
					},
					[2] = "\n",
				},
			}
			DataRemoteEvent:FireServer(unpack(args))
		end
	end
end)

CastleGroupBox:AddToggle("AutoStartInferno", {
	Text = "Start Floor",
	Default = false,
	Callback = function(state)
		IsAutoJoiningCastle = state
	end,
})
Toggles.AutoStartInferno:OnChanged(function(state)
	IsAutoJoiningCastle = state
end)

CastleGroupBox:AddToggle("AutoStartInfernoCheckpoint", {
	Text = "Start Checkpoint",
	Default = false,
	Callback = function(state)
		IsAutoJoiningCastleCheckpoint = state
	end,
})
Toggles.AutoStartInfernoCheckpoint:OnChanged(function(state)
	IsAutoJoiningCastleCheckpoint = state
end)

local isAutoNextRoom = false
local maxRoomDistance = 100000
local visitedRooms = {}

CastleGroupBox:AddToggle("AutoRoom", {
	Text = "Auto Next Room",
	Default = false,
	Callback = function(state)
		isAutoNextRoom = state
	end,
})
Toggles.AutoRoom:OnChanged(function(state)
	isAutoNextRoom = state
end)

local function FindNearestFirePortal()
	local nearestPrompt, nearestPosition, roomName
	local shortestDistance = math.huge

	local worldFolder = workspace:FindFirstChild("__Main") and workspace.__Main:FindFirstChild("__World")

	if not worldFolder then
		return
	end

	for _, room in ipairs(worldFolder:GetChildren()) do
		if not visitedRooms[room.Name] and room:FindFirstChild("FirePortal") then
			local portal = room.FirePortal
			local prompt = portal:FindFirstChildWhichIsA("ProximityPrompt", true)

			if prompt then
				local distance = (HumanoidRootPart.Position - portal.Position).Magnitude

				if distance < shortestDistance and distance <= maxRoomDistance then
					shortestDistance = distance
					nearestPrompt = prompt
					nearestPosition = portal.Position
					roomName = room.Name
				end
			end
		end
	end

	return nearestPrompt, nearestPosition, roomName
end

task.spawn(function()
	while true do
		task.wait(0.1)

		if isAutoNextRoom and HumanoidRootPart then
			local prompt, position, roomName = FindNearestFirePortal()

			if prompt and position and roomName then
				for i = 1, 5 do
					Character:PivotTo(CFrame.new(position + Vector3.new(0, 3, 0)))
					task.wait(0.01)
				end

				for i = 1, 50 do
					fireproximityprompt(prompt)
					task.wait(0.01)
				end
				visitedRooms[roomName] = true
			end
		end
	end
end)

DiscordGroupBox = Tabs.Main:AddLeftGroupbox("Discord")
DiscordGroupBox:AddButton("Join Discord", function()
	setclipboard("https://discord.gg/77aZtNXRVg", true)
	Library:Notify("Discord link copied to clipboard")
end)

CreditsGroupBox = Tabs.Main:AddRightGroupbox("Credits")
CreditsGroupBox:AddLabel("Script by: DevRy")
CreditsGroupBox:AddLabel("UI by: Obsidian")
CreditsGroupBox:AddDivider()
CreditsGroupBox:AddLabel("Thank you, enjoy!")


local MenuGroup = Tabs["UI Settings"]:AddLeftGroupbox("Menu")

MenuGroup:AddToggle("KeybindMenuOpen", {
	Default = Library.KeybindFrame.Visible,
	Text = "Open Keybind Menu",
	Callback = function(value)
		Library.KeybindFrame.Visible = value
	end,
})
MenuGroup:AddToggle("ShowCustomCursor", {
	Text = "Custom Cursor",
	Default = true,
	Callback = function(Value)
		Library.ShowCustomCursor = Value
	end,
})
MenuGroup:AddDropdown("NotificationSide", {
	Values = { "Left", "Right" },
	Default = "Right",
	Text = "Notification Side",
	Callback = function(Value)
		Library:SetNotifySide(Value)
	end,
})
MenuGroup:AddDropdown("DPIDropdown", {
	Values = { "50%", "75%", "100%", "125%", "150%", "175%", "200%" },
	Default = "100%",
	Text = "DPI Scale",
	Callback = function(Value)
		Value = Value:gsub("%%", "")
		local DPI = tonumber(Value)
		Library:SetDPIScale(DPI)
	end,
})
MenuGroup:AddDivider()
MenuGroup:AddLabel("Menu bind")
	:AddKeyPicker("MenuKeybind", { Default = "RightShift", NoUI = true, Text = "Menu keybind" })
MenuGroup:AddButton("Unload", function()
	Library:Unload()
end)
Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("DevRYHub")
SaveManager:SetFolder("DevRYHub/arise-crossover")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()
