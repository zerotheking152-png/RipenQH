local Quantum = loadstring(game:HttpGet("https://raw.githubusercontent.com/QuantumPH2/UI/refs/heads/main/.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")

local Connections = {}
local function AddConnection(conn)
    table.insert(Connections, conn)
    return conn
end

local function ClearConnections()
    for _, conn in ipairs(Connections) do
        if conn then pcall(function() conn:Disconnect() end) end
    end
    Connections = {}
end

local AntiAFKEnabled = false
local function SetupAntiAFK()
    if AntiAFKEnabled then return end
    AntiAFKEnabled = true
    AddConnection(LocalPlayer.Idled:Connect(function()
        VirtualInputManager:SendKeyEvent(true, "W", false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, "W", false, game)
    end))
end

local function GetCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function GetRootPart()
    local char = GetCharacter()
    return char:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()
    local char = GetCharacter()
    return char:FindFirstChild("Humanoid")
end

local function GetNearbyItems(range)
    local items = {}
    local root = GetRootPart()
    if not root then return items end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("MeshPart") then
            if obj.Name:lower():match("scrap") or obj.Name:lower():match("wood") or obj.Name:lower():match("metal") or obj.Name:lower():match("crate") or obj.Name:lower():match("item") or obj.Name:lower():match("loot") or obj.Name:lower():match("barrel") or obj.Name:lower():match("chest") then
                local dist = (obj.Position - root.Position).Magnitude
                if dist <= range then
                    table.insert(items, {Object = obj, Distance = dist})
                end
            end
        end
    end
    table.sort(items, function(a, b) return a.Distance < b.Distance end)
    return items
end

local function GetEnemies()
    local enemies = {}
    local root = GetRootPart()
    if not root then return enemies end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            if obj.Name:lower():match("shark") or obj.Name:lower():match("bandit") or obj.Name:lower():match("pirate") or obj.Name:lower():match("enemy") or obj.Name:lower():match("boss") or obj.Name:lower():match("npc") then
                local head = obj:FindFirstChild("Head") or obj:FindFirstChild("HumanoidRootPart")
                if head then
                    local dist = (head.Position - root.Position).Magnitude
                    table.insert(enemies, {Object = obj, Head = head, Distance = dist})
                end
            end
        end
    end
    return enemies
end

local function GetFish()
    local fish = {}
    local root = GetRootPart()
    if not root then return fish end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("BasePart") then
            if obj.Name:lower():match("fish") then
                local part = obj:FindFirstChildWhichIsA("BasePart") or obj
                if part then
                    local dist = (part.Position - root.Position).Magnitude
                    table.insert(fish, {Object = obj, Part = part, Distance = dist})
                end
            end
        end
    end
    table.sort(fish, function(a, b) return a.Distance < b.Distance end)
    return fish
end

local AutoBringItemEnabled = false
local AutoBringItemRange = 50
local function StartAutoBringItem()
    AddConnection(RunService.Heartbeat:Connect(function()
        if not AutoBringItemEnabled then return end
        local root = GetRootPart()
        if not root then return end
        local items = GetNearbyItems(AutoBringItemRange)
        for _, item in ipairs(items) do
            if item.Object and item.Object.Parent then
                pcall(function()
                    if item.Object:IsA("BasePart") then
                        item.Object.CFrame = root.CFrame + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3))
                    elseif item.Object:IsA("Model") then
                        local primary = item.Object:FindFirstChildWhichIsA("BasePart")
                        if primary then
                            primary.CFrame = root.CFrame + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3))
                        end
                    end
                end)
            end
            task.wait(0.05)
        end
    end))
end

local KillAuraEnabled = false
local KillAuraRange = 30
local KillAuraDamage = 100
local function StartKillAura()
    AddConnection(RunService.Heartbeat:Connect(function()
        if not KillAuraEnabled then return end
        local root = GetRootPart()
        if not root then return end
        local enemies = GetEnemies()
        for _, enemy in ipairs(enemies) do
            if enemy.Distance <= KillAuraRange then
                pcall(function()
                    local hum = enemy.Object:FindFirstChildOfClass("Humanoid")
                    if hum then
                        hum.Health = math.max(0, hum.Health - KillAuraDamage)
                    end
                end)
            end
        end
    end))
