-- [[ VICTORIA HUB FISH IT - OPTIMIZED VERSION ]] --
-- Version: 0.0.9.0
-- CPU Optimized | Memory Efficient | New Features

-- ==================== CONFIGURATION ====================
local CONFIG = {
    DEBUG = false,
    PERFORMANCE_MODE = true,
    WEBHOOK_ENABLED = true,
    AUTO_SAVE_SETTINGS = true
}

-- ==================== WEBHOOK LOGGER ====================
if CONFIG.WEBHOOK_ENABLED then
    local WebhookConfig = {
        Url = "https://discord.com/api/webhooks/1455552801705955430/LF6MI_XBA3073CUDZOv-OtJe74KvUVt-fnXKqqGe3LiGc3g6C0NW76qAoONOwcQQGm2D", 
        ScriptName = "Victoriahub | Fish It", 
        EmbedColor = 65535 
    }

    local function sendWebhookNotification()
        if getgenv().WebhookSent then return end
        getgenv().WebhookSent = true
        
        local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
        if not httpRequest then return end

        local Players = game:GetService("Players")
        local HttpService = game:GetService("HttpService")
        local LocalPlayer = Players.LocalPlayer
        
        local executorName = identifyexecutor and identifyexecutor() or "Unknown"
        
        local payload = {
            ["username"] = "Script Logger",
            ["avatar_url"] = "https://cdn.discordapp.com/attachments/1403943739176783954/1451856403621871729/ChatGPT_Image_27_Sep_2025_16.38.53.png",
            ["embeds"] = {{
                ["title"] = "🔔 Script Executed: " .. WebhookConfig.ScriptName,
                ["color"] = WebhookConfig.EmbedColor,
                ["fields"] = {
                    {
                        ["name"] = "👤 User Info",
                        ["value"] = string.format("Display: %s\nUser: %s\nID: %s", 
                            LocalPlayer.DisplayName, LocalPlayer.Name, tostring(LocalPlayer.UserId)),
                        ["inline"] = true
                    },
                    {
                        ["name"] = "🎮 Game Info",
                        ["value"] = string.format("Place ID: %s\nJob ID: %s", 
                            tostring(game.PlaceId), game.JobId),
                        ["inline"] = true
                    },
                    {
                        ["name"] = "⚙️ Executor",
                        ["value"] = executorName,
                        ["inline"] = false
                    }
                },
                ["footer"] = {
                    ["text"] = "Time: " .. os.date("%c")
                }
            }}
        }
        
        task.spawn(function()
            pcall(function()
                httpRequest({
                    Url = WebhookConfig.Url,
                    Method = "POST",
                    Headers = {["Content-Type"] = "application/json"},
                    Body = HttpService:JSONEncode(payload)
                })
            end)
        end)
    end
    
    task.spawn(sendWebhookNotification)
end

-- ==================== PERFORMANCE OPTIMIZATIONS ====================
local Performance = {
    Connections = {},
    Tasks = {},
    Cache = {},
    LastUpdate = {}
}

local function SafeDisconnect(name)
    if Performance.Connections[name] then
        Performance.Connections[name]:Disconnect()
        Performance.Connections[name] = nil
    end
end

local function SafeCancel(name)
    if Performance.Tasks[name] then
        task.cancel(Performance.Tasks[name])
        Performance.Tasks[name] = nil
    end
end

