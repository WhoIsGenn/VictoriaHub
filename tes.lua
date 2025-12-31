-- ====================================================================
--           AUTO FISH V7.0 - OPTIMIZED STABLE EDITION
--              Clean Code | Stable Features | Performance
-- ====================================================================

-- ====== DEPENDENCY CHECK ======
local success, errorMsg = pcall(function()
    assert(game, "game")
    assert(workspace, "workspace")
    assert(game:GetService("Players"), "Players")
    assert(game:GetService("ReplicatedStorage"), "ReplicatedStorage")
    return true
end)

if not success then
    error("❌ Critical dependency check failed: " .. tostring(errorMsg))
    return
end

-- ====== SERVICES ======
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- ====== CONFIGURATION ======
local CONFIG_FOLDER = "AutoFish_V7"
local CONFIG_FILE = CONFIG_FOLDER .. "/config_" .. LocalPlayer.UserId .. ".json"

local DefaultConfig = {
    -- Fishing Modes (SEPARATE TOGGLES)
    AutoFishBlatant = false,
    AutoFishLegit = false,
    AutoFishInstant = false,
    
    -- Blatant Settings
    BlatantReelDelay = 0.1,
    BlatantCastDelay = 0.15,
    
    -- Legit Settings (uses game's fishing, auto includes shake & reel)
    LegitFishingDelay = 1.0,
    
    -- Instant Settings
    InstantCompleteDelay = 0.5,
    
    -- Auto Systems
    AutoSell = false,
    SellThreshold = 50,
    SellDelay = 30,
    AutoFavorite = true,
    FavoriteRarity = "Mythic",
    
    -- Auto Weather
    AutoBuyWeather = false,
    WeatherLoop = false,
    SelectedWeathers = {Wind = true, Cloudy = true, Storm = true},
    WeatherBuyDelay = 300,
    
    -- Webhook
    WebhookEnabled = false,
    WebhookURL = "",
    WebhookRarities = {Common = false, Uncommon = false, Rare = false, Epic = false, Legendary = false, Mythic = true, Secret = true},
    
    -- Performance
    BoostFPS = 60,
    NoFishingAnimation = false,
    DisableCutscene = true,
    DisableFishNotifIcon = false,
    DisableFishingEffects = false,
    DisableVFX = false,
    
    -- Misc
    TeleportLocation = "Sisyphus Statue",
    ShowPingFPS = true,
    
    -- Auto Event
    AutoMegalodon = false,
    AutoGhostShark = false,
    AutoMerchant = false
}

local Config = {}
for k, v in pairs(DefaultConfig) do 
    if type(v) == "table" then
        Config[k] = {}
        for k2, v2 in pairs(v) do Config[k][k2] = v2 end
    else
        Config[k] = v 
    end
end

-- ====== TELEPORT LOCATIONS ======
local LOCATIONS = {
    ["Spawn"] = CFrame.new(45.2788086, 252.562927, 2987.10913),
    ["Sisyphus Statue"] = CFrame.new(-3728.21606, -135.074417, -1012.12744),
    ["Coral Reefs"] = CFrame.new(-3114.78198, 1.32066584, 2237.52295),
    ["Esoteric Depths"] = CFrame.new(3248.37109, -1301.53027, 1403.82727),
    ["Crater Island"] = CFrame.new(1016.49072, 20.0919304, 5069.27295),
    ["Lost Isle"] = CFrame.new(-3618.15698, 240.836655, -1317.45801),
    ["Weather Machine"] = CFrame.new(-1488.51196, 83.1732635, 1876.30298),
    ["Tropical Grove"] = CFrame.new(-2095.34106, 197.199997, 3718.08008),
    ["Mount Hallow"] = CFrame.new(2136.62305, 78.9163895, 3272.50439),
    ["Treasure Room"] = CFrame.new(-3606.34985, -266.57373, -1580.97339),
    ["Kohana"] = CFrame.new(-663.904236, 3.04580712, 718.796875),
    ["Underground Cellar"] = CFrame.new(2109.52148, -94.1875076, -708.609131),
    ["Ancient Jungle"] = CFrame.new(1831.71362, 6.62499952, -299.279175),
    ["Sacred Temple"] = CFrame.new(1466.92151, -21.8750591, -622.835693)
}

-- Weather list and prices
local WEATHER_DATA = {
    {Name = "Clear", Price = 0},
    {Name = "Wind", Price = 500},
    {Name = "Cloudy", Price = 1000},
    {Name = "Foggy", Price = 1500},
    {Name = "Rain", Price = 2000},
    {Name = "Storm", Price = 2500}
}

-- ====== CONFIG FUNCTIONS ======
local function saveConfig()
    if not writefile or not isfolder or not makefolder then return end
    if not isfolder(CONFIG_FOLDER) then pcall(makefolder, CONFIG_FOLDER) end
    pcall(function() writefile(CONFIG_FILE, HttpService:JSONEncode(Config)) end)
end

local function loadConfig()
    if not readfile or not isfile or not isfile(CONFIG_FILE) then return end
    pcall(function()
        local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
        for k, v in pairs(data) do
            if DefaultConfig[k] ~= nil then 
                if type(v) == "table" and type(Config[k]) == "table" then
                    for k2, v2 in pairs(v) do Config[k][k2] = v2 end
                else Config[k] = v end
            end
        end
    end)
end

loadConfig()

-- ====== NETWORK EVENTS ======
local function getEvents()
    local net = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
    return {
        fishing = net:WaitForChild("RE/FishingCompleted"),
        sell = net:WaitForChild("RF/SellAllItems"),
        charge = net:WaitForChild("RF/ChargeFishingRod"),
        minigame = net:WaitForChild("RF/RequestFishingMinigameStarted"),
        equip = net:WaitForChild("RE/EquipToolFromHotbar"),
        unequip = net:WaitForChild("RE/UnequipToolFromHotbar"),
        favorite = net:WaitForChild("RE/FavoriteItem"),
        weather = net:WaitForChild("RF/PurchaseWeather"),
        shake = net:WaitForChild("RE/FishingShake")
    }
end

local Events = getEvents()

-- ====== MODULES ======
local ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
local Replion = require(ReplicatedStorage.Packages.Replion)
local PlayerData = Replion.Client:WaitReplion("Data")

-- ====== RARITY SYSTEM ======
local RarityTiers = {Common=1, Uncommon=2, Rare=3, Epic=4, Legendary=5, Mythic=6, Secret=7}

local function getRarityValue(rarity)
    return RarityTiers[rarity] or 0
end

-- ====== PING & FPS DISPLAY ======
local PingFPSGui = nil

local function createPingFPSDisplay()
    if PingFPSGui then PingFPSGui:Destroy() end
    
    PingFPSGui = Instance.new("ScreenGui")
    PingFPSGui.Name = "PingFPSDisplay"
    PingFPSGui.ResetOnSpawn = false
    PingFPSGui.DisplayOrder = 999999
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 60)
    frame.Position = UDim2.new(1, -210, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BackgroundTransparency = 0.3
    frame.BorderSizePixel = 0
    frame.Parent = PingFPSGui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, -20)
    label.Position = UDim2.new(0, 10, 0, 10)
    label.BackgroundTransparency = 1
    label.Text = "Loading..."
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextSize = 14
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    PingFPSGui.Parent = game.CoreGui
    
    -- Update loop
    task.spawn(function()
        local lastTime = tick()
        local fps = 0
        
        while PingFPSGui and PingFPSGui.Parent do
            local currentTime = tick()
            fps = math.floor(1 / (currentTime - lastTime))
            lastTime = currentTime
            
            local ping = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()
            
            label.Text = string.format("🌐 Ping: %d ms\n📊 FPS: %d", math.floor(ping), fps)
            
            task.wait(1)
        end
    end)
