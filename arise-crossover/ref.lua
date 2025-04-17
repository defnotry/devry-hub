-- DevRY:HUB v0.01alpha

-- UI Library
local Obsidian = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library = loadstring(game:HttpGet(Obsidian .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(Obsidian .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(Obsidian .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

Library.ForceCheckbox = false
Library.ShowToggleFrameInKeybinds = true

local Window = Library:CreateWindow({
	Title = "DevRY:HUB",
	Footer = "version: 0.0.1alpha",
	NotifySide = "Right",
	ShowCustomCursor = false,
	Center = true,
	AutoShow = true,
	Resizable = true,
	MobileButtonsSide = "Right",
    Font = Enum.Font.BuilderSans,
    Size = UDim2.fromOffset(480, 360),
	CornerRadius = 10,
    Position = UDim2.fromScale(0.5, 0.5),
    BackgroundTransparency = 0.5,
})

local Tabs = {
	Home = Window:AddTab("Home", "house"),
	Main = Window:AddTab("Main", "sword"),
	Teleport = Window:AddTab("Teleport", "map"),
	["UI Settings"] = Window:AddTab("UI Settings", "settings"),
}

-- Add Home Groupbox here
local CreditsGroupBox = Tabs.Home:AddLeftGroupbox("Credits")
local UICreditsGroupBox = Tabs.Home:AddLeftGroupbox("UI Credits")
local DonateGroupBox = Tabs.Home:AddRightGroupbox("Like the script?")

local AutoFarmGroupBox = Tabs.Main:AddLeftGroupbox("Farm Settings")
local AutoDungeonGroupBox = Tabs.Main:AddLeftGroupbox("Dungeon Settings")
local GamePassGroupBox = Tabs.Main:AddRightGroupbox("Game Pass")
local AutoCastleGroupBox = Tabs.Main:AddRightGroupbox("Infernal Castle")
local AutoRankGroupBox = Tabs.Main:AddRightGroupbox("Auto Rank Exam")

local TeleportGroupBox = Tabs.Teleport:AddLeftGroupbox("Teleport")
local TeleportResetGroupBox = Tabs.Teleport:AddRightGroupbox("Reset Spawn Point")

CreditsGroupBox:AddLabel("DevRY:HUB")
CreditsGroupBox:AddLabel("Created by DevRY")

UICreditsGroupBox:AddLabel("Obsidian UI Library")
UICreditsGroupBox:AddLabel("Created by deividcomsono")

-- https://ko-fi.com/devry
DonateGroupBox:AddLabel("Consider buying me a coffee!", true)
DonateGroupBox:AddButton("Buy coffee", function()
	setclipboard("https://ko-fi.com/devry")
	Library:Notify({
		Title = "Link Copied",
		Description = "Ko-fi donation link copied to clipboard!",
		Duration = 3,
	})
end)

AutoFarmGroupBox:AddToggle("AutoFarm", {
	Text = "Farm Nearest",
	Tooltip = "Auto farm the enemies around you",
	Default = false,
	Disabled = false,
	Visible = true,
	Risky = false,
	Callback = function(Value)
		print("Auto Farming: " .. Value)
	end,
})

AutoFarmGroupBox:AddSlider("AFTweenSpeed", {
	Text = "Tween Speed",
	Tooltip = "Adjust the tween speed of your character farming",
	Default = 130,
	Min = 100,
	Max = 450,
	Rounding = 1,
	Compact = false,
	Disabled = false,
	Visible = true,
	HideMax = true,
	Callback = function(Value)
		print("Tween Speed: " .. Value)
	end,
})

AutoFarmGroupBox:AddSlider("AFKillDelay", {
	Text = "Kill Delay",
	Tooltip = "Adjust the delay between kills",
	Default = 1,
	Min = 0.1,
	Max = 5,
	Rounding = 2,
	Compact = false,
	Disabled = false,
	Visible = true,
	HideMax = true,
	Callback = function(Value)
		print("Kill Delay: " .. Value)
	end,
})

AutoFarmGroupBox:AddDropdown("AFMode", {
	Values = { "Tween", "Teleport" },
	Default = 1,
	Multi = false,
	Text = "Farm Mode",
	Tooltip = "Select the farm mode you want to use",
	Searchable = false,
	Disabled = false,
	Visible = true,
	Callback = function(Value)
		print("Farm Mode: " .. Value)
	end,
})

AutoFarmGroupBox:AddDivider()

AutoFarmGroupBox:AddToggle("AFBossFarm", {
	Text = "Farm Bosses",
	Tooltip = "Auto farm the bosses around you",
	Default = false,
	Visible = true,
	Disabled = false,
	Callback = function(Value)
		print("Boss Farming: " .. Value)
	end,
})

AutoFarmGroupBox:AddToggle("AFZiruFarm", {
	Text = "Farm Ziru",
	Tooltip = "Auto farm ziru",
	Default = false,
	Visible = true,
	Disabled = false,
	Callback = function(Value)
		print("Ziru Farming: " .. Value)
	end,
})

AutoDungeonGroupBox:AddToggle("AFDungeon", {
	Text = "Auto Clear",
	Tooltip = "Auto clear the dungeon",
	Default = false,
	Visible = true,
	Disabled = false,
	Callback = function(Value)
		print("Dungeon Farming: " .. Value)
	end,
})

AutoDungeonGroupBox:AddToggle("AutoStartDungeon", {
	Text = "Auto Start",
	Tooltip = "Auto start the dungeon",
	Default = false,
	Visible = true,
	Disabled = false,
	Callback = function(Value)
		print("Auto Start Dungeon: " .. Value)
	end,
})

AutoDungeonGroupBox:AddToggle("InstantRestartDungeon", {
	Text = "Quick Reset",
	Tooltip = "Quickly restart the dungeon",
	Default = false,
	Visible = true,
	Disabled = false,
	Callback = function(Value)
		print("Quick Dungeon Reset: " .. Value)
	end,
})

AutoDungeonGroupBox:AddDivider()

AutoDungeonGroupBox:AddSlider("DungeonTweenSpeed", {
	Text = "Tween Speed",
	Tooltip = "Adjust the tween speed of your character farming",
	Default = 130,
	Min = 100,
	Max = 450,
	Rounding = 1,
	Compact = false,
	Disabled = false,
	Visible = true,
	HideMax = true,
	Callback = function(Value)
		print("Tween Speed: " .. Value)
	end,
})

AutoDungeonGroupBox:AddSlider("DungeonDelay", {
	Text = "Kill Delay",
	Tooltip = "Adjust the delay between dungeon kills",
	Default = 1,
	Min = 0.1,
	Max = 5,
	Rounding = 2,
	Compact = false,
	Disabled = false,
	Visible = true,
	HideMax = true,
	Callback = function(Value)
		print("Dungeon Delay: " .. Value)
	end,
})

AutoDungeonGroupBox:AddDropdown("DungeonMode", {
	Values = { "Tween", "Teleport" },
	Default = 1,
	Multi = false,
	Text = "Dungeon Mode",
	Tooltip = "Select the dungeon mode you want to use",
	Searchable = false,
	Disabled = false,
	Visible = true,
	Callback = function(Value)
		print("Dungeon Mode: " .. Value)
	end,
})

AutoCastleGroupBox:AddToggle("AFInfernalCastle", {
	Text = "Auto Infernal Castle",
	Tooltip = "Auto clear enemies in the infernal castle",
	Default = false,
	Visible = true,
	Disabled = false,
	Callback = function(Value)
		print("Infernal Castle Farming: " .. Value)
	end,
})

AutoCastleGroupBox:AddToggle("AutoStartCastle", {
	Text = "Auto Start Castle",
	Tooltip = "Auto start the infernal castle",
	Default = false,
	Visible = true,
	Disabled = false,
	Callback = function(Value)
		print("Auto Start Castle: " .. Value)
	end,
})

AutoCastleGroupBox:AddToggle("CastleAutoNextRoom", {
	Text = "Auto Next Room",
	Tooltip = "Auto go to the next room in the infernal castle",
	Default = false,
	Visible = true,
	Disabled = false,
	Callback = function(Value)
		print("Auto Next Room: " .. Value)
	end,
})

AutoRankGroupBox:AddToggle("AutoRank", {
	Text = "Auto Start Exam",
	Tooltip = "Auto start the rank exam",
	Default = false,
	Visible = true,
	Disabled = false,
	Callback = function(Value)
		print("Auto Start Rank Exam: " .. Value)
	end,
})

AutoRankGroupBox:AddToggle("AutoClearRank", {
	Text = "Auto Clear Exam",
	Tooltip = "Auto clear the rank exam",
	Default = false,
	Visible = true,
	Disabled = false,
	Callback = function(Value)
		print("Auto Clear Exam: " .. Value)
	end,
})

AutoRankGroupBox:AddDivider()

AutoRankGroupBox:AddSlider("RankTweenSpeed", {
	Text = "Tween Speed",
	Tooltip = "Adjust the tween speed of your character clearing the rank exam",
	Default = 130,
	Min = 100,
	Max = 450,
	Rounding = 1,
	Compact = false,
	Disabled = false,
	Visible = true,
	HideMax = true,
	Callback = function(Value)
		print("Rank Tween Speed: " .. Value)
	end,
})

AutoRankGroupBox:AddSlider("RankKillDelay", {
	Text = "Kill Delay",
	Tooltip = "Adjust the delay between rank exam kills",
	Default = 1,
	Min = 0.1,
	Max = 5,
	Rounding = 2,
	Compact = false,
	Disabled = false,
	Visible = true,
	HideMax = true,
	Callback = function(Value)
		print("Rank Kill Delay: " .. Value)
	end,
})

AutoRankGroupBox:AddDropdown("RankMode", {
	Values = { "Tween", "Teleport" },
	Default = 1,
	Multi = false,
	Text = "Rank Mode",
	Tooltip = "Select the rank mode you want to use",
	Searchable = false,
	Disabled = false,
	Visible = true,
	Callback = function(Value)
		print("Rank Mode: " .. Value)
	end,
})

GamePassGroupBox:AddToggle("GPAutoArise", {
	Text = "Auto Arise",
	Tooltip = "Auto arise enemies",
	Default = false,
	Visible = true,
	Disabled = false,
	Callback = function(Value)
		print("Auto Arise: " .. Value)
	end,
})

GamePassGroupBox:AddToggle("GPAutoDestroy", {
	Text = "Auto Destroy",
	Tooltip = "Auto destroy enemies",
	Default = false,
	Visible = true,
	Disabled = false,
	Callback = function(Value)
		print("Auto Destroy: " .. Value)
	end,
})

GamePassGroupBox:AddToggle("GPAutoAttack", {
	Text = "Auto Attack",
	Tooltip = "Auto attack enemies",
	Default = false,
	Visible = true,
	Disabled = false,
	Callback = function(Value)
		print("Auto Attack: " .. Value)
	end,
})

local teleportLocations = {
	["DBWorld"] = Vector3.new(-6295.89209, 27.198103, -73.7149353, 0, 0, 1, 0, 1, 0, -1, 0, 0),
	["SoloWorld"] = Vector3.new(577.968262, 26.9623756, 261.452271),
	["ChainsawWorld"] = Vector3.new(236.932678, 32.3960934, -4301.60547),
	["BCWorld"] = CFrame.new(
		198.338684,
		38.2076797,
		4296.10938,
		0.993159413,
		-0,
		-0.116766132,
		0,
		1,
		-0,
		0.116766132,
		0,
		0.993159413
	),
	["BleachWorld"] = CFrame.new(
		2641.79517,
		44.9265289,
		-2645.07568,
		0.780932784,
		-0,
		-0.624615133,
		0,
		1,
		-0,
		0.624615133,
		0,
		0.780932784
	),
	["OpWorld"] = CFrame.new(
		-2851.1062,
		48.8987885,
		-2011.39526,
		0.739920259,
		-0.0159788765,
		0.672504723,
		0.0134891849,
		0.999869287,
		0.0089157233,
		-0.672559321,
		0.00247461651,
		0.74003911
	),
	["NarutoWorld"] = Vector3.new(-3380.2373, 28.8265285, 2257.26196),
	["JojoWorld"] = Vector3.new(4816.31641, 29.4423409, -120.22998),
	["Dedu"] = CFrame.new(
		4072.3396,
		65.590126,
		3325.87012,
		-0.852027357,
		0,
		-0.523497283,
		0,
		1,
		0,
		0.523497283,
		0,
		-0.852027357
	),
}

local selectedLocation = "None"

TeleportGroupBox:AddDropdown("TeleportLocation", {
	Values = {
		"None",
		"Dragon City",
		"Leveling City",
		"Mori City",
		"Nipon City",
		"Faceheal Town",
		"Lucky Kingdom",
		"Grass Village",
		"Brum Island",
		"Dedu Island",
	},
	Default = 1,
	Multi = false,
	Text = "Teleport Location",
	Tooltip = "Select the location you want to teleport to",
	Searchable = false,
	Disabled = false,
	Visible = true,
	Callback = function(selected)
		if selected == "None" then
			selectedLocation = "None"
		elseif selected == "Dragon City" then
			selectedLocation = "DBWorld"
		elseif selected == "Leveling City" then
			selectedLocation = "SoloWorld"
		elseif selected == "Mori City" then
			selectedLocation = "JojoWorld"
		elseif selected == "Nipon City" then
			selectedLocation = "ChainsawWorld"
		elseif selected == "Faceheal Town" then
			selectedLocation = "BleachWorld"
		elseif selected == "Lucky Kingdom" then
			selectedLocation = "BCWorld"
		elseif selected == "Grass Village" then
			selectedLocation = "NarutoWorld"
		elseif selected == "Brum Island" then
			selectedLocation = "OPWorld"
		elseif selected == "Dedu Island" then
			selectedLocation = "Dedu"
		end
		print("Teleport Location set to: " .. selectedLocation)
	end,
})

TeleportGroupBox:AddButton("Teleport", {
	Text = "Teleport to Island",
	Tooltip = "Teleport to the selected location",
	DoubleClick = false,
	Disabled = false,
	Visible = true,
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
	end,
})

TeleportGroupBox:AddDivider()

local guildLocation = CFrame.new(268.578613, 31.8532162, 157.246201, 1, 0, 0, 0, 1, 0, 0, 0, 1)

TeleportGroupBox:AddButton("GuildTeleport", {
	Text = "Teleport to Guild",
	Tooltip = "Teleport to the guild",
	DoubleClick = false,
	Disabled = false,
	Visible = true,
	Callback = function()
		HumanoidRootPart = LocalPlayer.Character and LocalPlayer.Character.FindFirstChild("HumanoidRootPart")

		if not HumanoidRootPart then
			return
		end

		task.spawn(function()
			for i = 1, 6 do
				HumanoidRootPart.CFrame = guildLocation
				task.wait(0.01)
			end
		end)
	end,
})

local function CreateTeleportResetButton(name, spawnPoint)
	TeleportResetGroupBox:AddButton(spawnPoint, {
		Text = name,
		Tooltip = "Reset Spawn Point to " .. name,
		DoubleClick = false,
		Disabled = false,
		Visible = true,
		Callback = function()
			LocalPlayer.Character:BreakJoints()

			local args = {
				[1] = {
					[1] = {
						["Event"] = "ChangeSpawn",
						["Spawn"] = spawnPoint,
					},
					[2] = "\n",
				},
			}

			DataRemoteEvent:FireServer(unpack(args))
		end,
	})
end

CreateTeleportResetButton("Dragon City", "DBWorld")
CreateTeleportResetButton("Leveling City", "SoloWorld")
CreateTeleportResetButton("Mori City", "JojoWorld")
CreateTeleportResetButton("Nipon City", "ChainsawWorld")
CreateTeleportResetButton("Faceheal Town", "BleachWorld")
CreateTeleportResetButton("Lucky Kingdom", "BCWorld")
CreateTeleportResetButton("Grass Village", "NarutoWorld")
CreateTeleportResetButton("Brum Island", "OPWorld")

-- Anti-AFK Variables
local isAntiAFKEnabled = true
local antiAFKConnection = nil

local function ToggleAntiAFK(state)
	if state then
		antiAFKConnection = LocalPlayer.Idled:Connect(function()
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new())
		end)

		Library:Notify({
			Title = "Anti-AFK",
			Description = "Anti-AFK has been enabled",
			Duration = 5,
		})
	else
		if antiAFKConnection then
			antiAFKConnection:Disconnect()
			antiAFKConnection = nil
		end

		Library:Notify({
			Title = "Anti-AFK",
			Description = "Anti-AFK has been disabled",
			Duration = 5,
		})
	end
end

ToggleAntiAFK(isAntiAFKEnabled)

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

Library.ToggleKeybind = Options.MenuKeybind -- Allows you to have a custom keybind for the menu

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("DevRYHub")
SaveManager:SetFolder("DevRYHub/arise-game")
SaveManager:BuildConfigSection(Tabs["UI Settings"])
ThemeManager:ApplyToTab(Tabs["UI Settings"])
SaveManager:LoadAutoloadConfig()

Library:Notify({
	Title = "DevRY:HUB",
	Description = "The script has been loaded.\n\nMade by DevRY\n\nPress RightShift to open/close the window.",
	Duration = 5,
})
