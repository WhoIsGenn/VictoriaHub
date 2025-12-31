-- ====================================================================
--                 AUTO FISH V6.0 - PREMIUM EDITION
--     Complete Features: Priority + Instant Reel + Auto Shake
-- ====================================================================

-- ====== SERVICES ======
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- ====== CONFIG ======
local CONFIG_FOLDER = "AutoFish_V6"
local CONFIG_FILE = CONFIG_FOLDER .. "/config_" .. LocalPlayer.UserId .. ".json"

local DefaultConfig = {
    -- Core Fishing
    AutoFish = false,
    BlatantMode = false,
    InstantReel = false,
    AutoShake = false,
    PerfectCast = false,
    
    -- Auto Systems
    AutoEquipBestRod = false,
    AutoUseBait = false,
    AutoSell = false,
    AutoCatch = false,
    
    -- Sell Settings
    SellByRarity = false,
    SellRarities = {Common = true, Uncommon = true, Rare = true, Epic = false, Legendary = false, Mythic = false, Secret = false},
    SellThreshold = 50,
    
    -- Safety
    HumanizeMode = false,
    SafeMode = false,
    AutoRejoin = true,
    ServerHop = false,
    
    -- Notifications
    RareFishAlert = true,
    WebhookURL = "",
    SoundAlerts = true,
    
    -- Performance
    NoAnimation = false,
    BoostFPS = false,
    GPUSaver = false,
    DeleteCutscene = true,
    DisableEffects = false,
    HideFishIcon = false,
    
    -- Delays
    FishDelay = 0.9,
    CatchDelay = 0.2,
    CastDelay = 0.15,
    ReelDelay = 0.08,
    SellDelay = 30,
    ShakeDelay = 0.05,
    
    -- Misc
    AutoFavorite = true,
    FavoriteRarity = "Mythic",
    AutoBuyWeather = false,
    WeatherType = "Wind",
    TeleportLocation = "Sisyphus Statue"
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

-- ====== STATS TRACKING ======
local Stats = {
    FishCaught = 0,
    MoneyEarned = 0,
    RareFishCaught = {Mythic = 0, Secret = 0, Legendary = 0},
    StartTime = tick(),
    SessionTime = 0,
    LastCatch = "None"
}

-- ====== LOCATIONS ======
local LOCATIONS = {
    ["Spawn"] = CFrame.new(45.28, 252.56, 2987.11),
    ["Sisyphus Statue"] = CFrame.new(-3728.22, -135.07, -1012.13),
    ["Coral Reefs"] = CFrame.new(-3114.78, 1.32, 2237.52),
    ["Esoteric Depths"] = CFrame.new(3248.37, -1301.53, 1403.83),
    ["Crater Island"] = CFrame.new(1016.49, 20.09, 5069.27),
    ["Lost Isle"] = CFrame.new(-3618.16, 240.84, -1317.46),
    ["Weather Machine"] = CFrame.new(-1488.51, 83.17, 1876.30),
    ["Tropical Grove"] = CFrame.new(-2095.34, 197.20, 3718.08),
    ["Mount Hallow"] = CFrame.new(2136.62, 78.92, 3272.50),
    ["Treasure Room"] = CFrame.new(-3606.35, -266.57, -1580.97),
    ["Kohana"] = CFrame.new(-663.90, 3.05, 718.80),
    ["Underground Cellar"] = CFrame.new(2109.52, -94.19, -708.61),
    ["Ancient Jungle"] = CFrame.new(1831.71, 6.62, -299.28),
    ["Sacred Temple"] = CFrame.new(1466.92, -21.88, -622.84)
}

-- ====== CONFIG FUNCTIONS ======
local function ensureFolder()
    if not isfolder or not makefolder then return false end
    if not isfolder(CONFIG_FOLDER) then
        pcall(makefolder, CONFIG_FOLDER)
    end
    return isfolder(CONFIG_FOLDER)
end

local function saveConfig()
    if not writefile or not ensureFolder() then return end
    pcall(function()
        writefile(CONFIG_FILE, HttpService:JSONEncode(Config))
    end)
end

local function loadConfig()
    if not readfile or not isfile or not isfile(CONFIG_FILE) then return end
    pcall(function()
        local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
        for k, v in pairs(data) do
            if DefaultConfig[k] ~= nil then 
                if type(v) == "table" and type(Config[k]) == "table" then
                    for k2, v2 in pairs(v) do Config[k][k2] = v2 end
                else
                    Config[k] = v 
                end
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
        shake = net:WaitForChild("RE/FishingShake"),
        bait = net:WaitForChild("RE/UseBait")
    }
end

local Events = getEvents()

-- ====== MODULES ======
local ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
local Replion = require(ReplicatedStorage.Packages.Replion)
local PlayerData = Replion.Client:WaitReplion("Data")

-- ====== RARITY SYSTEM ======
local RarityTiers = {
    Common = 1, Uncommon = 2, Rare = 3, Epic = 4,
    Legendary = 5, Mythic = 6, Secret = 7
}

local function getRarityValue(rarity)
    return RarityTiers[rarity] or 0
end

local function getFishRarity(itemData)
    if not itemData or not itemData.Data then return "Common" end
    return itemData.Data.Rarity or "Common"
end

-- ====== NOTIFICATION SYSTEM ======
local function notify(title, text, duration)
    pcall(function()
        game.StarterGui:SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = duration or 5
        })
    end)
