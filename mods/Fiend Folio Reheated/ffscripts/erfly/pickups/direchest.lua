local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

--Originally coded by cake

--Dire Chest
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, function(_, chest)
	chest = chest:ToPickup()
	local sprite = chest:GetSprite()
	local chestseed = tostring(chest.InitSeed)
	local d = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'ChestData', chestseed, {})
	local gd = chest:GetData()
	chest.Velocity = chest.Velocity * 0.8
	chest.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYERONLY

	if not d.init then
		sprite:Play("Appear", true)
		d.chanceToFinish = 0
		d.init = true
	end

	if sprite:IsEventTriggered("DropSound") then
		sfx:Play(SoundEffect.SOUND_CHEST_DROP, 1, 0, false, 1.0)
	end
	if sprite:IsFinished("Appear") then
		sprite:Play("Idle", true)
	end
	if sprite:IsEventTriggered("Leave") and d.remove == true then
		chest:Remove()
	end
	if sprite:IsFinished("Open") and d.ended ~= true then
		sprite:Play("CloseBack", true)
	end
	if sprite:IsFinished("CloseBack") then
		sprite:Play("Idle", true)
	end
	if sprite:IsFinished("OpenNothing") then
		sprite:Play("OpenedNothing", true)
	end

	mod.AnyPlayerDo(function(player)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_MAGNETO) 
		or player:HasTrinket(TrinketType.TRINKET_SUPER_MAGNET) then
			if player.Position:Distance(chest.Position) < 100 then
				mod:FFDireChestOpening(chest, player)
			end
		end
	end)

    if sprite:IsPlaying("Idle") and mod.anyPlayerHas(CollectibleType.COLLECTIBLE_GUPPYS_EYE) then
        local dist = Game():GetNearestPlayer(chest.Position).Position:Distance(chest.Position)
        gd.Alpha = gd.Alpha or 0
        gd.Alpha = mod:Lerp(gd.Alpha, 0.8, 0.1)
    else
        gd.Alpha = 0
    end
end, 712)

mod.direChestCardPool = {
	--Fiendish
	Card.PLUS_3_FIREBALLS,
	Card.IMPLOSION,
	Card.NECROMANCER,
	Card.SKIP_CARD,
	--Jacks
	Card.JACK_OF_CLUBS,
	Card.JACK_OF_DIAMONDS,
	Card.JACK_OF_HEARTS,
	Card.JACK_OF_SPADES,
}

