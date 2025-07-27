local mod = LastJudgement
local game = Game()
local sfx = SFXManager()

mod.MortisBackdrop = StageAPI.BackdropHelper({
    Walls = {"1", "1", "1", "2", "3",},
    Floors = {"1", "2", "flooralt_1", "flooralt_2"},
    NFloors = {"nfloor"},
    LFloors = {"lfloor"},
    Corners = {"corner"}
}, "gfx/backdrop/mortis/mortis_", ".png")

mod.MorgueisBackdrop = StageAPI.BackdropHelper({
    Walls = {"1", "1", "1", "2", "3",},
    Floors = {"1", "2", "flooralt_1", "flooralt_2"},
    NFloors = {"nfloor"},
    LFloors = {"lfloor"},
    Corners = {"corner"}
}, "gfx/backdrop/mortis/morgueis_", ".png")

mod.MoistisBackdrop = StageAPI.BackdropHelper({
    Walls = {"1", "1", "1", "2", "3",},
    Floors = {"1", "2", "flooralt_1", "flooralt_2"},
    NFloors = {"nfloor"},
    LFloors = {"lfloor"},
    Corners = {"corner"}
}, "gfx/backdrop/mortis/moistis_", ".png")

function mod:SetMortisGrids()
	local rocks, rocks2, rocks3 = mod:GetMortisRocks()
	local pits, pitsWater, pits2, pitsWater2, pits3, extra = mod:GetMortisPits()

	mod.MortisGrid = StageAPI.GridGfx()
	mod.MortisGrid:SetDoorSpawns(StageAPI.BaseDoorSpawnList)
    mod.MortisGrid:SetDoorSprites{
		Default = "gfx/grid/mortis/mortis_door.png",
		Secret = "gfx/grid/mortis/mortis_hole.png",
	}
	mod.MortisGrid:SetRocks(rocks)
	mod.MortisGrid:SetPits(pits, pitsWater, extra)
    mod.MortisGrid:SetGrid("gfx/grid/mortis/grid_spikes_mortis.png", GridEntityType.GRID_SPIKES)
    mod.MortisGrid:SetGrid("gfx/grid/mortis/grid_spikes_mortis.png", GridEntityType.GRID_SPIKES_ONOFF)
	mod.MortisGrid:SetDecorations("gfx/grid/mortis/props_mortis.png", "gfx/grid/mortis/props_mortis.anm2", 43, "Prop", "", "BigProp", 6)

	mod.MorgueisGrid = StageAPI.GridGfx()
	mod.MorgueisGrid:SetDoorSpawns(StageAPI.BaseDoorSpawnList)
    mod.MorgueisGrid:SetDoorSprites{
		Default = "gfx/grid/mortis/mortis_door.png",
		Secret = "gfx/grid/mortis/mortis_hole.png",
	}
	mod.MorgueisGrid:SetRocks(rocks2)
	mod.MorgueisGrid:SetPits(pits2, pitsWater2, extra)
    mod.MorgueisGrid:SetGrid("gfx/grid/mortis/grid_spikes_mortis.png", GridEntityType.GRID_SPIKES)
    mod.MorgueisGrid:SetGrid("gfx/grid/mortis/grid_spikes_mortis.png", GridEntityType.GRID_SPIKES_ONOFF)
	mod.MorgueisGrid:SetDecorations("gfx/grid/mortis/props_mortis.png", "gfx/grid/mortis/props_mortis.anm2", 43, "Prop", "", "BigProp", 6)

	mod.MoistisGrid = StageAPI.GridGfx()
	mod.MoistisGrid:SetDoorSpawns(StageAPI.BaseDoorSpawnList)
    mod.MoistisGrid:SetDoorSprites{
		Default = "gfx/grid/mortis/mortis_door.png",
		Secret = "gfx/grid/mortis/mortis_hole.png",
	}
	mod.MoistisGrid:SetRocks(rocks3)
	mod.MoistisGrid:SetPits(pits3, nil, extra)
    mod.MoistisGrid:SetGrid("gfx/grid/mortis/grid_spikes_mortis.png", GridEntityType.GRID_SPIKES)
    mod.MoistisGrid:SetGrid("gfx/grid/mortis/grid_spikes_mortis.png", GridEntityType.GRID_SPIKES_ONOFF)
	mod.MoistisGrid:SetDecorations("gfx/grid/mortis/props_mortis.png", "gfx/grid/mortis/props_mortis.anm2", 43, "Prop", "", "BigProp", 6)
end

function mod:GetMortisRocks()
	local savedata = mod:GetSaveData()
	if FiendFolio then
		return 
		"gfx/grid/mortis/rocks_mortis_ff.png", 
		"gfx/grid/mortis/rocks_morgueis_ff.png", 
		"gfx/grid/mortis/rocks_moistis_ff.png"
	else
		return 
		"gfx/grid/mortis/rocks_mortis.png", 
		"gfx/grid/mortis/rocks_morgueis.png", 
		"gfx/grid/mortis/rocks_moistis.png"
	end
end

function mod:GetMortisPits()
	local savedata = mod:GetSaveData()
	if FiendFolio then
		return 
		"gfx/grid/mortis/grid_pit_mortis_ff.png", 
		"gfx/grid/mortis/grid_pit_mortis_ff_chemical.png", 
		"gfx/grid/mortis/grid_pit_morgueis_ff.png", 
		"gfx/grid/mortis/grid_pit_morgueis_ff_chemical.png", 
		"gfx/grid/mortis/grid_pit_moistis_ff.png", 
		true
	else
		return 
		"gfx/grid/mortis/grid_pit_mortis.png", 
		"gfx/grid/mortis/grid_pit_mortis_chemical.png", 
		"gfx/grid/mortis/grid_pit_morgueis.png",
		"gfx/grid/mortis/grid_pit_morgueis_chemical.png", 
		"gfx/grid/mortis/grid_pit_moistis.png", 
		false
	end
end

mod.STAGE.Mortis = StageAPI.CustomStage("Mortis")
mod.MortisGfxRoomTypes = {RoomType.ROOM_DEFAULT, RoomType.ROOM_TREASURE, RoomType.ROOM_MINIBOSS, RoomType.ROOM_BOSS}

function mod:SetMortisRoomGfx()
	mod:SetMortisGrids()
	mod.MortisRoomGfx = StageAPI.RoomGfx(mod.MortisBackdrop, mod.MortisGrid)
	mod.MorgueisRoomGfx = StageAPI.RoomGfx(mod.MorgueisBackdrop, mod.MorgueisGrid)
	mod.MoistisRoomGfx = StageAPI.RoomGfx(mod.MoistisBackdrop, mod.MoistisGrid)
	mod.STAGE.Mortis:SetRoomGfx(mod.MortisRoomGfx, mod.MortisGfxRoomTypes)
end
mod:SetMortisRoomGfx()

