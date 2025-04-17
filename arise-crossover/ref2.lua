---@diagnostic disable: deprecated
-- Kupal Hub | Arise crossover v0.3beta
-- Main UI and configuration settings

-- Services
local PlayerService = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")

-- Player variables
local LocalPlayer = PlayerService.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
if not PlayerGui then return end


-- Load UI libraries
local FluentLib = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Create main window
local Window = FluentLib:CreateWindow({
    Title = "Kupal Hub | Arise crossover",
    SubTitle = "   v0.3beta",
    TabWidth = 80,
    Size = UDim2.fromOffset(490, 360),
    Acrylic = true,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Create tabs
local Tabs = {
    Home = Window:AddTab({ Title = "Home"}),
    Main = Window:AddTab({ Title = "Main"}),
    Rank = Window:AddTab({ Title = "Rank"}),
    Dungeon = Window:AddTab({ Title = "Dungeon"}),
    Infernal = Window:AddTab({ Title = "Infernal"}),
    Config = Window:AddTab({ Title = "Config"}),
    Teleport = Window:AddTab({ Title = "Teleport"}),
    Settings = Window:AddTab({ Title = "Settings"})
}

-- Discord button
Tabs.Home:AddButton({
    Title = "Copy Discord Invite",
    Description = "discord.gg/8Qev5g6r, join for more leaks",
    Callback = function()
        setClipboard("https://discord.gg/8Qev5g6r")
    end
})

-- Initialize common variables
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local EnemiesFolder = workspace:WaitForChild("__Main"):WaitForChild("__Enemies"):WaitForChild("Client")
local DataRemoteEvent = ReplicatedStorage:WaitForChild("BridgeNet2"):WaitForChild("dataRemoteEvent")

-- Character added event
LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    HumanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
end)

-- ===== TELEPORT PLAYER SECTION =====
Tabs.Teleport:AddSection(" [ Teleport Player ]")

-- Function to get all other players
local function GetOtherPlayers()
    local playerList = {}
    for _, player in ipairs(PlayerService:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerList, player.Name)
        end
    end
    return playerList
end

-- Player teleport variables
local selectedPlayer = nil
local isFollowingPlayer = false

-- Player selection dropdown
Tabs.Teleport:AddDropdown("PlayerDropdown", {
    Title = "Select Player",
    Values = GetOtherPlayers(),
    Multi = false,
    Default = nil,
    Callback = function(selected)
        selectedPlayer = PlayerService:FindFirstChild(selected)
    end
})

-- Toggle to follow selected player
Tabs.Teleport:AddToggle("FollowToggle", {
    Title = "Auto Teleport",
    Default = false,
    Callback = function(state)
        isFollowingPlayer = state
    end
})

-- Update dropdown when players join/leave
PlayerService.PlayerAdded:Connect(function()
    playerDropdown:SetValues(GetOtherPlayers())
end)

PlayerService.PlayerRemoving:Connect(function()
    playerDropdown:SetValues(GetOtherPlayers())
end)

-- Player following loop
task.spawn(function()
    while true do
        if isFollowingPlayer and selectedPlayer and selectedPlayer.Character and 
           selectedPlayer.Character:FindFirstChild("HumanoidRootPart") and HumanoidRootPart then
            local targetPosition = selectedPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, 0, 0)
            HumanoidRootPart.CFrame = CFrame.new(targetPosition)
        end
        task.wait(0.01)
    end
end)

-- ===== MAIN FARMING SECTION =====
Tabs.Main:AddSection(" [ Farming ]")

-- Farming variables
local isAutoFarming = false
local isTweening = false
local currentTarget = nil
local maxDistance = 1e9  -- Maximum distance to target
local tweenSpeed = 200   -- Movement speed
local farmingMode = "Tween"  -- Movement mode (Tween or Teleport)
local farmingDelay = 0.1  -- Delay between actions

-- Function to check if an enemy is alive
local function IsEnemyAlive(enemy)
    local healthLabel = enemy:FindFirstChild("HealthBar") and 
                       enemy.HealthBar:FindFirstChild("Main") and 
                       enemy.HealthBar.Main:FindFirstChild("Bar") and 
                       enemy.HealthBar.Main.Bar:FindFirstChild("Amount")
                       
    if healthLabel and healthLabel:IsA("TextLabel") then
        local healthText = healthLabel.Text
        return not (healthText == "" or healthText == "0" or healthText:find("0 HP"))
    end
    
    return false
end

