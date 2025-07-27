local mod = FiendFolio
local game = Game()

FiendFolio.AddItemPickupCallback(function(player, added)
    if player:GetCollectibleNum(mod.ITEM.COLLECTIBLE.CHIRUMIRU) == 9 then
        SFXManager():Play(SoundEffect.SOUND_POWERUP_SPEWER)
        game:GetHUD():ShowItemText("Cirno!", "9. Idiot.")
    end
end, nil, mod.ITEM.COLLECTIBLE.CHIRUMIRU)