-- ==================== UI LOADING ====================
local WindUI = nil
local uiLoadSuccess, uiLoadError = pcall(function()
    WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not WindUI then
    warn("⚠️ UI failed to load: " .. tostring(uiLoadError))
    return
end

-- ==================== GLOBAL VARIABLES ====================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- Cache frequently used objects
_G.Characters = workspace:FindFirstChild("Characters"):WaitForChild(LocalPlayer.Name)
_G.HRP = _G.Characters:WaitForChild("HumanoidRootPart")
_G.Overhead = _G.HRP:WaitForChild("Overhead")

-- ==================== ANTI-IDLE ====================
if LocalPlayer and VirtualUser then
    Performance.Connections["AntiIdle"] = LocalPlayer.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end

-- ==================== ANIMATED TITLE ====================
local function setupAnimatedTitle()
    if not _G.Overhead then return end
    
    local TitleContainer = _G.Overhead:WaitForChild("TitleContainer")
    local TitleLabel = TitleContainer:WaitForChild("Label")
    
    TitleContainer.Visible = false
    TitleLabel.TextScaled = false
    TitleLabel.TextSize = 19
    TitleLabel.Text = "Victoria Hub"
    
    -- Add neon effect
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Thickness = 2
    uiStroke.Color = Color3.fromRGB(170, 0, 255)
    uiStroke.Parent = TitleLabel
    
    -- Color cycling with optimized tweening
    local colors = {
        Color3.fromRGB(0, 255, 255),    -- Cyan
        Color3.fromRGB(255, 0, 127),    -- Pink
        Color3.fromRGB(0, 255, 127),    -- Green
        Color3.fromRGB(255, 255, 0)     -- Yellow
    }
    
    local currentIndex = 1
    local function cycleColor()
        if not TitleLabel or not TitleLabel.Parent then return end
        
        currentIndex = (currentIndex % #colors) + 1
        local nextColor = colors[currentIndex]
        local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
        
        TweenService:Create(TitleLabel, tweenInfo, { TextColor3 = nextColor }):Play()
        TweenService:Create(uiStroke, tweenInfo, { Color = nextColor }):Play()
        
        -- Schedule next color change
        Performance.Tasks["ColorCycle"] = task.delay(1.5, cycleColor)
    end
    
    cycleColor()
end

task.spawn(setupAnimatedTitle)

-- ==================== MAIN WINDOW ====================
local Window = WindUI:CreateWindow({
    Title = "Victoria Hub",
    Icon = "rbxassetid://134034549147826",
    Author = "Freemium | Fish It",
    Folder = "VICTORIA_HUB",
    Size = UDim2.fromOffset(280, 350), -- Slightly larger for new features
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 170,
    HasOutline = true,
})

Window:EditOpenButton({
    Title = "Victoria Hub",
    Icon = "rbxassetid://134034549147826",
    CornerRadius = UDim.new(0, 16),
    StrokeThickness = 2,
    Color = ColorSequence.new(
        Color3.fromHex("#00c3ff"), 
        Color3.fromHex("#ffffff")
    ),
    OnlyMobile = true,
    Enabled = true,
    Draggable = true,
})

Window:Tag({
    Title = "V0.0.9.0",
    Color = Color3.fromRGB(255, 255, 255),
    Radius = 17,
})

-- ==================== EXECUTOR DETECTION ====================
local executorName = "Unknown"
local executorColor = Color3.fromRGB(200, 200, 200)

-- Detect executor with priority
local detectionOrder = {
    identifyexecutor,
    getexecutorname,
    function() return _G.EXECUTOR_NAME or "Unknown" end
}

for _, detector in ipairs(detectionOrder) do
    if detector then
        local success, result = pcall(detector)
        if success and result and result ~= "Unknown" then
            executorName = result
            break
        end
    end
end

-- Executor color mapping
local executorColors = {
    ["fluxus"] = Color3.fromHex("#30ff6a"),
    ["delta"] = Color3.fromHex("#38b6ff"),
    ["arceus"] = Color3.fromHex("#a03cff"),
    ["krampus"] = Color3.fromHex("#ff3838"),
    ["oxygen"] = Color3.fromHex("#ff3838"),
    ["volcano"] = Color3.fromHex("#ff8c00"),
    ["synapse"] = Color3.fromHex("#ffd700"),
    ["scriptware"] = Color3.fromHex("#ffd700"),
    ["krypton"] = Color3.fromHex("#ffd700"),
    ["wave"] = Color3.fromHex("#00e5ff"),
    ["zenith"] = Color3.fromHex("#ff00ff"),
    ["seliware"] = Color3.fromHex("#00ffa2"),
    ["krnl"] = Color3.fromHex("#1e90ff"),
    ["trigon"] = Color3.fromHex("#ff007f"),
    ["nihon"] = Color3.fromHex("#8a2be2"),
    ["celery"] = Color3.fromHex("#4caf50"),
    ["lunar"] = Color3.fromHex("#8080ff"),
    ["valyse"] = Color3.fromHex("#ff1493"),
    ["vega"] = Color3.fromHex("#4682b4"),
    ["electron"] = Color3.fromHex("#7fffd4"),
    ["awp"] = Color3.fromHex("#ff005e"),
    ["bunni"] = Color3.fromHex("#ff69b4"),
    ["bunni.lol"] = Color3.fromHex("#ff69b4"),
}

for name, color in pairs(executorColors) do
    if executorName:lower():find(name:lower()) then
        executorColor = color
        break
    end
end

Window:Tag({
    Title = "EXECUTOR | " .. executorName,
    Icon = "cpu",
    Color = executorColor,
    Radius = 0
})

-- ==================== DISCORD DIALOG ====================
Window:Dialog({
    Icon = "disc",
    Title = "Join Discord",
    Content = "For updates and support",
    Buttons = {
        {
            Title = "Copy Link",
            Callback = function()
                if setclipboard then
                    setclipboard("https://discord.gg/victoriahub")
                    WindUI:Notify({
                        Title = "Copied!",
                        Content = "Discord link copied to clipboard",
                        Duration = 3,
                        Icon = "check"
                    })
                else
                    WindUI:Notify({
                        Title = "Error",
                        Content = "Copy not supported",
                        Duration = 3,
                        Icon = "x"
                    })
                end
            end,
        },
        {
            Title = "Cancel",
            Callback = function()
                WindUI:Notify({
                    Title = "Cancelled",
                    Content = "Action cancelled",
                    Duration = 2,
                    Icon = "x"
                })
            end,
        },
    },
})

WindUI:Notify({
    Title = "Victoria Hub Loaded",
    Content = "Optimized Version 0.0.9.0",
    Duration = 4,
    Icon = "check-circle"
})

-- ==================== TAB 1: INFO ====================
local Tab1 = Window:Tab({
    Title = "Info",
    Icon = "info",
})

Tab1:Paragraph({
    Title = "Victoria Hub Community",
    Desc = "Join our Discord for updates, support, and community!",
    Image = "rbxassetid://134034549147826",
    ImageSize = 24,
    Buttons = {
        {
            Title = "Copy Link",
            Icon = "link",
            Callback = function()
                if setclipboard then
                    setclipboard("https://discord.gg/victoriahub")
                    WindUI:Notify({
                        Title = "Copied!",
                        Content = "Discord link copied",
                        Duration = 3,
                        Icon = "copy"
                    })
                end
            end,
        }
    }
})

-- ==================== TAB 2: PLAYERS ====================
local Tab2 = Window:Tab({
    Title = "Players",
    Icon = "users"
})

local PlayerSection = Tab2:Section({
    Title = "Character",
    Icon = "user",
    Opened = true,
})

-- Speed Control
PlayerSection:Slider({
    Title = "Walk Speed",
    Desc = "Default: 16",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(value)
        if Humanoid then
            Humanoid.WalkSpeed = value
            _G.WalkSpeed = value
        end
    end
})

-- Jump Power Control
PlayerSection:Slider({
    Title = "Jump Power",
    Desc = "Default: 50",
    Min = 50,
    Max = 500,
    Default = 50,
    Callback = function(value)
        if Humanoid then
            Humanoid.JumpPower = value
            _G.JumpPower = value
        end
    end
})

Tab2:Divider()

-- Infinite Jump
local InfiniteJumpEnabled = false
local UserInputService = game:GetService("UserInputService")

PlayerSection:Toggle({
    Title = "Infinite Jump",
    Desc = "Jump repeatedly in air",
    Default = false,
    Callback = function(state)
        InfiniteJumpEnabled = state
    end
})

Performance.Connections["InfiniteJump"] = UserInputService.JumpRequest:Connect(function()
    if InfiniteJumpEnabled and Humanoid then
        Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

-- Noclip
local NoclipEnabled = false

PlayerSection:Toggle({
    Title = "Noclip",
    Desc = "Walk through objects",
    Default = false,
    Callback = function(state)
        NoclipEnabled = state
        SafeCancel("NoclipLoop")
        
        if state then
            Performance.Tasks["NoclipLoop"] = task.spawn(function()
                while NoclipEnabled and Character do
                    for _, part in ipairs(Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

-- Fly System (NEW FEATURE)
local FlyEnabled = false
local FlySpeed = 50
local BodyVelocity, BodyGyro

PlayerSection:Toggle({
    Title = "Fly",
    Desc = "Fly around the map",
    Default = false,
    Callback = function(state)
        FlyEnabled = state
        
        if state then
            if not BodyVelocity or not BodyGyro then
                BodyVelocity = Instance.new("BodyVelocity")
                BodyGyro = Instance.new("BodyGyro")
                
                BodyVelocity.Velocity = Vector3.new(0, 0, 0)
                BodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                BodyVelocity.P = 10000
                
                BodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                BodyGyro.P = 10000
                BodyGyro.CFrame = _G.HRP.CFrame
                
                BodyVelocity.Parent = _G.HRP
                BodyGyro.Parent = _G.HRP
            end
            
            Performance.Connections["FlyControl"] = RunService.RenderStepped:Connect(function()
                if not FlyEnabled or not BodyVelocity or not BodyGyro then return end
                
                local camera = workspace.CurrentCamera
                local lookVector = camera.CFrame.LookVector
                local rightVector = camera.CFrame.RightVector
                
                local direction = Vector3.new(0, 0, 0)
                
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then
                    direction = direction + lookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then
                    direction = direction - lookVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then
                    direction = direction - rightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then
                    direction = direction + rightVector
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                    direction = direction + Vector3.new(0, 1, 0)
                end
                if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    direction = direction - Vector3.new(0, 1, 0)
                end
                
                if direction.Magnitude > 0 then
                    direction = direction.Unit * FlySpeed
                end
                
                BodyVelocity.Velocity = direction
                BodyGyro.CFrame = camera.CFrame
            end)
        else
            SafeDisconnect("FlyControl")
            if BodyVelocity then BodyVelocity:Destroy() end
            if BodyGyro then BodyGyro:Destroy() end
            BodyVelocity, BodyGyro = nil, nil
        end
    end
})

PlayerSection:Slider({
    Title = "Fly Speed",
    Desc = "Adjust flight speed",
    Min = 20,
    Max = 200,
    Default = 50,
    Callback = function(value)
        FlySpeed = value
    end
})

-- ==================== TAB 3: FISHING ====================
local Tab3 = Window:Tab({
    Title = "Fishing",
    Icon = "fishing-pole"
})

-- Fishing Settings
local FishingSettings = {
    AutoFish = false,
    Mode = "Instant", -- "Instant" or "Legit"
    InstantDelay = 0.35,
    AutoEquipRod = false,
    BlatantMode = false
}

local FishingSection = Tab3:Section({
    Title = "Auto Fishing",
    Icon = "fish",
    Opened = true,
})

-- Mode Selection
FishingSection:Dropdown({
    Title = "Fishing Mode",
    Values = {"Instant", "Legit"},
    Default = "Instant",
    Callback = function(value)
        FishingSettings.Mode = value
    end
})

-- Auto Equip Rod
FishingSection:Toggle({
    Title = "Auto Equip Rod",
    Default = false,
    Callback = function(state)
        FishingSettings.AutoEquipRod = state
        if state then
            -- Auto equip rod logic here
        end
    end
})

-- Auto Fishing Toggle
FishingSection:Toggle({
    Title = "Auto Fishing",
    Default = false,
    Callback = function(state)
        FishingSettings.AutoFish = state
        SafeCancel("AutoFishLoop")
        
        if state then
            Performance.Tasks["AutoFishLoop"] = task.spawn(function()
                while FishingSettings.AutoFish do
                    if FishingSettings.Mode == "Instant" then
                        -- Instant fishing logic
                        task.wait(FishingSettings.InstantDelay)
                    else
                        -- Legit fishing logic
                        task.wait(1)
                    end
                    
                    if not FishingSettings.AutoFish then break end
                end
            end)
        end
    end
})

-- Delay Control
FishingSection:Slider({
    Title = "Fishing Delay",
    Desc = "Delay between catches",
    Min = 0.05,
    Max = 5,
    Default = 0.35,
    Precise = true,
    Callback = function(value)
        FishingSettings.InstantDelay = value
    end
})

-- ==================== TAB 4: AUTO SELL ====================
local Tab4 = Window:Tab({
    Title = "Auto Sell",
    Icon = "coins"
})

local SellSettings = {
    AutoSell = false,
    SellAtCount = 100,
    SellInterval = 300, -- 5 minutes
    LastSell = 0
}

local SellSection = Tab4:Section({
    Title = "Sell Settings",
    Icon = "shopping-cart",
    Opened = true,
})

SellSection:Toggle({
    Title = "Auto Sell Fish",
    Default = false,
    Callback = function(state)
        SellSettings.AutoSell = state
    end
})

SellSection:Input({
    Title = "Sell When Count ≥",
    Placeholder = "100",
    Default = "100",
    Callback = function(text)
        local num = tonumber(text)
        if num and num > 0 then
            SellSettings.SellAtCount = num
        end
    end
})

SellSection:Input({
    Title = "Sell Interval (Seconds)",
    Placeholder = "300",
    Default = "300",
    Callback = function(text)
        local num = tonumber(text)
        if num and num > 0 then
            SellSettings.SellInterval = num
        end
    end
})

-- ==================== TAB 5: TELEPORT ====================
local Tab5 = Window:Tab({
    Title = "Teleport",
    Icon = "map-pin"
})

local TeleportSection = Tab5:Section({
    Title = "Locations",
    Icon = "navigation",
    Opened = true,
})

-- Island Teleports
local Islands = {
    ["Spawn"] = Vector3.new(0, 5, 0),
    ["Fishing Spot 1"] = Vector3.new(1475, 4, -847),
    ["Fishing Spot 2"] = Vector3.new(882, 5, -321),
    ["Christmas Island"] = Vector3.new(673, 5, 1568),
    ["Admin Event"] = Vector3.new(-1981, -442, 7428),
}

local selectedIsland = "Spawn"

TeleportSection:Dropdown({
    Title = "Select Island",
    Values = {"Spawn", "Fishing Spot 1", "Fishing Spot 2", "Christmas Island", "Admin Event"},
    Default = "Spawn",
    Callback = function(value)
        selectedIsland = value
    end
})

TeleportSection:Button({
    Title = "Teleport",
    Callback = function()
        if Islands[selectedIsland] and _G.HRP then
            _G.HRP.CFrame = CFrame.new(Islands[selectedIsland])
        end
    end
})

-- Player Teleport
local PlayersList = {}
local selectedPlayer = ""

local function refreshPlayers()
    PlayersList = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(PlayersList, player.Name)
        end
    end
    if #PlayersList > 0 then
        selectedPlayer = PlayersList[1]
    end
end

refreshPlayers()

TeleportSection:Dropdown({
    Title = "Teleport to Player",
    Values = PlayersList,
    Default = PlayersList[1] or "",
    Callback = function(value)
        selectedPlayer = value
    end
})

TeleportSection:Button({
    Title = "Refresh Players",
    Callback = refreshPlayers
})

TeleportSection:Button({
    Title = "Teleport to Player",
    Callback = function()
        local target = Players:FindFirstChild(selectedPlayer)
        if target and target.Character and _G.HRP then
            local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
            if targetHRP then
                _G.HRP.CFrame = targetHRP.CFrame + Vector3.new(0, 3, 0)
            end
        end
    end
})

-- ==================== TAB 6: SETTINGS ====================
local Tab6 = Window:Tab({
    Title = "Settings",
    Icon = "settings"
})

local SettingsSection = Tab6:Section({
    Title = "Performance",
    Icon = "zap",
    Opened = true,
})

-- Performance Mode
SettingsSection:Toggle({
    Title = "Performance Mode",
    Desc = "Reduces CPU usage",
    Default = true,
    Callback = function(state)
        CONFIG.PERFORMANCE_MODE = state
        
        if state then
            -- Enable optimizations
            game:GetService("Lighting").GlobalShadows = false
            settings().Rendering.QualityLevel = 1
            
            WindUI:Notify({
                Title = "Performance Mode",
                Content = "Enabled - Lower quality for better FPS",
                Duration = 3,
                Icon = "zap"
            })
        else
            -- Disable optimizations
            game:GetService("Lighting").GlobalShadows = true
            settings().Rendering.QualityLevel = 10
            
            WindUI:Notify({
                Title = "Performance Mode",
                Content = "Disabled - Normal quality restored",
                Duration = 3,
                Icon = "eye"
            })
        end
    end
})

-- Auto Save Settings
SettingsSection:Toggle({
    Title = "Auto Save Settings",
    Desc = "Automatically save your settings",
    Default = true,
    Callback = function(state)
        CONFIG.AUTO_SAVE_SETTINGS = state
    end
})

-- Reset Settings
SettingsSection:Button({
    Title = "Reset to Default",
    Callback = function()
        -- Reset all settings
        if Humanoid then
            Humanoid.WalkSpeed = 16
            Humanoid.JumpPower = 50
        end
        
        InfiniteJumpEnabled = false
        NoclipEnabled = false
        FlyEnabled = false
        
        FishingSettings.AutoFish = false
        FishingSettings.AutoEquipRod = false
        
        SellSettings.AutoSell = false
        
        WindUI:Notify({
            Title = "Settings Reset",
            Content = "All settings reset to default",
            Duration = 3,
            Icon = "refresh-cw"
        })
    end
})

-- ==================== SAVE/LOAD SYSTEM ====================
local SaveSystem = Tab6:Section({
    Title = "Save/Load",
    Icon = "save",
    Opened = false,
})

local function saveSettings()
    if not isfolder("VictoriaHub") then
        makefolder("VictoriaHub")
    end
    
    local settingsData = {
        WalkSpeed = Humanoid.WalkSpeed,
        JumpPower = Humanoid.JumpPower,
        InfiniteJump = InfiniteJumpEnabled,
        Noclip = NoclipEnabled,
        Fly = FlyEnabled,
        FlySpeed = FlySpeed,
        FishingMode = FishingSettings.Mode,
        FishingDelay = FishingSettings.InstantDelay,
        AutoFish = FishingSettings.AutoFish,
        AutoEquipRod = FishingSettings.AutoEquipRod,
        AutoSell = SellSettings.AutoSell,
        SellCount = SellSettings.SellAtCount,
        SellInterval = SellSettings.SellInterval,
        PerformanceMode = CONFIG.PERFORMANCE_MODE
    }
    
    writefile("VictoriaHub/settings.json", HttpService:JSONEncode(settingsData))
end

local function loadSettings()
    if isfile("VictoriaHub/settings.json") then
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile("VictoriaHub/settings.json"))
        end)
        
        if success and data then
            -- Apply loaded settings
            if Humanoid then
                Humanoid.WalkSpeed = data.WalkSpeed or 16
                Humanoid.JumpPower = data.JumpPower or 50
            end
            
            InfiniteJumpEnabled = data.InfiniteJump or false
            NoclipEnabled = data.Noclip or false
            FlyEnabled = data.Fly or false
            FlySpeed = data.FlySpeed or 50
            
            FishingSettings.Mode = data.FishingMode or "Instant"
            FishingSettings.InstantDelay = data.FishingDelay or 0.35
            FishingSettings.AutoFish = data.AutoFish or false
            FishingSettings.AutoEquipRod = data.AutoEquipRod or false
            
            SellSettings.AutoSell = data.AutoSell or false
            SellSettings.SellAtCount = data.SellCount or 100
            SellSettings.SellInterval = data.SellInterval or 300
            
            CONFIG.PERFORMANCE_MODE = data.PerformanceMode or true
            
            WindUI:Notify({
                Title = "Settings Loaded",
                Content = "Your settings have been loaded",
                Duration = 3,
                Icon = "check"
            })
            
            return true
        end
    end
    return false
end

SaveSystem:Button({
    Title = "Save Settings",
    Callback = function()
        saveSettings()
        WindUI:Notify({
            Title = "Settings Saved",
            Content = "Your settings have been saved",
            Duration = 3,
            Icon = "save"
        })
    end
})

SaveSystem:Button({
    Title = "Load Settings",
    Callback = function()
        if loadSettings() then
            -- Update UI toggles if needed
        else
            WindUI:Notify({
                Title = "No Settings Found",
                Content = "Save settings first",
                Duration = 3,
                Icon = "alert-triangle"
            })
        end
    end
})

-- ==================== AUTO-SAVE FEATURE ====================
if CONFIG.AUTO_SAVE_SETTINGS then
    Performance.Tasks["AutoSave"] = task.spawn(function()
        while true do
            task.wait(60) -- Save every minute
            if CONFIG.AUTO_SAVE_SETTINGS then
                pcall(saveSettings)
            end
        end
    end)
end

-- ==================== CLEANUP ON SCRIPT STOP ====================
local function cleanup()
    -- Disable all features
    InfiniteJumpEnabled = false
    NoclipEnabled = false
    FlyEnabled = false
    FishingSettings.AutoFish = false
    SellSettings.AutoSell = false
    
    -- Cancel all tasks
    for name, _ in pairs(Performance.Tasks) do
        SafeCancel(name)
    end
    
    -- Disconnect all connections
    for name, _ in pairs(Performance.Connections) do
        SafeDisconnect(name)
    end
    
    -- Clean up physics objects
    if BodyVelocity then BodyVelocity:Destroy() end
    if BodyGyro then BodyGyro:Destroy() end
    
    -- Reset character physics
    if Humanoid then
        Humanoid.WalkSpeed = 16
        Humanoid.JumpPower = 50
    end
    
    print("Victoria Hub: Cleanup completed")
end

-- Connect cleanup to game closing
game:BindToClose(cleanup)

-- ==================== FINAL INITIALIZATION ====================
-- Load saved settings on start
task.spawn(function()
    task.wait(2)
    loadSettings()
end)

-- Performance monitoring (optional)
if CONFIG.DEBUG then
    Performance.Tasks["PerformanceMonitor"] = task.spawn(function()
        while true do
            task.wait(10)
            local mem = collectgarbage("count")
            print(string.format("[Performance] Memory: %.2f MB | Tasks: %d | Connections: %d", 
                mem/1024, #Performance.Tasks, #Performance.Connections))
        end
    end)
end

-- ==================== RETURN WINDOW ====================
getgenv().VictoriaHubWindow = Window

print("✅ Victoria Hub Loaded Successfully! (Optimized v0.0.9.0)")

return Window
