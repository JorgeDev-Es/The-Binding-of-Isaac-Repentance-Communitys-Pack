local HydrochloricAcid = {}

CollectibleType.COLLECTIBLE_HYDROCHLORIC_ACID = Isaac.GetItemIdByName("Hydrochloric Acid")

function HydrochloricAcid.ItemDamage(entity, amount, flags, source, countdownFrames)
  local player
  if (source ~= nil) then
    if (source.Type == EntityType.ENTITY_PLAYER) then
      player = source.Entity:ToPlayer()
    elseif (source.Entity ~= nil and source.Entity.Parent ~= nil and source.Entity.Parent.Type == EntityType.ENTITY_PLAYER) then
      player = source.Entity.Parent:ToPlayer()
    else
      return
    end

    if (player:HasCollectible(CollectibleType.COLLECTIBLE_HYDROCHLORIC_ACID) and entity:IsVulnerableEnemy()) then
      local data = entity:GetData()
      if not data.HclProcs then
        data.HclProcs = 1
      else
        data.HclProcs = data.HclProcs + 1
        if data.HclProcs == 5 then
          if not data.HclSprite then
            data.HclSprite = Sprite()
            data.HclSprite:Load("gfx/hclStatus.anm2", true)
            data.HclSprite:Play("Idle", true)
          end
        elseif data.HclProcs > 5 then
          entity:TakeDamage(3.0, 0, EntityRef(nil), 0)
        end
      end
    end
  end
end

function HydrochloricAcid.Render(npc, renderOffset)
  local data = npc:GetData()
  if data.HclSprite then
    data.HclSprite:Render(Isaac.WorldToScreen(npc.Position + Vector(0, -70)))
  end
end

function HydrochloricAcid.Update(npc)
  local data = npc:GetData()
  if data.HclSprite then
    data.HclSprite:Update()
  end
end

return HydrochloricAcid