end

local function playSound(soundId)
    if not Config.SoundAlerts then return end
    pcall(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://" .. soundId
        sound.Volume = 0.5
        sound.Parent = game.Workspace
        sound:Play()
        game:GetService("Debris"):AddItem(sound, 3)
    end)
end

local function rareFishAlert(fishName, rarity)
    if not Config.RareFishAlert then return end
    
    notify("🎣 RARE FISH!", fishName .. " (" .. rarity .. ")", 8)
    playSound("6647898081") -- Success sound
    
    -- Webhook notification
    if Config.WebhookURL ~= "" then
        pcall(function()
            local data = {
                content = "🎣 **RARE FISH CAUGHT!**\n" ..
                         "Fish: **" .. fishName .. "**\n" ..
                         "Rarity: **" .. rarity .. "**\n" ..
                         "Player: " .. LocalPlayer.Name
            }
            request({
                Url = Config.WebhookURL,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(data)
            })
        end)
    end
end

-- ====== AUTO EQUIP BEST ROD ======
local function getBestRod()
    local bestRod = nil
    local bestValue = 0
    
    pcall(function()
        local hotbar = PlayerData:GetExpect("Hotbar")
        if not hotbar then return end
        
        for slot, itemId in pairs(hotbar) do
            if itemId then
                local itemData = ItemUtility:GetItemData(itemId)
                if itemData and itemData.Data then
                    local name = itemData.Data.Name or ""
                    if string.find(string.lower(name), "rod") then
                        local value = getRarityValue(itemData.Data.Rarity or "Common")
                        if value > bestValue then
                            bestValue = value
                            bestRod = slot
                        end
                    end
                end
            end
        end
    end)
    
    return bestRod or 1
end

local currentRodSlot = 1

local function autoEquipBestRod()
    if not Config.AutoEquipBestRod then 
        currentRodSlot = 1
        return 
    end
    currentRodSlot = getBestRod()
    print("[Auto Equip] 🎣 Using slot " .. currentRodSlot)
end

-- ====== AUTO USE BAIT ======
local function getBestBait()
    local bestBait = nil
    
    pcall(function()
        local items = PlayerData:GetExpect("Inventory").Items
        if not items then return end
        
        for _, item in ipairs(items) do
            local data = ItemUtility:GetItemData(item.Id)
            if data and data.Data then
                local name = data.Data.Name or ""
                if string.find(string.lower(name), "bait") then
                    bestBait = item.UUID
                    break
                end
            end
        end
    end)
    
    return bestBait
end

