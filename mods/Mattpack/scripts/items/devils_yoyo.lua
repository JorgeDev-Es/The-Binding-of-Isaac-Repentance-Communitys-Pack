local mod = MattPack
local game = mod.constants.game
local sfx = mod.constants.sfx
local pool = mod.constants.pool
local SaveManager = mod.SaveManager

if EID then
    EID:addCollectible(MattPack.Items.DevilsYoYo, "Dangles a bladed Yo-Yo over Isaac's head, which triples all pedestal items#{{Warning}} Every frame, has a low chance to rev up and repeatedly slash into Isaac, damaging him down to half a heart")
    mod.appendToDescription(CollectibleType.COLLECTIBLE_DAMOCLES, 'using {{Collectible' .. CollectibleType.COLLECTIBLE_SPIN_TO_WIN .. "}} {{ColorYellow}}Spin to Win{{CR}}", true)

    -- Synergies
    mod.addSynergyDescription(MattPack.Items.Balor, 
    CollectibleType.COLLECTIBLE_DAMOCLES, 
    "Items are quadrupled")
end

function mod:playerYoyoUpdate(player)
    if player:HasCollectible(MattPack.Items.DevilsYoYo) then
        local data = player:GetData()
        if not data.yoyoFamiliar or data.yoyoFamiliar:Exists() == false then
            local familiar = Isaac.Spawn(3, 2021, 0, player.Position + Vector(0, -175), Vector.Zero, player):ToFamiliar()
            familiar.Visible = false
            if familiar then
                familiar.Parent = player
                familiar:FollowParent(player)
                data.yoyoFamiliar = familiar
                familiar:GetSprite():Play("HandIdle")
                familiar.DepthOffset = 200
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, mod.playerYoyoUpdate)

function mod:yoyoUpdate(ent)
    if not ent.Parent or ent.Parent:Exists() == false then
        ent:Remove()
    else
        ent.Visible = true
        local data = ent:GetData()
        local effect = data.yoyoEffect

        data.targetSpriteRotation = nil
        data.elasticity = nil
        data.handSpriteRot = nil

        if effect then
            local player = (ent.Player or Isaac.GetPlayer()):ToPlayer()
            effect.DepthOffset = 50
            if not data.state then
                data.state = 0
            end
            ent:GetSprite():Play("HandIdle")
            effect:GetSprite():Play("YoYoIdle")
            data.stateFrame = (data.stateFrame or 0) + 1
            if data.isSpinning then
                if not sfx:IsPlaying(MattPack.Sounds.SawLoop) then
                    local volume = 1.25
                    if data.state == 2 then
                        volume = .5
                    end
                    sfx:Play(MattPack.Sounds.SawLoop, volume, 2, true)
                end
            elseif sfx:IsPlaying(MattPack.Sounds.SawLoop) then
                sfx:Stop(MattPack.Sounds.SawLoop)
            end
            data.isSpinning = nil
            data.handSpriteRot = nil
            data.targetSpriteRotation = nil
            data.stringLength = nil
            data.elasticity = nil
            if data.state == 0 then -- hold in hand
                data.stringLength = 20
                data.elasticity = .5
                if data.stateFrame >= 30 then
                    data.state = 1
                    data.stateFrame = 0
                end
                effect.Velocity = effect.Velocity * .66
    
            elseif data.state == 1 then -- dangle, default
                data.stringLength = 75
                if math.random(1, 2500) == 1 then
                    if math.random(1, 15) == 1 then
                        data.state = 2
                    else     
                        data.state = 3
                    end
                    data.stateFrame = 0
                end
            elseif data.state == 2 then -- taunt
                data.stringLength = 100
                effect:GetSprite():Play("YoYoSpin")
                ent:GetSprite():Play("HandOpen")
                data.isSpinning = true
                data.handSpriteRot = Lerp(ent.SpriteRotation, -45, .25)
                data.targetSpriteRotation = effect.SpriteRotation + 120
                data.stateFrame = (data.stateFrame or 0) + 1
                if data.stateFrame >= 120 then
                    data.state = 0
                    data.stateFrame = 0
                end
            elseif data.state == 3 then -- damage
                data.targetSpriteRotation = effect.SpriteRotation + 120
                data.stringLength = 150
                data.elasticity = 0
                effect.Velocity = Lerp(effect.Velocity, (player.Position + Vector(0, -30) * player.SpriteScale.Y) - effect.Position, .66)
                ent:GetSprite():Play("HandOpen")
                effect:GetSprite():Play("YoYoSpin")
                data.isSpinning = true
                data.handSpriteRot = Lerp(ent.SpriteRotation, -45, .25)
                if math.random(1, 3) == 1 then
                    Isaac.Spawn(1000, 5, math.random(0,4), effect.Position, RandomVector():Resized(math.random(0,15)), player)
                    sfx:Play(SoundEffect.SOUND_BONE_BREAK, 1.25)
                else
                    Isaac.Spawn(1000, 2, math.random(1,3), effect.Position + RandomVector():Resized(math.random(0, 5)), Vector.Zero, player)
                end
                if data.stateFrame % 6 == 0 then
                    player:BloodExplode()
                    local toDamage = Isaac.FindByType(3, 62)
                    table.insert(toDamage, player)
                    for _,entToDmg in ipairs(toDamage) do
                        entToDmg:TakeDamage(1, DamageFlag.DAMAGE_NOKILL | DamageFlag.DAMAGE_NO_MODIFIERS | DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(ent), 0)
                    end
                    player:ResetDamageCooldown()
                    local hp = (player:GetEternalHearts() + player:GetHearts() + player:GetRottenHearts() + player:GetSoulHearts() + player:GetBoneHearts())
                    local healthType = player:GetHealthType()
                    if healthType == HealthType.COIN or healthType == HealthType.KEEPER then
                        hp = hp / 2
                    end
                    if hp <= 1 or (player:HasInstantDeathCurse()) 
                    and data.stateFrame >= 45 then
                        data.state = 0
                        data.stateFrame = 0
                        sfx:Play(MattPack.Sounds.SawEnd1, .75)
                    end
                end
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.yoyoUpdate, 2021)

