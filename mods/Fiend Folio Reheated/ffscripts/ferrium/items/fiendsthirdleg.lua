local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

function mod:fiendsThirdLegOnFireTear(player, tear, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.FIENDS_THIRD_LEG) then
		tear.TearFlags = tear.TearFlags | TearFlags.TEAR_HOMING
        local color = Color(0.3,0.5,1,1,0.2,0,0.2)
        color:SetColorize(1,1,2,1)
		tear.Color = color
        tear:GetData().fiendsThirdLeg = true
		tear:Update()
	end
end

function mod:fiendsThirdLegOnKnifeDamage(player, entity, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.FIENDS_THIRD_LEG) then
		sfx:Play(mod.Sounds.AceVenturaLaugh, 0.6, 0, false, 1.5)
        local splat = Isaac.Spawn(1000, 16, 4, entity.Position, Vector.Zero, player)
        local color = Color(0.3,0.5,1,1,0.35,0.15,0.35)
        color:SetColorize(1,1,2,1)
        splat.Color = color
        splat.SpriteScale = Vector(0.5, 0.5)
        local spood = Isaac.Spawn(5, FiendFolio.PICKUP.VARIANT.FIEND_MINION, 2, entity.Position, Vector.Zero, player)
		spood.Parent = player
        local isActiveRoom = mod.IsActiveRoom()
        if not isActiveRoom then
			spood:GetData().mixPersistent = true
			spood:GetData().mixRemainingRooms = 1
			spood:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
		end
	end
end

function mod:fiendsThirdLegOnFireBomb(player, bomb, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.FIENDS_THIRD_LEG) then
		bomb.Flags = bomb.Flags | TearFlags.TEAR_HOMING
		
		local color = Color(0.3,0.5,1,1,0.2,0,0.2)
        color:SetColorize(1,1,2,1)
		bomb.Color = color
        bomb:GetData().fiendsThirdLeg = true
	end
end

function mod:fiendsThirdLegBombRemove(bomb, data)
    if data.fiendsThirdLeg then
        sfx:Play(mod.Sounds.AceVenturaLaugh, 0.6, 0, false, 1)
        local splat = Isaac.Spawn(1000, 16, 4, bomb.Position, Vector.Zero, bomb)
        local color = Color(0.3,0.5,1,1,0.35,0.15,0.35)
        color:SetColorize(1,1,2,1)
        splat.Color = color
        local spood = Isaac.Spawn(5, FiendFolio.PICKUP.VARIANT.FIEND_MINION, 2, bomb.Position, Vector.Zero, bomb.SpawnerEntity)
		spood.Parent = bomb.SpawnerEntity
		--spood:GetData().hollow = true
        local isActiveRoom = mod.IsActiveRoom()
        if not isActiveRoom then
			spood:GetData().mixPersistent = true
			spood:GetData().mixRemainingRooms = 1
			spood:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
		end
        spood.SpriteScale = Vector(2,2)
        spood.Size = spood.Size*2
    end
end

function mod:fiendsThirdLegBombUpdate(v, d)
    if d.fiendsThirdLeg then
        if v.FrameCount % 2 == 0 then
            local creep = Isaac.Spawn(1000, 46, 0, v.Position, Vector.Zero, v):ToEffect()
            creep.Color = Color(0.2,0,1,1,0.15+math.random(25,30)/100,0.2,0.15+math.random(25,30)/100)
            local damage = 10
            if v.SpawnerEntity and v.SpawnerEntity:ToPlayer() then
                damage = v.SpawnerEntity:ToPlayer().Damage
            end
            creep.CollisionDamage = damage
            creep.SpriteScale = Vector(0.7,0.7)
            creep:SetTimeout(30)
        end
    end
end

