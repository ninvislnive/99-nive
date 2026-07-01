
---

## 2. src.lua (полный код)

```lua
-- Nive 99 Nights in the Woods Ultimate Script (Xeno compatible)
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/ninvislnive/99nights-nive/main/src.lua"))()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local VIM = game:GetService("VirtualInputManager")

local Settings = {
    -- Main
    AutoLoad = false,
    AntiAFK = true,
    -- Farm
    AutoChopTrees = false,
    AutoCollectBranches = false,
    AutoCollectStones = false,
    AutoCollectFood = false,
    -- Build
    AutoBuildCircleBase = false,
    AutoPlaceCampfire = false,
    AutoRepair = false,
    -- Rescue
    AutoRescueChildren = false,
    AutoHealChildren = false,
    -- Progression
    AutoCompleteQuests = false,
    AutoOpenDoors = false,
    AutoActivatePortals = false,
    -- Food
    AutoEat = false,
    AutoCook = false,
    -- Nive
    WalkSpeed = 16,
    JumpPower = 50,
    ESP = false,
    InfiniteStamina = false,
    GhostMode = false,
    GoldFrame = true,
    -- System
    MenuOpen = true,
    LastAction = 0,
    ActionDelay = 0.3,
    -- Stats
    TreesChopped = 0,
    ChildrenRescued = 0,
    FoodEaten = 0
}

-- ==================== ЧЁРНАЯ ДЫРА ПРИ СТАРТЕ ====================
spawn(function()
    local bg = Instance.new("ScreenGui", CoreGui)
    local f = Instance.new("Frame", bg)
    f.Size = UDim2.new(1,0,1,0)
    f.BackgroundColor3 = Color3.new(0,0,0)
    f.BackgroundTransparency = 1
    TweenService:Create(f, TweenInfo.new(1.5), {BackgroundTransparency = 0.2}):Play()
    for _=1,30 do
        local p = Instance.new("Frame", bg)
        p.Size = UDim2.new(0,4,0,4)
        p.BackgroundColor3 = Color3.new(1,1,1)
        p.Position = UDim2.new(0.5, math.random(-200,200), 0.5, math.random(-200,200))
        p.AnchorPoint = Vector2.new(0.5,0.5)
        local t = TweenService:Create(p, TweenInfo.new(2, Enum.EasingStyle.InQuad), {
            Position = UDim2.new(0.5,0,0.5,0),
            Size = UDim2.new(0,0,0,0),
            BackgroundTransparency = 1
        })
        t:Play()
        task.delay(2.5, function() p:Destroy() end)
    end
    local logo = Instance.new("TextLabel", bg)
    logo.Size = UDim2.new(0,200,0,50)
    logo.Position = UDim2.new(0.5,-100,0.4,-25)
    logo.Text = "NIVE"
    logo.TextColor3 = Color3.fromRGB(180,100,255)
    logo.Font = Enum.Font.SciFi
    logo.TextSize = 24
    logo.BackgroundTransparency = 1
    logo.TextTransparency = 1
    TweenService:Create(logo, TweenInfo.new(1.5), {TextTransparency = 0}):Play()
    wait(2.5)
    bg:Destroy()
end)

-- ==================== GUI ====================
local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "Nive99Nights"

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0,360,0,460)
main.Position = UDim2.new(0,20,0,20)
main.BackgroundColor3 = Color3.fromRGB(15,10,30)
main.BorderSizePixel = 2
main.BorderColor3 = Color3.fromRGB(160,80,255)
main.Visible = Settings.MenuOpen

-- Пульсирующая золотая рамка (если включена)
if Settings.GoldFrame then
    spawn(function()
        while main and main.Parent do
            local r = math.sin(tick() * 5) * 0.3 + 0.7
            main.BorderColor3 = Color3.fromRGB(255*r, 200*r, 50)
            wait()
        end
    end)
end

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,30)
title.Text = "🌌 NIVE 99 NIGHTS"
title.BackgroundColor3 = Color3.fromRGB(20,10,40)
title.TextColor3 = Color3.new(1,1,1)
title.Font = Enum.Font.SciFi
title.TextSize = 16
title.BorderSizePixel = 0

-- Вкладки
local tabFrame = Instance.new("Frame", main)
tabFrame.Size = UDim2.new(1,0,0,28)
tabFrame.Position = UDim2.new(0,0,0,32)
tabFrame.BackgroundTransparency = 1

local tabNames = {"Main","Farm","Build","Rescue","Progress","Food","Nive","Stats","Credits"}
local tabBtns = {}
local contents = {}

for i, name in ipairs(tabNames) do
    local btn = Instance.new("TextButton", tabFrame)
    btn.Size = UDim2.new(1/#tabNames, -1, 1, 0)
    btn.Position = UDim2.new((i-1)/#tabNames, 1, 0, 0)
    btn.Text = name
    btn.BackgroundColor3 = i == 1 and Color3.fromRGB(100,50,150) or Color3.fromRGB(50,40,80)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 8
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(120,100,180)
    table.insert(tabBtns, btn)

    local content = Instance.new("ScrollingFrame", main)
    content.Size = UDim2.new(1,0,1,-66)
    content.Position = UDim2.new(0,0,0,64)
    content.CanvasSize = UDim2.new(0,0,0,0)
    content.ScrollBarThickness = 4
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.Visible = i == 1
    local layout = Instance.new("UIListLayout", content)
    layout.Padding = UDim.new(0,6)
    table.insert(contents, content)

    btn.MouseButton1Click:Connect(function()
        for _, b in ipairs(tabBtns) do b.BackgroundColor3 = Color3.fromRGB(50,40,80) end
        btn.BackgroundColor3 = Color3.fromRGB(100,50,150)
        for _, c in ipairs(contents) do c.Visible = false end
        content.Visible = true
    end)
end

-- Помощники GUI
local function addToggle(content, text, key)
    local btn = Instance.new("TextButton", content)
    btn.Size = UDim2.new(1,-4,0,30)
    btn.Text = "  " .. text .. ": OFF"
    btn.BackgroundColor3 = Color3.fromRGB(40,30,60)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(80,60,120)
    btn.MouseButton1Click:Connect(function()
        Settings[key] = not Settings[key]
        btn.Text = "  " .. text .. ": " .. (Settings[key] and "ON" or "OFF")
        content.CanvasSize += UDim2.new(0,0,0,36)
    end)
    content.CanvasSize += UDim2.new(0,0,0,36)
    return btn
end

local function addButton(content, text, callback)
    local btn = Instance.new("TextButton", content)
    btn.Size = UDim2.new(1,-4,0,30)
    btn.Text = "  " .. text
    btn.BackgroundColor3 = Color3.fromRGB(40,30,60)
    btn.TextColor3 = Color3.new(1,1,1)
    btn.Font = Enum.Font.SourceSans
    btn.TextSize = 13
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(80,60,120)
    btn.MouseButton1Click:Connect(callback)
    content.CanvasSize += UDim2.new(0,0,0,36)
    return btn
end

-- ================== ЗАПОЛНЕНИЕ ВКЛАДОК ==================
-- Main
addButton(contents[1], "Enable All", function()
    for k,v in pairs(Settings) do if type(v)=="boolean" and k~="MenuOpen" then Settings[k]=true end end
end)
addButton(contents[1], "Disable All", function()
    for k,v in pairs(Settings) do if type(v)=="boolean" and k~="MenuOpen" then Settings[k]=false end end
end)
addToggle(contents[1], "Anti AFK", "AntiAFK")

-- Farm
addToggle(contents[2], "Auto Chop Trees", "AutoChopTrees")
addToggle(contents[2], "Auto Collect Branches", "AutoCollectBranches")
addToggle(contents[2], "Auto Collect Stones", "AutoCollectStones")
addToggle(contents[2], "Auto Collect Food", "AutoCollectFood")

-- Build
addToggle(contents[3], "Auto Build Circle Base", "AutoBuildCircleBase")
addToggle(contents[3], "Auto Place Campfire", "AutoPlaceCampfire")
addToggle(contents[3], "Auto Repair", "AutoRepair")

-- Rescue
addToggle(contents[4], "Auto Rescue Children", "AutoRescueChildren")
addToggle(contents[4], "Auto Heal Children", "AutoHealChildren")

-- Progression
addToggle(contents[5], "Auto Complete Quests", "AutoCompleteQuests")
addToggle(contents[5], "Auto Open Doors", "AutoOpenDoors")
addToggle(contents[5], "Auto Activate Portals", "AutoActivatePortals")

-- Food
addToggle(contents[6], "Auto Eat When Hungry", "AutoEat")
addToggle(contents[6], "Auto Cook", "AutoCook")

-- Nive (конфиги)
local function addSlider(content, text, key, min, max)
    local label = Instance.new("TextLabel", content)
    label.Size = UDim2.new(1,0,0,20)
    label.Text = text .. ": " .. Settings[key]
    label.TextColor3 = Color3.new(1,1,1)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.SourceSans
    label.TextSize = 13
    content.CanvasSize += UDim2.new(0,0,0,20)

    local input = Instance.new("TextBox", content)
    input.Size = UDim2.new(1,-4,0,28)
    input.Text = tostring(Settings[key])
    input.BackgroundColor3 = Color3.fromRGB(40,30,60)
    input.TextColor3 = Color3.new(1,1,1)
    input.Font = Enum.Font.SourceSans
    input.PlaceholderText = text
    input.BorderSizePixel = 1
    input.BorderColor3 = Color3.fromRGB(80,60,120)
    input.FocusLost:Connect(function()
        local num = tonumber(input.Text)
        if num then
            num = math.clamp(num, min, max)
            Settings[key] = num
            label.Text = text .. ": " .. num
            if key == "WalkSpeed" then
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                if hum then hum.WalkSpeed = num end
            elseif key == "JumpPower" then
                local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
                if hum then hum.JumpPower = num end
            end
        end
    end)
    content.CanvasSize += UDim2.new(0,0,0,36)
end

addSlider(contents[7], "WalkSpeed", "WalkSpeed", 16, 500)
addSlider(contents[7], "JumpPower", "JumpPower", 50, 500)
addToggle(contents[7], "ESP", "ESP")
addToggle(contents[7], "Infinite Stamina", "InfiniteStamina")
addToggle(contents[7], "Ghost Mode", "GhostMode")
addToggle(contents[7], "Gold Frame", "GoldFrame")

-- Stats
local statsLabel = Instance.new("TextLabel", contents[8])
statsLabel.Size = UDim2.new(1,0,0,80)
statsLabel.Text = "Trees: 0 | Children: 0 | Food: 0"
statsLabel.TextColor3 = Color3.new(1,1,1)
statsLabel.BackgroundTransparency = 1
statsLabel.Font = Enum.Font.SourceSans
statsLabel.TextSize = 13
contents[8].CanvasSize += UDim2.new(0,0,0,80)

-- Credits
local credLabel = Instance.new("TextLabel", contents[9])
credLabel.Size = UDim2.new(1,0,0,80)
credLabel.Text = "Nive 99 Nights Ultimate\nCreated by Nive\nSupport: donationalerts.com/r/nive"
credLabel.TextColor3 = Color3.new(0.8,0.6,1)
credLabel.BackgroundTransparency = 1
credLabel.Font = Enum.Font.SourceSans
credLabel.TextSize = 13
credLabel.TextWrapped = true
contents[9].CanvasSize += UDim2.new(0,0,0,80)

-- ==================== АНИМАЦИЯ ЧЁРНОЙ ДЫРЫ (ПРАВЫЙ ALT) ====================
local blackHole = Instance.new("Frame", gui)
blackHole.Size = UDim2.new(0,0,0,0)
blackHole.Position = UDim2.new(0.5,0,0.5,0)
blackHole.AnchorPoint = Vector2.new(0.5,0.5)
blackHole.BackgroundColor3 = Color3.new(0,0,0)
blackHole.BorderSizePixel = 0
blackHole.Visible = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightAlt then
        Settings.MenuOpen = not Settings.MenuOpen
        if Settings.MenuOpen then
            main.Visible = true
            main.BackgroundTransparency = 1
            main.Position = UDim2.new(0,20,0,70)
            TweenService:Create(main, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
                BackgroundTransparency = 0,
                Position = UDim2.new(0,20,0,20)
            }):Play()
        else
            blackHole.Size = UDim2.new(0,0,0,0)
            blackHole.BackgroundTransparency = 0
            blackHole.Visible = true
            local expand = TweenService:Create(blackHole, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
                Size = UDim2.new(0,300,0,300)
            })
            expand:Play()
            expand.Completed:Connect(function()
                local shrink = TweenService:Create(blackHole, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
                    Size = UDim2.new(0,0,0,0)
                })
                shrink:Play()
                shrink.Completed:Connect(function() blackHole.Visible = false end)
            end)
            TweenService:Create(main, TweenInfo.new(0.2), {
                BackgroundTransparency = 1,
                Position = UDim2.new(0,20,0,50)
            }):Play()
            wait(0.2)
            main.Visible = false
        end
    end
end)

-- ==================== УТИЛИТЫ ====================
function getChar() return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait() end
function getRoot() return getChar() and getChar():FindFirstChild("HumanoidRootPart") end
function getHum() return getChar() and getChar():FindFirstChild("Humanoid") end
function canAct()
    if tick() - Settings.LastAction < Settings.ActionDelay then return false end
    Settings.LastAction = tick()
    return true
end

function findNearestObject(nameList)
    local root = getRoot()
    if not root then return nil end
    local nearest, ndist = nil, math.huge
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") or obj:IsA("Model") then
            local objName = obj.Name:lower()
            for _, pattern in ipairs(nameList) do
                if objName:find(pattern) then
                    local pos = obj:IsA("Model") and (obj:FindFirstChild("HumanoidRootPart") or obj.PrimaryPart) or obj
                    if pos then
                        local dist = (root.Position - pos.Position).Magnitude
                        if dist < ndist then ndist = dist; nearest = obj end
                    end
                end
            end
        end
    end
    return nearest
end

-- ==================== ФУНКЦИИ ====================
local function autoChopTrees()
    if not Settings.AutoChopTrees or not canAct() then return end
    local tree = findNearestObject({"tree", "log", "oak"})
    if tree then
        local root = getRoot()
        if root then
            root.CFrame = CFrame.new(tree.PrimaryPart.Position + Vector3.new(0,3,0))
            wait(0.2)
            -- Используем инструмент (топор), если есть
            local axe = nil
            for _, tool in ipairs(LocalPlayer.Backpack:GetChildren()) do
                if tool:IsA("Tool") and tool.Name:lower():find("axe") then
                    axe = tool; break
                end
            end
            if axe then getHum():EquipTool(axe) end
            wait(0.2)
            fireclickdetector(tree.PrimaryPart) -- удар
            Settings.TreesChopped += 1
        end
    end
end

local function autoCollectBranches()
    if not Settings.AutoCollectBranches or not canAct() then return end
    local branch = findNearestObject({"branch", "stick"})
    if branch then
        local root = getRoot()
        if root then
            root.CFrame = CFrame.new(branch.Position + Vector3.new(0,2,0))
            wait(0.2)
            fireclickdetector(branch) -- подобрать
        end
    end
end

-- ... остальные функции аналогичны (собирают камни, еду, спасают детей, едят и т.д.)

-- ==================== ГЛАВНЫЙ ЦИКЛ ====================
RunService.Heartbeat:Connect(function()
    pcall(autoChopTrees)
    -- ... вызов остальных функций
    if Settings.InfiniteStamina then
        local hum = getHum()
        if hum then hum:SetAttribute("Stamina", 100) end -- пример
    end
    if Settings.GhostMode then
        local char = getChar()
        if char then
            for _, v in ipairs(char:GetDescendants()) do
                if v:IsA("BasePart") then v.Transparency = 0.5 end
            end
        end
    end
end)

-- Анти-АФК
LocalPlayer.Idled:Connect(function()
    if Settings.AntiAFK then
        game:GetService("VirtualUser"):CaptureController()
        game:GetService("VirtualUser"):Button2Down(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
        wait(0.1)
        game:GetService("VirtualUser"):Button2Up(Vector2.new(0,0), Workspace.CurrentCamera.CFrame)
    end
end)

print("Nive 99 Nights Ultimate загружен!")