function mod:FFDireChestOpening(pickup, collider, returnPayout)
	local chestseed = tostring(pickup.InitSeed)
	local data = FiendFolio.getFieldInit(FiendFolio.savedata, 'run', 'level', 'ChestData', chestseed, {})
	local isSnagger
	if collider.Type == 1 then
		collider = collider:ToPlayer()
	elseif collider.Type == mod.FF.Snagger.ID and collider.Variant == mod.FF.Snagger.Var then
		isSnagger = true
	end
	local rng = RNG()
	rng:SetSeed(pickup.InitSeed, 0)
	if data.chanceToFinish then
		for i = 1, data.chanceToFinish do
			rng:Next()
		end
	end

    local returnPayoutFinal
    local payout = {}

	if pickup:GetSprite():IsPlaying("Idle") then
	--print(pickup.SubType)
        if not returnPayout then
		    sfx:Play(SoundEffect.SOUND_CHEST_OPEN, 1, 0, false, 1)
        end
		local chance = rng:RandomInt(11)
		if chance <= data.chanceToFinish then
			local payoutChance = rng:RandomInt(5)
			if payoutChance == 0 then --Positive Payout
				--print("Payout: Positive")
                if returnPayout then
                    returnPayoutFinal = "positive"
                else
                    pickup:GetSprite():Play("Open")
                    mod.scheduleForUpdate(function()
                        sfx:Play(mod.Sounds.DirePayout, 0.4, 0, false, 1)
                    end, 5)
                    data.payout = "positive"
                    data.ended = true
                    pickup.SubType = 1
                end
			else--Negative Payout
                if returnPayout then
                    returnPayoutFinal = "negative"
                else
                    --print("Payout: Negative")
                    pickup:GetSprite():Play("OpenNothing")
                    mod.scheduleForUpdate(function()
                        sfx:Play(mod.Sounds.AceVenturaLaugh, 1, 0, false, 1.5)
                    end, 10)
                    data.payout = "negative"
                    data.ended = true
                    pickup.SubType = 1
                end
			end
		else --Since it is set amounts of items, and not a pool, using a table is probably not the best approach?
			if not returnPayout then
                pickup:GetSprite():Play("Open")
                data.chanceToFinish = data.chanceToFinish+1
            end
			local drop = rng:RandomInt(13)
			if drop == 0 or drop == 1 then -- 2 Friendly Skuzz
                if returnPayout then
                    table.insert(payout, {3, FamiliarVariant.ATTACK_SKUZZ})
                    table.insert(payout, {3, FamiliarVariant.ATTACK_SKUZZ})
                else
                    if isSnagger then
                        for i=1, 2 do
                            local skuzz = Isaac.Spawn(666, 60, 0, pickup.Position+RandomVector() * math.random(5,15), nilvector, pickup)
                            skuzz.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
                            skuzz:GetData().jumpytimer = 0
                            skuzz:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                            skuzz:Update()
                        end
                    else
                        local randVec = RandomVector() * math.random(5,15)
                        local skuzz = Isaac.Spawn(3, FamiliarVariant.ATTACK_SKUZZ, 0, pickup.Position + randVec, nilvector, pickup):ToFamiliar()
                        skuzz:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                        local skuzz2 = Isaac.Spawn(3, FamiliarVariant.ATTACK_SKUZZ, 0, pickup.Position + randVec, nilvector, pickup):ToFamiliar()
                        skuzz2:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                    end
                end
			elseif drop == 2 or drop == 9 then -- 2 Enemy Skuzz
				for i=1, 2 do
                    if returnPayout then
                        table.insert(payout, {666, 60})
                    else
                        local skuzz = Isaac.Spawn(666, 60, 0, pickup.Position+RandomVector() * math.random(5,15), nilvector, pickup)
                        skuzz.EntityCollisionClass = EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
                        skuzz:GetData().jumpytimer = 0
                        skuzz:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                        skuzz:Update()
                    end
				end
			elseif drop == 3 or drop == 4  then -- 1-3 Cursed coins
				for i = 1, 1 + rng:RandomInt(3) do
                    if returnPayout then
                        table.insert(payout, {5, 20, FiendFolio.PICKUP.COIN.CURSED})
                    else
					    Isaac.Spawn(5, 20, 213, pickup.Position, Vector(math.random(4, 7), 0):Rotated(math.random(90)+45), pickup):ToPickup()
                    end
				end
			elseif drop == 5 then -- Spicy Key
                if returnPayout then
                    table.insert(payout, {5, 30, 185})
                else
					Isaac.Spawn(5, 30, 185, pickup.Position, Vector(math.random(3, 4), 0):Rotated(90), pickup):ToPickup()
                end
			elseif drop == 6 then -- Card
				local cardChoice = rng:RandomInt(#mod.direChestCardPool)
                if returnPayout then
                    table.insert(payout, {5, 300, mod.direChestCardPool[cardChoice + 1]})
                else
                    Isaac.Spawn(5, 300, mod.direChestCardPool[cardChoice + 1], pickup.Position, Vector(math.random(3, 4), 0):Rotated(90), pickup):ToPickup()
                end
            elseif drop == 7 then -- Black Heart. but it's supposed to be Immoral! IT IS NOW
				if returnPayout then
                    table.insert(payout, {5, FiendFolio.PICKUP.VARIANT.IMMORAL_HEART})
                else
                    Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_IMMORAL_HEART, 0, pickup.Position, Vector(math.random(3, 4), 0):Rotated(90), pickup):ToPickup()
                end
			elseif drop == 8 then -- Blots
				for i = 60, 120, 60 do
                    if returnPayout then
                        table.insert(payout, {mod.FF.Blot.ID, mod.FF.Blot.Var})
                    else
                        local blotVec = Vector(4, 0):Rotated(i - 20 + math.random(40))
                        local blot = Isaac.Spawn(mod.FF.Blot.ID, mod.FF.Blot.Var, 0, pickup.Position, blotVec, pickup):ToNPC();
                        local blotdata = blot:GetData();
                        blotdata.downvelocity = -25
                        blotdata.downaccel = 2.5
                        blot.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
                        blot.GridCollisionClass = GridCollisionClass.COLLISION_NONE
                        blot:GetSprite().Offset = Vector(0, -30)
                        blotdata.state = "air"
                        blot:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                        blot:Update()
                    end
				end
			elseif drop == 10 then -- Rules Card
				local rando = rng:RandomInt(2)
                if rando == 1 then
                    if returnPayout then
                        table.insert(payout, {5,300,44})
                    else
                        Isaac.Spawn(5, 300, 44, pickup.Position, Vector(math.random(4, 7), 0):Rotated(90), pickup)
                    end
                else
                    if returnPayout then
                        table.insert(payout, {2,920})
                    else
                        mod:ShowFortune()
                    end
                end
			elseif drop == 11 then -- Copper Bomb
                if returnPayout then
                    table.insert(payout, {5, PickupVariant.PICKUP_BOMB, FiendFolio.PICKUP.BOMB.COPPER})
                else
				    Isaac.Spawn(5, PickupVariant.PICKUP_BOMB, FiendFolio.PICKUP.BOMB.COPPER, pickup.Position, Vector(math.random(3, 4), 0):Rotated(90), pickup):ToPickup()
                end
			elseif drop == 12 then -- Cursed Battery
				for i=0, rng:RandomInt(3) do
                    if returnPayout then
                        table.insert(payout, {5, mod.PICKUP.VARIANT.CURSED_BATTERY})
                    else
					    Isaac.Spawn(5, mod.PICKUP.VARIANT.CURSED_BATTERY, 0, pickup.Position, RandomVector()*3, pickup)
                    end
				end
			end
		end
		if data.payout == "positive" or returnPayoutFinal == "positive" then
			local drop = rng:RandomInt(3)
			--print("Drop"..drop)
            if returnPayout then
                table.insert(payout, {4,3})
            else
			    Isaac.Spawn(4,3,0,pickup.Position,nilvector,pickup)
            end
			if drop == 0 then
                data.storedItem = data.storedItem or mod.GetItemFromCustomItemPool(mod.CustomPool.DIRE_CHEST, rng)
                if returnPayout then
                    table.insert(payout, {5,100,data.storedItem})
                else
                    --print("positive:Item")
                    local item = Isaac.Spawn(5, 100, data.storedItem, pickup.Position, Vector(0,0), pickup)
                    pickup:AddEntityFlags(EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK)
                    data.remove = true
                end
			else -- Fiendish Trinket
				--print("positive:Trinket")
                data.storedTrinket = data.storedTrinket or mod.GetItemFromCustomItemPool(mod.CustomPool.DIRE_CHEST_TRINKET, rng)
                if returnPayout then
                    table.insert(payout, {5,350,data.storedTrinket})
                else
                    Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TRINKET, data.storedTrinket, pickup.Position, Vector(math.random(4, 7), 0):Rotated(50+math.random(10, 50)), pickup)
                end
			end
		elseif data.payout == "negative" or returnPayoutFinal == "negative" then
			--[[local drop = rng:RandomInt(2)
			if drop == 0 then -- Tick
				Isaac.Spawn(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_TRINKET, TrinketType.TRINKET_TICK, pickup.Position, Vector(math.random(4, 7), 0):Rotated(90), pickup)
			elseif drop == 1 then -- BOOM
				Isaac.Explode(pickup.Position,pickup,4)
			end]]
            if returnPayout then
                table.insert(payout, {1000, 1})
            else
			    Isaac.Explode(pickup.Position,pickup,4)
            end
			local drop = rng:RandomInt(4)
			if drop == 1 and not isSnagger then
                if returnPayout then
                    table.insert(payout, {5, 300, Card.CARD_HUMANITY})
                else
				    collider:UseCard(45,1)
                end
			end
			if not returnPayout and not isSnagger then
				mod:AddSamaelAngerBonus(0.1)
			end
		end

        if returnPayout then
            return payout
        end

		if pickup.OptionsPickupIndex ~= 0 then
			local pickups = Isaac.FindByType(EntityType.ENTITY_PICKUP)
			for _, entity in ipairs(pickups) do
				if entity:ToPickup().OptionsPickupIndex == pickup.OptionsPickupIndex and
					(entity.Index ~= pickup.Index or entity.InitSeed ~= pickup.InitSeed)
				then
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 0, entity.Position, nilvector, nil)
					entity:Remove()
				end
			end
			pickup.OptionsPickupIndex = 0
		end
	end
