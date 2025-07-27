local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local findOddRock = {
    ["gfx/grid/rocks_basement.png"] = {"gfx/grid/rocks_cellar.png", "gfx/grid/rocks_burningbasement.png", "gfx/grid/smoky_rocks.png", "gfx/grid/rocks_arcade.png"},
    ["gfx/grid/rocks_cellar.png"] = {"gfx/grid/rocks_basement.png", "gfx/grid/rocks_burningbasement.png", "gfx/grid/smoky_rocks.png", "gfx/grid/rocks_arcade.png"},
    ["gfx/grid/rocks_burningbasement.png"] = {"gfx/grid/rocks_cellar.png", "gfx/grid/rocks_basement.png", "gfx/grid/smoky_rocks.png", "gfx/grid/rocks_arcade.png"},
    ["gfx/grid/smoky_rocks.png"] = {"gfx/grid/rocks_cellar.png", "gfx/grid/rocks_basement.png", "gfx/grid/rocks_burningbasement.png", "gfx/grid/rocks_arcade.png"},

    ["gfx/grid/rocks_downpour.png"] = {"gfx/grid/rocks_downpour_entrance.png", "gfx/grid/rocks_dross", "gfx/grid/rocks_rocks_peepee", "gfx/grid/rocks_pipes.png"},
    ["gfx/grid/rocks_downpour_entrance.png"] = {"gfx/grid/rocks_downpour.png", "gfx/grid/rocks_dross", "gfx/grid/rocks_rocks_peepee", "gfx/grid/rocks_pipes.png"},
    ["gfx/grid/rocks_dross.png"] = {"gfx/grid/rocks_downpour_entrance.png", "gfx/grid/rocks_pipes.png", "gfx/grid/rocks_downpour.png"},
    ["gfx/grid/rocks_rocks_peepee.png"] = {"gfx/grid/rocks_downpour_entrance.png", "gfx/grid/rocks_pipes.png", "gfx/grid/rocks_downpour.png"},

    ["gfx/grid/rocks_caves.png"] = {"gfx/grid/rocks_catacombs.png", "gfx/grid/rocks_primitive.png", "gfx/grid/rocks_drownedcaves.png"},
    ["gfx/grid/rocks_primitive.png"] = {"gfx/grid/rocks_catacombs.png", "gfx/grid/rocks_caves.png", "gfx/grid/rocks_drownedcaves.png"},
    ["gfx/grid/rocks_catacombs.png"] = {"gfx/grid/rocks_caves.png", "gfx/grid/rocks_primitive.png", "gfx/grid/rocks_drownedcaves.png"},
    ["gfx/grid/rocks_drownedcaves.png"] = {"gfx/grid/rocks_catacombs.png", "gfx/grid/rocks_primitive.png", "gfx/grid/rocks_caves.png"},

    ["gfx/grid/rocks_secretroom.png"] = {"gfx/grid/rocks_ashpit.png"},
    ["gfx/grid/rocks_ashpit.png"] = {"gfx/grid/rocks_secretroom.png"},

    ["gfx/grid/rocks_depths_custom.png"] = {"gfx/grid/rocks_depths.png", "gfx/grid/rock_challenge_placeholderrecolor.png", "gfx/grid/rocks_necropolis.png", "gfx/grid/rocks_dankdepths.png", "gfx/grid/rocks_pipes.png", "gfx/grid/rocks_trash.png"},
    ["gfx/grid/rocks_depths.png"] = {"gfx/grid/rocks_depths_custom.png", "gfx/grid/rock_challenge_placeholderrecolor.png", "gfx/grid/rocks_necropolis.png", "gfx/grid/rocks_dankdepths.png", "gfx/grid/rocks_pipes.png", "gfx/grid/rocks_trash.png"},
    ["gfx/grid/rock_challenge_placeholderrecolor.png"] = {"gfx/grid/rocks_depths.png", "gfx/grid/rocks_depths_custom.png", "gfx/grid/rocks_necropolis.png", "gfx/grid/rocks_dankdepths.png", "gfx/grid/rocks_pipes.png", "gfx/grid/rocks_trash.png"},
    ["gfx/grid/rocks_necropolis.png"] = {"gfx/grid/rocks_depths.png", "gfx/grid/rock_challenge_placeholderrecolor.png", "gfx/grid/rocks_depths_custom.png", "gfx/grid/rocks_dankdepths.png", "gfx/grid/rocks_pipes.png", "gfx/grid/rocks_trash.png"},
    ["gfx/grid/rocks_dankdepths.png"] = {"gfx/grid/rocks_depths.png", "gfx/grid/rock_challenge_placeholderrecolor.png", "gfx/grid/rocks_necropolis.png", "gfx/grid/rocks_depths_custom.png", "gfx/grid/rocks_pipes.png", "gfx/grid/rocks_trash.png"},
    ["gfx/grid/rocks_pipes.png"] = {"gfx/grid/rocks_depths.png", "gfx/grid/rock_challenge_placeholderrecolor.png", "gfx/grid/rocks_necropolis.png", "gfx/grid/rocks_dankdepths.png", "gfx/grid/rocks_depths_custom.png", "gfx/grid/rocks_trash.png"},
    ["gfx/grid/rocks_trash.png"] = {"gfx/grid/rocks_depths.png", "gfx/grid/rock_challenge_placeholderrecolor.png", "gfx/grid/rocks_necropolis.png", "gfx/grid/rocks_dankdepths.png", "gfx/grid/rocks_pipes.png", "gfx/grid/rocks_depths_custom.png"},

    ["gfx/grid/rocks_mausoleum.png"] = {"gfx/grid/rocks_mausoleumb.png", "gfx/grid/rocks_gehenna.png", "gfx/grid/rocks_corpseentrance.png"},
    ["gfx/grid/rocks_mausoleumb.png"] = {"gfx/grid/rocks_mausoleum.png", "gfx/grid/rocks_gehenna.png", "gfx/grid/rocks_corpseentrance.png"},
    ["gfx/grid/rocks_gehenna.png"] = {"gfx/grid/rocks_mausoleumb.png", "gfx/grid/rocks_mausoleum.png", "gfx/grid/rocks_corpseentrance.png"},
    ["gfx/grid/rocks_corpseentrance.png"] = {"gfx/grid/rocks_mausoleumb.png", "gfx/grid/rocks_mausoleum.png", "gfx/grid/rocks_mausoleum.png"},

    ["gfx/grid/rocks_womb.png"] = {"gfx/grid/rocks_utero.png", "gfx/grid/rocks_scarredwomb.png", "gfx/grid/rocks_bluewomb.png"},
    ["gfx/grid/rocks_utero.png"] = {"gfx/grid/rocks_womb.png", "gfx/grid/rocks_scarredwomb.png", "gfx/grid/rocks_bluewomb.png"},
    ["gfx/grid/rocks_scarredwomb.png"] = {"gfx/grid/rocks_utero.png", "gfx/grid/rocks_womb.png", "gfx/grid/rocks_bluewomb.png"},
    ["gfx/grid/rocks_bluewomb.png"] = {"gfx/grid/rocks_utero.png", "gfx/grid/rocks_scarredwomb.png", "gfx/grid/rocks_womb.png"},

    ["gfx/grid/rocks_corpse.png"] = {"gfx/grid/morbus/morbus_rocks.png", "gfx/grid/rocks_corpse3.png"},
    ["gfx/grid/rocks_corpse2.png"] = {"gfx/grid/morbus/morbus_rocks.png", "gfx/grid/rocks_corpse3.png"},
    ["gfx/grid/rocks_corpse3.png"] = {"gfx/grid/morbus/morbus_rocks.png", "gfx/grid/rocks_corpse.png", "gfx/grid/rocks_corpse2.png"},
    ["gfx/grid/morbus/morbus_rocks.png"] = {"gfx/grid/rocks_corpse3.png", "gfx/grid/rocks_corpse.png", "gfx/grid/rocks_corpse2.png"},

    ["gfx/grid/rocks_cathedral.png"] = {"gfx/grid/rocks_sheol.png"},
    ["gfx/grid/rocks_sheol.png"] = {"gfx/grid/rocks_cathedral.png"},

    ["gfx/grid/rocks_chest.png"] = {"gfx/grid/rocks_darkroom.png"},
    ["gfx/grid/rocks_darkroom.png"] = {"gfx/grid/rocks_chest.png"},

    ["gfx/grid/rocks_library.png"] = {"gfx/grid/rocks_shop.png", "gfx/grid/rocks_dice", "gfx/grid/rocks_error-1.png", "gfx/grid/rocks_secret.png"},
    ["gfx/grid/rocks_shop.png"] = {"gfx/grid/rocks_library.png", "gfx/grid/rocks_dice", "gfx/grid/rocks_error-1.png", "gfx/grid/rocks_secret.png"},
    ["gfx/grid/rocks_dice.png"] = {"gfx/grid/rocks_shop.png", "gfx/grid/rocks_library", "gfx/grid/rocks_error-1.png", "gfx/grid/rocks_secret.png", "gfx/grid/rocks_d12.png", "gfx/grid/rocks_ed12.png"},
    ["gfx/grid/rocks_error-1.png"] = {"gfx/grid/rocks_shop.png", "gfx/grid/rocks_dice", "gfx/grid/rocks_library.png", "gfx/grid/rocks_secret.png"},
    ["gfx/grid/rocks_secret.png"] = {"gfx/grid/rocks_shop.png", "gfx/grid/rocks_dice", "gfx/grid/rocks_error-1.png", "gfx/grid/rocks_library.png"},
    ["gfx/grid/rocks_d12.png"] = {"gfx/grid/rocks_shop.png", "gfx/grid/rocks_library", "gfx/grid/rocks_error-1.png", "gfx/grid/rocks_secret.png", "gfx/grid/rocks_dice.png", "gfx/grid/rocks_ed12.png"},
    ["gfx/grid/rocks_ed12.png"] = {"gfx/grid/rocks_shop.png", "gfx/grid/rocks_library", "gfx/grid/rocks_error-1.png", "gfx/grid/rocks_secret.png", "gfx/grid/rocks_d12.png", "gfx/grid/rocks_dice.png"},
}

