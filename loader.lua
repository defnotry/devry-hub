repeat
    task.wait()
until game:IsLoaded()

local creator = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Creator.CreatorTargetId
print("Welcome to devry hub! loading...")
local games = {
    [3739465] = 'DungeonHeroes',
    [34644452] = 'AriseCrossover',
    [35789249] = 'GrowAGarden'
}

if games[creator] == 'DungeonHeroes' then
    loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/2146985311add4441096ab2fa045c43b.lua"))()
elseif games[creator] == 'AriseCrossover' then
    loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/9a06c295106b79bf51a671f942cc207d.lua"))()
elseif games[creator] == 'GrowAGarden' then
    -- Placeholder: Load Grow A Garden script here
    -- Example: loadstring(game:HttpGet('URL_TO_GROW_A_GARDEN_SCRIPT'))()
    print("Coming Soon")
else
    warn("Game is unsupported. Supported games: Dungeon Heroes, Arise Crossover, Grow A Garden")
    return
end