local function autoUseBait()
    if not Config.AutoUseBait then return end
    
    local bait = getBestBait()
    if bait then
        pcall(function()
            Events.bait:FireServer(bait)
            print("[Auto Bait] 🪱 Used bait")
        end)
    end
end

-- ====== INSTANT REEL SYSTEM ======
local function instantReel()
    if not Config.InstantReel then
        -- Normal reel
        pcall(function()
            Events.fishing:FireServer()
        end)
        return
    end
    
    -- Instant reel: spam 10x super fast
    for i = 1, 10 do
        pcall(function()
            Events.fishing:FireServer()
        end)
        task.wait(0.001) -- Ultra fast
    end
    print("[Instant Reel] ⚡ INSTANT!")
end

-- ====== AUTO SHAKE SYSTEM ======
local shakeConnection = nil
local isShaking = false

local function setupAutoShake()
    if shakeConnection then
        shakeConnection:Disconnect()
        shakeConnection = nil
    end
    
    if not Config.AutoShake then return end
    
    -- Monitor for shake events
    shakeConnection = RunService.Heartbeat:Connect(function()
        if not Config.AutoShake or isShaking then return end
        
        pcall(function()
            local playerGui = LocalPlayer:WaitForChild("PlayerGui")
            local fishingGui = playerGui:FindFirstChild("FishingGui")
            
            if fishingGui then
                local shakeFrame = fishingGui:FindFirstChild("Shake", true)
                if shakeFrame and shakeFrame.Visible then
                    isShaking = true
                    
                    -- Spam shake event
                    for i = 1, 5 do
                        Events.shake:FireServer()
                        task.wait(Config.ShakeDelay)
                    end
                    
                    task.wait(0.2)
                    isShaking = false
                    print("[Auto Shake] 🎯 Completed!")
                end
            end
        end)
    end)
end

-- ====== PERFECT CAST SYSTEM ======
local function perfectCast()
    if not Config.PerfectCast then
        -- Normal cast
        return 1755848498.4834
    end
    
    -- Perfect cast: maximum power
    return 9999999999.9999 -- Max value untuk perfect cast
end

-- ====== HUMANIZE MODE ======
local function getRandomDelay(base)
    if not Config.HumanizeMode then return base end
    
    local variance = base * 0.3 -- ±30% variance
    return base + (math.random() - 0.5) * 2 * variance
end

-- ====== FISHING LOGIC ======
local isFishing = false
local fishingActive = false

local function castRod()
    pcall(function()
        autoEquipBestRod()
        autoUseBait()
        
        Events.equip:FireServer(currentRodSlot)
        task.wait(getRandomDelay(Config.CastDelay))
        Events.charge:InvokeServer(perfectCast())
        task.wait(0.02)
        Events.minigame:InvokeServer(1.2854545116425, currentRodSlot)
        print("[Fishing] 🎣 Cast (Slot " .. currentRodSlot .. ")")
    end)
end

local function blatantFishing()
    while fishingActive and Config.BlatantMode do
        if not isFishing then
            isFishing = true
            
            -- Triple cast
            pcall(function()
                autoEquipBestRod()
                autoUseBait()
                
                Events.equip:FireServer(currentRodSlot)
                task.wait(getRandomDelay(Config.CastDelay))
                
                for i = 1, 3 do
                    task.spawn(function()
                        Events.charge:InvokeServer(perfectCast())
                        task.wait(getRandomDelay(Config.CastDelay))
                        Events.minigame:InvokeServer(1.2854545116425, currentRodSlot)
                    end)
                    task.wait(getRandomDelay(Config.CastDelay))
                end
            end)
            
            task.wait(getRandomDelay(Config.FishDelay))
            
            -- Instant reel
            instantReel()
            
            task.wait(getRandomDelay(Config.CatchDelay * 0.4))
            
            Stats.FishCaught = Stats.FishCaught + 1
            isFishing = false
        else
            task.wait(0.01)
        end
    end
end

