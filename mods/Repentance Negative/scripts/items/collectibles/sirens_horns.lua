local Mod = RepMMod
local game = Game()
local sfx = SFXManager()

local SirenHud = include("scripts.lib.chargebar")("gfx/chargebar_siren.anm2", true)
local sirenframesToCharge = 141
local sirenRenderedPosition = Vector(21, -12)

---@param player EntityPlayer
local function renderSirenCharge(_, player)
	if player:HasCollectible(Mod.RepmTypes.COLLECTIBLE_SIREN_HORNS) then
		local data = Mod:GetData(player)
		data.RepM_SirenChargeFrames = data.RepM_SirenChargeFrames or 0
		SirenHud:SetCharge(data.RepM_SirenChargeFrames, sirenframesToCharge)
		SirenHud:Render(Isaac.WorldToScreen(player.Position) + sirenRenderedPosition)
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_RENDER, renderSirenCharge)

---@param player EntityPlayer
local function waitFireSiren(_, player)
	local data = Mod:GetData(player)
	data.RepM_SirenChargeFrames = data.RepM_SirenChargeFrames or 0
	if player:HasCollectible(Mod.RepmTypes.COLLECTIBLE_SIREN_HORNS) then
		local aim = player:GetAimDirection()
		local isAim = aim:Length() > 0.01
		local effects = player:GetEffects()

		if isAim and not effects:HasNullEffect(Mod.RepmTypes.NULL_SIRENS_SINGING) then
			data.RepM_SirenChargeFrames = (data.RepM_SirenChargeFrames or 0) + 1
		elseif not game:IsPaused() then
			if data.RepM_SirenChargeFrames >= sirenframesToCharge then
				sfx:Play(SoundEffect.SOUND_SIREN_SING, 1, 0)
				local entities = Isaac.GetRoomEntities()
				local sirenRNG = player:GetCollectibleRNG(Mod.RepmTypes.COLLECTIBLE_SIREN_HORNS)
				effects:AddNullEffect(Mod.RepmTypes.NULL_SIRENS_SINGING, true, 1)
				for i, entity in ipairs(entities) do
					if
						entity:IsVulnerableEnemy()
						and not (entity:HasEntityFlags(EntityFlag.FLAG_CHARM | EntityFlag.FLAG_CONFUSION))
					then
						if sirenRNG:RandomInt(5) ~= 0 then
							entity:AddCharmed(EntityRef(player), 300)
						else
							entity:AddConfusion(EntityRef(player), 150, false)
						end
					end
				end
			end
			data.RepM_SirenChargeFrames = 0
		end
	else
		data.RepM_SirenChargeFrames = 0
	end

	if data.repM_fireSiren == -1 then
		--data.repM_fireSiren = game:GetFrameCount() + 90
		sfx:Play(SoundEffect.SOUND_SIREN_SING, 1, 0)
		local entities = Isaac.GetRoomEntities()
		local sirenRNG = player:GetCollectibleRNG(Mod.RepmTypes.COLLECTIBLE_SIREN_HORNS)
		player:GetEffects():AddNullEffect(Mod.RepmTypes.NULL_SIRENS_SINGING)
		for i, entity in ipairs(entities) do
			if
				entity:IsVulnerableEnemy()
				and not (entity:HasEntityFlags(EntityFlag.FLAG_CHARM | EntityFlag.FLAG_CONFUSION))
			then
				if sirenRNG:RandomInt(5) ~= 0 then
					entity:AddCharmed(EntityRef(player), 300)
				else
					entity:AddConfusion(EntityRef(player), 150, false)
				end
			end
		end
		data.repM_fireSiren = nil
	end

	if player:GetEffects():HasNullEffect(Mod.RepmTypes.NULL_SIRENS_SINGING) then
		if game:GetFrameCount() % 5 == 0 and game:GetFrameCount() ~= data.repM_fireSirenLastFrame then
			Isaac.Spawn(1000, EffectVariant.SIREN_RING, 0, player.Position, Vector.Zero, nil)
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, waitFireSiren)

---@param entity EntityNPC
local function charmDeath(_, entity)
	if entity:HasEntityFlags(EntityFlag.FLAG_CHARM) then
		Mod:AnyPlayerDo(function(player)
			if player:HasCollectible(Mod.RepmTypes.COLLECTIBLE_SIREN_HORNS) then
				for k, familiar in pairs(Isaac.FindByType(EntityType.ENTITY_FAMILIAR)) do
					if GetPtrHash(familiar:ToFamiliar().Player) == GetPtrHash(player) then
						--todo code
						local data = familiar:GetData()
						if data.SirenHornBuff then
							data.SirenHornBuff:Remove()
							data.SirenHornBuff = nil
						end
						familiar:SetColor(Color(1, 0.41, 0.71, 1, 0.4, 0.1, 0.2), 300, 255, false, true)
						data.SirenHornBuff = Isaac.CreateTimer(function()
							data.SirenHornBuff = nil
						end, 300, 1, true)
					end
				end
			end
		end)
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, charmDeath)

---@param ent EntityLaser | EntityTear | EntityProjectile
local function charmBuff(_, ent)
	local spawner = ent.SpawnerEntity
	if spawner then
		if spawner:GetData().SirenHornBuff then
			ent.CollisionDamage = ent.CollisionDamage * 1.3
		end
	end
end

for _, callback in ipairs({
	ModCallbacks.MC_POST_FAMILIAR_FIRE_BRIMSTONE,
	ModCallbacks.MC_POST_FAMILIAR_FIRE_PROJECTILE,
	ModCallbacks.MC_POST_FAMILIAR_FIRE_TECH_LASER,
}) do
	Mod:AddCallback(callback, charmBuff)
end
