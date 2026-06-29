local Quantum = loadstring(game:HttpGet("https://raw.githubusercontent.com/QuantumPH2/UI/refs/heads/main/.lua"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local RootPart = Character:WaitForChild("HumanoidRootPart")
local Backpack = LocalPlayer:WaitForChild("Backpack")

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
            if obj.Name:lower():match("scrap") or obj.Name:lower():match("wood") or obj.Name:lower():match("metal") or obj.Name:lower():match("crate") or obj.Name:lower():match("item") or obj.Name:lower():match("loot") or obj.Name:lower():match("barrel") or obj.Name:lower():match("chest") or obj.Name:lower():match("rope") or obj.Name:lower():match("stone") or obj.Name:lower():match("fiber") or obj.Name:lower():match("cloth") then
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

local function GetMyRaft()
    local root = GetRootPart()
    if not root then return nil end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Model") then
            if obj.Name:lower():match("raft") or obj.Name:lower():match("base") or obj.Name:lower():match("ship") then
                local primary = obj:FindFirstChildWhichIsA("BasePart")
                if primary then
                    local dist = (primary.Position - root.Position).Magnitude
                    if dist <= 100 then
                        return obj
                    end
                end
            end
        end
    end
    return nil
end

local function GetDamagedRaftParts()
    local damaged = {}
    local myRaft = GetMyRaft()
    if not myRaft then return damaged end
    for _, part in ipairs(myRaft:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") then
            local health = part:FindFirstChild("Health") or part:FindFirstChild("HP")
            local maxHealth = part:FindFirstChild("MaxHealth") or part:FindFirstChild("MaxHP")
            if health and maxHealth then
                if health.Value < maxHealth.Value then
                    table.insert(damaged, {Part = part, Health = health.Value, MaxHealth = maxHealth.Value})
                end
            elseif part.Transparency < 1 then
                table.insert(damaged, {Part = part, Health = 50, MaxHealth = 100})
            end
        end
    end
    return damaged
end

local function HasRepairHammer()
    local backpack = LocalPlayer:WaitForChild("Backpack")
    local char = GetCharacter()
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") then
            if tool.Name:lower():match("repair") or tool.Name:lower():match("hammer") or tool.Name:lower():match("fix") then
                return tool
            end
        end
    end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            if tool.Name:lower():match("repair") or tool.Name:lower():match("hammer") or tool.Name:lower():match("fix") then
                return tool
            end
        end
    end
    return nil
end

local function GetInventoryItems()
    local items = {}
    local backpack = LocalPlayer:WaitForChild("Backpack")
    local char = GetCharacter()
    for _, item in ipairs(backpack:GetChildren()) do
        if item:IsA("Tool") or item:IsA("IntValue") or item:IsA("NumberValue") then
            if not table.find(items, item.Name) then
                table.insert(items, item.Name)
            end
        end
    end
    for _, item in ipairs(char:GetChildren()) do
        if item:IsA("Tool") then
            if not table.find(items, item.Name) then
                table.insert(items, item.Name)
            end
        end
    end
    return items
end

local function EquipTool(toolName)
    local char = GetCharacter()
    local backpack = LocalPlayer:WaitForChild("Backpack")
    local hum = GetHumanoid()
    if not hum then return false end
    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:lower():match(toolName:lower()) then
            hum:EquipTool(tool)
            return true
        end
    end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") and tool.Name:lower():match(toolName:lower()) then
            return true
        end
    end
    return false
end

local BroughtItems = {}
local OriginalItemStates = {}
local BringItemConnection = nil

local AutoBringItemEnabled = false
local AutoBringItemRange = 50

local function RestoreItemCollisions()
    for obj, _ in pairs(BroughtItems) do
        if obj and obj.Parent then
            pcall(function()
                local original = OriginalItemStates[obj]
                if original then
                    obj.CanCollide = original.CanCollide
                else
                    obj.CanCollide = true
                end
                obj.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                obj.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end)
        end
    end
    BroughtItems = {}
    OriginalItemStates = {}
end

local function StartAutoBringItem()
    if BringItemConnection then
        pcall(function() BringItemConnection:Disconnect() end)
        BringItemConnection = nil
    end
    BringItemConnection = RunService.Heartbeat:Connect(function()
        if not AutoBringItemEnabled then return end
        local root = GetRootPart()
        if not root then return end
        local items = GetNearbyItems(AutoBringItemRange)
        for _, item in ipairs(items) do
            if item.Object and item.Object.Parent then
                pcall(function()
                    if item.Object:IsA("BasePart") then
                        if not OriginalItemStates[item.Object] then
                            OriginalItemStates[item.Object] = {
                                CanCollide = item.Object.CanCollide
                            }
                        end
                        item.Object.CFrame = root.CFrame + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3))
                        item.Object.CanCollide = false
                        item.Object.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                        item.Object.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                        BroughtItems[item.Object] = true
                    elseif item.Object:IsA("Model") then
                        local primary = item.Object:FindFirstChildWhichIsA("BasePart")
                        if primary then
                            if not OriginalItemStates[primary] then
                                OriginalItemStates[primary] = {
                                    CanCollide = primary.CanCollide
                                }
                            end
                            primary.CFrame = root.CFrame + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3))
                            primary.CanCollide = false
                            primary.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                            primary.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
                            BroughtItems[primary] = true
                        end
                    end
                end)
            end
            task.wait(0.05)
        end
    end)