-- Function to find the nearest enemy
local function FindNearestEnemy()
    local nearest, nearestDist = nil, math.huge
    
    for _, enemy in pairs(EnemiesFolder:GetChildren()) do
        if enemy:IsA("Model") and 
           enemy:FindFirstChild("HumanoidRootPart") and 
           IsEnemyAlive(enemy) then
           
            local distance = (enemy.HumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude
            if distance < nearestDist and distance <= maxDistance then
                nearestDist = distance
                nearest = enemy
            end
        end
    end
    
    return nearest
end

-- Function to move to position using tween
local function TweenToPosition(position)
    local distance = (HumanoidRootPart.Position - position).Magnitude
    local duration = distance / tweenSpeed
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(HumanoidRootPart, tweenInfo, {CFrame = CFrame.new(position)})
    
    isTweening = true
    tween:Play()
    tween.Completed:Wait()
    isTweening = false
end

-- Function to attack enemy
local function AttackEnemy(enemy)
    local args = {
        [1] = {
            [1] = {
                ["Event"] = "PunchAttack",
                ["Enemy"] = enemy.Name
            },
            [2] = "\4"
        }
    }
    
    DataRemoteEvent:FireServer(unpack(args))
end

-- Attack loop
task.spawn(function()
    while true do
        if isAutoFarming and currentTarget and IsEnemyAlive(currentTarget) then
            AttackEnemy(currentTarget)
        end
        task.wait(0.01)
    end
end)

-- Main farming loop
task.spawn(function()
    while true do
        if isAutoFarming and HumanoidRootPart and not isTweening then
            local enemy = FindNearestEnemy()
            
            if enemy and enemy:FindFirstChild("HumanoidRootPart") then
                currentTarget = enemy
                local targetPosition = enemy.HumanoidRootPart.Position + Vector3.new(0, -2, 3)
                
                if farmingMode == "Tween" then
                    TweenToPosition(targetPosition)
                elseif farmingMode == "Teleport" then
                    for i = 1, 3 do
                        HumanoidRootPart.CFrame = CFrame.new(targetPosition)
                        task.wait(0.01)
                    end
                end
            end
            
            task.wait(farmingDelay)
        else
            currentTarget = nil
            task.wait(0.1)
        end
    end
end)

-- Toggle for auto farming
Tabs.Main:AddToggle("AutoFarmEnemies", {
    Title = "Auto Farm Nearest",
    Default = false,
    Callback = function(state)
        isAutoFarming = state
    end
})

-- Farming settings section
Tabs.Main:AddSection(" [ Setting Farm ]")

-- Tween speed slider
Tabs.Main:AddSlider("TweenSpeedSlider", {
    Title = "Tween Speed",
    Default = 130,
    Min = 100,
    Max = 450,
    Rounding = 1,
    Callback = function(value)
        tweenSpeed = value
    end
})

-- Movement mode dropdown
Tabs.Main:AddDropdown("ModeDropdown", {
    Title = "Select Mode",
    Values = {"Tween", "Teleport"},
    Multi = false,
    Default = 1,
    Callback = function(value)
        farmingMode = value
    end
})

-- Delay slider
Tabs.Main:AddSlider("DelaySlider", {
    Title = "Delay Between",
    Default = 0.1,
    Min = 0.1,
    Max = 5,
    Rounding = 2,
    Callback = function(value)
        farmingDelay = value
    end
})

-- ===== BOSS FARMING SECTION =====
-- Variables for boss farming
local isAutoFarmingBoss = false
local maxBossDistance = 1000000000000000000000000000000000000000000000000000000000000000000000000000
local bossSizeTarget = Vector3.new(8, 12, 2.5)

-- Function to find boss by hitbox size
local function FindBossEnemy()
    local nearest, nearestDist = nil, math.huge
    
    for _, enemy in pairs(EnemiesFolder:GetChildren()) do
        local hitbox = enemy:FindFirstChild("Hitbox")
        
        if enemy:IsA("Model") and hitbox and IsEnemyAlive(enemy) and hitbox.Size == bossSizeTarget then
            local distance = (hitbox.Position - HumanoidRootPart.Position).Magnitude
            
            if distance < nearestDist and distance <= maxBossDistance then
                nearestDist = distance
                nearest = enemy
            end
        end
    end
    
    return nearest
end

-- Boss farming loop
task.spawn(function()
    while task.wait(0.01) do
        if isAutoFarmingBoss and HumanoidRootPart then
            local boss = FindBossEnemy()
            
            if boss then
                local hitbox = boss:FindFirstChild("Hitbox")
                
                if hitbox then
                    for i = 1, 6 do
                        HumanoidRootPart.CFrame = CFrame.new(hitbox.Position + Vector3.new(0, 0, 3))
                        AttackEnemy(boss)
                        task.wait(0.01)
                    end
                end
            end
        end
    end
end)

-- Boss farming section
Tabs.Main:AddSection(" [ Boss Farming ]")

-- Toggle for boss farming
Tabs.Main:AddToggle("AutoFarmBoss", {
    Title = "Auto Farm Boss",
    Default = false,
    Callback = function(state)
        isAutoFarmingBoss = state
    end
})

-- ===== BERU FARMING SECTION =====
-- Variables for Beru farming
local isAutoFarmingBeru = false
local beruSizeTargets = {
    Vector3.new(10, 15, 3.15),
    Vector3.new(14, 21, 4.375),
    Vector3.new(11.4, 17.1, 3.562)
}

-- Function to find Beru enemy by hitbox size
local function FindBeruEnemy()
    for _, targetSize in ipairs(beruSizeTargets) do
        for _, enemy in pairs(EnemiesFolder:GetChildren()) do
            if enemy:IsA("Model") and IsEnemyAlive(enemy) then
                local hitbox = enemy:FindFirstChild("Hitbox")
                
                if hitbox and (hitbox.Size - targetSize).Magnitude < 0.1 then
                    return enemy
                end
            end
        end
    end
    
    return nil
end

-- Beru farming loop
task.spawn(function()
    while task.wait(0.1) do
        if isAutoFarmingBeru and HumanoidRootPart then
            local beru = FindBeruEnemy()
            
            if beru and beru:FindFirstChild("Hitbox") then
                for i = 1, 5 do
                    HumanoidRootPart.CFrame = CFrame.new(beru.Hitbox.Position + Vector3.new(0, -5, 3))
                    AttackEnemy(beru)
                    task.wait(0.1)
                end
            else
                HumanoidRootPart.CFrame = CFrame.new(3877.32227, 60.1332474, 3074.55664)
            end
        end
    end
end)

-- Beru farming section
Tabs.Main:AddSection(" [ Dedu Farm ]")

-- Toggle for Beru farming
Tabs.Main:AddToggle("AutoFarmBer", {
    Title = "Auto Beru",
    Default = false,
    Callback = function(state)
        isAutoFarmingBeru = state
    end
})

-- ===== DUNGEON SECTION =====
Tabs.Dungeon:AddSection(" [ Dungeon ]")

-- World folder reference
local WorldFolder = workspace:WaitForChild("__Main"):WaitForChild("__World")

-- Dungeon farming variables
local isDungeonFarming = false
local isDungeonTweening = false
local maxDungeonDistance = 100000
local dungeonTweenSpeed = 130
local currentRoom = 1
local dungeonMovementMode = "Tween"
local dungeonActionDelay = 0.1
local currentDungeonTarget = nil

-- Function to move to position using tween in dungeon
local function DungeonTweenToPosition(position)
    local distance = (HumanoidRootPart.Position - position).Magnitude
    local duration = distance / dungeonTweenSpeed
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(HumanoidRootPart, tweenInfo, {CFrame = CFrame.new(position)})
    
    isDungeonTweening = true
    tween:Play()
    tween.Completed:Wait()
    isDungeonTweening = false
end

-- Function to find the next room entrance
local function FindNextRoomEntrance()
    local nextRoom = WorldFolder:FindFirstChild("Room_" .. tostring(currentRoom + 1))
    if nextRoom then
        local entrance = nextRoom:FindFirstChild("Entrace")
        if entrance and entrance:IsA("BasePart") then
            return entrance.Position, currentRoom + 1
        end
    end
    
    return nil, nil
end

-- Function to determine current room
local function DetermineCurrentRoom()
    for i = 1, 100 do
        local room = WorldFolder:FindFirstChild("Room_" .. tostring(i))
        if room and (HumanoidRootPart.Position - room.Position).Magnitude <= 80 then
            return i
        end
    end
    
    return nil
end

-- Main dungeon farming loop
task.spawn(function()
    while true do
        if isDungeonFarming and HumanoidRootPart and not isDungeonTweening then
            local enemy = FindNearestEnemy() -- Reusing function from main farming
            
            if enemy and enemy:FindFirstChild("HumanoidRootPart") then
                currentDungeonTarget = enemy
                local targetPosition = enemy.HumanoidRootPart.Position + Vector3.new(0, 0, 3)
                
                if dungeonMovementMode == "Tween" then
                    DungeonTweenToPosition(targetPosition)
                elseif dungeonMovementMode == "Teleport" then
                    for i = 1, 3 do
                        HumanoidRootPart.CFrame = CFrame.new(targetPosition)
                        task.wait(0.01)
                    end
                end
                
                task.wait(dungeonActionDelay)
            else
                currentDungeonTarget = nil
                local nextRoomPos, nextRoomNum = FindNextRoomEntrance()
                
                if nextRoomPos then
                    for i = 1, 5 do
                        HumanoidRootPart.CFrame = CFrame.new(nextRoomPos)
                        task.wait(0.01)
                    end
                    
                    currentRoom = nextRoomNum
                end
                
                task.wait(0.1)
            end
        else
            currentDungeonTarget = nil
            task.wait(0.1)
        end
    end
end)

-- Attack loop for dungeon
task.spawn(function()
    while true do
        if isDungeonFarming and currentDungeonTarget and IsEnemyAlive(currentDungeonTarget) then
            AttackEnemy(currentDungeonTarget)
        end
        
        task.wait(0.01)
    end
end)

-- Update room tracker
task.spawn(function()
    while task.wait(1) do
        if HumanoidRootPart then
            local detectedRoom = DetermineCurrentRoom()
            if detectedRoom then
                currentRoom = detectedRoom
            end
        end
    end
end)

-- Toggle for dungeon farming
Tabs.Dungeon:AddToggle("AutoFarmToggle", {
    Title = "Auto Farm Dungeon",
    Default = false,
    Callback = function(state)
        isDungeonFarming = state
    end
})

-- Dungeon place ID
local dungeonPlaceId = 128336380114944
local selectedDungeon = 1

-- Functions for dungeon management
local function BuyDungeonTicket()
    local args = {
        [1] = {
            [1] = {
                ["Type"] = "Gems",
                ["Event"] = "DungeonAction",
                ["Action"] = "BuyTicket"
            },
            [2] = "\n"
        }
    }
    DataRemoteEvent:FireServer(unpack(args))
end

local function CreateDungeon()
    local args = {
        [1] = {
            [1] = {
                ["Event"] = "DungeonAction",
                ["Action"] = "Create"
            },
            [2] = "\n"
        }
    }
    DataRemoteEvent:FireServer(unpack(args))
end

local function StartDungeon()
    local args = {
        [1] = {
            [1] = {
                ["Dungeon"] = tonumber(selectedDungeon),
                ["Event"] = "DungeonAction",
                ["Action"] = "Start"
            },
            [2] = "\n"
        }
    }
    DataRemoteEvent:FireServer(unpack(args))
end

-- Toggle for auto starting dungeon
Tabs.Dungeon:AddToggle("AutoDungeonStart", {
    Title = "Auto Start Dungeon",
    Default = false,
    Callback = function(state)
        if state then
            if game.PlaceId ~= dungeonPlaceId then
                task.spawn(function()
                    BuyDungeonTicket()
                    task.wait(0.5)
                    CreateDungeon()
                    task.wait(0.01)
                    StartDungeon()
                end)
            else
                print("Auto Dungeon disabled because already in the correct Place ID:", dungeonPlaceId)
            end
        end
    end
})

-- Toggle for instant dungeon restart when near end
Tabs.Dungeon:AddToggle("InstantLeave", {
    Title = "Instant Start",
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
    end
})

-- Dungeon settings section
Tabs.Dungeon:AddSection(" [ Setting ]")

-- Dungeon tween speed slider
Tabs.Dungeon:AddSlider("Slider", {
    Title = "Tween Speed",
    Default = 130,
    Min = 100,
    Max = 450,
    Rounding = 1,
    Callback = function(value)
        dungeonTweenSpeed = value
    end
})

-- Dungeon movement mode dropdown
Tabs.Dungeon:AddDropdown("Dropdown", {
    Title = "Select Mode",
    Values = {"Tween", "Teleport"},
    Multi = false,
    Default = 1,
    Callback = function(value)
        dungeonMovementMode = value
    end
})

-- Dungeon delay slider
Tabs.Dungeon:AddSlider("Slider", {
    Title = "Delay Between",
    Default = 0.1,
    Min = 0.1,
    Max = 5,
    Rounding = 2,
    Callback = function(value)
        dungeonActionDelay = value
    end
})

-- ===== RANK SECTION =====
local rankSection = Tabs.Rank:AddSection(" [ Ranking ]")

-- Auto test rank variables
local isAutoTestingRank = false

-- Toggle for auto test rank
Tabs.Rank:AddToggle("AutoTestRank", {
    Title = "Auto Test Rank",
    Default = false,
    Callback = function(state)
        isAutoTestingRank = state
    end
})

-- Auto test rank loop
task.spawn(function()
    while task.wait(1) do
        if isAutoTestingRank and game.PlaceId ~= dungeonPlaceId then
            local args = {
                [1] = {
                    [1] = {
                        ["Event"] = "DungeonAction",
                        ["Action"] = "TestEnter"
                    },
                    [2] = "\n"
                }
            }
            DataRemoteEvent:FireServer(unpack(args))
        end
    end
end)

-- Auto rank farming variables
local isAutoRankFarming = false
local isRankTweening = false
local maxRankDistance = 10000
local rankTweenSpeed = 160
local rankCurrentRoom = 1
local rankActionDelay = 0.1
local rankMovementMode = "Tween"

-- Function to check for enemies in the area
local function AreEnemiesPresent()
    for _, enemy in pairs(EnemiesFolder:GetChildren()) do
        if enemy:IsA("Model") and IsEnemyAlive(enemy) then
            return true
        end
    end
    
    return false
end

-- Function to find the next up door in rank test
local function FindNextUpDoor()
    rankCurrentRoom = rankCurrentRoom + 1
    local nextRoom = WorldFolder:FindFirstChild("Room_" .. tostring(rankCurrentRoom))
    
    if nextRoom then
        local upDoor = nextRoom:FindFirstChild("UpDoor")
        
        if upDoor and upDoor:IsA("BasePart") then
            print("Moving to Room_" .. rankCurrentRoom)
            return upDoor.Position
        end
    end
    
    return nil
end

-- Variable for current rank target
local currentRankTarget = nil

-- Main rank farming loop
task.spawn(function()
    while true do
        if isAutoRankFarming and HumanoidRootPart and not isRankTweening then
            local enemy = FindNearestEnemy()
            
            if enemy and enemy:FindFirstChild("HumanoidRootPart") then
                currentRankTarget = enemy
                local targetPosition = enemy.HumanoidRootPart.Position + Vector3.new(0, -2, 3)
                
                if rankMovementMode == "Tween" then
                    DungeonTweenToPosition(targetPosition) -- Reusing dungeon tween function
                elseif rankMovementMode == "Teleport" then
                    for i = 1, 2 do
                        HumanoidRootPart.CFrame = CFrame.new(targetPosition)
                        task.wait(0.01)
                    end
                end
                
                task.wait(rankActionDelay)
            else
                currentRankTarget = nil
                task.wait(0.1)
            end
        else
            currentRankTarget = nil
            task.wait(0.1)
        end
    end
end)

-- Attack loop for rank
task.spawn(function()
    while true do
        if isAutoRankFarming and currentRankTarget and IsEnemyAlive(currentRankTarget) then
            AttackEnemy(currentRankTarget)
        end
        
        task.wait(0.1)
    end
end)

-- External function reference placeholder
local function handleEnemyFarm() end

-- Farming loop call
task.spawn(function()
    while true do
        if isAutoRankFarming and HumanoidRootPart and not isRankTweening then
            handleEnemyFarm()
        else
            task.wait(0.1)
        end
    end
end)

-- Room transition loop
task.spawn(function()
    while task.wait(0.1) do
        if isAutoRankFarming and not AreEnemiesPresent() then
            local nextDoorPos = FindNextUpDoor()
            
            if nextDoorPos then
                for i = 1, 6 do
                    HumanoidRootPart.CFrame = CFrame.new(nextDoorPos + Vector3.new(0, -6, 0))
                    task.wait(0.01)
                end
            end
        end
    end
end)

-- Toggle for auto rank
Tabs.Rank:AddToggle("AutoRankToggle", {
    Title = "Auto Rank",
    Default = false,
    Callback = function(state)
        isAutoRankFarming = state
    end
})

-- Rank settings section
rankSection = Tabs.Rank:AddSection(" [ Setting ]")

-- Rank tween speed slider
Tabs.Rank:AddSlider("Slider", {
    Title = "Tween Speed",
    Default = 130,
    Min = 100,
    Max = 450,
    Rounding = 1,
    Callback = function(value)
        rankTweenSpeed = value
    end
})

-- Rank movement mode dropdown
Tabs.Rank:AddDropdown("Dropdown", {
    Title = "Select Mode",
    Values = {"Tween", "Teleport"},
    Multi = false,
    Default = 1,
    Callback = function(value)
        rankMovementMode = value
    end
})

-- Rank delay slider
Tabs.Rank:AddSlider("Slider", {
    Title = "Delay Between",
    Default = 0.1,
    Min = 0.1,
    Max = 5,
    Rounding = 2,
    Callback = function(value)
        rankActionDelay = value
    end
})

-- ===== INFERNAL CASTLE SECTION =====
-- Infernal variables
local isInfernalFarming = false
local maxInfernalDistance = 1e12
local infernalTweenSpeed = 120
local infernalCurrentRoom = 1

-- Function to move to position for infernal
function InfernalTweenToPosition(position)
    local distance = (HumanoidRootPart.Position - position).Magnitude
    local duration = distance / infernalTweenSpeed
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(HumanoidRootPart, tweenInfo, {CFrame = CFrame.new(position)})
    
    isDungeonTweening = true  -- Reusing dungeon tweening flag
    tween:Play()
    tween.Completed:Wait()
    isDungeonTweening = false
end

-- Infernal farming loop
task.spawn(function()
    while task.wait(0.05) do
        if isInfernalFarming then
            -- Check for fire portal in current room
            local currentRoom = WorldFolder:FindFirstChild("Room_" .. tostring(infernalCurrentRoom))
            
            if currentRoom and currentRoom:FindFirstChild("FirePortal") and 
               currentRoom.FirePortal:FindFirstChild("ProximityPrompt") then
                
                local portalPosition = currentRoom.FirePortal.Position
                
                if HumanoidRootPart then
                    HumanoidRootPart.CFrame = CFrame.new(portalPosition + 
                        Vector3.new(math.random(-2, 2), -3, math.random(-2, 2)))
                end
                
                -- Send promote event
                DataRemoteEvent:FireServer({
                    [1] = {
                        ["Event"] = "Promote"
                    },
                    [2] = "\4"
                })
            else
                infernalCurrentRoom = infernalCurrentRoom + 1
            end
            
            -- Farm enemies if not tweening
            if not isDungeonTweening and HumanoidRootPart then
                local enemy = FindNearestEnemy()
                
                if enemy and enemy:FindFirstChild("HumanoidRootPart") then
                    InfernalTweenToPosition(enemy.HumanoidRootPart.Position + Vector3.new(0, 0, 3))
                    AttackEnemy(enemy)
                end
            end
        end
    end
end)

-- Infernal Castle section
Tabs.Infernal:AddSection(" [ Infernal Castle ]")

-- Toggle for infernal farming
Tabs.Infernal:AddToggle("AutoInfernoFarm", {
    Title = "Auto Inferno Farm",
    Default = false,
    Callback = function(state)
        isInfernalFarming = state
    end
})

-- Auto join castle variables
local isAutoJoiningCastle = false

-- Auto join castle loop
task.spawn(function()
    while task.wait(1) do
        if isAutoJoiningCastle and game.PlaceId ~= dungeonPlaceId then
            local args = {
                [1] = {
                    [1] = {
                        ["Event"] = "JoinCastle"
                    },
                    [2] = "\n"
                }
            }
            DataRemoteEvent:FireServer(unpack(args))
        end
    end
end)

-- Toggle for auto join castle
Tabs.Infernal:AddToggle("AutoStartInferno", {
    Title = "Auto Start Inferno",
    Default = false,
    Callback = function(state)
        isAutoJoiningCastle = state
    end
})

-- Auto room transition variables
local isAutoNextRoom = false
local maxRoomDistance = 5000
local visitedRooms = {}

-- Toggle for auto next room
Tabs.Infernal:AddToggle("AutoRoom", {
    Title = "Auto Next Room",
    Default = false,
    Callback = function(state)
        isAutoNextRoom = state
    end
})

-- Function to find nearest fire portal
local function FindNearestFirePortal()
    local nearestPrompt, nearestPosition, roomName
    local shortestDistance = math.huge
    
    local worldFolder = workspace:FindFirstChild("__Main") and
                       workspace.__Main:FindFirstChild("__World")
    
    if not worldFolder then return end
    
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

-- Auto room transition loop
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

-- ===== CONFIG SECTION =====
Tabs.Config:AddSection(" [ Configs ]")

-- Auto punch (fast click) variables
local isAutoPunching = false
local punchRange = 100

-- Auto punch loop
task.spawn(function()
    while task.wait(0.01) do
        if isAutoPunching and HumanoidRootPart then
            local nearestEnemy = FindNearestEnemy()
            if nearestEnemy then
                AttackEnemy(nearestEnemy)
            end
        end
    end
end)


-- Auto Arise variables
local isAutoArising = false
local ariseRange = 100

-- Function to capture enemy
local function CaptureEnemy(enemy)
    if enemy then
        local args = {
            [1] = {
                [1] = {
                    ["Event"] = "EnemyCapture",
                    ["Enemy"] = enemy.Name
                },
                [2] = "\4"
            }
        }
        DataRemoteEvent:FireServer(unpack(args))
    end
end

-- Auto arise loop
task.spawn(function()
    while task.wait(0.01) do
        if isAutoArising and HumanoidRootPart then
            local nearestEnemy = FindNearestEnemy()
            if nearestEnemy then
                CaptureEnemy(nearestEnemy)
            end
        end
    end
end)

-- Toggle for auto arise
Tabs.Config:AddToggle("AutoArise", {
    Title = "Auto Arise",
    Default = false,
    Callback = function(state)
        isAutoArising = state
    end
})

-- Auto destroy variables
local isAutoDestroying = false
local destroyRange = 1000

-- Function to destroy enemy
local function DestroyEnemy(enemy)
    if enemy then
        local args = {
            [1] = {
                [1] = {
                    ["Event"] = "EnemyDestroy",
                    ["Enemy"] = enemy.Name
                },
                [2] = "\4"
            }
        }
        DataRemoteEvent:FireServer(unpack(args))
    end
end

-- Auto destroy loop
task.spawn(function()
    while task.wait(0.01) do
        if isAutoDestroying and HumanoidRootPart then
            local nearestEnemy = FindNearestEnemy()
            if nearestEnemy then
                DestroyEnemy(nearestEnemy)
            end
        end
    end
end)

-- Toggle for auto destroy
Tabs.Config:AddToggle("AutoDestroy", {
    Title = "Auto Destroy",
    Default = false,
    Callback = function(state)
        isAutoDestroying = state
    end
})

-- Auto attack variables
local isAutoAttackEnabled = false

-- Toggle for auto attack in settings
Tabs.Config:AddToggle("AutoAttack", {
    Title = "Auto Attack",
    Default = true,
    Callback = function(state)
        if state then
            isAutoAttackEnabled = true
            
            local args = {
                [1] = {
                    [1] = {
                        ["Event"] = "SettingsChange",
                        ["Setting"] = "AutoAttack"
                    },
                    [2] = "\n"
                }
            }
            
            DataRemoteEvent:FireServer(unpack(args))
        else
            isAutoAttackEnabled = false
            
            local args = {
                [1] = {
                    [1] = {
                        ["Event"] = "SettingsChange",
                        ["Setting"] = "AutoAttack"
                    },
                    [2] = "\n"
                }
            }
            
            DataRemoteEvent:FireServer(unpack(args))
        end
    end
})

-- ===== TELEPORT SECTION =====
Tabs.Teleport:AddSection(" [ Teleport ]")

-- Function to initialize player character references
local function InitializeCharacter()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
end

-- Initialize character
InitializeCharacter()

-- Handle character respawns
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.02)
    InitializeCharacter()
