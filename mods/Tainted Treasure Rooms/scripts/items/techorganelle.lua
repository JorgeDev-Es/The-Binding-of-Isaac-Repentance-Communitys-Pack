local mod = TaintedTreasure
local game = Game()

function mod:TechOrganelleTearUpdate(tear, data, player)
	data.TaintedTechLaser = data.TaintedTechLaser or Isaac.Spawn(EntityType.ENTITY_LASER, 10, 0, player.Position + Vector(0,-10), Vector.Zero, player):ToLaser()
	local laser = data.TaintedTechLaser
	local laserend = tear.Position + Vector(0, tear.Height + 7)
	laser.Angle = (laserend - player.Position):GetAngleDegrees()
	laser.MaxDistance = laserend:Distance(player.Position)
	laser.Velocity = (player.Position + Vector(0,-10)) - laser.Position
	laser.DepthOffset = -500
	laser.CollisionDamage = tear.CollisionDamage * 0.33
	laser:SetTimeout(2)
	laser:SetColor(Color(1, 0.3, 0.3, 0.8, 0, 0, 0), -1, 1)
end

function mod:TechOrganelleKnifeUpdate(knife, data)
	local player = mod:getPlayerFromKnife(knife)
	if player and player:HasCollectible(TaintedCollectibles.TECH_ORGANELLE) then
		data.TaintedTechLaser = data.TaintedTechLaser or Isaac.Spawn(EntityType.ENTITY_LASER, 10, 0, player.Position, Vector.Zero, player):ToLaser()
		if not data.TaintedTechLaser:Exists() then
			data.TaintedTechLaser = Isaac.Spawn(EntityType.ENTITY_LASER, 10, 0, player.Position, Vector.Zero, player):ToLaser()
		end
		local laser = data.TaintedTechLaser
		local laserend = knife.Position
		laser.Angle = (laserend - player.Position):GetAngleDegrees()
		laser.MaxDistance = laserend:Distance(player.Position)
		laser.Velocity = (player.Position + Vector(0,-10)) - laser.Position
		laser.DepthOffset = -500
		laser.CollisionDamage = knife.CollisionDamage * 0.33
		laser:SetTimeout(2)
		laser:SetColor(Color(1, 0.3, 0.3, 0.8, 0, 0, 0), -1, 1)
	end
end

function mod:TechOrganelleBombUpdate(bomb, data, player)
	data.TaintedTechLaser = data.TaintedTechLaser or Isaac.Spawn(EntityType.ENTITY_LASER, 10, 0, player.Position + Vector(0,-10), Vector.Zero, player):ToLaser()
	if not data.TaintedTechLaser:Exists() then
		data.TaintedTechLaser = Isaac.Spawn(EntityType.ENTITY_LASER, 10, 0, player.Position, Vector.Zero, player):ToLaser()
	end
	local laser = data.TaintedTechLaser
	local laserend = bomb.Position
	laser.Angle = (laserend - player.Position):GetAngleDegrees()
	laser.MaxDistance = laserend:Distance(player.Position)
	laser.Velocity = (player.Position + Vector(0,-10)) - laser.Position
	laser.DepthOffset = -500
	laser.CollisionDamage = bomb.ExplosionDamage * 0.05
	laser:SetTimeout(2)
	laser:SetColor(Color(1, 0.3, 0.3, 0.8, 0, 0, 0), -1, 1)
end