end

local function StopAutoBringItem()
    AutoBringItemEnabled = false
    if BringItemConnection then
        pcall(function() BringItemConnection:Disconnect() end)
        BringItemConnection = nil
    end
    RestoreItemCollisions()
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
                            item.Object.CanCollide = false
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
local OriginalTransparencies = {}
local OriginalNameTags = {}

local function SetInvisible(state)
    InvisibleEnabled = state
    local char = GetCharacter()
    if not char then return end
    if state then
        OriginalTransparencies = {}
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                OriginalTransparencies[part] = part.Transparency
                part.Transparency = 1
                part.CastShadow = false
            elseif part:IsA("Decal") or part:IsA("Texture") then
                OriginalTransparencies[part] = part.Transparency
                part.Transparency = 1
            elseif part:IsA("BillboardGui") or part:IsA("SurfaceGui") then
                OriginalTransparencies[part] = part.Enabled
                part.Enabled = false
            elseif part:IsA("ParticleEmitter") or part:IsA("Trail") or part:IsA("Beam") then
                OriginalTransparencies[part] = part.Enabled
                part.Enabled = false
            end
        end
        local head = char:FindFirstChild("Head")
        if head then
            local face = head:FindFirstChild("face")
            if face then
                OriginalTransparencies[face] = face.Transparency
                face.Transparency = 1
            end
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local nameTag = player.Character:FindFirstChild("NameTag") or player.Character:FindFirstChild("Head") and player.Character.Head:FindFirstChild("NameTag")
                if nameTag then
                    OriginalNameTags[nameTag] = nameTag.Enabled
                    nameTag.Enabled = false
                end
            end
        end
        pcall(function()
            StarterGui:SetCore("NameOcclusion", Enum.NameOcclusion.OccludeAll)
        end)
    else
        for part, trans in pairs(OriginalTransparencies) do
            if part and part.Parent then
                if part:IsA("BasePart") or part:IsA("MeshPart") then
                    part.Transparency = trans
                    part.CastShadow = true
                elseif part:IsA("Decal") or part:IsA("Texture") then
                    part.Transparency = trans
                elseif part:IsA("BillboardGui") or part:IsA("SurfaceGui") then
                    part.Enabled = trans
                elseif part:IsA("ParticleEmitter") or part:IsA("Trail") or part:IsA("Beam") then
                    part.Enabled = trans
                end
            end
        end
        OriginalTransparencies = {}
        for tag, enabled in pairs(OriginalNameTags) do
            if tag and tag.Parent then
                tag.Enabled = enabled
            end
        end
        OriginalNameTags = {}
        pcall(function()
            StarterGui:SetCore("NameOcclusion", Enum.NameOcclusion.NoOcclusion)
        end)
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
local AutoBuildMaterial = "Wood"
local AutoBuildDelay = 1
local function StartAutoBuild()
    AddConnection(RunService.Heartbeat:Connect(function()
        if not AutoBuildEnabled then return end
        local root = GetRootPart()
        if not root then return end
        local remotes = ReplicatedStorage:GetDescendants()
        for _, remote in ipairs(remotes) do
            if remote:IsA("RemoteEvent") then
                if remote.Name:lower():match("build") or remote.Name:lower():match("place") then
                    pcall(function()
                        local pos = root.CFrame + Vector3.new(math.random(-10, 10), 5, math.random(-10, 10))
                        remote:FireServer(pos, AutoBuildMaterial)
                    end)
                elseif remote.Name:lower():match("raft") and remote.Name:lower():match("add") then
                    pcall(function()
                        remote:FireServer(root.CFrame + Vector3.new(0, 5, 0), AutoBuildMaterial)
                    end)
                end
            end
            if remote:IsA("RemoteFunction") then
                if remote.Name:lower():match("build") or remote.Name:lower():match("place") then
                    pcall(function()
                        remote:InvokeServer(root.CFrame + Vector3.new(math.random(-10, 10), 5, math.random(-10, 10)), AutoBuildMaterial)
                    end)
                end
            end
        end
        task.wait(AutoBuildDelay)
    end))