end)

-- Island teleport positions
local teleportLocations = {
    ["DBWorld"] = Vector3.new(-6295.89209, 27.198103, -73.7149353, 0, 0, 1, 0, 1, 0, -1, 0, 0),
    ["SoloWorld"] = Vector3.new(577.968262, 26.9623756, 261.452271),
    ["ChainsawWorld"] = Vector3.new(236.932678, 32.3960934, -4301.60547),
    ["BCWorld"] = CFrame.new(198.338684, 38.2076797, 4296.10938, 0.993159413, -0, -0.116766132, 0, 1, -0, 0.116766132, 0, 0.993159413),
    ["BleachWorld"] = CFrame.new(2641.79517, 44.9265289, -2645.07568, 0.780932784, -0, -0.624615133, 0, 1, -0, 0.624615133, 0, 0.780932784),
    ["OpWorld"] = CFrame.new(-2851.1062, 48.8987885, -2011.39526, 0.739920259, -0.0159788765, 0.672504723, 0.0134891849, 0.999869287, 0.0089157233, -0.672559321, 0.00247461651, 0.74003911),
    ["NarutoWorld"] = Vector3.new(-3380.2373, 28.8265285, 2257.26196),
    ["JojoWorld"] = Vector3.new(4816.31641, 29.4423409, -120.22998),
    ["Dedu"] = CFrame.new(4072.3396, 65.590126, 3325.87012, -0.852027357, 0, -0.523497283, 0, 1, 0, 0.523497283, 0, -0.852027357)
}

