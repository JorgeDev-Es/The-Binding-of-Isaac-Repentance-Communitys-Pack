local mod = FiendFolio
local game = Game()
local sfx = SFXManager()

local CUSTOM_PICKUPS = {}

function mod:getCustomPickupInfo(variant, subtype)
	if CUSTOM_PICKUPS[variant] then
		return CUSTOM_PICKUPS[variant][subtype or 0]
	end
end

function mod:addCustomPickup(variant, subtype, onPickupFunc, canPickupFunc, dropSound)
	if not CUSTOM_PICKUPS[variant] then
		CUSTOM_PICKUPS[variant] = {}
	end
	CUSTOM_PICKUPS[variant][subtype] = {
		OnPickupFunc = onPickupFunc,
		CanPickupFunc = canPickupFunc,
		DropSound = dropSound,
	}
	
	mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, mod.customPickupUpdate, variant)
	mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, mod.customPickupCollision, variant)
end

function mod:customPickupUpdate(pickup)
	local sprite = pickup:GetSprite()
	
	if sprite:IsFinished("Collect") then
		pickup:Remove()
	elseif sprite:IsPlaying("Collect") then
		pickup.Velocity = Vector.Zero
	elseif sprite:IsEventTriggered("DropSound") then
		local tab = mod:getCustomPickupInfo(pickup.Variant, pickup.SubType)
		if tab and tab.DropSound then
			sfx:Play(tab.DropSound)
		end
	end
end

local function canPickupCustomPickup(player, pickup)
	local tab = mod:getCustomPickupInfo(pickup.Variant, pickup.SubType)
	if tab and tab.CanPickupFunc then
		return tab.CanPickupFunc(player, pickup)
	end
	return true
end

local function triggerCustomPickup(player, pickup)
	local tab = mod:getCustomPickupInfo(pickup.Variant, pickup.SubType)
	if tab and tab.OnPickupFunc then
		tab.OnPickupFunc(player, pickup)
	end
end

function mod:customPickupCollision(pickup, collider)
	local player = collider:ToPlayer()
	
	if not player then return end
	
	local sprite = pickup:GetSprite()
	
	if sprite:GetAnimation() == "Collect" then
		return true
	end
	
	if not canPickupCustomPickup(player, pickup) then
		return pickup:IsShopItem()
	end
	
	if pickup:IsShopItem() then
		if pickup.Price == PickupPrice.PRICE_SPIKES then
			local tookDamage = player:TakeDamage(2, DamageFlag.DAMAGE_SPIKES | DamageFlag.DAMAGE_NO_PENALTIES, EntityRef(nil), 30)
			if not tookDamage then
				return true
			end
		elseif pickup.Price > player:GetNumCoins() then
			return true
		elseif pickup.Price > 0 then
			player:AddCoins(-1 * pickup.Price)
		end
		pickup.Price = 0
	end
	
	sprite:Play("Collect", true)
	triggerCustomPickup(player, pickup)
	pickup:Die()
	
	return true
end
