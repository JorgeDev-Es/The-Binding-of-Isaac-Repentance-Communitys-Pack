local mod = FiendFolio
local game = Game()
local sfx = SFXManager()
local nilvector = Vector.Zero

mod.RMSprite = Sprite()
mod.RMSprite:Load("gfx/effects/effect_ridiculous_metal.anm2", true)

local rmCombos = {
    {mod.Sounds.RMetalCombo11, mod.Sounds.RMetalCombo12, mod.Sounds.RMetalCombo13, mod.Sounds.RMetalCombo1Miss},
    {mod.Sounds.RMetalCombo21, mod.Sounds.RMetalCombo22, mod.Sounds.RMetalCombo23, mod.Sounds.RMetalCombo2Miss},
}

local rmBeatCounts = {
    {Weight = 20, Output = 4},
    {Weight = 10, Output = 6},
    {Weight = 5, Output = 8},
    {Weight = 2, Output = 12},
    {Weight = 1, Output = 16},
}

local rmPatterns = {
    --Regular
    function(timer)
        return timer % 12 == 0
    end,
    function(timer)
        return timer % 15 == 0
    end,
    function(timer)
        return timer % 18 == 0
    end,
    --Missing bits
    function(timer)
        return timer % 12 == 0 and timer % 48 ~= 0
    end,
    function(timer)
        return timer % 12 == 0 and timer % 36 ~= 24
    end,
    --Weirdos
    function(timer)
        if timer % 50 <= 30 then
            return timer % 15 == 0
        else
            return timer % 10 == 0
        end
    end,
}

