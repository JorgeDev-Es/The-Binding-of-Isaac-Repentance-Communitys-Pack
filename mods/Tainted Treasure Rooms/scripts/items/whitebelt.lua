local mod = TaintedTreasure
local game = Game()

function mod:WhiteBeltNPCInit(npc, rng)
    if mod:RandomInt(1,3,rng) > 1 then --2/3 chance to convert into normal enemy
        Isaac.Spawn(npc.Type, npc.Variant, npc.SubType, npc.Position, npc.Velocity, npc.SpawnerEntity) --Yes, this is the only method of doing this
        npc:Remove()
    end
end

function mod:WhiteBeltPlayerLogic(player, data, savedata) 
    local effects = player:GetEffects()

    if player:HasCollectible(TaintedCollectibles.WHITE_BELT) then
        if game:GetLevel():GetCurrentRoomIndex() ~= data.CurrentRoomIndex then
            savedata.WhiteBeltRepulsion = 120
        end
    end

    if savedata.WhiteBeltRepulsion then
        savedata.WhiteBeltRepulsion = savedata.WhiteBeltRepulsion - 1
        if savedata.WhiteBeltRepulsion > 0 then
            if not effects:HasNullEffect(NullItemID.ID_REVERSE_MAGICIAN) then
                effects:AddNullEffect(NullItemID.ID_REVERSE_MAGICIAN, true, 1)
            end
        else
            effects:RemoveNullEffect(NullItemID.ID_REVERSE_MAGICIAN, 1)
            savedata.WhiteBeltRepulsion = nil
        end
    end
    --[[if player:HasCollectible(TaintedCollectibles.WHITE_BELT) then
        for _, enemy in pairs(Isaac.FindInRadius(player.Position, 80, EntityPartition.ENEMY)) do
            if enemy:IsEnemy() and not enemy:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
                enemy:SetColor(mod.ColorWeakness, 5, 1, false, false)
                enemy:GetData().WeaknessDebuffed = 5
                enemy:AddEntityFlags(EntityFlag.FLAG_WEAKNESS)
            end
        end
    end]]
end