-- [[ VICTORIA HUB FISH IT - COMPLETE ORIGINAL + OPTIMIZED ]] --
-- Version: 0.0.9.2
-- ALL ORIGINAL FEATURES + PERFORMANCE OPTIMIZATION

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

-- AUTO ANTI-AFK (ACTIVE ON EXECUTE)

local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")

_G.AntiAFK = true

-- Handle Roblox Idle Event
Players.LocalPlayer.Idled:Connect(function()
    if _G.AntiAFK then
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end)

-- Extra activity loop (anti detect tambahan)
task.spawn(function()
    while _G.AntiAFK do
        task.wait(30)
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:MoveMouseBy(1, 0)
            task.wait(0.1)
            VirtualUser:MoveMouseBy(-1, 0)
        end)
    end
end)

print("✅ Anti-AFK aktif (auto)")


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

-- ==================== MAIN WINDOW (UNIVERSAL DESKTOP + MOBILE) ====================
local Window = WindUI:CreateWindow({
    Title = "Victoria Hub",
    Icon = "rbxassetid://134034549147826",
    Author = "Freemium | Fish It",
    Folder = "VICTORIA_HUB",
    Size = UDim2.fromOffset(260, 290),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 170,
    HasOutline = true,                                                          
})                                                             

Window:EditOpenButton({
    Title = "Victoria Hub",
    Icon = "rbxassetid://134034549147826",
    CornerRadius = UDim.new(0,16),
    StrokeThickness = 2,
    Color = ColorSequence.new( -- gradient
        Color3.fromHex("#00c3ff"), 
        Color3.fromHex("#ffffff")
    ),
    OnlyMobile = true,
    Enabled = true,
    Draggable = true,
})

Window:Tag({
    Title = "V0.0.9.2",
    Color = Color3.fromRGB(255, 255, 255),
    Radius = 17,
})



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

Window:Tag({
    Title = "EXECUTOR | " .. executorName,
    Icon = "github",
    Color = executorColor,
    Radius = 0
})

