local mod = TaintedTreasure
local game = Game()
local sfx = SFXManager()

function mod:LeviathanPlayerLogic(player, data)
    local rng = player:GetCollectibleRNG(TaintedCollectibles.LEVIATHAN)

    if data.LeviathanSpew then
        data.LeviathanSpew = data.LeviathanSpew - 1
        if data.LeviathanSpew <= 0 then
            data.LeviathanSpew = nil
        else
            local isPiss = (rng:RandomFloat() <= 0.5)
            local tear = Isaac.Spawn(2,0,0,player.Position,RandomVector():Resized(mod:RandomInt(7,14,rng))+player.Velocity,player):ToTear()
            local effect = Isaac.Spawn(1000,43,0,player.Position+RandomVector():Resized(mod:RandomInt(0,20,rng)),Vector.Zero,player)
            if isPiss then
                tear:ChangeVariant(TearVariant.BLOOD)
                tear.Color = mod.ColorPeepPiss
                effect.Color = mod.ColorPeepPiss
            else
                local data = tear:GetData()
                local sprite = tear:GetSprite()
                local path = "gfx/projectiles/tear_poopy.png"
                sprite:ReplaceSpritesheet(0, path)
                sprite:LoadGraphics()
                data.CustomSplat = path
            end
            tear.FallingAcceleration = 2
            tear.FallingSpeed = mod:RandomInt(-20,-10,rng)
            sfx:Play(SoundEffect.SOUND_BLOODSHOOT)
        end
    end
end

function mod:LeviathanNewRoom(player, room)
    local rng = player:GetCollectibleRNG(TaintedCollectibles.LEVIATHAN)
    local savedata = mod.GetPersistentPlayerData(player)
    savedata.LeviathanRooms = savedata.LeviathanRooms or 10 --mod:RandomInt(15,30,rng)
    savedata.LeviathanHalfway = savedata.LeviathanHalfway or (savedata.LeviathanRooms / 3)
    if room:IsFirstVisit() and not room:IsClear() then
        if savedata.LeviathanRooms <= 0 then
            if not savedata.LeviathanPurified then
                savedata.LeviathanPurified = true
                player:GetData().LeviathanSpew = 150
                player:UseActiveItem(CollectibleType.COLLECTIBLE_LEMON_MISHAP, UseFlag.USE_NOANIM, -1)
                player:UsePill(PillEffect.PILLEFFECT_RELAX, 0, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_NOHUD)
                
                sfx:Stop(SoundEffect.SOUND_THUMBS_DOWN)
                sfx:Play(SoundEffect.SOUND_POOP_LASER, 1, 0, false, 0.6) 
                sfx:Play(SoundEffect.SOUND_SUPERHOLY)
                sfx:Play(SoundEffect.SOUND_FLUSH)
                sfx:Play(SoundEffect.SOUND_BOSS2INTRO_PIPES_TURNON)
                sfx:Play(SoundEffect.SOUND_BABY_HURT, 3, 0, false, 0.25)
                
                player:AddNullCostume(TaintedCostumes.LeviathanPurified)
                player:AddCacheFlags(CacheFlag.CACHE_ALL)
                player:EvaluateItems()
            end
        else
            local rand = mod:RandomInt(1,4,rng)
            if rand == 1 then
                if savedata.LeviathanRooms <= savedata.LeviathanHalfway then
                    player:UsePill(PillEffect.PILLEFFECT_RELAX, 2048, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_NOHUD)
                    sfx:Stop(SoundEffect.SOUND_THUMBSDOWN_AMPLIFIED)
                else
                    player:UsePill(PillEffect.PILLEFFECT_RELAX, 0, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER | UseFlag.USE_NOHUD)
                    sfx:Stop(SoundEffect.SOUND_THUMBS_DOWN)
                end
                sfx:Play(SoundEffect.SOUND_POOP_LASER)
                savedata.LeviathanRooms = savedata.LeviathanRooms - 1
            elseif rand == 2 then
                if savedata.LeviathanRooms <= savedata.LeviathanHalfway then
                    player:UseActiveItem(CollectibleType.COLLECTIBLE_FREE_LEMONADE, UseFlag.USE_NOANIM, -1)
                else
                    player:UseActiveItem(CollectibleType.COLLECTIBLE_LEMON_MISHAP, UseFlag.USE_NOANIM, -1)
                end 
                player:AnimateSad()
                sfx:Stop(SoundEffect.SOUND_THUMBS_DOWN)
                savedata.LeviathanRooms = savedata.LeviathanRooms - 1
            end
        end
    end
    --print(savedata.LeviathanRooms)
end