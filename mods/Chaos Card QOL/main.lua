ChaosCardQOL = RegisterMod("[REP(+)] Chaos Card QOL", 1)
local mod = ChaosCardQOL

--Stolen from Controlled Chaos
function mod:HasCard(player, card)
	for i=0,3 do
		if player:GetCard(i) == card then return true end
	end
	return false
end

--This one too
function mod:RemoveCard(player, card)
	if player:GetCard(1) == card then
		player:SetCard(1,Card.CARD_NULL)
		return true
	elseif player:GetCard(0) == card then
		local otherCard = player:GetCard(1)
		local otherPill = player:GetPill(1)
		if otherCard > 0 then
			player:SetCard(0,otherCard)
			player:SetCard(1,Card.CARD_NULL)
		elseif otherPill > 0 then
			player:SetPill(0,otherPill)
			player:SetCard(1,Card.CARD_NULL)
		else
			player:SetCard(0,Card.CARD_NULL)
		end
		return true
	end
	return false
end

--And this one
local CancelENSpawn = {frame=-2,players={}}
mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, function(_, pickup)
	if pickup.SubType ~= Card.CARD_CHAOS then return end
	if Game():GetFrameCount() > CancelENSpawn.frame then return end
	for _,player in pairs(CancelENSpawn.players) do
		if pickup.SpawnerEntity and GetPtrHash(player) == GetPtrHash(pickup.SpawnerEntity) then pickup:Remove() end
	end
end, PickupVariant.PICKUP_TAROTCARD)

mod:AddCallback(ModCallbacks.MC_USE_CARD, function(_, c, p, flags)
  if flags & UseFlag.USE_CARBATTERY > 0 then return end
  local BlankCard = (flags & UseFlag.USE_MIMIC > 0) and (flags & UseFlag.USE_NOHUD == 0)
  local EchoChamber = flags & UseFlag.USE_OWNED == 0 and not BlankCard
	
  local d = p:GetData()
  if d.HoldingChaosCard and not (EchoChamber or BlankCard) then
    mod:ScheduleForUpdate( function()
      d.HoldingChaosCard = nil
      d.HoldingChaosCardFree = nil
      p:AnimateCard(42, "HideItem")
    end, 2)
  else
    mod:ScheduleForUpdate( function()
      if not d.HoldingChaosCard then
        p:StopExtraAnimation()
        p:ResetItemState()
        d.HoldingChaosCard = true
        if BlankCard or EchoChamber then d.HoldingChaosCardFree = true end
        p:AnimateCard(42, "LiftItem")
      end
    end, 1)
  end
    
  if not (EchoChamber or BlankCard) then
    p:AddCard(Card.CARD_CHAOS)
		if p:HasTrinket(TrinketType.TRINKET_ENDLESS_NAMELESS) then
			if Game():GetFrameCount() > CancelENSpawn.frame then
				CancelENSpawn = {frame=Game():GetFrameCount(), players={}}
			end
			table.insert(CancelENSpawn.players, p)
    end
  end
  for _, v in pairs(Isaac.FindByType(EntityType.ENTITY_TEAR, TearVariant.CHAOS_CARD)) do
    if v.FrameCount == 0 and v.SpawnerEntity and GetPtrHash(v.SpawnerEntity) == GetPtrHash(p) then v:Remove() end
  end
  if SFXManager():IsPlaying(SoundEffect.SOUND_CHAOS_CARD) then
    SFXManager():Stop(SoundEffect.SOUND_CHAOS_CARD)
  end
end, Card.CARD_CHAOS)

mod:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE, function(_, p)
  local d = p:GetData()
  if d.HoldingChaosCard then
    if p:GetItemState() ~= 0 or p:IsExtraAnimationFinished() then
      d.HoldingChaosCard = nil
      d.HoldingChaosCardFree = nil
      return
    end
    if not mod:HasCard(p, 42) and not d.HoldingChaosCardFree then
      d.HoldingChaosCard = nil
      p:AnimateCard(42, "HideItem")
      return
    end
    local aim = p:GetAimDirection()
    if aim:Length() > 0.5 then
      aim = aim:Normalized()
      
      Isaac.Spawn(EntityType.ENTITY_TEAR, TearVariant.CHAOS_CARD, 0, p.Position, aim:Resized(10) + p:GetTearMovementInheritance(aim), p)
			
      if not d.HoldingChaosCardFree then
        mod:RemoveCard(p, 42)
  			local rand = p:GetTrinketRNG(TrinketType.TRINKET_ENDLESS_NAMELESS):RandomFloat()
  			if p:HasTrinket(TrinketType.TRINKET_ENDLESS_NAMELESS) and rand < 0.25 then
          local pos = Game():GetRoom():FindFreePickupSpawnPosition(p.Position, 0, true)
  				Isaac.Spawn(5, 300, 42, pos, Vector.Zero, p)
  			end
  			if Options.AnnouncerVoiceMode == 2 or (Options.AnnouncerVoiceMode == 0 and math.random(2) == 1) then
  				SFXManager():Play(SoundEffect.SOUND_CHAOS_CARD)
  			end
      end

      d.HoldingChaosCard = nil
      d.HoldingChaosCardFree = nil
      p:AnimateCard(42, "HideItem")
    end
  end
end)




--Stolen from Fiend Folio
DelayedFuncs = {}
local function RunUpdates(tab)
  	for i = #tab, 1, -1 do
    		local f = tab[i]
    		f.Delay = f.Delay - 1
    		if f.Delay <= 0 then
      			f.Func()
      			table.remove(tab, i)
    		end
  	end
end
function mod:ScheduleForUpdate(foo, delay, callback, noCancelOnNewRoom)
  	callback = callback or ModCallbacks.MC_POST_UPDATE
  	if not DelayedFuncs[callback] then
    		DelayedFuncs[callback] = {}
    		mod:AddCallback(callback, function()
    		    RunUpdates(DelayedFuncs[callback])
    		end)
  	end
  	table.insert(DelayedFuncs[callback], { Func = foo, Delay = delay or 0, NoCancel = noCancelOnNewRoom })
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, CallbackPriority.IMPORTANT, function()
  	for callback, tab in pairs(DelayedFuncs) do
    		for i = #tab, 1, -1 do
      			local f = tab[i]
      			if not f.NoCancel then
                table.remove(tab, i)
      			end
    		end
  	end
end)

--PRAYING THAT THIS DOESN'T BRAKES ANYTHING
local META, META0

local function BeginClass(T)
	META = {}
	if type(T) == "function" then
		META0 = getmetatable(T())
	else
		META0 = getmetatable(T).__class
	end
end

local function EndClass()
	local oldIndex = META0.__index
	local newMeta = META
	
	rawset(META0, "__index", function(self, k)
		return newMeta[k] or oldIndex(self, k)
	end)
end

BeginClass(EntityPlayer)

local originalResetItemState = META0.ResetItemState

function META.ResetItemState(self)
  if self:GetData().HoldingChaosCard then
  	self:GetData().HoldingChaosCard = nil
  	self:GetData().HoldingChaosCardFree = nil
  	self:AnimateCard(42, "HideItem")
  end
	return originalResetItemState(self)
end

EndClass()