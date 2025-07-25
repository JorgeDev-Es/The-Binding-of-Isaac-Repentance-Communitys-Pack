local ICMod = RegisterMod("Isaac's Collection", 1)
ICMod.savemanager = include("scripts.save_manager")
ICMod.savemanager.Init(ICMod)
local sfx = SFXManager()
local targetplayer = Isaac.GetPlayer(0) --default, dumb baby boy

--//SOUNDS (grab your rods folks)//------------------------------------------------------------------------------------

local shieldflash_sound = Isaac.GetSoundIdByName("shield flash")
local eat_sound = Isaac.GetSoundIdByName("eat")



--//ITEMS//------------------------------------------------------------------------------------------------------------

local whitebow = Isaac.GetItemIdByName("White Bow")
local metalophagia = Isaac.GetItemIdByName("Metallophagia")



--//EFFECTS//----------------------------------------------------------------------------------------------------------

local whitebow_viseffect = Isaac.GetEntityVariantByName("White Bow Flash")
local eat_viseffect = Isaac.GetEntityVariantByName("Eat")



--White Bow (please excuse this fudging mess)--------------------------------------------------------------------------

function ICMod:whitebow_effect(heart_pickup, collider)
    targetplayer = collider:ToPlayer()

    if targetplayer and targetplayer:HasCollectible(whitebow) and targetplayer:CanPickSoulHearts() then
        if heart_pickup.SubType == HeartSubType.HEART_SOUL or heart_pickup.SubType == HeartSubType.HEART_HALF_SOUL then
            if targetplayer:GetEffects():HasNullEffect(NullItemID.ID_HOLY_CARD) ~= true then
                if targetplayer:GetEffects():HasCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE) ~= true then
                    targetplayer:GetEffects():AddCollectibleEffect(CollectibleType.COLLECTIBLE_HOLY_MANTLE, true, 1)
                    targetplayer:GetEffects():AddNullEffect(NullItemID.ID_HOLY_CARD, false, 1)
                        
                    --//VISUAL//--
                    Isaac.Spawn(EntityType.ENTITY_EFFECT, whitebow_viseffect, 0, targetplayer.Position, Vector.Zero, nil)
                    sfx:Play(shieldflash_sound)
                    targetplayer:SetColor(Color(0,0,0,1,1,1,1),10,999,true,false)
                end
            end
        end
    end
end

function ICMod:whitebow_pickup_effect()
    for p = 0, Game():GetNumPlayers() - 1 do
        targetplayer = Isaac.GetPlayer(p)
        if targetplayer and targetplayer:HasCollectible(whitebow, true) then
            local runsave = ICMod.savemanager.GetRunSave(targetplayer)
            if targetplayer:GetCollectibleNum(whitebow, true) > (runsave.whitebow_num or 0) then
                runsave.whitebow_num = (runsave.whitebow_num or 0) + 1
                Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_SOUL, Isaac.GetFreeNearPosition(targetplayer.Position, 35), Vector.Zero, nil)
            end
        end
    end
end

function ICMod:whitebow_viseffect_init(effect)
    effect.SpriteOffset = Vector(0, -5)
    effect.Position = targetplayer.Position
    effect:FollowParent(targetplayer)
end

ICMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, ICMod.whitebow_viseffect_init, whitebow_viseffect)
ICMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, ICMod.whitebow_effect, PickupVariant.PICKUP_HEART)
ICMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, ICMod.whitebow_pickup_effect)



--Metalophagia (coins are good for you actually)-----------------------------------------------------------------------

function ICMod:metalophagia_effect(coin_pickup, collider)
    targetplayer = collider:ToPlayer()

    if targetplayer and targetplayer:HasCollectible(metalophagia) and coin_pickup.SubType ~= CoinSubType.COIN_STICKYNICKEL then
        local runsave = ICMod.savemanager.GetRunSave(targetplayer)
        local stats = {0,1,2,3,4}
        local chosen_stat = stats[targetplayer:GetCollectibleRNG(metalophagia):RandomInt(#stats) + 1]

        if chosen_stat == 0 then
            runsave.metalophagia_damage = (runsave.metalophagia_damage or 0) + coin_pickup:GetCoinValue()
        elseif chosen_stat == 1 then
            runsave.metalophagia_range = (runsave.metalophagia_range or 0) + coin_pickup:GetCoinValue()
        elseif chosen_stat == 2 then
            runsave.metalophagia_speed = (runsave.metalophagia_speed or 0) + coin_pickup:GetCoinValue()
        elseif chosen_stat == 3 then
            runsave.metalophagia_luck = (runsave.metalophagia_luck or 0) + coin_pickup:GetCoinValue()
        elseif chosen_stat == 4 then
            runsave.metalophagia_shot = (runsave.metalophagia_shot or 0) + coin_pickup:GetCoinValue()
        end
        sfx:Play(eat_sound)
        Isaac.Spawn(EntityType.ENTITY_EFFECT, eat_viseffect, 0, targetplayer.Position, Vector.Zero, nil)
        targetplayer:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_RANGE | CacheFlag.CACHE_SPEED | CacheFlag.CACHE_LUCK | CacheFlag.CACHE_SHOTSPEED)
        targetplayer:EvaluateItems()
    end
end

function ICMod:metalophagia_eval(player, cache)
    if player:HasCollectible(metalophagia) then
        local runsave = ICMod.savemanager.GetRunSave(player)

        if cache & CacheFlag.CACHE_DAMAGE == CacheFlag.CACHE_DAMAGE then
            player.Damage = player.Damage * (1 + (runsave.metalophagia_damage or 0) * 0.02857)
        elseif cache & CacheFlag.CACHE_RANGE == CacheFlag.CACHE_RANGE then
            player.TearRange = player.TearRange + ((runsave.metalophagia_range or 0) * 10)
        elseif cache & CacheFlag.CACHE_SPEED == CacheFlag.CACHE_SPEED then
            player.MoveSpeed = player.MoveSpeed + ((runsave.metalophagia_speed or 0) * 0.02)
        elseif cache & CacheFlag.CACHE_LUCK == CacheFlag.CACHE_LUCK then
            player.Luck = player.Luck + ((runsave.metalophagia_luck or 0) * 0.1)
        elseif cache & CacheFlag.CACHE_SHOTSPEED == CacheFlag.CACHE_SHOTSPEED then
            player.ShotSpeed = player.ShotSpeed + ((runsave.metalophagia_shot or 0) * 0.02)
        end
    end
end

function ICMod:metalophagia_pickup_effect()
    for p = 0, Game():GetNumPlayers() - 1 do
        targetplayer = Isaac.GetPlayer(p)
        if targetplayer and targetplayer:HasCollectible(metalophagia, true) then
            local runsave = ICMod.savemanager.GetRunSave(targetplayer)
            if targetplayer:GetCollectibleNum(metalophagia, true) > (runsave.metalophagia_num or 0) then
                runsave.metalophagia_num = (runsave.metalophagia_num or 0) + 1
                for n = 1, 3 do
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY, Isaac.GetFreeNearPosition(targetplayer.Position, 35 + n), Vector.Zero, nil)
                end
            end
        end
    end
