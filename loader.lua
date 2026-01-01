if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(1.2)

local WindUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/main.lua"
))()

loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/WhoIsGenn/Fish-it/main/main.lua"
))()(WindUI)

