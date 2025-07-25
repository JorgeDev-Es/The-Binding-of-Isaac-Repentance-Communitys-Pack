local Mod = RepMMod
local SaveManager = Mod.saveManager

local AxeHudChargeBar = include("scripts.lib.chargebar")("gfx/chargebar_axe.anm2", true)
local framesToCharge = 235
local axeRenderedPosition = Vector(20, -27)
local sfx = SFXManager()

local Sim = { -- Change Sim everywhere to match your character. No spaces!
	DAMAGE = 1, -- These are all relative to Isaac's base stats.
	SPEED = 0.3,
	SHOTSPEED = -1,
	TEARHEIGHT = 2,
	TEARFALLINGSPEED = 0,
	LUCK = 4,
	FLYING = false,
	TEARFLAG = 0, -- 0 is default
	TEARCOLOR = Color(1.0, 1.0, 1.0, 1.0, 0, 0, 0), -- Color(1.0, 1.0, 1.0, 1.0, 0, 0, 0) is default
}

local function onCache(_, player, cacheFlag) -- I do mean everywhere!
	if player:GetPlayerType() == Mod.RepmTypes.CHARACTER_SIM then -- Especially here!
		if cacheFlag == CacheFlag.CACHE_RANGE then
			player.TearHeight = player.TearHeight - Sim.TEARHEIGHT
			player.TearFallingSpeed = player.TearFallingSpeed + Sim.TEARFALLINGSPEED
		end
		if cacheFlag == CacheFlag.CACHE_FLYING and Sim.FLYING then
			player.CanFly = true
		end
		if cacheFlag == CacheFlag.CACHE_TEARFLAG then
			player.TearFlags = player.TearFlags | Sim.TEARFLAG
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, onCache)

local function renderSimCharge(_, player)
	local data = Mod:GetData(player)
	if player:GetPlayerType() == Mod.RepmTypes.CHARACTER_SIM then
		AxeHudChargeBar:SetCharge(data.RepM_SimChargeFrames or 0, framesToCharge)
		AxeHudChargeBar:Render(Isaac.WorldToScreen(player.Position) + axeRenderedPosition)
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, renderSimCharge)

local function GiveAxeOnStart(_, player)
	if not Isaac.GetPersistentGameData():Unlocked(Mod.RepmAchivements.SIM_DELIRIUM.ID) then
		player:RemoveCollectible(Mod.RepmTypes.COLLECTIBLE_AXE_ACTIVE)
	end
end

--Mod:AddCallback(ModCallbacks.MC_PLAYER_INIT_POST_LEVEL_INIT_STATS, GiveAxeOnStart, Mod.RepmTypes.CHARACTER_SIM)

local function onUpdateAxeDrops(_, axe)
	if axe.SubType == 1 then
		if axe:GetSprite():IsEventTriggered("DropSound") then
			sfx:Play(SoundEffect.SOUND_GOLD_HEART_DROP, 2)
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, onUpdateAxeDrops, Mod.RepmTypes.PICKUP_AXE)

local function OnCollideAxe(_, entity, collider, Low)
	if collider and collider:ToPlayer() then
		local player = collider:ToPlayer()

		if entity:GetData().Collected ~= true and player:GetPlayerType() == Mod.RepmTypes.CHARACTER_SIM then
			entity:GetData().Collected = true
			entity:GetSprite():Play("Collect")
			sfx:Play(SoundEffect.SOUND_SCAMPER)
			local runData = Mod:RunSave()
			runData.SimAxesCollected = (runData.SimAxesCollected or 0) + 1
			entity:Remove()
			entity.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
			entity.Velocity = Vector.Zero
		else
			return entity:IsShopItem()
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, OnCollideAxe, Mod.RepmTypes.PICKUP_AXE)