mod.STAGE.Mortis:OverrideRockAltEffects(mod.MortisGfxRoomTypes)
mod.STAGE.Mortis:SetBosses(mod.MortisBosses, true)
mod.STAGE.Mortis:SetRequireRoomTypeMatching(true)

mod.STAGE.Mortis:SetStageMusic(mod.Music.Mortis)
mod.STAGE.Mortis:SetBossMusic(Music.MUSIC_BOSS3, Music.MUSIC_BOSS_OVER, Music.MUSIC_JINGLE_BOSS, Music.MUSIC_JINGLE_BOSS_OVER3)
mod.STAGE.Mortis:SetTransitionMusic(Music.MUSIC_JINGLE_NIGHTMARE)
mod.STAGE.Mortis:SetDisplayName("Mortis I")
mod.STAGE.Mortis:SetReplace(StageAPI.StageOverride.CatacombsOne)
mod.STAGE.Mortis:SetLevelgenStage(LevelStage.STAGE4_1, StageType.STAGETYPE_REPENTANCE)
mod.STAGE.Mortis:SetNextStage({
    NormalStage = true,
	AltPath = true,
    Stage = LevelStage.STAGE4_2,
	StageType = StageType.STAGETYPE_REPENTANCE,
})
mod.STAGE.Mortis:SetSpots(
	"gfx/ui/boss/bossspot_mortis.png", 
	"gfx/ui/boss/playerspot_mortis.png",
	Color(20/255, 15/255, 19/255)
)
mod.STAGE.Mortis:SetTransitionIcon(
	"gfx/ui/stage/mortis_icon.png", 
	"gfx/ui/boss/bossspot_mortis.png"
)
mod.STAGE.Mortis:SetPregenerationEnabled(true)
mod.STAGE.Mortis.IsSecondStage = false
mod.STAGE.Mortis:SetStageNumber(8,7)

mod.STAGE.MortisXL = mod.STAGE.Mortis("Mortis XL")
mod.STAGE.MortisXL:SetDisplayName("Mortis XL")
mod.STAGE.MortisXL:SetNextStage({
    NormalStage = true,
    Stage = LevelStage.STAGE5,
	StageType = StageType.STAGE_STAGETYPE_ORIGINAL,
})
mod.STAGE.MortisXL.IsSecondStage = true
mod.STAGE.MortisXL:SetStageNumber(9,7)
mod.STAGE.Mortis:SetXLStage(mod.STAGE.MortisXL)

mod.STAGE.MortisTwo = mod.STAGE.Mortis("Mortis 2")
mod.STAGE.MortisTwo:SetReplace(StageAPI.StageOverride.CatacombsTwo)
mod.STAGE.MortisTwo:SetLevelgenStage(LevelStage.STAGE4_2, StageType.STAGETYPE_REPENTANCE)
mod.STAGE.MortisTwo:SetDisplayName("Mortis II")
mod.STAGE.MortisTwo:SetNextStage({
    NormalStage = true,
    Stage = LevelStage.STAGE5,
	StageType = StageType.STAGE_STAGETYPE_ORIGINAL,
})
mod.STAGE.MortisTwo.IsSecondStage = true
mod.STAGE.MortisTwo:SetStageNumber(9,8)

