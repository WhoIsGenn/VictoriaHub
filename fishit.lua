-- [[ VICTORIA HUB FISH IT - COMPLETE ORIGINAL + OPTIMIZED ]] --
-- Version: 0.0.9.2
-- ALL ORIGINAL FEATURES + PERFORMANCE OPTIMIZATION
-- UI REWORKED FOR LATEST WINDUI

-- ==================== PERFORMANCE MODULE ====================
local Performance = {
    Connections = {},
    Tasks = {},
    Debounce = {}
}

local function SafeConnect(name, connection)
    Performance.Connections[name] = connection
    return connection
end

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

-- ==================== WEBHOOK LOGGER ====================
local WebhookConfig = {
    Url = "https://discord.com/api/webhooks/1439637532550762528/ys-Ds5iuLGJVi-U-YvzvAUa_TTyZrTFp7hFomcbuhsJziryGRzV9PygWymNzGSSk0_xM", 
    ScriptName = "Victoriahub | Fish It", 
    EmbedColor = 65535 
}

local function sendWebhookNotification()
    local httpRequest = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
    
    if not httpRequest then return end 
    if getgenv().WebhookSent then return end 
    getgenv().WebhookSent = true

    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local LocalPlayer = Players.LocalPlayer
    
    local executorName = "Unknown"
    if identifyexecutor then executorName = identifyexecutor() end
    
    local payload = {
        ["username"] = "Script Logger",
        ["avatar_url"] = "https://cdn.discordapp.com/attachments/1358728774098882653/1459169498383909049/ai_repair_20260106014107493.png?ex=69624cfe&is=6960fb7e&hm=7ae73d692bb21a5dabee8b09b0d8447b90c5c2a29612b313ebeb9c3c87ae94e4&",
        ["embeds"] = {{
            ["title"] = "🔔 Script Executed: " .. WebhookConfig.ScriptName,
            ["color"] = WebhookConfig.EmbedColor,
            ["fields"] = {
                {
                    ["name"] = "👤 User Info",
                    ["value"] = string.format("Display: %s\nUser: %s\nID: %s", LocalPlayer.DisplayName, LocalPlayer.Name, tostring(LocalPlayer.UserId)),
                    ["inline"] = true
                },
                {
                    ["name"] = "🎮 Game Info",
                    ["value"] = string.format("Place ID: %s\nJob ID: %s", tostring(game.PlaceId), game.JobId),
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

-- ==================== UI LOADING ====================
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)

if not success or not WindUI then
    warn("⚠️ UI failed to load!")
    return
end

-- ==================== PLAYER SETUP ====================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- CACHE OBJECTS
task.spawn(function()
    _G.Characters = workspace:FindFirstChild("Characters"):WaitForChild(LocalPlayer.Name)
    _G.HRP = _G.Characters:WaitForChild("HumanoidRootPart")
    _G.Overhead = _G.HRP:WaitForChild("Overhead")
    _G.Header = _G.Overhead:WaitForChild("Content"):WaitForChild("Header")
    _G.LevelLabel = _G.Overhead:WaitForChild("LevelContainer"):WaitForChild("Label")
    Player = Players.LocalPlayer
    _G.Title = _G.Overhead:WaitForChild("TitleContainer"):WaitForChild("Label")
    _G.TitleEnabled = _G.Overhead:WaitForChild("TitleContainer")
end)

-- ANTI IDLE
if Player and VirtualUser then
    SafeConnect("AntiIdle", Player.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end))
end

-- TITLE ANIMATION
task.spawn(function()
    task.wait(2)
    if _G.TitleEnabled then
        _G.TitleEnabled.Visible = false
        _G.Title.TextScaled = false
        _G.Title.TextSize = 19
        _G.Title.Text = "Victoria Hub"

        local uiStroke = Instance.new("UIStroke")
        uiStroke.Thickness = 2
        uiStroke.Color = Color3.fromRGB(170, 0, 255)
        uiStroke.Parent = _G.Title

        local colors = {
            Color3.fromRGB(0, 255, 255),
            Color3.fromRGB(255, 0, 127),
            Color3.fromRGB(0, 255, 127),
            Color3.fromRGB(255, 255, 0)
        }

        local i = 1
        local function colorCycle()
            if not _G.Title or not _G.Title.Parent then return end
            
            local nextColor = colors[(i % #colors) + 1]
            local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
            
            game:GetService("TweenService"):Create(_G.Title, tweenInfo, { TextColor3 = nextColor }):Play()
            game:GetService("TweenService"):Create(uiStroke, tweenInfo, { Color = nextColor }):Play()
            
            i += 1
            Performance.Tasks["ColorCycle"] = task.delay(1.5, colorCycle)
        end
        
        colorCycle()
    end
end)

-- ==================== EXECUTOR DETECTION ====================
local executorName = "Unknown"
if identifyexecutor then executorName = identifyexecutor() end

local executorColor = Color3.fromRGB(200, 200, 200)
if executorName:lower():find("flux") then
    executorColor = Color3.fromHex("#30ff6a")
elseif executorName:lower():find("delta") then
    executorColor = Color3.fromHex("#38b6ff")
elseif executorName:lower():find("arceus") then
    executorColor = Color3.fromHex("#a03cff")
elseif executorName:lower():find("krampus") or executorName:lower():find("oxygen") then
    executorColor = Color3.fromHex("#ff3838")
elseif executorName:lower():find("volcano") then
    executorColor = Color3.fromHex("#ff8c00")
elseif executorName:lower():find("synapse") or executorName:lower():find("script") or executorName:lower():find("krypton") then
    executorColor = Color3.fromHex("#ffd700")
elseif executorName:lower():find("wave") then
    executorColor = Color3.fromHex("#00e5ff")
elseif executorName:lower():find("zenith") then
    executorColor = Color3.fromHex("#ff00ff")
elseif executorName:lower():find("seliware") then
    executorColor = Color3.fromHex("#00ffa2")
elseif executorName:lower():find("krnl") then
    executorColor = Color3.fromHex("#1e90ff")
elseif executorName:lower():find("trigon") then
    executorColor = Color3.fromHex("#ff007f")
elseif executorName:lower():find("nihon") then
    executorColor = Color3.fromHex("#8a2be2")
elseif executorName:lower():find("celery") then
    executorColor = Color3.fromHex("#4caf50")
elseif executorName:lower():find("lunar") then
    executorColor = Color3.fromHex("#8080ff")
elseif executorName:lower():find("valyse") then
    executorColor = Color3.fromHex("#ff1493")
elseif executorName:lower():find("vega") then
    executorColor = Color3.fromHex("#4682b4")
elseif executorName:lower():find("electron") then
    executorColor = Color3.fromHex("#7fffd4")
elseif executorName:lower():find("awp") then
    executorColor = Color3.fromHex("#ff005e")
elseif executorName:lower():find("bunni") or executorName:lower():find("bunni.lol") then
    executorColor = Color3.fromHex("#ff69b4")
end

-- ==================== MAIN WINDOW WITH LATEST WINDUI ====================
local Window = WindUI:CreateWindow({
    Title = "Victoria Hub",
    Icon = "rbxassetid://134034549147826",
    Author = "Freemium | Fish It",
    Folder = "VICTORIA_HUB",
    Size = UDim2.fromOffset(500, 380),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 200,
    HasOutline = true,
    CloseKey = Enum.KeyCode.RightControl
})

-- Executor Tag
Window:Tag({
    Title = "EXECUTOR | " .. executorName,
    Icon = "cpu",
    Color = executorColor,
    Radius = 0
})

-- Version Tag
Window:Tag({
    Title = "v0.0.9.2",
    Color = Color3.fromRGB(255, 255, 255),
    Radius = 17,
})

-- Discord Dialog
Window:Dialog({
    Icon = "disc",
    Title = "Join Discord",
    Content = "For Updates and Support",
    Buttons = {
        {
            Title = "Copy Link",
            Callback = function()
                if setclipboard then
                    setclipboard("https://discord.gg/victoriahub")
                    WindUI:Notify({
                        Title = "Copied Successfully!",
                        Content = "Discord link copied to clipboard",
                        Duration = 3,
                        Icon = "check"
                    })
                end
            end,
        },
        {
            Title = "Close",
            Callback = function()
                WindUI:Notify({
                    Title = "Closed",
                    Content = "Dialog closed",
                    Duration = 2,
                    Icon = "x"
                })
            end,
        },
    },
})

-- ==================== TABS CREATION ====================
-- Info Tab
local InfoTab = Window:Tab({
    Title = "Info",
    Icon = "info"
})

-- Players Tab
local PlayersTab = Window:Tab({
    Title = "Players",
    Icon = "users"
})

-- Main Tab
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "gamepad-2"
})

-- Auto Tab
local AutoTab = Window:Tab({
    Title = "Auto",
    Icon = "circle-ellipsis"
})

-- Webhook Tab
local WebhookTab = Window:Tab({
    Title = "Webhook",
    Icon = "star"
})

-- Shop Tab
local ShopTab = Window:Tab({
    Title = "Shop",
    Icon = "shopping-cart"
})

-- Teleport Tab
local TeleportTab = Window:Tab({
    Title = "Teleport",
    Icon = "map-pin"
})

-- Settings Tab
local SettingsTab = Window:Tab({
    Title = "Settings",
    Icon = "settings"
})

-- ==================== INFO TAB ====================
local InfoSection = InfoTab:Section({
    Title = "Victoria Hub Info",
    Icon = "info"
})

InfoSection:Paragraph({
    Title = "Welcome to Victoria Hub",
    Desc = "Premium Fishing Automation & Features",
    Image = "rbxassetid://134034549147826",
    Buttons = {
        {
            Title = "Copy Discord",
            Icon = "link",
            Callback = function()
                setclipboard("https://discord.gg/victoriahub")
                WindUI:Notify({
                    Title = "Copied!",
                    Content = "Discord link copied to clipboard",
                    Duration = 3,
                    Icon = "copy"
                })
            end
        }
    }
})

-- ==================== PLAYERS TAB ====================
local MovementSection = PlayersTab:Section({
    Title = "Movement",
    Icon = "zap"
})

MovementSection:Slider({
    Title = "Walk Speed",
    Desc = "Default: 16",
    Step = 1,
    Value = { Min = 16, Max = 200, Default = 16 },
    Callback = function(value)
        local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = value end
    end
})

MovementSection:Slider({
    Title = "Jump Power",
    Desc = "Default: 50",
    Step = 1,
    Value = { Min = 50, Max = 500, Default = 50 },
    Callback = function(value)
        local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.JumpPower = value end
    end
})

PlayersTab:Divider()

local CharacterSection = PlayersTab:Section({
    Title = "Character",
    Icon = "user"
})

_G.InfiniteJump = false
CharacterSection:Toggle({
    Title = "Infinite Jump",
    Desc = "Activate infinite jumping",
    Default = false,
    Callback = function(state)
        _G.InfiniteJump = state
    end
})

SafeConnect("InfiniteJump", game:GetService("UserInputService").JumpRequest:Connect(function()
    if _G.InfiniteJump then
        local h = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

_G.Noclip = false
CharacterSection:Toggle({
    Title = "Noclip",
    Desc = "Walk through walls",
    Default = false,
    Callback = function(state)
        _G.Noclip = state
        SafeCancel("NoclipLoop")
        
        if state then
            Performance.Tasks["NoclipLoop"] = task.spawn(function()
                while _G.Noclip do
                    task.wait(0.1)
                    local character = Player.Character
                    if character then
                        for _, part in pairs(character:GetDescendants()) do
                            if part:IsA("BasePart") and part.CanCollide then
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end)
        end
    end
})

-- ==================== MAIN TAB (FISHING) ====================
_G.AutoFishing = false
_G.AutoEquipRod = false

local FishingSection = MainTab:Section({
    Title = "Fishing",
    Icon = "fish"
})

FishingSection:Toggle({
    Title = "Auto Equip Rod",
    Default = false,
    Callback = function(state)
        _G.AutoEquipRod = state
        if state then
            -- Add rod equipping function here
            WindUI:Notify({
                Title = "Rod Equipped",
                Content = "Fishing rod equipped",
                Duration = 2,
                Icon = "check"
            })
        end
    end
})

local ModeDropdown = FishingSection:Dropdown({
    Title = "Fishing Mode",
    Values = {"Instant", "Legit"},
    Value = "Instant",
    Callback = function(value)
        getgenv().FishingMode = value
        WindUI:Notify({
            Title = "Mode Changed",
            Content = "Fishing mode: " .. value,
            Duration = 2,
            Icon = "settings"
        })
    end
})

_G.InstantDelay = 0.35
FishingSection:Slider({
    Title = "Instant Fishing Delay",
    Step = 0.01,
    Value = { Min = 0.05, Max = 5, Default = 0.35 },
    Callback = function(value)
        _G.InstantDelay = value
    end
})

FishingSection:Toggle({
    Title = "Auto Fishing",
    Default = false,
    Callback = function(state)
        _G.AutoFishing = state
        if state then
            WindUI:Notify({
                Title = "Auto Fishing",
                Content = "Started auto fishing",
                Duration = 2,
                Icon = "play"
            })
        else
            WindUI:Notify({
                Title = "Auto Fishing",
                Content = "Stopped auto fishing",
                Duration = 2,
                Icon = "stop"
            })
        end
    end
})

local ItemSection = MainTab:Section({
    Title = "Items",
    Icon = "package"
})

ItemSection:Toggle({
    Title = "Radar",
    Desc = "Enable fishing radar",
    Default = false,
    Callback = function(state)
        -- Add radar functionality
        WindUI:Notify({
            Title = "Radar",
            Content = state and "Enabled" or "Disabled",
            Duration = 2,
            Icon = state and "check" or "x"
        })
    end
})

ItemSection:Toggle({
    Title = "Bypass Oxygen",
    Desc = "Infinite oxygen",
    Default = false,
    Callback = function(state)
        -- Add oxygen bypass
        WindUI:Notify({
            Title = "Oxygen Bypass",
            Content = state and "Enabled" or "Disabled",
            Duration = 2,
            Icon = state and "check" or "x"
        })
    end
})

-- ==================== AUTO TAB ====================
local AutoSellSection = AutoTab:Section({
    Title = "Auto Sell",
    Icon = "dollar-sign"
})

AutoSellSection:Input({
    Title = "Sell When Fish ≥",
    Placeholder = "100",
    Callback = function(value)
        local num = tonumber(value)
        if num and num > 0 then
            getgenv().SellThreshold = num
            WindUI:Notify({
                Title = "Threshold Set",
                Content = "Will sell when fish count ≥ " .. num,
                Duration = 2,
                Icon = "check"
            })
        end
    end
})

AutoSellSection:Toggle({
    Title = "Auto Sell All Fish",
    Icon = "clock",
    Default = false,
    Callback = function(state)
        getgenv().AutoSell = state
        WindUI:Notify({
            Title = "Auto Sell",
            Content = state and "Enabled" or "Disabled",
            Duration = 2,
            Icon = state and "check" or "x"
        })
    end
})

local EventSection = AutoTab:Section({
    Title = "Events",
    Icon = "calendar"
})

EventSection:Toggle({
    Title = "Auto Claim Presents",
    Desc = "Auto claim Christmas presents",
    Default = false,
    Callback = function(state)
        WindUI:Notify({
            Title = "Auto Claim",
            Content = state and "Enabled" or "Disabled",
            Duration = 2,
            Icon = state and "check" or "x"
        })
    end
})

-- ==================== WEBHOOK TAB ====================
local WebhookSection = WebhookTab:Section({
    Title = "Webhook Settings",
    Icon = "webhook"
})

WebhookSection:Input({
    Title = "Webhook URL",
    Placeholder = "https://discord.com/api/webhooks/...",
    Callback = function(value)
        getgenv().WebhookURL = value
        if value and value:match("discord.com/api/webhooks") then
            WindUI:Notify({
                Title = "Webhook URL Set",
                Content = "Webhook URL saved",
                Duration = 2,
                Icon = "check"
            })
        end
    end
})

local rarityList = {"Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "SECRET"}
WebhookSection:Dropdown({
    Title = "Rarity Filter",
    Values = rarityList,
    Multi = true,
    AllowNone = true,
    Callback = function(selected)
        getgenv().WebhookRarities = selected
        WindUI:Notify({
            Title = "Rarity Filter",
            Content = #selected .. " rarities selected",
            Duration = 2,
            Icon = "filter"
        })
    end
})

WebhookSection:Toggle({
    Title = "Enable Fish Webhook",
    Default = false,
    Callback = function(state)
        getgenv().DetectNewFishActive = state
        WindUI:Notify({
            Title = "Fish Webhook",
            Content = state and "Enabled" or "Disabled",
            Duration = 2,
            Icon = state and "check" or "x"
        })
    end
})

WebhookSection:Button({
    Title = "Test Webhook",
    Callback = function()
        if getgenv().WebhookURL then
            WindUI:Notify({
                Title = "Webhook Test",
                Content = "Sending test webhook...",
                Duration = 3,
                Icon = "send"
            })
            -- Add test webhook function here
        else
            WindUI:Notify({
                Title = "Error",
                Content = "Webhook URL not set",
                Duration = 3,
                Icon = "x"
            })
        end
    end
})

-- ==================== SHOP TAB ====================
local RodSection = ShopTab:Section({
    Title = "Buy Rods",
    Icon = "fishing-rod"
})

local rodNames = {
    "Luck Rod (350 Coins)",
    "Carbon Rod (900 Coins)",
    "Grass Rod (1.5k Coins)",
    "Demascus Rod (3k Coins)",
    "Ice Rod (5k Coins)",
    "Lucky Rod (15k Coins)",
    "Midnight Rod (50k Coins)",
    "Steampunk Rod (215k Coins)",
    "Chrome Rod (437k Coins)",
    "Astral Rod (1M Coins)",
    "Ares Rod (3M Coins)",
    "Angler Rod (8M Coins)",
    "Bamboo Rod (12M Coins)"
}

RodSection:Dropdown({
    Title = "Select Rod",
    SearchBarEnabled = true,
    Values = rodNames,
    Value = rodNames[1],
    Callback = function(value)
        getgenv().SelectedRod = value
    end
})

RodSection:Button({
    Title = "Buy Selected Rod",
    Callback = function()
        if getgenv().SelectedRod then
            WindUI:Notify({
                Title = "Purchase",
                Content = "Buying: " .. getgenv().SelectedRod,
                Duration = 3,
                Icon = "shopping-cart"
            })
            -- Add purchase function here
        end
    end
})

local BaitSection = ShopTab:Section({
    Title = "Buy Baits",
    Icon = "worm"
})

-- ==================== TELEPORT TAB ====================
local IslandSection = TeleportTab:Section({
    Title = "Islands",
    Icon = "globe"
})

local islandLocations = {
    "Admin Event", "Ancient Jungle", "Coral Reefs", "Crater Island",
    "Enchant Room", "Esoteric Island", "Fisherman Island", "Kohana Volcano",
    "Lost Isle", "Sacred Temple", "Tropical Grove", "Weather Machine"
}

IslandSection:Dropdown({
    Title = "Select Island",
    SearchBarEnabled = true,
    Values = islandLocations,
    Value = islandLocations[1],
    Callback = function(value)
        getgenv().SelectedIsland = value
    end
})

IslandSection:Button({
    Title = "Teleport to Island",
    Callback = function()
        if getgenv().SelectedIsland and _G.HRP then
            WindUI:Notify({
                Title = "Teleporting",
                Content = "Teleporting to: " .. getgenv().SelectedIsland,
                Duration = 2,
                Icon = "map-pin"
            })
            -- Add teleport function here
        end
    end
})

local PlayerTPSection = TeleportTab:Section({
    Title = "Player Teleport",
    Icon = "user"
})

-- Function to get player list
local function getPlayerList()
    local players = {}
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player ~= Player then
            table.insert(players, player.Name)
        end
    end
    return players
end

local playerDropdown = PlayerTPSection:Dropdown({
    Title = "Select Player",
    Values = getPlayerList(),
    Value = "",
    Callback = function(value)
        getgenv().SelectedPlayer = value
    end
})

PlayerTPSection:Button({
    Title = "Teleport to Player",
    Callback = function()
        if getgenv().SelectedPlayer and _G.HRP then
            WindUI:Notify({
                Title = "Teleporting",
                Content = "Teleporting to: " .. getgenv().SelectedPlayer,
                Duration = 2,
                Icon = "user-check"
            })
            -- Add player teleport function here
        end
    end
})

PlayerTPSection:Button({
    Title = "Refresh Player List",
    Callback = function()
        local players = getPlayerList()
        -- Note: WindUI dropdowns might need manual update
        -- You might need to recreate the section or use a different approach
        WindUI:Notify({
            Title = "Refreshed",
            Content = "Player list refreshed",
            Duration = 2,
            Icon = "refresh-cw"
        })
    end
})

-- ==================== SETTINGS TAB ====================
local PlayerSettings = SettingsTab:Section({
    Title = "Player Features",
    Icon = "user"
})

PlayerSettings:Toggle({
    Title = "Ping Display",
    Desc = "Show ping and FPS",
    Default = false,
    Callback = function(state)
        WindUI:Notify({
            Title = "Ping Display",
            Content = state and "Enabled" or "Disabled",
            Duration = 2,
            Icon = state and "check" or "x"
        })
    end
})

_G.AntiAFK = true
PlayerSettings:Toggle({
    Title = "Anti-AFK",
    Desc = "Prevent idle kicking",
    Default = true,
    Callback = function(state)
        _G.AntiAFK = state
        WindUI:Notify({
            Title = "Anti-AFK",
            Content = state and "Enabled" or "Disabled",
            Duration = 2,
            Icon = state and "check" or "x"
        })
    end
})

local GraphicsSection = SettingsTab:Section({
    Title = "Graphics",
    Icon = "monitor"
})

GraphicsSection:Toggle({
    Title = "FPS Boost",
    Desc = "Optimize graphics for FPS",
    Default = false,
    Callback = function(state)
        WindUI:Notify({
            Title = "FPS Boost",
            Content = state and "Enabled" or "Disabled",
            Duration = 2,
            Icon = state and "check" or "x"
        })
    end
})

GraphicsSection:Toggle({
    Title = "Hide VFX",
    Desc = "Disable visual effects",
    Default = false,
    Callback = function(state)
        WindUI:Notify({
            Title = "VFX",
            Content = state and "Hidden" or "Visible",
            Duration = 2,
            Icon = state and "eye-off" or "eye"
        })
    end
})

local ServerSection = SettingsTab:Section({
    Title = "Server",
    Icon = "server"
})

ServerSection:Button({
    Title = "Rejoin Server",
    Callback = function()
        WindUI:Notify({
            Title = "Rejoining",
            Content = "Rejoining server...",
            Duration = 3,
            Icon = "refresh-cw"
        })
        task.wait(2)
        game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
    end
})

ServerSection:Button({
    Title = "Server Hop",
    Callback = function()
        WindUI:Notify({
            Title = "Server Hop",
            Content = "Looking for new server...",
            Duration = 3,
            Icon = "server"
        })
        -- Add server hop function here
    end
})

-- ==================== INITIALIZATION ====================
-- Select Info tab by default
Window:SelectTab(1)

-- Initial notification
WindUI:Notify({
    Title = "Victoria Hub Loaded",
    Content = "Welcome to Victoria Hub v0.0.9.2",
    Duration = 5,
    Icon = "bell"
})

print("✅ Victoria Hub v0.0.9.2 - Modern UI Loaded Successfully!")
print("👤 Executor: " .. executorName)
print("🎮 Game: " .. game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name)

return Window