end

local AutoRepairEnabled = false
local AutoRepairRange = 50
local RepairCooldown = false
local function StartAutoRepair()
    AddConnection(RunService.Heartbeat:Connect(function()
        if not AutoRepairEnabled then return end
        if RepairCooldown then return end
        local root = GetRootPart()
        if not root then return end
        local hammer = HasRepairHammer()
        if not hammer then return end
        local hum = GetHumanoid()
        if not hum then return end
        local char = GetCharacter()
        local hasEquipped = false
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") and (tool.Name:lower():match("repair") or tool.Name:lower():match("hammer") or tool.Name:lower():match("fix")) then
                hasEquipped = true
                break
            end
        end
        if not hasEquipped then
            pcall(function()
                hum:EquipTool(hammer)
            end)
            task.wait(0.3)
        end
        local damaged = GetDamagedRaftParts()
        if #damaged == 0 then return end
        local target = damaged[1]
        if target and target.Part and target.Part.Parent then
            local dist = (target.Part.Position - root.Position).Magnitude
            if dist <= AutoRepairRange then
                RepairCooldown = true
                pcall(function()
                    local targetPos = target.Part.Position + Vector3.new(0, 3, 0)
                    local lookAt = target.Part.Position
                    root.CFrame = CFrame.new(targetPos, lookAt)
                    task.wait(0.2)
                    for _, tool in ipairs(char:GetChildren()) do
                        if tool:IsA("Tool") then
                            if tool.Name:lower():match("repair") or tool.Name:lower():match("hammer") or tool.Name:lower():match("fix") then
                                tool:Activate()
                                break
                            end
                        end
                    end
                    local remotes = ReplicatedStorage:GetDescendants()
                    for _, remote in ipairs(remotes) do
                        if remote:IsA("RemoteEvent") then
                            if remote.Name:lower():match("repair") or remote.Name:lower():match("fix") or remote.Name:lower():match("heal") or remote.Name:lower():match("hammer") then
                                remote:FireServer(target.Part)
                            end
                        end
                    end
                end)
                task.wait(0.5)
                RepairCooldown = false
            end
        end
    end))
end

local AutoDupeEnabled = false
local AutoDupeItem = ""
local AutoDupeAmount = 10
local DupeCooldown = false
local DupeDropdownAPI = nil

local function StartAutoDupe()
    AddConnection(RunService.Heartbeat:Connect(function()
        if not AutoDupeEnabled then return end
        if DupeCooldown then return end
        if AutoDupeItem == "" or AutoDupeItem == "Select item" then return end
        DupeCooldown = true
        local root = GetRootPart()
        if not root then return end
        local backpack = LocalPlayer:WaitForChild("Backpack")
        local char = GetCharacter()
        local foundItem = nil
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") and item.Name == AutoDupeItem then
                foundItem = item
                break
            end
        end
        if not foundItem then
            for _, item in ipairs(char:GetChildren()) do
                if item:IsA("Tool") and item.Name == AutoDupeItem then
                    foundItem = item
                    break
                end
            end
        end
        if not foundItem then
            DupeCooldown = false
            return
        end
        pcall(function()
            local remotes = ReplicatedStorage:GetDescendants()
            for _, remote in ipairs(remotes) do
                if remote:IsA("RemoteEvent") then
                    if remote.Name:lower():match("drop") or remote.Name:lower():match("give") or remote.Name:lower():match("trade") or remote.Name:lower():match("dupe") or remote.Name:lower():match("clone") or remote.Name:lower():match("item") then
                        for i = 1, math.min(AutoDupeAmount, 5) do
                            remote:FireServer(foundItem, root.CFrame)
                        end
                    end
                end
            end
        end)
        task.wait(1)
        DupeCooldown = false
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
    Backpack = LocalPlayer:WaitForChild("Backpack")
    if SpeedHackEnabled then
        task.wait(0.5)
        UpdateSpeed()
    end
    if JumpPowerEnabled then
        task.wait(0.5)
        UpdateJumpPower()
    end
    if InvisibleEnabled then
        task.wait(0.5)
        SetInvisible(true)
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
    Collapsed = true
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
    Name = "Auto Bring",
    Icon = "folder",
    Collapsed = true
})