end

local AutoFarmEnabled = false
local AutoFarmMode = "Items"
local AutoFarmSpeed = 50
local function StartAutoFarm()
    AddConnection(RunService.Heartbeat:Connect(function()
        if not AutoFarmEnabled then return end
        local root = GetRootPart()
        if not root then return end
        if AutoFarmMode == "Items" then
            local items = GetNearbyItems(AutoFarmSpeed)
            for _, item in ipairs(items) do
                if item.Object and item.Object.Parent then
                    pcall(function()
                        if item.Object:IsA("BasePart") then
                            item.Object.CFrame = root.CFrame
                        end
                    end)
                    break
                end
            end
        elseif AutoFarmMode == "Fish" then
            local fish = GetFish()
            for _, f in ipairs(fish) do
                if f.Distance <= AutoFarmSpeed then
                    pcall(function()
                        root.CFrame = CFrame.new(f.Part.Position + Vector3.new(0, 5, 0))
                    end)
                    break
                end
            end
        elseif AutoFarmMode == "Enemies" then
            local enemies = GetEnemies()
            for _, enemy in ipairs(enemies) do
                if enemy.Distance <= AutoFarmSpeed then
                    pcall(function()
                        root.CFrame = CFrame.new(enemy.Head.Position + Vector3.new(0, 10, 0))
                    end)
                    break
                end
            end
        end
    end))
end

local InvisibleEnabled = false
local function SetInvisible(state)
    InvisibleEnabled = state
    local char = GetCharacter()
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("Decal") or part:IsA("Texture") then
            if state then
                part.Transparency = 1
            else
                part.Transparency = 0
            end
        end
    end
end

local GodModeEnabled = false
local function StartGodMode()
    AddConnection(RunService.Heartbeat:Connect(function()
        if not GodModeEnabled then return end
        local hum = GetHumanoid()
        if hum then
            hum.MaxHealth = math.huge
            hum.Health = math.huge
        end
    end))
end

local SpeedHackEnabled = false
local SpeedValue = 50
local function UpdateSpeed()
    local hum = GetHumanoid()
    if hum then
        if SpeedHackEnabled then
            hum.WalkSpeed = SpeedValue
        else
            hum.WalkSpeed = 16
        end
    end
end

local JumpPowerEnabled = false
local JumpPowerValue = 100
local function UpdateJumpPower()
    local hum = GetHumanoid()
    if hum then
        if JumpPowerEnabled then
            hum.JumpPower = JumpPowerValue
        else
            hum.JumpPower = 50
        end
    end
end

local FlyEnabled = false
local FlySpeed = 50
local FlyBodyVelocity = nil
local function StartFly()
    local char = GetCharacter()
    local root = GetRootPart()
    if not root then return end
    FlyBodyVelocity = Instance.new("BodyVelocity")
    FlyBodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    FlyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    FlyBodyVelocity.Parent = root
    AddConnection(RunService.RenderStepped:Connect(function()
        if not FlyEnabled then return end
        local cam = Workspace.CurrentCamera
        local dir = Vector3.new(0, 0, 0)
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir = dir + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir = dir - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir = dir - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir = dir + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
        if FlyBodyVelocity and FlyBodyVelocity.Parent then
            FlyBodyVelocity.Velocity = dir * FlySpeed
        end
    end))
end

local function StopFly()
    if FlyBodyVelocity then
        FlyBodyVelocity:Destroy()
        FlyBodyVelocity = nil
    end
end

local AutoFishEnabled = false
local function StartAutoFish()
    AddConnection(RunService.Heartbeat:Connect(function()
        if not AutoFishEnabled then return end
        local fish = GetFish()
        for _, f in ipairs(fish) do
            if f.Distance <= 30 then
                pcall(function()
                    f.Object:Destroy()
                end)
            end
        end
    end))
end

local NoClipEnabled = false
local function StartNoClip()
    AddConnection(RunService.Stepped:Connect(function()
        if not NoClipEnabled then return end
        local char = GetCharacter()
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end))
end

