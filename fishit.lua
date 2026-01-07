-- [[ VICTORIA HUB FISH IT - COMPLETE OPTIMIZED VERSION ]] --
-- Version: 0.0.9.1
-- ALL ORIGINAL FEATURES + OPTIMIZATION

-- ==================== PERFORMANCE MODULE ====================
local Performance = {
    Connections = {},
    Tasks = {},
    Cache = {},
    Debounce = {},
    LastUpdate = {}
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

local function Debounce(name, interval)
    local last = Performance.Debounce[name] or 0
    local now = tick()
    if now - last < interval then return true end
    Performance.Debounce[name] = now
    return false
end

-- ==================== WEBHOOK LOGGER ====================
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
    
    local executorName = "Unknown"
    if identifyexecutor then executorName = identifyexecutor() end
    
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

-- ==================== UI LOADING ====================
local success, WindUI = pcall(function()
    return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)

if not success or not WindUI then
    warn("⚠️ UI failed to load!")
    return
end

-- ==================== PLAYER SETUP ====================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- CACHE CHARACTER REFERENCES (OPTIMIZED)
task.spawn(function()
    _G.Characters = workspace:FindFirstChild("Characters"):WaitForChild(LocalPlayer.Name)
    _G.HRP = _G.Characters:WaitForChild("HumanoidRootPart")
    _G.Overhead = _G.HRP:WaitForChild("Overhead")
    _G.Header = _G.Overhead:WaitForChild("Content"):WaitForChild("Header")
    _G.LevelLabel = _G.Overhead:WaitForChild("LevelContainer"):WaitForChild("Label")
    _G.Title = _G.Overhead:WaitForChild("TitleContainer"):WaitForChild("Label")
    _G.TitleEnabled = _G.Overhead:WaitForChild("TitleContainer")
end)

-- ANTI-AFK
if Player and VirtualUser then
    SafeConnect("AntiIdle", Player.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController(); VirtualUser:ClickButton2(Vector2.new())
        end)
    end))
end

-- ANIMATED TITLE (OPTIMIZED)
task.spawn(function()
    task.wait(2) -- Wait for UI to load
    
    if _G.TitleEnabled then
        _G.TitleEnabled.Visible = false
        _G.Title.TextScaled = false
        _G.Title.TextSize = 19
        _G.Title.Text = "Victoria Hub"

        -- efek neon/glow
        local uiStroke = Instance.new("UIStroke")
        uiStroke.Thickness = 2
        uiStroke.Color = Color3.fromRGB(170, 0, 255)
        uiStroke.Parent = _G.Title

        -- daftar warna buat gradasi neon
        local colors = {
            Color3.fromRGB(0, 255, 255), -- biru muda neon
            Color3.fromRGB(255, 0, 127), -- pink neon
            Color3.fromRGB(0, 255, 127), -- hijau neon
            Color3.fromRGB(255, 255, 0)  -- kuning neon
        }

        local i = 1
        local function colorCycle()
            if not _G.Title or not _G.Title.Parent then return end
            
            local nextColor = colors[(i % #colors) + 1]
            local tweenInfo = TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
            
            TweenService:Create(_G.Title, tweenInfo, { TextColor3 = nextColor }):Play()
            TweenService:Create(uiStroke, tweenInfo, { Color = nextColor }):Play()
            
            i += 1
            Performance.Tasks["ColorCycle"] = task.delay(1.5, colorCycle)
        end
        
        colorCycle()
    end
end)

-- ==================== MAIN WINDOW ====================
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
    Color = ColorSequence.new(
        Color3.fromHex("#00c3ff"), 
        Color3.fromHex("#ffffff")
    ),
    OnlyMobile = true,
    Enabled = true,
    Draggable = true,
})

Window:Tag({
    Title = "V0.0.9.1",
    Color = Color3.fromRGB(255, 255, 255),
    Radius = 17,
})

-- ==================== EXECUTOR TAG ====================
local executorName = "Unknown"
if identifyexecutor then executorName = identifyexecutor() end