local yoyoSprite = Sprite()
yoyoSprite:Load("gfx/devilsyoyo.anm2")
yoyoSprite:Play("String", true)

local function spawnCord(parent, target, position)
    local cord = Isaac.Spawn(865, 10, 2021, position, Vector.Zero, parent)
    cord.Parent = parent
    cord.Target = target
    cord:GetSprite():ReplaceSpritesheet(0, "gfx/yoyo_beam.png", true)
    cord:GetSprite():ReplaceSpritesheet(1, "gfx/yoyo_beam.png", true)
    cord:GetSprite():Play("Gut", true)
    cord:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
    cord:AddEntityFlags(EntityFlag.FLAG_DONT_OVERWRITE)
    return cord
end

function mod:yoyoTrack(ent, offset)
    if game:GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT == false then
        local parent = ent.Parent and ent.Parent:ToPlayer()
        local data = ent:GetData()
        if parent and parent:HasCollectible(MattPack.Items.DevilsYoYo) then
            local isPaused = game:IsPaused()
            ent:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
            ent.PositionOffset = Vector(3, -2)
            ent.Position = parent.Position + Vector(0, -175)
            local origPos = ent.Position
            local effect = data.yoyoEffect
            if (not effect) or effect:Exists() == false then
                local spawnPos = origPos
                if ent.FrameCount > 1 then
                    spawnPos = spawnPos + Vector(0, data.cordLength or 75)
                end
                effect = Isaac.Spawn(1000, 2021, 0, spawnPos, Vector.Zero, ent)
                effect:AddEntityFlags(EntityFlag.FLAG_PERSISTENT)
                effect:GetSprite():Play("YoYoIdle", true)
                effect.Parent = ent
                data.yoyoEffect = effect
            end
            if isPaused and not data.effectOffset and (RoomTransition.GetTransitionMode() ~= 4) then
                data.effectOffset = effect.Position - ent.Position
                data.effectVel = effect.Velocity
                effect.Visible = false
                effect:Render((data.effectOffset or Vector.Zero) + offset) -- this worked?
            else
                if data.effectOffset then
                    effect.Position = ent.Position + data.effectOffset
                    data.effectOffset = nil
                    effect.Velocity = data.effectVel
                    data.effectVel = nil
                end
                effect.Visible = true
            end
            effect.DepthOffset = 25
            local dist = origPos - effect.Position
            local stringLength = data.stringLength or 75

            if isPaused == false then
                effect.Velocity = effect.Velocity + Vector(0, 3)
                if dist:Length() > stringLength then
                    local distToClose = dist - dist:Resized(stringLength)
                    effect.Velocity = effect.Velocity + distToClose * (data.elasticity or 0.5)
                end
            else
                effect:Render((data.effectOffset or Vector.Zero) + offset)
            end
            ent.SpriteRotation = data.handSpriteRot or ((dist:Rotated(90):GetAngleDegrees()) / 3)
            local targetSpriteRotation = data.targetSpriteRotation or -dist:GetAngleDegrees() * 1.5 + (data.lastSpriteRot or 0) * .15
            data.lastSpriteRot = targetSpriteRotation - effect.SpriteRotation
            effect.SpriteRotation = targetSpriteRotation
            effect.PositionOffset = Vector(0, -15)

            effect:GetData().parentFamiliar = ent

            local cord = data.stringCord
            if not cord or cord:Exists() == false then
                cord = spawnCord(ent, effect, origPos)
                data.stringCord = cord
            end
            if cord.FrameCount > 1 and not isPaused then
                cord:Update()
            end
        else
            if data.yoyoEffect then
                data.yoyoEffect:Remove()
            end
            if data.stringCord then
                data.stringCord:Remove()
            end
            ent:Remove()
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_RENDER, mod.yoyoTrack, 2021)

