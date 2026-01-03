local games = {
    [121864768012064] = "https://raw.githubusercontent.com/WhoIsGenn/VictoriaHub/refs/heads/main/fishit.lua",
}

local currentID = game.PlaceId
local scriptURL = games[currentID]

if scriptURL then
    loadstring(game:HttpGet(scriptURL))()
else
    game.Players.LocalPlayer:Kick("This game ain't on the list.")
end
