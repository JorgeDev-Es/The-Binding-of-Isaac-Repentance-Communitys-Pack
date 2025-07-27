local mod = TaintedTreasure
local game = Game()
local sfx = SFXManager()

local function MakeKnifeIntoBottle(knife, data, sprite, isBroken)
	local familiar = knife.Parent:ToFamiliar()
	if familiar and familiar.Player:GetPlayerType() == PlayerType.PLAYER_LILITH_B then
		local playerdata = familiar.Player:GetData()
		data.BrokenBottle = playerdata.BrokenBottle
	end
    if isBroken then
        data.BottleRoomIndex = game:GetLevel():GetCurrentRoomIndex()
        data.BrokenBefore = true
        sprite:ReplaceSpritesheet(0, "gfx/projectiles/knife_bottle_broken.png")
        sprite:LoadGraphics()
    else
        sprite:ReplaceSpritesheet(0, "gfx/projectiles/knife_bottle.png")
        sprite:LoadGraphics()
    end
    data.IsTaintedBottle = true
end

local function BreakBottle(knife, data)
    local rng = knife:GetDropRNG()
    knife.Visible = false
    knife.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
    data.BrokenBottle = 150
    data.BottleRoomIndex = game:GetLevel():GetCurrentRoomIndex()
    sfx:Play(TaintedSounds.BOTTLE_BREAK)
    sfx:Play(TaintedSounds.BOTTLE_BREAK2)
    local shardvec = RandomVector()
    for i = 1, 5 do
        local shard = Isaac.Spawn(1000, TaintedEffects.BOTTLE_SHARD, 0, knife.Position, (shardvec * mod:RandomInt(2,4,rng)):Rotated(i * (360/5)), knife)
        shard.CollisionDamage = math.max(3.5, knife.CollisionDamage)
    end
	if knife.Parent:ToFamiliar() and knife.Parent:ToFamiliar().Player:GetPlayerType() == PlayerType.PLAYER_LILITH_B then
		local playerdata = knife.Parent:ToFamiliar().Player:GetData()
		playerdata.BrokenBefore = true
		playerdata.BrokenBottle = 150
	end
end

local function RestoreBottle(knife, data, sprite)
    local color = knife.Color
    knife:SetColor(Color(color.R,color.G,color.B,-1,color.RO,color.GO,color.BO),8,1,true,false)
    Isaac.Spawn(1000,15,1,knife.Parent.Position + Vector(25,0):Rotated(knife.Rotation),Vector.Zero,knife)
    knife.Visible = true
    knife.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
    data.BrokenBottle = nil
    data.BrokenBefore = true
    sprite:ReplaceSpritesheet(0, "gfx/projectiles/knife_bottle_broken.png")
    sprite:LoadGraphics()
end

local function ResetBottle(knife, data, sprite)
    sprite:ReplaceSpritesheet(0, "gfx/projectiles/knife_bottle.png")
    sprite:LoadGraphics()
    knife.Visible = true
    knife.EntityCollisionClass = EntityCollisionClass.ENTCOLL_ALL
    data.BrokenBottle = nil
    data.BrokenBefore = nil
	if knife.Parent:ToFamiliar() and knife.Parent:ToFamiliar().Player:GetPlayerType() == PlayerType.PLAYER_LILITH_B then
		local playerdata = knife.Parent:ToFamiliar().Player:GetData()
		playerdata.BrokenBefore = nil
		playerdata.BrokenBottle = nil
	end
end

function mod:TheBottlePlayerLogic(player, data, savedata)
    mod:CheckItemWisps(player, CollectibleType.COLLECTIBLE_MOMS_KNIFE, player:GetCollectibleNum(TaintedCollectibles.THE_BOTTLE))

    if player:HasCollectible(TaintedCollectibles.THE_BOTTLE) then
		if data.BrokenBottle then
			if data.BrokenBottle > 0 then
				data.BrokenBottle = data.BrokenBottle - 1
			else
				data.BrokenBottle = nil
			end
		end
    end
end

