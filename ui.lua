-- =========================
-- Chloe X - Fluent UI
-- =========================

local Fluent = loadstring(game:HttpGet(
    "https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"
))()

-- Window
local Window = Fluent:CreateWindow({
    Title = "Chloe X  [ v1.1 ]",
    SubTitle = "discord.gg/chloex  |  RGD.GG",
    TabWidth = 165,
    Size = UDim2.fromOffset(560, 440),
    Acrylic = true,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Sidebar Tabs (mirip gambar)
local Tabs = {
    Info = Window:AddTab({ Title = "Info", Icon = "user" }),
    Fishing = Window:AddTab({ Title = "Fishing", Icon = "fish" }),
    Auto = Window:AddTab({ Title = "Automatically", Icon = "play-circle" }),
    Trading = Window:AddTab({ Title = "Trading", Icon = "refresh-cw" }),
    Menu = Window:AddTab({ Title = "Menu", Icon = "settings" })
}

-- =========================
-- INFO TAB (panel besar)
-- =========================

Tabs.Info:AddParagraph({
    Title = "Chloe X Information",
    Content = "Chloe X is a modern fishing assistant UI.\n" ..
              "Clean • Fast • Mobile Friendly\n\n" ..
              "Version : v1.1\nStatus  : Online"
})

Tabs.Info:AddSection("Links")

Tabs.Info:AddButton({
    Title = "CHLOE X Discord",
    Description = "Official Chloe X Discord Server",
    Callback = function()
        setclipboard("https://discord.gg/chloex")
    end
})

Tabs.Info:AddButton({
    Title = "RGD Top Up",
    Description = "Top up robux termurah hanya di RGD.GG",
    Callback = function()
        setclipboard("https://rgd.gg")
    end
})

-- =========================
-- FISHING TAB
-- =========================

Tabs.Fishing:AddSection("Fishing Core")

Tabs.Fishing:AddToggle("AutoCast", {
    Title = "Auto Cast",
    Description = "Automatically cast fishing rod",
    Default = false
})

Tabs.Fishing:AddToggle("AutoReel", {
    Title = "Auto Reel",
    Description = "Automatically reel when fish hooked",
    Default = false
})

Tabs.Fishing:AddToggle("PerfectTiming", {
    Title = "Perfect Timing",
    Description = "Always perfect catch timing",
    Default = false
})

Tabs.Fishing:AddSection("Fishing Settings")

Tabs.Fishing:AddSlider("CastDelay", {
    Title = "Cast Delay",
    Min = 0,
    Max = 5,
    Default = 1,
    Rounding = 1,
    Suffix = "s"
})

Tabs.Fishing:AddDropdown("FishingArea", {
    Title = "Fishing Area",
    Values = {"River", "Lake", "Ocean", "Island"},
    Default = 1
})

-- =========================
-- AUTOMATICALLY TAB
-- =========================

Tabs.Auto:AddSection("Automation")

Tabs.Auto:AddToggle("AutoSell", {
    Title = "Auto Sell Fish",
    Description = "Sell fish automatically when inventory full",
    Default = false
})

Tabs.Auto:AddToggle("AutoEquipRod", {
    Title = "Auto Equip Best Rod",
    Description = "Automatically equip best available rod",
    Default = true
})

Tabs.Auto:AddToggle("AutoEnchant", {
    Title = "Auto Enchant",
    Description = "Automatically enchant rod",
    Default = false
})

-- =========================
-- TRADING TAB
-- =========================

Tabs.Trading:AddSection("Trading System")

Tabs.Trading:AddToggle("TradeLock", {
    Title = "Trade Lock",
    Description = "Block incoming trade requests",
    Default = false
})

Tabs.Trading:AddButton({
    Title = "Open Trading Menu",
    Description = "Quick access trading",
    Callback = function()
        print("Trading menu opened")
    end
})

-- =========================
-- MENU TAB
-- =========================

Tabs.Menu:AddSection("UI Control")

Tabs.Menu:AddKeybind("ToggleUI", {
    Title = "Toggle UI",
    Mode = "Toggle",
    Default = "LeftControl",
    Callback = function()
        Window:Minimize()
    end
})

Tabs.Menu:AddButton({
    Title = "Unload Chloe X",
    Description = "Close and unload UI",
    Callback = function()
        Fluent:Destroy()
    end
})

-- =========================
-- Startup Notification
-- =========================

Fluent:Notify({
    Title = "Chloe X",
    Content = "UI Loaded Successfully",
    Duration = 4
})
