local mod = TaintedTreasure
local game = Game()
local sfx = SFXManager()

mod.savedata.PersistentEntityData = {}

function mod:GetPersistentEntityData(entity)
    local index = entity.InitSeed..""
    if not mod.savedata.PersistentEntityData[index] then
        mod.savedata.PersistentEntityData[index] = {}
    end
    return mod.savedata.PersistentEntityData[index], index
end

mod:AddCustomCallback("SLOT_UPDATE", function(_, slot)
    local rng = slot:GetDropRNG()
    local sprite = slot:GetSprite()
    local data, index = mod:GetPersistentEntityData(slot)

    data.CoinsPayed = data.CoinsPayed or 0
    data.CoinsTilPayout = data.CoinsTilPayout or 6
    data.ItemChance = data.ItemChance or 0.25
    --slot.SpriteOffset = Vector(0,5)

    if sprite:IsFinished("PayNothing") or sprite:IsFinished("Prize") then
        sprite:Play("Idle")
    elseif sprite:IsFinished("PayPrize") then
        sprite:Play("Prize")
    elseif sprite:IsFinished("Teleport") then
        slot:Remove()
    end

    if sprite:IsEventTriggered("Prize") then
        sfx:Play(SoundEffect.SOUND_SLOTSPAWN)
        if rng:RandomFloat() <= data.ItemChance then
            mod:TaintedBeggarItem(slot)
            mod.savedata.spawnchancemultiplier = mod.savedata.spawnchancemultiplier + 0.5
            sprite:Play("Teleport")
            slot.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
        else
            mod:TaintedBeggarPayout(slot)
            data.ItemChance = data.ItemChance + 0.25
        end
    end

    if slot.GridCollisionClass == 5 then --Blown up
		slot:BloodExplode()
        slot:Remove()
    end
end, TaintedMachines.TAINTED_BEGGAR)

mod:AddCustomCallback("SLOT_TOUCH", function(_, player, slot)
    local rng = slot:GetDropRNG()
    local sprite = slot:GetSprite()
    local data, index = mod:GetPersistentEntityData(slot)
    if sprite:GetAnimation() == "Idle" then
        if player:GetNumCoins() > 0 then
            player:AddCoins(-1)
            data.CoinsPayed = data.CoinsPayed + 1
            --print(data.CoinsPayed)
            sfx:Play(SoundEffect.SOUND_SCAMPER)
            if data.CoinsTilPayout <= 0 then
                data.CoinsTilPayout = mod:RandomInt(4,8,rng)
                sprite:Play("PayPrize")
				
				if tmmc then
					tmmc.enable[TaintedMachines.TAINTED_BEGGAR] = false
					tmmc:find_slot()
					sprite.PlaybackSpeed = 1.5
				end
            else
                data.CoinsTilPayout = data.CoinsTilPayout - 1
                sprite:Play("PayNothing")
            end
        end
    end
end, TaintedMachines.TAINTED_BEGGAR)

function mod:TaintedBeggarPayout(slot)
    local roll = slot:GetDropRNG():RandomFloat()
    local vec = RandomVector() * 5
    if roll <= 0.2 then --Cracked Key
        Isaac.Spawn(5, 300, Card.CARD_CRACKED_KEY, slot.Position, vec, slot)
    elseif roll <= 0.5 then --Trinket
        Isaac.Spawn(5, 69, 0, slot.Position, vec, slot)
    else --Sack
        Isaac.Spawn(5, 350, 0, slot.Position, vec, slot)
    end
	if tmmc then
		tmmc.enable[TaintedMachines.TAINTED_BEGGAR] = true
		tmmc:find_slot()
		slot:GetSprite().PlaybackSpeed = 1
	end
end

function mod:TaintedBeggarItem(slot)
    local rng = slot:GetDropRNG()
    local item, index = mod:GetRandomElem(mod.savedata.TaintedBeggarPool, rng) 
    if item then
        table.remove(mod.savedata.TaintedBeggarPool, index)
    else
        item = game:GetItemPool():GetCollectible(ItemPoolType.POOL_BEGGAR, false, rng:GetSeed())
    end
    Isaac.Spawn(5, 100, item, Isaac.GetFreeNearPosition(slot.Position, 40), Vector.Zero, slot)
    game:GetItemPool():RemoveCollectible(item)
	if tmmc then
		tmmc.enable[TaintedMachines.TAINTED_BEGGAR] = true
		tmmc:find_slot()
		slot:GetSprite().PlaybackSpeed = 1
	end
end