local selectedLocation = "None"

-- Island selection dropdown
Tabs.Teleport:AddDropdown("TeleportW", {
    Title = "Select Island",
    Values = {"None", "DBWorld", "SoloWorld", "ChainsawWorld", "BCWorld", "BleachWorld", "OpWorld", "NarutoWorld", "JojoWorld", "Dedu"},
    Multi = false,
    Default = 1,
    Callback = function(selected)
        selectedLocation = selected
    end
})

-- Button to teleport to selected location
Tabs.Teleport:AddButton({
    Title = "Teleport Island",
    Callback = function()
        local destination = teleportLocations[selectedLocation]
        
        if destination and HumanoidRootPart then
            for i = 1, 9 do
                if typeof(destination) == "CFrame" then
                    Character:PivotTo(destination)
                else
                    Character:PivotTo(CFrame.new(destination))
                end
                
                task.wait(0.01)
            end
        end
    end
})

-- Guild teleport section
Tabs.Teleport:AddSection(" [ Guilds ]")

-- Guild location
local guildLocation = CFrame.new(268.578613, 31.8532162, 157.246201, 1, 0, 0, 0, 1, 0, 0, 0, 1)

-- Button to teleport to guild
Tabs.Teleport:AddButton({
    Title = "Teleport Guild",
    Callback = function()
        HumanoidRootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        
        if not HumanoidRootPart then return end
        
        task.spawn(function()
            for i = 1, 6 do
                HumanoidRootPart.CFrame = guildLocation
                task.wait(0.01)
            end
        end)
    end
})