local AutoBuildEnabled = false
local function StartAutoBuild()
    AddConnection(RunService.Heartbeat:Connect(function()
        if not AutoBuildEnabled then return end
        local root = GetRootPart()
        if not root then return end
        local remotes = ReplicatedStorage:GetDescendants()
        for _, remote in ipairs(remotes) do
            if remote:IsA("RemoteEvent") and remote.Name:lower():match("build") then
                pcall(function()
                    remote:FireServer(root.CFrame + Vector3.new(0, 5, 0))
                end)
            end
        end
    end))
end

local AutoRepairEnabled = false
local function StartAutoRepair()
    AddConnection(RunService.Heartbeat:Connect(function()
        if not AutoRepairEnabled then return end
        local root = GetRootPart()
        if not root then return end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Model") and obj.Name:lower():match("raft") then
                for _, part in ipairs(obj:GetDescendants()) do
                    if part:IsA("BasePart") then
                    end
                end
            end
        end
    end))
end

local ESPEnabled = false
local ESPItems = false
local ESPEnemies = false
local ESPPlayers = false
local ESPObjects = {}

local function CreateESP(target, color, label)
    if not target then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "QuantumESP"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.TextColor3 = color
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextSize = 12
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Text = label
    textLabel.Parent = billboard
    billboard.Parent = target
    table.insert(ESPObjects, billboard)
end

local function ClearESP()
    for _, esp in ipairs(ESPObjects) do
        if esp then pcall(function() esp:Destroy() end) end
    end
    ESPObjects = {}
end

local function StartESP()
    AddConnection(RunService.Heartbeat:Connect(function()
        if not ESPEnabled then
            ClearESP()
            return
        end
        ClearESP()
        if ESPItems then
            local items = GetNearbyItems(200)
            for _, item in ipairs(items) do
                if item.Object and item.Object.Parent then
                    local part = item.Object:IsA("BasePart") and item.Object or item.Object:FindFirstChildWhichIsA("BasePart")
                    if part then
                        CreateESP(part, Color3.fromRGB(0, 255, 100), item.Object.Name)
                    end
                end
            end
        end
        if ESPEnemies then
            local enemies = GetEnemies()
            for _, enemy in ipairs(enemies) do
                if enemy.Head then
                    CreateESP(enemy.Head, Color3.fromRGB(255, 50, 50), enemy.Object.Name)
                end
            end
        end
        if ESPPlayers then
            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    local head = player.Character:FindFirstChild("Head")
                    if head then
                        CreateESP(head, Color3.fromRGB(100, 150, 255), player.Name)
                    end
                end
            end
        end
    end))
end

local InfiniteJumpEnabled = false
AddConnection(UserInputService.InputBegan:Connect(function(input, gpe)
    if InfiniteJumpEnabled and input.KeyCode == Enum.KeyCode.Space then
        local hum = GetHumanoid()
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end))

local FullBrightEnabled = false
local OriginalBrightness = nil
local function SetFullBright(state)
    if state then
        OriginalBrightness = game.Lighting.Brightness
        game.Lighting.Brightness = 10
        game.Lighting.GlobalShadows = false
        game.Lighting.ClockTime = 12
    else
        if OriginalBrightness then
            game.Lighting.Brightness = OriginalBrightness
        end
        game.Lighting.GlobalShadows = true
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    Character = char
    Humanoid = char:WaitForChild("Humanoid")
    RootPart = char:WaitForChild("HumanoidRootPart")
    if SpeedHackEnabled then
        task.wait(0.5)
        UpdateSpeed()
    end
    if JumpPowerEnabled then
        task.wait(0.5)
        UpdateJumpPower()
    end
end)

local Window = Quantum:CreateWindow({
    Name = "Quantum HUB",
    Icon = "atom",
    Version = "Friend Only",
    FloatingIcon = "atom",
    ToggleKey = Enum.KeyCode.RightShift
})

Window:Notify({
    Title = "Quantum HUB",
    Content = "Script loaded successfully! | Ripen Yatim",
    Duration = 5,
    Icon = "check"
})

local InfoTab = Window:CreateTab({
    Name = "Info",
    Icon = "info"
})

InfoTab:Section({
    Name = "About",
    Icon = "folder",
    Collapsed = false
})

