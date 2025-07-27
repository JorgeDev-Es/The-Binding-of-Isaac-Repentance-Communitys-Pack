local mod = TaintedTreasure
local game = Game()
local rng = RNG()
mod.overchargedbarsprite = Sprite()

--SANIO RENDERACTIVE CODE
local renderActive = {}

local function GetScreenBottomRight()
	local hudOffset = Options.HUDOffset
	local offset = Vector(-hudOffset * 16, -hudOffset * 6)

	return Vector(Isaac.GetScreenWidth(), Isaac.GetScreenHeight()) + offset
end

local function GetScreenBottomLeft()
	local hudOffset = Options.HUDOffset
	local offset = Vector(hudOffset * 22, -hudOffset * 6)

	return Vector(0, Isaac.GetScreenHeight()) + offset
end

local function GetScreenTopRight()
	local hudOffset = Options.HUDOffset
	local offset = Vector(-hudOffset * 24, hudOffset * 12)
	
	return Vector(Isaac.GetScreenWidth(), 0) + offset
end

local function GetScreenTopLeft()
	local hudOffset = Options.HUDOffset
	local offset = Vector(hudOffset * 20, hudOffset * 12)

	return Vector.Zero + offset
end

---@param player EntityPlayer
---@param itemID CollectibleType
local function GetActiveSlots(player, itemID)
	local slots = {}
	for i = 0, 3 do
		if player:GetActiveItem(i) == itemID then
			table.insert(slots, i)
		end
	end
	return slots
end

---@return EntityPlayer[]
local function GetAllMainPlayers()
	local players = {}
	for i = 0, Game():GetNumPlayers() - 1 do
		if Isaac.GetPlayer(i):GetMainTwin():GetPlayerType() == Isaac.GetPlayer(i):GetPlayerType()
			--Is the main twin of 2 players
			and (not Isaac.GetPlayer(i).Parent or Isaac.GetPlayer(i).Parent.Type ~= EntityType.ENTITY_PLAYER) then --Not an item-related spawned-in player.
			table.insert(players, Isaac.GetPlayer(i))
		end
	end
	return players
end

---@param player EntityPlayer
---@return boolean
local function IsJudasBirthrightActive(player)
	local playerType = player:GetPlayerType()
	return (playerType == PlayerType.PLAYER_JUDAS or playerType == PlayerType.PLAYER_BLACKJUDAS) and
		player:HasCollectible(CollectibleType.COLLECTIBLE_BIRTHRIGHT)
end

---@param player EntityPlayer
---@return integer
local function GetBookState(player)
	local hasVirtues = player:HasCollectible(CollectibleType.COLLECTIBLE_BOOK_OF_VIRTUES)
	local hasBelial = IsJudasBirthrightActive(player)
	local bookState = (hasVirtues and hasBelial) and 2 or
		(hasVirtues or hasBelial) and 1 or 0

	return bookState
end

local numHUDPlayers = 1
local hasLoadedItems = false

---@type table<integer, {Player: EntityPlayer, ScreenPos: function, Offset: table<ActiveSlot, Vector>}>
local IndexedPlayers = {
	[1] = {
		Player = nil,
		ScreenPos = function() return GetScreenTopLeft() end,
		Offset = {
			[ActiveSlot.SLOT_PRIMARY] = Vector(4, 0),
			[ActiveSlot.SLOT_SECONDARY] = Vector(-5, 0),
		}
	},
	[2] = {
		Player = nil,
		ScreenPos = function() return GetScreenTopRight() end,
		Offset = {
			[ActiveSlot.SLOT_PRIMARY] = Vector(-155, 0),
			[ActiveSlot.SLOT_SECONDARY] = Vector(-164, 0),
		}
	},
	[3] = {
		Player = nil,
		ScreenPos = function() return GetScreenBottomLeft() end,
		Offset = {
			[ActiveSlot.SLOT_PRIMARY] = Vector(14, -39),
			[ActiveSlot.SLOT_SECONDARY] = Vector(5, -39)
		}
	},
	[4] = {
		Player = nil,
		Offset = {
			[ActiveSlot.SLOT_PRIMARY] = Vector(-36, -39),
			[ActiveSlot.SLOT_SECONDARY] = Vector(-10, -39),
		},
		ScreenPos = function() return GetScreenBottomRight() end,
	}
}

