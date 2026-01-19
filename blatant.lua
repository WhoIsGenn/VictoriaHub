local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)

-- ============================
-- UI
-- ============================

local Window = WindUI:CreateWindow({
    Title = "Lexs Hub",
    Icon = "rbxassetid://71947103252559",
    Author = "Premium | Fish It",
    Folder = "LEXS_HUB",
    Size = UDim2.fromOffset(260, 290),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 170,
    HasOutline = true,                                                             
})

Window:EditOpenButton({
    Title = "Lexs Hub",
    Icon = "rbxassetid://71947103252559",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = ColorSequence.new( -- gradient
        Color3.fromHex("#00fbff"), 
        Color3.fromHex("#ffffff")
    ),
    OnlyMobile = false,
    Enabled = true,
    Draggable = true,
})

Window:Tag({
    Title = "VBLANTANT",
    Color = Color3.fromRGB(255, 255, 255),
    Radius = 17,
})

local executorName = "Unknown"
if identifyexecutor then
    executorName = identifyexecutor()
elseif getexecutorname then
    executorName = getexecutorname()
elseif executor then
    executorName = executor
end

-- Pilih warna berdasarkan executor
local executorColor = Color3.fromRGB(200, 200, 200) -- Default (abu-abu)

if executorName:lower():find("flux") then
    executorColor = Color3.fromHex("#30ff6a")     -- Fluxus
elseif executorName:lower():find("delta") then
    executorColor = Color3.fromHex("#38b6ff")     -- Delta
elseif executorName:lower():find("arceus") then
    executorColor = Color3.fromHex("#a03cff")     -- Arceus X
elseif executorName:lower():find("krampus") or executorName:lower():find("oxygen") then
    executorColor = Color3.fromHex("#ff3838")     -- Krampus / Oxygen
elseif executorName:lower():find("volcano") then
    executorColor = Color3.fromHex("#ff8c00")     -- Volcano
elseif executorName:lower():find("synapse") or executorName:lower():find("script") or executorName:lower():find("krypton") then
    executorColor = Color3.fromHex("#ffd700")     -- Synapse / Script-Ware / Krypton
elseif executorName:lower():find("wave") then
    executorColor = Color3.fromHex("#00e5ff")     -- Wave
elseif executorName:lower():find("zenith") then
    executorColor = Color3.fromHex("#ff00ff")     -- Zenith
elseif executorName:lower():find("seliware") then
    executorColor = Color3.fromHex("#00ffa2")     -- Seliware
elseif executorName:lower():find("krnl") then
    executorColor = Color3.fromHex("#1e90ff")     -- KRNL
elseif executorName:lower():find("trigon") then
    executorColor = Color3.fromHex("#ff007f")     -- Trigon
elseif executorName:lower():find("nihon") then
    executorColor = Color3.fromHex("#8a2be2")     -- Nihon
elseif executorName:lower():find("celery") then
    executorColor = Color3.fromHex("#4caf50")     -- Celery
elseif executorName:lower():find("lunar") then
    executorColor = Color3.fromHex("#8080ff")     -- Lunar
elseif executorName:lower():find("valyse") then
    executorColor = Color3.fromHex("#ff1493")     -- Valyse
elseif executorName:lower():find("vega") then
    executorColor = Color3.fromHex("#4682b4")     -- Vega X
elseif executorName:lower():find("electron") then
    executorColor = Color3.fromHex("#7fffd4")     -- Electron
elseif executorName:lower():find("awp") then
    executorColor = Color3.fromHex("#ff005e") -- AWP (merah neon ke pink)
elseif executorName:lower():find("bunni") or executorName:lower():find("bunni.lol") then
    executorColor = Color3.fromHex("#ff69b4") -- Bunni.lol (Hot Pink / Neon Pink)
end

-- Buat Tag UI
local TagUI = Window:Tag({
    Title = "EXECUTOR | " .. tostring(executorName),
    Icon = "github",
    Color = executorColor,
    Radius = 0
})

WindUI:Notify({
    Title = "Lexs Hub Loaded",
    Content = "UI loaded successfully!",
    Duration = 3,
    Icon = "bell",
})

