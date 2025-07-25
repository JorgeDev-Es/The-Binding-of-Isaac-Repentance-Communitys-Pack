local mod = MattPack
local game = mod.constants.game
local sfx = mod.constants.sfx

if EID then
    EID:addCollectible(MattPack.Items.MultiMush, "{{MegaArrowUp}} x2 multiplier to all stats, including deal and planetarium chance#Multiplied stats can go past their usual caps#{{Heart}} Doubles max heart containers#{{Warning}} Increases the speed of all enemies and projectiles")
    mod.appendToDescription(CollectibleType.COLLECTIBLE_MAGIC_MUSHROOM, 'by losing a {{GoldenHeart}} {{ColorYellow}}Gold Heart{{CR}}', true)
end
mod.playerIsGolden = true

function mod:statDouble(player, flag)
    local multiplier = player:GetCollectibleNum(MattPack.Items.MultiMush) + 1
    if multiplier > 1 then
        if flag == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage * multiplier
        elseif flag == CacheFlag.CACHE_FIREDELAY then
            player.MaxFireDelay = player.MaxFireDelay / multiplier
        elseif flag == CacheFlag.CACHE_SHOTSPEED then
            player.ShotSpeed = player.ShotSpeed * multiplier
        elseif flag == CacheFlag.CACHE_RANGE then
            player.TearRange = player.TearRange * multiplier
        elseif flag == CacheFlag.CACHE_SPEED then
            player:GetData().setSpeed = player.MoveSpeed * multiplier
        elseif flag == CacheFlag.CACHE_LUCK then
            player.Luck = player.Luck * multiplier
        elseif flag == CacheFlag.CACHE_SIZE then
            player.SpriteScale = player.SpriteScale / (Vector.One / player.SpriteScale)
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_EVALUATE_CACHE, CallbackPriority.LATE + 1, mod.statDouble)

function mod:statDouble2(player)
    local sprite = player:GetSprite()
    if player:HasCollectible(MattPack.Items.MultiMush) then
        if player:GetData().setSpeed then
            local multiplier = player:GetCollectibleNum(MattPack.Items.MultiMush) + 1
            player.MoveSpeed = math.min(2 * multiplier, player:GetData().setSpeed)
        end
        mod.playerIsGolden = true
        sprite:SetRenderFlags(sprite:GetRenderFlags() | AnimRenderFlags.GOLDEN)
        for _,desc in ipairs(player:GetCostumeSpriteDescs()) do
            local costumeSprite = desc:GetSprite()
            if costumeSprite:GetLayer("head") or costumeSprite:GetLayer("body") then
                costumeSprite:SetRenderFlags(sprite:GetRenderFlags() | AnimRenderFlags.GOLDEN)
            end
        end
    elseif mod.playerIsGolden then
        mod.playerIsGolden = nil
        sprite:SetRenderFlags(sprite:GetRenderFlags() & ~(AnimRenderFlags.GOLDEN))
        for _,desc in ipairs(player:GetCostumeSpriteDescs()) do
            local costumeSprite = desc:GetSprite()
            if costumeSprite:GetLayer("head") or costumeSprite:GetLayer("body") then
                costumeSprite:SetRenderFlags(sprite:GetRenderFlags() & ~(AnimRenderFlags.GOLDEN))
            end
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, CallbackPriority.LATE, mod.statDouble2)

function mod:knockbackDouble(ent)
    local player = ent.SpawnerEntity and ent.SpawnerEntity:ToPlayer()
    if player and player:HasCollectible(MattPack.Items.MultiMush) then
        local multiplier = player:GetCollectibleNum(MattPack.Items.MultiMush) + 1
        ent.KnockbackMultiplier = ent.KnockbackMultiplier * multiplier
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_TEAR_INIT, CallbackPriority.LATE, mod.knockbackDouble)

function mod:mmDealChance(chance)
    if PlayerManager.AnyoneHasCollectible(MattPack.Items.MultiMush) then
        local multiplier = PlayerManager.GetNumCollectibles(MattPack.Items.MultiMush) + 1
        return chance * multiplier
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_DEVIL_CALCULATE, CallbackPriority.EARLY, mod.mmDealChance)
mod:AddPriorityCallback(ModCallbacks.MC_POST_PLANETARIUM_CALCULATE, CallbackPriority.EARLY, mod.mmDealChance)

function mod:mmHeartLimit(player, limit)
    if player:HasCollectible(MattPack.Items.MultiMush) then
        local multiplier = player:GetCollectibleNum(MattPack.Items.MultiMush) + 1
        return limit * multiplier
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_PLAYER_GET_HEART_LIMIT, CallbackPriority.EARLY, mod.mmHeartLimit)




mod.npcSpeedMulti = 1.5

