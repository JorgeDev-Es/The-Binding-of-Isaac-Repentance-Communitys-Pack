local mod = LastJudgement
local game = Game()
local sfx = SFXManager()

--Disable sprite flipping on Lil' Haunts
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    if npc.Variant == 10 then
        npc:GetSprite().FlipX = false
    end
end, EntityType.ENTITY_THE_HAUNT)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, familiar)
    familiar:GetSprite().FlipX = false
end, FamiliarVariant.LIL_HAUNT)

--Crispy body color matches head color
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    if npc.Variant == 2 then
        local sprite = npc:GetSprite()
        sprite:GetLayer("body"):SetColor(sprite:GetLayer("head"):GetColor())
    end
end, EntityType.ENTITY_SKINNY)

--Make Clutch trail color match head color
mod:AddCallback(ModCallbacks.MC_PRE_NPC_RENDER, function(_, npc)
    if npc.Variant == 0 then
        local sprite = npc:GetSprite()
        for i = 1, 2 do
            sprite:GetLayer(i):SetColor(Color.Default)
        end
    end
end, EntityType.ENTITY_CLUTCH)

--Adjust The Hollow's head rotation
mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, npc)
    if npc.Variant == 1 then
        if not npc.Parent then
            local sprite = npc:GetSprite()
            if sprite:GetAnimation() == "WalkHeadHori" and npc.Velocity.Y < 0 then
                npc:GetSprite():GetLayer(0):SetRotation(-15)
            end
        end
    end
end, EntityType.ENTITY_LARRYJR)

--Make fire projectile rotate to their velocity
mod:AddCallback(ModCallbacks.MC_POST_PROJECTILE_UPDATE, function(_, proj)
    proj.SpriteRotation = proj.Velocity:GetAngleDegrees()
end, ProjectileVariant.PROJECTILE_FIRE)

--Add armor to certain vanilla enemies/bosses
mod.ArmorToAdd = {
    [EntityType.ENTITY_SUCKER] = {
        [4] = 2.5, --Mama Fly
    },
    [EntityType.ENTITY_ISAAC] = {
        [1] = 30, ---??? (boss)
    },
    [EntityType.ENTITY_THE_LAMB] = {
        [0] = 30, --The Lamb
        [10] = 20, --The Lamb (body)
    },
    [EntityType.ENTITY_ADULT_LEECH] = {
        [0] = 8, --Adult Leech
    }, 
    [EntityType.ENTITY_GASBAG] = {
        [0] = 8, --Gasbag
    },
    [EntityType.ENTITY_UNBORN] = {
        [0] = 2.5, --Unborn
    },
    [EntityType.ENTITY_SCOURGE] = {
        [0] = 25, --The Scourge
    },
    [EntityType.ENTITY_CHIMERA] = {
        [0] = 20, --Chimera
        [1] = 20, --Chimera (body)
        [2] = 20, --Chimera (head)
    },
    [EntityType.ENTITY_ROTGUT] = {
        [0] = 20, --Rotgut (mouth)
        [1] = 20, --Rotgut (grub)
        [2] = 20, --Rotgut (heart)
    },
}

for type, entry in pairs(mod.ArmorToAdd) do
    mod:AddPriorityCallback(ModCallbacks.MC_POST_NPC_INIT, CallbackPriority.IMPORTANT, function(_, npc)
        if mod.ArmorToAdd[npc.Type] and mod.ArmorToAdd[npc.Type][npc.Variant] then
            npc:SetShieldStrength(mod.ArmorToAdd[npc.Type][npc.Variant])
        end
    end, type)
end