local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

-- 🔍 Deteksi Executor
local executor = (identifyexecutor and identifyexecutor()) or "Unknown"

local bannedExecutors = {
    "Solara", "TRIGON", "Luna", "XENO", "Swift", "ARGON"
}

for _, name in ipairs(bannedExecutors) do
    if executor:lower():find(name:lower()) then
        warn("❌ Executor \"" .. executor .. "\" not supported by VictoriaHub.")
        StarterGui:SetCore("SendNotification", {
            Title = "Executor Not Supported",
            Text = "Your executor: " .. executor .. "\nUse Volcano, Velocity, or something similar.",
            Duration = 8
        })
        return
    end
end

print("✅ Executor detected:", executor)

-- 📦 Load WindUI
local success, WindUI = pcall(function()
	return loadstring(game:HttpGet("https://raw.githubusercontent.com/WhoIsGenn/VictoriaHub/refs/heads/main/Loader/fishit.lua"))()
end)

if not success then
	warn("⚠️ Gagal load WindUI:", WindUI)
	return
end

local Window = getgenv().LexsHubWindow or WindUI
if not Window then
	warn("❌ Tidak menemukan Window WindUI")
	return
end

-- 📱 Deteksi perangkat
local isMobileReal = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
local isEmulatorOrPC = not isMobileReal

-- 🖥️ Hanya munculkan tombol Open/Close jika PC atau Emulator
if isEmulatorOrPC then
    local ToggleUI = Instance.new("ScreenGui")
    ToggleUI.Name = "VictoriaHub_OpenClose"
    ToggleUI.IgnoreGuiInset = true
    ToggleUI.ResetOnSpawn = false
    ToggleUI.Parent = PlayerGui

    local Button = Instance.new("ImageButton")
    Button.Size = UDim2.new(0, 80, 0, 80)
    Button.Position = UDim2.new(0, 25, 0, 80)
    Button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Button.Image = "rbxassetid://134034549147826"
    Button.BorderSizePixel = 0
    Button.Draggable = true
    Button.Parent = ToggleUI

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 20)
    corner.Parent = Button

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 2.5
    stroke.Color = Color3.fromRGB(0, 255, 255)
    stroke.Parent = Button

    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40, 40, 40)}):Play()
    end)
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(25, 25, 25)}):Play()
    end)

    local open = true
    Button.MouseButton1Click:Connect(function()
        open = not open

        if typeof(Window.Toggle) == "function" then
            Window:Toggle(open)
        else
            for _, gui in ipairs(PlayerGui:GetChildren()) do
                if gui:IsA("ScreenGui") and gui.Name:lower():find("wind") and gui.Name ~= "Victoriahub_openclose" then
                    gui.Enabled = open
                end
            end
        end

        TweenService:Create(stroke, TweenInfo.new(0.25), {
            Color = open and Color3.fromRGB(0, 255, 255) or Color3.fromRGB(0, 0, 0)
        }):Play()

        print(open and "[UI Dibuka]" or "[UI Ditutup]")
    end)

    print("🖥️ PC/Emulator mode — open/close button is active")
else
    print("📱 Mobile Mode — open/close button is not displayed")
end