end

function ICMod:eat_viseffect_init(effect)
    effect.SpriteOffset = Vector(0, -20)
    effect.Position = targetplayer.Position
    effect:FollowParent(targetplayer)
    if math.random(0, 1) == 1 then
        effect.FlipX = true
    end
end

ICMod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, ICMod.eat_viseffect_init, eat_viseffect)
ICMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, ICMod.metalophagia_effect, PickupVariant.PICKUP_COIN)
ICMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ICMod.metalophagia_eval)
ICMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, ICMod.metalophagia_pickup_effect)



--//TRINKETS//---------------------------------------------------------------------------------------------------------

local ossifiedpenny = Isaac.GetTrinketIdByName("Ossified Penny")
local theorphans = Isaac.GetTrinketIdByName("The Orphans")



--Ossified Penny-------------------------------------------------------------------------------------------------------

function ICMod:ossifiedpenny_effect(coin_pickup, collider)
    targetplayer = collider:ToPlayer()
    local bone_orbital

    if targetplayer and coin_pickup.SubType ~= CoinSubType.COIN_STICKYNICKEL then
        for n = 1, coin_pickup:GetCoinValue() do
            if Isaac.CountEntities(targetplayer, 3, 128, -1) < 12 and targetplayer:HasTrinket(ossifiedpenny) and targetplayer:GetTrinketRNG(ossifiedpenny):RandomFloat() <= 0.5 then
                bone_orbital = Isaac.Spawn(3, 128, -1, targetplayer.Position, targetplayer.Velocity, targetplayer)
                bone_orbital:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
            end
        end
    end
end

ICMod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, ICMod.ossifiedpenny_effect, PickupVariant.PICKUP_COIN)



--The Orphans (shipped from No Mom No Dad Co.)-------------------------------------------------------------------------

function ICMod:theorphans_pickup_effect(_, cache)
    if cache & CacheFlag.CACHE_FAMILIARS == CacheFlag.CACHE_FAMILIARS then
        ICMod:theorphans_effect()
    end
end

function ICMod:theorphans_effect()
    for p = 0, Game():GetNumPlayers() - 1 do
        targetplayer = Isaac.GetPlayer(p)
        local runsave = ICMod.savemanager.GetRunSave(targetplayer)

        for n = 1, 2 * targetplayer:GetTrinketMultiplier(theorphans) do
            if (runsave.orphan_count or 0) < 2 * targetplayer:GetTrinketMultiplier(theorphans) then
                runsave.orphan_count = math.min((runsave.orphan_count or 0) + 1, 2 * targetplayer:GetTrinketMultiplier(theorphans))
                targetplayer:AddMinisaac(targetplayer.Position, false)
            end
        end
    end
end

function ICMod:theorphans_orphan_count()
    for p = 0, Game():GetNumPlayers() - 1 do
        targetplayer = Isaac.GetPlayer(p)
        if targetplayer:HasTrinket(theorphans) then
            local runsave = ICMod.savemanager.GetRunSave(targetplayer)
            runsave.orphan_count = Isaac.CountEntities(targetplayer, 3, 228, -1)
        end
    end
end

ICMod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, ICMod.theorphans_orphan_count)
ICMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, ICMod.theorphans_effect)
ICMod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ICMod.theorphans_pickup_effect, CacheFlag.CACHE_FAMILIARS)



--//EXTERNAL ITEM DESCRIPTIONS COMPATIBILITY//-------------------------------------------------------------------------

if EID then
    --//ITEMS//--
    EID:addCollectible(whitebow, "{{HolyMantle}} Picking up a {{SoulHeart}} Soul Heart grants a Holy Mantle shield (prevents damage once)#{{SoulHeart}} Spawns a Soul Heart")
    EID:addCollectible(metalophagia, "{{ArrowUp}} Picking up {{Coin}} coins grants random permanent stat ups#Higher stats from nickels and dimes#{{Coin}} Spawns 3 coins#:P")

    --//TRINKETS//--
    EID:addTrinket(ossifiedpenny, "Picking up a coin has a 50% chance to spawn a bone orbital#Nickels and dimes spawn more bone orbitals")
    EID:addTrinket(theorphans, "Spawns 2 Minisaacs#Respawns each room#Minisaacs chase and shoot at nearby enemies")
end