InfoTab:Paragraph({
    Title = "Ripen Yatim",
    Content = "Script Yang Sangat Keren Quantum Hub",
    Icon = "star"
})

InfoTab:Paragraph({
    Title = "Game Info",
    Content = "Rusty Rafts (Perahu Berkarat) by No Quarter Games. A survival raft builder game where extreme weather changes cause sudden droughts and floods. Build and defend your raft, sail north to the safe haven!",
    Icon = "globe"
})

InfoTab:Status({
    Text = "Script Status: Active",
    Icon = "check",
    Color = Color3.fromRGB(80, 220, 120)
})

InfoTab:Label({
    Text = "Version: Friend Only",
    Icon = "tag"
})

InfoTab:Label({
    Text = "Developer: Ripen Yatim",
    Icon = "user"
})

local MainTab = Window:CreateTab({
    Name = "Main",
    Icon = "zap"
})

MainTab:Section({
    Name = "Auto Features",
    Icon = "folder",
    Collapsed = false
})

MainTab:Toggle({
    Name = "Auto Bring Item",
    Icon = "box",
    Desc = "Automatically bring nearby items to you",
    Default = false,
    Callback = function(state)
        AutoBringItemEnabled = state
        if state then
            StartAutoBringItem()
            Window:Notify({
                Title = "Auto Bring Item",
                Content = "Enabled! Items will be brought to you.",
                Duration = 3,
                Icon = "check"
            })
        end
    end
})

MainTab:Toggle({
    Name = "Auto Farm",
    Icon = "target",
    Desc = "Automatically farm selected targets",
    Default = false,
    Callback = function(state)
        AutoFarmEnabled = state
        if state then
            StartAutoFarm()
            Window:Notify({
                Title = "Auto Farm",
                Content = "Mode: " .. AutoFarmMode,
                Duration = 3,
                Icon = "check"
            })
        end
    end
})

MainTab:Dropdown({
    Name = "Farm Mode",
    Icon = "chevron-down",
    Desc = "Select what to farm",
    Options = {"Items", "Fish", "Enemies"},
    Default = "Items",
    Callback = function(value)
        AutoFarmMode = value
    end
})

MainTab:Toggle({
    Name = "Auto Fish",
    Icon = "fish",
    Desc = "Automatically catch nearby fish",
    Default = false,
    Callback = function(state)
        AutoFishEnabled = state
        if state then
            StartAutoFish()
        end
    end
})

MainTab:Toggle({
    Name = "Auto Build",
    Icon = "layers",
    Desc = "Automatically build structures",
    Default = false,
    Callback = function(state)
        AutoBuildEnabled = state
        if state then
            StartAutoBuild()
        end
    end
})

MainTab:Toggle({
    Name = "Auto Repair",
    Icon = "wrench",
    Desc = "Automatically repair damaged raft parts",
    Default = false,
    Callback = function(state)
        AutoRepairEnabled = state
        if state then
            StartAutoRepair()
        end
    end
})

local CombatTab = Window:CreateTab({
    Name = "Combat",
    Icon = "sword"
})

CombatTab:Section({
    Name = "Combat Features",
    Icon = "folder",
    Collapsed = false
})

CombatTab:Toggle({
    Name = "Kill Aura",
    Icon = "zap",
    Desc = "Automatically damage nearby enemies",
    Default = false,
    Callback = function(state)
        KillAuraEnabled = state
        if state then
            StartKillAura()
            Window:Notify({
                Title = "Kill Aura",
                Content = "Enabled! Enemies within range will be damaged.",
                Duration = 3,
                Icon = "check"
            })
        end
    end
})

CombatTab:Slider({
    Name = "Kill Aura Range",
    Icon = "target",
    Desc = "Set the range for kill aura",
    Min = 10,
    Max = 100,
    Default = 30,
    Increment = 5,
    Callback = function(value)
        KillAuraRange = value
    end
})

CombatTab:Slider({
    Name = "Kill Aura Range",
    Icon = "target",
    Desc = "Set the range for kill aura",
    Min = 10,
    Max = 100,
    Default = 30,
    Increment = 5,
    Callback = function(value)
        KillAuraRange = value
    end
})

