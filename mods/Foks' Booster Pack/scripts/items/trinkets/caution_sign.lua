local mod = _FOKS_BOOSTER_PACK_MOD
local game = Game()
local sfx = SFXManager()

local EXPLOSION_DAMAGE = 185

mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, function(_, npc)
	local trinketMult = PlayerManager.GetTotalTrinketMultiplier(mod.Trinket.CAUTION_SIGN)
	
	if trinketMult > 0 and mod.IsLastVulnerableEnemy(npc) then
		local damageFlags = DamageFlag.DAMAGE_EXPLOSION | DamageFlag.DAMAGE_NO_PENALTIES | DamageFlag.DAMAGE_IGNORE_ARMOR
		local tearFlags = TearFlags.TEAR_NORMAL
		
		if trinketMult > 1 then
			tearFlags = tearFlags | TearFlags.TEAR_CROSS_BOMB
		end
		game:BombExplosionEffects(npc.Position, EXPLOSION_DAMAGE, tearFlags, nil, nil, nil, nil, nil, damageFlags)
	end
end)

--------------------
-- << RENDERER >> --
--------------------
local indicatorSpr = Sprite("gfx/ui/indicator_cautionsign.anm2")

mod:AddCallback(ModCallbacks.MC_POST_NPC_RENDER, function(_, npc, offset)
	if game:GetRoom():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then return end
	
	if PlayerManager.AnyoneHasTrinket(mod.Trinket.CAUTION_SIGN) and mod.IsLastVulnerableEnemy(npc) then
		local nullFrame = npc:GetSprite():GetNullFrame("OverlayEffect")
		
		if nullFrame and nullFrame:IsVisible() then
			local xOffset, yOffset = 0, math.sin(npc.FrameCount * 0.1) * 3
			
			indicatorSpr:Render(Isaac.GetRenderPosition(npc.Position + npc.PositionOffset) + nullFrame:GetPos() + offset + Vector(xOffset, yOffset))
			indicatorSpr:Play("Idle")
		end
	end
end)