local function IsDoubleTapTriggered(player)
	local data = Mod:GetData(player)
	data.LastTimeArrowPress = data.LastTimeArrowPress or 0
	if
		Game():GetFrameCount() - data.LastTimeArrowPress < 6
		and (
			(
				Input.IsActionTriggered(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex)
				and data.ArrowLastUsed == ButtonAction.ACTION_SHOOTLEFT
			)
			or (Input.IsActionTriggered(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex) and data.ArrowLastUsed == ButtonAction.ACTION_SHOOTRIGHT)
			or (Input.IsActionTriggered(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex) and data.ArrowLastUsed == ButtonAction.ACTION_SHOOTUP)
			or (
				Input.IsActionTriggered(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex)
				and data.ArrowLastUsed == ButtonAction.ACTION_SHOOTDOWN
			)
		)
	then
		return true
	elseif Input.IsActionTriggered(ButtonAction.ACTION_SHOOTRIGHT, player.ControllerIndex) then
		data.ArrowLastUsed = ButtonAction.ACTION_SHOOTRIGHT
		data.LastTimeArrowPress = Game():GetFrameCount()
	elseif Input.IsActionTriggered(ButtonAction.ACTION_SHOOTUP, player.ControllerIndex) then
		data.ArrowLastUsed = ButtonAction.ACTION_SHOOTUP
		data.LastTimeArrowPress = Game():GetFrameCount()
	elseif Input.IsActionTriggered(ButtonAction.ACTION_SHOOTDOWN, player.ControllerIndex) then
		data.ArrowLastUsed = ButtonAction.ACTION_SHOOTDOWN
		data.LastTimeArrowPress = Game():GetFrameCount()
	elseif Input.IsActionTriggered(ButtonAction.ACTION_SHOOTLEFT, player.ControllerIndex) then
		data.ArrowLastUsed = ButtonAction.ACTION_SHOOTLEFT
		data.LastTimeArrowPress = Game():GetFrameCount()
	end
	return false
end

local function adjustAngle_SIM(velocity, stream, totalstreams)
	local multiplicator = velocity:Length()
	local angleAdjustment = 10 * (stream - 1) - 5 * (totalstreams - 1)
	local correctAngle = velocity:GetAngleDegrees() + angleAdjustment
	return Vector.FromAngle(correctAngle) * multiplicator
end

---@param player EntityPlayer
local function onSimUpdate(_, player)
	if player:GetPlayerType() ~= Mod.RepmTypes.CHARACTER_SIM then
		return
	end
	local data = Mod:GetData(player)
	data.RepM_SimChargeFrames = data.RepM_SimChargeFrames or 0
	local maxThreshold = data.RepM_SimChargeFrames
	local aim = player:GetAimDirection()
	local isAim = aim:Length() > 0.01
	local runData = Mod:RunSave()

	if isAim and runData.SimAxesCollected and runData.SimAxesCollected > 0 then
		data.RepM_SimChargeFrames = (data.RepM_SimChargeFrames or 0) + 1
	elseif not Game():IsPaused() then
		data.RepM_SimChargeFrames = 0
	end

	if maxThreshold > framesToCharge and data.RepM_SimChargeFrames == 0 then
		data.repM_fireAxe = true
	end
	if
		(IsDoubleTapTriggered(player) or Mod:GetData(player).repM_fireAxe)
		and runData.SimAxesCollected
		and runData.SimAxesCollected > 0
	then --
		Mod:GetData(player).repM_fireAxe = false
		runData.SimAxesCollected = math.max(0, runData.SimAxesCollected - 1)
		local direction = Mod.directionToVector[player:GetHeadDirection()] * (25 * player.ShotSpeed)
		local weapon = player:GetWeapon(1)
		local weaponType = weapon:GetWeaponType()
		local multiShotParams = player:GetMultiShotParams(weaponType)
		---@cast multiShotParams MultiShotParams
		for y = 1, multiShotParams:GetNumTears(), 1 do
			local new_dir = adjustAngle_SIM(direction, y, multiShotParams:GetNumTears())
			local tear
			if player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT) then
				tear = player:FireTear(player.Position, new_dir, false, true, false, nil, 5)
				if math.random(1, 3) == 1 then
					tear:AddTearFlags(TearFlags.TEAR_HP_DROP)
				end
			else
				tear = player:FireTear(player.Position, new_dir, false, true, false, nil, 3)
			end
			sfx:Play(SoundEffect.SOUND_BIRD_FLAP)
			tear.Scale = tear.Scale * 0.5
			tear.Variant = TearVariant.SCHYTHE
			tear:AddTearFlags(TearFlags.TEAR_BOOMERANG | TearFlags.TEAR_PIERCING | TearFlags.TEAR_SPECTRAL)
			tear:GetData().repm_IsAxeCharge = true
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, onSimUpdate, PlayerVariant.PLAYER)

