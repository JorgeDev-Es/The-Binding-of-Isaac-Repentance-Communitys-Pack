local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

function mod:sapphicSapphireFire(player, tear, rng, pdata, tdata)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.SAPPHIC_SAPPHIRE) then
        local trinketPower = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SAPPHIC_SAPPHIRE)
        local chance = math.min(5 + player.Luck * 2, 20) * trinketPower
        if rng:RandomInt(60) < chance then
            tear.Color = Color(0.7, 0.7, 1, 1, -0.1, -0.1, 0.1)
            tear.TearFlags = tear.TearFlags | TearFlags.TEAR_ICE | TearFlags.TEAR_SLOW
        end
    end
end

function mod:sapphicSapphirePostFireBomb(player, bomb, rng, pdata, bdata)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.SAPPHIC_SAPPHIRE) then
        local trinketPower = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SAPPHIC_SAPPHIRE)
        local chance = math.min(5 + player.Luck * 2, 20) * trinketPower
        if rng:RandomInt(60) < chance then
            bomb.Color = Color(0.7, 0.7, 1, 1, -0.1, -0.1, 0.1)
            bomb.Flags = bomb.Flags | TearFlags.TEAR_ICE | TearFlags.TEAR_SLOW
        end
    end
end

function mod:sapphicSapphireOnRocketFire(player, target)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.SAPPHIC_SAPPHIRE) then
        local trinketPower = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SAPPHIC_SAPPHIRE)
        local chance = math.min(5 + player.Luck * 2, 20) * trinketPower
        if player:GetTrinketRNG(FiendFolio.ITEM.ROCK.SAPPHIC_SAPPHIRE):RandomInt(60) < chance then
			local data = target:GetData()

			data.ApplySapphicSapphireFreeze = true
        end
    end
end

function mod:sapphicSapphireOnFireAquarius(player, creep, secondHandMultiplier)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.SAPPHIC_SAPPHIRE) then
        local trinketPower = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SAPPHIC_SAPPHIRE)
        local chance = math.min(5 + player.Luck * 2, 20) * trinketPower
        if player:GetTrinketRNG(FiendFolio.ITEM.ROCK.SAPPHIC_SAPPHIRE):RandomInt(60) < chance then
			local data = creep:GetData()

			data.ApplySapphicSapphireFreeze = true

			local color = Color(0.3, 0.7, 1, 1, -0.2, -0.1, 0.3)
			data.FFAquariusColor = color
        end
    end
end

function mod:sapphicSapphireFireRocketAquariusDamage(source, entity, data)
    if data.ApplySapphicSapphireFreeze then
        entity:AddSlowing(EntityRef(Isaac.GetPlayer()), 60, 0.5, Color(1.2,1.2,1.2,1,0,0,0.1))
        entity:AddEntityFlags(EntityFlag.FLAG_ICE)
        entity:GetData().PeppermintSlowed = true
    end
end

function mod:sapphicSapphireOnGenericDamage(player, entity)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.SAPPHIC_SAPPHIRE) then
        local trinketPower = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.SAPPHIC_SAPPHIRE)
        local chance = math.min(5 + player.Luck * 2, 20) * trinketPower
        if player:GetTrinketRNG(FiendFolio.ITEM.ROCK.SAPPHIC_SAPPHIRE):RandomInt(60) < chance then
            entity:AddSlowing(EntityRef(player), 60, 0.5, Color(1.2,1.2,1.2,1,0,0,0.1))
			entity:AddEntityFlags(EntityFlag.FLAG_ICE)
			entity:GetData().PeppermintSlowed = true
        end
    end
end

function mod:tryMakeLaserSapphic(laser)
    if laser.Variant == 1 then
        local sprite = laser:GetSprite()
        sprite:Load("gfx/effects/sapphicsapphire/effect_lesbeam.anm2")
        sprite:Play("LargeRedLaser", true)
        laser:GetData().SapphicSapphireLesbianBeam = true
        return true
    elseif laser.Variant == 9 then
        local sprite = laser:GetSprite()
        sprite:Load("gfx/effects/sapphicsapphire/effect_lestech.anm2")
        sprite:Play("LargeRedLaser", true)
        laser:GetData().SapphicSapphireLesbianBeam = true
        return true
    end
end

--Here for ease/consistency ig
function mod:tryMakeLaserTrans(laser)
    if laser.Variant == 1 then
        local sprite = laser:GetSprite()
        sprite:Load("gfx/effects/sapphicsapphire/effect_transbeam.anm2")
        sprite:Play("LargeRedLaser", true)
        laser:GetData().TransRightsAreHumanRightsBeam = true
        return true
    elseif laser.Variant == 11 then
        local sprite = laser:GetSprite()
        sprite:Load("gfx/effects/sapphicsapphire/effect_transbeam_big.anm2")
        sprite:Play("LargeRedLaser", true)
        laser:GetData().TransRightsAreHumanRightsBeamBig = true
        return true
    end
end
function mod:tryMakeLaserEmoji(laser)
    if laser.Variant == 1 then
        local sprite = laser:GetSprite()
        sprite:Load("gfx/effects/sapphicsapphire/effect_emojibeam.anm2")
        sprite:Play("LargeRedLaser", true)
        laser:GetData().EmojisAreInTheBeam = true
        return true
    end
