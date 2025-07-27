local mod = TaintedTreasure
local game = Game()
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, function(_, familiar)
    if familiar.Player:HasCollectible(TaintedCollectibles.WORMWOOD) then
		familiar:GetData().IsWormwood = true
		familiar:GetSprite():Load("gfx/familiar/familiar_starofwormwood.anm2", true)
	end
end, FamiliarVariant.STAR_OF_BETHLEHEM)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
	if familiar:GetData().IsWormwood then
		local ownerplayer = familiar.Player
		local savedata = mod.GetPersistentPlayerData(ownerplayer)
		local level = game:GetLevel()
		local roomdesc = level:GetRoomByIdx(familiar.Coins, 0)
		savedata.WormwoodScale = savedata.WormwoodScale or 0.7
		savedata.WormwoodStatus = savedata.WormwoodStatus or 0 --0 = Undetermined, 1 = Deactivated, 2 = Activated
		if familiar.Visible then
			for i, player in pairs(mod:GetAllPlayers()) do
				if familiar.Position:Distance(player.Position) < 82 then
					player:GetData().CancelStarEffect = true
					player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_TEARFLAG)
					player:EvaluateItems()
					player.TearColor = player:GetData().PreStarTearColor or player.TearColor
				elseif familiar.Position:Distance(player.Position) > 110 then
					if player:GetData().CancelStarEffect then
						player:GetData().CancelStarEffect = false
						player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_TEARFLAG)
						player:EvaluateItems()
					else
						player:GetData().PreStarTears = player.MaxFireDelay
						player:GetData().PreStarDamage = player.Damage
						if player:GetData().WormwoodEffect then
							player:GetData().PreStarTears = player.MaxFireDelay*0.7
							player:GetData().PreStarDamage = player.Damage/0.7
						end
						player:GetData().PreStarTearColor = player.TearColor
					end
				end
				if (familiar.Position:Distance(player.Position) < 80 * savedata.WormwoodScale) and savedata.WormwoodStatus ~= 1 then
					player:GetData().WormwoodEffect = true
					player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY)
					player:EvaluateItems()
				else
					player:GetData().WormwoodEffect = false
					player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY)
					player:EvaluateItems()
				end
			end
			if savedata.WormwoodStatus == 2 then
				if savedata.WormwoodScale < 10 then
					savedata.WormwoodScale = savedata.WormwoodScale + 0.01
				end
				mod:spritePlay(familiar:GetSprite(), "Open")
			else
				savedata.WormwoodScale = 0.7
				mod:spritePlay(familiar:GetSprite(), "Float")
			end
		else
			for i, player in pairs(mod:GetAllPlayers()) do
				if player:GetData().WormwoodEffect or player:GetData().CancelStarEffect then
					player:GetData().WormwoodEffect = false
					player:GetData().CancelStarEffect = false
					player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY | CacheFlag.CACHE_TEARFLAG)
					player:EvaluateItems()
				end
			end
		end
		if savedata.WormwoodStatus == 0 then
			if level:GetCurrentRoomDesc().Data.Type == RoomType.ROOM_BOSS and not familiar.Visible then
				savedata.WormwoodStatus = 1
				savedata.WormwoodTearsUps = savedata.WormwoodTearsUps or 0
				savedata.WormwoodTearsUps = savedata.WormwoodTearsUps + 1
				ownerplayer:AddCacheFlags(CacheFlag.CACHE_FIREDELAY)
				ownerplayer:EvaluateItems()
				ownerplayer:AnimateHappy()
			elseif roomdesc.Data and roomdesc.Data.Type == RoomType.ROOM_BOSS and familiar.Velocity:Length() <= 0.01 and game:GetRoom():GetFrameCount() > 1 and mod:IsPlayerInOrAdjacentToBoss() then
				if level:GetCurrentRoomIndex() ~= familiar.Coins then
					savedata.WormwoodStatus = 2
					roomdesc.Flags = roomdesc.Flags | RoomDescriptor.FLAG_FLOODED
					ownerplayer:AnimateSad()
					sfx:Stop(SoundEffect.SOUND_THUMBS_DOWN)
					sfx:Play(SoundEffect.SOUND_DEATH_CARD, 1)
				end
			end
		end
	end
end, FamiliarVariant.STAR_OF_BETHLEHEM)

mod:AddCustomCallback("GAIN_COLLECTIBLE", function(_, player, collectible)
	player:GetData().PreStarTears = player.MaxFireDelay
	player:GetData().PreStarDamage = player.Damage
end, TaintedCollectibles.WORMWOOD)

function mod:IsPlayerInOrAdjacentToBoss()
	local level = game:GetLevel()
	local start = level:GetCurrentRoomDesc()
	local indexes = mod.adjindexes[start.Data.Shape]
	if start.Data and start.Data.Type == RoomType.ROOM_BOSS then
		return true
	end
	for _, index in pairs(indexes) do
		local roomdesc = level:GetRoomByIdx(start.SafeGridIndex + index, 0)
		if roomdesc.Data and roomdesc.Data.Type == RoomType.ROOM_BOSS then
			return true
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	for i, familiar in pairs(Isaac.FindInRadius(effect.Position, 10, EntityPartition.FAMILIAR)) do
		if familiar.Variant == FamiliarVariant.STAR_OF_BETHLEHEM and familiar:GetData().IsWormwood then
			local data = familiar:GetData()
			local savedata = mod.GetPersistentPlayerData(familiar:ToFamiliar().Player)
			effect.Color = Color(0.3,1,0.3,1,0,0,0)
			if savedata.WormwoodScale then
				effect.SpriteScale = Vector(savedata.WormwoodScale,savedata.WormwoodScale)
			end
			
			if savedata.WormwoodStatus == 1 then
				effect.Visible = false
			elseif savedata.WormwoodStatus == 2 then
				effect.DepthOffset = 1000
			end
		end
	end
end, EffectVariant.HALLOWED_GROUND)