mod.STAGE.Mortis.CurrentRooms = {}
function mod:LoadMortisRooms()
	for _, roompack in pairs(mod.Rooms.Mortis) do
		mod.STAGE.Mortis.CurrentRooms[#mod.STAGE.Mortis.CurrentRooms + 1] = roompack
	end
	if FiendFolio then
		for _, roompack in pairs(mod.Rooms.MortisFF) do
			mod.STAGE.Mortis.CurrentRooms[#mod.STAGE.Mortis.CurrentRooms + 1] = roompack
		end
	end
	local MortisRooms = StageAPI.RoomsList("Mortis Rooms", table.unpack(mod.STAGE.Mortis.CurrentRooms))
	local ChallengeWaves = StageAPI.RoomsList("Mortis Challenge Rooms", table.unpack(mod.Rooms.MortisChallenge))
	local BossChallengeWaves = StageAPI.RoomsList("Mortis Boss Challenge Rooms", table.unpack(mod.Rooms.MortisBossChallenge))
	mod.STAGE.Mortis:SetRooms({
		[RoomType.ROOM_DEFAULT] = MortisRooms,
		[RoomType.ROOM_TREASURE] = MortisRooms,
		[RoomType.ROOM_SECRET] = MortisRooms,
	})
	mod.STAGE.Mortis:SetChallengeWaves(ChallengeWaves, BossChallengeWaves)
end

function mod:IsMotherRoom(roomDesc)
	roomDesc = roomDesc or game:GetLevel():GetCurrentRoomDesc()
	return (roomDesc.Data and roomDesc.Data.Subtype == 88)
end

function mod:IsMotherEntranceRoom(roomDesc)
	roomDesc = roomDesc or game:GetLevel():GetCurrentRoomDesc()
	return (mod:IsMotherRoom(roomDesc) and roomDesc.Data.Shape == RoomShape.ROOMSHAPE_1x1) 
end

function mod:IsMotherBossRoom(roomDesc)
	roomDesc = roomDesc or game:GetLevel():GetCurrentRoomDesc()
	return (mod:IsMotherRoom(roomDesc) and roomDesc.Data.Shape == RoomShape.ROOMSHAPE_1x2) 
end

mod.DecorationRNG = RNG()
mod.MortisDirtColor = Color(1,0.75,1)
StageAPI.AddCallback("Last Judgement", "PRE_CHANGE_ROOM_GFX", 1, function(currentRoom, usingGfx, onRoomLoad)
	if mod.STAGE.Mortis:IsStage() then
		mod.MortisDirtColor = Color(1,0.75,1)
		mod.UsingMorgueisBackdrop = false
		mod.UsingMoistisBackdrop = false
		if usingGfx then
			local room = game:GetRoom()
			local roomDesc = game:GetLevel():GetCurrentRoomDesc()
			mod.DecorationRNG:SetSeed(room:GetDecorationSeed(), 35)
			if room:HasWater() then
				mod.UsingMoistisBackdrop = true
				return mod.MoistisRoomGfx
			elseif (mod:RandomInt(1,3,mod.DecorationRNG) <= 1 or mod:IsMotherBossRoom(roomDesc)) and not mod:IsMotherEntranceRoom(roomDesc) then
				mod.MortisDirtColor = Color(0.75,0.75,1)
				mod.UsingMorgueisBackdrop = true
				return mod.MorgueisRoomGfx
			end
		end
	end
end)

function mod:GetAbsoluteCenterPos()
	local room = game:GetRoom()
	return Vector(room:GetGridWidth() * 20, room:GetGridHeight() * 20) + Vector(20,100)
end

function mod:GetBackdropCorners()
	local room = game:GetRoom()
	local roomShape = room:GetRoomShape()
	local cp = mod:GetAbsoluteCenterPos()
	local tl = room:GetTopLeftPos() 
	local br = room:GetBottomRightPos()
	local tr = Vector(br.X, tl.Y)
	local bl = Vector(tl.X, br.Y)

	local topleft = tl + Vector(-80,-80)
	local bottomright = br + Vector(80,80)
	local topright = Vector(bottomright.X, topleft.Y)
	local bottomleft = Vector(topleft.X, bottomright.Y) 

	if roomShape == RoomShape.ROOMSHAPE_LTL then
		local topleft1 = Vector(cp.X, tl.Y) + Vector(-80,-80)
		local topleft2 = Vector(tl.X, cp.Y) + Vector(-80,-80)
		return {topleft1, bottomright, topright, bottomleft, topleft2}
	
	elseif roomShape == RoomShape.ROOMSHAPE_LTR then
		local topright1 = Vector(cp.X, tr.Y) + Vector(80,-80)
		local topright2 = Vector(tr.X, cp.Y) + Vector(80,-80)
		return {topleft, bottomright, topright1, bottomleft, topright2}
	
	elseif roomShape == RoomShape.ROOMSHAPE_LBL then
		local bottomleft1 = Vector(cp.X, bl.Y) + Vector(-80,80)
		local bottomleft2 = Vector(bl.X, cp.Y) + Vector(-80,80)
		return {topleft, bottomright, topright, bottomleft1, bottomleft2}
	
	elseif roomShape == RoomShape.ROOMSHAPE_LBR then
		local bottomright1 = Vector(cp.X, br.Y) + Vector(80,80)
		local bottomright2 = Vector(br.X, cp.Y) + Vector(80,80)
		return {topleft, bottomright1, topright, bottomleft, bottomright2}
	
	else
		return {topleft, bottomright, topright, bottomleft}
	end
end

function mod:OrientBackdropDetail(effect, i)
	if i == 2 then
		effect:GetSprite().FlipX = true
		effect:GetSprite().FlipY = true
	elseif i == 3 then
		effect:GetSprite().FlipX = true
	elseif i == 4 then
		effect:GetSprite().FlipY = true
	elseif i == 5 then --L room extra corner
		local roomShape = game:GetRoom():GetRoomShape()
		if roomShape == RoomShape.ROOMSHAPE_LTR then
			effect:GetSprite().FlipX = true
		elseif roomShape == RoomShape.ROOMSHAPE_LBL then
			effect:GetSprite().FlipY = true
		elseif roomShape == RoomShape.ROOMSHAPE_LBR then
			effect:GetSprite().FlipX = true
			effect:GetSprite().FlipY = true
		end
	end
end

function mod:SpawnBackdropDetail(variant, pos, i, offset)
	offset = offset or -10000
	if offset > 0 then
		local detail = Isaac.Spawn(EntityType.ENTITY_EFFECT, variant, 0, pos, Vector.Zero, nil)
		detail.DepthOffset = offset
		mod:OrientBackdropDetail(detail, i)
		detail:AddEntityFlags(EntityFlag.FLAG_DONT_OVERWRITE | EntityFlag.FLAG_BACKDROP_DETAIL)
		return detail
	else
		local details = {}
		for j = 1, 2 do
			local detail = Isaac.Spawn(EntityType.ENTITY_EFFECT, variant, 0, pos, Vector.Zero, nil)
			detail.DepthOffset = offset
			mod:OrientBackdropDetail(detail, i)
			if j == 1 then
				detail:AddEntityFlags(EntityFlag.FLAG_RENDER_WALL | EntityFlag.FLAG_DONT_OVERWRITE | EntityFlag.FLAG_BACKDROP_DETAIL)
			else
				detail:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR | EntityFlag.FLAG_DONT_OVERWRITE | EntityFlag.FLAG_BACKDROP_DETAIL)
			end
			table.insert(details, detail)
		end
		return details
	end
end

StageAPI.AddCallback("Last Judgement", "POST_CHANGE_ROOM_GFX", 1, function(currentRoom, usingGfx, onRoomLoad)
	if mod.STAGE.Mortis:IsStage() then
		if usingGfx then
			local room = game:GetRoom()
			mod.DecorationRNG:SetSeed(room:GetDecorationSeed(), 0)

			for i, corner in pairs(mod:GetBackdropCorners()) do
				local isTop = (corner.Y < room:GetCenterPos().Y)
				if isTop and mod.DecorationRNG:RandomFloat() <= 0.1 and not mod:IsMotherBossRoom(game:GetLevel():GetCurrentRoomDesc()) then
					local detail = mod:SpawnBackdropDetail(mod.ENT.MortisDetails.Var, corner, i, 10000)
					detail:GetSprite():SetFrame("Details", 0)
					detail:Update()
				end
			end

			if mod.UsingMoistisBackdrop and mod:RandomInt(1,1,mod.DecorationRNG) == 1 then
				local tries = 5
				while tries > 0 do
					local spawnx = mod:RandomInt(room:GetTopLeftPos().X + 80, (room:GetGridWidth() * 40) - 80, mod.DecorationRNG)
					local spawny = mod:RandomInt(room:GetTopLeftPos().Y + 80, (room:GetGridHeight() * 40) - 80, mod.DecorationRNG)
					if room:IsPositionInRoom(Vector(spawnx, spawny), 50) then
						mod.RainingPos = Vector(spawnx, spawny)
						tries = 0
					else
						tries = tries - 1
					end
				end
			else
				mod.RainingPos = nil
			end

			local hasTerrorCell = (mod:GetEntityCount(mod.ENT.TerrorCell.ID, mod.ENT.TerrorCell.Var) > 0)
			local mistAmount = hasTerrorCell and mod:RandomInt(6,8,mod.DecorationRNG) or mod:RandomInt(3,5,mod.DecorationRNG)
			for i = 1, mistAmount do 
				local spawnx = mod:RandomInt(room:GetTopLeftPos().X - 200, (room:GetGridWidth() * 40) + 200, mod.DecorationRNG)
				local spawny = mod:RandomInt(room:GetTopLeftPos().Y - 60, (room:GetGridHeight() * 40) + 120, mod.DecorationRNG)
				local mistspeed = mod:RandomInt(50,150,mod.DecorationRNG) * 0.01
				local mistvel
				if spawnx <= room:GetCenterPos().X then
					mistvel = Vector(mistspeed,0)
				else
					mistvel = Vector(-mistspeed,0)
				end
				local mist = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.MIST, 0, Vector(spawnx, spawny), mistvel, nil)
				mist:GetSprite():SetFrame("Idle", mod:RandomInt(0,3,mod.DecorationRNG))
				mist:GetSprite().FlipX = (mod.DecorationRNG:RandomFloat() <= 0.5)
				mist.Color = (hasTerrorCell and Color(0.25,0.65,1.2)) or (mod.UsingMoistisBackdrop and mod.Colors.MoistisWater) or Color(0.8,0.8,1)
				mist:GetData().MortisMist = true
				mod:FadeIn(mist, 30)
				mist:Update()
			end

			StageAPI.ChangeStageShadow("gfx/overlays/mortis/", 1, 0.25, true)
		end
	end
end)

