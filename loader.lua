-- ====================================================================
--                 AUTO FISH V5.0 - WINDUI EDITION
--          Enhanced Stability with WindUI & Better Blatant Mode
-- ====================================================================

-- ====== ENHANCED DEPENDENCY VALIDATION ======
local function validateDependencies()
    local success, errorMsg = pcall(function()
        -- Check essential services
        local services = {
            Players = game:GetService("Players"),
            RunService = game:GetService("RunService"),
            ReplicatedStorage = game:GetService("ReplicatedStorage"),
            HttpService = game:GetService("HttpService"),
            VirtualUser = game:GetService("VirtualUser")
        }
        
        for serviceName, service in pairs(services) do
            if not service then
                error("Missing service: " .. serviceName)
            end
        end
        
        -- Check LocalPlayer
        local LocalPlayer = services.Players.LocalPlayer
        if not LocalPlayer then
            error("LocalPlayer not available")
        end
        
        return true
    end)
    
    if not success then
        warn("❌ [Auto Fish] Dependency check failed: " .. tostring(errorMsg))
        return false
    end
    
    return true
end

if not validateDependencies() then
    return
end

print("✅ [Auto Fish] Dependencies validated")

-- ====================================================================
--                        CORE SERVICES
-- ====================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- ====================================================================
--                    ENHANCED CONFIGURATION
-- ====================================================================
local CONFIG_FOLDER = "AutoFishV5"
local CONFIG_FILE = CONFIG_FOLDER .. "/config_" .. LocalPlayer.UserId .. ".json"

local DefaultConfig = {
    -- Fishing Settings
    AutoFish = false,
    AutoSell = false,
    AutoCatch = false,
    BlatantMode = false,
    
    -- Delay Settings
    FishDelay = 0.9,
    CatchDelay = 0.2,
    ReelDelay = 0.05,       -- NEW: Delay between reel spams
    BaitDelay = 0.1,        -- NEW: Delay between bait casts
    SellDelay = 30,
    
    -- Performance
    GPUSaver = false,
    PerformanceMode = false,
    AntiAFK = true,
    
    -- Teleport
    TeleportLocation = "Sisyphus Statue",
    
    -- Auto Favorite
    AutoFavorite = true,
    FavoriteRarity = "Mythic",
    
    -- Blatant Mode Settings
    BlatantCasts = 2,       -- Number of parallel casts
    BlatantReels = 5,       -- Number of reel spams
    BlatantMultiplier = 0.5 -- Speed multiplier
}

local Config = {}
for k, v in pairs(DefaultConfig) do Config[k] = v end

-- Teleport Locations
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

-- ====================================================================
--                     ENHANCED CONFIG FUNCTIONS
-- ====================================================================
local function ensureFolder()
    if not isfolder or not makefolder then return false end
    
    local success, result = pcall(function()
        if not isfolder(CONFIG_FOLDER) then
            makefolder(CONFIG_FOLDER)
        end
        return isfolder(CONFIG_FOLDER)
    end)
    
    return success and result
end

local function saveConfig()
    if not writefile then return false end
    
    local success, errorMsg = pcall(function()
        if not ensureFolder() then return false end
        writefile(CONFIG_FILE, HttpService:JSONEncode(Config))
        return true
    end)
    
    return success
end

local function loadConfig()
    if not readfile or not isfile or not isfile(CONFIG_FILE) then return false end
    
    local success, errorMsg = pcall(function()
        local data = HttpService:JSONDecode(readfile(CONFIG_FILE))
        for k, v in pairs(data) do
            if DefaultConfig[k] ~= nil then Config[k] = v end
        end
        return true
    end)
    
    return success
end

loadConfig()

-- ====================================================================
--                     NETWORK EVENTS
-- ====================================================================
local Events = {}

local function initializeEvents()
    local success, errorMsg = pcall(function()
        local net = ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
        
        Events = {
            fishing = net:WaitForChild("RE/FishingCompleted"),
            sell = net:WaitForChild("RF/SellAllItems"),
            charge = net:WaitForChild("RF/ChargeFishingRod"),
            minigame = net:WaitForChild("RF/RequestFishingMinigameStarted"),
            cancel = net:WaitForChild("RF/CancelFishingInputs"),
            equip = net:WaitForChild("RE/EquipToolFromHotbar"),
            unequip = net:WaitForChild("RE/UnequipToolFromHotbar"),
            favorite = net:WaitForChild("RE/FavoriteItem")
        }
        
        return true
    end)
    
    if not success then
        warn("❌ [Events] Failed to initialize: " .. tostring(errorMsg))
        return false
    end
    
    return true
end

if not initializeEvents() then
    warn("⚠️ [Events] Retrying initialization...")
    task.wait(2)
    if not initializeEvents() then
        error("❌ [Events] Critical: Failed to initialize")
    end