---@type table<CollectibleType, {Sprite: Sprite, Directory: string, StartFrame: integer, UpdatedFrame?: function, Condition?: function}>
local activesToRender = {
	[TaintedCollectibles.OVERCHARGED_BATTERY] = { --Entry for one collectible.
		Sprite = mod.overchargedbarsprite,
		Directory = "gfx/ui/ui_overchargedchargebar.anm2",
		StartFrame = 0,
		UpdatedFrame = function(player) --If you want to update what frame your animation is on
			return mod.GetPersistentPlayerData(player).TaintedOvercharge or 0
		end,
		Condition = function(player, activeSlot) --If you want to make a condition for it to render at all
			local id = player:GetActiveItem(activeSlot)
			return id ~= 0 and Isaac.GetItemConfig():GetCollectible(id).MaxCharges > 0
		end
	},
}

---@param i integer
---@param player EntityPlayer
local function AddActivePlayers(i, player)

	IndexedPlayers[i].Player = player
	
	if i == 1
		and player:GetOtherTwin() ~= nil
		and player:GetOtherTwin():GetPlayerType() == PlayerType.PLAYER_ESAU
		and IndexedPlayers[4].Player == nil then
		IndexedPlayers[4].Player = player:GetOtherTwin()
	end
end

local function LoadItemSprites()
	for _, params in pairs(activesToRender) do
		params.Sprite:Load(params.Directory, true)
		params.Sprite:Play(params.Sprite:GetDefaultAnimation(), true)
		params.Sprite:SetFrame(params.Sprite:GetDefaultAnimation(), params.StartFrame)
	end
end

function renderActive:UpdatePlayers()
	local players = GetAllMainPlayers()

	if #players ~= numHUDPlayers
		or (Game():GetFrameCount() == 0 and IndexedPlayers[1].Player ~= nil)
	then
		numHUDPlayers = #players
		for i = 1, 4 do
			IndexedPlayers[i].Player = nil
		end
	end

	for i = 1, #players do
		if i > 4 then break end

		local player = players[i]

		if IndexedPlayers[i].Player == nil then
			AddActivePlayers(i, player)
		end
	end
end

function renderActive:RenderActiveItem()
	for i = 1, #IndexedPlayers do
		local activeItemPlayer = IndexedPlayers[i]

		if hasLoadedItems == false then
			LoadItemSprites()
			hasLoadedItems = true
		elseif activeItemPlayer
			and activeItemPlayer.Player ~= nil
			and activeItemPlayer.Player:Exists()
			and Game():GetHUD():IsVisible()
		then
			local player = activeItemPlayer.Player
			for itemID, params in pairs(activesToRender) do
				
				if player:HasCollectible(itemID) and player.Variant == 0 then
					if ((params.Condition == nil) or (params.Condition ~= nil and params.Condition(player, ActiveSlot.SLOT_PRIMARY) == true)) then
						local pos = activeItemPlayer.ScreenPos() +
							(activeItemPlayer.Offset[ActiveSlot.SLOT_PRIMARY] or activeItemPlayer.Offset[ActiveSlot.SLOT_PRIMARY])
						local size = 1
						local bookOffset = GetBookState(player) > 0 and -4 or 0
						if params.UpdatedFrame then
							params.Sprite:SetFrame(params.UpdatedFrame(player))
						end
						params.Sprite.Scale = Vector(size, size)
						if pos.X > 450 then
							pos = pos + Vector(-2, 17)
							params.Sprite.Scale = Vector(-size, size)
						else
							pos = pos + Vector(34, 17)
						end
						params.Sprite:Render(Vector(pos.X, pos.Y + bookOffset), Vector.Zero, Vector.Zero)
					end
				end
			end
		end
	end
end

--MC_POST_RENDER
function renderActive:OnRender()
	if mod:GetPlayersHoldingCollectible(TaintedCollectibles.OVERCHARGED_BATTERY) then
		renderActive:UpdatePlayers()
		renderActive:RenderActiveItem()
	end
end

--MC_GET_SHADER_PARAMS
--Use blank shader that renders above HUD
function renderActive:OnGetShaderParams(shaderName)
	if shaderName == "ModNameHereProbably-RenderAboveHUD" then
		renderActive:RenderActiveItem()
	end
end

function renderActive:ResetOnGameStart()
	for i = 1, 4 do
		IndexedPlayers[i].Player = nil
	end
end
--END OF RENDERACTIVE CODE


mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, function(_)
	local players = mod:GetPlayersHoldingCollectible(TaintedCollectibles.OVERCHARGED_BATTERY)
	if players then
		for i, player in pairs(players) do
			local savedata = mod.GetPersistentPlayerData(player)
			savedata.TaintedOvercharge = savedata.TaintedOvercharge or 0
			local item = Isaac.GetItemConfig():GetCollectible(player:GetActiveItem())
			if savedata.TaintedOvercharge < 3 and player:GetActiveItem() ~= 0 and item.MaxCharges > 0 and not savedata.TaintedNeededCharge then
				local charges = 1
				if game:GetRoom():GetRoomShape() >= 8 then
					charges = 2
				end
				savedata.TaintedOvercharge = savedata.TaintedOvercharge + charges
				SFXManager():Play(SoundEffect.SOUND_BEEP, 1, 2, false, 1.5)
				if savedata.TaintedOvercharge == 3 then
					player:AddNullCostume(TaintedCostumes.OverchargedBattery)
					SFXManager():Play(SoundEffect.SOUND_REDLIGHTNING_ZAP_WEAK, 1)
				end
			end
		end
	end