function mod:MortisVisualEffectsUpdate()
	if mod.STAGE.Mortis:IsStage() then
		local room = game:GetRoom()
		
		mod.RainVolume = mod.RainVolume or 0
		local targetRainVolume = 0
		
		if mod.RainingPos and room:HasWater() then --Rain update
			Isaac.Spawn(1000, EffectVariant.RAIN_DROP, 0, mod.RainingPos + (RandomVector()*mod:RandomInt(0,80)), Vector.Zero, nil)
			local player = game:GetNearestPlayer(mod.RainingPos)
			targetRainVolume = math.max(0, 1 - player.Position:Distance(mod.RainingPos)/600)
		end
		
		mod.RainVolume = mod:Lerp(mod.RainVolume, targetRainVolume, 0.1)
		sfx:SetAmbientSound(mod.Sounds.RainLoop, mod.RainVolume, 1)
	else
		sfx:Stop(mod.Sounds.RainLoop)
	end
end

local function IsOffScreen(pos, val)
	local room = game:GetRoom()
	local centerpos = room:GetCenterPos()
	if pos.X < centerpos.X then
		return (room:GetGridPosition(0).X - pos.X > val)
	else
		return (room:GetGridPosition(room:GetGridSize() - 1).X - pos.X < -val)
	end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
	local data = effect:GetData()
	if data.MortisMist then
		local room = game:GetRoom()
		if room:IsPositionInRoom(effect.Position,0) then
			data.CrossedOver = true
		end
		if data.CrossedOver then
			if IsOffScreen(effect.Position,400) then
				effect:Remove()
			elseif IsOffScreen(effect.Position,0) and not data.SpawnedNewMist then
				local spawnpos = Vector((effect.Position.X - room:GetCenterPos().X) * -3.5, effect.Position.Y + mod:RandomInt(-80,80,mod.DecorationRNG))
				local mist = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.MIST, 0, spawnpos, effect.Velocity, effect.SpawnerEntity)
				mist:GetSprite():SetFrame("Idle", mod:RandomInt(0,3,mod.DecorationRNG))
				mist:GetSprite().FlipX = (mod.DecorationRNG:RandomFloat() <= 0.5)
				mist.Color = effect.Color
				mist:GetData().MortisMist = true
				mod:FadeIn(mist, 30)
				mist:Update()
				data.SpawnedNewMist = true
			end
		end
	elseif mod.STAGE.Mortis:IsStage() then
		effect.Visible = false
		effect:Remove()
	end
end, EffectVariant.MIST)

StageAPI.AddCallback("Last Judgement", "POST_OVERRIDDEN_ALT_ROCK_BREAK", 1, function(gridpos, gridvar, shroomData, customGrid)
	if mod.STAGE.Mortis:IsStage() then
		sfx:Play(SoundEffect.SOUND_MEATY_DEATHS)
		sfx:Stop(SoundEffect.SOUND_MUSHROOM_POOF_2)
		mod:ScheduleForUpdate(function() sfx:Stop(SoundEffect.SOUND_MUSHROOM_POOF_2) end, 2, ModCallbacks.MC_POST_RENDER)

        local spawnedItem, spawnedPickup, spawnedFart
        if shroomData then
            for _, spawn in ipairs(shroomData) do
                if spawn.Type == EntityType.ENTITY_PICKUP and spawn.Variant == PickupVariant.PICKUP_COLLECTIBLE then
                    spawnedItem = true
                    break
                end

				if spawn.Type == EntityType.ENTITY_PICKUP and spawn.Variant == PickupVariant.PICKUP_PILL then
                    spawnedPickup = true
                    break
                end

                if spawn.Type == EntityType.ENTITY_EFFECT and spawn.Variant == EffectVariant.FART then
                    spawnedFart = true
                    break
                end
            end
        end
        if spawnedItem then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_EXPERIMENTAL_TREATMENT, gridpos, Vector.Zero, nil)
			game:GetItemPool():RemoveCollectible(CollectibleType.COLLECTIBLE_EXPERIMENTAL_TREATMENT)
        elseif spawnedPickup then
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_PILL, 0, gridpos, Vector.Zero, nil)
			--Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_HEART, HeartSubType.HEART_ROTTEN, gridpos, Vector.Zero, nil)
		elseif spawnedFart then
			local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, gridpos, Vector.Zero, nil)
			poof.Color = mod.Colors.VirusBlue
			poof:Update()
			for i = 1, 4 do
				local vec = RandomVector() * 12
                local phage = Isaac.Spawn(mod.ENT.Phage.ID, mod.ENT.Phage.Var, 0, gridpos + vec, vec, nil)
				phage:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
				phage:GetData().State = "Idle"
			end
        end
    end
end)

function mod:SetColorCorrection(doLerp)
    if mod.STAGE.Mortis:IsStage() then
		local fxParams = game:GetRoom():GetFXParams()
	
		if mod.UsingMoistisBackdrop then
			fxParams.WaterEffectColor = mod.Colors.MoistisWater
			fxParams.WaterColor = KColor(0.25,0.7,0.7,0.5)
			fxParams.LightColor = KColor(0.5,1.5,1.5,0.8)
		elseif mod.UsingMorgueisBackdrop then
			fxParams.WaterEffectColor = mod.Colors.MorgueisWater
			fxParams.LightColor = KColor(1.5,0.25,1.5,0.8)
		else
			fxParams.WaterEffectColor = mod.Colors.MortisWater
			fxParams.LightColor = KColor(1.5,1.25,0.65,0.8)
		end
	
		game:SetColorModifier(ColorModifier(0.6,0.8,1.3,0.2,0,1.025), doLerp)
    end
end

--Chemical flooded rooms
function mod:FloodMortisRoom(roomDesc, room)
	if room then
		room:SetWaterAmount(1)
	end
	roomDesc.Flags = roomDesc.Flags | RoomDescriptor.FLAG_FLOODED
end

mod.MortisFloodableRoomTypes = {
	[RoomType.ROOM_DEFAULT] = true,
	[RoomType.ROOM_TREASURE] = true,
	[RoomType.ROOM_MINIBOSS] = true,
}
mod.FloodingRNG = RNG()
StageAPI.AddCallback("Last Judgement", "EARLY_NEW_CUSTOM_STAGE", 1, function(customStage)
	if customStage and customStage.Name == "Mortis" then
		local level = game:GetLevel()
		local roomsList = level:GetRooms()
		for i = 0, roomsList.Size - 1 do
			local roomDesc = roomsList:Get(i)
			if roomDesc then
				roomDesc = level:GetRoomByIdx(roomDesc.SafeGridIndex, 0)
				if roomDesc then
					mod.FloodingRNG:SetSeed(roomDesc.DecorationSeed + 1, 35)
					if mod:RandomInt(1,7,mod.FloodingRNG) <= 1 and roomDesc.Data and mod.MortisFloodableRoomTypes[roomDesc.Data.Type] then
						if roomDesc.SafeGridIndex == level:GetStartingRoomIndex() then
							mod:FloodMortisRoom(roomDesc, game:GetRoom())
						else
							mod:FloodMortisRoom(roomDesc)
						end
					end
				end
			end
		end
	end
end)