end

if Config.ShowPingFPS then
    createPingFPSDisplay()
end

-- ====== WEBHOOK SYSTEM ======
local function sendWebhook(fishName, rarity, itemData)
    if not Config.WebhookEnabled or Config.WebhookURL == "" then return end
    if not Config.WebhookRarities[rarity] then return end
    
    pcall(function()
        local embed = {
            title = "🎣 Rare Fish Caught!",
            description = string.format("**%s** has been caught!", fishName),
            color = ({
                Mythic = 0xFF00FF,
                Secret = 0xFFD700,
                Legendary = 0xFF4500,
                Epic = 0x9400D3,
                Rare = 0x0000FF,
                Uncommon = 0x00FF00,
                Common = 0xFFFFFF
            })[rarity] or 0xFFFFFF,
            fields = {
                {name = "Fish", value = fishName, inline = true},
                {name = "Rarity", value = rarity, inline = true},
                {name = "Player", value = LocalPlayer.Name, inline = true},
                {name = "Time", value = os.date("%H:%M:%S"), inline = true}
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
        }
        
        local data = {
            embeds = {embed}
        }
        
        request({
            Url = Config.WebhookURL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode(data)
        })
    end)
end

-- ====== PERFORMANCE OPTIMIZATIONS ======

-- FPS Booster
local function setFPSCap(fps)
    pcall(function()
        if fps <= 30 then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        elseif fps <= 60 then
            settings().Rendering.QualityLevel = Enum.QualityLevel.Level03
        else
            settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        end
        
        if setfpscap then
            setfpscap(fps)
        end
    end)
end

-- No Fishing Animation
local function disableFishingAnimation()
    if not Config.NoFishingAnimation then return end
    pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        
        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
            if track.Animation and string.find(string.lower(track.Animation.Name), "fish") then
                track:Stop()
            end
        end
    end)
end

-- Disable Cutscene
local function disableCutscene()
    if not Config.DisableCutscene then return end
    pcall(function()
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        for _, gui in pairs(playerGui:GetChildren()) do
            if string.find(string.lower(gui.Name), "cutscene") or 
               string.find(string.lower(gui.Name), "intro") then
                gui.Enabled = false
            end
        end
    end)
end