-- Shop locations
local runeShopLocation = CFrame.new(9517.85938, -205.738647, 309.181976, 0.807982385, -0.000137400144, -0.589206636, 0.000190894381, 1, 2.85793867e-05, 0.589206636, -0.000135567883, 0.807982385)
local exchangeShopLocation = CFrame.new(9593.41797, -205.569931, 310.082428, 0.78986758, -0.000135342547, 0.613277495, 0.000191303247, 1, -2.57007523e-05, -0.613277495, 0.000137622148, 0.78986758)

-- Function for quick teleport (teleport and return)
function QuickTeleport(destination)
    local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not rootPart then return end
    
    local originalPosition = rootPart.CFrame
    
    task.spawn(function()
        for i = 1, 3 do
            rootPart.CFrame = destination
            task.wait(0.25)
        end
        
        rootPart.CFrame = originalPosition
    end)
end

-- Buttons for shop teleports
Tabs.Teleport:AddButton({
    Title = "Rune Shop",
    Callback = function()
        QuickTeleport(runeShopLocation)
    end
})

Tabs.Teleport:AddButton({
    Title = "Exchange Shop",
    Callback = function()
        QuickTeleport(exchangeShopLocation)
    end
})

-- Teleport reset section
Tabs.Teleport:AddSection(" [ Teleport Reset ]")

