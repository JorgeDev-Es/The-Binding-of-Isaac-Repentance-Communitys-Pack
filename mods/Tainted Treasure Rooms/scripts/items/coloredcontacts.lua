local mod = TaintedTreasure
local game = Game()
local sfx = SFXManager()
local rng = RNG()

function mod:RandomColor(maxoffset, customRNG) --Patented funny function
    local rand = customRNG or rng
    maxoffset = maxoffset or 0
    maxoffset = math.floor((maxoffset / 0.1) * 100)
    return Color(rand:RandomFloat(),rand:RandomFloat(),rand:RandomFloat(),1,mod:RandomInt(0,maxoffset,rand)/100,mod:RandomInt(0,maxoffset,rand)/100,mod:RandomInt(0,maxoffset,rand)/100)
end

function mod:ColoredContactsOnFireTear(tear, data)
    data.TaintedColoredContact = true
    data.ColoredContactProjectiles = {}
    data.ColoredContactDamage = tear.CollisionDamage / 2
    mod:TryConvertToBlueTear(tear)
end

function mod:ColoredContactsOnFireBomb(bomb, data)
    data.TaintedColoredContact = true
    data.ColoredContactProjectiles = {}
    data.ColoredContactDamage = bomb.ExplosionDamage / 2
end

function mod:ColoredContactTearUpdate(tear, data) --Shared logic for tears and Dr. Fetus bombs
    if data.TaintedPlayerRef and data.TaintedPlayerRef:Exists() then
        for _, proj in pairs(Isaac.FindByType(9)) do
            proj = proj:ToProjectile()
            if proj.Position:Distance(tear.Position) < proj.Size + tear.Size and (tear:ToBomb() or math.abs(tear.Height - proj.Height) <= 20) and not data.ColoredContactProjectiles[proj.InitSeed] then
                local offset = 0

                if tear:ToBomb() then --Bombs only
                    tear = tear:ToBomb()
                    tear.ExplosionDamage = tear.ExplosionDamage + (data.ColoredContactDamage * data.TaintedPlayerRef:GetCollectibleNum(TaintedCollectibles.COLORED_CONTACTS))
                    offset = 0.05
                else --Tears only
                    tear.CollisionDamage = tear.CollisionDamage + (data.ColoredContactDamage * data.TaintedPlayerRef:GetCollectibleNum(TaintedCollectibles.COLORED_CONTACTS))
                    if not data.ColoredContactBoosted then
                        tear.Velocity = tear.Velocity * 1.5
                    end
                    tear.Scale = tear.Scale + 0.05
                end

                data.ColoredContactProjectiles[proj.InitSeed] = true
                data.ColoredContactBoosted = true
                tear.Color = mod:RandomColor(offset, data.TaintedPlayerRef:GetCollectibleRNG(TaintedCollectibles.COLORED_CONTACTS))
                sfx:Play(SoundEffect.SOUND_SOUL_PICKUP, 0.2)
            end
        end
    end
end