mod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, CallbackPriority.EARLY, function()
	if mod.STAGE.Mortis:IsStage() then
		local level = game:GetLevel()
		local room = game:GetRoom()
		local roomDesc = level:GetRoomByIdx(level:GetCurrentRoomIndex(), level:GetDimension())
		if roomDesc.Flags & RoomDescriptor.FLAG_FLOODED ~= 0 then
			--print("addWater")
			mod:FloodMortisRoom(roomDesc, room)
		elseif room:GetWaterAmount() > 0 then
			--print("removeWater")
			room:SetWaterAmount(0)
		end

		if not room:HasWater() then
			--print("noWater")
			for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
				local door = room:GetDoor(i)
				if door then
					local doorRoomDesc = level:GetRoomByIdx(door.TargetRoomIndex, level:GetDimension())
					if doorRoomDesc and doorRoomDesc.Flags & RoomDescriptor.FLAG_FLOODED ~= 0 then
						--print("do flooding at slot "..i)
						local vec = Vector(0,1):Rotated(door:GetSprite().Rotation)
						for i = 20, 180, 20 do
							local spawnpos = door.Position + vec:Resized(i) + vec:Rotated(90):Resized(mod:RandomInt(-15,15))
							local splat = Isaac.Spawn(mod.ENT.MortisSplat.ID, mod.ENT.MortisSplat.Var, 0, spawnpos, Vector.Zero, nil)
							local sprite = splat:GetSprite()
							local anim = "Size"..math.ceil(((180 - i)/33) + 1).."BloodStains"
							local frame = mod:RandomInt(0, sprite:GetAnimationData(anim):GetLength())
							sprite:SetFrame(anim, frame)
							splat.Color = mod.Colors.OrganBlue
							sprite:GetLayer(0):SetColor(Color(1,1,1,mod:RandomInt(75,100) * 0.01))
							splat.SortingLayer = SortingLayer.SORTING_BACKGROUND
							splat:AddEntityFlags(EntityFlag.FLAG_FRIENDLY) --Look StageAPI don't delete this one heheheehe kms
							mod:ScheduleForUpdate(function() splat:AddEntityFlags(EntityFlag.FLAG_RENDER_FLOOR) end, 0)
						end
					end
				end
			end
		end
	end
end)

function mod:GetMortisBackdropSplatColor()
	if mod.UsingMorgueisBackdrop then
		return mod.Colors.VirusBlue
	elseif mod.UsingMoistisBackdrop then
		return mod.Colors.OrganBlue
	else
		return mod.Colors.MortisBlood
	end
end

--Scalpels
function mod:SpawnScalpelLines()
	local currentRoom = StageAPI.GetCurrentRoom()
	if currentRoom then
		for _, metaEnt in pairs(currentRoom.Metadata:Search({Name = "ScalpelLine"})) do
			Isaac.Spawn(mod.ENT.ScalpelLine.ID, mod.ENT.ScalpelLine.Var, metaEnt.BitValues.Frame, game:GetRoom():GetGridPosition(metaEnt.Index), Vector.Zero, nil)
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
	effect:GetSprite():SetFrame("Lines", effect.SubType)
	effect.SortingLayer = SortingLayer.SORTING_BACKGROUND
	effect.RenderZOffset = 3500
end, mod.ENT.ScalpelLine.Var)

function mod:MakeScalpelPit(npc, doCheck)
	local room = game:GetRoom()
	sfx:Play(SoundEffect.SOUND_MEATY_DEATHS)
	for i = 1, 3 do
		local particle = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCK_PARTICLE, 0, npc.Position, RandomVector() * mod:RandomInt(2,6), npc)
		particle:Update()
	end
	local poof = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BLOOD_EXPLOSION, 0, npc.Position, Vector.Zero, npc)
	poof.DepthOffset = -40
	poof.Color = mod:GetMortisBackdropSplatColor()
	poof:Update()
	if room:CanSpawnObstacleAtPosition(room:GetGridIndex(npc.Position), true) or not doCheck then
		local index = room:GetGridIndex(npc.Position)
		local grid = room:GetGridEntity(index)
		local makeBridge = false
		if grid then 
			if grid:GetType() == GridEntityType.GRID_PIT then
				return false
			else
				if grid.CollisionClass >= GridCollisionClass.COLLISION_SOLID and grid:Destroy(true) then
					makeBridge = true
				elseif grid.CollisionClass > GridCollisionClass.COLLISION_NONE then
					return false
				end
			end
		end
		local pit = Isaac.GridSpawn(GridEntityType.GRID_PIT, 0, npc.Position, true):ToPit()
		if makeBridge then
			pit:MakeBridge(grid)
		end
		mod:UpdatePits()
		pit:PostInit()
		return true
	end
	return false
end

mod.ScalpelMoveData = {
	[0] = {
		[Direction.LEFT] = Direction.LEFT,
		[Direction.RIGHT] = Direction.RIGHT,
	},
	[1] = {
		[Direction.UP] = Direction.UP,
		[Direction.DOWN] = Direction.DOWN,
	},
	[2] = {
		[Direction.NO_DIRECTION] = Direction.RIGHT,
	},
	[3] = {
		[Direction.NO_DIRECTION] = Direction.LEFT,
	},
	[4] = {
		[Direction.NO_DIRECTION] = Direction.DOWN,
	},
	[5] = {
		[Direction.NO_DIRECTION] = Direction.UP,
	},
	[6] = {
		[Direction.UP] = Direction.RIGHT,
		[Direction.LEFT] = Direction.DOWN,
	},
	[7] = {
		[Direction.UP] = Direction.LEFT,
		[Direction.RIGHT] = Direction.DOWN,
	},
	[8] = {
		[Direction.DOWN] = Direction.RIGHT,
		[Direction.LEFT] = Direction.UP,
	},
	[9] = {
		[Direction.DOWN] = Direction.LEFT,
		[Direction.RIGHT] = Direction.UP,
	},
	[10] = {
		[Direction.LEFT] = Direction.LEFT,
		[Direction.UP] = Direction.UP,
		[Direction.RIGHT] = Direction.RIGHT,
		[Direction.DOWN] = Direction.DOWN,
	},
}

local moveDirToSuffix = {
	[Direction.NO_DIRECTION] = {"Hori", false},
	[Direction.LEFT] = {"Hori", false},
	[Direction.UP] = {"Up", false},
	[Direction.RIGHT] = {"Hori", true},
	[Direction.DOWN] = {"Down", false},
}

