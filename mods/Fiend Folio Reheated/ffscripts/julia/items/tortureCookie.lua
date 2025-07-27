--TODO: adjust drop rates?
--      pity system if you don't get payouts for too long
--      cyanide pills as a rare drop?

--torture cookie >:)
local mod = FiendFolio
local game = Game()

local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, id, rng, player, useflags, activeslot, customvardata)
    if player:TakeDamage(1, (DamageFlag.DAMAGE_RED_HEARTS | DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_INVINCIBLE | DamageFlag.DAMAGE_IV_BAG), EntityRef(player), 0) then

        Isaac.Spawn(1000, 2, 0, player.Position, Vector.Zero, player)

        local r = player:GetCollectibleRNG(mod.ITEM.COLLECTIBLE.TORTURE_COOKIE)

        local chance = r:RandomInt(100) + 1
        local hud = game:GetHUD()

        local room = game:GetRoom()
        local pos = room:FindFreePickupSpawnPosition(player.Position, 40, true)

        sfx:Play(SoundEffect.SOUND_FORTUNE_COOKIE)

        if chance < 3 then
            Isaac.Spawn(5, 350, mod.GetItemFromCustomItemPool(mod.CustomPool.TORTURE_COOKIE_TRINKETS, r), pos, Vector.Zero, nil) --evil trinket
        elseif chance < 17 then
            Isaac.Spawn(5, 300, math.random(56, 77), pos, Vector.Zero, nil) --reverse tarot card
        elseif chance < 33 then
            Isaac.Spawn(5, 10, 6, pos, Vector.Zero, nil) --black heart
        else
            mod:ShowTortune()
        end

        return true
    end
end, mod.ITEM.COLLECTIBLE.TORTURE_COOKIE)