local Tab0 = Window:Tab({
    Title = "Exclusive",
    Icon = "star",
})

--// SERVICES
local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

--// NET
local Net = RS:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

--// REMOTES
local RF_Start    = Net:WaitForChild("RF/RequestFishingMinigameStarted")
local RF_Charge   = Net:WaitForChild("RF/ChargeFishingRod")
local RF_Cancel   = Net:WaitForChild("RF/CancelFishingInputs")
local RE_Complete = Net:WaitForChild("RE/FishingCompleted")

--// BYPASS CONTROLLER
local FishingController = require(
    RS:WaitForChild("Controllers"):WaitForChild("FishingController")
)

do
    local old = FishingController.RequestChargeFishingRod
    FishingController.RequestChargeFishingRod = function(...)
        if _G.BlFishing then return end
        return old(...)
    end
end

--// GLOBAL CONFIG
_G.BlFishing = false
_G.BlDelay = 0.7
_G.BlCompleteDelay = 0.3

--// INTERNAL STATE
local busy = false
local lastTick = 0
local missCount = 0
local MISS_LIMIT = 3

--// CORE FISHING TICK (NON STOP)
local function fishingTick()
    if busy then return end
    busy = true

    local startTime = os.clock()

    -- selalu charge (NON STOP)
    pcall(function()
        RF_Charge:InvokeServer(startTime)
        RF_Start:InvokeServer(
            -140 + math.random(-1, 1),
            0.99
        )

        task.wait(_G.BlCompleteDelay)
        RE_Complete:FireServer()
    end)

    -- soft miss detection (infer)
    if os.clock() - startTime < 0.15 then
        missCount += 1
    else
        missCount = 0
    end

    -- soft retry (tanpa stop loop)
    if missCount >= MISS_LIMIT then
        RF_Cancel:InvokeServer()
        missCount = 0
    end

    busy = false
end

--// LOOP ENGINE
task.spawn(function()
    while true do
        if _G.BlFishing then
            local now = os.clock()
            if now - lastTick >= math.max(_G.BlDelay, 0.15) then
                lastTick = now
                fishingTick()
            end
        end
        RunService.Heartbeat:Wait()
    end
end)

--// ===================== UI =====================

local BlatantSection = Tab0:Section({
    Title = "Blatant Fishing (Stable)",
    Icon = "fish",
    TextTransparency = 0.05,
    TextXAlignment = "Left",
    TextSize = 17,
})

BlatantSection:Toggle({
    Title = "Enable Blatant Fishing",
    Value = _G.BlFishing,
    Callback = function(v)
        _G.BlFishing = v
    end
})

BlatantSection:Input({
    Title = "Loop Delay",
    Placeholder = "contoh: 0.7",
    Default = tostring(_G.BlDelay),
    Callback = function(v)
        local n = tonumber(v)
        if n and n >= 0.15 then
            _G.BlDelay = n
        end
    end
})

BlatantSection:Input({
    Title = "Complete Delay",
    Placeholder = "contoh: 0.3",
    Default = tostring(_G.BlCompleteDelay),
    Callback = function(v)
        local n = tonumber(v)
        if n and n >= 0.03 then
            _G.BlCompleteDelay = n
        end
    end
})


local RS = game:GetService("ReplicatedStorage")
local Net = RS.Packages._Index["sleitnick_net@0.2.0"].net
local FC = require(RS.Controllers.FishingController)

local oc, orc = FC.RequestFishingMinigameClick, FC.RequestChargeFishingRod
local ap = false

task.spawn(function()
    while task.wait() do
        if ap then
            Net["RF/UpdateAutoFishingState"]:InvokeServer(true)
        end
    end
end)

blantant:Toggle({
    Title = "Auto Perfection",
    Value = false,
    Callback = function(s)
        ap = s
        if s then
            FC.RequestFishingMinigameClick = function() end
            FC.RequestChargeFishingRod = function() end
        else
            Net["RF/UpdateAutoFishingState"]:InvokeServer(false)
            FC.RequestFishingMinigameClick = oc
            FC.RequestChargeFishingRod = orc
        end
    end
})