function mod:clearYoyo(ent)
    if not (ent.Parent and ent.Parent:Exists()) then
        ent:Remove()
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_EFFECT_UPDATE, mod.clearYoyo, 2021)

function mod:yoyoString(cord, offset)
    if cord.Variant == 10 and cord.SubType == 2021 then
        if cord.FrameCount == 1 and not game:IsPaused() then
            cord:Update()
            cord:Update()
            cord:Update()
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_NPC_RENDER, mod.yoyoString, 865)

local storyItems = {
    [626] = true,
    [627] = true,
    [238] = true,
    [239] = true,
    [327] = true,
    [328] = true,
    [668] = true,
}

function mod.duplicateItem(ent, dupes)
    local runSave = SaveManager.GetRunSave()
    if runSave then
        ent:GetData().DamoclesDuplicate = true
        if not runSave.dontDupe then
            runSave.dontDupe = {}
        end
        runSave.dontDupe[tostring(ent.InitSeed)] = true
        if game:GetLevel():GetCurrentRoomDesc():GetDimension() == Dimension.DEATH_CERTIFICATE then
            return
        end
        local dupes = dupes or 2
        for i = 1, dupes do
            local roompool = game:GetRoom():GetItemPool()
            local subtype = pool:GetCollectible(roompool, true, ent.InitSeed)
            local pos = game:GetRoom():FindFreePickupSpawnPosition(ent.Position, i <= 3 and 60 or 20) -- thank u cucco
            if storyItems[ent.SubType] then
                subtype = storyItems[ent.SubType]
            end
            local dupe = Isaac.Spawn(5, 100, subtype, pos, Vector.Zero, ent):ToPickup()
            dupe:ClearEntityFlags(EntityFlag.FLAG_ITEM_SHOULD_DUPLICATE)
            dupe:GetData().DamoclesDuplicate = true
            runSave.dontDupe[tostring(dupe.InitSeed)] = true
            if ent.ShopItemId and ent.Price ~= 0 then
                dupe:MakeShopItem(ent.ShopItemId)
            end
            if ent.OptionsPickupIndex ~= 0 then
                dupe.OptionsPickupIndex = ent.OptionsPickupIndex + 25 + i
            end
            if ent:IsBlind() then
                dupe:SetForceBlind (true)
            end
        end
    end
end

function mod:damoclesEffect(ent)
    local runSave = SaveManager.GetRunSave()
    if runSave then
        if PlayerManager.AnyoneHasCollectible(MattPack.Items.DevilsYoYo) then
            if not runSave.dontDupe then
                runSave.dontDupe = {}
            end
            if mod.cancelDupeFrame then
                if mod.cancelDupeFrame == game:GetFrameCount() then
                    return
                else
                    mod.cancelDupeFrame = nil
                end
            end
            if not (runSave.dontDupe[tostring(ent.InitSeed)]) then
                if (not ent:GetData().DamoclesDuplicate) and not (ent.SpawnerEntity and ent.SpawnerEntity:GetData().DamoclesDuplicate) then
                    ent:GetData().DamoclesDuplicate = true
                    local dupes = 2
                    if ent:HasEntityFlags(EntityFlag.FLAG_ITEM_SHOULD_DUPLICATE) then
                        ent:ClearEntityFlags(EntityFlag.FLAG_ITEM_SHOULD_DUPLICATE) -- ESSENTIAL line LMAO
                        dupes = dupes + 1
                    end
                    Isaac.CreateTimer(function()
                        mod.duplicateItem(ent, dupes)
                    end, 1, 1)
                end
            end
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_PICKUP_INIT, CallbackPriority.IMPORTANT, mod.damoclesEffect, 100)

