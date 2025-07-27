local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, item, rng, player, useFlags, activeSlot)
    local usable = false
    local origData = player:GetData().ffsavedata
    if not origData.SpellSlots then
        origData.SpellSlots = {}
    end
    local savedata = origData.SpellSlots
    if useFlags == useFlags | UseFlag.USE_OWNED then
        if savedata[item].CurrentSlots > 0 then
            savedata[item].CurrentSlots = savedata[item].CurrentSlots-1
            savedata[item].LastChanged = game:GetFrameCount()
            usable = true
        end
    else
        usable = true
    end

    if usable then
        local target = Isaac.Spawn(mod.FF.MoonbeamTarget.ID, mod.FF.MoonbeamTarget.Var, mod.FF.MoonbeamTarget.Sub, player.Position, Vector.Zero, player)
        target:GetData().player = player
    end
end, FiendFolio.ITEM.COLLECTIBLE.MOONBEAM)

function mod:moonbeamTargetEffect(e)
    local sprite = e:GetSprite()
    local data = e:GetData()

    if not data.player or not data.player:Exists() then
        e:Remove()
    else
        local move = true
        local xIn = data.player:GetShootingInput().X
        local yIn = data.player:GetShootingInput().Y
        if Options.MouseControl == true then
			if Input.IsMouseBtnPressed(0) == false and (xIn == 0 and yIn == 0) then
				move = false
			end
		else
			if (xIn == 0 and yIn == 0) then
				move = false
			end
		end

        if move then
            local vec = Vector(xIn, 0):Resized(14)+Vector(0, yIn):Resized(14)
            e.Velocity = mod:Lerp(e.Velocity, vec, 0.3)
        else
            e.Velocity = mod:Lerp(e.Velocity, Vector.Zero, 0.3)
        end

        if e.FrameCount > 80 then
            local beam = Isaac.Spawn(mod.FF.MoonbeamLight.ID, mod.FF.MoonbeamLight.Var, mod.FF.MoonbeamLight.Sub, e.Position, Vector.Zero, data.player)
            beam:GetData().moonbeamStuff = {player = data.player, damage = data.player.Damage, luck = data.player.Luck}
            sfx:Play(SoundEffect.SOUND_ANGEL_BEAM, 1, 0, false, 1.3)
            e:Remove()
        end
    end
end

function mod:moonbeamLightEffect(e)
    local sprite = e:GetSprite()
    local data = e:GetData()

    if not data.init then
        data.state = "Appear"
        data.init = true
    end

    if not data.moonbeamStuff or not data.moonbeamStuff.player:Exists() then
        e:Remove()
    elseif data.state == "Idle" then
        if e.FrameCount > 300 then
            data.state = "Disappear"
        end
        mod:spritePlay(sprite, "Idle")

        for _,ent in ipairs(Isaac.FindInRadius(e.Position, 60, EntityPartition.ENEMY)) do
            if ent:IsActiveEnemy() and (not mod:isFriend(ent)) and ent:IsVulnerableEnemy() and not ent:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) then
                if e.FrameCount % 20 == 0 then
                    local d = ent:GetData()
                    local r = ent:GetDropRNG()
                    local r2 = data.moonbeamStuff.player:GetDropRNG()
                    if not d.SpellStats then
                        d.SpellStats = {
                            Strength = r:RandomInt(30)+1,
                            Dexterity = r:RandomInt(30)+1,
                            Constitution = r:RandomInt(30)+1,
                            Intelligence = r:RandomInt(30)+1,
                            Wisdom = r:RandomInt(30)+1,
                            Charisma = r:RandomInt(30)+1,
                        }
                    end
                    --Roll for Constitution saving throw
                    local roll = (r:RandomInt(20)+1)+math.floor((d.SpellStats.Constitution-10)/2)
                    local attackRoll = r2:RandomInt(20)+1 --I will do character modifiers later, for now let's just roll
                    local damage = r2:RandomInt(10)+r2:RandomInt(10)+2
                    if roll < attackRoll then --Your foe takes 2d10 radiant damage
                        ent:TakeDamage(damage, 0, EntityRef(data.moonbeamStuff.Player), 0)
                    else --Your foe manages to resist your attack, taking half damage
                        ent:TakeDamage(damage/2, 0, EntityRef(data.moonbeamStuff.Player), 0)
                    end
                end
            end
        end

    elseif data.state == "Appear" then
        if sprite:IsFinished("Appear") then
            data.state = "Idle"
        else
            mod:spritePlay(sprite, "Appear")
        end
    elseif data.state == "Disappear" then
        if sprite:IsFinished("Disappear") then
            e:Remove()
        else
            mod:spritePlay(sprite, "Disappear")
        end
    end
end