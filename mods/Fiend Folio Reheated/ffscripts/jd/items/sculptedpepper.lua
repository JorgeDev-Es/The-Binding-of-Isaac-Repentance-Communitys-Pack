local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local pepperberetcostume = Isaac.GetCostumeIdByPath("gfx/characters/sculpted_pepper.anm2")
local StatueSubtype = {
	ISAAC = 0,
	MAGGY = 1,
	FIEND = 2,
}

local HaloColor = {
	[StatueSubtype.ISAAC] = Color(1, 0.2, 0.2, 1, 0.3, 0, 0),
	[StatueSubtype.MAGGY] = Color(1, 0.2, 0.6, 1, 0.3, 0, 0.1),
	[StatueSubtype.FIEND] = Color(1, 0.2, 0.9, 1, 0.3, 0, 0.25),
}

local function filter(_, npc)
	if not (npc:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) or npc:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) or npc:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) or npc:IsBoss()) then
		return true
	end
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, collectible, rng, player)
	local room = game:GetRoom()
	for i, entity in pairs(Isaac.FindByType(mod.FF.PepperStatue.ID, mod.FF.PepperStatue.Var)) do
		entity:Kill()
	end
	local pos = Isaac.GetFreeNearPosition(room:GetRandomPosition(50), 10)
	local target = mod:GetClosest(player.Position, mod:GetAllEnemies(filter))
	if target and mod:RandomInt(1, 3) == 1 then
		pos = target.Position + target.Velocity*8
	end
	local statue = Isaac.Spawn(mod.FF.PepperStatue.ID, mod.FF.PepperStatue.Var, mod:RandomInt(0, 2), pos, Vector.Zero, player)
	statue.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	statue:GetData().StatuePlayer = player
	
	player:AddNullCostume(pepperberetcostume)
	return true
end, mod.ITEM.COLLECTIBLE.SCULPTED_PEPPER)

mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, function(_)
	for i, player in pairs(mod:GetAllPlayers()) do
		player:TryRemoveNullCostume(pepperberetcostume)
	end
end)

function mod:PepperAI(npc, sprite, data)
	local player = data.StatuePlayer
	if not data.StatuePlayer then
		data.StatuePlayer = Isaac.GetPlayer(0) --for testing convienience
	end
	
	if not data.Init then
        npc:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        npc:AddEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS | EntityFlag.FLAG_NO_TARGET | EntityFlag.FLAG_NO_PHYSICS_KNOCKBACK | EntityFlag.FLAG_NO_KNOCKBACK 
        | EntityFlag.FLAG_HIDE_HP_BAR | EntityFlag.FLAG_NO_REWARD | EntityFlag.FLAG_NO_BLOOD_SPLASH)
		sprite:Play("Drop", true)
		npc.Visible = true
		data.PepperState = 0
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
		
        data.Init = true
    end
	
	if sprite:IsEventTriggered("Impact") then
		sfx:Play(SoundEffect.SOUND_FORESTBOSS_STOMPS)
		game:MakeShockwave(npc.Position, 0.01, 0.025, 15)
		for i = 25, 360, 25 do
			local smoke = Isaac.Spawn(1000, mod.FF.FFWhiteSmoke.Var, mod.FF.FFWhiteSmoke.Sub, npc.Position, Vector.FromAngle(i):Resized(5), npc):ToEffect()
			--smoke.Timeout = mod:RandomInt(25, 30)
			smoke.Color = Color(1,1,1,0.1,0,0,0)
		end
		for i, entity in pairs(Isaac.FindInRadius(npc.Position, npc.Size+5, EntityPartition.ENEMY)) do
			if entity:ToNPC() and not entity:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) and not entity:IsBoss() then
				entity:AddEntityFlags(EntityFlag.FLAG_EXTRA_GORE)
				entity:Kill()
			end
		end
		npc.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
	end
	
	if sprite:GetAnimation() == "Stage3" then
		if not data.PepperHalo then
			data.PepperHalo = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.HALLOWED_GROUND, 0, npc.Position, Vector.Zero, player):ToEffect()
			data.PepperHalo:FollowParent(npc)
			data.PepperHalo.DepthOffset = -100
			data.PepperHalo.Color = HaloColor[npc.SubType]
		end
		
		for i, entity in pairs(Isaac.FindInRadius(npc.Position, 80, EntityPartition.ENEMY)) do
			if not entity:HasEntityFlags(EntityFlag.FLAG_NO_STATUS_EFFECTS) then
				
				if npc.SubType == StatueSubtype.ISAAC then
					FiendFolio.AddBleed(entity, npc, 3, player.Damage * 0.7)
				elseif npc.SubType == StatueSubtype.MAGGY then
					entity:AddCharmed(EntityRef(npc), 3)
					if mod:RandomInt(1, 15) == 1 then
						entity.Target = npc
					end
				elseif npc.SubType == StatueSubtype.FIEND then
					entity:AddFear(EntityRef(npc), 2)
				end
			end
		end
		
		for i, player in pairs(mod:GetAllPlayers()) do
			player:AddCacheFlags(CacheFlag.CACHE_DAMAGE | CacheFlag.CACHE_FIREDELAY)
			player:EvaluateItems()
		end
	end
	
	if npc:IsDead() then
		if sprite:GetAnimation() == "Stage3" then
			for i = 45, 360, 45 do
				local tear = player:FireTear(npc.Position, Vector.FromAngle(i):Resized(10), false, true, false, npc, 1.5)
				local teardata = tear:GetData()
				tear:ChangeVariant(TearVariant.ROCK)
				tear.Color = Color.Lerp(HaloColor[npc.SubType], Color.Default, 0.5)
				tear.Color.A = 0.7
				if npc.SubType == StatueSubtype.ISAAC then
					teardata.ApplyBleed = true
					teardata.ApplyBleedDamage = player.Damage * 0.7
					teardata.ApplyBleedDuration = 40
				elseif npc.SubType == StatueSubtype.MAGGY then
					tear:AddTearFlags(TearFlags.TEAR_CHARM)
				elseif npc.SubType == StatueSubtype.FIEND then
					tear:AddTearFlags(TearFlags.TEAR_FEAR | TearFlags.TEAR_HOMING)
				end
			end
		end
	end
end

function mod:PepperHurt(npc, amount)
	local sprite = npc:GetSprite()
	local data = npc:GetData()
	if sprite:GetAnimation() ~= "Stage3" and sprite:GetFrame() > 3 then
		if mod:RandomInt(1,2) == 1 then
			data.PepperState = data.PepperState + 1
			for i = 0, 3 do
				local effect = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCK_PARTICLE, 7, npc.Position, RandomVector()*mod:RandomInt(3,7), npc):ToEffect()
				--effect:GetData().changespritesheet = "gfx/grid/rocks_vanilla.png"
			end
			sfx:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 0.5)
		end
		sprite:Play("Stage"..data.PepperState, true)
		return false
	end
end

function mod:IsNearPepperStatue(pos, statuesubtype)
	statuesubtype = statuesubtype or -1
	for i, entity in pairs(Isaac.FindByType(mod.FF.PepperStatue.ID, mod.FF.PepperStatue.Var, statuesubtype)) do
		if entity.Position:Distance(pos) < 80 and entity:GetSprite():GetAnimation() == "Stage3" and not entity:IsDead() then
			return true
		end
	end
end