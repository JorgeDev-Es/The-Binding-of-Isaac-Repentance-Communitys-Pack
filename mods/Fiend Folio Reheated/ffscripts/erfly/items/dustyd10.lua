local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, itemID, rng, player, useflags, activeslot)
    if useflags == useflags | UseFlag.USE_CARBATTERY then
        return {Discharge = false, Remove = false, ShowAnim = false}
    end
    
    local D10Filter = function (_, candidate)
        if candidate:CanReroll() then
            return true
        end
    end
    local enemies = mod:GetAllEnemies(D10Filter)
    if #enemies > 0 then
        for _, enemy in pairs(enemies) do
            game:RerollEnemy(enemy)
        end
    end
    return true
end, mod.ITEM.COLLECTIBLE.DUSTY_D10)

function mod:dustyD10WispTearUpdate(tear, tdata)
    if not tdata.checkedD10Wisp then
        tdata.checkedD10Wisp = true
        if tear.SpawnerType == 3 and tear.SpawnerVariant == 206 then
            local fam = tear.SpawnerEntity
            if not fam then return end
            if fam.SubType == mod.ITEM.COLLECTIBLE.DUSTY_D10 then
                if tear:HasTearFlags(TearFlags.TEAR_REROLL_ENEMY) then
                    tear:ClearTearFlags(TearFlags.TEAR_REROLL_ENEMY)
                    tdata.isRerolliganTear = true
                end
            end
        end
    end
end