local function GetScalpelMovement(npc)
	local currentRoom = StageAPI.GetCurrentRoom()
	if currentRoom then
		local metaEnts = currentRoom.Metadata:Search({Name = "ScalpelLine"; Index = game:GetRoom():GetGridIndex(npc.Position)})
		if metaEnts and #metaEnts > 0 then
			local metaEnt = metaEnts[1]
			local data = mod.ScalpelMoveData[metaEnt.BitValues.Frame]
			if data then
				return data[npc:GetData().MoveDirection]
			end
		end
	end
end

function mod:IsScalpel(ent)
	return (ent.Type == mod.ENT.ScalpelTimed.ID and (ent.Variant == mod.ENT.ScalpelTimed.Var or ent.Variant == mod.ENT.ScalpelKills.Var or ent.Variant == mod.ENT.ScalpelEventTriggered.Var))
end

local scalpelCutInterval = 8

function mod:ScalpelAI(npc, sprite, data, isDoc)
	local room = game:GetRoom()

	if not data.Init then
		npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK | EntityFlag.FLAG_NO_REWARD | EntityFlag.FLAG_NO_BLOOD_SPLASH)
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc.Visible = false
		npc.CollisionDamage = 0
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		npc.V1 = Vector.Zero
		if npc.Variant == mod.ENT.ScalpelTimed.Var then
			npc.StateFrame = npc.SubType * 5
		elseif npc.Variant == mod.ENT.ScalpelKills.Var then
			npc.StateFrame = npc.SubType
		end
		data.CutInterval = scalpelCutInterval
		data.MoveDirection = Direction.NO_DIRECTION
		data.State = "Waiting"
		data.Init = true

		mod:ScheduleForUpdate(function() 
			if mod.UsingMorgueisBackdrop then
				sprite:ReplaceSpritesheet(0, "gfx/grid/mortis/scalpel_morgueis.png", true)
			elseif mod.UsingMoistisBackdrop then
				sprite:ReplaceSpritesheet(0, "gfx/grid/mortis/scalpel_moistis.png", true)
			end
		end, 0)
	end

	if data.State == "Waiting" then
		if npc.Variant == mod.ENT.ScalpelTimed.Var then
			npc.StateFrame = npc.StateFrame - 1
		end
	
		local shouldEmerge = false
		if npc.Variant == mod.ENT.ScalpelEventTriggered.Var then
			local currentRoom = StageAPI.GetCurrentRoom()
			if currentRoom then
				local metaEnts = currentRoom.Metadata:Search({Name = "ScalpelLine"; Index = game:GetRoom():GetGridIndex(npc.Position)})
				if metaEnts and #metaEnts > 0 then
					local metaEnt = metaEnts[1]
					shouldEmerge = metaEnt.Triggered
				end
			end
		else
			shouldEmerge = (npc.StateFrame <= 0)
		end
		if shouldEmerge then
			data.State = "Emerge"
			mod:SpritePlay(sprite, "Emerge")
			npc.Visible = true
		elseif not (mod:IsRoomActive() or npc.Variant == mod.ENT.ScalpelEventTriggered.Var) then
			npc:Remove()
		end

	elseif data.State == "Emerge" then
		if sprite:IsFinished("Emerge") then
			npc.StateFrame = data.CutInterval
			data.State = "Idle"
		elseif sprite:IsEventTriggered("Coll") then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
		elseif sprite:IsEventTriggered("Sound") then
			mod:PlaySound(SoundEffect.SOUND_MEATY_DEATHS, npc, 2, 0.5)
		elseif sprite:IsEventTriggered("Break") then
			npc.CollisionDamage = 2
			if mod:MakeScalpelPit(npc, isDoc) then
				if mod:HasWaterPits() then 
					npc:SetColor(game:GetRoom():GetFXParams().WaterEffectColor, 15, 999, true, true)
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.BIG_SPLASH, 0, npc.Position, Vector.Zero, npc)
					mod:PlaySound(SoundEffect.SOUND_BOSS2_DIVE, npc, 1.25, 0.75)
				end
			end
			mod:PlaySound(SoundEffect.SOUND_KNIFE_PULL, npc)
		else
			mod:SpritePlay(sprite, "Emerge")
		end

	elseif data.State == "Idle" then
		npc.StateFrame = npc.StateFrame - 1
		if npc.StateFrame <= 0 then
			if isDoc then
				data.MoveDirection = Direction.NO_DIRECTION
				local shouldLeave = true
				if npc.I1 > 0 then
					local currentRoom = StageAPI.GetCurrentRoom()
					local targetpos = mod:GetPlayerTargetPos(npc)
					local dist = 9999
					for i = 90, 360, 90 do
						local samplePos = npc.Position + Vector(40,0):Rotated(i)
						local index = room:GetGridIndex(samplePos)
						if room:CanSpawnObstacleAtPosition(index, true) and not (currentRoom and currentRoom.Metadata:Has({Name = "ScalpelLine"; Index = index})) then
							local newDist = targetpos:Distance(samplePos)
							if newDist < dist then
								data.MoveDirection = mod:VecToDir(samplePos - npc.Position)
								dist = newDist
								shouldLeave = false
							end
						end
					end
				end
				if shouldLeave then
					local animData = moveDirToSuffix[data.MoveDirection]
					data.AnimSuffix, sprite.FlipX = animData[1], animData[2]
					data.State = "Leave"
				else
					local animData = moveDirToSuffix[data.MoveDirection]
					data.AnimSuffix, sprite.FlipX = animData[1], animData[2]
					data.State = "Move"
					sprite:Play("Move"..data.AnimSuffix, true)
					npc.I1 = npc.I1 - 1
				end
			else
				local newDir = GetScalpelMovement(npc)
				if newDir and (mod:IsRoomActive() or npc.Variant == mod.ENT.ScalpelEventTriggered.Var) then
					data.MoveDirection = newDir
					local animData = moveDirToSuffix[data.MoveDirection]
					data.AnimSuffix, sprite.FlipX = animData[1], animData[2]
					data.State = "Move"
					sprite:Play("Move"..data.AnimSuffix, true)
				else
					local animData = moveDirToSuffix[data.MoveDirection]
					data.AnimSuffix, sprite.FlipX = animData[1], animData[2]
					data.State = "Leave"
				end
			end

		end

	elseif data.State == "Move" then
		if sprite:IsFinished("Move"..data.AnimSuffix) then
			npc.StateFrame = data.CutInterval
			data.State = "Idle"
		elseif sprite:IsEventTriggered("Move") then
			npc.V1 = Vector(-8,0):Rotated(data.MoveDirection * 90)
		elseif sprite:IsEventTriggered("Break") then
			npc.V1 = Vector.Zero
			mod:MakeScalpelPit(npc, isDoc)
			mod:PlaySound(SoundEffect.SOUND_KNIFE_PULL, npc, 1.2, 0.5)
		else
			mod:SpritePlay(sprite, "Move"..data.AnimSuffix)
		end
	
	elseif data.State == "Leave" then
		if sprite:IsFinished("Leave"..data.AnimSuffix) then
			if isDoc then
				return true
			else
				npc:Remove()
			end
		elseif sprite:IsEventTriggered("Coll") then
			npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		else
			mod:SpritePlay(sprite, "Leave"..data.AnimSuffix)
		end
	end

	npc.Velocity = npc.V1
