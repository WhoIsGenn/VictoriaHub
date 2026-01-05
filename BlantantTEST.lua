local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

-- ============================
-- UI
-- ============================

local Window = WindUI:CreateWindow({
    Title = "Victoria Hub",
    Icon = "rbxassetid://71947103252559",
    Author = "Premium | Fish It",
    Folder = "Victoria_HUB",
    Size = UDim2.fromOffset(260, 290),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 170,
    HasOutline = true,                                                             
})

Window:EditOpenButton({
    Title = "Victoria Hub",
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

local Dialog = Window:Dialog({
    Icon = "circle-plus",
    Title = "Join Discord",
    Content = "For Update",
    Buttons = {
        {
            Title = "Copy Discord",
            Callback = function()
                if setclipboard then
                    setclipboard("https://discord.gg/tjb2jWgfVC")
                    
                    -- Notify jika berhasil
                    WindUI:Notify({
                        Title = "Copied Successfully!",
                        Content = "The Discord link has been copied to the clipboard.",
                        Duration = 3,
                        Icon = "check"
                    })
                else
                    -- Notify jika executor tidak support
                    WindUI:Notify({
                        Title = "Fail!",
                        Content = "Your executor does not support the auto-copy command.",
                        Duration = 3,
                        Icon = "x"
                    })
                end
            end,
        },
        {
            Title = "No",
            Callback = function()
                WindUI:Notify({
                    Title = "Canceled",
                    Content = "You cancel the action.",
                    Duration = 3,
                    Icon = "x"
                })
            end,
        },
    },
})

WindUI:Notify({
    Title = "Victoria Hub Loaded",
    Content = "UI loaded successfully!",
    Duration = 3,
    Icon = "bell",
})

local Tab0 = Window:Tab({
    Title = "Main",
    Icon = "star",
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local c={d=false,e=1.6,f=0.37}

local g=ReplicatedStorage:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")

local h,i,j,k,l
pcall(function()
    h=g:WaitForChild("RF/ChargeFishingRod")
    i=g:WaitForChild("RF/RequestFishingMinigameStarted")
    j=g:WaitForChild("RE/FishingCompleted")
    k=g:WaitForChild("RE/EquipToolFromHotbar")
    l=g:WaitForChild("RF/CancelFishingInputs")
end)

local m=nil
local n=nil
local o=nil

local function p()
    task.spawn(function()
        pcall(function()
            local q,r=l:InvokeServer()
            if not q then
                while not q do
                    local s=l:InvokeServer()
                    if s then break end
                    task.wait(0.05)
                end
            end

            local t,u=h:InvokeServer(math.huge)
            if not t then
                while not t do
                    local v=h:InvokeServer(math.huge)
                    if v then break end
                    task.wait(0.05)
                end
            end

            i:InvokeServer(-139.63,0.996)
        end)
    end)

    task.spawn(function()
        task.wait(c.f)
        if c.d then
            pcall(j.FireServer,j)
        end
    end)
end

local function w()
    n=task.spawn(function()
        while c.d do
            pcall(k.FireServer,k,1)
            task.wait(1.5)
        end
    end)

    while c.d do
        p()
        task.wait(c.e)
        if not c.d then break end
        task.wait(0.1)
    end
end

local function x(y)
    c.d=y
    if y then
        if m then task.cancel(m) end
        if n then task.cancel(n) end
        m=task.spawn(w)
    else
        if m then task.cancel(m) end
        if n then task.cancel(n) end
        m=nil
        n=nil
        pcall(l.InvokeServer,l)
    end
end

blantant = Tab0:Section({ 
    Title = "Blantant X7 | Tester",
    Icon = "fish",
    TextTransparency = 0.05,
    TextXAlignment = "Left",
    TextSize = 17,
})

blantant:Toggle({
    Title = "Blantant",
    Value = c.d,
    Callback = function(z2)
        x(z2)
    end
})

blantant:Input({
    Title = "Cancel Delay",
    Placeholder = "1.7",
    Default = tostring(c.e),
    Callback = function(z4)
        local z5 = tonumber(z4)
        if z5 and z5 > 0 then
            c.e = z5
        end
    end
})

blantant:Input({
    Title = "Complete Delay",
    Placeholder = "1.4",
    Default = tostring(c.f),
    Callback = function(z7)
        local z8 = tonumber(z7)
        if z8 and z8 > 0 then
            c.f = z8
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