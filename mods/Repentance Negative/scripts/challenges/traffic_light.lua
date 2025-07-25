local Mod = RepMMod
local SaveManager = Mod.saveManager

local lightSprite = Sprite("gfx/trafficlight.anm2", true)
lightSprite:Play("GreenLight", true)

local function trafficRender()
	local runSave = Mod:RunSave()
	if Isaac.GetChallenge() == Mod.RepmChallenges.CHALLENGE_TRAFFIC_LIGHT
    and Game():GetRoom():GetRenderMode() ~= RenderMode.RENDER_WATER_REFLECT
	and runSave.RedLightSign ~= nil then
		if lightSprite:GetAnimation() ~= runSave.RedLightSign then
			lightSprite:Play(runSave.RedLightSign)
		end
		local horiz, vert = Isaac.GetScreenWidth() / 2, Isaac.GetScreenHeight() * 0.05
		if not RoomTransition.IsRenderingBossIntro() then
			lightSprite:Render(Vector(horiz, vert) + Vector(0, 12) * Options.HUDOffset)
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_HUD_RENDER, trafficRender)

--local saveTimer

local function IsMoving(player)
	local index = player.ControllerIndex
	return Input.IsActionPressed(ButtonAction.ACTION_LEFT, index)
		or Input.IsActionPressed(ButtonAction.ACTION_RIGHT, index)
		or Input.IsActionPressed(ButtonAction.ACTION_UP, index)
		or Input.IsActionPressed(ButtonAction.ACTION_DOWN, index)
end

local function changeLights()
	if Isaac.GetChallenge() == Mod.RepmChallenges.CHALLENGE_TRAFFIC_LIGHT  then
		local runSave = Mod:RunSave()
		if not runSave.saveTimer then
			runSave.saveTimer = Mod.RNG:RandomInt(1350) + 300
			runSave.RedLightSign = "GreenLight"
		end
		if runSave.saveTimer <= 0 then
			if runSave.RedLightSign == "RedLight" then
				runSave.saveTimer = Mod.RNG:RandomInt(1350) + 300
				runSave.RedLightSign = "GreenLight"
				SFXManager():Play(SoundEffect.SOUND_THUMBSUP, 2)
			elseif runSave.RedLightSign == "YellowLight" then
				runSave.saveTimer = Mod.RNG:RandomInt(300) + 30
				runSave.RedLightSign = "RedLight"
				SFXManager():Play(SoundEffect.SOUND_BOSS2INTRO_ERRORBUZZ, 2)
			else
				runSave.saveTimer = Mod.RNG:RandomInt(30, 60)
				runSave.RedLightSign = "YellowLight" --SOUND_TOOTH_AND_NAIL_TICK
				SFXManager():Play(SoundEffect.SOUND_BUTTON_PRESS, 2)
			end
		elseif Game():GetRoom():GetAliveEnemiesCount() > 0 then
			runSave.saveTimer = runSave.saveTimer - 1
		else
			if runSave.RedLightSign == "YellowLight"
			or runSave.saveTimer < 90 and runSave.RedLightSign == "GreenLight" then
				runSave.saveTimer = 90
				if runSave.RedLightSign == "YellowLight" then
					SFXManager():Play(SoundEffect.SOUND_THUMBSUP, 2)
				end
				runSave.RedLightSign = "GreenLight"
			elseif runSave.RedLightSign == "RedLight" then
				runSave.saveTimer = runSave.saveTimer - 4
			end
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, changeLights)

---@param player EntityPlayer
local function LightPlayer(_, player)
	if Isaac.GetChallenge() ~= Mod.RepmChallenges.CHALLENGE_TRAFFIC_LIGHT then
		return
	end
    local pdata = Mod:GetData(player)
	local runData = Mod:RunSave()
    if runData.RedLightSign == "RedLight" then
		if IsMoving(player) 
		and player:GetDamageCountdown() <= 0 then
			pdata.RedLightDamage = true
			player:TakeDamage(1, DamageFlag.DAMAGE_COUNTDOWN, EntityRef(player), 4)
		end
    else
		pdata.RedLightDamage = nil
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, LightPlayer, PlayerVariant.PLAYER)

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, function(_, ent, damage, flags, source, cd)
	local player = ent:ToPlayer()
	if Mod:GetData(player).RedLightDamage and flags & DamageFlag.DAMAGE_COUNTDOWN ~= 0 then
		Mod:GetData(player).RedLightDamage = nil
		player:ResetDamageCooldown()
		player:SetMinDamageCooldown(20)
	end
end, EntityType.ENTITY_PLAYER)