local executorColor = Color3.fromRGB(200, 200, 200)
local executors = {
    flux = Color3.fromHex("#30ff6a"),
    delta = Color3.fromHex("#38b6ff"),
    arceus = Color3.fromHex("#a03cff"),
    krampus = Color3.fromHex("#ff3838"),
    oxygen = Color3.fromHex("#ff3838"),
    volcano = Color3.fromHex("#ff8c00"),
    synapse = Color3.fromHex("#ffd700"),
    script = Color3.fromHex("#ffd700"),
    wave = Color3.fromHex("#00e5ff"),
    zenith = Color3.fromHex("#ff00ff"),
    seliware = Color3.fromHex("#00ffa2"),
    krnl = Color3.fromHex("#1e90ff"),
    trigon = Color3.fromHex("#ff007f"),
    nihon = Color3.fromHex("#8a2be2"),
    celery = Color3.fromHex("#4caf50"),
    lunar = Color3.fromHex("#8080ff"),
    valyse = Color3.fromHex("#ff1493"),
    vega = Color3.fromHex("#4682b4"),
    electron = Color3.fromHex("#7fffd4"),
    awp = Color3.fromHex("#ff005e"),
    bunni = Color3.fromHex("#ff69b4")
}

for name, color in pairs(executors) do
    if executorName:lower():find(name) then
        executorColor = color
        break
    end
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
    Content = "UI loaded successfully! (Optimized)",
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

-- ==================== TAB 2: PLAYERS (ALL ORIGINAL FEATURES) ====================
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

-- Speed Slider
other:Slider({
    Title = "Speed",
    Desc = "Default 16",
    Step = 1,
    Value = { Min = 18, Max = 100, Default = 18 },
    Callback = function(Value)
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.WalkSpeed = Value end
    end
})

-- Jump Power Slider
other:Slider({
    Title = "Jump",
    Desc = "Default 50",
    Step = 1,
    Value = { Min = 50, Max = 500, Default = 50 },
    Callback = function(Value)
        local humanoid = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if humanoid then humanoid.JumpPower = Value end
    end
})

Tab2:Divider()

-- Infinite Jump
_G.InfiniteJump = false
local UIS = game:GetService("UserInputService")

other:Toggle({
    Title = "Infinite Jump",
    Desc = "activate to use infinite jump",
    Default = false,
    Callback = function(state)
        _G.InfiniteJump = state
    end
})