-- Disable Fish Notification Icon (slow down notif spam)
local notifDelay = {}
local function disableFishNotifIcon()
    if not Config.DisableFishNotifIcon then return end
    pcall(function()
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        for _, gui in pairs(playerGui:GetDescendants()) do
            if gui:IsA("ImageLabel") and (
                string.find(string.lower(gui.Name), "fish") or 
                string.find(string.lower(gui.Name), "item") or
                string.find(string.lower(gui.Name), "icon")
            ) then
                if gui.Parent and gui.Parent:FindFirstChild("TextLabel") then
                    gui.Visible = false
                    
                    -- Slow down notification spam
                    if not notifDelay[gui] then
                        notifDelay[gui] = true
                        task.spawn(function()
                            task.wait(0.5) -- Add delay to make notif visible longer
                            notifDelay[gui] = nil
                        end)
                    end
                end
            end
        end
    end)
end

-- Disable Fishing Effects
local function disableFishingEffects()
    if not Config.DisableFishingEffects then return end
    pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        
        for _, obj in pairs(character:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Beam") or obj:IsA("Trail") then
                if string.find(string.lower(obj.Name), "fish") or 
                   string.find(string.lower(obj.Name), "water") then
                    obj.Enabled = false
                end
            end
        end
    end)
end

-- Disable VFX
local function disableVFX()
    if not Config.DisableVFX then return end
    pcall(function()
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Beam") then
                obj.Enabled = false
            end
        end
        
        for _, effect in pairs(Lighting:GetChildren()) do
            if effect:IsA("PostEffect") then
                effect.Enabled = false
            end
        end
    end)
end

-- Monitor performance features
task.spawn(function()
    while true do
        task.wait(0.5)
        disableFishingAnimation()
        disableCutscene()
        disableFishNotifIcon()
        disableFishingEffects()
        disableVFX()
    end
end)

-- ====== FISHING SYSTEM ======
local currentRodSlot = 1

-- Get currently equipped rod
local function getCurrentRod()
    pcall(function()
        local character = LocalPlayer.Character
        if character then
            local tool = character:FindFirstChildOfClass("Tool")
            if tool and string.find(string.lower(tool.Name), "rod") then
                local hotbar = PlayerData:GetExpect("Hotbar")
                for slot, itemId in pairs(hotbar) do
                    local itemData = ItemUtility:GetItemData(itemId)
                    if itemData and itemData.Data and itemData.Data.Name == tool.Name then
                        currentRodSlot = slot
                        return
                    end
                end
            end
        end
    end)
end

-- ====== 1. BLATANT MODE - FASTEST & MOST AGGRESSIVE (SEPARATE) ======
local blatantActive = false
local blatantFishing = false

local function startBlatantMode()
    blatantActive = true
    
    task.spawn(function()
        while blatantActive do
            if not blatantFishing then
                blatantFishing = true
                
                pcall(function()
                    getCurrentRod()
                    
                    -- Ultra fast cast (3 rods parallel like other hubs)
                    Events.equip:FireServer(currentRodSlot)
                    task.wait(Config.BlatantCastDelay)
                    
                    -- Triple cast for maximum speed
                    for i = 1, 3 do
                        task.spawn(function()
                            Events.charge:InvokeServer(1755848498.4834)
                            task.wait(0.01)
                            Events.minigame:InvokeServer(1.2854545116425, currentRodSlot)
                        end)
                        task.wait(Config.BlatantCastDelay * 0.5)
                    end
                    
                    -- Minimal wait for bite (super fast)
                    task.wait(0.5)
                    
                    -- Spam reel 6x for instant catch (like other hubs)
                    for i = 1, 6 do
                        Events.fishing:FireServer()
                        task.wait(Config.BlatantReelDelay)
                    end
                    
                    -- Minimal cooldown (fastest cycle)
                    task.wait(0.1)
                end)
                
                blatantFishing = false
            else
                task.wait(0.01)
            end
        end
    end)
end

local function stopBlatantMode()
    blatantActive = false
    blatantFishing = false
    pcall(function() Events.unequip:FireServer() end)
end

-- ====== 2. LEGIT MODE - Uses Game's Fishing + Auto Assist (SEPARATE) ======
local legitActive = false
local legitConnection = nil

local function startLegitMode()
    legitActive = true
    
    if legitConnection then legitConnection:Disconnect() end
    
    legitConnection = RunService.Heartbeat:Connect(function()
        if not legitActive then return end
        
        pcall(function()
            local playerGui = LocalPlayer:WaitForChild("PlayerGui")
            local fishingGui = playerGui:FindFirstChild("FishingGui")
            
            if fishingGui then
                -- Auto Shake/Tap (Always enabled in Legit mode)
                local shakeFrame = fishingGui:FindFirstChild("Shake", true)
                if shakeFrame and shakeFrame.Visible then
                    for i = 1, 3 do
                        Events.shake:FireServer()
                        task.wait(0.05)
                    end
                end
                
                -- Auto Reel (Always enabled in Legit mode)
                local reelButton = fishingGui:FindFirstChild("ReelButton", true)
                if reelButton and reelButton.Visible then
                    for i = 1, 2 do
                        Events.fishing:FireServer()
                        task.wait(0.1)
                    end
                end
            end
        end)
        
        -- Apply legit fishing delay
        task.wait(Config.LegitFishingDelay)
    end)
