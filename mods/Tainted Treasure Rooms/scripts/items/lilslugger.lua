local mod = TaintedTreasure
local game = Game()
local sfx = SFXManager()

local function ConvertTearToSawblade(tear, player)
    if mod:CheckTearVariant(tear, TaintedTears.SAWBLADE, true) then
        mod:SawbladeTearInit(tear)
        if player and player:Exists() then
            tear:GetData().TaintedSawbladeRange = player.TearRange
        end
    end
end

function mod:FireSawblade(player, velocity, color, mult, position, parent)
    mult = mult or 1
    position = position or player.Position
    local tear = player:FireTear(position, velocity, false, false, false, player, mult)
    if color then
        tear.Color = color
    end
    if not player:HasCollectible(TaintedCollectibles.LIL_SLUGGER) then
        ConvertTearToSawblade(tear, player)
    end
	if parent then
		tear:GetData().SawbladeParent = parent
	end
    return tear
end

function mod:LilSluggerOnFireTear(player, tear)
    ConvertTearToSawblade(tear, player)
end

function mod:SawbladeTearInit(tear)
    mod:MakeTearSpectral(tear, true)
    if not tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then
        tear.Velocity = tear.Velocity:Resized(10)
        tear.ContinueVelocity = tear.ContinueVelocity:Resized(10)
        sfx:Play(TaintedSounds.SAW_SHOOT, 1.5, 0, false, math.max(0.6, 2 - tear.Scale))
    end
    if not sfx:IsPlaying(TaintedSounds.SAW_AMBIENT) then
        sfx:Play(TaintedSounds.SAW_AMBIENT, 0.05, 0, true)
    end
end

mod:AddCallback(ModCallbacks.MC_POST_TEAR_INIT, mod.SawbladeTearInit, TaintedTears.SAWBLADE)

mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, function(_, tear)
    local data = tear:GetData()
    local room = game:GetRoom()

    tear.FallingSpeed = 0
    tear.FallingAcceleration = -0.1
    data.TaintedSawbladeRange = data.TaintedSawbladeRange or 130
    data.Height = tear.Height --I hate that I have to store this information
    data.Scale = tear.Scale --This also
    mod:spritePlay(tear:GetSprite(), "Move")
	
	if data.SawbladeParent then
		tear.Velocity = data.SawbladeParent.Position-tear.Position+Vector(data.SawbladeParent.Size, data.SawbladeParent.Size):Rotated(data.SawbladeParent:GetSprite():GetFrame()*15)
		if not data.SawbladeParent:Exists() then
			tear:Remove()
		end
		
		return true
	end
	
    if data.WallStickerData and data.WallStickerData.WallStickerInit then
        mod:WallStickerMovement(tear, 5)
        data.TaintedSawbladeRange = data.TaintedSawbladeRange - 1
        if data.TaintedSawbladeRange <= 0 then
            tear:Die()
        end
    elseif room:GetGridCollisionAtPos(tear.Position) >= GridCollisionClass.COLLISION_SOLID and not tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then
        local dir, cc = mod:GetOrientationFromVector(tear.Velocity)
        mod:WallStickerInit(tear, dir, cc, GridCollisionClass.COLLISION_PIT, 6, true)
        mod:ClearMovementAlteratingTearFlags(tear)
        sfx:Play(TaintedSounds.SAW_ATTACH, 0.8)
    elseif tear.FrameCount >= data.TaintedSawbladeRange / 4 and not data.SawbladeLock then
        mod:ClearMovementAlteratingTearFlags(tear)
        tear.Velocity = tear.Velocity:Resized(math.max(tear.Velocity:Length(), 10))
        data.SawbladeLock = true
    end
end, TaintedTears.SAWBLADE)

mod:AddCallback(ModCallbacks.MC_PRE_TEAR_COLLISION, function(_, tear, collider)
    if tear.FrameCount % 2 == 0 then
        if collider:TakeDamage(tear.CollisionDamage, 0, EntityRef(tear), 0) then
            mod:GrindGibs(collider)
        end
    end
	if tear:HasTearFlags(TearFlags.TEAR_SHIELDED) and collider.Type == EntityType.ENTITY_PROJECTILE then
		collider:Die()
	end
    return true
end, TaintedTears.SAWBLADE)

mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, function(_, tear)
    if tear.Variant == TaintedTears.SAWBLADE then
        local data = tear:GetData()

        for i = 1, mod:RandomInt(2,4) do
            local gib = Isaac.Spawn(1000, 86, 1, tear.Position, RandomVector() * mod:RandomInt(2,6), tear)
            gib.Color = tear.Color
        end

        local effect = Isaac.Spawn(1000,97,0,tear.Position,Vector.Zero,tear)
        effect.SpriteOffset = Vector(0, data.Height)
        effect.SpriteScale = Vector(data.Scale, data.Scale)
        effect.Color = tear.Color
        
        if Isaac.CountEntities(nil, EntityType.ENTITY_TEAR, TaintedTears.SAWBLADE) <= 1 then
            sfx:Stop(TaintedSounds.SAW_AMBIENT)
        end
        sfx:Play(SoundEffect.SOUND_POT_BREAK, 0.3, 0, false, 3)
    end
end, EntityType.ENTITY_TEAR)

function mod:LilSluggerPlayerLogic(player)
    if player.FrameCount % 2 == 0 then
        local vec = Vector(15,0):Rotated(mod:GetHeadDirection(player))
        local pos = player.Position + vec
        local enemies = Isaac.FindInRadius(pos, 100, EntityPartition.ENEMY)
        for _, enemy in pairs(enemies) do
            if enemy:IsEnemy() and enemy.EntityCollisionClass >= EntityCollisionClass.ENTCOLL_PLAYEROBJECTS and enemy.Position:Distance(pos) < enemy.Size + 13 then
                if enemy:TakeDamage(math.max(3.5, player.Damage), 0, EntityRef(player), 0) then
                    mod:GrindGibs(enemy)
                end
            end
        end
    end
end

function mod:GrindGibs(npc) --From Fiend Folio's minions
    sfx:Play(SoundEffect.SOUND_MEATY_DEATHS,0.2,0,false,mod:RandomInt(150,200)/100)

    if not npc:HasEntityFlags(EntityFlag.FLAG_NO_BLOOD_SPLASH) then
        local dedbaby = Isaac.Spawn(1000, 2, 1, npc.Position + Vector(0, 1), Vector.Zero, npc)
        dedbaby.Color = npc.SplatColor
        dedbaby.SpriteOffset = npc.SpriteOffset + Vector(0,-5) + RandomVector() * mod:RandomInt(15)
        dedbaby:Update()
    end
end

function mod:ClearMovementAlteratingTearFlags(tear)
    tear:ClearTearFlags(TearFlags.TEAR_HOMING | TearFlags.TEAR_BOOMERANG | TearFlags.TEAR_WIGGLE | TearFlags.TEAR_ORBIT | TearFlags.TEAR_WAIT | TearFlags.TEAR_BOUNCE |
    TearFlags.TEAR_SPIRAL | TearFlags.TEAR_SQUARE | TearFlags.TEAR_TRACTOR_BEAM | TearFlags.TEAR_BIG_SPIRAL | TearFlags.TEAR_BOOGER | TearFlags.TEAR_OCCULT | 
    TearFlags.TEAR_ORBIT_ADVANCED | TearFlags.TEAR_TURN_HORIZONTAL | TearFlags.TEAR_SPORE)
end

function mod:GetHeadDirection(player)
    local dir = player:GetHeadDirection()
    return (dir * 90) + 180
end