end

-- ====================================================================
--                     MODULES
-- ====================================================================
local ItemUtility, Replion, PlayerData

local function loadModules()
    local success, errorMsg = pcall(function()
        ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
        Replion = require(ReplicatedStorage.Packages.Replion)
        PlayerData = Replion.Client:WaitReplion("Data")
        return true
    end)
    
    return success
end

loadModules()

-- ====================================================================
--                     RARITY SYSTEM
-- ====================================================================
local RarityTiers = {
    Common = 1,
    Uncommon = 2,
    Rare = 3,
    Epic = 4,
    Legendary = 5,
    Mythic = 6,
    Secret = 7
}

local function getRarityValue(rarity)
    return RarityTiers[rarity] or 0
end

-- ====================================================================
--                     ENHANCED TELEPORT SYSTEM
-- ====================================================================
local Teleport = {}

function Teleport.to(locationName)
    local cframe = LOCATIONS[locationName]
    if not cframe then
        warn("❌ [Teleport] Location not found: " .. tostring(locationName))
        return false
    end
    
    local success = pcall(function()
        local character = LocalPlayer.Character
        if not character then return false end
        
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then return false end
        
        rootPart.CFrame = cframe
        return true
    end)
    
    return success
end

-- ====================================================================
--                     ENHANCED GPU SAVER
-- ====================================================================
local gpuActive = false
local whiteScreen = nil

local function enableGPU()
    if gpuActive then return end
    
    pcall(function()
        settings().Rendering.QualityLevel = 1
        game.Lighting.GlobalShadows = false
        game.Lighting.FogEnd = 1
        if setfpscap then setfpscap(15) end
    end)
    
    whiteScreen = Instance.new("ScreenGui")
    whiteScreen.Name = "GPUSaverUI"
    whiteScreen.ResetOnSpawn = false
    whiteScreen.DisplayOrder = 999999
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.Parent = whiteScreen
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0, 300, 0, 80)
    label.Position = UDim2.new(0.5, -150, 0.5, -40)
    label.BackgroundTransparency = 1
    label.Text = "🟢 GPU SAVER ACTIVE\nAuto Fish Running..."
    label.TextColor3 = Color3.fromRGB(0, 255, 0)
    label.TextSize = 22
    label.Font = Enum.Font.GothamBold
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Parent = frame
    
    whiteScreen.Parent = game.CoreGui
    gpuActive = true
end

local function disableGPU()
    if not gpuActive then return end
    
    pcall(function()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
        game.Lighting.GlobalShadows = true
        game.Lighting.FogEnd = 100000
        if setfpscap then setfpscap(0) end
    end)
    
    if whiteScreen then
        whiteScreen:Destroy()
        whiteScreen = nil
    end
    
    gpuActive = false
end

-- ====================================================================
--                     ANTI-AFK
-- ====================================================================
local function setupAntiAFK()
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

setupAntiAFK()

-- ====================================================================
--                     ENHANCED AUTO FAVORITE
-- ====================================================================
local favoritedItems = {}

local function autoFavoriteByRarity()
    if not Config.AutoFavorite or not ItemUtility or not PlayerData then return end
    
    local targetValue = getRarityValue(Config.FavoriteRarity)
    if targetValue < 6 then targetValue = 6 end
    
    local favorited = 0
    
    pcall(function()
        local items = PlayerData:GetExpect("Inventory").Items
        if not items then return end
        
        for _, item in ipairs(items) do
            local itemData = ItemUtility:GetItemData(item.Id)
            if itemData and itemData.Data then
                local rarity = itemData.Data.Rarity or "Common"
                local rarityValue = getRarityValue(rarity)
                
                if rarityValue >= targetValue then
                    if not favoritedItems[item.UUID] then
                        Events.favorite:FireServer(item.UUID)
                        favoritedItems[item.UUID] = true
                        favorited = favorited + 1
                        task.wait(0.3)
                    end
                end
            end
        end
    end)
    
    return favorited
end

-- ====================================================================
--                     ENHANCED FISHING LOGIC
-- ====================================================================
local isFishing = false
local fishingActive = false
local fishingTask = nil

-- NEW: Safety cooldown system
local lastActionTime = 0
local ACTION_COOLDOWN = 0.05

local function safeAction()
    local currentTime = tick()
    if currentTime - lastActionTime < ACTION_COOLDOWN then
        task.wait(ACTION_COOLDOWN)
    end
    lastActionTime = tick()
end

-- NEW: Improved casting with delay
local function castRodWithDelay()
    safeAction()
    pcall(function()
        Events.equip:FireServer(1)
        task.wait(Config.BaitDelay) -- Use BaitDelay
        Events.charge:InvokeServer(1755848498.4834)
        task.wait(0.02)
        Events.minigame:InvokeServer(1.2854545116425, 1)
    end)
end

