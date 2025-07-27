local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

FiendFolio.TrashbagGrid = StageAPI.CustomGrid("FFTrashbag", {
    BaseType = GridEntityType.GRID_POOP,
    Anm2 = "gfx/grid/grid_trashbag.anm2",
    Animation = "State1",
    OverrideGridSpawns = true,
    RemoveOnAnm2Change = true,
    PoopExplosionColor = mod.ColorDankBlackReal,
    PoopGibSheet = "gfx/grid/grid_trashbag_gibs.png",
    SpawnerEntity = {Type = FiendFolio.FFID.Grid, Variant = 1037},
})

StageAPI.AddCallback("FiendFolio", "POST_SPAWN_CUSTOM_GRID", 1, function(customGrid)
    local grid = customGrid.GridEntity
	local sprite = grid:GetSprite()
	FiendFolio.SetPoopSpriteState(grid, sprite)
    --print(mod:CheckStage("Dross", {45}))
    if mod:CheckStage("Dross", {45}) then
        sprite:ReplaceSpritesheet(0, "gfx/grid/grid_trashbag_dross.png")
        sprite:LoadGraphics()
        customGrid.GridConfig.PoopGibSheet = "gfx/grid/grid_trashbag_gibs_dross.png"
    end
end, "FFTrashbag")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_UPDATE", 1, function(customGrid)
    if customGrid:IsOnGrid() then
        local grid = customGrid.GridEntity

    end
end, "FFTrashbag")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_DESTROY", 1, function(customGrid, projectile)
    local pos = customGrid.Position
    local rng = customGrid.RNG

    sfx:Play(SoundEffect.SOUND_MUSHROOM_POOF, 1.5, 0, false, 1.5)

    local enemychance = 0.5
    local pickupchance = 0.33
    local maxextraflies = 1
    if mod:CheckStage("Dank Depths", {9}) then
        local creep = Isaac.Spawn(1000,26,0,pos,Vector.Zero,nil)
        creep.SpriteScale = Vector(1.5,1.5)
        creep:Update()
        maxextraflies = 2
    end
    if customGrid.PersistentData.NoReward then
        enemychance = 1
        pickupchance = 0
    end

    if rng:RandomFloat() <= enemychance then --Enemies (Flies)
        local spawner = Isaac.Spawn(17,0,0,pos,Vector.Zero,nil)
        spawner.Visible = false
        mod:TrashbaggerUnboxing(spawner, mod:RandomInt(0,maxextraflies), rng)
        spawner:Remove()
    else --Familiars
        local player = game:GetNearestPlayer(pos)
        for i = 1, mod:RandomInt(1,2,rng) do
            if rng:RandomFloat() <= 0.33 then
                local skuzz = Isaac.Spawn(3, mod.ITEM.FAMILIAR.ATTACK_SKUZZ, 0, pos, Vector.Zero, nil):ToFamiliar()
                skuzz.Player = player
                skuzz:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            elseif rng:RandomFloat() <= 0.66 then
                local fly = Isaac.Spawn(3, 43, 0, pos, RandomVector() * 3, nil):ToFamiliar()
                fly.Player = player
                fly:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            else
                player:ThrowBlueSpider(pos, pos + RandomVector() * 3)
            end
        end
    end

    if rng:RandomFloat() <= pickupchance then --Pickups
        if rng:RandomFloat() <= 0.1 then
            local randWorm = mod:GetRandomElem(mod.TrashBagMiscs.Worms, rng)
            local picky = Isaac.Spawn(5, 350, randWorm, pos, Vector.Zero, nil)
            picky:GetData().bloodsackspawned = true
        elseif rng:RandomFloat() <= 0.5 then
            local randHeart = mod:GetRandomElem(mod.TrashBagMiscs.Hearts, rng)
            local picky = Isaac.Spawn(5, 10, randHeart, pos, Vector.Zero, nil)
            picky:GetData().bloodsackspawned = true
        else
            local picky = Isaac.Spawn(5, 20, 0, pos, Vector.Zero, nil)
            picky:GetData().bloodsackspawned = true
        end
    end
end, "FFTrashbag")

StageAPI.AddCallback("FiendFolio", "POST_CUSTOM_GRID_DIRTY_MIND_SPAWN", 1, function(customGrid, familiar)

end, "FFTrashbag")