function mod:fixRerollDupe(ent, type, var)
    local runSave = SaveManager.GetRunSave()
    if runSave then
        if ent.Variant == 100 then
            mod.cancelDupeFrame = game:GetFrameCount()
            if not runSave.dontDupe then
                runSave.dontDupe = {}
            end
            runSave.dontDupe[tostring(ent.InitSeed)] = true
        end
    end
end
mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_MORPH, mod.fixRerollDupe)
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_MORPH, mod.fixRerollDupe)


function mod:clearDataNewRoom()
    mod.cancelDupeFrame = nil
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.clearDataNewRoom)

function mod:clearDataNewLevel()
    local runSave = SaveManager.GetRunSave()
    runSave.dontDupe = {}
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, mod.clearDataNewLevel)


function mod:devilsYoyoUnlock(ent)
    if ent.Velocity:Length() > 10 then
        local dmc = Isaac.FindByType(5, 100, CollectibleType.COLLECTIBLE_DAMOCLES) or {}
        local pedestalExists = false
        for _,pedestal in ipairs(dmc) do
            pedestalExists = true
            local data = pedestal:GetData()
            data.spinCharge = (data.spinCharge or 0) + .25
        end
        if pedestalExists then
            ent.Player:SetActiveCharge(90)
        end
    end
end
mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, mod.devilsYoyoUnlock, 226)

local maxSpin = 75
function mod:devilsYoyoPedestalSpin(ent)
    if ent.SubType == CollectibleType.COLLECTIBLE_DAMOCLES then
        local data = ent:GetData()
        local itemLayer = ent:GetSprite():GetLayer(1)
        if data.spinCharge then
            local percent = data.spinCharge / maxSpin
            data.spinCharge = data.spinCharge - .05
            local targetScale = Vector(.75, 1)
            local targetOffset = Vector(-3, 7)
            local targetColor = Color(1,1,1,1)
            targetColor:SetColorize(2, .1, .1, 2)
            local pos = ent.Position + Vector(0, -42.5)
            if data.spinCharge <= 0 then
                data.spinCharge = nil
            elseif data.spinCharge > maxSpin then
                ent:Morph(ent.Type, ent.Variant, MattPack.Items.DevilsYoYo, true)
                mod.constants.pool:RemoveCollectible(MattPack.Items.DevilsYoYo)
                ent:SetColor(targetColor, 15, 999, true, true)
                for i = 0, math.random(10, 15) do
                    local particle = Isaac.Spawn(1000, 66, 0, pos, RandomVector():Resized(math.random(2, 15), math.random(0, 50) / 100), nil)
                    particle.Color = Color(1,1,1,1,1)
                end
                sfx:Play(SoundEffect.SOUND_DEVILROOM_DEAL, 1.5)
                sfx:Play(SoundEffect.SOUND_TOOTH_AND_NAIL, 1.5, nil, nil, 1)
                sfx:Play(SoundEffect.SOUND_SATAN_CHARGE_UP, 1.5, nil, nil, 1.5)
                data.spinCharge = nil
                sfx:Stop(MattPack.Sounds.TechOmegaLoop)

            else
                if not sfx:IsPlaying(MattPack.Sounds.TechOmegaLoop) then
                    sfx:Play(MattPack.Sounds.TechOmegaLoop)
                end
                local targetPitch = 2.5
                local targetVolume = 2
                sfx:AdjustPitch(MattPack.Sounds.TechOmegaLoop, percent * targetPitch)
                sfx:AdjustVolume(MattPack.Sounds.TechOmegaLoop, percent * targetVolume)

                itemLayer:SetRotation(itemLayer:GetRotation() + data.spinCharge)
                itemLayer:SetPos((Vector(0, -17.5) + Vector.FromAngle(itemLayer:GetRotation() + 90):Resized(17.5)) + (targetOffset * percent))
                itemLayer:SetSize(Lerp(Vector.One, targetScale, percent))
                itemLayer:SetColor(Color.Lerp(Color(1,1,1,1), targetColor, percent))
            end
        end
    end
end
mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_RENDER, CallbackPriority.LATE, mod.devilsYoyoPedestalSpin, 100)