-- NEW: Improved reeling with delay
local function reelInWithDelay()
    for i = 1, (Config.BlatantMode and Config.BlatantReels or 1) do
        safeAction()
        pcall(function()
            Events.fishing:FireServer()
        end)
        task.wait(Config.ReelDelay) -- Use ReelDelay
    end
end

-- ENHANCED BLATANT MODE WITH STABILITY IMPROVEMENTS
local function enhancedBlatantFishingLoop()
    local cycleCount = 0
    local successCount = 0
    local failCount = 0
    
    while fishingActive and Config.BlatantMode do
        if not isFishing then
            isFishing = true
            cycleCount += 1
            
            -- Phase 1: Parallel Casting with improved stability
            local castPromises = {}
            for i = 1, math.min(Config.BlatantCasts, 3) do -- Max 3 casts for stability
                table.insert(castPromises, task.spawn(function()
                    local success = pcall(function()
                        castRodWithDelay()
                        return true
                    end)
                    return success
                end))
                
                -- Stagger casts slightly for stability
                if i < Config.BlatantCasts then
                    task.wait(Config.BaitDelay * 0.5)
                end
            end
            
            -- Wait for all casts to complete
            local castResults = {}
            for _, promise in ipairs(castPromises) do
                table.insert(castResults, promise:await())
            end
            
            -- Phase 2: Wait for fish bite with dynamic adjustment
            local actualFishDelay = Config.FishDelay
            if cycleCount > 10 and failCount < successCount then
                -- If stable, slightly reduce delay for speed
                actualFishDelay = math.max(0.7, Config.FishDelay * 0.9)
            end
            task.wait(actualFishDelay)
            
            -- Phase 3: Reeling with improved stability
            local reelSuccess = pcall(function()
                reelInWithDelay()
                return true
            end)
            
            -- Phase 4: Cooldown with stability adjustment
            local cooldownMultiplier = Config.BlatantMultiplier
            if not reelSuccess then
                failCount += 1
                -- Increase cooldown on failure
                cooldownMultiplier = math.min(1, cooldownMultiplier * 1.2)
            else
                successCount += 1
            end
            
            -- Reset counters periodically
            if cycleCount % 20 == 0 then
                successCount = math.floor(successCount * 0.7)
                failCount = math.floor(failCount * 0.7)
            end
            
            -- Stability check and notification
            if cycleCount % 5 == 0 then
                local stability = (successCount / (successCount + failCount + 0.001)) * 100
                
                -- 5/7 Notification System
                if stability >= 85 then
                    print("✅ [Blatant] Stability: EXCELLENT (" .. math.floor(stability) .. "%)")
                elseif stability >= 70 then
                    print("🟡 [Blatant] Stability: GOOD (" .. math.floor(stability) .. "%)")
                elseif stability >= 50 then
                    print("🟠 [Blatant] Stability: FAIR (" .. math.floor(stability) .. "%)")
                else
                    print("🔴 [Blatant] Stability: POOR (" .. math.floor(stability) .. "%)")
                    -- Auto-adjust on poor stability
                    Config.BlatantCasts = math.max(1, Config.BlatantCasts - 1)
                    Config.BlatantMultiplier = math.min(0.8, Config.BlatantMultiplier * 1.1)
                end
            end
            
            task.wait(Config.CatchDelay * cooldownMultiplier)
            isFishing = false
            
        else
            task.wait(0.01)
        end
    end
end

-- Normal Fishing Mode
local function normalFishingLoop()
    while fishingActive and not Config.BlatantMode do
        if not isFishing then
            isFishing = true
            
            pcall(function()
                castRodWithDelay()
                task.wait(Config.FishDelay)
                reelInWithDelay()
                task.wait(Config.CatchDelay)
            end)
            
            isFishing = false
        else
            task.wait(0.1)
        end
    end
end

-- Main fishing controller
local function startFishingLoop()
    if fishingTask then
        task.cancel(fishingTask)
    end
    
    fishingTask = task.spawn(function()
        while fishingActive do
            if Config.BlatantMode then
                enhancedBlatantFishingLoop()
            else
                normalFishingLoop()
            end
            task.wait(0.05)
        end
    end)
end

-- ====================================================================
--                     AUTO CATCH
-- ====================================================================
task.spawn(function()
    while true do
        if Config.AutoCatch and not isFishing then
            pcall(function()
                Events.fishing:FireServer()
            end)
        end
        task.wait(Config.CatchDelay)
    end
end)

-- ====================================================================
--                     AUTO SELL
-- ====================================================================
local function simpleSell()
    pcall(function()
        Events.sell:InvokeServer()
    end)
end

task.spawn(function()
    while true do
        task.wait(Config.SellDelay)
        if Config.AutoSell then
            simpleSell()
        end
    end
end)