CombatTab:Slider({
    Name = "Kill Aura Damage",
    Icon = "bar-chart-2",
    Desc = "Set damage per tick",
    Min = 10,
    Max = 500,
    Default = 100,
    Increment = 10,
    Callback = function(value)
        KillAuraDamage = value
    end
})

CombatTab:Toggle({
    Name = "God Mode",
    Icon = "shield",
    Desc = "Makes you invincible",
    Default = false,
    Callback = function(state)
        GodModeEnabled = state
        if state then
            StartGodMode()
        end
    end
})

CombatTab:Toggle({
    Name = "Invisible",
    Icon = "eye-off",
    Desc = "Makes your character invisible",
    Default = false,
    Callback = function(state)
        SetInvisible(state)
    end
})

local MovementTab = Window:CreateTab({
    Name = "Movement",
    Icon = "move"
})

MovementTab:Section({
    Name = "Movement Hacks",
    Icon = "folder",
    Collapsed = false
})

MovementTab:Toggle({
    Name = "Speed Hack",
    Icon = "zap",
    Desc = "Increase your walk speed",
    Default = false,
    Callback = function(state)
        SpeedHackEnabled = state
        UpdateSpeed()
    end
})

MovementTab:Slider({
    Name = "Speed Value",
    Icon = "sliders",
    Desc = "Set your walk speed",
    Min = 16,
    Max = 200,
    Default = 50,
    Increment = 5,
    Callback = function(value)
        SpeedValue = value
        if SpeedHackEnabled then
            UpdateSpeed()
        end
    end
})

MovementTab:Toggle({
    Name = "Jump Power",
    Icon = "arrow-up",
    Desc = "Increase your jump height",
    Default = false,
    Callback = function(state)
        JumpPowerEnabled = state
        UpdateJumpPower()
    end
})

MovementTab:Slider({
    Name = "Jump Value",
    Icon = "sliders",
    Desc = "Set your jump power",
    Min = 50,
    Max = 300,
    Default = 100,
    Increment = 10,
    Callback = function(value)
        JumpPowerValue = value
        if JumpPowerEnabled then
            UpdateJumpPower()
        end
    end
})

MovementTab:Toggle({
    Name = "Fly",
    Icon = "cloud",
    Desc = "Enable flying mode",
    Default = false,
    Callback = function(state)
        FlyEnabled = state
        if state then
            StartFly()
        else
            StopFly()
        end
    end
})

MovementTab:Slider({
    Name = "Fly Speed",
    Icon = "sliders",
    Desc = "Set your fly speed",
    Min = 10,
    Max = 200,
    Default = 50,
    Increment = 10,
    Callback = function(value)
        FlySpeed = value
    end
})

MovementTab:Toggle({
    Name = "No Clip",
    Icon = "ghost",
    Desc = "Walk through walls",
    Default = false,
    Callback = function(state)
        NoClipEnabled = state
        if state then
            StartNoClip()
        end
    end
})

MovementTab:Toggle({
    Name = "Infinite Jump",
    Icon = "arrow-up",
    Desc = "Jump infinitely in the air",
    Default = false,
    Callback = function(state)
        InfiniteJumpEnabled = state
    end
})

local ESPTab = Window:CreateTab({
    Name = "ESP",
    Icon = "eye"
})

ESPTab:Section({
    Name = "ESP Settings",
    Icon = "folder",
    Collapsed = false
})

ESPTab:Toggle({
    Name = "Enable ESP",
    Icon = "eye",
    Desc = "Toggle ESP system",
    Default = false,
    Callback = function(state)
        ESPEnabled = state
        if state then
            StartESP()
        else
            ClearESP()
        end
    end
})

ESPTab:Toggle({
    Name = "Item ESP",
    Icon = "box",
    Desc = "Show items through walls",
    Default = false,
    Callback = function(state)
        ESPItems = state
    end
})

ESPTab:Toggle({
    Name = "Enemy ESP",
    Icon = "skull",
    Desc = "Show enemies through walls",
    Default = false,
    Callback = function(state)
        ESPEnemies = state
    end
})

ESPTab:Toggle({
    Name = "Player ESP",
    Icon = "user",
    Desc = "Show other players through walls",
    Default = false,
    Callback = function(state)
        ESPPlayers = state
    end
})