local function normalFishing()
    while fishingActive and not Config.BlatantMode do
        if not isFishing then
            isFishing = true
            
            castRod()
            task.wait(getRandomDelay(Config.FishDelay))
            instantReel()
            task.wait(getRandomDelay(Config.CatchDelay))
            
            Stats.FishCaught = Stats.FishCaught + 1
            isFishing = false
        else
            task.wait(0.1)
        end
    end
end

local function startFishing()
    fishingActive = true
    setupAutoShake()
    if Config.BlatantMode then
        task.spawn(blatantFishing)
    else
        task.spawn(normalFishing)
    end
end

local function stopFishing()
    fishingActive = false
    isFishing = false
    if shakeConnection then
        shakeConnection:Disconnect()
        shakeConnection = nil
    end
    pcall(function() Events.unequip:FireServer() end)
end

-- ====== SMART SELL SYSTEM ======
local function shouldSellFish(itemData)
    if not itemData or not itemData.Data then return true end
    
    local rarity = itemData.Data.Rarity or "Common"
    
    -- Check if favorited
    if itemData.Favorited then return false end
    
    -- Sell by rarity
    if Config.SellByRarity then
        return Config.SellRarities[rarity] == true
    end
    
    return true
end

local function smartSell()
    print("╔═══════════════════════════════╗")
    print("[Smart Sell] 💰 Processing...")
    
    local sold = 0
    local kept = 0
    
    pcall(function()
        -- Get inventory count
        local items = PlayerData:GetExpect("Inventory").Items
        local itemCount = #items
        
        -- Check threshold
        if Config.SellThreshold > 0 and itemCount < Config.SellThreshold then
            print("[Smart Sell] ⏸️ Below threshold (" .. itemCount .. "/" .. Config.SellThreshold .. ")")
            return
        end
        
        -- Sell all non-favorited items
        local result = Events.sell:InvokeServer()
        if result then
            sold = itemCount
            print("[Smart Sell] ✅ Sold: " .. sold .. " items")
            Stats.MoneyEarned = Stats.MoneyEarned + (sold * 10) -- Estimate
        end
    end)
    
    print("╚═══════════════════════════════╝")
end

-- Auto sell loop
task.spawn(function()
    while true do
        task.wait(Config.SellDelay)
        if Config.AutoSell then
            smartSell()
        end
    end
end)

-- ====== AUTO CATCH ======
task.spawn(function()
    while true do
        if Config.AutoCatch and not isFishing then
            instantReel()
        end
        task.wait(Config.CatchDelay)
    end
end)

-- ====== AUTO FAVORITE ======
local favoritedItems = {}

local function autoFavorite()
    if not Config.AutoFavorite then return end
    
    local targetValue = getRarityValue(Config.FavoriteRarity)
    if targetValue < 6 then targetValue = 6 end
    
    local favorited = 0
    
    pcall(function()
        local items = PlayerData:GetExpect("Inventory").Items
        if not items then return end
        
        for _, item in ipairs(items) do
            local data = ItemUtility:GetItemData(item.Id)
            if data and data.Data then
                local rarity = getFishRarity(data)
                local rarityValue = getRarityValue(rarity)
                
                if rarityValue >= targetValue and not favoritedItems[item.UUID] then
                    Events.favorite:FireServer(item.UUID)
                    favoritedItems[item.UUID] = true
                    favorited = favorited + 1
                    
                    -- Rare fish alert
                    if rarityValue >= 6 then
                        Stats.RareFishCaught[rarity] = (Stats.RareFishCaught[rarity] or 0) + 1
                        rareFishAlert(data.Data.Name or "Unknown", rarity)
                    end
                    
                    task.wait(0.3)
                end
            end
        end
    end)
end

task.spawn(function()
    while true do
        task.wait(10)
        autoFavorite()
    end
end)

-- ====== PERFORMANCE ======
local function boostFPS()
    if not Config.BoostFPS then return end
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 1
    if setfpscap then setfpscap(240) end
end

local function disableAnimations()
    if not Config.NoAnimation then return end
    pcall(function()
        local humanoid = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        for _, track in pairs(humanoid:GetPlayingAnimationTracks()) do
            if string.find(string.lower(track.Animation.Name), "fish") then
                track:Stop()
            end
        end
    end)