local gibTable = {"BloodGib01", "BloodGib02", "BloodGib03", "BloodGib01", "BloodGib02", "BloodGib03",  "Bone01", "Bone02", "Eye", "Liver", "Guts01", "Guts02"}

local function findOddRockTexture()
    local roomgfx = mod:getCurrentRoomGfx()
    local backdropType = game:GetRoom():GetBackdropType()
    local roomType = game:GetRoom():GetType()

    if roomgfx and type(roomgfx) ~= "function" and roomgfx.Grids and roomgfx.Grids.Rocks then --aaaa this has a lot more edge cases than I thought
        local tab = findOddRock[roomgfx.Grids.Rocks]
        return tab[math.random(#tab)]
    elseif backdropType == 1 then
        local tab = findOddRock["gfx/grid/rocks_basement.png"]
        return tab[math.random(#tab)]
    elseif backdropType == 4 then
        local tab = findOddRock["gfx/grid/rocks_caves.png"]
        return tab[math.random(#tab)]
    elseif backdropType == 6 then
        local tab = findOddRock["gfx/grid/rocks_drownedcaves.png"]
        return tab[math.random(#tab)]
    elseif backdropType == 7 and roomType == RoomType.ROOM_SACRIFICE then
        local tab = findOddRock["gfx/grid/rocks_depths.png"]
        return tab[math.random(#tab)]
    elseif backdropType == 10 then
        local tab = findOddRock["gfx/grid/rocks_womb.png"]
        return tab[math.random(#tab)]
    elseif backdropType == 12 then
        local tab = findOddRock["gfx/grid/rocks_scarredwomb.png"]
        return tab[math.random(#tab)]
    elseif backdropType == 13 then
        local tab = findOddRock["gfx/grid/rocks_bluewomb.png"]
        return tab[math.random(#tab)]
    elseif backdropType == 14 then
        local tab = findOddRock["gfx/grid/rocks_sheol.png"]
        return tab[math.random(#tab)]
    elseif backdropType == 15 then
        local tab = findOddRock["gfx/grid/rocks_cathedral.png"]
        return tab[math.random(#tab)]
    elseif backdropType == 23 and roomType == RoomType.ROOM_SECRET_EXIT then
        local tab = findOddRock["gfx/grid/rocks_secretroom.png"]
        return tab[math.random(#tab)]
    elseif backdropType == 31 then
        local tab = findOddRock["gfx/grid/rocks_downpour.png"]
        return tab[math.random(#tab)]
    elseif backdropType == 32 then
        local tab = findOddRock["gfx/grid/rocks_secretroom.png"]
        return tab[math.random(#tab)]
    elseif backdropType == 33 or backdropType == 40 or backdropType == 41 or backdropType == 42 then
        local tab = findOddRock["gfx/grid/rocks_mausoleum.png"]
        return tab[math.random(#tab)]
    elseif backdropType == 39 then
        local tab = findOddRock["gfx/grid/rocks_corpseentrance.png"]
        return tab[math.random(#tab)]
    elseif backdropType == 43 then
        local tab = findOddRock["gfx/grid/rocks_corpse2.png"]
        return tab[math.random(#tab)]
    elseif backdropType == 45 then
        local tab = findOddRock["gfx/grid/rocks_dross.png"]
        return tab[math.random(#tab)]
    elseif backdropType == 46 then
        local tab = findOddRock["gfx/grid/rocks_ashpit.png"]
        return tab[math.random(#tab)]
    elseif backdropType == 47 then
        local tab = findOddRock["gfx/grid/rocks_gehenna.png"]
        return tab[math.random(#tab)]
    else
        return mod.FloorGrids[math.random(#mod.FloorGrids) + 1].Rocks
    end
end

function mod:fistfulOfAshNewRoom()
    local data = FiendFolio.savedata.run
	local level = game:GetLevel()
	local room = game:GetRoom()
    local currentRoom = level:GetCurrentRoomDesc().ListIndex

    if mod.anyPlayerHas(mod.ITEM.COLLECTIBLE.FISTFUL_OF_ASH) then
        local tab = mod.GetGridEntities()
        local sData = FiendFolio.savedata.run
        sData.perfectVerminConversion = sData.perfectVerminConversion or 4

        mod.perfectVermin = {}

        if room:IsFirstVisit()  and sData.perfectVerminConversion > 0 then
            local tints = false
            local regulars = {}
            for _,grid in ipairs(tab) do
                if grid:GetType() == GridEntityType.GRID_ROCKT then
                    tints = true
                elseif grid:GetType() == GridEntityType.GRID_ROCK then
                    local sprite = grid:GetSprite()
                    if sprite:GetAnimation() == "normal" then
                        table.insert(regulars, grid)
                    end
                end
            end
            if tints == false then
                local rng = RNG()
                rng:SetSeed(room:GetDecorationSeed(), 0)
                if rng:RandomInt(100) < 20 and #regulars > 0 then
                    local chosenRock = regulars[rng:RandomInt(#regulars)+1]
                    chosenRock:SetType(GridEntityType.GRID_ROCKT)
                    sData.perfectVerminConversion = sData.perfectVerminConversion-1
                    chosenRock:GetSprite():Play("tinted", true)
                    --print("conversion")
                end
            end
        end

        for _,grid in ipairs(tab) do
            if grid:GetType() == GridEntityType.GRID_ROCKT then
                data.perfectVerminRocks = data.perfectVerminRocks or {}
                if data.perfectVerminRocks[currentRoom] == nil then
                    data.perfectVerminRocks[currentRoom] = {}
                end
                local index = grid:GetGridIndex()
                if data.perfectVerminRocks[currentRoom][index] == nil then
                    local tex = findOddRockTexture()
                    data.perfectVerminRocks[currentRoom][index] = tex
                end
                if grid.State == 1 then
                    mod.perfectVermin[index] = 4
                else
                    mod.perfectVermin[index] = nil
                end
            end
        end
    end
    --[[local roomgfx = mod:getCurrentRoomGfx()

    if roomgfx and type(roomgfx) ~= "function" and roomgfx.Grids and roomgfx.Grids.Rocks then
        print(roomgfx.Grids.Rocks)
    end
    print(game:GetRoom():GetBackdropType(), game:GetRoom():GetType(), findOddRockTexture())]]

    if data.perfectVerminRocks then
		for list,rooms in pairs(data.perfectVerminRocks) do
			if level:GetCurrentRoomDesc().ListIndex == list then
				for index,tex in pairs(rooms) do
					local grid = room:GetGridEntity(index)
					if grid and grid:GetType() == GridEntityType.GRID_ROCKT then
						local sprite = grid:GetSprite()
						sprite:ReplaceSpritesheet(0, tex)
						sprite:LoadGraphics()
					else
						rooms[index] = nil
					end
				end
			end
		end
	end
end

function mod:fistfulOfAshUpdate(player, data)
    if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.FISTFUL_OF_ASH) then
		local queuedItem = player.QueuedItem
        local rng = player:GetCollectibleRNG(FiendFolio.ITEM.COLLECTIBLE.FISTFUL_OF_ASH)
		
		if queuedItem.Item ~= nil and queuedItem.Item:IsCollectible() and queuedItem.Item.ID == FiendFolio.ITEM.COLLECTIBLE.FISTFUL_OF_ASH then
			if not data.perfectVerminSet then
				mod.setRockTable()
				data.perfectVerminSet = true
			end
		else
			data.perfectVerminSet = nil
		end
		
		for _,grid in ipairs(mod.GetGridEntities()) do
			if mod.perfectVermin[grid:GetGridIndex()] ~= nil then
				if grid.CollisionClass == GridCollisionClass.COLLISION_NONE then
					mod.perfectVermin[grid:GetGridIndex()] = nil
					data.fistfulOfAshBonus = (data.fistfulOfAshBonus or 0)+6
                    if rng:RandomInt(2) == 0 and player:GetBrokenHearts() > 0 then
                        player:AddBrokenHearts(-1)
                        player:AnimateHappy()
                    end
                    for i=1,8 do
                        local particle = Isaac.Spawn(1000, 5, 0, grid.Position, RandomVector()*math.random(70)/10, player):ToEffect()
                        particle:Update()
                        local pSprite = particle:GetSprite()
                        pSprite:Play(gibTable[math.random(#gibTable)], true)
                    end
                    for i=1,4 do
                        local randVel = RandomVector()*math.random(10,30)/20
                        local cloud = Isaac.Spawn(1000, 59, 0, grid.Position, Vector.Zero, nil):ToEffect()
                        cloud:SetTimeout(math.random(100,150))
                        local color = Color(0.45,0,0,0,0,0,0)
                        cloud.Color = color
                        local randScale = math.random(80,150)/100
                        cloud.SpriteScale = Vector(0.5, 0.5)
                        cloud:GetData().cosmeticDust = {scale = randScale, vel = randVel, alpha = 0.5}
                    end
                    local bigSplat = Isaac.Spawn(1000, 7, 0, grid.Position, Vector.Zero, player):ToEffect()
                    bigSplat.SpriteScale = Vector(2,2)
                    bigSplat:Update()
                    for i=0,3 do
                        local splat = Isaac.Spawn(1000, 7, 0, grid.Position+mod:shuntedPosition(60, rng), Vector.Zero, player):ToEffect()
                        local scale = math.random(100,200)/100
                        splat.SpriteScale = Vector(scale, scale)
                        splat:Update()
                    end
                    Isaac.Spawn(1000, 16, 3, grid.Position, Vector.Zero, player)
                    Isaac.Spawn(1000, 16, 4, grid.Position, Vector.Zero, player)

                    for i=1,5 do
                        local tear = Isaac.Spawn(2, 1, 0, grid.Position, Vector(mod:getRoll(2, 5, rng), 0):Rotated(rng:RandomInt(360)), player):ToTear()
                        tear.CollisionDamage = player.Damage*2
                        tear.Scale = mod:getRoll(60,160,rng)/100
                        tear.FallingAcceleration = mod:getRoll(100,180,rng)/100
                        tear.FallingSpeed = -mod:getRoll(10,20,rng)
                        tear:Update()
                    end

                    local heart = Isaac.Spawn(5, 10, 2, grid.Position, Vector(mod:getRoll(1, 3, rng), 0):Rotated(rng:RandomInt(360)), player)
                    for i=1,3 do
                        heart:Update()
                    end

                    sfx:Play(mod.Sounds.VerminImpact, 3.5, 2, false, 1)
                    --FrameDelay stupid
                    mod.scheduleForUpdate(function()
                        sfx:Play(mod.Sounds.VerminBreak, 3.5, 2, false, 1)
                        sfx:Play(mod.Sounds.VerminAgony, 3.5, 2, false, 1)
                    end, 5)
                    mod.scheduleForUpdate(function()
                        sfx:Play(mod.Sounds.VerminGibs, 3.5, 2, false, 1)
                    end, 7)
                    mod.scheduleForUpdate(function()
                        sfx:Play(mod.Sounds.VerminGibs, 2.5, 2, false, 1)
                    end, 13)
                    mod.scheduleForUpdate(function()
                        sfx:Play(mod.Sounds.VerminGibs, 1.5, 2, false, 1)
                    end, 24)
                    mod.scheduleForUpdate(function()
                        sfx:Play(mod.Sounds.VerminGibs, 0.5, 2, false, 1)
                    end, 36)

                    player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
                    player:EvaluateItems()
				end
			end
		end

        if data.fistfulOfAshBonus and data.fistfulOfAshBonus > 0 and player.FrameCount % 35 == 0 then
            data.fistfulOfAshBonus = data.fistfulOfAshBonus-0.1
            player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
            player:EvaluateItems()
        end
	end
end

function mod:fistfulOfAshNewLevel(player)
    if player:HasCollectible(mod.ITEM.COLLECTIBLE.FISTFUL_OF_ASH) then
        mod.scheduleForUpdate(function()
            player:AnimateSad()
            sfx:Play(SoundEffect.SOUND_WHEEZY_COUGH, 0.4, 0, false, math.random(110,130)/100)
            if player:GetPlayerType() == PlayerType.PLAYER_KEEPER or player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B then
            elseif player:GetHeartLimit() > 2 then
                player:AddBrokenHearts(1)
            end
        end, 1)

        local sData = FiendFolio.savedata.run
        sData.perfectVerminConversion = 4

        for i=1,5 do
            local randVel = RandomVector()*math.random(10,30)/20
            local cloud = Isaac.Spawn(1000, 59, 0, player.Position, Vector.Zero, nil):ToEffect()
            cloud:SetTimeout(math.random(60,120))
            local color = Color(0.05,0,0,0,0,0,0)
            cloud.Color = color
            local randScale = math.random(50,90)/100
            cloud.SpriteScale = Vector(0.5, 0.5)
            cloud.SpriteOffset = Vector(0,-10)*player.SpriteScale.Y
            cloud:GetData().cosmeticDust = {scale = randScale, vel = randVel, customEffect = function()
                --[[if cloud.FrameCount > 30 then
                    cloud.Color = Color(cloud.Color.R+0.03,0,0,cloud.Color.A-0.01, 0,0,0)
                end]]
            end}
        end
    end
end