function mod:ridiculousMetalNewRoom(player, d, savedata)
    if d.RidiculousMetalBoost then
        d.RidiculousMetalBoost = nil
        player:AddCacheFlags(CacheFlag.CACHE_ALL)
		player:EvaluateItems()
    end
    if player:HasTrinket(FiendFolio.ITEM.ROCK.RIDICULOUS_METAL) then        
        local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.RIDICULOUS_METAL)
        d.RidiculousMetal = d.RidiculousMetal or {}
        d.RidiculousMetal.Upcoming = {}
        d.RidiculousMetal.Combo = 0
        d.RidiculousMetal.Notes = 0
        d.RidiculousMetal.NoteOrbit = 0
        d.RidiculousMetal.CheckedLast = nil
        d.RidiculousMetal.AdditionalDist = 0
        local room = game:GetRoom()
        if room:IsClear() then
            d.RidiculousMetal.Count = 0
        else
            
            d.RidiculousMetal.Timer = 0
            d.RidiculousMetal.ComboSFX = {rng:RandomInt(#rmCombos) + 1, -1}

            d.RidiculousMetal.Pattern = rng:RandomInt(#rmPatterns) + 1
            --d.RidiculousMetal.Speed = 1 + math.random()
            if game:GetRoom():GetType() == RoomType.ROOM_BOSS then
                d.RidiculousMetal.Count = 16
            else
                d.RidiculousMetal.Count = mod.randomArrayWeightBased(rmBeatCounts, rng)
            end
            d.RidiculousMetal.RoomCount = d.RidiculousMetal.Count
        end
    end
end

local function getPlayerDPS(player)
    return (player.Damage * 30)/(player.MaxFireDelay + 1)
end

local function triggerRidiculousEnemyDamage(player, d)
    --Visual flair
    d.RidiculousMetal.ComboSFX = d.RidiculousMetal.ComboSFX or {1, -1}
    d.RidiculousMetal.ComboSFX[2] = (d.RidiculousMetal.ComboSFX[2] + 1) % 3
    sfx:Play(rmCombos[d.RidiculousMetal.ComboSFX[1]][d.RidiculousMetal.ComboSFX[2] + 1], 1, 0, false, 1)
    game:MakeShockwave(player.Position, 0.005, 0.025, 10)
    d.RidiculousMetal.Rockout = math.random(30,50)

    --Visual notes
    d.RidiculousMetal.Notes = d.RidiculousMetal.Notes or 0
    local note = Isaac.Spawn(1000, mod.FF.RidiculousMetalNote.Var, mod.FF.RidiculousMetalNote.Sub, player.Position, nilvector, player)
    note.Parent = player
    d.RidiculousMetal.Notes = d.RidiculousMetal.Notes + 1
    note:GetData().NotePosition = d.RidiculousMetal.Notes
    note:Update()

    --Enemy damage
    d.RidiculousMetal.Combo = d.RidiculousMetal.Combo or 0
    d.RidiculousMetal.Combo = d.RidiculousMetal.Combo + 1
    local damageAmount = (getPlayerDPS(player) / 8) * d.RidiculousMetal.Combo * FiendFolio.GetGolemTrinketPower(player, FiendFolio.ITEM.ROCK.RIDICULOUS_METAL)
    local room = game:GetRoom()
    for index,entity in ipairs(Isaac.FindInRadius(room:GetCenterPos(), 500, EntityPartition.ENEMY)) do
        local npc = entity:ToNPC()
        if npc then
            if not mod:isFriend(npc) and npc:IsVulnerableEnemy(npc) then
                npc:TakeDamage(damageAmount, 0, EntityRef(player), 0)
                mod:makeEnemyGib(npc)
            end
        end
    end
end

local roomCountToStatBonus = {
    [4] = 1,
    [6] = 2,
    [8] = 3,
    [12] = 4,
    [16] = 5,
}

function mod:ridiculouslyBoostStat(player, d)
    d.RidiculousMetalBoost = d.RidiculousMetalBoost or {0,0,0,0,0}
    local rng = player:GetTrinketRNG(FiendFolio.ITEM.ROCK.RIDICULOUS_METAL)
    local rand = rng:RandomInt(#d.RidiculousMetalBoost) + 1
    d.RidiculousMetalBoost[rand] = d.RidiculousMetalBoost[rand] + 1
    player:AddCacheFlags(CacheFlag.CACHE_ALL)
    player:EvaluateItems()
end

local function triggerRidiculousFinalNote(player, d)
    if not d.RidiculousMetal.CheckedLast then
        d.RidiculousMetal.CheckedLast = true
        
        if d.RidiculousMetal.Combo == d.RidiculousMetal.RoomCount then
            sfx:Play(mod.Sounds.CrowdCheer, 1, 0, false, math.random(80,120)/100)
            player:AnimateHappy()

            if d.RidiculousMetal.RoomCount >= 8 then
                player:UseActiveItem(CollectibleType.COLLECTIBLE_NECRONOMICON, false, false, true, false)
            end
            for i = 1, roomCountToStatBonus[d.RidiculousMetal.RoomCount] do
                mod:ridiculouslyBoostStat(player, d)
            end
        end
    end
end

function mod:ridiculousMetalPeffectUpdate(player, d)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.RIDICULOUS_METAL) then
        d.RidiculousMetal = d.RidiculousMetal or {}
        d.RidiculousMetal.Upcoming = d.RidiculousMetal.Upcoming or {}
        --d.RidiculousMetal.Speed = d.RidiculousMetal.Speed or 1
        d.RidiculousMetal.Timer = d.RidiculousMetal.Timer or 0
        d.RidiculousMetal.Timer = d.RidiculousMetal.Timer + 1
        d.RidiculousMetal.Pattern = d.RidiculousMetal.Pattern or 1

        if d.RidiculousMetal.Notes and d.RidiculousMetal.Notes > 0 then
            d.RidiculousMetal.NoteOrbit = d.RidiculousMetal.NoteOrbit or 0
            d.RidiculousMetal.NoteOrbit = (d.RidiculousMetal.NoteOrbit + 5) % 360
        end
        if d.RidiculousMetal.CheckedLast then
            d.RidiculousMetal.AdditionalDist = d.RidiculousMetal.AdditionalDist or 0
            d.RidiculousMetal.AdditionalDist = d.RidiculousMetal.AdditionalDist + 10
        end

        if d.RidiculousMetal.Count and d.RidiculousMetal.Count > 0 then
            --print(d.RidiculousMetal.Pattern)
            local addArrow = rmPatterns[d.RidiculousMetal.Pattern](d.RidiculousMetal.Timer)
            if addArrow then
                d.RidiculousMetal.Count = d.RidiculousMetal.Count - 1
                table.insert(d.RidiculousMetal.Upcoming, {
                    ArrowType = math.random(4),
                    Offset = 60,
                    Alpha = 0,
                    Order = d.RidiculousMetal.RoomCount - d.RidiculousMetal.Count
                })
            end
        end

        d.RidiculousMetal.Rockout = d.RidiculousMetal.Rockout or 0
        d.RidiculousMetal.Rockout = mod:Lerp(d.RidiculousMetal.Rockout, 0, 0.2)
        d.RidiculousMetal.GuitarAlpha = d.RidiculousMetal.GuitarAlpha or 0

        local aim = mod.GetGoodShootingJoystick(player):Length()
        local aimMin = 0.5
        --d.RidiculousMetal.AllowPress = d.RidiculousMetal.AllowPress or true
        if aim < aimMin then
            d.RidiculousMetal.AllowPress = true
        end

        if #d.RidiculousMetal.Upcoming > 0 then
            d.RidiculousMetal.GuitarAlpha = mod:Lerp(d.RidiculousMetal.GuitarAlpha, 1, 0.2)
            local removeArrows = {}
   
            local speed = 1 + ((mod:getFloorDepth() - 1)/10)
            for i = 1, #d.RidiculousMetal.Upcoming do
                d.RidiculousMetal.Upcoming[i].Offset = d.RidiculousMetal.Upcoming[i].Offset - speed
                d.RidiculousMetal.Upcoming[i].Offset = math.max(d.RidiculousMetal.Upcoming[i].Offset, 0)
                
                if d.RidiculousMetal.Upcoming[i].Offset == 0 then
                    if not d.RidiculousMetal.Upcoming[i].ZeroInit then
                        if not d.RidiculousMetal.Upcoming[i].Successful then
                            d.RidiculousMetal.Upcoming[i].Alpha = 1.5
                            d.RidiculousMetal.Upcoming[i].Scale = 1.5
                        end
                        d.RidiculousMetal.Upcoming[i].ZeroInit = true
                        sfx:Play(mod.Sounds.RMetalMetronome, 0.2, 0, false, 1)
                    end
                else
                    d.RidiculousMetal.Upcoming[i].Alpha = math.min(d.RidiculousMetal.Upcoming[i].Alpha + (0.1 * speed), 1)
                end

                if d.RidiculousMetal.Upcoming[i].Successful or d.RidiculousMetal.Upcoming[i].Offset == 0 then
                    if d.RidiculousMetal.Upcoming[i].Scale then
                        d.RidiculousMetal.Upcoming[i].Scale = d.RidiculousMetal.Upcoming[i].Scale - (0.1 * speed)
                    end
                    if d.RidiculousMetal.Upcoming[i].Alpha then
                        d.RidiculousMetal.Upcoming[i].Alpha = math.max(d.RidiculousMetal.Upcoming[i].Alpha - (0.1 * speed), 0)
                        if d.RidiculousMetal.Upcoming[i].Alpha == 0 then
                            table.insert(removeArrows, 1, i)
                            if not d.RidiculousMetal.Upcoming[i].Successful then
                                d.RidiculousMetal.Combo = 0
                            end
                            if d.RidiculousMetal.Upcoming[i].Order == d.RidiculousMetal.RoomCount then
                                 triggerRidiculousFinalNote(player, d)
                            end
                        end
                    end
                end

                if d.RidiculousMetal.Upcoming[i].Alpha > 0.8 then
                    if not d.RidiculousMetal.Upcoming[i].Successful then
                        if d.RidiculousMetal.AllowPress and d.RidiculousMetal.Upcoming[i].Offset < 8 then
                            if aim > aimMin then
                                d.RidiculousMetal.AllowPress = false
                                if d.RidiculousMetal.Upcoming[i].Offset < 4 and d.RidiculousMetal.Upcoming[i].Alpha >= 1 then
                                    if not d.RidiculousMetal.Upcoming[i].Successful then
                                        d.RidiculousMetal.Upcoming[i].Scale = 1.5
                                        d.RidiculousMetal.Upcoming[i].Alpha = 1.5
                                        d.RidiculousMetal.Upcoming[i].Successful = true
                                        d.RidiculousMetal.Upcoming[i].HitEnemy = true
                                        triggerRidiculousEnemyDamage(player, d)
                                        if d.RidiculousMetal.Upcoming[i].Order == d.RidiculousMetal.RoomCount then
                                            triggerRidiculousFinalNote(player, d)
                                        end

                                    end
                                else
                                    d.RidiculousMetal.ComboSFX = d.RidiculousMetal.ComboSFX or {1, -1}
                                    sfx:Play(rmCombos[d.RidiculousMetal.ComboSFX[1]][4], 1, 0, false, 1)
                                    d.RidiculousMetal.Upcoming[i].Successful = true
                                    d.RidiculousMetal.Upcoming[i].Scale = math.min(d.RidiculousMetal.Upcoming[i].Scale or 1, 1)
                                    d.RidiculousMetal.Upcoming[i].Alpha = math.min(d.RidiculousMetal.Upcoming[i].Alpha or 1, 1)
                                    d.RidiculousMetal.Combo = 0
                                    d.RidiculousMetal.Notes = d.RidiculousMetal.Notes or 0

                                    local note = Isaac.Spawn(1000, mod.FF.RidiculousMetalNote.Var, mod.FF.RidiculousMetalNote.Sub, player.Position, RandomVector(), player)
                                    note.Parent = player
                                    note:GetData().missedNote = 1
                                    note:Update()
                                    if d.RidiculousMetal.Upcoming[i].Order == d.RidiculousMetal.RoomCount then
                                        triggerRidiculousFinalNote(player, d)
                                    end
                                end
                            end
                        end
                    end
                elseif d.RidiculousMetal.Upcoming[i].Offset == 0 then
                    if not d.RidiculousMetal.Upcoming[i].Successful then
                        d.RidiculousMetal.Upcoming[i].Successful = true
                        d.RidiculousMetal.Combo = 0
                    end
                end
            end
            if #removeArrows > 0 then
                for i = 1, #removeArrows do
                    table.remove(d.RidiculousMetal.Upcoming, removeArrows[i])
                end
            end
        else
            d.RidiculousMetal.GuitarAlpha = mod:Lerp(d.RidiculousMetal.GuitarAlpha, 0, 0.2)
        end
    elseif d.RidiculousMetal then
        d.RidiculousMetal = nil
    end
end

function mod:ridiculousMetalPlayerRender(player, renderOffset, d)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.RIDICULOUS_METAL) then
        if mod.WaterRenderModes[game:GetRoom():GetRenderMode()] then return end

        if d.RidiculousMetal and d.RidiculousMetal.Upcoming then
            --Guitar
            mod.RMSprite.FlipX = false
            d.RidiculousMetal.Rockout = d.RidiculousMetal.Rockout or 0
            mod.RMSprite.Color = Color(1,1,1,d.RidiculousMetal.GuitarAlpha)
            mod.RMSprite.Scale = player.SpriteScale
            mod.RMSprite:SetFrame("Rock", 0)
            mod.RMSprite.Rotation = d.RidiculousMetal.Rockout
            local pos = player.Position + Vector(5, -10)
            local renderpos = Isaac.WorldToRenderPosition(pos) + game:GetRoom():GetRenderScrollOffset()
            mod.RMSprite:Render(renderpos, nilvector, nilvector)
            --Necrodancer
            mod.RMSprite.Rotation = 0
            mod.RMSprite:SetFrame("Bar", 0)
            local pos = player.Position + Vector(0, 20)
            local renderpos = Isaac.WorldToRenderPosition(pos) + game:GetRoom():GetRenderScrollOffset()
            mod.RMSprite:Render(renderpos, nilvector, nilvector)

            mod.RMSprite:SetFrame("Line", 0)
            for i = 1, #d.RidiculousMetal.Upcoming do
                for offset = -1, 1, 2 do
                    local arrowAlpha = d.RidiculousMetal.Upcoming[i].Alpha or 1
                    local arrowScale = d.RidiculousMetal.Upcoming[i].Scale or 1
                    if not d.RidiculousMetal.Upcoming[i].HitEnemy then
                        arrowAlpha = math.min(arrowAlpha, 1)
                        arrowScale = math.min(arrowScale, 1)
                    end
                    mod.RMSprite.Color = Color(arrowAlpha,arrowAlpha,arrowAlpha,arrowAlpha)
                    mod.RMSprite.Scale = player.SpriteScale * arrowScale
                    if offset == 1 then
                        mod.RMSprite.FlipX = true
                    else
                        mod.RMSprite.FlipX = false
                    end
                    local pos = player.Position + Vector(0, 20) + Vector(d.RidiculousMetal.Upcoming[i].Offset * offset, 0)
                    local renderpos = Isaac.WorldToRenderPosition(pos) + game:GetRoom():GetRenderScrollOffset()
                    mod.RMSprite:Render(renderpos, nilvector, nilvector)
                end
            end
            if d.RidiculousMetal.Combo and d.RidiculousMetal.Combo > 0 then
                local pos = game:GetRoom():WorldToScreenPosition(player.Position) + Vector(mod.TempestFont:GetStringWidth(d.RidiculousMetal.Combo) * -0.5, 0) + Vector(0, 20)
                mod.TempestFont:DrawString(d.RidiculousMetal.Combo, pos.X, pos.Y, KColor(113/256,195/256,57/256,math.min(1, d.RidiculousMetal.GuitarAlpha * d.RidiculousMetal.Combo/5)), 0, false)
            end
        end
    end
end

function mod:ridiculousMetalNoteAI(e)
    local d, sprite = e:GetData(), e:GetSprite()
    if not e.Parent then
        e.Parent = Isaac.GetPlayer()
        local pd = e.Parent:GetData()
        pd.RidiculousMetal = pd.RidiculousMetal or {}
        pd.RidiculousMetal.Notes = pd.RidiculousMetal.Notes or 0
        pd.RidiculousMetal.Notes = pd.RidiculousMetal.Notes + 1
        d.NotePosition = pd.RidiculousMetal.Notes
        --[[d.missedNote = 1
        e.Velocity = RandomVector()]]
    end
    if e.Parent then
        sprite:SetFrame("Note", d.missedNote or 0)
        local pd = e.Parent:GetData()
        if not pd.RidiculousMetal then
            e:Remove()
        elseif d.missedNote then
            e.Velocity = e.Velocity:Resized(5)
            e.SpriteOffset = Vector(0, -15 - math.abs(math.cos(e.FrameCount/5) * 30 * (1 - e.FrameCount/90)))
            e.Color = Color(1,1,1,1 - e.FrameCount/15)
            if e.FrameCount > 15 then
                e:Remove()
            end
        elseif pd.RidiculousMetal.NoteOrbit then
            e.Color = Color(1,1,1,1,-0.5 + math.sin(game:GetRoom():GetFrameCount()/50),-0.5 + math.sin(game:GetRoom():GetFrameCount()/50) * -1, -0.5 + math.sin(game:GetRoom():GetFrameCount()/25), 1)
            e.SpriteOffset = Vector(0, -15)
            local orbitPos = pd.RidiculousMetal.NoteOrbit + (d.NotePosition * (360 / pd.RidiculousMetal.Notes))
            local targAng = Vector(50 + pd.RidiculousMetal.AdditionalDist or 0,0):Rotated(orbitPos)
            local targPos = e.Parent.Position + targAng

            local tilt = (targPos - Vector(50,0)).X / 80
            local oscillate = math.cos(game:GetRoom():GetFrameCount() * 0.1) * 5
            targPos = targPos + Vector(0, tilt * oscillate)
            
            local vec = (targPos - e.Position) * 0.5
            if vec:Length() > 15 then
                vec:Resized(15)
            end
            e.Velocity = mod:Lerp(vec, e.Velocity, 0.1)

            if pd.RidiculousMetal.AdditionalDist then
                if pd.RidiculousMetal.AdditionalDist > 1000 then
                    e:Remove()
                end
            end
        end
    else
        e:Remove()
    end
end

--Initial prototype
--[[
function mod:ridiculousMetalPeffectUpdate(player, d)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.RIDICULOUS_METAL) then
        d.RidiculousMetal.Upcoming = d.RidiculousMetal.Upcoming or {}
        if player.FrameCount % 10 == 0 then
            table.insert(d.RidiculousMetal.Upcoming, {
                ArrowType = math.random(4),
                Offset = 60,
                Alpha = 0
            })
        end
        if #d.RidiculousMetal.Upcoming > 0 then
            local removeArrows = {}
            local speed = 3
            for i = 1, #d.RidiculousMetal.Upcoming do
                d.RidiculousMetal.Upcoming[i].Offset = d.RidiculousMetal.Upcoming[i].Offset - speed
                if d.RidiculousMetal.Upcoming[i].Offset < -30 then
                    table.insert(removeArrows, 1, i)
                elseif d.RidiculousMetal.Upcoming[i].Offset > -10 then
                    d.RidiculousMetal.Upcoming[i].Alpha = math.min(d.RidiculousMetal.Upcoming[i].Alpha + (0.1 * speed), 1)
                else
                    d.RidiculousMetal.Upcoming[i].Alpha = math.max(d.RidiculousMetal.Upcoming[i].Alpha - (0.05 * speed), 0)
                end
            end
            if #removeArrows > 0 then
                for i = 1, #removeArrows do
                    table.remove(d.RidiculousMetal.Upcoming, removeArrows[i])
                end
            end
        end
    end
end

local arrowBaseDetails = {
    [1] = {Position = Vector(-61, 0), Rotation = -90},
    [2] = {Position = Vector(-35, 0), Rotation = 180},
    [3] = {Position = Vector(35, 0), Rotation = 0},
    [4] = {Position = Vector(61, 0), Rotation = 90},
}

function mod:ridiculousMetalPlayerRender(player, offset, d)
    if player:HasTrinket(FiendFolio.ITEM.ROCK.RIDICULOUS_METAL) then
        mod.RMSprite:SetFrame("ArrowOutline", 0)
        mod.RMSprite.Color = Color(1,1,1,1)
        for i = 1, #arrowBaseDetails do
            mod.RMSprite.Rotation = arrowBaseDetails[i].Rotation
            local pos = player.Position + Vector(0, -25) + arrowBaseDetails[i].Position
            local renderpos = Isaac.WorldToRenderPosition(pos) + game:GetRoom():GetRenderScrollOffset()
            mod.RMSprite:Render(renderpos, nilvector, nilvector)
        end
        if d.RidiculousMetal.Upcoming then
            mod.RMSprite:SetFrame("ArrowFull", 0)
            for i = 1, #d.RidiculousMetal.Upcoming do
                mod.RMSprite.Color = Color(1,1,1,d.RidiculousMetal.Upcoming[i].Alpha)
                mod.RMSprite.Rotation = arrowBaseDetails[d.RidiculousMetal.Upcoming[i].ArrowType].Rotation
                local pos = player.Position + Vector(0, -25) + arrowBaseDetails[d.RidiculousMetal.Upcoming[i].ArrowType].Position + Vector(0, d.RidiculousMetal.Upcoming[i].Offset)
                local renderpos = Isaac.WorldToRenderPosition(pos) + game:GetRoom():GetRenderScrollOffset()
                mod.RMSprite:Render(renderpos, nilvector, nilvector)
            end
        end
    end
end
]]