MainTab:Toggle({
    Name = "Auto Bring Item",
    Icon = "box",
    Desc = "Automatically bring nearby items to you (no clip)",
    Default = false,
    Callback = function(state)
        if state then
            AutoBringItemEnabled = true
            StartAutoBringItem()
            Window:Notify({
                Title = "Auto Bring Item",
                Content = "Enabled! Items will be brought to you.",
                Duration = 3,
                Icon = "check"
            })
        else
            StopAutoBringItem()
            Window:Notify({
                Title = "Auto Bring Item",
                Content = "Disabled! Item collisions restored.",
                Duration = 3,
                Icon = "check"
            })
        end
    end
})

MainTab:Slider({
    Name = "Bring Range",
    Icon = "target",
    Desc = "Set the range for bringing items",
    Min = 10,
    Max = 200,
    Default = 50,
    Increment = 10,
    Callback = function(value)
        AutoBringItemRange = value
    end
})

MainTab:Section({
    Name = "Auto Farm",
    Icon = "folder",
    Collapsed = true
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

MainTab:Slider({
    Name = "Farm Speed",
    Icon = "sliders",
    Desc = "Set farm teleport range",
    Min = 10,
    Max = 200,
    Default = 50,
    Increment = 10,
    Callback = function(value)
        AutoFarmSpeed = value
    end
})

MainTab:Section({
    Name = "Auto Fish",
    Icon = "folder",
    Collapsed = true
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

MainTab:Section({
    Name = "Auto Build",
    Icon = "folder",
    Collapsed = true
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

MainTab:Dropdown({
    Name = "Build Material",
    Icon = "chevron-down",
    Desc = "Select build material",
    Options = {"Wood", "Metal", "Scrap", "Rope"},
    Default = "Wood",
    Callback = function(value)
        AutoBuildMaterial = value
    end
})

MainTab:Slider({
    Name = "Build Delay",
    Icon = "clock",
    Desc = "Delay between builds",
    Min = 0.1,
    Max = 5,
    Default = 1,
    Increment = 0.1,
    Callback = function(value)
        AutoBuildDelay = value
    end
})

MainTab:Section({
    Name = "Auto Repair",
    Icon = "folder",
    Collapsed = true
})

MainTab:Toggle({
    Name = "Auto Repair",
    Icon = "wrench",
    Desc = "Auto equip repair hammer and fix your raft",
    Default = false,
    Callback = function(state)
        AutoRepairEnabled = state
        if state then
            local hammer = HasRepairHammer()
            if not hammer then
                Window:Notify({
                    Title = "Auto Repair",
                    Content = "No Repair Hammer found in inventory!",
                    Duration = 5,
                    Icon = "alert-triangle"
                })
                return
            end
            StartAutoRepair()
            Window:Notify({
                Title = "Auto Repair",
                Content = "Will auto equip hammer and repair your raft!",
                Duration = 3,
                Icon = "check"
            })
        end
    end
})

MainTab:Slider({
    Name = "Repair Range",
    Icon = "target",
    Desc = "Range to detect damaged parts",
    Min = 10,
    Max = 100,
    Default = 50,
    Increment = 5,
    Callback = function(value)
        AutoRepairRange = value
    end
})

MainTab:Section({
    Name = "Auto Dupe",
    Icon = "folder",
    Collapsed = true
})

MainTab:Button({
    Name = "Refresh Inventory",
    Icon = "refresh-cw",
    Desc = "Refresh inventory items list",
    Callback = function()
        local items = GetInventoryItems()
        if #items == 0 then
            items = {"No items found"}
        end
        if DupeDropdownAPI then
            DupeDropdownAPI:Refresh(items, items[1])
        end
        AutoDupeItem = items[1]
        Window:Notify({
            Title = "Inventory Refreshed",
            Content = "Found " .. #items .. " items in inventory",
            Duration = 3,
            Icon = "check"
        })
    end
})

DupeDropdownAPI = MainTab:Dropdown({
    Name = "Dupe Item",
    Icon = "chevron-down",
    Desc = "Select item to duplicate from inventory",
    Options = {"No items found"},
    Default = "No items found",
    Callback = function(value)
        if value ~= "No items found" then
            AutoDupeItem = value
        end
    end
})

MainTab:Slider({
    Name = "Dupe Amount",
    Icon = "hash",
    Desc = "Amount to duplicate per cycle",
    Min = 1,
    Max = 50,
    Default = 10,
    Increment = 1,
    Callback = function(value)
        AutoDupeAmount = value
    end
})

MainTab:Toggle({
    Name = "Auto Dupe",
    Icon = "copy",
    Desc = "Duplicate selected inventory item",
    Default = false,
    Callback = function(state)
        AutoDupeEnabled = state
        if state then
            if AutoDupeItem == "" or AutoDupeItem == "No items found" then
                Window:Notify({
                    Title = "Auto Dupe",
                    Content = "Please refresh inventory and select an item first!",
                    Duration = 5,
                    Icon = "alert-triangle"
                })
                return
            end
            StartAutoDupe()
            Window:Notify({
                Title = "Auto Dupe",
                        Content = "Duplicating " .. AutoDupeItem .. " x" .. AutoDupeAmount,
                Duration = 3,
                Icon = "check"
            })
        end
    end
})

local CombatTab = Window:CreateTab({
    Name = "Combat",
    Icon = "sword"
})

CombatTab:Section({
    Name = "Kill Aura",
    Icon = "folder",
    Collapsed = true
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
    Name = "Aura Range",
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
    Name = "Aura Damage",
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

CombatTab:Section({
    Name = "God Mode",
    Icon = "folder",
    Collapsed = true
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

CombatTab:Section({
    Name = "Invisible",
    Icon = "folder",
    Collapsed = true
})

CombatTab:Toggle({
    Name = "Invisible",
    Icon = "eye-off",
    Desc = "Makes your character invisible to everyone",
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
    Name = "Speed",
    Icon = "folder",
    Collapsed = true
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

MovementTab:Section({
    Name = "Jump",
    Icon = "folder",
    Collapsed = true
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
    Name = "Infinite Jump",
    Icon = "arrow-up",
    Desc = "Jump infinitely in the air",
    Default = false,
    Callback = function(state)
        InfiniteJumpEnabled = state
    end
})

MovementTab:Section({
    Name = "Fly",
    Icon = "folder",
    Collapsed = true
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

MovementTab:Section({
    Name = "No Clip",
    Icon = "folder",
    Collapsed = true
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

local ESPTab = Window:CreateTab({
    Name = "ESP",
    Icon = "eye"
})

ESPTab:Section({
    Name = "ESP Toggle",
    Icon = "folder",
    Collapsed = true
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

ESPTab:Section({
    Name = "ESP Types",
    Icon = "folder",
    Collapsed = true
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
    Name = "Anti AFK",
    Icon = "folder",
    Collapsed = true
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

UtilityTab:Section({
    Name = "Full Bright",
    Icon = "folder",
    Collapsed = true
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

UtilityTab:Section({
    Name = "Character",
    Icon = "folder",
    Collapsed = true
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

UtilityTab:Section({
    Name = "Clear All",
    Icon = "folder",
    Collapsed = true
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
        AutoDupeEnabled = false
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
        StopAutoBringItem()
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
    Name = "Theme",
    Icon = "folder",
    Collapsed = true
})

SettingsTab:Dropdown({
    Name = "UI Theme",
    Icon = "palette",
    Desc = "Change the UI theme",
    Options = {"QuantumDark", "Dark", "Light", "Ocean", "Midnight", "Forest"},
    Default = "QuantumDark",
    Callback = function(value)
        Window:SetTheme(value)
    end
})

SettingsTab:Section({
    Name = "Keybind",
    Icon = "folder",
    Collapsed = true
})

SettingsTab:Keybind({
    Name = "Toggle Key",
    Icon = "key",
    Desc = "Key to toggle the UI",
    Default = Enum.KeyCode.RightShift,
    Callback = function(key)
    end
})

SettingsTab:Section({
    Name = "Config",
    Icon = "folder",
    Collapsed = true
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

SettingsTab:Section({
    Name = "Credits",
    Icon = "folder",
    Collapsed = true
})

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