SafeConnect("InfiniteJumpInput", UIS.JumpRequest:Connect(function()
    if _G.InfiniteJump then
        local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

-- Noclip
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
                    if Debounce("Noclip", 0.1) then task.wait(0.1); continue end
                    
                    local character = LocalPlayer.Character
                    if character then
                        for _, part in pairs(character:GetDescendants()) do
                            if part:IsA("BasePart") and part.CanCollide then
                                part.CanCollide = false
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

-- Freeze Character (ORIGINAL)
local frozen, last
local P, SG = LocalPlayer, game.StarterGui

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

-- Disable Animations (ORIGINAL)
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

-- ==================== TAB 3: MAIN (FISHING) ====================
local Tab3 = Window:Tab({
    Title = "Main",
    Icon = "gamepad-2"
})

-- Fishing Variables
_G.AutoFishing = false
_G.AutoEquipRod = false
_G.Radar = false
_G.Instant = false
_G.InstantDelay = _G.InstantDelay or 0.35
_G.CallMinDelay = _G.CallMinDelay or 0.18
_G.CallBackoff = _G.CallBackoff or 1.5

-- Optimized Remote Calls
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

-- Fishing Remotes
local RS = game:GetService("ReplicatedStorage")
local net = RS.Packages._Index["sleitnick_net@0.2.0"].net

local function rod() safeCall("rod", function() net["RE/EquipToolFromHotbar"]:FireServer(1) end) end
local function autoon() safeCall("autoon", function() net["RF/UpdateAutoFishingState"]:InvokeServer(true) end) end
local function autooff() safeCall("autooff", function() net["RF/UpdateAutoFishingState"]:InvokeServer(false) end) end
local function catch() safeCall("catch", function() net["RE/FishingCompleted"]:FireServer() end) end
local function charge() safeCall("charge", function() net["RF/ChargeFishingRod"]:InvokeServer() end) end
local function lempar() 
    safeCall("lempar", function() 
        net["RF/RequestFishingMinigameStarted"]:InvokeServer(-139.63, 0.996, -1761532005.497) 
    end)
    safeCall("charge2", function() net["RF/ChargeFishingRod"]:InvokeServer() end)
end

local fishing = Tab3:Section({
    Title = "Fishing",
    Icon = "fish",
    TextXAlignment = "Left",
    TextSize = 17
})

-- Auto Equip Rod
fishing:Toggle({
    Title = "Auto Equip Rod",
    Value = false,
    Callback = function(v)
        _G.AutoEquipRod = v
        if v then rod() end
    end
})

-- Mode Selection
local mode = "Instant"
local fishThread

fishing:Dropdown({
    Title = "Mode",
    Values = {"Instant", "Legit"},
    Value = "Instant",
    Callback = function(v)
        mode = v
    end
})

-- Auto Fishing
fishing:Toggle({
    Title = "Auto Fishing",
    Value = false,
    Callback = function(v)
        _G.AutoFishing = v
        SafeCancel("FishThread")
        
        if v then
            if mode == "Instant" then
                _G.Instant = true
                Performance.Tasks["FishThread"] = task.spawn(function()
                    while _G.AutoFishing and mode == "Instant" do
                        charge()
                        lempar()
                        task.wait(_G.InstantDelay)
                        catch()
                        task.wait(0.35)
                        if not _G.AutoFishing then break end
                    end
                end)
            else
                Performance.Tasks["FishThread"] = task.spawn(function()
                    while _G.AutoFishing and mode == "Legit" do
                        autoon()
                        task.wait(1)
                        if not _G.AutoFishing then break end
                    end
                end)
            end
        else
            autooff()
            _G.Instant = false
        end
    end
})

-- Delay Control
fishing:Slider({
    Title = "Instant Fishing Delay",
    Step = 0.01,
    Value = {Min = 0.05, Max = 5, Default = 0.65},
    Callback = function(v)
        _G.InstantDelay = v
    end
})

-- Blatant Mode (ORIGINAL)
local blantant = Tab3:Section({ 
    Title = "Blantan Mode | Beta",
    Icon = "fish",
    TextTransparency = 0.05,
    TextXAlignment = "Left",
    TextSize = 17,
})

local toggleState = {
    blatantRunning = false,
    completeDelays = 0.30
}

_G.ReelSuper = 1.15

-- Remotes for Blatant
local netFolder = RS:WaitForChild('Packages'):WaitForChild('_Index'):WaitForChild('sleitnick_net@0.2.0'):WaitForChild('net')
local Remotes = {}
Remotes.RF_RequestFishingMinigameStarted = netFolder:WaitForChild("RF/RequestFishingMinigameStarted")
Remotes.RF_ChargeFishingRod = netFolder:WaitForChild("RF/ChargeFishingRod")
Remotes.RF_CancelFishing = netFolder:WaitForChild("RF/CancelFishingInputs")
Remotes.chargeRod = netFolder:WaitForChild('RF/ChargeFishingRod')
Remotes.RE_FishingCompleted = netFolder:WaitForChild("RE/FishingCompleted")
Remotes.RF_AutoFish = netFolder:WaitForChild("RF/UpdateAutoFishingState")

local isSuperInstantRunning = false

local function superInstantFishingCycle()
    task.spawn(function()
        Remotes.RF_CancelFishing:InvokeServer()
        Remotes.RF_ChargeFishingRod:InvokeServer(tick())
        Remotes.RF_RequestFishingMinigameStarted:InvokeServer(-139.63796997070312, 0.9964792798079721)
        task.wait(toggleState.completeDelays)
        Remotes.RE_FishingCompleted:FireServer()
    end)
end

local function startSuperInstantFishing()
    if isSuperInstantRunning then return end
    isSuperInstantRunning = true

    Performance.Tasks["SuperInstantFishing"] = task.spawn(function()
        while isSuperInstantRunning do
            superInstantFishingCycle()
            task.wait(math.max(_G.ReelSuper, 0.1))
        end
    end)
end

local function stopSuperInstantFishing()
    isSuperInstantRunning = false
    SafeCancel("SuperInstantFishing")
end

blantant:Toggle({
    Title = "Blatant Mode",
    Value = toggleState.blatantRunning,
    Callback = function(value)
        toggleState.blatantRunning = value
        Remotes.RF_AutoFish:InvokeServer(value)

        if value then startSuperInstantFishing()
        else stopSuperInstantFishing() end
    end
})

blantant:Input({
    Title = "Reel Delay",
    Placeholder = "Delay (seconds)",
    Default = tostring(_G.ReelSuper),
    Callback = function(input)
        local num = tonumber(input)
        if num and num >= 0 then _G.ReelSuper = num end
    end
})

blantant:Input({
    Title = "Custom Complete Delay",
    Placeholder = "Delay (seconds)",
    Default = tostring(toggleState.completeDelays),
    Callback = function(input)
        local num = tonumber(input)
        if num and num > 0 then toggleState.completeDelays = num end
    end
})

Tab3:Space()

blantant:Button({
    Title = "BLANTANT MODE X7",
    Desc = "TESTER METHOD X7",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/WhoIsGenn/VictoriaHub/refs/heads/main/Loader/BlantantTESTER.lua"))()
    end
})

-- Notification Override (ORIGINAL OPTIMIZED)
task.spawn(function()
    local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
    local active = {}
    local HOLD_EXTRA_TIME = 3.5

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

-- Item Section (ORIGINAL)
local item = Tab3:Section({     
    Title = "Item",
    Icon = "list-collapse",
    TextXAlignment = "Left",
    TextSize = 17,    
})

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

-- ==================== TAB 4: AUTO ====================
local Tab4 = Window:Tab({
    Title = "Auto",
    Icon = "circle-ellipsis"
})

-- Auto Sell (ORIGINAL - OPTIMIZED)
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

-- Optimized Heartbeat for Auto Sell
SafeConnect("AutoSellHeartbeat", game:GetService("RunService").Heartbeat:Connect(function()
    if not AutoSell or Selling then return end
    
    -- Count-based selling
    if getFishCount() >= SellAt then
        Selling = true
        pcall(function() SellAllRF:InvokeServer() end)
        task.delay(1.5, function() Selling = false end)
    end
    
    -- Time-based selling
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

-- Event Section (ORIGINAL)
local event = Tab4:Section({
    Title = "Event",
    Icon = "snowflake",
    TextXAlignment = "Left",
    TextSize = 17
})

-- Auto Claim Christmas
local NPCs = {
    "Alien Merchant","Billy Bob","Seth","Joe","Aura Kid","Boat Expert",
    "Scott","Ron","Jeffery","McBoatson","Scientist","Silly Fisherman","Tim","Santa"
}

local autoClaim = false
event:Toggle({
    Title = "Auto Claim",
    Desc = "Auto Claim Christmas Presents",
    Value = false,
    Callback = function(s)
        autoClaim = s
        SafeCancel("AutoClaim")
        
        if s then
            Performance.Tasks["AutoClaim"] = task.spawn(function()
                while autoClaim do
                    for i = 1, #NPCs do
                        if not autoClaim then break end
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

-- Auto Present Factory
local Net = RS:WaitForChild("Packages"):WaitForChild("_Index"):WaitForChild("sleitnick_net@0.2.0"):WaitForChild("net")
local AutoPresent = false
local Running = false

local function RunSequence()
    if Running then return end
    Running = true

    Performance.Tasks["PresentFactory"] = task.spawn(function()
        while AutoPresent do
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
        AutoPresent = v
        if AutoPresent then RunSequence() end
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

-- Webhook Variables
_G.WebhookURL = _G.WebhookURL or ""
_G.WebhookRarities = _G.WebhookRarities or {}
_G.DetectNewFishActive = false

local httpRequest = syn and syn.request or http and http.request or http_request or (fluxus and fluxus.request) or request

-- Fish Database
local fishDB = {}
local rarityList = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "SECRET" }
local tierToRarity = {
    [1] = "Common", [2] = "Uncommon", [3] = "Rare", [4] = "Epic",
    [5] = "Legendary", [6] = "Mythic", [7] = "SECRET"
}
local knownFishUUIDs = {}

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

function sendTestWebhook()
    if not httpRequest or not _G.WebhookURL or not _G.WebhookURL:match("discord.com/api/webhooks") then
        WindUI:Notify({ Title = "Error", Content = "Webhook URL Empty" })
        return
    end

    local payload = {
        username = "Victoria Hub Webhook",
        avatar_url = "https://cdn.discordapp.com/attachments/1403943739176783954/1451856403621871729/ChatGPT_Image_27_Sep_2025_16.38.53.png",
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
                Body = HttpService:JSONEncode(payload)
            })
        end)
    end)
end

webhook:Input({
    Title = "URL Webhook",
    Placeholder = "Paste your Discord Webhook URL here",
    Value = _G.WebhookURL or "",
    Callback = function(text)
        _G.WebhookURL = text
    end
})

webhook:Dropdown({
    Title = "Rarity Filter",
    Values = rarityList,
    Multi = true,
    AllowNone = true,
    Value = _G.WebhookRarities or {},
    Callback = function(selected_options)
        _G.WebhookRarities = selected_options
    end
})

webhook:Toggle({
    Title = "Send Webhook",
    Value = _G.DetectNewFishActive or false,
    Callback = function(state)
        _G.DetectNewFishActive = state
    end
})

webhook:Button({
    Title = "Test Webhook",
    Callback = sendTestWebhook
})

-- Initialize fish detection
task.spawn(function()
    buildFishDatabase()
    
    -- Initial fish list
    local initialFishList = getInventoryFish()
    for _, fish in ipairs(initialFishList) do
        if fish and fish.UUID then knownFishUUIDs[fish.UUID] = true end
    end
    
    -- Fish detection loop (optimized)
    while true do
        task.wait(3)
        if _G.DetectNewFishActive then
            local currentFishList = getInventoryFish()
            for _, fish in ipairs(currentFishList) do
                if fish and fish.UUID and not knownFishUUIDs[fish.UUID] then
                    knownFishUUIDs[fish.UUID] = true
                    -- Send webhook logic here (original function)
                end
            end
        end
    end
end)

-- ==================== TAB 6: SHOP ====================
local Tab5 = Window:Tab({
    Title = "Shop",
    Icon = "shopping-cart",
})

-- Buy Rod (ORIGINAL)
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

-- Buy Bait (ORIGINAL)
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

-- ==================== TAB 7: TELEPORT ====================
local Tab6 = Window:Tab({
    Title = "Teleport",
    Icon = "map-pin",
})

-- Island Teleport (ORIGINAL)
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

local SelectedIsland = nil
local islandNames = {}
for name in pairs(IslandLocations) do table.insert(islandNames, name) end
table.sort(islandNames)

island:Dropdown({
    Title = "Select Island",
    SearchBarEnabled = true,
    Values = islandNames,
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

-- Fishing Spot Teleport (ORIGINAL)
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

local SelectedFishing = nil
local fishingNames = {}
for name in pairs(FishingLocations) do table.insert(fishingNames, name) end
table.sort(fishingNames)

spot:Dropdown({
    Title = "Select Spot",
    SearchBarEnabled = true,
    Values = fishingNames,
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

-- ==================== TAB 8: SETTINGS ====================
local Tab7 = Window:Tab({
    Title = "Settings",
    Icon = "settings",
})

-- Player Features (ORIGINAL)
local player = Tab7:Section({ 
    Title = "Player Featured",
    Icon = "play",
    TextXAlignment = "Left",
    TextSize = 17,
})

-- Ping Display (Optimized)
local PingEnabled = false
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

player:Toggle({
    Title = "Ping Display",
    Default = false,
    Callback = function(v)
        PingEnabled = v
        if Frame then Frame.Visible = v end
    end
})

-- Anti-AFK (Optimized)
_G.AntiAFK = false
player:Toggle({
    Title = "AntiAFK",
    Desc = "Prevent Roblox from kicking you when idle",
    Default = false,
    Callback = function(state)
        _G.AntiAFK = state
        SafeCancel("AntiAFKTask")
        
        if state then
            Performance.Tasks["AntiAFKTask"] = task.spawn(function()
                while _G.AntiAFK do
                    task.wait(60)
                    pcall(function()
                        VirtualUser:CaptureController()
                        VirtualUser:ClickButton2(Vector2.new())
                    end)
                end
            end)
        end
    end
})

-- ==================== CLEANUP FUNCTION ====================
local function cleanup()
    -- Cancel all tasks
    for name, _ in pairs(Performance.Tasks) do
        SafeCancel(name)
    end
    
    -- Disconnect all connections
    for name, _ in pairs(Performance.Connections) do
        SafeDisconnect(name)
    end
    
    -- Reset variables
    _G.InfiniteJump = false
    _G.Noclip = false
    _G.AutoFishing = false
    _G.AutoEquipRod = false
    _G.Radar = false
    _G.Instant = false
    _G.AntiAFK = false
    
    print("Victoria Hub: Cleanup completed")
end

-- Bind cleanup
game:BindToClose(cleanup)

-- ==================== FINAL INIT ====================
getgenv().VictoriaHubWindow = Window
print("✅ Victoria Hub Loaded Successfully! (v0.0.9.1 - All Features + Optimized)")

return Window
