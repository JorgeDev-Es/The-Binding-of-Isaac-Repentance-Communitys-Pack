local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

if StageAPI and StageAPI.Loaded then
    StageAPI.AddPlayerGraphicsInfo(FiendFolio.PLAYER.FEND, {
        Name = "gfx/ui/boss/playername_fend.png",
        Portrait = "gfx/ui/stage/playerportrait_fend.png",
        NoShake = false
    })
end

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player)
	if player:GetPlayerType() == mod.PLAYER.FEND then
		player.Damage = player.Damage * 0.2
	end
end, CacheFlag.CACHE_DAMAGE)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player)
	if player:GetPlayerType() == mod.PLAYER.FEND then
		player.TearFlags = player.TearFlags | TearFlags.TEAR_SHIELDED
	end
end, CacheFlag.CACHE_TEARFLAG)

local fendSwords = {
    [10] = "spirit_sword_fend",
    --[11] = "spirit_sword_tech_fend",
}

mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, function(_, knife) -- Mom's Knife
    if knife.FrameCount <= 0 then
        local knifeVar = knife.Variant
        if fendSwords[knifeVar] then
            if knife.Parent and knife.Parent.Type == 1 then
                local p = knife.Parent:ToPlayer()
                if p:GetPlayerType() == mod.PLAYER.FEND then
                    local sprite = knife:GetSprite()
                    for i = 0, 4 do
                        sprite:ReplaceSpritesheet(i, "gfx/effects/" .. fendSwords[knifeVar] .. ".png")
                    end
                    sprite:LoadGraphics()
                end
            end
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, function(_, tear)
    if tear.SpawnerEntity and tear.SpawnerEntity.Type == 1 then
        local p = tear.SpawnerEntity:ToPlayer()
        if p:GetPlayerType() == mod.PLAYER.FEND then
            tear:GetData().isFend = true
            local sprite = tear:GetSprite()
            sprite:Load("gfx/effects/spiritsword_fend_proj.anm2")
            sprite:Play("Idle")
        end
    end
end, 47)

--[[mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, function(_, tear)
    if tear.SpawnerEntity and tear.SpawnerEntity.Type == 1 then
        local p = tear.SpawnerEntity:ToPlayer()
        if p:GetPlayerType() == mod.PLAYER.FEND then
            tear:GetData().isFend = true
            local sprite = tear:GetSprite()
            sprite:ReplaceSpritesheet(0, "gfx/effects/spirit_sword_tech_fend.png")
            sprite:LoadGraphics()
        end
    end
end, 49)]]

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, e)
    if e.SubType == 22 then
        for _, en in pairs(Isaac.FindByType(2, 47, -1)) do
            if en:GetData().isFend then
                if e.Position:Distance(en.Position) <= 1 then
                    local sprite = e:GetSprite()
                    sprite:Load("gfx/effects/spiritsword_fend_proj_poof.anm2")
                    sprite:Play("Idle")
                end
            end
        end
    end
end, 12)