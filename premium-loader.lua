if not game:IsLoaded() then
    game.Loaded:Wait()
end
print("Welcome to devry hub! loading...")
local experience_id = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Creator.CreatorTargetId

local experiences = {
    [3739465] = 'https://api.luarmor.net/files/v3/loaders/2146985311add4441096ab2fa045c43b.lua',  -- DH
    [34644452] = 'https://api.luarmor.net/files/v3/loaders/9a06c295106b79bf51a671f942cc207d.lua', -- AC
    [35789249] = 'https://api.luarmor.net/files/v3/loaders/34a51369fb7ff2ccec7ad7595ed5df59.lua', -- GAG
}

if experiences[experience_id] then
    loadstring(game:HttpGet(experiences[experience_id]))()
else
    warn("No loader found for this experience/Unsupported experience")
end