end

local function stopLegitMode()
    legitActive = false
    if legitConnection then
        legitConnection:Disconnect()
        legitConnection = nil
    end
end

-- ====== 3. INSTANT FISHING - Fast Complete with Delay (SEPARATE) ======
local instantActive = false
local instantFishing = false

local function startInstantMode()
    instantActive = true
    
    task.spawn(function()
        while instantActive do
            if not instantFishing then
                instantFishing = true
                
                pcall(function()
                    getCurrentRod()
                    
                    -- Normal cast
                    Events.equip:FireServer(currentRodSlot)
                    task.wait(0.15)
                    Events.charge:InvokeServer(1755848498.4834)
                    task.wait(0.02)
                    Events.minigame:InvokeServer(1.2854545116425, currentRodSlot)
                    
                    -- Wait for bite (normal timing)
                    task.wait(0.8)
                    
                    -- Instant complete with user-defined delay
                    task.wait(Config.InstantCompleteDelay)
                    
                    -- Spam reel 5x (less aggressive than blatant)
                    for i = 1, 5 do
                        Events.fishing:FireServer()
                        task.wait(0.02)
                    end
                    
                    -- Normal cooldown
                    task.wait(0.3)
                end)
                
                instantFishing = false
            else
                task.wait(0.01)
            end
        end
    end)
end

local function stopInstantMode()
    instantActive = false
    instantFishing = false
    pcall(function() Events.unequip:FireServer() end)
end

-- ====== AUTO SELL BY THRESHOLD ======
local function autoSell()
    pcall(function()
        local items = PlayerData:GetExpect("Inventory").Items
        local itemCount = #items
        
        if itemCount >= Config.SellThreshold then
            Events.sell:InvokeServer()
            print("[Auto Sell] ✅ Sold " .. itemCount .. " items (Threshold: " .. Config.SellThreshold .. ")")
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(Config.SellDelay)
        if Config.AutoSell then
            autoSell()
        end
    end
end)

-- ====== AUTO FAVORITE ======
local favoritedItems = {}

local function autoFavorite()
    if not Config.AutoFavorite then return end
    
    local targetValue = getRarityValue(Config.FavoriteRarity)
    if targetValue < 6 then targetValue = 6 end
    
    pcall(function()
        local items = PlayerData:GetExpect("Inventory").Items
        if not items then return end
        
        for _, item in ipairs(items) do
            local data = ItemUtility:GetItemData(item.Id)
            if data and data.Data then
                local rarity = data.Data.Rarity or "Common"
                local rarityValue = getRarityValue(rarity)
                
                if rarityValue >= targetValue and not favoritedItems[item.UUID] then
                    Events.favorite:FireServer(item.UUID)
                    favoritedItems[item.UUID] = true
                    
                    -- Send webhook for rare fish
                    sendWebhook(data.Data.Name or "Unknown", rarity, data)
                    
                    task.wait(0.3)
                end
            end
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(15)
        autoFavorite()
    end
end)

-- ====== AUTO WEATHER SYSTEM ======
local lastWeatherBuy = 0

local function buyWeather(weatherName)
    if tick() - lastWeatherBuy < 60 then return end
    
    pcall(function()
        Events.weather:InvokeServer(weatherName)
        lastWeatherBuy = tick()
        print("[Weather] 🌤️ Purchased: " .. weatherName)
    end)
end

task.spawn(function()
    while true do
        task.wait(Config.WeatherBuyDelay)
        
        if Config.AutoBuyWeather then
            if Config.WeatherLoop then
                -- Loop through Wind, Cloudy, Storm only
                local loopWeathers = {"Wind", "Cloudy", "Storm"}
                for _, weather in ipairs(loopWeathers) do
                    if Config.SelectedWeathers[weather] then
                        buyWeather(weather)
                        task.wait(60)
                    end
                end
            else
                -- Buy once
                for weather, enabled in pairs(Config.SelectedWeathers) do
                    if enabled then
                        buyWeather(weather)
                        break
                    end
                end
            end
        end
    end
end)

-- ====== AUTO EVENT DETECTION ======

-- Scan for Megalodon
local function scanMegalodon()
    for _, npc in pairs(Workspace:GetDescendants()) do
        if npc.Name == "Megalodon" or string.find(string.lower(npc.Name), "megalodon") then
            return npc
        end
    end
    return nil
end

-- Scan for Ghost Shark
local function scanGhostShark()
    for _, npc in pairs(Workspace:GetDescendants()) do
        if npc.Name == "GhostShark" or string.find(string.lower(npc.Name), "ghost") then
            return npc
        end
    end
    return nil
end

-- Auto Megalodon Hunt
task.spawn(function()
    while true do
        task.wait(5)
        
        if Config.AutoMegalodon then
            local megalodon = scanMegalodon()
            if megalodon then
                local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if rootPart and megalodon:FindFirstChild("HumanoidRootPart") then
                    rootPart.CFrame = megalodon.HumanoidRootPart.CFrame * CFrame.new(0, 5, 10)
                    print("[Event] 🦈 Megalodon detected! Teleporting...")
                    task.wait(2)
                end
            end
        end
    end
end)

