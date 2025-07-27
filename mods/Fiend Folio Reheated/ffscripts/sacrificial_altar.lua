local mod = FiendFolio

local function turnFairyFlyIntoCandyHeart(fam)
    if fam then
        local rockCandy = Isaac.Spawn(5, 10, 2, fam.Position, Vector.Zero, fam):ToPickup()
        rockCandy.Timeout = math.floor(120)
        rockCandy:Update()
        rockCandy:GetSprite():ReplaceSpritesheet(0, "gfx/items/pick ups/rockcandy_heart.png")
        rockCandy:GetSprite():LoadGraphics()
        fam:Remove()
    end
end

local uniqueFams = {
    [mod.ITEM.FAMILIAR.ATTACK_SKUZZ] = {5,20,1},
    [mod.ITEM.FAMILIAR.FRAGILE_BOBBY] = {5,20,1},
    [mod.ITEM.FAMILIAR.MORBID_CHUNK] = {5,20,1},
    [mod.ITEM.FAMILIAR.FAIRY_FLY_1] = turnFairyFlyIntoCandyHeart,
    [mod.ITEM.FAMILIAR.FAIRY_FLY_2] = turnFairyFlyIntoCandyHeart,
    [mod.ITEM.FAMILIAR.FAIRY_FLY_3] = turnFairyFlyIntoCandyHeart,
}

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, id, rng, player, useflags)
    local triggered
    for _, fam in ipairs(Isaac.FindByType(3)) do
        if uniqueFams[fam.Variant] then
            if type(uniqueFams[fam.Variant]) == "table" then
                Isaac.Spawn(uniqueFams[fam.Variant][1],uniqueFams[fam.Variant][2],uniqueFams[fam.Variant][3], fam.Position, Vector.Zero, fam)
                fam:Remove()
            elseif type(uniqueFams[fam.Variant]) == "function" then
                turnFairyFlyIntoCandyHeart(fam)
            end
            triggered = true 
        end
    end
    if triggered then
        local storedNumOfSacAltars = player:GetCollectibleNum(id)
        mod.scheduleForUpdate(function()
            if player:GetCollectibleNum(id) == storedNumOfSacAltars then --Wasn't removed
                player:RemoveCollectible(id)
                SFXManager():Play(SoundEffect.SOUND_SATAN_GROW)
                Game():Darken(1, 60)
            end
        end, 0)
    end
end, CollectibleType.COLLECTIBLE_SACRIFICIAL_ALTAR)