mod.speedMultiBlacklist = { -- [type] == {{variant, subtype}, {variant, subtype}, etc}
    [808] = true,
    [450] = {{33}},
    [876] = {{0}},
    [311] = true,
}

function mod:npcSpeedupPre(npc)
    if PlayerManager.AnyoneHasCollectible(MattPack.Items.MultiMush) and npc:IsActiveEnemy() then
        local data = npc:GetData()
        if not data.parriable then
            local speedMulti = mod.npcSpeedMulti or 1.5
            npc:SetSpeedMultiplier(npc:GetSpeedMultiplier() * speedMulti)
        end
        data.preUpdateSpeed = npc.Velocity
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_UPDATE, CallbackPriority.LATE, mod.npcSpeedupPre)

function mod:npcSpeedup(npc)
    if PlayerManager.AnyoneHasCollectible(MattPack.Items.MultiMush) and npc:IsActiveEnemy() then
        local dontChangeVel = false
        local blacklistEntry = mod.speedMultiBlacklist[npc.Type]
        if blacklistEntry then
            if blacklistEntry == true then
                dontChangeVel = true
            else
                for _,id in ipairs(mod.speedMultiBlacklist[npc.Type]) do
                    if id == true or (not id[1] or id[1] == npc.Variant) and (not id[2] or id[2] == npc.SubType) then
                        dontChangeVel = true
                    end 
                end
            end
        else
            local speedMulti = mod.npcSpeedMulti or 1.5
            local data = npc:GetData()
            if (not dontChangeVel) and npc.Mass < 100 and (not npc.ParentNPC) and data.preUpdateSpeed then
                local velDiff = (npc.Velocity - data.preUpdateSpeed) / 2
                npc.Velocity = npc.Velocity + (velDiff * (speedMulti - 1))
            end
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_NPC_UPDATE, CallbackPriority.IMPORTANT - 50, mod.npcSpeedup)

function mod:shotSpeeds(projectile)
    if PlayerManager.AnyoneHasCollectible(MattPack.Items.MultiMush) then
        local speedMulti = mod.npcSpeedMulti or 1.5
        projectile.Velocity = projectile.Velocity * speedMulti
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_PROJECTILE_INIT, CallbackPriority.LATE, mod.shotSpeeds)

function mod:shotSpeedsArcPre(projectile)
    if PlayerManager.AnyoneHasCollectible(MattPack.Items.MultiMush) and projectile.FrameCount == 1 then
        projectile:GetData().preUpdateFallingSpeed = projectile.FallingSpeed
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_PROJECTILE_UPDATE, CallbackPriority.LATE, mod.shotSpeedsArcPre)

function mod:shotSpeedsArcPost(projectile)
    if PlayerManager.AnyoneHasCollectible(MattPack.Items.MultiMush) and projectile.FrameCount == 1 then
        local data = projectile:GetData()
        if data.preUpdateFallingSpeed then
            local speedDiff = projectile.FallingSpeed - data.preUpdateFallingSpeed
            local speedMulti = mod.npcSpeedMulti or 1.5
            if projectile.FrameCount == 1 then
                speedMulti = speedMulti * 2
            end
            projectile.FallingSpeed = projectile.FallingSpeed + (speedDiff * speedMulti)
            data.preUpdateFallingSpeed = nil
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, CallbackPriority.EARLY, mod.shotSpeedsArcPost)



function mod:checkGoldHeartPre(ent)
    local player = ent:ToPlayer()
    if player and player:GetGoldenHearts() then
        player:GetData().lastGoldenHearts = player:GetGoldenHearts()
    end
end
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, mod.checkGoldHeartPre)

function mod:checkGoldHeartPost(ent)
    local player = ent:ToPlayer()
    if player then
        local data = ent:GetData()
        if data.lastGoldenHearts and data.lastGoldenHearts > player:GetGoldenHearts() then
            local isGold = false
            for _,pedestal in ipairs(Isaac.FindByType(5, 100, 12)) do
                if not isGold then
                    game:GetRoom():TurnGold()
                    isGold = true
                end
                pedestal:ToPickup():Morph(5, 100, MattPack.Items.MultiMush, true)
                mod.constants.pool:RemoveCollectible(MattPack.Items.MultiMush)
                pedestal:SetColor(Color(0, 0, 0, 1, 1, .85, 0), 30, 999, true, true)
                pedestal:GetSprite():GetLayer(0):SetRenderFlags(AnimRenderFlags.GOLDEN)
                pedestal:GetSprite():GetLayer(5):SetRenderFlags(AnimRenderFlags.GOLDEN)
            end
            sfx:Play(SoundEffect.SOUND_MUSHROOM_POOF_2, 1, nil, nil, .75)
        end
        data.lastGoldenHearts = nil
    end
end
mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, mod.checkGoldHeartPost)