-- Auto Ghost Shark Hunt
task.spawn(function()
    while true do
        task.wait(5)
        
        if Config.AutoGhostShark then
            local ghostShark = scanGhostShark()
            if ghostShark then
                local rootPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if rootPart and ghostShark:FindFirstChild("HumanoidRootPart") then
                    rootPart.CFrame = ghostShark.HumanoidRootPart.CFrame * CFrame.new(0, 5, 10)
                    print("[Event] 👻 Ghost Shark detected! Teleporting...")
                    task.wait(2)
                end
            end
        end
    end
end)

-- ====== MERCHANT SHOP SCANNER ======
local merchantData = {}

local function scanMerchant()
    merchantData = {}
    
    pcall(function()
        for _, npc in pairs(Workspace:GetDescendants()) do
            if npc.Name == "Merchant" or string.find(string.lower(npc.Name), "merchant") then
                local stock = {}
                local prompt = npc:FindFirstChildOfClass("ProximityPrompt")
                
                if prompt then
                    table.insert(merchantData, {
                        Name = npc.Name,
                        Position = npc:FindFirstChild("HumanoidRootPart") and npc.HumanoidRootPart.Position or Vector3.new(0,0,0),
                        Stock = stock
                    })
                end
            end
        end
    end)
    
    return merchantData
end