end)

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, type, rng, player)
	local savedata = mod.GetPersistentPlayerData(player)
	savedata.TaintedOvercharge = savedata.TaintedOvercharge or 0
	savedata.TaintedNeededCharge = true
	if player:HasCollectible(TaintedCollectibles.OVERCHARGED_BATTERY) and savedata.TaintedOvercharge > 2 then
		savedata.TaintedOvercharge = 0
		player:TryRemoveNullCostume(TaintedCostumes.OverchargedBattery)
		player:GetData().TaintedOverchargeSparks = 20
	end
end)

mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, function(_, pickup, collider)
	local player = collider:ToPlayer()
	if player then
		if player:HasCollectible(TaintedCollectibles.OVERCHARGED_BATTERY) then
			local savedata = mod.GetPersistentPlayerData(player)
			local item = Isaac.GetItemConfig():GetCollectible(player:GetActiveItem())
			savedata.TaintedOvercharge = savedata.TaintedOvercharge or 0
			if savedata.TaintedOvercharge < 3 and player:GetActiveItem() ~= 0 and item.MaxCharges > 0 and not player:NeedsCharge() and not pickup:GetSprite():IsPlaying() then
				if pickup.SubType == BatterySubType.BATTERY_MICRO then
					savedata.TaintedOvercharge = savedata.TaintedOvercharge + 2
				else
					savedata.TaintedOvercharge = 3
				end
				pickup:GetSprite():Play("Collect")
				pickup.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
				SFXManager():Play(SoundEffect.SOUND_BATTERYCHARGE, 1, 2, false, 1.2)
				mod:scheduleForUpdate(function()
					pickup:Remove()
				end, 4)
				if savedata.TaintedOvercharge >= 3 then
					savedata.TaintedOvercharge = 3
					player:AddNullCostume(TaintedCostumes.OverchargedBattery)
					SFXManager():Play(SoundEffect.SOUND_REDLIGHTNING_ZAP_WEAK, 1)
				end
			end
		end
	end
end, PickupVariant.PICKUP_LIL_BATTERY)

function mod:OverchargedBatteryPlayerLogic(player, data)
	if player:HasCollectible(TaintedCollectibles.OVERCHARGED_BATTERY) and data.TaintedOverchargeSparks and data.TaintedOverchargeSparks > 0 and game:GetFrameCount() % mod:RandomInt(1, 4) == 0 then
		local laser = Isaac.Spawn(EntityType.ENTITY_LASER, 10, 0, player.Position, RandomVector():Resized(mod:RandomInt(10,15))+player.Velocity, player):ToLaser()
		local closestenemy = nil
        local dist = 9999
        for _, entity in pairs(Isaac.FindInRadius(player.Position, 1000)) do
            if entity:IsEnemy() and not entity:HasEntityFlags(EntityFlag.FLAG_NO_TARGET) then
                if player.Position:Distance(entity.Position) < dist then
                    closestenemy = entity
                    dist = player.Position:Distance(entity.Position)
                end
            end
        end
		if closestenemy and mod:RandomInt(1, 4) == 1 then
			laser.Velocity = (closestenemy.Position-player.Position):Resized(mod:RandomInt(10,15))+Vector(mod:RandomInt(-2, 2), mod:RandomInt(-2, 2))+player.Velocity
		end
		laser.Position = laser.Position + laser.Velocity:Resized(10):Rotated(90) + player.Velocity
		laser.Angle = (laser.Velocity):GetAngleDegrees() - 90
		laser:SetTimeout(mod:RandomInt(10,15))
		laser.MaxDistance = 20
		laser:AddTearFlags(TearFlags.TEAR_ACID)
		laser.CollisionDamage = player.Damage*2.5
		laser.DepthOffset = -500
		laser:SetColor(Color(1, 0.5, 0.2, 1, 0.5, 0.4, 0), -1, 1)
		laser:GetData().TaintedOverchageLaser = true
		
		data.TaintedOverchargeSparks = data.TaintedOverchargeSparks - 1
	end
end

mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, function(_, laser)
	if laser:GetData().TaintedOverchageLaser then
		laser.MaxDistance = laser.FrameCount*5 + 20
	end
end)

mod:AddCallback(ModCallbacks.MC_POST_RENDER, renderActive.OnRender)