function mod:BottleKnifeUpdate(knife, data)
    if knife.Variant == 0 then
        local sprite = knife:GetSprite()
        if data.IsTaintedBottle then
            if data.BrokenBottle then
                local player = knife.Parent:ToPlayer() or knife.Parent:ToFamiliar().Player
                knife:Reset()
                knife:Shoot(0,0) --Prevents charging the knife
                if player and player:Exists() then
                    knife.Rotation = mod:GetAimDirectionGood(player):GetAngleDegrees()
                    data.BrokenBottle = data.BrokenBottle - 1
                    if data.BrokenBottle <= 0 then
                        RestoreBottle(knife, data, sprite)
                    elseif data.BottleRoomIndex ~= game:GetLevel():GetCurrentRoomIndex() then
                        ResetBottle(knife, data, sprite)
                    end
                end
            elseif data.BrokenBefore then
                if data.BottleRoomIndex ~= game:GetLevel():GetCurrentRoomIndex() then --Repair the bottle on new rooms
                    ResetBottle(knife, data, sprite)
                end
            end
        else
            local parent = knife.Parent
            if parent then
                if parent:ToPlayer() then
                    local player = parent:ToPlayer()
                    if player:Exists() and player:HasCollectible(TaintedCollectibles.THE_BOTTLE) then
                        MakeKnifeIntoBottle(knife, data, sprite)
                    end
                elseif parent:ToKnife() then --Multi-shot knifes
                    if parent:GetData().IsTaintedBottle then
                        MakeKnifeIntoBottle(knife, data, sprite, parent:GetData().BrokenBefore)
                    end
                elseif parent:ToFamiliar() then
					local player = parent:ToFamiliar().Player
					if player:Exists() and player:HasCollectible(TaintedCollectibles.THE_BOTTLE) then
						if player:GetPlayerType() ~= PlayerType.PLAYER_LILITH_B then
							MakeKnifeIntoBottle(knife, data, sprite)
						else
							MakeKnifeIntoBottle(knife, data, sprite, player:GetData().BrokenBefore)
						end
                    end
				end
            end
        end
    end
end

function mod:BottleKnifeOnHit(knife, data, npc, flags, damage, countdown)
	local player = knife.Parent:ToPlayer()
	local familiar = knife.Parent:ToFamiliar()
	local mult = 1
	if data.TaintedRawSoylent then
		mult = mult * 0.2
	end
	
    if data.BrokenBottle then
        return false
    elseif knife:IsFlying() and (knife.Charge >= 1.0 or (knife.Charge >= 0.69 and familiar and familiar.Player:GetPlayerType() == PlayerType.PLAYER_LILITH_B) or (knife.Charge >= 0.97 and player and player:HasCollectible(CollectibleType.COLLECTIBLE_MARKED))) then
        BreakBottle(knife, data)
        npc:TakeDamage(damage * 3 * mult, flags | DamageFlag.DAMAGE_CLONES, EntityRef(knife), countdown)  
        return false
    elseif not data.BrokenBefore then
        npc:TakeDamage(damage * 0.25 * mult, flags | DamageFlag.DAMAGE_CLONES, EntityRef(knife), countdown)  
        return false
    --[[else
		npc:TakeDamage(damage * 1.05, flags | DamageFlag.DAMAGE_CLONES, EntityRef(knife), countdown)
        return false]]
	end
end

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, function(_, effect)
    local rng = effect:GetDropRNG()
    local data = effect:GetData()
    local sprite = effect:GetSprite()
    data.StateFrame = 2
    data.Increment = mod:RandomInt(9,12,rng) * 0.05
    data.Height = mod:RandomInt(20,40,rng)
    sprite.FlipX = (rng:RandomFloat() <= 0.5)
    sprite:SetFrame("Shard", mod:RandomInt(0,7,rng))
end, TaintedEffects.BOTTLE_SHARD)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_RENDER, function(_, effect)
    if mod:IsNormalRender() and effect:Exists() then
        local data = effect:GetData()
        local sprite = effect:GetSprite()
        if not data.Landed then
            local curve = math.sin(math.rad(data.StateFrame * 9))
            local height = 0 - curve * data.Height
            sprite.Offset = Vector(0, height)
            if height >= 0 then
                effect.Velocity = Vector.Zero
                sprite.Offset = Vector.Zero
                data.Landed = true
                if game:GetRoom():GetGridCollisionAtPos(effect.Position) > GridCollisionClass.COLLISION_NONE then
                    effect:Remove()
                end
            else
                data.StateFrame = data.StateFrame + data.Increment
            end
        end
    end
end, TaintedEffects.BOTTLE_SHARD)

mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, function(_, effect)
    local data = effect:GetData()
    if data.Landed then
        if effect.FrameCount == 300 then --Fade out
            effect.Color = Color(1,1,1,0)
            effect:SetColor(Color.Default, 10, 1, true, false)
        elseif effect.FrameCount == 315 then --Remove
            effect:Remove()
        elseif effect.FrameCount % 5 == 0 then
            for _, enemy in pairs(Isaac.FindInRadius(effect.Position, 100, EntityPartition.ENEMY)) do
                if enemy:IsEnemy() and enemy.EntityCollisionClass >= EntityCollisionClass.ENTCOLL_PLAYEROBJECTS and enemy.Position:Distance(effect.Position) < enemy.Size + (effect.Size * 1.5) and not enemy:IsFlying() then
                    enemy:TakeDamage(effect.CollisionDamage / 2, 0, EntityRef(effect), 0)
                    enemy:AddEntityFlags(EntityFlag.FLAG_BLEED_OUT)
                    enemy:GetData().BleedDebuffed = 150
                end
            end
        end
    end
end, TaintedEffects.BOTTLE_SHARD)