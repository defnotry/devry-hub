if not game:IsLoaded() then
    game.Loaded:Wait()
end
print("Welcome to devry hub! loading...")
local experience_id = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Creator.CreatorTargetId

local experiences = {
    [3739465] = 'https://api.luarmor.net/files/v3/loaders/2146985311add4441096ab2fa045c43b.lua',  -- DH
    [34644452] = 'https://api.luarmor.net/files/v3/loaders/3bbc2fb333727745623a2e9e69d7b8a3.lua', -- AC
    [35789249] = 'https://api.luarmor.net/files/v3/loaders/34a51369fb7ff2ccec7ad7595ed5df59.lua', -- GAG
}

if experiences[experience_id] then
    loadstring(game:HttpGet(experiences[experience_id]))()
else
    warn("No loader found for this experience/Unsupported experience")
end