end

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, function(_, npc)
    if npc:IsEnemy() and npc:CanShutDoors() then
		for _, scalpel in pairs(Isaac.FindByType(mod.ENT.ScalpelKills.ID, mod.ENT.ScalpelKills.Var)) do
			scalpel = scalpel:ToNPC()
			scalpel.StateFrame = scalpel.StateFrame - 1
		end
	end
end)

--Full heart damage in Mortis--
mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, function(_, player, amount, flags, source)
	if mod.STAGE.Mortis:IsStage() and amount < 2 and not mod:HasDamageFlag(flags, DamageFlag.DAMAGE_NO_MODIFIERS) then
		return {Damage = 2}
	end
end, EntityType.ENTITY_PLAYER)

--Going to Mortis
function mod:ShouldGoToMortis()
	if Isaac.GetPersistentGameData():Unlocked(mod.Achievement.Mortis) then
		local currentstage = StageAPI.GetCurrentStage()
		local levelstage = game:GetLevel():GetStage() 
		local stagetype = game:GetLevel():GetStageType()
		if currentstage and currentstage.LevelgenStage then
			levelstage = currentstage.LevelgenStage.Stage
			stagetype = currentstage.LevelgenStage.StageType
		end
		if stagetype == StageType.STAGETYPE_REPENTANCE or stagetype == StageType.STAGETYPE_REPENTANCE_B then
			if game:GetStateFlag(GameStateFlag.STATE_MAUSOLEUM_HEART_KILLED) and levelstage == LevelStage.STAGE3_2 then
				return true
			elseif levelstage == LevelStage.STAGE4_1 then
				return true
			end
		end
		return false
	end
end

mod.ForceMortis = true
mod.StageRNG = RNG()
StageAPI.AddCallback("Last Judgement", "PRE_SELECT_NEXT_STAGE", 1, function(currentStage, isSecretExit)
	if not (mod.TriedSelectStage or game:IsGreedMode()) then
		mod.TriedSelectStage = true
		local mortisChance = 0.5
		mod.StageRNG:SetSeed(game:GetRoom():GetDecorationSeed() + 1, 35)
		if (mod.ForceMortis or mod.StageRNG:RandomFloat() <= mortisChance) then
			--StageAPI.Log("Going to Mortis")
			local levelstage = mod:GetStageAndType()
			if levelstage == LevelStage.STAGE3_2 then
				--StageAPI.Log("Mortis I chosen")
				mod.DoMortisDarkness = true
				return mod.STAGE.Mortis
			elseif levelstage == LevelStage.STAGE4_1 then
				--StageAPI.Log("Mortis II chosen")
				return mod.STAGE.MortisTwo
			end
		end
	end
end)

--Choice item rooms in Mortis
function mod:CheckForMortisChoiceItemRoom()
	local room = game:GetRoom()
	if room:GetType() == RoomType.ROOM_TREASURE and room:IsFirstVisit() and StageAPI.GetCurrentRoom() then
		mod.StageRNG:SetSeed(room:GetDecorationSeed(), 35)
		local subtype = StageAPI.GetCurrentRoom().Layout.SubType 
		local choicelimit = 2 --Default choices is 2
		if subtype == 1 or subtype == 3 then --Increases choices to 3 in More Options layouts
			choicelimit = 3
		end
		for i, item in pairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
			item = item:ToPickup()
			if i <= choicelimit then
				item.OptionsPickupIndex = 1
			end
			if i == 2 and not (mod:AnyPlayerHasTrinket(TrinketType.TRINKET_BROKEN_GLASSES) and mod.StageRNG:RandomFloat() <= 0.5) then --Second item -> make it a ?
				item:SetForceBlind(true)
			end
		end
	end
end

--Remove alt path door in Mortis
function mod:CheckAltPathDoor()
    local room = game:GetRoom()
    if mod.STAGE.Mortis:IsStage() and room:GetType() == RoomType.ROOM_BOSS and room:IsClear() then
        if not mod.CheckedForAltDoor then
            for i = 0, DoorSlot.NUM_DOOR_SLOTS - 1 do
                local door = room:GetDoor(i)
                if door then
                    if door.TargetRoomType == RoomType.ROOM_SECRET_EXIT then 
                        shouldRemoveDoor = true
                        if shouldRemoveDoor then
                            for _, dust in pairs(Isaac.FindByType(1000, EffectVariant.DUST_CLOUD)) do
                                if dust.Position:Distance(door.Position) <= 20 then
                                    dust.Visible = false
                                    dust:Remove()
                                end
                            end
                            StageAPI.GetCurrentRoom().PersistentData.AltPathDoorSlotToRemove = i
                            room:RemoveDoor(i)
                        end
                        break
                    end
                end
            end
            mod.CheckedForAltDoor = true
        end
    end
end

function mod:CheckAltPathDoor2()
	if mod.STAGE.Mortis:IsStage() then
		local currentRoom = StageAPI.GetCurrentRoom()
		if currentRoom and currentRoom.PersistentData.AltPathDoorSlotToRemove then
			game:GetRoom():RemoveDoor(currentRoom.PersistentData.AltPathDoorSlotToRemove)
			mod.CheckedForAltDoor = true
		end
	end
end

--Mother
StageAPI.AddCallback("Last Judgement", "PRE_BOSS_SELECT", -10, function(bosses, rng, roomDesc, ignoreNoOptions)
	if mod.STAGE.Mortis:IsStage() and mod:IsMotherEntranceRoom(roomDesc) then 
		return true
	end
end)