end

-- Monitor performance
task.spawn(function()
    while true do
        task.wait(0.5)
        boostFPS()
        disableAnimations()
    end
end)

-- ====== AUTO REJOIN ======
game:GetService("CoreGui").ChildRemoved:Connect(function()
    if Config.AutoRejoin then
        task.wait(1)
        game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
    end
end)

-- ====== ANTI-AFK ======
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- ====== STATS UPDATE ======
task.spawn(function()
    while true do
        task.wait(1)
        Stats.SessionTime = tick() - Stats.StartTime
    end
end)

-- ====== WINDUI ======
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/sius-x/Wind-UI/main/source.lua"))()

local Window = WindUI:CreateWindow({
    Title = "🎣 Auto Fish V6.0 - Premium",
    Icon = "rbxassetid://4483362458",
    Author = "VictoriaHub",
    Folder = "VH_AutoFish_V6",
    Size = UDim2.fromOffset(600, 500),
    KeySystem = {
        Key = "FreeForAll",
        Note = "No Key Required",
        SaveKey = false,
        CheckKey = function(k) return k == "FreeForAll" end
    },
    Transparent = true,
    Theme = "Dark"
})

-- ====== MAIN TAB ======
local Main = Window:Tab({
    Name = "Main",
    Icon = "rbxassetid://10734950309",
    Color = Color3.fromRGB(255, 0, 0)
})

local Fish = Main:Section({Name = "🎣 Core Fishing", Side = "Left"})

Fish:Toggle({Name = "🤖 Auto Fish", Value = Config.AutoFish, Callback = function(v)
    Config.AutoFish = v
    if v then startFishing() else stopFishing() end
    saveConfig()
end})

Fish:Toggle({Name = "⚡ Blatant Mode", Value = Config.BlatantMode, Callback = function(v)
    Config.BlatantMode = v
    saveConfig()
end})

Fish:Toggle({Name = "⚡ Instant Reel", Value = Config.InstantReel, Callback = function(v)
    Config.InstantReel = v
    saveConfig()
end})

Fish:Toggle({Name = "🎯 Auto Shake", Value = Config.AutoShake, Callback = function(v)
    Config.AutoShake = v
    setupAutoShake()
    saveConfig()
end})

Fish:Toggle({Name = "🎯 Perfect Cast", Value = Config.PerfectCast, Callback = function(v)
    Config.PerfectCast = v
    saveConfig()
end})

Fish:Toggle({Name = "🎣 Auto Equip Best Rod", Value = Config.AutoEquipBestRod, Callback = function(v)
    Config.AutoEquipBestRod = v
    saveConfig()
end})

Fish:Toggle({Name = "🪱 Auto Use Bait", Value = Config.AutoUseBait, Callback = function(v)
    Config.AutoUseBait = v
    saveConfig()
end})

local Delays = Main:Section({Name = "⏱️ Delays", Side = "Right"})

Delays:Slider({Name = "Cast Delay", Min = 0.05, Max = 1, Default = Config.CastDelay, Callback = function(v)
    Config.CastDelay = v
    saveConfig()
end})

Delays:Slider({Name = "Reel Delay", Min = 0.01, Max = 0.5, Default = Config.ReelDelay, Callback = function(v)
    Config.ReelDelay = v
    saveConfig()
end})

Delays:Slider({Name = "Shake Delay", Min = 0.01, Max = 0.2, Default = Config.ShakeDelay, Callback = function(v)
    Config.ShakeDelay = v
    saveConfig()
end})

-- ====== SELL TAB ======
local Sell = Window:Tab({Name = "Sell", Icon = "rbxassetid://10734950309", Color = Color3.fromRGB(0, 255, 0)})

local SellSec = Sell:Section({Name = "💰 Smart Sell", Side = "Left"})

SellSec:Toggle({Name = "💰 Auto Sell", Value = Config.AutoSell, Callback = function(v)
    Config.AutoSell = v
    saveConfig()
end})