local PriceTextFontTempesta = Font()
PriceTextFontTempesta:Load("font/pftempestasevencondensed.fnt")
local SimAxeUI = Sprite("gfx/ui/hudpickupsAXE.anm2", true)
SimAxeUI:Play("Idle", true)
SimAxeUI:SetFrame(0)

local function simUIAxeRender()
	local isSim = PlayerManager.AnyoneIsPlayerType(Mod.RepmTypes.CHARACTER_SIM)
	if isSim then
		--if Game():GetHUD():IsVisible() then
		local runData = Mod:RunSave()
		local targetPos = Vector(30, 33) + Game().ScreenShakeOffset + (Options.HUDOffset * Vector(20, 12))
		PriceTextFontTempesta:DrawStringScaled(
			string.format("%02d", (runData.SimAxesCollected or 0)),
			targetPos.X + 15,
			targetPos.Y,
			1,
			1,
			KColor(1, 1, 1, 1)
		)
		SimAxeUI:Render(targetPos)
		--end
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, simUIAxeRender)

local function OnRoomClear_SimAxes()
	local room = Game():GetRoom()
	local level = Game():GetLevel()
	if Game():IsGreedMode() then
		if level:GetCurrentRoomDesc().GridIndex == 84 then
			if PlayerManager.AnyoneIsPlayerType(Mod.RepmTypes.CHARACTER_SIM) then
				local axeSpawnPos = {}
				if
					Game().Difficulty == Difficulty.DIFFICULTY_GREED and level.GreedModeWave == 10
					or Game().Difficulty == 3 and level.GreedModeWave == 11
				then
					axeSpawnPos = {
						Vector(80, 160),
						Vector(80, 800),
						Vector(800, 300),
						Vector(800, 2000),
						Game():GetRoom():GetCenterPos(),
					}
				end
				for _, vec in ipairs(axeSpawnPos) do
					local pos = room:FindFreePickupSpawnPosition(vec)
					Isaac.Spawn(
						5,
						Mod.RepmTypes.PICKUP_AXE,
						1,
						pos,
						EntityPickup.GetRandomPickupVelocity(pos, Mod.RNG, 0),
						nil
					)
				end
			end
		end
	end
	if room:GetType() == RoomType.ROOM_BOSS then
		if PlayerManager.AnyoneIsPlayerType(Mod.RepmTypes.CHARACTER_SIM) then
			local axeSpawnPos = {
				Vector(80, 160),
				Vector(80, 400),
				Vector(560, 160),
				Vector(560, 400),
				room:GetCenterPos(),
			}
			for _, vec in ipairs(axeSpawnPos) do
				local pos = room:FindFreePickupSpawnPosition(vec)
				Isaac.Spawn(
					5,
					Mod.RepmTypes.PICKUP_AXE,
					1,
					pos,
					EntityPickup.GetRandomPickupVelocity(pos, Mod.RNG, 0),
					nil
				)
			end
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, OnRoomClear_SimAxes)

local function NewRoomAXE()
	local room = Game():GetRoom()
	if
		room:GetType() == RoomType.ROOM_TREASURE
		or room:GetType() == RoomType.ROOM_SHOP
		or room:GetType() == RoomType.ROOM_SECRET
		or room:GetType() == RoomType.ROOM_PLANETARIUM
	then
		if PlayerManager.AnyPlayerTypeHasBirthright(Mod.RepmTypes.CHARACTER_SIM) and room:IsFirstVisit() then
			local pos = room:FindFreePickupSpawnPosition(room:GetCenterPos())
			for i = 1, Mod.RNG:RandomInt(3) + 1 do
				Isaac.Spawn(
					5,
					Mod.RepmTypes.PICKUP_AXE,
					1,
					pos,
					EntityPickup.GetRandomPickupVelocity(pos, Mod.RNG, 0),
					nil
				)
			end
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, NewRoomAXE)