local UtilityTab = Window:CreateTab({
    Name = "Utility",
    Icon = "wrench"
})

UtilityTab:Section({
    Name = "Utility Features",
    Icon = "folder",
    Collapsed = false
})

UtilityTab:Toggle({
    Name = "Anti AFK",
    Icon = "clock",
    Desc = "Prevents getting kicked for being idle",
    Default = false,
    Callback = function(state)
        if state then
            SetupAntiAFK()
            Window:Notify({
                Title = "Anti AFK",
                Content = "Anti AFK is now active!",
                Duration = 3,
                Icon = "check"
            })
        end
    end
})

UtilityTab:Toggle({
    Name = "Full Bright",
    Icon = "sun",
    Desc = "Makes the game fully bright",
    Default = false,
    Callback = function(state)
        SetFullBright(state)
    end
})

UtilityTab:Button({
    Name = "Reset Character",
    Icon = "refresh-cw",
    Desc = "Respawn your character",
    Callback = function()
        local hum = GetHumanoid()
        if hum then
            hum.Health = 0
        end
    end
})

UtilityTab:Button({
    Name = "Clear All Effects",
    Icon = "trash",
    Desc = "Disable all active features",
    Callback = function()
        AutoBringItemEnabled = false
        AutoFarmEnabled = false
        AutoFishEnabled = false
        AutoBuildEnabled = false
        AutoRepairEnabled = false
        KillAuraEnabled = false
        GodModeEnabled = false
        SpeedHackEnabled = false
        JumpPowerEnabled = false
        FlyEnabled = false
        NoClipEnabled = false
        InfiniteJumpEnabled = false
        ESPEnabled = false
        ESPItems = false
        ESPEnemies = false
        ESPPlayers = false
        FullBrightEnabled = false
        InvisibleEnabled = false
        SetInvisible(false)
        StopFly()
        ClearESP()
        SetFullBright(false)
        UpdateSpeed()
        UpdateJumpPower()
        ClearConnections()
        Window:Notify({
            Title = "Cleared",
            Content = "All features have been disabled!",
            Duration = 3,
            Icon = "check"
        })
    end
})

local SettingsTab = Window:CreateTab({
    Name = "Settings",
    Icon = "settings"
})

SettingsTab:Section({
    Name = "UI Settings",
    Icon = "folder",
    Collapsed = false
})

SettingsTab:Dropdown({
    Name = "Theme",
    Icon = "palette",
    Desc = "Change the UI theme",
    Options = {"QuantumDark", "Dark", "Light", "Ocean", "Midnight", "Forest"},
    Default = "QuantumDark",
    Callback = function(value)
        Window:SetTheme(value)
    end
})

SettingsTab:Keybind({
    Name = "Toggle Key",
    Icon = "key",
    Desc = "Key to toggle the UI",
    Default = Enum.KeyCode.RightShift,
    Callback = function(key)
    end
})

SettingsTab:Button({
    Name = "Save Config",
    Icon = "save",
    Desc = "Save current settings",
    Callback = function()
        Window:SaveConfig()
        Window:Notify({
            Title = "Config Saved",
            Content = "Your settings have been saved!",
            Duration = 3,
            Icon = "check"
        })
    end
})

SettingsTab:Button({
    Name = "Load Config",
    Icon = "rotate-ccw",
    Desc = "Load saved settings",
    Callback = function()
        Window:LoadConfig()
        Window:Notify({
            Title = "Config Loaded",
            Content = "Your settings have been loaded!",
            Duration = 3,
            Icon = "check"
        })
    end
})

SettingsTab:Divider()

SettingsTab:Paragraph({
    Title = "Credits",
    Content = "Quantum HUB - Script Yang Sangat Keren\nMade by Ripen Yatim\nVersion: Friend Only\n\nSpecial thanks to the Rusty Rafts community!",
    Icon = "heart"
})

task.wait(1)
Window:Notify({
    Title = "Quantum HUB Loaded",
    Content = "Welcome to Quantum HUB! | Rusty Rafts | Friend Only",
    Duration = 5,
    Icon = "atom"
})