task.spawn(function()
    while true do
        task.wait(30)
        
        if Config.AutoMerchant then
            scanMerchant()
            if #merchantData > 0 then
                print("[Merchant] 🛒 Found " .. #merchantData .. " merchants")
            end
        end
    end
end)

-- ====== TELEPORT SYSTEM ======
local function teleportTo(locationName)
    local cframe = LOCATIONS[locationName]
    if not cframe then return false end
    
    pcall(function()
        local character = LocalPlayer.Character
        if not character then return end
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return end
        
        rootPart.CFrame = cframe
        print("[Teleport] ✅ " .. locationName)
    end)
    
    return true
end

-- ====== ANTI-AFK ======
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- ====== LOAD WINDUI ======
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/sius-x/Wind-UI/main/source.lua"))()

local Window = WindUI:CreateWindow({
    Title = "🎣 Auto Fish V7.0 - Optimized",
    Icon = "rbxassetid://4483362458",
    Author = "VictoriaHub",
    Folder = "VH_AutoFish_V7",
    Size = UDim2.fromOffset(600, 520),
    KeySystem = {
        Key = "FreeForAll",
        Note = "No Key Required",
        SaveKey = false,
        CheckKey = function(k) return k == "FreeForAll" end
    },
    Transparent = true,
    Theme = "Dark"
})

-- ====== BLATANT TAB ======
local BlatantTab = Window:Tab({Name = "Blatant", Icon = "rbxassetid://10734950309", Color = Color3.fromRGB(255,0,0)})

local BlatantSec = BlatantTab:Section({Name = "⚡ Blatant Mode", Side = "Left"})

BlatantSec:Toggle({
    Name = "🤖 Auto Fish (Blatant)",
    Value = Config.AutoFishBlatant,
    Callback = function(v)
        Config.AutoFishBlatant = v
        if v then 
            -- Stop other modes
            Config.AutoFishLegit = false
            Config.AutoFishInstant = false
            stopLegitMode()
            stopInstantMode()
            
            startBlatantMode() 
        else 
            stopBlatantMode() 
        end
        saveConfig()
    end
})

BlatantSec:Slider({
    Name = "Reel/Bait Delay",
    Min = 0.05,
    Max = 0.5,
    Default = Config.BlatantReelDelay,
    Callback = function(v)
        Config.BlatantReelDelay = v
        saveConfig()
    end
})

BlatantSec:Slider({
    Name = "Cast Delay",
    Min = 0.1,
    Max = 1.0,
    Default = Config.BlatantCastDelay,
    Callback = function(v)
        Config.BlatantCastDelay = v
        saveConfig()
    end
})

BlatantSec:Label({Name = "💡 Blatant Mode: FASTEST!"})
BlatantSec:Label({Name = "Triple cast + spam reel 6x"})
BlatantSec:Label({Name = "Like other premium hubs"})
BlatantSec:Label({Name = "Most aggressive mode"})

-- ====== LEGIT TAB ======
local LegitTab = Window:Tab({Name = "Legit", Icon = "rbxassetid://10734950309", Color = Color3.fromRGB(0,255,0)})

local LegitSec = LegitTab:Section({Name = "🎮 Legit Mode", Side = "Left"})

LegitSec:Toggle({
    Name = "🤖 Auto Fish (Legit)",
    Value = Config.AutoFishLegit,
    Callback = function(v)
        Config.AutoFishLegit = v
        if v then 
            -- Stop other modes
            Config.AutoFishBlatant = false
            Config.AutoFishInstant = false
            stopBlatantMode()
            stopInstantMode()
            
            startLegitMode() 
        else 
            stopLegitMode() 
        end
        saveConfig()
    end
})

LegitSec:Slider({
    Name = "Auto Fishing Delay",
    Min = 0.5,
    Max = 3.0,
    Default = Config.LegitFishingDelay,
    Callback = function(v)
        Config.LegitFishingDelay = v
        saveConfig()
    end
})

LegitSec:Label({Name = "💡 Legit Mode: Uses game fishing"})
LegitSec:Label({Name = "Auto includes shake & reel"})
LegitSec:Label({Name = "Most safe, looks natural"})
LegitSec:Label({Name = "Delay controls overall speed"})

-- ====== INSTANT TAB ======
local InstantTab = Window:Tab({Name = "Instant", Icon = "rbxassetid://10734950309", Color = Color3.fromRGB(255,255,0)})

local InstantSec = InstantTab:Section({Name = "⚡ Instant Mode", Side = "Left"})

InstantSec:Toggle({
    Name = "🤖 Auto Fish (Instant)",
    Value = Config.AutoFishInstant,
    Callback = function(v)
        Config.AutoFishInstant = v
        if v then 
            -- Stop other modes
            Config.AutoFishBlatant = false
            Config.AutoFishLegit = false
            stopBlatantMode()
            stopLegitMode()
            
            startInstantMode() 
        else 
            stopInstantMode() 
        end
        saveConfig()
    end
})

InstantSec:Slider({
    Name = "Complete Delay",
    Min = 0.1,
    Max = 2.0,
    Default = Config.InstantCompleteDelay,
    Callback = function(v)
        Config.InstantCompleteDelay = v
        saveConfig()
    end
})

InstantSec:Label({Name = "💡 Instant Mode: Medium-Fast"})
InstantSec:Label({Name = "Spam 5x reel for quick catch"})
InstantSec:Label({Name = "Faster than Legit"})
InstantSec:Label({Name = "Slower than Blatant"})

-- ====== SELL TAB ======
local SellTab = Window:Tab({Name = "Sell", Icon = "rbxassetid://10734950309", Color = Color3.fromRGB(0,200,255)})

local SellSec = SellTab:Section({Name = "💰 Auto Sell", Side = "Left"})

SellSec:Toggle({
    Name = "💰 Auto Sell",
    Value = Config.AutoSell,
    Callback = function(v)
        Config.AutoSell = v
        saveConfig()
    end
})

SellSec:Slider({
    Name = "Sell Threshold",
    Min = 10,
    Max = 100,
    Default = Config.SellThreshold,
    Callback = function(v)
        Config.SellThreshold = v
        saveConfig()
    end
})

SellSec:Slider({
    Name = "Sell Delay (seconds)",
    Min = 10,
    Max = 300,
    Default = Config.SellDelay,
    Callback = function(v)
        Config.SellDelay = v
        saveConfig()
    end
})

SellSec:Button({
    Name = "💰 Sell All Now",
    Callback = function()
        pcall(function() 
            Events.sell:InvokeServer()
            print("[Manual Sell] ✅ Sold all items")
        end)
    end
})

SellSec:Label({Name = "💡 Auto sells when inventory"})
SellSec:Label({Name = "reaches threshold amount"})

-- Favorite Section
local FavSec = SellTab:Section({Name = "⭐ Auto Favorite", Side = "Right"})

FavSec:Toggle({
    Name = "⭐ Auto Favorite",
    Value = Config.AutoFavorite,
    Callback = function(v)
        Config.AutoFavorite = v
        saveConfig()
    end
})

FavSec:Dropdown({
    Name = "Favorite Rarity",
    Options = {"Mythic", "Secret"},
    Default = Config.FavoriteRarity,
    Callback = function(v)
        Config.FavoriteRarity = v
        saveConfig()
    end
})

FavSec:Button({
    Name = "⭐ Favorite All Now",
    Callback = function()
        autoFavorite()
        print("[Manual Favorite] ✅ Favorited rare fish")
    end
})

-- ====== WEATHER TAB ======
local WeatherTab = Window:Tab({Name = "Weather", Icon = "rbxassetid://10734950309", Color = Color3.fromRGB(100,200,255)})

local WeatherSec = WeatherTab:Section({Name = "🌤️ Auto Weather", Side = "Left"})

WeatherSec:Toggle({
    Name = "🌤️ Auto Buy Weather",
    Value = Config.AutoBuyWeather,
    Callback = function(v)
        Config.AutoBuyWeather = v
        saveConfig()
    end
})

WeatherSec:Toggle({
    Name = "🔄 Weather Loop (W/C/S)",
    Value = Config.WeatherLoop,
    Callback = function(v)
        Config.WeatherLoop = v
        saveConfig()
    end
})

WeatherSec:Slider({
    Name = "Buy Delay (seconds)",
    Min = 60,
    Max = 600,
    Default = Config.WeatherBuyDelay,
    Callback = function(v)
        Config.WeatherBuyDelay = v
        saveConfig()
    end
})

WeatherSec:Label({Name = "Select Weathers:"})

WeatherSec:Toggle({
    Name = "💨 Wind ($500)",
    Value = Config.SelectedWeathers.Wind,
    Callback = function(v)
        Config.SelectedWeathers.Wind = v
        saveConfig()
    end
})

WeatherSec:Toggle({
    Name = "☁️ Cloudy ($1000)",
    Value = Config.SelectedWeathers.Cloudy,
    Callback = function(v)
        Config.SelectedWeathers.Cloudy = v
        saveConfig()
    end
})

WeatherSec:Toggle({
    Name = "⛈️ Storm ($2500)",
    Value = Config.SelectedWeathers.Storm,
    Callback = function(v)
        Config.SelectedWeathers.Storm = v
        saveConfig()
    end
})

WeatherSec:Label({Name = "💡 Loop: Buys Wind→Cloudy→Storm"})
WeatherSec:Label({Name = "Non-loop: Buys once only"})

-- ====== WEBHOOK TAB ======
local WebhookTab = Window:Tab({Name = "Webhook", Icon = "rbxassetid://10734950309", Color = Color3.fromRGB(150,0,255)})

local WebhookSec = WebhookTab:Section({Name = "🔔 Discord Webhook", Side = "Left"})

WebhookSec:Toggle({
    Name = "🔔 Enable Webhook",
    Value = Config.WebhookEnabled,
    Callback = function(v)
        Config.WebhookEnabled = v
        saveConfig()
    end
})

WebhookSec:Input({
    Name = "Webhook URL",
    Placeholder = "https://discord.com/api/webhooks/...",
    Default = Config.WebhookURL,
    Callback = function(v)
        Config.WebhookURL = v
        saveConfig()
    end
})

WebhookSec:Label({Name = "Select Rarities to Alert:"})

local RaritySec = WebhookTab:Section({Name = "🎨 Rarity Alerts", Side = "Right"})

for rarity, _ in pairs(RarityTiers) do
    RaritySec:Toggle({
        Name = rarity,
        Value = Config.WebhookRarities[rarity] or false,
        Callback = function(v)
            Config.WebhookRarities[rarity] = v
            saveConfig()
        end
    })
end

-- ====== MISC TAB ======
local MiscTab = Window:Tab({Name = "Misc", Icon = "rbxassetid://10734950309", Color = Color3.fromRGB(200,200,200)})

local PerfSec = MiscTab:Section({Name = "⚡ Performance", Side = "Left"})

PerfSec:Slider({
    Name = "Boost FPS Cap",
    Min = 30,
    Max = 240,
    Default = Config.BoostFPS,
    Callback = function(v)
        Config.BoostFPS = v
        setFPSCap(v)
        saveConfig()
    end
})

PerfSec:Toggle({
    Name = "🎬 No Fishing Animation",
    Value = Config.NoFishingAnimation,
    Callback = function(v)
        Config.NoFishingAnimation = v
        saveConfig()
    end
})

PerfSec:Toggle({
    Name = "🎥 Disable Cutscene",
    Value = Config.DisableCutscene,
    Callback = function(v)
        Config.DisableCutscene = v
        saveConfig()
    end
})

PerfSec:Toggle({
    Name = "🔕 Disable Fish Notif Icon",
    Value = Config.DisableFishNotifIcon,
    Callback = function(v)
        Config.DisableFishNotifIcon = v
        saveConfig()
    end
})

PerfSec:Toggle({
    Name = "✨ Disable Fishing Effects",
    Value = Config.DisableFishingEffects,
    Callback = function(v)
        Config.DisableFishingEffects = v
        saveConfig()
    end
})

PerfSec:Toggle({
    Name = "🌟 Disable VFX",
    Value = Config.DisableVFX,
    Callback = function(v)
        Config.DisableVFX = v
        saveConfig()
    end
})

local DisplaySec = MiscTab:Section({Name = "📊 Display", Side = "Right"})

DisplaySec:Toggle({
    Name = "📊 Show Ping & FPS",
    Value = Config.ShowPingFPS,
    Callback = function(v)
        Config.ShowPingFPS = v
        if v then
            createPingFPSDisplay()
        else
            if PingFPSGui then
                PingFPSGui:Destroy()
                PingFPSGui = nil
            end
        end
        saveConfig()
    end
})

DisplaySec:Button({
    Name = "💾 Save Config",
    Callback = function()
        saveConfig()
        print("[Config] ✅ Configuration saved!")
    end
})

DisplaySec:Button({
    Name = "🔄 Reset Config",
    Callback = function()
        for k, v in pairs(DefaultConfig) do
            if type(v) == "table" then
                Config[k] = {}
                for k2, v2 in pairs(v) do Config[k][k2] = v2 end
            else
                Config[k] = v
            end
        end
        saveConfig()
        print("[Config] 🔄 Reset to default!")
    end
})

-- ====== TELEPORT TAB ======
local TeleportTab = Window:Tab({Name = "Teleport", Icon = "rbxassetid://10734950309", Color = Color3.fromRGB(0,150,255)})

local TpSec = TeleportTab:Section({Name = "🌍 Locations", Side = "Left"})

local locationNames = {}
for name, _ in pairs(LOCATIONS) do
    table.insert(locationNames, name)
end
table.sort(locationNames)

TpSec:Dropdown({
    Name = "Select Location",
    Options = locationNames,
    Default = Config.TeleportLocation,
    Callback = function(v)
        Config.TeleportLocation = v
        saveConfig()
    end
})

TpSec:Button({
    Name = "📍 Teleport",
    Callback = function()
        teleportTo(Config.TeleportLocation)
    end
})

TpSec:Label({Name = "Quick Teleports:"})

-- Create buttons for popular locations
local popularLocations = {"Sisyphus Statue", "Coral Reefs", "Esoteric Depths", "Crater Island"}

for _, location in ipairs(popularLocations) do
    TpSec:Button({
        Name = location,
        Callback = function()
            teleportTo(location)
        end
    })
end

-- ====== EVENT TAB ======
local EventTab = Window:Tab({Name = "Events", Icon = "rbxassetid://10734950309", Color = Color3.fromRGB(255,100,0)})

local EventSec = EventTab:Section({Name = "🎯 Auto Events", Side = "Left"})

EventSec:Toggle({
    Name = "🦈 Auto Megalodon Hunt",
    Value = Config.AutoMegalodon,
    Callback = function(v)
        Config.AutoMegalodon = v
        saveConfig()
    end
})

EventSec:Toggle({
    Name = "👻 Auto Ghost Shark Hunt",
    Value = Config.AutoGhostShark,
    Callback = function(v)
        Config.AutoGhostShark = v
        saveConfig()
    end
})

EventSec:Toggle({
    Name = "🛒 Auto Merchant Scan",
    Value = Config.AutoMerchant,
    Callback = function(v)
        Config.AutoMerchant = v
        saveConfig()
    end
})

EventSec:Label({Name = "💡 Auto detects events"})
EventSec:Label({Name = "Teleports to event location"})

local MerchantSec = EventTab:Section({Name = "🛒 Merchant Info", Side = "Right"})

MerchantSec:Button({
    Name = "🔍 Scan Merchants Now",
    Callback = function()
        local merchants = scanMerchant()
        print("[Merchant] Found " .. #merchants .. " merchants")
        
        for i, merchant in ipairs(merchants) do
            print(string.format("[Merchant %d] %s at %s", i, merchant.Name, tostring(merchant.Position)))
        end
    end
})

MerchantSec:Label({Name = "Merchant stock will appear here"})

-- ====== INFO TAB ======
local InfoTab = Window:Tab({Name = "Info", Icon = "rbxassetid://10734950309", Color = Color3.fromRGB(100,100,100)})

local InfoSec = InfoTab:Section({Name = "ℹ️ Information", Side = "Left"})

InfoSec:Label({Name = "🎣 Auto Fish V7.0"})
InfoSec:Label({Name = "Optimized & Stable Edition"})
InfoSec:Label({Name = ""})
InfoSec:Label({Name = "📝 Features:"})
InfoSec:Label({Name = "• 3 Fishing Modes (Separate)"})
InfoSec:Label({Name = "• Auto Sell by Threshold"})
InfoSec:Label({Name = "• Auto Weather (Loop 3)"})
InfoSec:Label({Name = "• Discord Webhook Alerts"})
InfoSec:Label({Name = "• Performance Optimizations"})
InfoSec:Label({Name = "• Auto Event Detection"})
InfoSec:Label({Name = "• Merchant Scanner"})
InfoSec:Label({Name = "• Real-time Ping & FPS"})

local GuideSec = InfoTab:Section({Name = "📖 Quick Guide", Side = "Right"})

GuideSec:Label({Name = "⚡ Blatant Mode:"})
GuideSec:Label({Name = "FASTEST - Triple cast system"})
GuideSec:Label({Name = "6x spam reel (aggressive)"})
GuideSec:Label({Name = "Like other premium hubs"})
GuideSec:Label({Name = "Best for speed farming"})
GuideSec:Label({Name = ""})
GuideSec:Label({Name = "🎮 Legit Mode:"})
GuideSec:Label({Name = "SAFEST - Uses game system"})
GuideSec:Label({Name = "Auto shake & reel included"})
GuideSec:Label({Name = "Most safe option"})
GuideSec:Label({Name = "Slider controls speed"})
GuideSec:Label({Name = ""})
GuideSec:Label({Name = "⚡ Instant Mode:"})
GuideSec:Label({Name = "MEDIUM - Quick completion"})
GuideSec:Label({Name = "5x spam reel"})
GuideSec:Label({Name = "Faster than Legit"})
GuideSec:Label({Name = "Slower than Blatant"})

-- ====== STARTUP MESSAGE ======
print("╔════════════════════════════════════════════════╗")
print("║                                                ║")
print("║  ✅ AUTO FISH V7.0 LOADED SUCCESSFULLY!       ║")
print("║                                                ║")
print("║  🎣 3 Fishing Modes Ready                     ║")
print("║  ⚡ Optimized & Stable                        ║")
print("║  🚀 All Features Active                       ║")
print("║                                                ║")
print("╚════════════════════════════════════════════════╝")

game.StarterGui:SetCore("SendNotification", {
    Title = "✅ Auto Fish V7.0",
    Text = "Loaded! Choose your fishing mode.",
    Duration = 5
})
