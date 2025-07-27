local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

if StageAPI and StageAPI.Loaded then
    StageAPI.AddPlayerGraphicsInfo(FiendFolio.PLAYER.FIENT, {
        Name = "gfx/ui/boss/playername_fient.png",
        Portrait = "gfx/ui/stage/playerportrait_fient.png",
        NoShake = false
    })
end

function mod:fientPlayerUpdate(player, data)
	if player:GetPlayerType() == mod.PLAYER.FIENT then
		local sprite = player:GetSprite()
		if sprite:IsPlaying("Happy") and sprite:GetFrame() == 5 then
			if not data.fientWhipcracked then
				sfx:Play(mod.Sounds.WhipCrack, 1, 0, false, 1)
				data.fientWhipcracked = true
			end
		else
			data.fientWhipcracked = false
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function(_, player)
	if player:GetPlayerType() == mod.PLAYER.FIENT then
        mod:AddMorbidHearts(player, 3)
        --player:AddCollectible(mod.ITEM.COLLECTIBLE.DEVILS_HARVEST, 0, true)
        player:AddTrinket(FiendFolio.ITEM.TRINKET.CHILI_POWDER)
		player:SetPocketActiveItem(CollectibleType.COLLECTIBLE_WAVY_CAP, ActiveSlot.SLOT_POCKET, false)
	end
end, 0)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player)
	if player:GetPlayerType() == mod.PLAYER.FIENT then
		player.MaxFireDelay = player.MaxFireDelay * 3
	end
end, CacheFlag.CACHE_FIREDELAY)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player)
	if player:GetPlayerType() == mod.PLAYER.FIENT then
		player.Damage = player.Damage * 4.057
	end
end, CacheFlag.CACHE_DAMAGE)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player)
	if player:GetPlayerType() == mod.PLAYER.FIENT then
		player.TearFlags = player.TearFlags | TearFlags.TEAR_CONFUSION
	end
end, CacheFlag.CACHE_TEARFLAG)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player)
	if player:GetPlayerType() == mod.PLAYER.FIENT then
		player.TearColor = FiendFolio.ColorGreyscale
	end
end, CacheFlag.CACHE_TEARCOLOR)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player)
	if player:GetPlayerType() == mod.PLAYER.FIENT then
		player.ShotSpeed = player.ShotSpeed * 0.420
	end
end, CacheFlag.CACHE_SHOTSPEED)

mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, function(_, player)
	if player:GetPlayerType() == mod.PLAYER.FIENT then
		player.TearRange = player.TearRange - 92
	end
end, CacheFlag.CACHE_RANGE)

function mod:fientPostFire(player, tear, rng, pdata, tdata)
	if player:GetPlayerType() == mod.PLAYER.FIENT then
		sfx:Play(mod.Sounds.AGWheeze, 1, 0, false, 1)
		for i = -30, 30, 30 do
			local smoke = Isaac.Spawn(1000, mod.FF.FFWhiteSmoke.Var, mod.FF.FFWhiteSmoke.Sub, tear.Position, tear.Velocity:Resized(3):Rotated(i), npc)
			--smoke.SpriteScale = Vector(1,1)
			smoke.SpriteOffset = Vector(0, -10)
			smoke.Color = Color(1,1,1,0.2)
			smoke:GetData().longonly = true
			smoke:Update()
		end
	end
end