local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero
local sfx = SFXManager()

mod.ReheatedPizzaHearts = {
    {ID = HeartSubType.HEART_FULL,              Unlocked = function() return true end},
    {ID = HeartSubType.HEART_SOUL,              Unlocked = function() return true end},
    {ID = HeartSubType.HEART_ETERNAL,           Unlocked = function() return true end},
    {ID = HeartSubType.HEART_BLACK,             Unlocked = function() return true end},
    {ID = HeartSubType.HEART_GOLDEN,            Unlocked = function() return mod.AchievementTrackers.GoldenHeartsUnlocked end},
    {ID = HeartSubType.HEART_BLENDED,           Unlocked = function() return true end},
    {ID = HeartSubType.HEART_BONE,              Unlocked = function() return mod.AchievementTrackers.BoneHeartsUnlocked end},
    {ID = HeartSubType.HEART_ROTTEN,            Unlocked = function() return mod.AchievementTrackers.RottenHeartsUnlocked end},
    {ID = {Var = mod.PICKUP.VARIANT.IMMORAL_HEART,          Sub = 0},   Unlocked = function() return mod.ACHIEVEMENT.IMMORAL_HEART:IsUnlocked() end},
    {ID = {Var = mod.PICKUP.VARIANT.MORBID_HEART,           Sub = 0},   Unlocked = function() return mod.ACHIEVEMENT.MORBID_HEART:IsUnlocked() end},
}

function mod:reheatedPizzaNewLevel(player, d)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.REHEATED_PIZZA) then
        mod.scheduleForUpdate(function()
            player:AnimateHappy()
        end, 1)
        local savedata = d.ffsavedata or {}
        local r = player:GetCollectibleRNG(mod.ITEM.COLLECTIBLE.REHEATED_PIZZA)
        for i = 1, player:GetCollectibleNum(mod.ITEM.COLLECTIBLE.REHEATED_PIZZA) do
            if not savedata.reheatedPizzaHearts or (savedata.reheatedPizzaHearts and #savedata.reheatedPizzaHearts <= 0) then
                savedata.reheatedPizzaHearts = {}
                for _, data in pairs(mod.ReheatedPizzaHearts) do
                    if data.Unlocked() then
                        table.insert(savedata.reheatedPizzaHearts, data.ID)
                    end
                end
            end
            local rand = r:RandomInt(#savedata.reheatedPizzaHearts) + 1
            local pickupChoice = savedata.reheatedPizzaHearts[rand]
            table.remove(savedata.reheatedPizzaHearts, rand)
            local pickup
            local spawnPos =  Game():GetRoom():FindFreePickupSpawnPosition(player.Position + Vector(0,25))
            if tonumber(pickupChoice) then
                pickup = Isaac.Spawn(5, 10, pickupChoice, spawnPos, nilvector, player)
            else
                pickup = Isaac.Spawn(5, pickupChoice.Var, pickupChoice.Sub, spawnPos, nilvector, player)
            end
            pickup:Update()

            local pizzaBox = Isaac.Spawn(1000, mod.FF.PizzaBox.Var, mod.FF.PizzaBox.Sub, spawnPos, nilvector, player):ToEffect()
        end
    end
end

function mod:pizzaBoxEffectAI(e)
    e.DepthOffset = -15
    e.SpriteOffset = Vector(-1,-2)
    if e.FrameCount > 5 then
        if e:GetSprite():IsEventTriggered("spawn") then
            e:GetSprite():Play("TopOnly", true)
            local newEffect = Isaac.Spawn(1000, mod.FF.PizzaBox.Var, mod.FF.PizzaBox.Sub, e.Position, nilvector, e):ToEffect()
            newEffect:GetSprite():SetFrame("BottomOnly", 1)
            newEffect:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR)
            newEffect:Update()
        end
    end
end