-- ====================================================================
--                     WINDUI IMPLEMENTATION
-- ====================================================================
local WindUI = {}

function WindUI:CreateWindow(options)
    local window = {}
    
    -- Create main GUI
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AutoFishV5UI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    if gethui then
        ScreenGui.Parent = gethui()
    else
        ScreenGui.Parent = game.CoreGui
    end
    
    -- Main Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 400, 0, 450)
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -225)
    MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui
    
    -- Corner
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 8)
    Corner.Parent = MainFrame
    
    -- Shadow
    local Shadow = Instance.new("ImageLabel")
    Shadow.Name = "Shadow"
    Shadow.Size = UDim2.new(1, 10, 1, 10)
    Shadow.Position = UDim2.new(0, -5, 0, -5)
    Shadow.BackgroundTransparency = 1
    Shadow.Image = "rbxassetid://1316045217"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.5
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    Shadow.Parent = MainFrame
    
    -- Title Bar
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = options.Name or "Auto Fish V5.0"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 18
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TitleBar
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Size = UDim2.new(0, 30, 0, 30)
    CloseButton.Position = UDim2.new(1, -35, 0.5, -15)
    CloseButton.BackgroundColor3 = Color3.fromRGB(220, 60, 60)
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.TextSize = 16
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Parent = TitleBar
    
    local CloseCorner = Instance.new("UICorner")
    CloseCorner.CornerRadius = UDim.new(0, 4)
    CloseCorner.Parent = CloseButton
    
    CloseButton.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    -- Tab System
    local TabButtons = Instance.new("Frame")
    TabButtons.Name = "TabButtons"
    TabButtons.Size = UDim2.new(1, 0, 0, 40)
    TabButtons.Position = UDim2.new(0, 0, 0, 40)
    TabButtons.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    TabButtons.BorderSizePixel = 0
    TabButtons.Parent = MainFrame
    
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(1, -20, 1, -100)
    TabContainer.Position = UDim2.new(0, 10, 0, 90)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = MainFrame
    
    local tabs = {}
    local currentTab = nil
    
    function window:CreateTab(name, icon)
        local tab = {}
        local tabName = name
        
        -- Tab Button
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name .. "Tab"
        TabButton.Size = UDim2.new(0, 80, 1, 0)
        TabButton.Position = UDim2.new(0, (#tabs * 85), 0, 0)
        TabButton.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
        TabButton.Text = name
        TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabButton.TextSize = 14
        TabButton.Font = Enum.Font.Gotham
        TabButton.Parent = TabButtons
        
        local ButtonCorner = Instance.new("UICorner")
        ButtonCorner.CornerRadius = UDim.new(0, 4)
        ButtonCorner.Parent = TabButton
        
        -- Tab Content
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = name .. "Content"
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = Color3.fromRGB(60, 60, 65)
        TabContent.Visible = false
        TabContent.Parent = TabContainer
        
        local UIListLayout = Instance.new("UIListLayout")
        UIListLayout.Padding = UDim.new(0, 8)
        UIListLayout.Parent = TabContent
        
        -- Select first tab by default
        if #tabs == 0 then
            TabButton.BackgroundColor3 = Color3.fromRGB(65, 65, 70)
            TabContent.Visible = true
            currentTab = name
        end
        
        TabButton.MouseButton1Click:Connect(function()
            -- Hide all tabs
            for _, otherTab in pairs(tabs) do
                otherTab.button.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
                otherTab.content.Visible = false
            end
            
            -- Show selected tab
            TabButton.BackgroundColor3 = Color3.fromRGB(65, 65, 70)
            TabContent.Visible = true
            currentTab = name
        end)
        
        tabs[name] = {
            button = TabButton,
            content = TabContent,
            elements = {}
        }
        
        -- UI Element Functions
        function tab:CreateSection(title)
            local section = {}
            
            local SectionFrame = Instance.new("Frame")
            SectionFrame.Name = "Section"
            SectionFrame.Size = UDim2.new(1, 0, 0, 40)
            SectionFrame.BackgroundTransparency = 1
            SectionFrame.Parent = TabContent
            
            local TitleLabel = Instance.new("TextLabel")
            TitleLabel.Name = "Title"
            TitleLabel.Size = UDim2.new(1, 0, 0, 20)
            TitleLabel.BackgroundTransparency = 1
            TitleLabel.Text = "  " .. title
            TitleLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
            TitleLabel.TextSize = 14
            TitleLabel.Font = Enum.Font.GothamBold
            TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
            TitleLabel.Parent = SectionFrame
            
            local Separator = Instance.new("Frame")
            Separator.Name = "Separator"
            Separator.Size = UDim2.new(1, -10, 0, 1)
            Separator.Position = UDim2.new(0, 5, 1, -1)
            Separator.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
            Separator.BorderSizePixel = 0
            Separator.Parent = SectionFrame
            
            table.insert(tabs[name].elements, SectionFrame)
            
            return section
        end
        
        function tab:CreateToggle(options)
            local toggle = {}
            local value = options.CurrentValue or false
            
            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = "Toggle"
            ToggleFrame.Size = UDim2.new(1, 0, 0, 30)
            ToggleFrame.BackgroundTransparency = 1
            ToggleFrame.Parent = TabContent
            
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Name = "ToggleButton"
            ToggleButton.Size = UDim2.new(1, 0, 1, 0)
            ToggleButton.BackgroundTransparency = 1
            ToggleButton.Text = ""
            ToggleButton.Parent = ToggleFrame
            
            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Name = "Label"
            ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Text = "  " .. options.Name
            ToggleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
            ToggleLabel.TextSize = 14
            ToggleLabel.Font = Enum.Font.Gotham
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.Parent = ToggleFrame
            
            local ToggleBox = Instance.new("Frame")
            ToggleBox.Name = "Box"
            ToggleBox.Size = UDim2.new(0, 40, 0, 20)
            ToggleBox.Position = UDim2.new(1, -45, 0.5, -10)
            ToggleBox.BackgroundColor3 = value and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(70, 70, 75)
            ToggleBox.BorderSizePixel = 0
            ToggleBox.Parent = ToggleFrame
            
            local BoxCorner = Instance.new("UICorner")
            BoxCorner.CornerRadius = UDim.new(0, 4)
            BoxCorner.Parent = ToggleBox
            
            local ToggleCircle = Instance.new("Frame")
            ToggleCircle.Name = "Circle"
            ToggleCircle.Size = UDim2.new(0, 16, 0, 16)
            ToggleCircle.Position = UDim2.new(0, value and 22 or 2, 0.5, -8)
            ToggleCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            ToggleCircle.BorderSizePixel = 0
            ToggleCircle.Parent = ToggleBox
            
            local CircleCorner = Instance.new("UICorner")
            CircleCorner.CornerRadius = UDim.new(1, 0)
            CircleCorner.Parent = ToggleCircle
            
            local function updateToggle()
                value = not value
                ToggleBox.BackgroundColor3 = value and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(70, 70, 75)
                
                local tweenInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local tween = game:GetService("TweenService"):Create(
                    ToggleCircle,
                    tweenInfo,
                    {Position = UDim2.new(0, value and 22 or 2, 0.5, -8)}
                )
                tween:Play()
                
                if options.Callback then
                    options.Callback(value)
                end
            end
            
            ToggleButton.MouseButton1Click:Connect(updateToggle)
            
            table.insert(tabs[name].elements, ToggleFrame)
            
            function toggle:Set(newValue)
                if value ~= newValue then
                    updateToggle()
                end
            end
            
            return toggle
        end
        
        function tab:CreateButton(options)
            local button = {}
            
            local ButtonFrame = Instance.new("Frame")
            ButtonFrame.Name = "Button"
            ButtonFrame.Size = UDim2.new(1, 0, 0, 35)
            ButtonFrame.BackgroundTransparency = 1
            ButtonFrame.Parent = TabContent
            
            local MainButton = Instance.new("TextButton")
            MainButton.Name = "MainButton"
            MainButton.Size = UDim2.new(1, 0, 1, 0)
            MainButton.BackgroundColor3 = Color3.fromRGB(0, 120, 215)
            MainButton.Text = options.Name
            MainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            MainButton.TextSize = 14
            MainButton.Font = Enum.Font.GothamBold
            MainButton.Parent = ButtonFrame
            
            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 4)
            ButtonCorner.Parent = MainButton
            
            MainButton.MouseButton1Click:Connect(function()
                if options.Callback then
                    options.Callback()
                end
            end)
            
            table.insert(tabs[name].elements, ButtonFrame)
            
            return button
        end
        
        function tab:CreateInput(options)
            local input = {}
            local value = ""
            
            local InputFrame = Instance.new("Frame")
            InputFrame.Name = "Input"
            InputFrame.Size = UDim2.new(1, 0, 0, 35)
            InputFrame.BackgroundTransparency = 1
            InputFrame.Parent = TabContent
            
            local TextBox = Instance.new("TextBox")
            TextBox.Name = "TextBox"
            TextBox.Size = UDim2.new(1, 0, 1, 0)
            TextBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
            TextBox.Text = options.PlaceholderText or ""
            TextBox.PlaceholderText = options.PlaceholderText or ""
            TextBox.TextColor3 = Color3.fromRGB(240, 240, 240)
            TextBox.TextSize = 14
            TextBox.Font = Enum.Font.Gotham
            TextBox.ClearTextOnFocus = options.RemoveTextAfterFocusLost or false
            TextBox.Parent = InputFrame
            
            local BoxCorner = Instance.new("UICorner")
            BoxCorner.CornerRadius = UDim.new(0, 4)
            BoxCorner.Parent = TextBox
            
            TextBox.FocusLost:Connect(function()
                value = TextBox.Text
                if options.Callback then
                    options.Callback(value)
                end
            end)
            
            table.insert(tabs[name].elements, InputFrame)
            
            return input
        end
        
        function tab:CreateDropdown(options)
            local dropdown = {}
            local isOpen = false
            local currentOption = options.CurrentOption or options.Options[1]
            
            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Name = "Dropdown"
            DropdownFrame.Size = UDim2.new(1, 0, 0, 35)
            DropdownFrame.BackgroundTransparency = 1
            DropdownFrame.ClipsDescendants = true
            DropdownFrame.Parent = TabContent
            
            local MainButton = Instance.new("TextButton")
            MainButton.Name = "MainButton"
            MainButton.Size = UDim2.new(1, 0, 0, 35)
            MainButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
            MainButton.Text = currentOption
            MainButton.TextColor3 = Color3.fromRGB(240, 240, 240)
            MainButton.TextSize = 14
            MainButton.Font = Enum.Font.Gotham
            MainButton.Parent = DropdownFrame
            
            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 4)
            ButtonCorner.Parent = MainButton
            
            local OptionsFrame = Instance.new("Frame")
            OptionsFrame.Name = "Options"
            OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
            OptionsFrame.Position = UDim2.new(0, 0, 0, 40)
            OptionsFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            OptionsFrame.Visible = false
            OptionsFrame.Parent = DropdownFrame
            
            local OptionsList = Instance.new("UIListLayout")
            OptionsList.Parent = OptionsFrame
            
            -- Create option buttons
            for i, option in ipairs(options.Options) do
                local OptionButton = Instance.new("TextButton")
                OptionButton.Name = option
                OptionButton.Size = UDim2.new(1, 0, 0, 30)
                OptionButton.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
                OptionButton.Text = option
                OptionButton.TextColor3 = Color3.fromRGB(240, 240, 240)
                OptionButton.TextSize = 14
                OptionButton.Font = Enum.Font.Gotham
                OptionButton.Parent = OptionsFrame
                
                OptionButton.MouseButton1Click:Connect(function()
                    currentOption = option
                    MainButton.Text = option
                    isOpen = false
                    OptionsFrame.Visible = false
                    OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
                    
                    if options.Callback then
                        options.Callback(option)
                    end
                end)
            end
            
            MainButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                OptionsFrame.Visible = isOpen
                OptionsFrame.Size = UDim2.new(1, 0, 0, isOpen and (#options.Options * 30) or 0)
            end)
            
            table.insert(tabs[name].elements, DropdownFrame)
            
            return dropdown
        end
        
        return tab
    end
    
    function window:CreateNotification(options)
        local notification = {}
        
        local NotifFrame = Instance.new("Frame")
        NotifFrame.Name = "Notification"
        NotifFrame.Size = UDim2.new(0, 300, 0, 80)
        NotifFrame.Position = UDim2.new(1, -320, 1, -90)
        NotifFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
        NotifFrame.BorderSizePixel = 0
        NotifFrame.Parent = ScreenGui
        
        local NotifCorner = Instance.new("UICorner")
        NotifCorner.CornerRadius = UDim.new(0, 8)
        NotifCorner.Parent = NotifFrame
        
        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Name = "Title"
        TitleLabel.Size = UDim2.new(1, -20, 0, 25)
        TitleLabel.Position = UDim2.new(0, 10, 0, 10)
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Text = options.Title or "Notification"
        TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleLabel.TextSize = 16
        TitleLabel.Font = Enum.Font.GothamBold
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.Parent = NotifFrame
        
        local ContentLabel = Instance.new("TextLabel")
        ContentLabel.Name = "Content"
        ContentLabel.Size = UDim2.new(1, -20, 0, 35)
        ContentLabel.Position = UDim2.new(0, 10, 0, 35)
        ContentLabel.BackgroundTransparency = 1
        ContentLabel.Text = options.Content or ""
        ContentLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        ContentLabel.TextSize = 14
        ContentLabel.Font = Enum.Font.Gotham
        ContentLabel.TextXAlignment = Enum.TextXAlignment.Left
        ContentLabel.TextYAlignment = Enum.TextYAlignment.Top
        ContentLabel.TextWrapped = true
        ContentLabel.Parent = NotifFrame
        
        local duration = options.Duration or 5
        
        task.spawn(function()
            task.wait(duration)
            local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local tween = game:GetService("TweenService"):Create(
                NotifFrame,
                tweenInfo,
                {Position = UDim2.new(1, -320, 1, 10)}
            )
            tween:Play()
            tween.Completed:Wait()
            NotifFrame:Destroy()
        end)
        
        return notification
    end
    
    return window
end

-- ====================================================================
--                     INITIALIZE WINDUI
-- ====================================================================
local Window = WindUI:CreateWindow({
    Name = "🎣 Auto Fish V5.0 - WindUI"
})

-- ====== MAIN TAB ======
local MainTab = Window:CreateTab("Main")

MainTab:CreateSection("Auto Fishing")

local BlatantToggle = MainTab:CreateToggle({
    Name = "⚡ BLATANT MODE (Enhanced)",
    CurrentValue = Config.BlatantMode,
    Callback = function(value)
        Config.BlatantMode = value
        saveConfig()
        if value then
            Window:CreateNotification({
                Title = "Blatant Mode",
                Content = "Enabled - Ultra Fast Fishing",
                Duration = 3
            })
        end
    end
})

local AutoFishToggle = MainTab:CreateToggle({
    Name = "🤖 Auto Fish",
    CurrentValue = Config.AutoFish,
    Callback = function(value)
        Config.AutoFish = value
        fishingActive = value
        saveConfig()
        
        if value then
            startFishingLoop()
            Window:CreateNotification({
                Title = "Auto Fish",
                Content = Config.BlatantMode and "Started (Blatant Mode)" or "Started (Normal Mode)",
                Duration = 3
            })
        else
            if fishingTask then
                task.cancel(fishingTask)
                fishingTask = nil
            end
            pcall(function() Events.unequip:FireServer() end)
            Window:CreateNotification({
                Title = "Auto Fish",
                Content = "Stopped",
                Duration = 3
            })
        end
    end
})

MainTab:CreateToggle({
    Name = "🎯 Auto Catch",
    CurrentValue = Config.AutoCatch,
    Callback = function(value)
        Config.AutoCatch = value
        saveConfig()
    end
})

MainTab:CreateSection("Delay Settings")

MainTab:CreateInput({
    Name = "Fish Delay (Bite Wait)",
    PlaceholderText = "Default: 0.9",
    RemoveTextAfterFocusLost = false,
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 0.1 and num <= 5 then
            Config.FishDelay = num
            saveConfig()
        end
    end
})

MainTab:CreateInput({
    Name = "Catch Delay (Cooldown)",
    PlaceholderText = "Default: 0.2",
    RemoveTextAfterFocusLost = false,
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 0.1 and num <= 5 then
            Config.CatchDelay = num
            saveConfig()
        end
    end
})

-- NEW: Reel Delay Input
MainTab:CreateInput({
    Name = "Reel Delay (Between Reels)",
    PlaceholderText = "Default: 0.05",
    RemoveTextAfterFocusLost = false,
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 0.01 and num <= 0.5 then
            Config.ReelDelay = num
            saveConfig()
            Window:CreateNotification({
                Title = "Delay Updated",
                Content = "Reel delay set to " .. num .. "s",
                Duration = 2
            })
        end
    end
})

-- NEW: Bait Delay Input
MainTab:CreateInput({
    Name = "Bait Delay (Between Casts)",
    PlaceholderText = "Default: 0.1",
    RemoveTextAfterFocusLost = false,
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 0.01 and num <= 0.5 then
            Config.BaitDelay = num
            saveConfig()
            Window:CreateNotification({
                Title = "Delay Updated",
                Content = "Bait delay set to " .. num .. "s",
                Duration = 2
            })
        end
    end
})

MainTab:CreateSection("Blatant Settings")

MainTab:CreateInput({
    Name = "Parallel Casts (1-3)",
    PlaceholderText = "Default: 2",
    RemoveTextAfterFocusLost = false,
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 1 and num <= 3 then
            Config.BlatantCasts = math.floor(num)
            saveConfig()
        end
    end
})

MainTab:CreateInput({
    Name = "Reel Spams (1-10)",
    PlaceholderText = "Default: 5",
    RemoveTextAfterFocusLost = false,
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 1 and num <= 10 then
            Config.BlatantReels = math.floor(num)
            saveConfig()
        end
    end
})

MainTab:CreateInput({
    Name = "Speed Multiplier (0.3-1)",
    PlaceholderText = "Default: 0.5",
    RemoveTextAfterFocusLost = false,
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 0.3 and num <= 1 then
            Config.BlatantMultiplier = num
            saveConfig()
        end
    end
})

MainTab:CreateSection("Auto Sell")

MainTab:CreateToggle({
    Name = "💰 Auto Sell",
    CurrentValue = Config.AutoSell,
    Callback = function(value)
        Config.AutoSell = value
        saveConfig()
    end
})

MainTab:CreateInput({
    Name = "Sell Delay (Seconds)",
    PlaceholderText = "Default: 30",
    RemoveTextAfterFocusLost = false,
    Callback = function(value)
        local num = tonumber(value)
        if num and num >= 10 and num <= 300 then
            Config.SellDelay = num
            saveConfig()
        end
    end
})

MainTab:CreateButton({
    Name = "💰 Sell All Now",
    Callback = function()
        simpleSell()
        Window:CreateNotification({
            Title = "Sell All",
            Content = "Attempting to sell items...",
            Duration = 3
        })
    end
})

-- ====== TELEPORT TAB ======
local TeleportTab = Window:CreateTab("Teleport")

TeleportTab:CreateSection("Locations")

for locationName, _ in pairs(LOCATIONS) do
    TeleportTab:CreateButton({
        Name = locationName,
        Callback = function()
            if Teleport.to(locationName) then
                Window:CreateNotification({
                    Title = "Teleport",
                    Content = "Moved to " .. locationName,
                    Duration = 3
                })
            end
        end
    })
end

-- ====== SETTINGS TAB ======
local SettingsTab = Window:CreateTab("Settings")

SettingsTab:CreateSection("Performance")

SettingsTab:CreateToggle({
    Name = "🖥️ GPU Saver Mode",
    CurrentValue = Config.GPUSaver,
    Callback = function(value)
        Config.GPUSaver = value
        saveConfig()
        if value then
            enableGPU()
        else
            disableGPU()
        end
    end
})

SettingsTab:CreateToggle({
    Name = "🔄 Anti-AFK",
    CurrentValue = Config.AntiAFK,
    Callback = function(value)
        Config.AntiAFK = value
        saveConfig()
    end
})

SettingsTab:CreateSection("Auto Favorite")

SettingsTab:CreateToggle({
    Name = "⭐ Auto Favorite",
    CurrentValue = Config.AutoFavorite,
    Callback = function(value)
        Config.AutoFavorite = value
        saveConfig()
    end
})

SettingsTab:CreateDropdown({
    Name = "Favorite Rarity",
    Options = {"Mythic", "Secret"},
    CurrentOption = Config.FavoriteRarity,
    Callback = function(option)
        Config.FavoriteRarity = option
        saveConfig()
    end
})

SettingsTab:CreateButton({
    Name = "⭐ Favorite Now",
    Callback = function()
        local count = autoFavoriteByRarity()
        Window:CreateNotification({
            Title = "Auto Favorite",
            Content = "Favorited " .. count .. " items",
            Duration = 3
        })
    end
})

SettingsTab:CreateSection("Configuration")

SettingsTab:CreateButton({
    Name = "💾 Save Config",
    Callback = function()
        if saveConfig() then
            Window:CreateNotification({
                Title = "Configuration",
                Content = "Settings saved successfully",
                Duration = 3
            })
        end
    end
})

SettingsTab:CreateButton({
    Name = "🔄 Load Config",
    Callback = function()
        if loadConfig() then
            BlatantToggle:Set(Config.BlatantMode)
            AutoFishToggle:Set(Config.AutoFish)
            Window:CreateNotification({
                Title = "Configuration",
                Content = "Settings loaded successfully",
                Duration = 3
            })
        end
    end
})

SettingsTab:CreateButton({
    Name = "🗑️ Reset Config",
    Callback = function()
        for k, v in pairs(DefaultConfig) do
            Config[k] = v
        end
        saveConfig()
        BlatantToggle:Set(Config.BlatantMode)
        AutoFishToggle:Set(Config.AutoFish)
        Window:CreateNotification({
            Title = "Configuration",
            Content = "Settings reset to defaults",
            Duration = 3
        })
    end
})

-- ====== INFO TAB ======
local InfoTab = Window:CreateTab("Info")

InfoTab:CreateSection("About")

InfoTab:CreateButton({
    Name = "📊 Check Stability",
    Callback = function()
        if fishingActive and Config.BlatantMode then
            Window:CreateNotification({
                Title = "Stability Check",
                Content = "Check console for 5/7 stability report",
                Duration = 5
            })
        else
            Window:CreateNotification({
                Title = "Stability Check",
                Content = "Blatant Mode must be active",
                Duration = 3
            })
        end
    end
})

InfoTab:CreateButton({
    Name = "🔄 Restart Script",
    Callback = function()
        Window:CreateNotification({
            Title = "Restart",
            Content = "Please re-execute the script",
            Duration = 3
        })
    end
})

-- ====================================================================
--                     STARTUP
-- ====================================================================
Window:CreateNotification({
    Title = "Auto Fish V5.0 Loaded",
    Content = "WindUI Edition - Enhanced Stability",
    Duration = 5
})

print("=========================================")
print("🎣 AUTO FISH V5.0 - WINDUI EDITION")
print("✅ Enhanced Blatant Mode with 5/7 Notifs")
print("✅ Added Reel Delay & Bait Delay")
print("✅ WindUI Implementation")
print("✅ Improved Stability System")
print("=========================================")

-- Apply GPU Saver on startup if enabled
if Config.GPUSaver then
    task.wait(1)
    enableGPU()
end