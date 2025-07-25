----------------------------------------------------------
--Stalker's Curse
----------------------------------------------------------
local Mod = RepMMod
local game = Mod.Game
local stalkerCurseId = Isaac.GetCurseIdByName("Stalker's Curse!")
local curseSprite = Sprite("gfx/ui/stalker curse.anm2", true)
local stalkerCurseIdBitMask = 1 << (stalkerCurseId - 1)
local function IsStalkerCurseAllowed()
	return game:GetLevel():GetStage() <= LevelStage.STAGE3_2 and not game:IsGreedMode()
		or game:GetLevel():GetStage() <= LevelStage.STAGE3_GREED and game:IsGreedMode()
end
if BetterCurseAPI then
	--[[BetterCurseAPI:registerCurse("Stalker's Curse!", 1, function()
		return false
	end, { curseSprite, "Idle", 0 })]]
else
	function Mod:StalkerCurseInit(curses)
		if curses == 0 and IsStalkerCurseAllowed() then
			local seed = game:GetSeeds():GetStageSeed(game:GetLevel():GetStage())
			local rng = RNG(seed)
			if rng:RandomFloat() <= 0.4 then
				return stalkerCurseIdBitMask
			end
		end
	end
	--Mod:AddCallback(ModCallbacks.MC_POST_CURSE_EVAL, Mod.StalkerCurseInit)
end

MinimapAPI:AddMapFlag(stalkerCurseId, function()
	return game:GetLevel():GetCurses() & stalkerCurseIdBitMask == stalkerCurseIdBitMask
end, curseSprite, "Idle", 0)

local annoyingHaunt = Isaac.GetEntityTypeByName("Lil Stalker")

---@param npc EntityNPC
function Mod:LilStalkerAI(npc)
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	data.Angle = data.Angle or 0
	data.StateCD = data.StateCD or 150
	data.StateCD = math.max(0, data.StateCD - 1)
	local stopwatchbonus = {
		[1] = 0,
		[2] = -1,
		[3] = 1,
	}
	local attackStateBonus = npc.State == NpcState.STATE_ATTACK and 3 or 0
	data.Angle = (data.Angle + 2 + stopwatchbonus[game:GetRoom():GetBrokenWatchState() + 1] + attackStateBonus) % 360
	if npc.State == NpcState.STATE_INIT then
		npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
		npc.Color = Color(1, 1, 1, 0)
		npc.State = NpcState.STATE_IDLE
		sprite:Play("Float", true)
		npc:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
	elseif npc.State == NpcState.STATE_IDLE or npc.State == NpcState.STATE_ATTACK then
		local color = npc.State == NpcState.STATE_ATTACK and Color.Default or Color(1, 1, 1, 0.6)
		if npc:GetPlayerTarget() and npc:GetPlayerTarget():ToPlayer() then
			local player = npc:GetPlayerTarget():ToPlayer()
			local targetPosition = player.Position + Vector.FromAngle(data.Angle):Resized(80)
			npc.Velocity = Mod.Lerp(npc.Velocity, (targetPosition - npc.Position))
			local anim = "Float"
			if npc.State == NpcState.STATE_ATTACK then
				anim = anim .. "Chase"
			end
			sprite:Play(anim, false)
		end
		npc.Color = Color.Lerp(npc.Color, color, 0.1)
		if data.StateCD == 0 then
			if npc:GetDropRNG():RandomFloat() < 0.65 then
				if npc.State ~= NpcState.STATE_ATTACK then
					npc.State = NpcState.STATE_ATTACK
				else
					npc.State = NpcState.STATE_IDLE
				end
			end
			data.StateCD = npc:GetDropRNG():RandomInt(90, 240)
		end
	elseif npc.State == NpcState.STATE_DEATH then
		if npc.Color.A == 0 then
			npc:Remove()
		end
	end
	npc.Color = Color.Lerp(npc.Color, Color(1, 1, 1, 0), 0.02)
	if npc.State ~= NpcState.STATE_ATTACK then
		npc:ClearEntityFlags(
			EntityFlag.FLAG_SLOW
				| EntityFlag.FLAG_FRIENDLY
				| EntityFlag.FLAG_CHARM
				| EntityFlag.FLAG_CONFUSION
				| EntityFlag.FLAG_BURN
				| EntityFlag.FLAG_BLEED_OUT
				| EntityFlag.FLAG_POISON
		)
	end
	npc.EntityCollisionClass = npc.State == NpcState.STATE_ATTACK and EntityCollisionClass.ENTCOLL_PLAYEROBJECTS
		or EntityCollisionClass.ENTCOLL_NONE
	npc:SetInvincible(npc.State ~= NpcState.STATE_ATTACK)
end
Mod:AddCallback(ModCallbacks.MC_NPC_UPDATE, Mod.LilStalkerAI, annoyingHaunt)

function Mod:LilStalkerNewRoom()
	for _, st in ipairs(Isaac.FindByType(annoyingHaunt)) do
		st = st:ToNPC()
		local data = st:GetData()
		if st:GetPlayerTarget() and st:GetPlayerTarget():ToPlayer() then
			local player = st:GetPlayerTarget():ToPlayer()
			st.Position = player.Position + Vector.FromAngle(data.Angle):Resized(80)
		end
	end
end
Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Mod.LilStalkerNewRoom)

function Mod:LilStalkerCollision(npc)
	if npc.State ~= NpcState.STATE_ATTACK then
		return false
	end
end
Mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, Mod.LilStalkerCollision, annoyingHaunt)