end

function mod:sapphicSapphireFireLaser(player, laser, rng)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.SAPPHIC_SAPPHIRE) or player:HasTrinket(FiendFolio.ITEM.ROCK.HOMOEROTIC_RUBY) or player:HasTrinket(FiendFolio.ITEM.ROCK.GAY_GARNET) then
        mod:tryMakeLaserSapphic(laser)
    end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, npc)
    if npc.FrameCount == 0 then
        if npc.Parent:GetData().SapphicSapphireLesbianBeam then
            local sprite = npc:GetSprite()
            sprite:Load("gfx/effects/sapphicsapphire/effect_lesbeam_impact.anm2")
            sprite:Play("Start", true)
        elseif npc.Parent:GetData().TransRightsAreHumanRightsBeam then
            local sprite = npc:GetSprite()
            sprite:Load("gfx/effects/sapphicsapphire/effect_transbeam_impact.anm2")
            sprite:Play("Start", true)
        elseif npc.Parent:GetData().TransRightsAreHumanRightsBeamBig then
            local sprite = npc:GetSprite()
            sprite:Load("gfx/effects/sapphicsapphire/effect_transbeam_impact_big.anm2")
            sprite:Play("Start", true)
        elseif npc.Parent:GetData().EmojisAreInTheBeam then
            local sprite = npc:GetSprite()
            sprite:Load("gfx/effects/sapphicsapphire/effect_emojibeam_impact.anm2")
            sprite:Play("Start", true)
        end
    end
end, EffectVariant.LASER_IMPACT)

mod:AddCallback(ModCallbacks.MC_POST_NPC_INIT, function(_, npc)
    --oh I was going to do more support but it doesn't actually need it after the second hand rewrite, I guess mult doesn't matter
    if mod.anyPlayerHas(FiendFolio.ITEM.ROCK.SAPPHIC_SAPPHIRE, true) or mod.anyPlayerHas(FiendFolio.ITEM.ROCK.GAY_GARNET, true) then
        for j = 1, game:GetNumPlayers() do
            local isWoman
            local p = Isaac.GetPlayer(j - 1)
            local secondHand = p:GetTrinketMultiplier(TrinketType.TRINKET_SECOND_HAND) + 1

            for i = 1, #FiendFolio.Nonmale do
                if FiendFolio.Nonmale[i].ID
                and (npc.Type == FiendFolio.Nonmale[i].ID[1]) 
                and ((not FiendFolio.Nonmale[i].ID[2]) or npc.Variant == FiendFolio.Nonmale[i].ID[2]) 
                and ((not FiendFolio.Nonmale[i].ID[3]) or npc.SubType == FiendFolio.Nonmale[i].ID[3]) 
                and FiendFolio.Nonmale[i].Affliction == "Woman"
                then
                    isWoman = true
                    break
                end
            end

            if isWoman then
                npc:AddCharmed(EntityRef(p), 300*secondHand)
                if mod.WomanMode > 0 then
                    sfx:Stop(mod.Sounds.WomanRevealer)
                    sfx:Play(mod.Sounds.WomanRevealer, 4, 0, false, 1)
                    mod:ShowFortune("Woman", true)
                    game:GetHUD():ShowItemText("Woman", "This is a woman")
                    local e = Isaac.Spawn(mod.FF.WomanIndicator.ID, mod.FF.WomanIndicator.Var, mod.FF.WomanIndicator.Sub, npc.Position, Vector.Zero, p):ToEffect()
                    e.SpriteOffset = Vector(0, -30 + npc.Size * -1.0)
                    e:FollowParent(npc)
                    e.DepthOffset = 20
                end
                break
            end
        end
    elseif mod.WomanMode == 2 then
        local isWoman
        for i = 1, #FiendFolio.Nonmale do
            if FiendFolio.Nonmale[i].ID
            and (npc.Type == FiendFolio.Nonmale[i].ID[1]) 
            and ((not FiendFolio.Nonmale[i].ID[2]) or npc.Variant == FiendFolio.Nonmale[i].ID[2]) 
            and ((not FiendFolio.Nonmale[i].ID[3]) or npc.SubType == FiendFolio.Nonmale[i].ID[3]) 
            and FiendFolio.Nonmale[i].Affliction == "Woman"
            then
                isWoman = true
                break
            end
        end
        if isWoman then
            sfx:Stop(mod.Sounds.WomanRevealer)
            sfx:Play(mod.Sounds.WomanRevealer, 4, 0, false, 1)
            mod:ShowFortune("Woman", true)
            game:GetHUD():ShowItemText("Woman", "This is a woman")
            local e = Isaac.Spawn(mod.FF.WomanIndicator.ID, mod.FF.WomanIndicator.Var, mod.FF.WomanIndicator.Sub, npc.Position, Vector.Zero, npc):ToEffect()
            e.SpriteOffset = Vector(0, -30 + npc.Size * -1.0)
            e:FollowParent(npc)
            e.DepthOffset = 20
        end
    end
end)