function mod:fiendsThirdLegOnLaserDamage(player, entity, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.FIENDS_THIRD_LEG) then
        sfx:Play(mod.Sounds.AceVenturaLaugh, 0.6, 0, false, 1.5)
        local splat = Isaac.Spawn(1000, 16, 4, entity.Position, Vector.Zero, player)
        local color = Color(0.3,0.5,1,1,0.35,0.15,0.35)
        color:SetColorize(1,1,2,1)
        splat.Color = color
        splat.SpriteScale = Vector(0.5, 0.5)
        local spood = Isaac.Spawn(5, FiendFolio.PICKUP.VARIANT.FIEND_MINION, 2, entity.Position, Vector.Zero, player)
		spood.Parent = player
        local isActiveRoom = mod.IsActiveRoom()
        if not isActiveRoom then
			spood:GetData().mixPersistent = true
			spood:GetData().mixRemainingRooms = 1
			spood:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
		end
	end
end

function mod:fiendsThirdLegOnFireAquarius(player, creep, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.FIENDS_THIRD_LEG) then
        local data = creep:GetData()
        data.fiendsThirdLeg = true
        local color = Color(0.3,0.5,1,1,0.35,0.15,0.35)
        color:SetColorize(1,1,2,1)
		data.FFAquariusColor = color
	end
end

function mod:fiendsThirdLegOnFireRocket(player, target, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.FIENDS_THIRD_LEG) then
		local data = target:GetData()
		data.fiendsThirdLeg = true
        local color = Color(0.3,0.5,1,1,0.35,0.15,0.35)
        color:SetColorize(1,1,2,1)
		data.FFExplosionColor = color
	end
end

function mod:fiendsThirdLegOnDarkArtsDamage(player, entity, secondHandMultiplier)
	if player:HasCollectible(FiendFolio.ITEM.COLLECTIBLE.FIENDS_THIRD_LEG) then
		sfx:Play(mod.Sounds.AceVenturaLaugh, 0.6, 0, false, 1.5)
        local splat = Isaac.Spawn(1000, 16, 4, entity.Position, Vector.Zero, player)
        local color = Color(0.3,0.5,1,1,0.35,0.15,0.35)
        color:SetColorize(1,1,2,1)
        splat.Color = color
        splat.SpriteScale = Vector(0.5, 0.5)
        local spood = Isaac.Spawn(5, FiendFolio.PICKUP.VARIANT.FIEND_MINION, 2, entity.Position, Vector.Zero, player)
		spood.Parent = player
        local isActiveRoom = mod.IsActiveRoom()
        if not isActiveRoom then
			spood:GetData().mixPersistent = true
			spood:GetData().mixRemainingRooms = 1
			spood:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
		end
	end
end

function mod:fiendsThirdLegTearRemove(tear1, data)
    if data.fiendsThirdLeg then
        local tear = tear1:ToTear()
        local pitch = ((60-tear.Scale*10)+100)/100
        sfx:Play(mod.Sounds.AceVenturaLaugh, 0.6, 0, false, pitch)
        local splat = Isaac.Spawn(1000, 16, 4, tear.Position, Vector.Zero, tear)
        local color = Color(0.3,0.5,1,1,0.35,0.15,0.35)
        color:SetColorize(1,1,2,1)
        splat.Color = color
        splat.SpriteScale = Vector(tear.Scale/2, tear.Scale/2)
        local spood = Isaac.Spawn(5, FiendFolio.PICKUP.VARIANT.FIEND_MINION, 2, tear.Position, Vector.Zero, tear.SpawnerEntity)
		spood.Parent = tear.SpawnerEntity
		--spood:GetData().hollow = true
        local isActiveRoom = mod.IsActiveRoom()
        if not isActiveRoom then
			spood:GetData().mixPersistent = true
			spood:GetData().mixRemainingRooms = 1
			spood:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
		end
    end
end

function mod.fiendsThirdLegTear(v, d)
    if d.fiendsThirdLeg then
        if v.FrameCount % 2 == 0 then
            local creep = Isaac.Spawn(1000, 46, 0, v.Position, Vector.Zero, v):ToEffect()
            creep.Color = Color(0.2,0,1,1,0.15+math.random(25,30)/100,0.2,0.15+math.random(25,30)/100)
            local damage = 10
            if v.SpawnerEntity and v.SpawnerEntity:ToPlayer() then
                damage = v.SpawnerEntity:ToPlayer().Damage
            end
            creep.CollisionDamage = damage
            creep.SpriteScale = Vector(0.7,0.7)
            creep:SetTimeout(30)
        end
    end
end