-- Function to create teleport reset button
local function CreateTeleportResetButton(name, spawnPoint)
    Tabs.Teleport:AddButton({
        Title = name,
        Callback = function()
            -- Kill character to respawn
            LocalPlayer.Character:BreakJoints()
            
            -- Set spawn point
            local args = {
                [1] = {
                    [1] = {
                        ["Event"] = "ChangeSpawn",
                        ["Spawn"] = spawnPoint
                    },
                    [2] = "\n"
                }
            }
            
            DataRemoteEvent:FireServer(unpack(args))
        end
    })
end

-- Create teleport reset buttons for each world
CreateTeleportResetButton("DBWorld", "DBWorld")
CreateTeleportResetButton("JojoWorld", "JojoWorld")
CreateTeleportResetButton("NarutoWorld", "NarutoWorld")
CreateTeleportResetButton("OPWorld", "OPWorld")
CreateTeleportResetButton("SoloWorld", "SoloWorld")
CreateTeleportResetButton("BleachWorld", "BleachWorld")
CreateTeleportResetButton("ChainsawWorld", "ChainsawWorld")
CreateTeleportResetButton("BCWorld", "BCWorld")

-- ===== SETTINGS SECTION =====
-- Anti-AFK variables
local isAntiAFKEnabled = true
local antiAFKConnection = nil