local function getTearScale13(tear)
	local sprite = tear:GetSprite()
	local scale = tear.Scale
	local sizeMulti = tear.SizeMulti
	local flags = tear.TearFlags

	if scale > 2.55 then
		return Vector((scale * sizeMulti.X) / 2.55, (scale * sizeMulti.Y) / 2.55)
	elseif
		flags & TearFlags.TEAR_GROW == TearFlags.TEAR_GROW
		or flags & TearFlags.TEAR_LUDOVICO == TearFlags.TEAR_LUDOVICO
	then
		if scale <= 0.3 then
			return Vector((scale * sizeMulti.X) / 0.25, (scale * sizeMulti.Y) / 0.25)
		elseif scale <= 0.55 then
			local adjustedBase = math.ceil((scale - 0.175) / 0.25) * 0.25 + 0.175
			return Vector((scale * sizeMulti.X) / adjustedBase, (scale * sizeMulti.Y) / adjustedBase)
		elseif scale <= 1.175 then
			local adjustedBase = math.ceil((scale - 0.175) / 0.125) * 0.125 + 0.175
			return Vector((scale * sizeMulti.X) / adjustedBase, (scale * sizeMulti.Y) / adjustedBase)
		elseif scale <= 2.175 then
			local adjustedBase = math.ceil((scale - 0.175) / 0.25) * 0.25 + 0.175
			return Vector((scale * sizeMulti.X) / adjustedBase, (scale * sizeMulti.Y) / adjustedBase)
		else
			return Vector((scale * sizeMulti.X) / 2.55, (scale * sizeMulti.Y) / 2.55)
		end
	else
		return sizeMulti
	end
end

local function axeTearUpdate(_, tear)
	local data = tear:GetData()
	if data.repm_IsAxeCharge == nil then
		return
	end

	if not data.AxeDefaultSprite then
		data.AxeDefaultSprite = Sprite("gfx/axe_tear_.anm2", true)
	end

	local tearsprite = tear:GetSprite()
	local scale = tear.Scale
	local flags = tear.TearFlags

	local anim
	if scale <= 0.3 then
		anim = "Rotate1"
	elseif scale <= 0.8 then
		anim = "Rotate2"
	elseif scale <= 1.175 then
		anim = "Rotate3"
	elseif scale <= 1.925 then
		anim = "Rotate4"
	else
		anim = "Rotate5"
	end

	data.AxeDefaultSprite.PlaybackSpeed = tearsprite.PlaybackSpeed
	if not data.AxeDefaultSprite:IsPlaying(anim) then
		local frame = data.AxeDefaultSprite:GetFrame()
		data.AxeDefaultSprite:Play(anim, true)
		data.AxeDefaultSprite:SetFrame(frame)
	elseif Game():GetFrameCount() % 3 == 0 and data.REPM_LastRenderFrame ~= Game():GetFrameCount() then
		data.AxeDefaultSprite:Update()
	end

	local spritescale = getTearScale13(tear)
	data.AxeDefaultSprite.Scale = spritescale
	data.AxeDefaultSprite.Color = tearsprite.Color
	tearsprite:ReplaceSpritesheet(0, "gfx/blank.png", true)
	--tearsprite:LoadGraphics()
	--tear.Visible = false
	--tear:GetSprite():LoadGraphics()

	---@diagnostic disable-next-line: param-type-mismatch
	--print(tear.Position + tear.PositionOffset)

	--print(Isaac.WorldToRenderPosition(tear.Position + tear.PositionOffset) + offset)
	data.REPM_LastRenderFrame = Game():GetFrameCount()
end
Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, axeTearUpdate)

local function axeTearRender(_, tear, offset)
	local data = tear:GetData()
	if data.repm_IsAxeCharge == nil then
		return
	end

	if data.AxeDefaultSprite then
		data.AxeDefaultSprite:Render(
			Isaac.WorldToRenderPosition(tear.Position + tear.PositionOffset) + offset,
			Vector.Zero,
			Vector.Zero
		)
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_TEAR_RENDER, axeTearRender)
