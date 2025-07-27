local mod = TaintedTreasure
local game = Game()

function mod:WarMaidenPlayerLogic(player, data)
	if player:HasCollectible(TaintedCollectibles.WAR_MAIDEN) then
		data.TaintedSmashTimer = data.TaintedSmashTimer or 0
		data.TaintedSmashInvincibility = data.TaintedSmashInvincibility or 0
		
		local room = game:GetRoom()
		local wrapposition = room:ScreenWrapPosition(player.Position, 15)
		if not room:IsPositionInRoom(player.Position + player.Velocity, 10) and mod:IsGridWalkable(wrapposition, player.CanFly or player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B) and player:CollidesWithGrid() and room:IsPositionInRoom(wrapposition, 10) and data.TaintedSmashTimer == 0 then
			local isdoor = false
			local secretslot = false
			local closestdistance = 100000
			for i = 0, DoorSlot.NUM_DOOR_SLOTS do
				local door = room:GetDoor(i)
				if door then
					if player.Position:Distance(room:GetDoorSlotPosition(i)) < 40 and door:IsOpen() then
						isdoor = true
					end
					if wrapposition:Distance(room:GetDoorSlotPosition(i)) < 50 and not door:IsOpen() and (door.TargetRoomType == RoomType.ROOM_SECRET or door.TargetRoomType == RoomType.ROOM_SUPERSECRET or door:IsRoomType(RoomType.ROOM_SECRET) or door:IsRoomType(RoomType.ROOM_SUPERSECRET)) then
						secretslot = i
					end
				end
			end
			
			if not isdoor and (player:GetPlayerType() ~= PlayerType.PLAYER_THEFORGOTTEN_B or string.sub(player:GetOtherTwin():GetSprite():GetAnimation(), 1, #"Pickup") ~= "Pickup") then --if player is Tainted Forgotten, checks if the Soul is in a pickup animation
				local color = player.Color
				local pos = player.Position
				
				if player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN_B then --Gives Tainted Forgotten some extra oomph, otherwise he sits right next to the wall
					player.Velocity = player.Velocity + (player.Position - wrapposition):Resized(6)
				end
				
				player.Position = wrapposition
				data.TaintedSmashTimer = 15
				data.TaintedSmashInvincibility = 10
				player:SetColor(Color(color.R,color.G,color.B,0,color.RO,color.GO,color.BO),6,1,true,false)
				SFXManager():Play(SoundEffect.SOUND_ROCK_CRUMBLE, 1)
				game:ShakeScreen(4)
				
				for i = 0, 3 do
					Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.ROCK_PARTICLE, 0, player.Position, RandomVector()*mod:RandomInt(5,10), player)
					
					local smoke = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.DARK_BALL_SMOKE_PARTICLE, 0, player.Position, Vector(mod:RandomInt(-1, -1), mod:RandomInt(-1, 1))*mod:RandomInt(5,10)*-player.Velocity, player)
					smoke:SetColor(Color(0.1, 0.1, 0.1, 0.3, 0.5, 0.5, 0.5), -1, 1)
				end
				
				local angle
				if math.abs(pos.X - wrapposition.X) < math.abs(pos.Y - wrapposition.Y) then
					if pos.Y < wrapposition.Y then
						angle = 180
					else
						angle = 0
					end
				else
					if pos.X < wrapposition.X then
						angle = 90
					else
						angle = 270
					end
				end

				local hole = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.XRAY_WALL, 0, player.Position - Vector(0,40):Rotated(angle), Vector.Zero, player):ToEffect()
				hole:GetSprite():Play("Idle")
				hole:GetSprite().PlaybackSpeed = 0.02
				hole.Color = Color(1,1,1,0)
				hole:SetColor(Color.Default, 100, 1, true, false)
				hole.SpriteRotation = angle --(wrapposition-pos):GetAngleDegrees()
				
				--[[local biggestdiff = {1000, 0}
				for i = -180, 180, 90 do
					local diff = math.abs(hole.SpriteRotation - i)
					if diff < biggestdiff[1] or biggestdiff[1] == 1000 then
						biggestdiff = {diff, i}
					end
				end
				
				hole.SpriteRotation = biggestdiff[2] + 90]]
				
				if secretslot then
					local door = room:GetDoor(secretslot)
					door:TryBlowOpen(false, player)
				end
			end
		end
		if data.TaintedSmashTimer > 0 then
				data.TaintedSmashTimer = data.TaintedSmashTimer - 1
			end
		if data.TaintedSmashInvincibility > 0 then
			data.TaintedSmashInvincibility = data.TaintedSmashInvincibility - 1
		end
	end
end

mod:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, function(_, projectile, collider)
	if collider:GetData().TaintedSmashInvincibility and collider:GetData().TaintedSmashInvincibility ~= 0 then
		return true
	end
end)

mod:AddCallback(ModCallbacks.MC_PRE_NPC_COLLISION, function(_, projectile, collider)
	if collider:GetData().TaintedSmashInvincibility and collider:GetData().TaintedSmashInvincibility ~= 0 then
		return true
	end
end)