-- Function to toggle anti-AFK
local function ToggleAntiAFK(state)
    if state then
        antiAFKConnection = LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
        
        print("Anti AFK Enabled")
    else
        if antiAFKConnection then
            antiAFKConnection:Disconnect()
            antiAFKConnection = nil
        end
        
        print("Anti AFK Disabled")
    end
end

-- Initialize anti-AFK
ToggleAntiAFK(isAntiAFKEnabled)

-- Full bright variables
local isFullBrightEnabled = false
local originalLightingSettings = {}
local fullBrightConnection = nil

-- Function to toggle full bright
local function ToggleFullBright(state)
    if state then
        -- Save original lighting settings
        originalLightingSettings.Brightness = Lighting.Brightness
        originalLightingSettings.ClockTime = Lighting.ClockTime
        originalLightingSettings.FogEnd = Lighting.FogEnd
        originalLightingSettings.GlobalShadows = Lighting.GlobalShadows
        
        -- Apply full bright settings
        Lighting.Brightness = 2
        Lighting.ClockTime = 12
        Lighting.FogEnd = 1000000
        Lighting.GlobalShadows = false
        
        -- Create connection to maintain settings
        fullBrightConnection = RunService.RenderStepped:Connect(function()
            Lighting.Brightness = 2
            Lighting.ClockTime = 12
            Lighting.FogEnd = 1000000
            Lighting.GlobalShadows = false
        end)
    else
        -- Disconnect full bright connection
        if fullBrightConnection then
            fullBrightConnection:Disconnect()
            fullBrightConnection = nil
        end
        
        -- Restore original lighting settings
        Lighting.Brightness = originalLightingSettings.Brightness or 1
        Lighting.ClockTime = originalLightingSettings.ClockTime or 14
        Lighting.FogEnd = originalLightingSettings.FogEnd or 1000
        Lighting.GlobalShadows = originalLightingSettings.GlobalShadows or true
    end
