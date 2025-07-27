local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod.BlacklistedGreenhouseEntities = {
--Types only
    [EntityType.ENTITY_FIREPLACE] = true,
    [EntityType.ENTITY_ETERNALFLY] = true,
    [EntityType.ENTITY_BLOOD_PUPPY] = true,
    [EntityType.ENTITY_DARK_ESAU] = true,
    [EntityType.ENTITY_MOTHERS_SHADOW] = true,
    [EntityType.ENTITY_GENERIC_PROP] = true,
    [EntityType.ENTITY_SIREN_HELPER] = true,
--Vars needed
    [79 .. "." .. 20] = true, --Gemini balls
    [35 .. "." .. 10] = true,		--Mr. Maw Neck
    [216 .. "." .. 10] = true,		--Swinger Neck
    [EntityType.ENTITY_EVIS .. "." .. 10] = true, --Evis guts
    [mod.FF.Lurker.ID .. "." .. mod.FF.Lurker.Var] = true,
    [mod.FF.LurkerCore.ID .. "." .. mod.FF.LurkerCore.Var] = true,
    [mod.FF.LurkerTooth.ID .. "." .. mod.FF.LurkerTooth.Var] = true,
    [mod.FF.LurkerStoma.ID .. "." .. mod.FF.LurkerStoma.Var] = true,
    [mod.FF.LurkerStretch.ID .. "." .. mod.FF.LurkerStretch.Var] = true,
    [mod.FF.LurkerBrain.ID .. "." .. mod.FF.LurkerBrain.Var] = true,
    [mod.FF.LurkerCollider.ID .. "." .. mod.FF.LurkerCollider.Var] = true,
    [mod.FF.LurkerStretchCollider.ID .. "." .. mod.FF.LurkerStretchCollider.Var] = true,
    [mod.FF.LurkerPsuedoDefault.ID .. "." .. mod.FF.LurkerPsuedoDefault.Var] = true,
    [mod.FF.LurkerBridgeProj.ID .. "." .. mod.FF.LurkerBridgeProj.Var] = true,
    [mod.FF.FingoreHand.ID .. "." .. mod.FF.FingoreHand.Var] = true,
--Subs needed
    [13 .. "." .. 0 .. "." .. 250] = true, --Soundmaker fly
    [5 .. "." .. 100 .. "." .. 0] = true, --Empty Pedestals
    [mod.FF.ThrallCord.ID .. "." .. mod.FF.ThrallCord.Var .. "." .. mod.FF.ThrallCord.Sub] = true,
    [mod.FF.EffigyCord.ID .. "." .. mod.FF.EffigyCord.Var .. "." .. mod.FF.EffigyCord.Sub] = true,
    [mod.FF.Bola.ID .. "." .. mod.FF.Bola.Var .. "." .. mod.FF.BolaHead.Sub] = true,
    [mod.FF.Bola.ID .. "." .. mod.FF.Bola.Var .. "." .. mod.FF.BolaNeck.Sub] = true,
    [mod.FF.WarbleTail.ID .. "." .. mod.FF.WarbleTail.Var .. "." .. mod.FF.WarbleTail.Sub] = true,
    [mod.FF.RiftWalkerGfx.ID .. "." .. mod.FF.RiftWalkerGfx.Var .. "." .. mod.FF.RiftWalkerGfx.Sub] = true,
    [mod.FF.PatzerShell.ID .. "." .. mod.FF.PatzerShell.Var] = true,
}

function mod:isEntityBlacklistedGreenHouse(entity)
    if mod.BlacklistedGreenhouseEntities[entity.Type]
    or mod.BlacklistedGreenhouseEntities[entity.Type .. "." .. entity.Variant]
    or mod.BlacklistedGreenhouseEntities[entity.Type .. "." .. entity.Variant .. "." .. entity.SubType]
    then
        return true
    --Other cases
    elseif entity.Type >= 10 and mod:isFriend(entity:ToNPC()) --No friendly enemies
    or entity.Type == 62 and entity.Parent --No pin segments
    or entity.Type == 281 and entity.Parent --No swarm followers
    then
        return true
    end
end

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, cardID, player, useFlags)
    FiendFolio.savedata.dadsHomeGreenHouseTable = FiendFolio.savedata.dadsHomeGreenHouseTable or {}
    for _,entity in ipairs(Isaac.GetRoomEntities()) do
        if (entity:IsEnemy() and not entity:IsBoss()) or (entity.Type == 5 and not entity:ToPickup():IsShopItem()) then

            local blacklisted = mod:isEntityBlacklistedGreenHouse(entity)
            if not blacklisted then
                table.insert(FiendFolio.savedata.dadsHomeGreenHouseTable, {entity.Type, entity.Variant, entity.SubType})
                Isaac.Spawn(1000, 15, 0, entity.Position, nilvector, player)
                entity:Remove()
            end
        end
    end
    if #FiendFolio.savedata.dadsHomeGreenHouseTable > 0 then
        sfx:Play(mod.Sounds.CarIgnition, 1, 0, false, 1)
    else
        sfx:Play(mod.Sounds.FunnyFart, 1, 0, false, 1)
    end
    FiendFolio:trySayAnnouncerLine(mod.Sounds.VAObjectGreenHouse, useFlags, 30)
end, Card.GREEN_HOUSE)

function mod:greenHouseDadsHome()
    if FiendFolio.savedata.dadsHomeGreenHouseTable then
        mod.scheduleForUpdate(function()
            sfx:Play(SoundEffect.SOUND_SUMMONSOUND,1,0,false,1)
            for i = 1, #FiendFolio.savedata.dadsHomeGreenHouseTable do
                local room = game:GetRoom()
                local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 1, true)
                if FiendFolio.savedata.dadsHomeGreenHouseTable[i][1] > 9 then
                    if FiendFolio.savedata.dadsHomeGreenHouseTable[i][1] == 281 then
                        mod.cheekyspawn(pos, Isaac.GetPlayer(), pos, FiendFolio.savedata.dadsHomeGreenHouseTable[i][1],FiendFolio.savedata.dadsHomeGreenHouseTable[i][2],FiendFolio.savedata.dadsHomeGreenHouseTable[i][3])
                    else
                        local enemy = Isaac.Spawn(FiendFolio.savedata.dadsHomeGreenHouseTable[i][1],FiendFolio.savedata.dadsHomeGreenHouseTable[i][2],FiendFolio.savedata.dadsHomeGreenHouseTable[i][3], pos, nilvector, nil):ToNPC()
                        local newpos = mod:FindRandomValidPathPosition(enemy, 2, 80)
                        enemy.Position = newpos
                        enemy:Update()
                    end
                else
                    Isaac.Spawn(FiendFolio.savedata.dadsHomeGreenHouseTable[i][1],FiendFolio.savedata.dadsHomeGreenHouseTable[i][2],FiendFolio.savedata.dadsHomeGreenHouseTable[i][3], pos, nilvector, nil)
                end
                for i = 0, 7 do
					local door = room:GetDoor(i)
                    if door then
                        door:Close()
                    end
				end
            end
            FiendFolio.savedata.dadsHomeGreenHouseTable = nil
        end, 1, ModCallbacks.MC_POST_UPDATE, true)
    end
end