SellSec:Toggle({Name = "📊 Sell By Rarity", Value = Config.SellByRarity, Callback = function(v)
    Config.SellByRarity = v
    saveConfig()
end})

SellSec:Slider({Name = "Sell Threshold", Min = 0, Max = 100, Default = Config.SellThreshold, Callback = function(v)
    Config.SellThreshold = v
    saveConfig()
end})

SellSec:Button({Name = "💰 Sell Now", Callback = smartSell})

local Rarities = Sell:Section({Name = "🎨 Sell Rarities", Side = "Right"})

for rarity, _ in pairs(RarityTiers) do
    Rarities:Toggle({Name = rarity, Value = Config.SellRarities[rarity] or false, Callback = function(v)
        Config.SellRarities[rarity] = v
        saveConfig()
    end})
end

-- ====== STATS TAB ======
local Stats = Window:Tab({Name = "Stats", Icon = "rbxassetid://10734950309", Color = Color3.fromRGB(0, 150, 255)})

local function formatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local mins = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    return string.format("%02d:%02d:%02d", hours, mins, secs)
end

Stats:Section({Name = "📊 Session Stats", Side = "Left"}):Label({
    Name = "Loading stats...",
    Flag = "StatsLabel"
})

task.spawn(function()
    while true do
        task.wait(1)
        local statsText = string.format(
            "🎣 Fish Caught: %d\n" ..
            "💰 Money Earned: ~$%d\n" ..
            "⏱️ Session Time: %s\n" ..
            "⭐ Mythic: %d | Secret: %d\n" ..
            "🔥 Legendary: %d",
            Stats.FishCaught,
            Stats.MoneyEarned,
            formatTime(Stats.SessionTime),
            Stats.RareFishCaught.Mythic or 0,
            Stats.RareFishCaught.Secret or 0,
            Stats.RareFishCaught.Legendary or 0
        )
        
        -- Update label
        pcall(function()
            Window.Flags.StatsLabel:Set(statsText)
        end)
    end
end)

-- ====== SAFETY TAB ======
local Safety = Window:Tab({Name = "Safety", Icon = "rbxassetid://10734950309", Color = Color3.fromRGB(255, 200, 0)})

local Safe = Safety:Section({Name = "🛡️ Anti-Detection", Side = "Left"})

Safe:Toggle({Name = "🎭 Humanize Mode", Value = Config.HumanizeMode, Callback = function(v)
    Config.HumanizeMode = v
    saveConfig()
end})

Safe:Toggle({Name = "🐢 Safe Mode", Value = Config.SafeMode, Callback = function(v)
    Config.SafeMode = v
    if v then
        Config.BlatantMode = false
        Config.InstantReel = false
    end
    saveConfig()
end})

Safe:Toggle({Name = "🔄 Auto Rejoin", Value = Config.AutoRejoin, Callback = function(v)
    Config.AutoRejoin = v
    saveConfig()
end})

-- ====== NOTIFICATION TAB ======
local Notif = Window:Tab({Name = "Alerts", Icon = "rbxassetid://10734950309", Color = Color3.fromRGB(255, 100, 200)})

local Alerts = Notif:Section({Name = "🔔 Notifications", Side = "Left"})

Alerts:Toggle({Name = "🎣 Rare Fish Alert", Value = Config.RareFishAlert, Callback = function(v)
    Config.RareFishAlert = v
    saveConfig()
end})

Alerts:Toggle({Name = "🔊 Sound Alerts", Value = Config.SoundAlerts, Callback = function(v)
    Config.SoundAlerts = v
    saveConfig()
end})

Alerts:Input({Name = "Discord Webhook URL", Placeholder = "https://discord.com/api/webhooks/...", Callback = function(v)
    Config.WebhookURL = v
    saveConfig()
end})

print("✅ Auto Fish V6.0 Premium Loaded!")
print("⚡ All Priority Features Active")
print("🚀 Instant Reel + Auto Shake Ready!")