-- ==================== DISCORD DIALOG ====================
Window:Dialog({
    Icon = "circle-plus",
    Title = "Join Discord",
    Content = "For Update",
    Buttons = {
        {
            Title = "Copy Discord",
            Callback = function()
                if setclipboard then
                    setclipboard("https://discord.gg/victoriahub")
                    WindUI:Notify({
                        Title = "Copied Successfully!",
                        Content = "The Discord link has been copied to the clipboard.",
                        Duration = 3,
                        Icon = "check"
                    })
                else
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

-- ==================== TAB 1: INFO ====================
local Tab1 = Window:Tab({
    Title = "Info",
    Icon = "info",
})

Window:SelectTab(1)

Tab1:Paragraph({
    Title = "Victoria Hub Community",
    Desc = "Join Our Community Discord Server to get the latest updates, support, and connect with other users!",
    Image = "rbxassetid://134034549147826",
    ImageSize = 24,
    Buttons = {
        {
            Title = "Copy Link",
            Icon = "link",
            Callback = function()
                setclipboard("https://discord.gg/victoriahub")
                WindUI:Notify({
                    Title = "Link Disalin!",
                    Content = "Link Discord Victoria Hub berhasil disalin.",
                    Duration = 3,
                    Icon = "copy",
                })
            end,
        }
    }
})

-- ==================== TAB 2: PLAYERS ====================
local Tab2 = Window:Tab({
    Title = "Players",
    Icon = "user"
})

local other = Tab2:Section({ 
    Title = "Other",
    Icon = "user",
    TextXAlignment = "Left",
    TextSize = 17,
    Opened = true,
})

-- SPEED
other:Slider({
    Title = "Speed",
    Desc = "Default 16",
    Step = 1,
    Value = { Min = 18, Max = 100, Default = 18 },
    Callback = function(Value)
        local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = Value end
    end
})

-- JUMP
other:Slider({
    Title = "Jump",
    Desc = "Default 50",
    Step = 1,
    Value = { Min = 50, Max = 500, Default = 50 },
    Callback = function(Value)
        local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.JumpPower = Value end
    end
})

Tab2:Divider()

-- INFINITE JUMP
local UIS = game:GetService("UserInputService")
_G.InfiniteJump = false

other:Toggle({
    Title = "Infinite Jump",
    Desc = "activate to use infinite jump",
    Default = false,
    Callback = function(state)
        _G.InfiniteJump = state
    end
})

SafeConnect("InfiniteJump", UIS.JumpRequest:Connect(function()
    if _G.InfiniteJump then
        local h = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

-- NOCLIP
_G.Noclip = false

other:Toggle({
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

-- FREEZE CHARACTER (ORIGINAL)
local frozen, last
local P, SG = game.Players.LocalPlayer, game.StarterGui

local function msg(t,c)
    pcall(function()
        SG:SetCore("ChatMakeSystemMessage",{
            Text="[FREEZE] "..t,
            Color=c or Color3.fromRGB(150,255,150),
            Font=Enum.Font.SourceSansBold,
            FontSize=Enum.FontSize.Size24
        })
    end)
end

local function setFreeze(s)
    local c = P.Character or P.CharacterAdded:Wait()
    local h = c:FindFirstChildOfClass("Humanoid")
    local r = c:FindFirstChild("HumanoidRootPart")
    if not h or not r then return end

    if s then
        last = r.CFrame
        h.WalkSpeed,h.JumpPower,h.AutoRotate,h.PlatformStand = 0,0,false,true
        for _,t in ipairs(h:GetPlayingAnimationTracks()) do t:Stop(0) end
        local a = h:FindFirstChildOfClass("Animator")
        if a then a:Destroy() end
        r.Anchored = true
        msg("Freeze character",Color3.fromRGB(100,200,255))
    else
        h.WalkSpeed,h.JumpPower,h.AutoRotate,h.PlatformStand = 16,50,true,false
        if not h:FindFirstChildOfClass("Animator") then Instance.new("Animator",h) end
        r.Anchored = false
        if last then r.CFrame = last end
        msg("Character released",Color3.fromRGB(255,150,150))
    end
end

other:Toggle({
    Title="Freeze Character",
    Value=false,
    Callback=function(s)
        frozen = s
        setFreeze(s)
    end
})

-- DISABLE ANIMATIONS (ORIGINAL)
local animDisabled = false
local animConn

local function applyAnimState()
    local c = P.Character or P.CharacterAdded:Wait()
    local h = c:FindFirstChildOfClass("Humanoid")
    if not h then return end

    if animDisabled then
        for _, track in ipairs(h:GetPlayingAnimationTracks()) do
            pcall(function() track:Stop(0); track:Destroy() end)
        end

        if animConn then animConn:Disconnect(); animConn = nil end

        animConn = h.AnimationPlayed:Connect(function(track)
            if animDisabled and track then
                task.defer(function()
                    pcall(function() track:Stop(0); track:Destroy() end)
                end)
            end
        end)
    else
        if animConn then animConn:Disconnect(); animConn = nil end
        local animate = c:FindFirstChild("Animate")
        if animate then animate.Disabled = false end
        h:ChangeState(Enum.HumanoidStateType.Physics)
        task.wait()
        h:ChangeState(Enum.HumanoidStateType.Running)
    end
end

SafeConnect("CharacterAddedAnim", P.CharacterAdded:Connect(function()
    task.wait(0.4)
    if animDisabled then pcall(applyAnimState) end
end))

other:Toggle({
    Title = "Disable Animations",
    Value = false,
    Callback = function(state)
        animDisabled = state
        pcall(applyAnimState)
    end
})

_G.AutoFishing = false
_G.AutoEquipRod = false
_G.Radar = false
_G.Instant = false
_G.InstantDelay = _G.InstantDelay or 0.35
_G.CallMinDelay = _G.CallMinDelay or 0.18
_G.CallBackoff = _G.CallBackoff or 1.5

local lastCall = {}
local function safeCall(k, f)
    local n = os.clock()
    if lastCall[k] and n - lastCall[k] < _G.CallMinDelay then
        task.wait(_G.CallMinDelay - (n - lastCall[k]))
    end
    local ok, result = pcall(f)
    lastCall[k] = os.clock()
    if not ok then
        local msg = tostring(result):lower()
        task.wait(msg:find("429") or msg:find("too many requests") and _G.CallBackoff or 0.2)
    end
    return ok, result
end

local RS = game:GetService("ReplicatedStorage")
local net = RS.Packages._Index["sleitnick_net@0.2.0"].net

local function rod()
    safeCall("rod", function()
        net["RE/EquipToolFromHotbar"]:FireServer(1)
    end)
end

local function autoon()
    safeCall("autoon", function()
        net["RF/UpdateAutoFishingState"]:InvokeServer(true)
    end)
end

local function autooff()
    safeCall("autooff", function()
        net["RF/UpdateAutoFishingState"]:InvokeServer(false)
    end)
end

local function catch()
    safeCall("catch", function()
        net["RE/FishingCompleted"]:FireServer()
    end)
end

local function charge()
    safeCall("charge", function()
        net["RF/ChargeFishingRod"]:InvokeServer()
    end)
end

local function lempar()
    safeCall("lempar", function()
        net["RF/RequestFishingMinigameStarted"]:InvokeServer(-139.63, 0.996, -1761532005.497)
    end)
    safeCall("charge2", function()
        net["RF/ChargeFishingRod"]:InvokeServer()
    end)
end

local function instant_cycle()
    charge()
    lempar()
    task.wait(_G.InstantDelay)
    catch()
end

local Tab3 = Window:Tab({
    Title = "Main",
    Icon = "gamepad-2"
})

fishing = Tab3:Section({
    Title = "Fishing",
    Icon = "fish",
    TextXAlignment = "Left",
    TextSize = 17
})

fishing:Toggle({
    Title = "Auto Equip Rod",
    Value = false,
    Callback = function(v)
        _G.AutoEquipRod = v
        if v then rod() end
    end
})

local mode = "Instant"
local fishThread
local sellThread

fishing:Dropdown({
    Title = "Mode",
    Values = {"Instant", "Legit"},
    Value = "Instant",
    Callback = function(v)
        mode = v
        
        -- Auto matikan fishing ketika ganti mode
        if _G.AutoFishing then
            _G.AutoFishing = false
            autooff()
            if fishThread then 
                task.cancel(fishThread) 
                fishThread = nil
            end
        end
    end
})

-- Variable untuk menyimpan slider
local delaySlider

-- Function untuk update tampilan slider
local function updateDelaySlider()
    if delaySlider then
        if mode == "Instant" then
            -- Tampilkan slider jika mode Instant
            delaySlider.Visible = true
        else
            -- Sembunyikan slider jika mode Legit
            delaySlider.Visible = false
        end
    end
end

-- Buat slider (tetap dibuat, tapi visibility diatur)
delaySlider = fishing:Slider({
    Title = "Instant Fishing Delay",
    Step = 0.01,
    Value = {Min = 0.05, Max = 5, Default = _G.InstantDelay},
    Callback = function(v)
        _G.InstantDelay = v
    end,
    Visible = true -- Awalnya visible, nanti diatur berdasarkan mode
})

-- Update slider visibility berdasarkan mode awal
updateDelaySlider()

fishing:Toggle({
    Title = "Auto Fishing",
    Value = false,
    Callback = function(v)
        _G.AutoFishing = v
        if v then
            if mode == "Instant" then
                _G.Instant = true
                if fishThread then 
                    task.cancel(fishThread) 
                    fishThread = nil
                end
                fishThread = task.spawn(function()
                    while _G.AutoFishing and mode == "Instant" do
                        instant_cycle()
                        task.wait(_G.InstantDelay) -- Pakai delay yang bisa diatur
                    end
                end)
            else
                _G.Instant = false
                if fishThread then 
                    task.cancel(fishThread) 
                    fishThread = nil
                end
                fishThread = task.spawn(function()
                    while _G.AutoFishing and mode == "Legit" do
                        autoon()
                        task.wait(1)
                    end
                end)
            end
        else
            autooff()
            _G.Instant = false
            if fishThread then 
                task.cancel(fishThread) 
                fishThread = nil
            end
        end
    end
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- ================= CONFIG =================
local c = {
    d = false,
    e = 1.6,
    f = 0.37
}

-- CAST QUALITY CONFIG (IMPROVED RANGES)
local CastQuality = {
    Enabled = true,
    Mode = "random", -- "Random", "Fixed", "Cycle"
    FixedQuality = "Perfect",
    Qualities = {
        Perfect = {
            AngleMin = -1.2332,
            AngleMax = -1.2332,
            PowerMin = 1.0000,
            PowerMax = 1.0000
        },
        Amazing = {
            AngleMin = -1.2332,
            AngleMax = -1.2332,
            PowerMin = 1.0000,
            PowerMax = 1.0000
        },
        Great = {
            AngleMin = -1.2332,
            AngleMax = -1.2332,
            PowerMin = 1.0000,
            PowerMax = 1.0000
        }
    },
    CycleIndex = 1
}

local g = ReplicatedStorage
    :WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

-- ================= REMOTES =================
local h,i,j,k,l
pcall(function()
    h = g:WaitForChild("RF/ChargeFishingRod")
    i = g:WaitForChild("RF/RequestFishingMinigameStarted")
    j = g:WaitForChild("RE/FishingCompleted")
    k = g:WaitForChild("RE/EquipToolFromHotbar")
    l = g:WaitForChild("RF/CancelFishingInputs")
end)

local m,n

-- ================= GET CAST VALUES =================
local function getCastValues()
    if not CastQuality.Enabled then
        return -139.63796997070312, 0.9964792798079721
    end
    
    local quality
    
    if CastQuality.Mode == "Fixed" then
        quality = CastQuality.Qualities[CastQuality.FixedQuality]
    elseif CastQuality.Mode == "Cycle" then
        local qualityNames = {"Perfect", "Amazing", "Great"}
        quality = CastQuality.Qualities[qualityNames[CastQuality.CycleIndex]]
        CastQuality.CycleIndex = (CastQuality.CycleIndex % 3) + 1
    else -- Random
        local qualityNames = {"Perfect", "Amazing", "Great"}
        local randomQuality = qualityNames[math.random(#qualityNames)]
        quality = CastQuality.Qualities[randomQuality]
    end
    
    -- Random value dalam range
    local angle = math.random() * (quality.AngleMax - quality.AngleMin) + quality.AngleMin
    local power = math.random() * (quality.PowerMax - quality.PowerMin) + quality.PowerMin
    
    return angle, power
end

-- ================= ORIGINAL CAST =================
local function p()
    task.spawn(function()
        pcall(function()
            local q = l:InvokeServer()
            if not q then
                while not q do
                    local s = l:InvokeServer()
                    if s then break end
                    task.wait(0.05)
                end
            end

            local t = h:InvokeServer(math.huge)
            if not t then
                while not t do
                    local v = h:InvokeServer(math.huge)
                    if v then break end
                    task.wait(0.05)
                end
            end

            local angle, power = getCastValues()
            i:InvokeServer(angle, power)
        end)
    end)

    task.spawn(function()
        task.wait(c.f)
        if c.d then
            pcall(j.FireServer, j)
        end
    end)
end

-- ================= LOOP =================
local function w()
    n = task.spawn(function()
        while c.d do
            pcall(k.FireServer, k, 1)
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

-- ================= TOGGLE =================
local function x(state)
    c.d = state
    if state then
        if m then task.cancel(m) end
        if n then task.cancel(n) end
        m = task.spawn(w)
    else
        if m then task.cancel(m) end
        if n then task.cancel(n) end
        m,n = nil,nil
        pcall(l.InvokeServer, l)
    end
end

-- ========== BLANTANT V1 CONFIG & FUNCTIONS (FIXED) ==========
local netFolder = ReplicatedStorage:WaitForChild('Packages')
    :WaitForChild('_Index')
    :WaitForChild('sleitnick_net@0.2.0')
    :WaitForChild('net')

local Remotes = {}
Remotes.RF_RequestFishingMinigameStarted = netFolder:WaitForChild("RF/RequestFishingMinigameStarted")
Remotes.RF_ChargeFishingRod = netFolder:WaitForChild("RF/ChargeFishingRod")
Remotes.RF_CancelFishing = netFolder:WaitForChild("RF/CancelFishingInputs")
Remotes.RE_FishingCompleted = netFolder:WaitForChild("RE/FishingCompleted")
Remotes.RE_EquipTool = netFolder:WaitForChild("RE/EquipToolFromHotbar")

local toggleState = {
    blatantRunning = false,
}

local FishingController = require(
    ReplicatedStorage:WaitForChild('Controllers')
        :WaitForChild('FishingController')
)

local oldCharge = FishingController.RequestChargeFishingRod
FishingController.RequestChargeFishingRod = function(...)
    if toggleState.blatantRunning then
        return
    end
    return oldCharge(...)
end

local isSuperInstantRunning = false
_G.ReelSuper = 1.30
toggleState.completeDelays = 0.40
toggleState.delayStart = 0.1

local function autoEquipSuper()
    local success, err = pcall(function()
        Remotes.RE_EquipTool:FireServer(1)
    end)
end

local function superInstantFishingCycle()
    task.spawn(function()
        pcall(function()
            Remotes.RF_CancelFishing:InvokeServer()
            task.wait(0.05)
            Remotes.RF_ChargeFishingRod:InvokeServer(tick())
            task.wait(0.05)
            Remotes.RF_RequestFishingMinigameStarted:InvokeServer(-139.63796997070312, 0.9964792798079721)
            task.wait(toggleState.completeDelays)
            Remotes.RE_FishingCompleted:FireServer()
        end)
    end)
end

local function startSuperInstantFishing()
    if isSuperInstantRunning then return end
    isSuperInstantRunning = true
    toggleState.blatantRunning = true

    -- Auto equip fishing rod
    autoEquipSuper()
    task.wait(0.5)

    task.spawn(function()
        while isSuperInstantRunning do
            superInstantFishingCycle()
            task.wait(math.max(_G.ReelSuper, 0.1))
        end
    end)
end

local function stopSuperInstantFishing()
    isSuperInstantRunning = false
    toggleState.blatantRunning = false
    
    -- Cancel any ongoing fishing
    pcall(function()
        Remotes.RF_CancelFishing:InvokeServer()
    end)
    
end

-- ========== AUTO PERFECTION FUNCTIONS (ASLI) ==========
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

local function updateAutoPerfection(s)
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

-- ========== RECOVERY FISHING FUNCTION (FULL RESET) ==========
local function doRecoveryFishing()
    -- STEP 1: Force stop semua blatant yang aktif (instant)
    isSuperInstantRunning = false
    toggleState.blatantRunning = false
    c.d = false
    if m then pcall(task.cancel, m) end
    if n then pcall(task.cancel, n) end
    m, n = nil, nil
    
    -- STEP 2: Reset FishingController (instant)
    pcall(function()
        FishingController.RequestChargeFishingRod = oldCharge
    end)
    
    -- STEP 3: Cancel & cleanup di background (async)
    task.spawn(function()
        pcall(function()
            -- Multi cancel
            for i = 1, 3 do
                Remotes.RF_CancelFishing:InvokeServer()
            end
        end)
    end)
    
    -- STEP 4: Reset rod di background (async)
    task.spawn(function()
        pcall(function()
            Remotes.RE_EquipTool:FireServer(0)
            Remotes.RE_EquipTool:FireServer(1)
        end)
    end)
    
    -- STEP 5: Final cleanup di background (async)
    task.spawn(function()
        pcall(function()
            Remotes.RF_ChargeFishingRod:InvokeServer(0)
            Remotes.RF_CancelFishing:InvokeServer()
        end)
    end)
end

-- ========== SECTION 1: BLANTANT V1 ==========
blantantV1 = Tab3:Section({ 
    Title = "Blantant V1",
    Icon = "fish",
    TextTransparency = 0.05,
    TextXAlignment = "Left",
    TextSize = 17,
})

blantantV1:Toggle({
    Title = "Blatant V1",
    Value = false,
    Callback = function(value)
        if value then
            startSuperInstantFishing()
        else
            stopSuperInstantFishing()
        end
    end
})

blantantV1:Input({
    Title = "Reel Delay",
    Placeholder = "Delay (seconds)",
    Default = tostring(_G.ReelSuper),
    Callback = function(input)
        local num = tonumber(input)
        if num and num >= 0 then
            _G.ReelSuper = num
        end
    end
})

blantantV1:Input({
    Title = "Custom Complete Delay",
    Placeholder = "Delay (seconds)",
    Default = tostring(toggleState.completeDelays),
    Callback = function(input)
        local num = tonumber(input)
        if num and num > 0 then
            toggleState.completeDelays = num
        end
    end
})

blantantV1:Button({
    Title = "Recovery Fishing",
    Callback = function()
        doRecoveryFishing()
        WindUI:Notify({
            Title = "Recovery Fishing",
            Content = "Recovery completed!",
            Duration = 3,
            Icon = "check"
        })
    end
})

-- ========== SECTION 2: BLANTANT V2 ==========
blantantV2 = Tab3:Section({ 
    Title = "Blantant V2",
    Icon = "fish",
    TextTransparency = 0.05,
    TextXAlignment = "Left",
    TextSize = 17,
})

blantantV2:Toggle({
    Title = "Blantant V2",
    Value = c.d,
    Callback = function(z2)
        x(z2)
    end
})

blantantV2:Input({
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

blantantV2:Input({
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

blantantV2:Button({
    Title = "Recovery Fishing",
    Callback = function()
        doRecoveryFishing()
        WindUI:Notify({
            Title = "Recovery Fishing",
            Content = "Recovery completed!",
            Duration = 3,
            Icon = "check"
        })
    end
})

-- SECTION 3: AUTO PERFECTION
autoPerfectionSection = Tab3:Section({ 
    Title = "Auto Perfection",
    Icon = "settings",
    TextTransparency = 0.05,
    TextXAlignment = "Left",
    TextSize = 17,
})

autoPerfectionSection:Toggle({
    Title = "Auto Perfection",
    Value = ap,
    Callback = function(s)
        updateAutoPerfection(s)
    end
})

-- ==================== NOTIFICATION OVERRIDE ====================
task.spawn(function()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    local active = {}
    local HOLD_EXTRA_TIME = 5.5

    local function isFishNotif(frame)
        return frame:IsA("Frame") and frame.Name == "NewFrame"
    end

    local function lockFrame(frame)
        if active[frame] then return end
        active[frame] = true
        task.delay(HOLD_EXTRA_TIME, function()
            if frame and frame.Parent then frame:Destroy() end
            active[frame] = nil
        end)
    end

    SafeConnect("FishNotification", PlayerGui.DescendantAdded:Connect(function(frame)
        if not isFishNotif(frame) then return end
        task.wait()
        if not frame.Parent then return end
        
        lockFrame(frame)
        
        task.delay(0, function()
            if not frame or not frame.Parent then return end
            local clone = frame:Clone()
            clone.Parent = frame.Parent
            clone.Visible = true
            clone.ZIndex = frame.ZIndex + 1
            
            task.delay(HOLD_EXTRA_TIME, function()
                if clone then clone:Destroy() end
            end)
        end)
    end))
end)

-- ==================== ITEM SECTION ====================
local item = Tab3:Section({     
    Title = "Item",
    Icon = "list-collapse",
    TextXAlignment = "Left",
    TextSize = 17,    
})

-- RADAR
item:Toggle({
    Title = "Radar",
    Value = false,
    Callback = function(s)
        local RS, L = game.ReplicatedStorage, game.Lighting
        if require(RS.Packages.Replion).Client:GetReplion("Data")
        and require(RS.Packages.Net):RemoteFunction("UpdateFishingRadar"):InvokeServer(s) then

            local spr = require(RS.Packages.spr)
            local cc = L:FindFirstChildWhichIsA("ColorCorrectionEffect")

            require(RS.Shared.Soundbook).Sounds.RadarToggle:Play().PlaybackSpeed = 1 + math.random() * .3

            if cc then
                spr.stop(cc)
                local prof = (require(RS.Controllers.ClientTimeController)._getLightingProfile or require(RS.Controllers.ClientTimeController)._getLighting_profile)(require(RS.Controllers.ClientTimeController)) or {}
                local cfg = prof.ColorCorrection or {}

                cfg.Brightness = cfg.Brightness or .04
                cfg.TintColor = cfg.TintColor or Color3.new(1,1,1)

                cc.TintColor = s and Color3.fromRGB(42,226,118) or Color3.fromRGB(255,0,0)
                cc.Brightness = s and .4 or .2

                require(RS.Controllers.TextNotificationController):DeliverNotification{
                    Type="Text",
                    Text="Radar: "..(s and "Enabled" or "Disabled"),
                    TextColor=s and {R=9,G=255,B=0} or {R=255,G=0,B=0}
                }

                spr.target(cc,1,1,cfg)
            end

            spr.stop(L)
            L.ExposureCompensation = 1
            spr.target(L,1,2,{ExposureCompensation=0})
        end
    end
})

-- BYPASS OXYGEN
item:Toggle({
    Title = "Bypass Oxygen",
    Desc = "Inf Oxygen",
    Default = false,
    Callback = function(s)
        local net = game.ReplicatedStorage.Packages._Index["sleitnick_net@0.2.0"].net
        if s then net["RF/EquipOxygenTank"]:InvokeServer(105)
        else net["RF/UnequipOxygenTank"]:InvokeServer() end
    end
})

-- AUTO PLACE TOTEM (WINDUI VERSION)

local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local Net = RS:WaitForChild("Packages")
    :WaitForChild("_Index")
    :WaitForChild("sleitnick_net@0.2.0")
    :WaitForChild("net")

-- TOTEM DATA
local Totems = {
    ["Mutations Totem"] = "be68fbc3-a16d-4696-bc71-12f58446ad76",
    ["Luck Totem"]      = "de2e86b3-acf6-4ec8-ad33-10b35cd0d8a4"
}

-- STATE
local SelectedTotem = "Mutations Totem"
local Auto = false
local Running = false

-- SETTINGS
local DelayMinutes = 60 -- default 60 menit
local PLACE_DELAY = 0.25

-------------------------------------------------
-- NOTIFY HELPER
-------------------------------------------------
local function Notify(title, content)
    WindUI:Notify({
        Title = title,
        Content = content,
        Duration = 5
    })
end

-------------------------------------------------
-- INVENTORY CHECK (BY ID)
-------------------------------------------------
local function HasTotem(id)
    local backpack = LP:FindFirstChild("Backpack")
    if not backpack then return false end

    for _, tool in ipairs(backpack:GetChildren()) do
        if tool:GetAttribute("ItemId") == id then
            return true
        end

        local v = tool:FindFirstChild("ItemId")
        if v and v.Value == id then
            return true
        end
    end

    return false
end

-------------------------------------------------
-- EQUIP & PLACE
-------------------------------------------------
local function EquipTotem(id)
    Net:WaitForChild("RE/EquipItem"):FireServer(id, "Totems")
end

local function PlaceTotem()
    local char = LP.Character
    if not char then return end

    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        tool:Activate()
    end
end

-------------------------------------------------
-- MAIN LOOP
-------------------------------------------------
local function Run()
    if Running then return end
    Running = true

    task.spawn(function()
        while Auto do
            local id = Totems[SelectedTotem]
            if not id then
                Notify("Auto Totem", "Totem ID tidak valid")
                Auto = false
                break
            end

            -- INVENTORY CHECK
            if not HasTotem(id) then
                Notify(
                    "Auto Totem",
                    SelectedTotem .. " tidak ada / sudah habis di tas"
                )
                Auto = false
                break
            end

            pcall(function()
                EquipTotem(id)
                task.wait(PLACE_DELAY)
                PlaceTotem()

                Notify(
                    "Auto Totem",
                    SelectedTotem .. " berhasil di-place\nNext: " .. DelayMinutes .. " menit"
                )
            end)

            -- DELAY (CANCELABLE)
            local waitSeconds = DelayMinutes * 60
            for i = 1, waitSeconds do
                if not Auto then break end
                task.wait(1)
            end
        end

        Running = false
    end)
end

-------------------------------------------------
-- UI
-------------------------------------------------
item:Dropdown({
    Title = "Select Totem",
    Values = {"Mutations Totem", "Luck Totem"},
    Default = SelectedTotem,
    Callback = function(v)
        SelectedTotem = v
    end
})

item:Input({
    Title = "Totem Delay (Minutes)",
    Placeholder = "Contoh: 60",
    Value = tostring(DelayMinutes), -- ✅ FIX
    Callback = function(v)
        local num = tonumber(v)
        if num and num > 0 then
            DelayMinutes = math.floor(num)
            Notify("Auto Totem", "Delay diset ke " .. DelayMinutes .. " menit")
        else
            Notify("Auto Totem", "Input delay tidak valid")
        end
    end
})


item:Toggle({
    Title = "Auto Place Totem",
    Desc = "Auto place totem dengan delay & inventory check",
    Default = false,
    Callback = function(v)
        Auto = v
        if Auto then
            Notify("Auto Totem", "Auto Place Totem diaktifkan")
            Run()
        else
            Notify("Auto Totem", "Auto Place Totem dimatikan")
        end
    end
})

-- ==================== TAB 4: AUTO ====================
local Tab4 = Window:Tab({
    Title = "Auto",
    Icon = "circle-ellipsis"
})

-- AUTO SELL
local sell = Tab4:Section({
    Title = "Sell",
    Icon = "coins",
    TextXAlignment = "Left",
    TextSize = 17
})

local SellAllRF = RS.Packages._Index["sleitnick_net@0.2.0"].net["RF/SellAllItems"]
local AutoSell = false
local SellAt = 100
local Selling = false
local SellMinute = 5
local LastSell = 0

-- Item utility
local ItemUtility, DataService
task.spawn(function()
    ItemUtility = require(RS.Shared.ItemUtility)
    DataService = require(RS.Packages.Replion).Client:WaitReplion("Data")
end)

local function getFishCount()
    if not (DataService and ItemUtility) then return 0 end
    local items = DataService:GetExpect({ "Inventory", "Items" })
    local count = 0
    for _, v in pairs(items) do
        local itemData = ItemUtility.GetItemDataFromItemType("Items", v.Id)
        if itemData and itemData.Data and itemData.Data.Type == "Fish" then
            count += 1
        end
    end
    return count
end

sell:Input({
    Title = "Auto Sell When Fish ≥",
    Placeholder = "contoh: 100",
    Value = tostring(SellAt),
    Callback = function(text)
        local n = tonumber(text)
        if n and n > 0 then SellAt = math.floor(n) end
    end
})

sell:Toggle({
    Title = "Auto Sell All Fish",
    Value = false,
    Icon = "dollar-sign",
    Callback = function(state)
        AutoSell = state
    end
})

sell:Input({
    Title = "Auto Sell Interval (Minute)",
    Placeholder = "contoh: 5",
    Value = tostring(SellMinute),
    Callback = function(text)
        local n = tonumber(text)
        if n and n > 0 then SellMinute = math.floor(n) end
    end
})

sell:Toggle({
    Title = "Auto Sell All (By Minute)",
    Value = false,
    Icon = "clock",
    Callback = function(state)
        AutoSell = state
        if state then LastSell = os.clock() end
    end
})

-- Combined Auto Sell Heartbeat
SafeConnect("AutoSellHeartbeat", game:GetService("RunService").Heartbeat:Connect(function()
    if not AutoSell or Selling then return end
    
    if getFishCount() >= SellAt then
        Selling = true
        pcall(function() SellAllRF:InvokeServer() end)
        task.delay(1.5, function() Selling = false end)
    end
    
    if os.clock() - LastSell >= (SellMinute * 60) then
        if getFishCount() > 0 then
            Selling = true
            pcall(function() SellAllRF:InvokeServer() end)
            LastSell = os.clock()
            task.delay(1.5, function() Selling = false end)
        else
            LastSell = os.clock()
        end
    end
end))

-- ==================== EVENT SECTION ====================
local event = Tab4:Section({
    Title = "Event",
    Icon = "snowflake",
    TextXAlignment = "Left",
    TextSize = 17
})

-- AUTO CLAIM CHRISTMAS
local NPCs = {
    "Alien Merchant","Billy Bob","Seth","Joe","Aura Kid","Boat Expert",
    "Scott","Ron","Jeffery","McBoatson","Scientist","Silly Fisherman","Tim","Santa"
}

local auto = false
event:Toggle({
    Title = "Auto Claim",
    Desc = "Auto Claim Christmas Presents",
    Value = false,
    Callback = function(s)
        auto = s
        SafeCancel("AutoClaim")
        
        if s then
            Performance.Tasks["AutoClaim"] = task.spawn(function()
                while auto do
                    for i = 1, #NPCs do
                        if not auto then break end
                        pcall(RS.Packages._Index["sleitnick_net@0.2.0"].net["RF/SpecialDialogueEvent"].InvokeServer, 
                              RS.Packages._Index["sleitnick_net@0.2.0"].net["RF/SpecialDialogueEvent"], NPCs[i], "ChristmasPresents")
                        task.wait(0.15)
                    end
                    task.wait(2)
                end
            end)
        end
    end
})

-- AUTO PRESENT FACTORY
local Net = RS:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
local Auto = false
local Running = false

local function RunSequence()
    if Running then return end
    Running = true

    Performance.Tasks["PresentFactory"] = task.spawn(function()
        while Auto do
            Net:WaitForChild("RE/EquipItem"):FireServer("0e98569c-edd0-4d75-bab9-7788a9ea0a4f", "Gears")
            task.wait(0.2)
            Net:WaitForChild("RE/EquipToolFromHotbar"):FireServer(5)
            task.wait(0.2)
            Net:WaitForChild("RF/RedeemGift"):InvokeServer()
            task.wait(5)
        end
        Running = false
    end)
end

event:Toggle({
    Title = "Auto Present Factory",
    Desc = "Auto Gift Present To Factory",
    Default = false,
    Callback = function(v)
        Auto = v
        if Auto then RunSequence() end
    end
})

-- ==================== TAB 5: WEBHOOK ====================
local Tab0 = Window:Tab({
    Title = "Webhook",
    Icon = "star",
})

local webhook = Tab0:Section({ 
    Title = "Webhook Fish Caught",
    Icon = "webhook",
    TextXAlignment = "Left",
    TextSize = 17 
})

local httpRequest = syn and syn.request or http and http.request or http_request or (fluxus and fluxus.request) or request

-- Fish Database
local fishDB = {}
local rarityList = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "SECRET" }
local tierToRarity = {
    [1] = "Common", [2] = "Uncommon", [3] = "Rare", [4] = "Epic",
    [5] = "Legendary", [6] = "Mythic", [7] = "SECRET"
}
local knownFishUUIDs = {}

-- Load ItemUtility and DataService for webhook
local ItemUtility, Replion, DataService
task.spawn(function()
    ItemUtility = require(ReplicatedStorage.Shared.ItemUtility)
    Replion = require(ReplicatedStorage.Packages.Replion)
    DataService = Replion.Client:WaitReplion("Data")
end)

function buildFishDatabase()
    local itemsContainer = RS:WaitForChild("Items")
    if not itemsContainer then return end

    for _, itemModule in ipairs(itemsContainer:GetChildren()) do
        local success, itemData = pcall(require, itemModule)
        if success and type(itemData) == "table" and itemData.Data and itemData.Data.Type == "Fish" then
            local data = itemData.Data
            if data.Id and data.Name then
                fishDB[data.Id] = {
                    Name = data.Name,
                    Tier = data.Tier,
                    Icon = data.Icon,
                    SellPrice = itemData.SellPrice
                }
            end
        end
    end
end

function getInventoryFish()
    if not (DataService and ItemUtility) then return {} end
    local inventoryItems = DataService:GetExpect({ "Inventory", "Items" })
    local fishes = {}
    for _, v in pairs(inventoryItems) do
        local itemData = ItemUtility.GetItemDataFromItemType("Items", v.Id)
        if itemData and itemData.Data.Type == "Fish" then
            table.insert(fishes, { Id = v.Id, UUID = v.UUID, Metadata = v.Metadata })
        end
    end
    return fishes
end

function getPlayerCoins()
    if not DataService then return "N/A" end
    local success, coins = pcall(function() return DataService:Get("Coins") end)
    if success and coins then
        return string.format("%d", coins):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
    end
    return "N/A"
end

function getThumbnailURL(assetString)
    local assetId = assetString:match("rbxassetid://(%d+)")
    if not assetId then return nil end
    local api = string.format(
        "https://thumbnails.roblox.com/v1/assets?assetIds=%s&type=Asset&size=420x420&format=Png",
        assetId
    )
    local success, response = pcall(function()
        return game:GetService("HttpService"):JSONDecode(game:HttpGet(api))
    end)
    return success and response and response.data and response.data[1] and response.data[1].imageUrl
end

function sendTestWebhook()
    if not httpRequest or not _G.WebhookURL or not _G.WebhookURL:match("discord.com/api/webhooks") then
        WindUI:Notify({ Title = "Error", Content = "Webhook URL Empty" })
        return
    end

    local payload = {
        username = "Victoria Hub Webhook",
        avatar_url = "https://cdn.discordapp.com/attachments/1358728774098882653/1459169498383909049/ai_repair_20260106014107493.png?ex=69624cfe&is=6960fb7e&hm=7ae73d692bb21a5dabee8b09b0d8447b90c5c2a29612b313ebeb9c3c87ae94e4&",
        embeds = {{
            title = "Test Webhook Connected",
            description = "Webhook connection successful!",
            color = 0xFFFFFF
        }}
    }

    task.spawn(function()
        pcall(function()
            httpRequest({
                Url = _G.WebhookURL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = game:GetService("HttpService"):JSONEncode(payload)
            })
        end)
    end)
end

function sendNewFishWebhook(newlyCaughtFish)
    if not httpRequest or not _G.WebhookURL or not _G.WebhookURL:match("discord.com/api/webhooks") then return end

    local newFishDetails = fishDB[newlyCaughtFish.Id]
    if not newFishDetails then return end

    local newFishRarity = tierToRarity[newFishDetails.Tier] or "Unknown"
    if #_G.WebhookRarities > 0 and not table.find(_G.WebhookRarities, newFishRarity) then return end

    local fishWeight = (newlyCaughtFish.Metadata and newlyCaughtFish.Metadata.Weight and string.format("%.2f Kg", newlyCaughtFish.Metadata.Weight)) or "N/A"
    local mutation   = (newlyCaughtFish.Metadata and newlyCaughtFish.Metadata.VariantId and tostring(newlyCaughtFish.Metadata.VariantId)) or "None"
    local sellPrice  = (newFishDetails.SellPrice and ("$"..string.format("%d", newFishDetails.SellPrice):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "").." Coins")) or "N/A"
    local currentCoins = getPlayerCoins()

    local totalFishInInventory = #getInventoryFish()
    local backpackInfo = string.format("%d/4500", totalFishInInventory)
    local playerName = game.Players.LocalPlayer.Name

    local payload = {
        content = nil,
        embeds = {{
            title = "Victoria Hub Webhook Fish caught!",
            description = string.format("Congrats! **%s** You obtained new **%s** here for full detail fish :", playerName, newFishRarity),
            url = "https://discord.gg/victoriahub",
            color = 65535,
            fields = {
                {
                    name = "Fish Details",
                    value = "```" ..
                        "Name Fish        : " .. newFishDetails.Name .. "\n" ..
                        "Rarity           : " .. newFishRarity .. "\n" ..
                        "Weight           : " .. fishWeight .. "\n" ..
                        "Mutation         : " .. mutation .. "\n" ..
                        "Sell Price       : " .. sellPrice .. "\n" ..
                        "Backpack Counter : " .. backpackInfo .. "\n" ..
                        "Current Coin     : " .. currentCoins .. "\n" ..
                        "```"
                }
            },
            footer = {
                text = "Victoria Hub Webhook",
                icon_url = "https://cdn.discordapp.com/attachments/1358728774098882653/1459169498383909049/ai_repair_20260106014107493.png?ex=69624cfe&is=6960fb7e&hm=7ae73d692bb21a5dabee8b09b0d8447b90c5c2a29612b313ebeb9c3c87ae94e4&"
            },
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z"),
            thumbnail = { url = getThumbnailURL(newFishDetails.Icon) }
        }},
        username = "Victoria Hub Webhook",
        avatar_url = "https://cdn.discordapp.com/attachments/1358728774098882653/1459169498383909049/ai_repair_20260106014107493.png?ex=69624cfe&is=6960fb7e&hm=7ae73d692bb21a5dabee8b09b0d8447b90c5c2a29612b313ebeb9c3c87ae94e4&",
        attachments = {}
    }

    task.spawn(function()
        pcall(function()
            httpRequest({
                Url = _G.WebhookURL,
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = game:GetService("HttpService"):JSONEncode(payload)
            })
        end)
    end)
end

-- Webhook UI
webhook:Input({
    Title = "URL Webhook",
    Placeholder = "Paste your Discord Webhook URL here",
    Value = _G.WebhookURL or "",
    Callback = function(text) _G.WebhookURL = text end
})

webhook:Dropdown({
    Title = "Rarity Filter",
    Values = rarityList,
    Multi = true,
    AllowNone = true,
    Value = _G.WebhookRarities or {},
    Callback = function(selected_options) _G.WebhookRarities = selected_options end
})

webhook:Toggle({
    Title = "Send Webhook",
    Value = _G.DetectNewFishActive or false,
    Callback = function(state) _G.DetectNewFishActive = state end
})

webhook:Button({
    Title = "Test Webhook",
    Callback = sendTestWebhook
})

-- Initialize fish detection
task.spawn(function()
    buildFishDatabase()
    
    local initialFishList = getInventoryFish()
    for _, fish in ipairs(initialFishList) do
        if fish and fish.UUID then knownFishUUIDs[fish.UUID] = true end
    end
    
    Performance.Tasks["FishDetection"] = task.spawn(function()
        while true do
            task.wait(3)
            if _G.DetectNewFishActive then
                local currentFishList = getInventoryFish()
                for _, fish in ipairs(currentFishList) do
                    if fish and fish.UUID and not knownFishUUIDs[fish.UUID] then
                        knownFishUUIDs[fish.UUID] = true
                        sendNewFishWebhook(fish)
                    end
                end
            end
        end
    end)
end)

-- ==================== TAB 6: SHOP ====================
local Tab5 = Window:Tab({
    Title = "Shop",
    Icon = "shopping-cart",
})

-- BUY ROD
local rod = Tab5:Section({ 
    Title = "Buy Rod",
    Icon = "shrimp",
    TextXAlignment = "Left",
    TextSize = 17,
})

local R = {
    ["Luck Rod"] = 79, ["Carbon Rod"] = 76, ["Grass Rod"] = 85,
    ["Demascus Rod"] = 77, ["Ice Rod"] = 78, ["Lucky Rod"] = 4,
    ["Midnight Rod"] = 80, ["Steampunk Rod"] = 6, ["Chrome Rod"] = 7,
    ["Astral Rod"] = 5, ["Ares Rod"] = 126, ["Angler Rod"] = 168,
    ["Bamboo Rod"] = 258
}

local N = {
    "Luck Rod (350 Coins)", "Carbon Rod (900 Coins)", "Grass Rod (1.5k Coins)",
    "Demascus Rod (3k Coins)", "Ice Rod (5k Coins)", "Lucky Rod (15k Coins)",
    "Midnight Rod (50k Coins)", "Steampunk Rod (215k Coins)", "Chrome Rod (437k Coins)",
    "Astral Rod (1M Coins)", "Ares Rod (3M Coins)", "Angler Rod (8M Coins)",
    "Bamboo Rod (12M Coins)"
}

local M = {}
for _, display in ipairs(N) do
    local name = display:match("^(.-) %(")
    if name then M[display] = name end
end

local S = N[1]
rod:Dropdown({
    Title = "Select Rod",
    SearchBarEnabled = true,
    Values = N,
    Value = S,
    Callback = function(v) S = v end
})

rod:Button({
    Title = "Buy Rod",
    Callback = function()
        local k = M[S]
        if k and R[k] then
            pcall(function() RS.Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseFishingRod"]:InvokeServer(R[k]) end)
        end
    end
})

-- BUY BAIT
local bait = Tab5:Section({
    Title = "Buy Baits",
    Icon = "compass",
    TextXAlignment = "Left",
    TextSize = 17,
})

local B = {
    ["Luck Bait"] = 2, ["Midnight Bait"] = 3, ["Nature Bait"] = 10,
    ["Chroma Bait"] = 6, ["Dark Matter Bait"] = 8, ["Corrupt Bait"] = 15,
    ["Aether Bait"] = 16, ["Floral Bait"] = 20
}

local baitNames = {}
for name, _ in pairs(B) do
    table.insert(baitNames, name .. " (Price varies)")
end

local selectedBait = baitNames[1]
bait:Dropdown({
    Title = "Select Bait",
    SearchBarEnabled = true,
    Values = baitNames,
    Value = selectedBait,
    Callback = function(v) selectedBait = v end
})

bait:Button({
    Title = "Buy Bait",
    Callback = function()
        local name = selectedBait:match("^(.-) %(")
        if name and B[name] then
            pcall(function() RS.Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseBait"]:InvokeServer(B[name]) end)
        end
    end
})

-- BUY WEATHER EVENT
local weather = Tab5:Section({
    Title = "Buy Weather Event",
    Icon = "cloud-drizzle",
    TextXAlignment = "Left",
    TextSize = 17,
})

local weatherKeyMap = {
    ["Wind (10k Coins)"] = "Wind",
    ["Snow (15k Coins)"] = "Snow",
    ["Cloudy (20k Coins)"] = "Cloudy",
    ["Storm (35k Coins)"] = "Storm",
    ["Radiant (50k Coins)"] = "Radiant",
    ["Shark Hunt (300k Coins)"] = "Shark Hunt"
}

local weatherNames = {
    "Wind (10k Coins)", "Snow (15k Coins)", "Cloudy (20k Coins)",
    "Storm (35k Coins)", "Radiant (50k Coins)", "Shark Hunt (300k Coins)"
}

local selectedWeathers = {}
local autoBuyEnabled = false
local buyDelay = 540

weather:Dropdown({
    Title = "Select Weather",
    Values = weatherNames,
    Multi = true,
    Callback = function(values) selectedWeathers = values end
})

weather:Input({
    Title = "Buy Delay (minutes)",
    Desc = "Default 9 Minutes",
    Placeholder = "9",
    Callback = function(input)
        local num = tonumber(input)
        if num and num > 0 then
            buyDelay = num * 60
            WindUI:Notify({
                Title = "Delay Updated",
                Content = "Pembelian setiap " .. num .. " menit",
                Duration = 2
            })
        end
    end
})

weather:Toggle({
    Title = "Buy Weather",
    Value = false,
    Callback = function(state)
        autoBuyEnabled = state
        SafeCancel("AutoBuyWeather")
        
        if state then
            WindUI:Notify({
                Title = "Auto Buy",
                Content = "Enabled (Beli setiap " .. (buyDelay / 60) .. " menit)",
                Duration = 2
            })
            
            Performance.Tasks["AutoBuyWeather"] = task.spawn(function()
                while autoBuyEnabled do
                    for _, displayName in ipairs(selectedWeathers) do
                        local key = weatherKeyMap[displayName]
                        if key then
                            pcall(function()
                                RS.Packages._Index["sleitnick_net@0.2.0"].net["RF/PurchaseWeatherEvent"]:InvokeServer(key)
                            end)
                        end
                    end
                    task.wait(buyDelay)
                end
            end)
        end
    end
})

-- ==================== TAB 7: TELEPORT ====================
local Tab6 = Window:Tab({
    Title = "Teleport",
    Icon = "map-pin",
})

-- ISLAND TELEPORT
local island = Tab6:Section({ 
    Title = "Island",
    Icon = "tree-palm",
    TextXAlignment = "Left",
    TextSize = 17,
})

local IslandLocations = {
    ["Admin Event"] = Vector3.new(-1981, -442, 7428),
    ["Ancient Jungle"] = Vector3.new(1518, 1, -186),
    ["Coral Refs"] = Vector3.new(-2855, 47, 1996),
    ["Crater Island"] = Vector3.new(997, 1, 5012),
    ["Enchant Room"] = Vector3.new(3221, -1303, 1406),
    ["Enchant Room 2"] = Vector3.new(1480, 126, -585),
    ["Esoteric Island"] = Vector3.new(1990, 5, 1398),
    ["Fisherman Island"] = Vector3.new(-64, 3, 2767),
    ["Kohana Volcano"] = Vector3.new(-545.302429, 17.1266193, 118.870537),
    ["Konoha"] = Vector3.new(-603, 3, 719),
    ["Lost Isle"] = Vector3.new(-3643, 1, -1061),
    ["Sacred Temple"] = Vector3.new(1498, -23, -644),
    ["Sysyphus Statue"] = Vector3.new(-3783.26807, -135.073914, -949.946289),
    ["Treasure Room"] = Vector3.new(-3600, -267, -1575),
    ["Tropical Grove"] = Vector3.new(-2091, 6, 3703),
    ["Underground Cellar"] = Vector3.new(2135, -93, -701),
    ["Weather Machine"] = Vector3.new(-1508, 6, 1895),
    ["Ancient Ruin"] = Vector3.new(6051, -541, 4414),
    ["Christmas Island"] = Vector3.new(673, 5, 1568),
}

local islandNames = {}
for name in pairs(IslandLocations) do table.insert(islandNames, name) end
table.sort(islandNames)

local SelectedIsland = islandNames[1]
island:Dropdown({
    Title = "Select Island",
    SearchBarEnabled = true,
    Values = islandNames,
    Value = SelectedIsland,
    Callback = function(Value) SelectedIsland = Value end
})

island:Button({
    Title = "Teleport to Island",
    Callback = function()
        if SelectedIsland and IslandLocations[SelectedIsland] and _G.HRP then
            _G.HRP.CFrame = CFrame.new(IslandLocations[SelectedIsland])
        end
    end
})

-- FISHING SPOT TELEPORT
local spot = Tab6:Section({ 
    Title = "Fishing Spot",
    Icon = "spotlight",
    TextXAlignment = "Left",
    TextSize = 17,
})

local FishingLocations = {
    ["Levers 1"] = Vector3.new(1475,4,-847),
    ["Levers 2"] = Vector3.new(882,5,-321),
    ["levers 3"] = Vector3.new(1425,6,126),
    ["levers 4"] = Vector3.new(1837,4,-309),
    ["Sysyphus Statue"] = Vector3.new(-3710, -97, -952),
    ["King Jelly Spot (For quest elemental)"] = Vector3.new(1473.60, 3.58, -328.23),
    ["El Shark Gran Maja Spot"] = Vector3.new(1526, 4, -629),
    ["Ancient Lochness"] = Vector3.new(6078, -586, 4629),
    ["Christmas Island"] = Vector3.new(918, 2, 1235),
    ["Christmas Cave"] = Vector3.new(606, -581, 8887),
}

local fishingNames = {}
for name in pairs(FishingLocations) do table.insert(fishingNames, name) end
table.sort(fishingNames)

local SelectedFishing = fishingNames[1]
spot:Dropdown({
    Title = "Select Spot",
    SearchBarEnabled = true,
    Values = fishingNames,
    Value = SelectedFishing,
    Callback = function(Value) SelectedFishing = Value end
})

spot:Button({
    Title = "Teleport to Fishing Spot",
    Callback = function()
        if SelectedFishing and FishingLocations[SelectedFishing] and _G.HRP then
            _G.HRP.CFrame = CFrame.new(FishingLocations[SelectedFishing])
        end
    end
})

-- PLAYER TELEPORT
local tpplayer = Tab6:Section({
    Title = "Player",
    Icon = "user-search",
    TextXAlignment = "Left",
    TextSize = 17,
})

local function getPlayerList()
    local t = {}
    for _,p in ipairs(game:GetService("Players"):GetPlayers()) do
        if p ~= Player then table.insert(t, p.Name) end
    end
    return t
end

local playerList = getPlayerList()
local selectedPlayer = playerList[1] or ""

tpplayer:Dropdown({
    Title = "Teleport Target",
    Values = playerList,
    Value = selectedPlayer,
    Callback = function(v) selectedPlayer = v end
})

tpplayer:Button({
    Title = "Teleport to Player",
    Callback = function()
        local target = game:GetService("Players"):FindFirstChild(selectedPlayer)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and _G.HRP then
            _G.HRP.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
        end
    end
})

tpplayer:Button({
    Title = "Refresh Player List",
    Callback = function()
        playerList = getPlayerList()
        selectedPlayer = playerList[1] or ""
    end
})

events = Tab6:Section({
    Title = "Event Teleporter",
    Icon = "calendar",
    TextXAlignment = "Left",
    TextSize = 17,
})

-- SERVICES (SATU TABLE)
local S = setmetatable({}, {
    __index = function(_, k)
        return game:GetService(k)
    end
})

-- STATE
local ST = {
    player = S.Players.LocalPlayer,
    char = nil,
    hrp = nil,

    megRadius = 150,
    autoTP = false,
    autoFloat = false,
    selectedEvents = {},
    lastTP = nil,
    tpCooldown = 0.3,
    floatOffset = 6
}

-- INIT CHARACTER
local function bindChar(c)
    ST.char = c
    task.wait(1)
    ST.hrp = c:WaitForChild("HumanoidRootPart")
end

bindChar(ST.player.Character or ST.player.CharacterAdded:Wait())
ST.player.CharacterAdded:Connect(bindChar)

-- EVENT DATA (TETAP)
local eventData = {
    ["Worm Hunt"] = {
        TargetName = "Model",
        Locations = {
            Vector3.new(2190.85, -1.4, 97.575),
            Vector3.new(-2450.679, -1.4, 139.731),
            Vector3.new(-267.479, -1.4, 5188.531),
            Vector3.new(-327, -1.4, 2422)
        },
        PlatformY = 106,
        Priority = 1
    },

    ["Megalodon Hunt"] = {
        TargetName = "Megalodon Hunt",
        Locations = {
            Vector3.new(-1076.3, -1.4, 1676.2),
            Vector3.new(-1191.8, -1.4, 3597.3),
            Vector3.new(412.7, -1.4, 4134.4)
        },
        PlatformY = 106,
        Priority = 2
    },

    ["Ghost Shark Hunt"] = {
        TargetName = "Ghost Shark Hunt",
        Locations = {
            Vector3.new(489.559, -1.35, 25.406),
            Vector3.new(-1358.216, -1.35, 4100.556),
            Vector3.new(627.859, -1.35, 3798.081)
        },
        PlatformY = 106,
        Priority = 3
    },

    ["Shark Hunt"] = {
        TargetName = "Shark Hunt",
        Locations = {
            Vector3.new(1.65, -1.35, 2095.725),
            Vector3.new(1369.95, -1.35, 930.125),
            Vector3.new(-1585.5, -1.35, 1242.875),
            Vector3.new(-1896.8, -1.35, 2634.375)
        },
        PlatformY = 106,
        Priority = 4
    }
}

-- EVENT NAMES
local eventNames = {}
for n in pairs(eventData) do
    eventNames[#eventNames+1] = n
end

-- FORCE TP
local function forceTP(pos)
    if not ST.lastTP or (ST.lastTP - pos).Magnitude > 5 then
        ST.lastTP = pos
        for _ = 1, 2 do
            ST.hrp.CFrame = CFrame.new(pos.X, pos.Y + 3, pos.Z)
            ST.hrp.AssemblyLinearVelocity = Vector3.zero
            ST.hrp.Velocity = Vector3.zero
            task.wait(0.02)
        end
    end
end

-- MAIN TP LOOP
local function runEventTP()
    while ST.autoTP do
        local list = {}

        for _, name in ipairs(ST.selectedEvents) do
            if eventData[name] then
                list[#list+1] = eventData[name]
            end
        end

        table.sort(list, function(a, b)
            return a.Priority < b.Priority
        end)

        for _, cfg in ipairs(list) do
            local found

            if cfg.TargetName == "Model" then
                local rings = S.Workspace:FindFirstChild("!!! MENU RINGS")
                if rings then
                    for _, p in ipairs(rings:GetChildren()) do
                        if p.Name == "Props" then
                            local m = p:FindFirstChild("Model")
                            if m and m.PrimaryPart then
                                for _, loc in ipairs(cfg.Locations) do
                                    if (m.PrimaryPart.Position - loc).Magnitude <= ST.megRadius then
                                        found = m.PrimaryPart.Position
                                        break
                                    end
                                end
                            end
                        end
                        if found then break end
                    end
                end
            else
                for _, loc in ipairs(cfg.Locations) do
                    for _, d in ipairs(S.Workspace:GetDescendants()) do
                        if d.Name == cfg.TargetName then
                            local pos = d:IsA("BasePart") and d.Position or (d.PrimaryPart and d.PrimaryPart.Position)
                            if pos and (pos - loc).Magnitude <= ST.megRadius then
                                found = pos
                                break
                            end
                        end
                    end
                    if found then break end
                end
            end

            if found then
                forceTP(found)
            end
        end

        task.wait(ST.tpCooldown)
    end
end

-- FLOAT
S.RunService.RenderStepped:Connect(function()
    if ST.autoFloat and ST.hrp then
        local pos = ST.hrp.Position
        local targetY = S.Workspace.Terrain.WaterLevel + ST.floatOffset
        if pos.Y < targetY then
            ST.hrp.CFrame = CFrame.new(pos.X, targetY, pos.Z)
            ST.hrp.AssemblyLinearVelocity = Vector3.zero
        end
    end
end)

Tab6:Dropdown({
    Title = "Select Events",
    Values = eventNames,
    Multi = true,
    AllowNone = true,
    Callback = function(v)
        ST.selectedEvents = v
    end
})

Tab6:Toggle({
    Title = "Auto Event",
    Value = false,
    Callback = function(state)
        ST.autoTP = state
        ST.autoFloat = state
        ST.lastTP = nil
        if state then
            task.defer(runEventTP)
        end
    end
})

-- ==================== TAB 8: SETTINGS ====================
local Tab7 = Window:Tab({
    Title = "Settings",
    Icon = "settings",
})

local playerSettings = Tab7:Section({ 
    Title = "Player Featured",
    Icon = "play",
    TextXAlignment = "Left",
    TextSize = 17,
})

-- Ping Display (Optimized)
local PingEnabled = true
local Frame, Text
local lastPingUpdate = 0
local pingUpdateInterval = 0.5

local function createPingDisplay()
    local CG = game:GetService("CoreGui")
    Gui = Instance.new("ScreenGui")
    Gui.Name = "PerformanceHUD"
    Gui.Parent = CG
    Gui.ResetOnSpawn = false
    Gui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    Frame = Instance.new("Frame", Gui)
    Frame.Size = UDim2.fromOffset(205,34)
    Frame.Position = UDim2.fromScale(0.5,0.05)
    Frame.AnchorPoint = Vector2.new(0.5,0)
    Frame.BackgroundColor3 = Color3.fromRGB(0,0,0)
    Frame.BackgroundTransparency = 0.7
    Frame.BorderSizePixel = 0
    Frame.Visible = PingEnabled
    Frame.ZIndex = 1000
    Instance.new("UICorner",Frame).CornerRadius = UDim.new(0,24)

    local Stroke = Instance.new("UIStroke", Frame)
    Stroke.Thickness = 3
    Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    Stroke.ZIndex = 1001

    local Gradient = Instance.new("UIGradient", Stroke)
    Gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0,255,255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180,255,255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
    }

    Text = Instance.new("TextLabel", Frame)
    Text.Size = UDim2.new(1,-30,1,0)
    Text.Position = UDim2.fromOffset(30,0)
    Text.BackgroundTransparency = 1
    Text.Font = Enum.Font.GothamBold
    Text.TextSize = 10
    Text.TextXAlignment = Enum.TextXAlignment.Left
    Text.TextYAlignment = Enum.TextYAlignment.Center
    Text.TextColor3 = Color3.fromRGB(230,230,230)
    Text.ZIndex = 1002
    
    return Frame
end

if createPingDisplay() then
    SafeConnect("PingUpdate", game:GetService("RunService").RenderStepped:Connect(function()
        if not PingEnabled then return end
        
        local now = tick()
        if now - lastPingUpdate < pingUpdateInterval then return end
        lastPingUpdate = now
        
        local ping = math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
        local fps = math.floor(1 / game:GetService("RunService").RenderStepped:Wait())
        
        Text.Text = string.format("PING: %d ms | FPS: %d", ping, math.min(fps, 999))
    end))
end

playerSettings:Toggle({
    Title = "Ping Display",
    Default = false,
    Callback = function(v)
        PingEnabled = v
        if Frame then Frame.Visible = v end
    end
})

-- HIDE NAME & LEVEL
local P = Player
local C = P.Character or P.CharacterAdded:Wait()
local O = C:WaitForChild("HumanoidRootPart"):WaitForChild("Overhead")
local H = O.Content.Header
local L = O.LevelContainer.Label

local D = {h = H.Text, l = L.Text, ch = H.Text, cl = L.Text, on = false}

playerSettings:Input({
    Title = "Hide Name",
    Placeholder = "Input Name",
    Default = D.h,
    Callback = function(v)
        D.ch = v
        if D.on then H.Text = v end
    end
})

playerSettings:Input({
    Title = "Hide Level",
    Placeholder = "Input Level",
    Default = D.l,
    Callback = function(v)
        D.cl = v
        if D.on then L.Text = v end
    end
})

playerSettings:Toggle({
    Title = "Hide Name & Level (Custom)",
    Default = false,
    Callback = function(v)
        D.on = v
        if v then
            H.Text = D.ch
            L.Text = D.cl
        else
            H.Text = D.h
            L.Text = D.l
        end
    end
})

-- DEFAULT HIDE
local HN, HL = "discord.gg/victoriahub", "Lv. ???"
local S = {on = false, ui = nil}

local function setup(c)
    local o = c:WaitForChild("HumanoidRootPart"):WaitForChild("Overhead")
    local h = o.Content.Header
    local l = o.LevelContainer.Label
    return {h = h, l = l, dh = h.Text, dl = l.Text}
end

S.ui = setup(P.Character or P.CharacterAdded:Wait())

SafeConnect("CharAddedHide", P.CharacterAdded:Connect(function(c)
    task.wait(0.2)
    S.ui = setup(c)
    if S.on then
        S.ui.h.Text = HN
        S.ui.l.Text = HL
    end
end))

playerSettings:Toggle({
    Title = "Hide Name & Level (Default)",
    Default = false,
    Callback = function(v)
        S.on = v
        if not S.ui then return end
        if v then
            S.ui.h.Text = HN
            S.ui.l.Text = HL
        else
            S.ui.h.Text = S.ui.dh
            S.ui.l.Text = S.ui.dl
        end
    end
})

-- INFINITE ZOOM
local Z = {P.CameraMaxZoomDistance, P.CameraMinZoomDistance}

playerSettings:Toggle({
    Title="Infinite Zoom",
    Desc="infinite zoom to take a photo",
    Value=false,
    Callback=function(s)
        if s then
            P.CameraMaxZoomDistance=math.huge
            P.CameraMinZoomDistance=.5
        else
            P.CameraMaxZoomDistance=Z[1] or 128
            P.CameraMinZoomDistance=Z[2] or .5
        end
    end
})

-- AUTO RECONNECT
local AutoReconnect = false
local VIM = game:GetService("VirtualInputManager")

local function click(btn)
    local pos = btn.AbsolutePosition + btn.AbsoluteSize / 2
    VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 0)
    task.wait(0.05)
    VIM:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 0)
end

SafeConnect("AutoReconnect", game:GetService("CoreGui"):WaitForChild("RobloxPromptGui")
    :WaitForChild("promptOverlay")
    .ChildAdded:Connect(function(v)
        if not AutoReconnect then return end
        if v.Name ~= "ErrorPrompt" then return end

        task.wait(0.3)
        local btn = v:FindFirstChild("ReconnectButton", true)
        if btn then click(btn) end
    end))

playerSettings:Toggle({
    Title = "Auto Reconnect",
    Desc = "Auto click Reconnect",
    Default = false,
    Callback = function(v) AutoReconnect = v end
})

-- ANTI STAFF
local ON = true
local BL = {
    [75974130]=1,[40397833]=1,[187190686]=1,[33372493]=1,[889918695]=1,
    [33679472]=1,[30944240]=1,[25050357]=1,[8462585751]=1,[8811129148]=1,
    [192821024]=1,[4509801805]=1,[124505170]=1,[108397209]=1
}

playerSettings:Toggle({
    Title="Anti Staff",
    Desc="Auto serverhop if there is staff",
    Value=true,
    Callback=function(s) ON=s end
})

local function hop()
    task.wait(6)
    local d = game.HttpService:JSONDecode(
        game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")
    ).data
    for _,v in ipairs(d) do
        if v.playing < v.maxPlayers and v.id ~= game.JobId then
            game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, v.id, Player)
            break
        end
    end
end

SafeConnect("PlayerAddedAntiStaff", game:GetService("Players").PlayerAdded:Connect(function(plr)
    if ON and plr~=Player and BL[plr.UserId] then
        WindUI:Notify({
            Title="Victoria Hub",
            Content=plr.Name.." telah join, serverhop dalam 6 detik...",
            Duration=6,
            Icon="alert-triangle"
        })
        hop()
    end
end))

Performance.Tasks["AntiStaffCheck"] = task.spawn(function()
    while task.wait(2) do
        if ON then
            for _,plr in ipairs(game:GetService("Players"):GetPlayers()) do
                if plr~=Player and BL[plr.UserId] then
                    WindUI:Notify({
                        Title="Victoria Hub",
                        Content=plr.Name.." terdeteksi, serverhop dalam 6 detik...",
                        Duration=6,
                        Icon="alert-triangle"
                    })
                    hop()
                    break
                end
            end
        end
    end
end)

-- ==================== GRAPHICS SECTION ====================
local graphic = Tab7:Section({ 
    Title = "Graphics Featured",
    Icon = "chart-bar",
    TextXAlignment = "Left",
    TextSize = 17,
})

-- FPS BOOST
local Cache = {}
local White = Color3.fromRGB(220,220,220)
local FPSBoost = false

local function cache(o)
    if Cache[o] then return end
    if o:IsA("BasePart") then
        Cache[o] = {o.Color, o.Material}
    elseif o:IsA("PointLight") or o:IsA("SpotLight") or o:IsA("SurfaceLight")
    or o:IsA("ParticleEmitter") or o:IsA("Beam") or o:IsA("Trail")
    or o:IsA("Fire") or o:IsA("Smoke") then
        Cache[o] = o.Enabled
    end
end

local function apply(o)
    if o:IsDescendantOf(Player.PlayerGui)
    or (workspace.Terrain and o:IsDescendantOf(workspace.Terrain))
    or (Player.Character and o:IsDescendantOf(Player.Character)) then return end

    cache(o)

    if o:IsA("BasePart") then
        o.Color = White
        o.Material = Enum.Material.SmoothPlastic
    elseif o:IsA("PointLight") or o:IsA("SpotLight") or o:IsA("SurfaceLight")
    or o:IsA("ParticleEmitter") or o:IsA("Beam") or o:IsA("Trail")
    or o:IsA("Fire") or o:IsA("Smoke") then
        o.Enabled = false
    end
end

local function restore(o)
    local d = Cache[o]
    if d == nil then return end

    if o:IsA("BasePart") then
        o.Color, o.Material = d[1], d[2]
    else
        o.Enabled = d
    end
end

SafeConnect("FPSBoostDescendant", workspace.DescendantAdded:Connect(function(o)
    if FPSBoost then task.wait(); apply(o) end
end))

graphic:Toggle({
    Title = "FPS Boost",
    Default = false,
    Callback = function(v)
        FPSBoost = v
        local Lighting = game:GetService("Lighting")
        
        Lighting.GlobalShadows = not v
        Lighting.EnvironmentDiffuseScale = v and 0 or 1
        Lighting.EnvironmentSpecularScale = v and 0 or 1

        for _,e in ipairs(Lighting:GetChildren()) do
            if e:IsA("BloomEffect") or e:IsA("SunRaysEffect") or e:IsA("BlurEffect")
            or e:IsA("DepthOfFieldEffect") or e:IsA("ColorCorrectionEffect") then
                e.Enabled = not v
            end
        end

        for _,o in ipairs(workspace:GetDescendants()) do
            if v then apply(o) else restore(o) end
        end
    end
})

-- REMOVE FISH NOTIFICATION
local PopupConn, RemoteConn

graphic:Toggle({
    Title = "Remove Fish Notification Pop-up",
    Value = false,
    Callback = function(state)
        local PlayerGui = Player:WaitForChild("PlayerGui")
        local RemoteEvent = RS.Packages._Index["sleitnick_net@0.2.0"].net["RE/ObtainedNewFishNotification"]

        if state then
            local function getPopup()
                local gui = PlayerGui:FindFirstChild("Small Notification")
                if not gui then return end
                local display = gui:FindFirstChild("Display")
                if not display then return end
                return display:FindFirstChild("NewFrame")
            end

            local frame = getPopup()
            if frame then frame.Visible = false; frame:Destroy() end

            PopupConn = PlayerGui.DescendantAdded:Connect(function(v)
                if v.Name == "NewFrame" then
                    task.wait()
                    v.Visible = false
                    v:Destroy()
                end
            end)

            RemoteConn = RemoteEvent.OnClientEvent:Connect(function()
                local f = getPopup()
                if f then f.Visible = false; f:Destroy() end
            end)
        else
            if PopupConn then PopupConn:Disconnect(); PopupConn = nil end
            if RemoteConn then RemoteConn:Disconnect(); RemoteConn = nil end
        end
    end
})

-- DISABLE 3D RENDERING
local G
graphic:Toggle({
    Title = "Disable 3D Rendering",
    Value = false,
    Callback = function(s)
        pcall(function() game:GetService("RunService"):Set3dRenderingEnabled(not s) end)
        if s then
            G = Instance.new("ScreenGui")
            G.IgnoreGuiInset = true
            G.ResetOnSpawn = false
            G.Parent = Player.PlayerGui

            Instance.new("Frame", G).Size = UDim2.fromScale(1,1)
            G.Frame.BackgroundColor3 = Color3.new(1,1,1)
            G.Frame.BorderSizePixel = 0
        elseif G then
            G:Destroy()
            G = nil
        end
    end
})

-- HIDE ALL VFX
local VFXState = {on = false, cache = {}}

local VFX = {
    ParticleEmitter = true, Beam = true, Trail = true, Smoke = true,
    Fire = true, Sparkles = true, Explosion = true,
    PointLight = true, SpotLight = true, SurfaceLight = true, Highlight = true
}

local LE = {
    BloomEffect = true, SunRaysEffect = true, ColorCorrectionEffect = true,
    DepthOfFieldEffect = true, Atmosphere = true
}

local function disableVFX()
    for _, o in ipairs(workspace:GetDescendants()) do
        if VFX[o.ClassName] and o.Enabled == true then
            VFXState.cache[o] = true
            o.Enabled = false
        end
    end

    for _, o in ipairs(game:GetService("Lighting"):GetChildren()) do
        if LE[o.ClassName] and o.Enabled ~= nil then
            VFXState.cache[o] = true
            o.Enabled = false
        end
    end
end

local function restoreVFX()
    for o in pairs(VFXState.cache) do
        if o and o.Parent and o.Enabled ~= nil then o.Enabled = true end
    end
    VFXState.cache = {}
end

SafeConnect("VFXDescendant", workspace.DescendantAdded:Connect(function(o)
    if VFXState.on and VFX[o.ClassName] and o.Enabled ~= nil then
        task.defer(function() o.Enabled = false end)
    end
end))

SafeConnect("LightingDescendant", game:GetService("Lighting").DescendantAdded:Connect(function(o)
    if VFXState.on and LE[o.ClassName] and o.Enabled ~= nil then
        task.defer(function() o.Enabled = false end)
    end
end))

graphic:Toggle({
    Title = "Hide All VFX",
    Value = false,
    Callback = function(state)
        VFXState.on = state
        if state then disableVFX() else restoreVFX() end
    end
})

-- REMOVE SKIN EFFECT
local VFX = require(RS.Controllers.VFXController)
local ORI = {
    H = VFX.Handle,
    P = VFX.RenderAtPoint,
    I = VFX.RenderInstance
}

graphic:Toggle({
    Title = "Remove Skin Effect",
    Desc = "Remove Your Skin Effect",
    Default = false,
    Callback = function(state)
        if state then
            VFX.Handle = function() end
            VFX.RenderAtPoint = function() end
            VFX.RenderInstance = function() end

            local f = workspace:FindFirstChild("CosmeticFolder")
            if f then pcall(f.ClearAllChildren, f) end
        else
            VFX.Handle = ORI.H
            VFX.RenderAtPoint = ORI.P
            VFX.RenderInstance = ORI.I
        end
    end
})

-- DISABLE CUTSCENE
_G.CutsceneController = require(RS.Controllers.CutsceneController)
_G.GuiControl = require(RS.Modules.GuiControl)
_G.ProximityPromptService = game:GetService("ProximityPromptService")
_G.AutoSkipCutscene = false

if not _G.OriginalPlayCutscene then
    _G.OriginalPlayCutscene = _G.CutsceneController.Play
end

_G.CutsceneController.Play = function(self, ...)
    if _G.AutoSkipCutscene then
        task.spawn(function()
            task.wait()
            if _G.GuiControl then _G.GuiControl:SetHUDVisibility(true) end
            _G.ProximityPromptService.Enabled = true
            LocalPlayer:SetAttribute("IgnoreFOV", false)
        end)
        return
    end
    return _G.OriginalPlayCutscene(self, ...)
end

graphic:Toggle({
    Title = "Disable Cutscene",
    Value = false,
    Callback = function(state)
        _G.AutoSkipCutscene = state
        if state then
            if _G.CutsceneController then
                _G.CutsceneController:Stop()
                _G.GuiControl:SetHUDVisibility(true)
                _G.ProximityPromptService.Enabled = true
            end
        end
    end
})

-- ==================== SERVER SECTION ====================
local server = Tab7:Section({ 
    Title = "Server",
    Icon = "server",
    TextXAlignment = "Left",
    TextSize = 17,
})

server:Button({
    Title = "Rejoin",
    Desc = "rejoin to the same server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
    end
})

server:Button({
    Title = "Server Hop",
    Desc = "Switch To Another Server",
    Callback = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, Player)
    end
})

-- ==================== CONFIG SECTION ====================
local config = Tab7:Section({ 
    Title = "Config",
    Icon = "folder-open",
    TextXAlignment = "Left",
    TextSize = 17,
})

local ConfigFolder = "VICTORIA_HUB/Configs"
if not isfolder("VICTORIA_HUB") then makefolder("VICTORIA_HUB") end
if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end

local ConfigName = "default.json"

local function GetConfig()
    local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    return {
        WalkSpeed = humanoid and humanoid.WalkSpeed or 16,
        JumpPower = _G.CustomJumpPower or 50,
        InfiniteJump = _G.InfiniteJump or false,
        AutoSell = AutoSell or false,
        InstantCatch = _G.InstantCatch or false,
        AntiAFK = _G.AntiAFK or false,
        AutoReconnect = AutoReconnect or false,
    }
end

local function ApplyConfig(data)
    local humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if data.WalkSpeed and humanoid then humanoid.WalkSpeed = data.WalkSpeed end
    if data.JumpPower and humanoid then
        _G.CustomJumpPower = data.JumpPower
        humanoid.UseJumpPower = true
        humanoid.JumpPower = data.JumpPower
    end
    if data.InfiniteJump ~= nil then _G.InfiniteJump = data.InfiniteJump end
    if data.AutoSell ~= nil then AutoSell = data.AutoSell end
    if data.InstantCatch ~= nil then _G.InstantCatch = data.InstantCatch end
    if data.AntiAFK ~= nil then _G.AntiAFK = data.AntiAFK end
    if data.AutoReconnect ~= nil then AutoReconnect = data.AutoReconnect end
end

config:Button({
    Title = "Save Config",
    Desc = "Save all settings",
    Callback = function()
        local data = GetConfig()
        writefile(ConfigFolder.."/"..ConfigName, game:GetService("HttpService"):JSONEncode(data))
        WindUI:Notify({Title = "Config Saved", Content = "Settings saved successfully", Duration = 3, Icon = "check"})
    end
})

config:Button({
    Title = "Load Config",
    Desc = "Use saved config",
    Callback = function()
        if isfile(ConfigFolder.."/"..ConfigName) then
            local data = readfile(ConfigFolder.."/"..ConfigName)
            local decoded = game:GetService("HttpService"):JSONDecode(data)
            ApplyConfig(decoded)
            WindUI:Notify({Title = "Config Loaded", Content = "Settings loaded successfully", Duration = 3, Icon = "check"})
        else
            WindUI:Notify({Title = "Error", Content = "Config file not found", Duration = 3, Icon = "x"})
        end
    end
})

config:Button({
    Title = "Delete Config",
    Desc = "Delete saved config",
    Callback = function()
        if isfile(ConfigFolder.."/"..ConfigName) then
            delfile(ConfigFolder.."/"..ConfigName)
            WindUI:Notify({Title = "Config Deleted", Content = "Settings deleted", Duration = 3, Icon = "trash"})
        else
            WindUI:Notify({Title = "Error", Content = "No config to delete", Duration = 3, Icon = "x"})
        end
    end
})

-- ==================== OTHER SCRIPTS ====================
local script = Tab7:Section({ 
    Title = "Other Scripts",
    Icon = "scroll",
    TextXAlignment = "Left",
    TextSize = 17,
})

script:Button({
    Title = "Infinite Yield",
    Desc = "Other Scripts",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/DarkNetworks/Infinite-Yield/main/latest.lua'))()
    end
})

-- ==================== FINAL CLEANUP ====================
local function cleanup()
    for name, _ in pairs(Performance.Tasks) do SafeCancel(name) end
    for name, _ in pairs(Performance.Connections) do SafeDisconnect(name) end
    
    _G.InfiniteJump = false
    _G.Noclip = false
    _G.AutoFishing = false
    _G.AutoEquipRod = false
    _G.Radar = false
    _G.Instant = false
    _G.AntiAFK = false
    _G.AutoSkipCutscene = false
    
    if Frame then Frame:Destroy() end
    if G then G:Destroy() end
    
    print("Victoria Hub: Cleanup completed")
end

--- game:BindToClose(cleanup)

-- ==================== FINAL INIT ====================
getgenv().LexsHubWindow = Window
print("✅ Victoria Hub Loaded Successfully! (v0.0.9.2 - All Original Features + Optimized)")

return Window
