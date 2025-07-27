local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

local fiddleCube = Sprite()
fiddleCube:Load("gfx/effects/fiddle_cube.anm2", true)
fiddleCube:SetFrame("Idle", 0)

local fiddleAnims = {"→","↘","↓","↙","←","↖","↑"}

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, id, rng, player)
	local d = player:GetData()
	d.storedFiddleCubeClicks = d.storedFiddleCubeClicks or {}
	local freeToAmend = true
	if #d.storedFiddleCubeClicks > 0 then
		if player.FrameCount < d.storedFiddleCubeClicks[#d.storedFiddleCubeClicks] + 15 then
			freeToAmend = false
		end
	end
	if freeToAmend then
		sfx:Play(mod.Sounds.LightSwitch,1,0,false,math.random(80,120)/100)
		table.insert(d.storedFiddleCubeClicks, player.FrameCount)
        d.currentFiddleCubeSprite = d.currentFiddleCubeSprite or 0
        fiddleCube:ReplaceSpritesheet(0, "gfx/items/collectibles/collectibles_fidget_cube_" .. d.currentFiddleCubeSprite + 1 .. ".png")
        fiddleCube:LoadGraphics()
        d.currentFiddleCubeSprite = (d.currentFiddleCubeSprite + math.random(5)) % 6
        d.currentFiddleCubeAnimation = fiddleAnims[math.random(#fiddleAnims)]

		if player:HasTrinket(mod.ITEM.ROCK.ELECTRUM) then
			local mult = mod.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.ELECTRUM)
			local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.ELECTRUM)
			mod:alternateElectrumShock(player, rng, player.Damage*mult*(#d.storedFiddleCubeClicks/3.5), player.Position, 1)
		end

		if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
			local wispCount = 0
			local storedHash = GetPtrHash(player)
			for _, currentWisp in ipairs(Isaac.FindByType(3, 206, mod.ITEM.COLLECTIBLE.FIDDLE_CUBE)) do
				if currentWisp:ToFamiliar().Player then
					if GetPtrHash(currentWisp:ToFamiliar().Player) == storedHash then
						wispCount = wispCount + 1
					end
				end
			end
			if wispCount < math.min(#d.storedFiddleCubeClicks, 5) then
				local wisp = player:AddWisp(mod.ITEM.COLLECTIBLE.FIDDLE_CUBE, player.Position)
				wisp.CollisionDamage = player.Damage * 0.1
				sfx:Play(SoundEffect.SOUND_CANDLE_LIGHT, 1, 0, false, 1)
			end
		end
	end
	player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY)
	player:EvaluateItems()
end, mod.ITEM.COLLECTIBLE.FIDDLE_CUBE)

function mod:fiddlecubePlayerUpdaet(player, d)
	if player:HasCollectible(mod.ITEM.COLLECTIBLE.FIDDLE_CUBE) then
		d.storedFiddleCubeClicks = d.storedFiddleCubeClicks or {}
		if #d.storedFiddleCubeClicks > 7 then
			table.remove(d.storedFiddleCubeClicks,1)
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY)
			player:EvaluateItems()
		end
		for i = 1, #d.storedFiddleCubeClicks do
			if d.storedFiddleCubeClicks[i] then
				if d.storedFiddleCubeClicks[i] < player.FrameCount - 150 then
					table.remove(d.storedFiddleCubeClicks,i)
					player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY)
					player:EvaluateItems()
					if player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES) then
						local wispCount = 0
						local storedHash = GetPtrHash(player)
						for _, currentWisp in ipairs(Isaac.FindByType(3, 206, mod.ITEM.COLLECTIBLE.FIDDLE_CUBE)) do
							if currentWisp:ToFamiliar().Player then
								if GetPtrHash(currentWisp:ToFamiliar().Player) == storedHash then
									wispCount = wispCount + 1
									if wispCount > math.min(#d.storedFiddleCubeClicks, 5) then
										currentWisp:Kill()
									end
								end
							end
						end
					end
				end
			end
		end
        if d.storedFiddleCubeClicks[#d.storedFiddleCubeClicks] then
            if d.storedFiddleCubeClicks[#d.storedFiddleCubeClicks] >= player.FrameCount - 5 then
                d.currentFiddleCubeAnimation = d.currentFiddleCubeAnimation or fiddleAnims[1]
                fiddleCube:SetFrame(d.currentFiddleCubeAnimation, player.FrameCount - d.storedFiddleCubeClicks[#d.storedFiddleCubeClicks])
            end
        end
	elseif d.storedFiddleCubeClicks and #d.storedFiddleCubeClicks > 0 then
		d.storedFiddleCubeClicks = {}
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY)
		player:EvaluateItems()
    end
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, function(_, player)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.FIDDLE_CUBE) then
        local fiddleCubeOffset = Vector(0,player.Size * -6)
        fiddleCube.Scale = Vector(0.5,0.5)
        local d = player:GetData()
        if d.fiddleCubeVectorOffsetDist then
            fiddleCubeOffset = fiddleCubeOffset + Vector(d.fiddleCubeVectorOffsetDist, 0):Rotated(d.fiddleCubeVectorOffsetAng)
        end
        d.storedFiddleCubeClicks = d.storedFiddleCubeClicks or {}
        local ext = 0.2 * math.min(#d.storedFiddleCubeClicks, 5)
		if mod:playerIsBelialMode(player) then
			fiddleCube.Color = Color(ext, ext, ext, ext, 0.5,-0.2,-0.2)
		else
        	fiddleCube.Color = Color(ext, ext, ext, ext)
		end
        local pos = Isaac.WorldToRenderPosition(player.Position + fiddleCubeOffset) + game:GetRoom():GetRenderScrollOffset()
        fiddleCube:Render(pos, nilvector, nilvector)
    end
end)

function mod:fiddleCubeLocustAI(locust)
	local sprite = locust:GetSprite()
	sprite.PlaybackSpeed = 0.25
end

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_,  fam)
	if fam.SubType == mod.ITEM.COLLECTIBLE.FIDDLE_CUBE then
		if fam.Player then
			fam.CollisionDamage = fam.Player.Damage * 0.1
		else
			fam.CollisionDamage = 1
		end
	end
end, FamiliarVariant.WISP)