end

-- Game ID for server hopping
local gameId = 87039211657390

-- Function to server hop (join different server)
function ServerHop()
    print("Searching for another server...")
    local cursor = ""
    local servers = {}
    
    local function GetServers()
        local apiUrl = "https://games.roblox.com/v1/games/" .. 
                      gameId .. 
                      "/servers/Public?sortOrder=Asc&limit=100" .. 
                      (cursor ~= "" and "&cursor=" .. cursor or "")
                      
        local response = HttpService:JSONDecode(game:HttpGet(apiUrl))
        cursor = response.nextPageCursor or ""
        return response.data
    end
    
    repeat
        for _, server in ipairs(GetServers()) do
            if server.playing < 30 and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(gameId, server.id)
                return
            end
        end
    until cursor == ""
    
    warn("No suitable servers found.")
end

-- Function to rejoin current game
function RejoinServer()
    print("Rejoining server...")
    TeleportService:Teleport(gameId, LocalPlayer)
end

-- Function to find empty server
function ServerHopEmpty()
    print("Searching for empty server (less than 2 players)...")
    local cursor = ""
    
    local function GetServers()
        local apiUrl = "https://games.roblox.com/v1/games/" .. 
                      gameId .. 
                      "/servers/Public?sortOrder=Asc&limit=100" .. 
                      (cursor ~= "" and "&cursor=" .. cursor or "")
                      
        local response = HttpService:JSONDecode(game:HttpGet(apiUrl))
        cursor = response.nextPageCursor or ""
        return response.data
    end
    
    repeat
        for _, server in ipairs(GetServers()) do
            if server.playing < 2 and server.id ~= game.JobId then
                TeleportService:TeleportToPlaceInstance(gameId, server.id)
                return
            end
        end
    until cursor == ""
    
    warn("No empty servers found.")
end

-- Server section
Tabs.Settings:AddSection(" [ Server ]")

-- Server hop buttons
Tabs.Settings:AddButton({
    Title = "ServerHop",
    Callback = function()
        ServerHop()
    end
})

Tabs.Settings:AddButton({
    Title = "RejoinServer",
    Callback = function()
        RejoinServer()
    end
})

Tabs.Settings:AddButton({
    Title = "ServerHopEmpty",
    Callback = function()
        ServerHopEmpty()
    end
})

-- Settings section
Tabs.Settings:AddSection(" [ Settings ]")

-- Anti-AFK toggle
Tabs.Settings:AddToggle("Anti AFK", {
    Title = "Anti AFK",
    Default = true,
    Callback = function(state)
        ToggleAntiAFK(state)
    end
})

-- Full bright toggle
Tabs.Settings:AddToggle("Full Bright", {
    Title = "Full Bright",
    Default = false,
    Callback = function(state)
        ToggleFullBright(state)
    end
})

-- Shader button
Tabs.Settings:AddButton({
    Title = "Shader",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/randomstring0/pshade-ultimate/refs/heads/main/src/cd.lua'))()
    end
})

-- Configure save manager and interface manager
SaveManager:SetLibrary(FluentLib)
InterfaceManager:SetLibrary(FluentLib)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("SarynHub")
SaveManager:SetFolder("SarynHub/specific-game")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- Select default tab
Window:SelectTab(1)

-- Notification when script loads
FluentLib:Notify({
    Title = "Midnyt Hub",
    Content = "The script has been loaded.",
    Duration = 5
})

-- Load auto save config
SaveManager:LoadAutoloadConfig()
