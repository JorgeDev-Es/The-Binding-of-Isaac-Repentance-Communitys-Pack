local mod = FiendFolio
local game = Game()

local realColor = Color(0.7, 0.7, 0.7, 1, 0, 0, 0)
realColor:SetColorize(0.5, 0.5, 0.5, 1)

function mod:chunkOfGalliumOnFireTear(player, tear, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.CHUNK_OF_GALLIUM) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.CHUNK_OF_GALLIUM)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.CHUNK_OF_GALLIUM)
		local chance = 15*mult+mod.XalumLuckBonus(player.Luck, 20, 0.3)*100

		if rng:RandomInt(100) < chance then
			tear:GetData().chunkOfGalliumTear = true
			tear.Color = realColor
			tear:Update()
		end
	end
end

function mod:chunkOfGalliumTearUpdate(tear, d)
    if d.chunkOfGalliumTear then
        if Isaac.CountEntities(nil, 1000, EffectVariant.PLAYER_CREEP_BLACK, -1) < 100 then
            local creep = Isaac.Spawn(1000, EffectVariant.PLAYER_CREEP_BLACK, 0, tear.Position, Vector.Zero, tear):ToEffect()
            creep.Color = Color(1, 1, 1, 1, 0.45, 0.45, 0.45)
            creep.Scale = math.max(0.2, tear.Scale-0.5)
            creep:Update()
        elseif tear.FrameCount % 3 == 0 then
            local creep = Isaac.Spawn(1000, EffectVariant.PLAYER_CREEP_BLACK, 0, tear.Position, Vector.Zero, tear):ToEffect()
            creep.Color = Color(1, 1, 1, 1, 0.45, 0.45, 0.45)
            creep.Scale = math.max(0.2, tear.Scale-0.5)
            creep:Update()
        end
    end
end

function mod:chunkOfGalliumOnFireKnife(player, knife)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.CHUNK_OF_GALLIUM) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.CHUNK_OF_GALLIUM)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.CHUNK_OF_GALLIUM)
		local chance = 15*mult+mod.XalumLuckBonus(player.Luck, 20, 0.3)*100

		if rng:RandomInt(100) < chance then
			knife:GetData().chunkOfGalliumKnife = true
		end
	end
end

function mod:chunkOfGalliumKnifeUpdate(player, knife, data)
    if data.chunkOfGalliumKnife then
        if knife.FrameCount % 2 == 0 then
            local creep = Isaac.Spawn(1000, EffectVariant.PLAYER_CREEP_BLACK, 0, knife.Position, Vector.Zero, player):ToEffect()
            creep.Color = Color(1, 1, 1, 1, 0.45, 0.45, 0.45)
            creep:Update()
        end
    end
end

function mod:chunkOfGalliumKnifeReset(player, knife, data)
    data.chunkOfGalliumKnife = nil
end

function mod:chunkOfGalliumOnFireBomb(player, bomb, secondHandMultiplier)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.CHUNK_OF_GALLIUM) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.CHUNK_OF_GALLIUM)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.CHUNK_OF_GALLIUM)
		local chance = 15*mult+mod.XalumLuckBonus(player.Luck, 20, 0.3)*100

		if rng:RandomInt(100) < chance then
			bomb:GetData().chunkOfGalliumBomb = true

            bomb.Color = realColor
		end
	end
end

function mod:chunkOfGalliumBombUpdate(bomb, data)
    if data.chunkOfGalliumBomb then
        local creep = Isaac.Spawn(1000, EffectVariant.PLAYER_CREEP_BLACK, 0, bomb.Position, Vector.Zero, bomb):ToEffect()
        creep.Color = Color(1, 1, 1, 1, 0.45, 0.45, 0.45)
        creep:Update()
    end
end

function mod:chunkOfGalliumOnFireLaser(player, laser)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.CHUNK_OF_GALLIUM) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.CHUNK_OF_GALLIUM)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.CHUNK_OF_GALLIUM)
		local chance = 15*mult+mod.XalumLuckBonus(player.Luck, 20, 0.3)*100

		if rng:RandomInt(100) < chance then
            mod.scheduleForUpdate(function()
                local list = laser:GetNonOptimizedSamples()
                for i=1,list.Size-1 do
                    if i % 3 == 0 then
                        local creep = Isaac.Spawn(1000, EffectVariant.PLAYER_CREEP_BLACK, 0, list:Get(i), Vector.Zero, player):ToEffect()
                        creep.Color = Color(1, 1, 1, 1, 0.45, 0.45, 0.45)
                        if laser.Variant == LaserVariant.THIN_RED or laser.Variant == LaserVariant.THICKER_RED then
                            creep.Scale = 0.7
                        end
                        creep:Update()
                    end
                end
            end, 0)
		end
	end
end

function mod:chunkOfGalliumOnFireRocket(player, target, secondHandMultiplier)
	if player:HasTrinket(FiendFolio.ITEM.ROCK.CHUNK_OF_GALLIUM) then
		local mult = FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.CHUNK_OF_GALLIUM)
		local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.CHUNK_OF_GALLIUM)
		local chance = 15*mult+mod.XalumLuckBonus(player.Luck, 20, 0.3)*100

		if rng:RandomInt(100) < chance then
			target:GetData().chunkOfGalliumTarget = true
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, target)
	if target:GetData().chunkOfGalliumTarget then
        if target.FrameCount % 2 == 0 then
            local creep = Isaac.Spawn(1000, EffectVariant.PLAYER_CREEP_BLACK, 0, target.Position, Vector.Zero, target):ToEffect()
            creep.Color = Color(1, 1, 1, 1, 0.45, 0.45, 0.45)
            creep:Update()
        end
    end
end, EffectVariant.TARGET)