end

function mod:FFDireChestPedestal(pickup)
	if pickup.SpawnerEntity ~= nil then
		if pickup.SpawnerEntity.Variant == 712 then
			for i = 3, 5 do pickup:GetSprite():ReplaceSpritesheet(i,"gfx/items/slots/dire_pedestal.png") end
			pickup:GetSprite():LoadGraphics()
		end
	end
end

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.FFDireChestOpening, 712)
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, mod.FFDireChestPedestal)

function mod.TryDireChestConversion(boostOdds)
	if boostOdds then
		mod.savedata.direChestConvertChance = 1 / (1 / mod.savedata.direChestConvertChance / 2)
	end

	for _, chest in pairs(Isaac.FindByType(5, PickupVariant.PICKUP_REDCHEST)) do
		if chest:GetDropRNG():RandomFloat() < mod.savedata.direChestConvertChance then
			if not mod.ACHIEVEMENT.DIRE_CHEST:IsUnlocked(true) then
				mod.ACHIEVEMENT.DIRE_CHEST:Unlock()
			end

			game:BombExplosionEffects(chest.Position, 100, TearFlags.TEAR_NORMAL, mod.ColorPsy)
			sfx:Play(mod.Sounds.FiendFolioBook)

			chest:ToPickup():Morph(5, mod.PICKUP.VARIANT.DIRE_CHEST, 0)
			mod.savedata.direChestConvertChance = 1/128
			break
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function()
	local room = game:GetRoom()
	if room:GetType() == RoomType.ROOM_CURSE and not room:IsFirstVisit() then
		local playerMeetsChanceBoostCondition = false
		mod.AnyPlayerDo(function(player)
			if player:GetDamageCooldown() > 0 and player:GetData().lastDamageSourceWasCursedDoor then
				playerMeetsChanceBoostCondition = true
			end
		end)

		mod.TryDireChestConversion(playerMeetsChanceBoostCondition)
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_RENDER, function(_, chest)
    local gd = chest:GetData()
    if chest:GetData().Opened then return end
    if gd.Alpha and gd.Alpha > 0 then
        if mod.WaterRenderModes[game:GetRoom():GetRenderMode()] then return end
        
        local icon = Sprite()
        icon.Color = Color(icon.Color.R, icon.Color.G, icon.Color.B, gd.Alpha or 0, icon.Color.RO, icon.Color.GO, icon.Color.BO)

        icon:Load("gfx/005.011_heart.anm2", true)
        icon:SetFrame("Idle", 0)
        local baseOffset = nilvector
        local drops = mod:FFDireChestOpening(chest, Isaac.GetPlayer(), true)
        if drops and #drops > 0 then
            local count = math.min(#drops, 16)
            for i = 1, #mod.GuppyEyeOffsets[count] do
                --print(drops[i][1],drops[i][2] or 0,drops[i][3] or 0)
                baseOffset = nilvector
                icon.Scale = Vector(0.5, 0.5)

                if drops[i][1] == 2 then
                    icon:Load("gfx/projectiles/fortune_cookie_tear.anm2", true)
                    icon:SetFrame("Stone3Idle", 1)
                    baseOffset = Vector(0, -10)
                elseif drops[i][1] == 3 then
                    icon:Load("gfx/enemies/skuzzball/attack skuzz.anm2", true)
                    icon:SetFrame("idle", 1)
                    baseOffset = Vector(0, -2)
                elseif drops[i][1] == 4 then
                    local config = StageAPI.GetEntityConfig(drops[i][1], drops[i][2] or 0, drops[i][3] or 0)
                    icon:Load("gfx/004.003_troll bomb.anm2", true)
                    icon:SetFrame("Idle", 0)
                elseif drops[i][1] == 5 then
                    if drops[i][2] == 20 then
                        icon:Load("gfx/items/pick ups/cursed_penny.anm2", true)
                        icon:SetFrame("Idle", 0)
                        baseOffset = Vector(0, -5)
                    elseif drops[i][2] == 30 then
                        icon:Load("gfx/items/pick ups/spicykey.anm2", true)
                        icon:SetFrame("Idle", 0)
                        baseOffset = Vector(0, -2)
                    elseif drops[i][2] == 40 then
                        icon:Load("gfx/items/pick ups/bombs/copper/_pickup.anm2", true)
                        icon:SetFrame("Idle", 0)
                    elseif drops[i][2] == 100 then
                        icon:Load("gfx/005.100_collectible.anm2", true)
                        icon:SetFrame("Idle", 0)
                        local curses = game:GetLevel():GetCurses()
                        if curses == curses | LevelCurse.CURSE_OF_BLIND then
                            icon:ReplaceSpritesheet(1, "gfx/items/collectibles/questionmark.png")
                        else
                            icon:ReplaceSpritesheet(1, Isaac.GetItemConfig():GetCollectible(drops[i][3]).GfxFileName)
                        end
                        baseOffset = Vector(0, 12)
                    elseif drops[i][2] == 300 then
                        if drops[i][3] == Card.CARD_HUMANITY then
                            icon:Load("gfx/grid/grid_poop.anm2", true)
                            icon:SetFrame("State1", 4)
                            baseOffset = Vector(0, -3)
                            icon.Scale = Vector(0.4, 0.4)
                        else
                            if drops[i][3] == FiendFolio.ITEM.CARD.REVERSE_3_FIREBALLS then
                                icon:Load("gfx/items/cards/reverse_fireballs_card.anm2", true)
                            elseif drops[i][3] == FiendFolio.ITEM.CARD.IMPLOSION then
                                icon:Load("gfx/items/cards/hs_card.anm2", true)
                            elseif drops[i][3] == FiendFolio.ITEM.CARD.PLAGUE_OF_DECAY then
                                icon:Load("gfx/items/cards/sb_card.anm2", true)
                            elseif drops[i][3] == FiendFolio.ITEM.CARD.SKIP_CARD then
                                icon:Load("gfx/items/cards/phase10_card.anm2", true)
                            elseif drops[i][3] == Card.CARD_RULES then
                                icon:Load("gfx/items/cards/phase10_card.anm2", true)
                            else
                                local cardback = Isaac.GetItemConfig():GetCard(drops[i][3]).CardType    
                                icon:Load(FiendFolio.CardBackToANM2[cardback] or "gfx/005.309_card against humanity.anm2", true)
                            end
                            icon:SetFrame("Idle", 0)
                        end
                    elseif drops[i][2] == 350 then
                        icon:Load("gfx/005.350_trinket.anm2", true)
                        icon:SetFrame("Idle", 0)
                        if drops[i][3] > 0 then
                            icon:ReplaceSpritesheet(0, Isaac.GetItemConfig():GetTrinket(drops[i][3]).GfxFileName)
                        end
                    elseif drops[i][2] == FiendFolio.PICKUP.VARIANT.IMMORAL_HEART then
                        icon:Load("gfx/items/pick ups/fiendish_heart.anm2", true)
                        icon:SetFrame("Idle", 0)
                        baseOffset = Vector(0, -2)
                    elseif drops[i][2] == FiendFolio.PICKUP.VARIANT.CURSED_BATTERY then
                        icon:Load("gfx/items/pick ups/cursed_battery.anm2", true)
                        icon:SetFrame("Idle", 0)
                        baseOffset = Vector(0, -2)
                    end
                elseif drops[i][1] == 170 then
                        icon:Load("gfx/enemies/blot/monster_blot.anm2", true)
                        icon:SetFrame("Idle", 0)
                        baseOffset = Vector(0, -2)
                elseif drops[i][1] == 666 then
                        icon:Load("gfx/enemies/skuzzball/skuzz.anm2", true)
                        icon:SetFrame("idle", 2)
                        baseOffset = Vector(0, -2)
                elseif drops[i][1] == 1000 then
                    if drops[i][2] == 1 then
                        icon:Load("gfx/1000.001_bomb explosion.anm2", true)
                        icon:ReplaceSpritesheet(2, "gfx/nothing.png")
                        icon:SetFrame("Explosion", 2)
                        icon.Scale = Vector(0.25, 0.25)
                    end
                end
                icon:LoadGraphics()

                local renderPos = chest.Position + baseOffset - mod.GuppyEyeOffsets[count][i]
                renderPos = Isaac.WorldToScreen(renderPos)
                icon:Render(renderPos, Vector.Zero, Vector.Zero)
            end
        end
    end
end, 712)