function mod:CheckForMotherRoom()
	if mod.STAGE.Mortis:IsStage() then
		local room = game:GetRoom()
		local roomDesc = game:GetLevel():GetCurrentRoomDesc()
		if mod:IsMotherEntranceRoom(roomDesc) then 
			for _, door in pairs(mod:GetAllDoors()) do
				if not (door.TargetRoomType == RoomType.ROOM_DEFAULT or (door.TargetRoomType == RoomType.ROOM_BOSS and door.TargetRoomIndex >= 0)) then
					room:RemoveDoor(door.Slot)
				end
			end

			local grid = room:GetGridEntityFromPos(room:GetCenterPos())
			if grid and grid:GetType() ~= GridEntityType.GRID_TRAPDOOR then
				room:RemoveGridEntityImmediate(grid:GetGridIndex(), 0, false)
				grid = nil
			end
			if not grid then
				grid = Isaac.GridSpawn(GridEntityType.GRID_TRAPDOOR, 0, room:GetCenterPos(), true)
			end
			grid:GetSprite():ReplaceSpritesheet(0, "gfx/grid/mortis/trapdoor_mortis_big.png", true)

		elseif mod:IsMotherBossRoom(roomDesc) then
			if not room:IsClear() then
				local spawnPos = room:GetGridPosition(67) + Vector(0,100)
				for _, player in pairs(mod:GetAllPlayers()) do
					mod:MovePlayer(player, spawnPos)
				end
				room:GetCamera():SnapToPosition(spawnPos)
			end

			for _, effect in pairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.BACKDROP_DECORATION)) do
				local sprite = effect:GetSprite()
				for i = 0, 3 do
					sprite:ReplaceSpritesheet(i, "gfx/backdrop/mortis/morgueis_bottomwall.png")
				end
				sprite:LoadGraphics()
			end

			mod.CheckForMotherVsScreen = true
		end
	end
end

function mod:LoadMotherVsScreen()
	local sprite = RoomTransition.GetVersusScreenSprite()
	sprite:ReplaceSpritesheet(4, "gfx/enemies/reskins/mother/portrait_mother_mortis.png")
	sprite:ReplaceSpritesheet(15, "gfx/enemies/reskins/mother/portrait_mother_mortis.png")
	sprite:ReplaceSpritesheet(3, "gfx/ui/boss/playerspot_mortis_blue.png")
	sprite:GetLayer(0):SetColor(Color(14/255, 14/255, 20/255))
	sprite:LoadGraphics()
end

mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, function(_, id, var, sub, pos, vel, spawner, seed)
	if id == EntityType.ENTITY_MOTHER and var == 0 and sub == 0 then
		if mod.STAGE.Mortis:IsStage() then
			local room = game:GetRoom()
			local roomDesc = game:GetLevel():GetCurrentRoomDesc()
			if mod:IsMotherBossRoom(roomDesc) and room:GetFrameCount() <= 0 and room:IsFirstVisit() and not room:IsClear() then
				for i = 0, 149 do
					local grid = room:GetGridEntity(i)
					if grid and grid:GetType() ~= GridEntityType.GRID_WALL then
						room:RemoveGridEntityImmediate(i, 0, false)
					end
				end
				StageAPI.ConsoleSpawningGrid = true
				for i = 150, room:GetGridSize() - 1 do
					local grid = room:GetGridEntity(i)
					if not (grid and grid:GetType() == GridEntityType.GRID_WALL) then
						Isaac.ExecuteCommand("gridspawn 1999 "..i)
					end
				end
				StageAPI.ConsoleSpawningGrid = false
			end
		end
	end
end)

StageAPI.AddCallback("Last Judgement", "POST_SELECT_BOSS_MUSIC", 1, function(currentstage, musicID, isCleared, musicRNG)
	if mod.STAGE.Mortis:IsStage() and mod:IsMotherBossRoom(game:GetLevel():GetCurrentRoomDesc()) then
		if musicID == Music.MUSIC_BOSS3 then
			return Music.MUSIC_MOTHER_BOSS
		elseif musicID == Music.MUSIC_JINGLE_BOSS_OVER3 then
			return Music.MUSIC_JINGLE_MOTHER_OVER
		end
	end
end)

function mod:HasCurse(curse)
    return (game:GetLevel():GetCurses() & curse > 0)
end

function mod:IsXLFloor()
    return mod:HasCurse(LevelCurse.CURSE_OF_LABYRINTH)
end

mod:AddPriorityCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, CallbackPriority.IMPORTANT, function(_, rng, spawnPos)
	if mod.STAGE.Mortis:IsStage() and mod:IsMotherBossRoom(game:GetLevel():GetCurrentRoomDesc()) then
		game:GetLevel():SetStage(mod:IsXLFloor() and LevelStage.STAGE4_1 or LevelStage.STAGE4_2, StageType.STAGETYPE_REPENTANCE)
		--Isaac.Spawn(EntityType.ENTITY_PICKUP, game.Challenge > 0 and PickupVariant.PICKUP_TROPHY or PickupVariant.PICKUP_BIGCHEST, 0, spawnPos, Vector.Zero, nil)
		mod:ScheduleForUpdate(function()
			game:GetLevel():SetStage(mod:IsXLFloor() and LevelStage.STAGE2_1 or LevelStage.STAGE2_2, StageType.STAGETYPE_WOTL)
		end, 5, ModCallbacks.MC_POST_UPDATE, true)
	end

	mod:CheckMortisUnlock()
end)

mod:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, function(_, pickup, collider)
    local player = collider:ToPlayer()
    if player and mod.STAGE.Mortis:IsStage() and mod:IsMotherBossRoom() then
        game:GetLevel():SetStage(mod:IsXLFloor() and LevelStage.STAGE4_1 or LevelStage.STAGE4_2, StageType.STAGETYPE_REPENTANCE)
    end
end, PickupVariant.PICKUP_BIGCHEST)

--Trapdoor stuff
local function IsMortisTwo()
	if mod.STAGE.Mortis:IsStage() then
		local levelStage = mod:GetStageAndType()
		if (levelStage == LevelStage.STAGE4_2 or (mod:IsXLFloor() and levelStage == LevelStage.STAGE4_1)) then
			return true
		end	
	end
end

mod:AddCallback(ModCallbacks.MC_PRE_GRID_ENTITY_SPAWN, function(_, id, var, varData, index)
	if IsMortisTwo() then
		if mod:IsMotherEntranceRoom() then
			return index == 67
		else
			return MotherContinue
		end
	end
end, GridEntityType.GRID_TRAPDOOR)

local function CheckForMortisTrapdoorSkin(grid)
	if mod.STAGE.Mortis:IsStage() and not IsMortisTwo() then
		if not (mod:IsMotherEntranceRoom() and grid:GetGridIndex() == 67) then
			grid:GetSprite():Load("gfx/grid/mortis/trapdoor_mortis.anm2", true)
			return true
		end
	end
end

mod:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_SPAWN, function(_, grid)
	CheckForMortisTrapdoorSkin(grid)
end, GridEntityType.GRID_TRAPDOOR)

mod:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_TRAPDOOR_UPDATE, function(_, grid)
	if game:GetRoom():GetFrameCount() <= 1 then
		CheckForMortisTrapdoorSkin(grid)
	end
end)

--Achievement
function mod:CheckMortisUnlock()
	local persistData = Isaac.GetPersistentGameData()
	if persistData:Unlocked(Achievement.ROTTEN_HEARTS)
	and persistData:IsBossKilled(BossType.SCOURGE)
	and persistData:IsBossKilled(BossType.CHIMERA)
	and persistData:IsBossKilled(BossType.ROTGUT) then
		return persistData:TryUnlock(mod.Achievement.Mortis)
	end
end