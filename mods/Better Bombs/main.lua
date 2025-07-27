local BetterBombs = RegisterMod("BetterBombs", 1);

-- Mod has been added to ab+ 2nd Booster Pack and Rep! Here's a happy ascii to celebrate!
--_________________________________________________________________
--_________________________________________________________________
--___________##________________________________________________##__
--__________###________##___________________##________________###__
--_________###________#__#___###########___#__#______________###___
--_______###___________##____#_________#____##_____________###_____
--_____####__________________#_________#_________________####______
--__#####____________________#________##______________#####________
--___________________________________##____________________________
--________________________________####_____________________________
--____________________________#####________________________________
--_________________________________________________________________

local show_debug = false    -- [true / false] To show debug mode.

local flag = 0
local bFlags = {}
if REPENTANCE then
	bFlags[1] = {1 << 2, 1 << 4, 1 << 29, 1 << 28, 1 << 37, 1 << 22, 1 << 35}
else       --Homing, Poison, Butt,    Sad,     Sticky,  Fire,    Glitter
	bFlags[1] = {1 << 2, 1 << 4, 1 << 29, 1 << 28, 1 << 35, 1 << 22, 1 << 30}
end
bFlags[2] = {false, false, false, false, false, false, false, false, false, false}
--Mega, Fast,  Golden

local BodyBomb = 0
local effect = 0

local BombVar = nil    -- (Variant ID; 1: Regular, 2: Troll; 3: Mr. Boom; 4: Best Friend)
local matBombVar = {"regular", "troll", "mrboom", "bestfriend"}

local bombSize = ""
local bombGold = ""

local matBomb = {}      -- This table has sprites numbers that the mod loads on "bbomb.anm2" / "bbest_friend.anm2", go to the gfx folder to see it yourself.
matBomb[1] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 1, 2, 11, 12, 13, 14, 11, 12, 1, 2, 1, 2, 15, 16, 17, 18, 15, 16}                    -- Regular bombs
matBomb[2] = {1, 2, 3, 4, 5, 6, 1, 2, 7, 8, 7, 8, 9, 10, 9, 10}                                                                   -- Troll bombs
matBomb[3] = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 1, 2, 7, 8, 13, 14, 15, 16, 13, 14, 15, 16, 17, 18, 19, 20, 17, 18, 19, 20}  -- Mr. Boom bombs
matBomb[4] = {1, 2, 3, 4, 5, 6, 7, 8}                                                                                             -- Best Friend

local matBRoom = {}   -- Mod uses a table to save bombs and it's "build" (appearance) to prevent bombs having incorrect animation when you drop a bomb and leave the room, picking up an item that changes bomb's animation, and returning to the room with the bomb.

local function hasFlag(bomb, flag)
	local res
	if REPENTANCE then
		res = bomb:ToBomb():HasTearFlags(flag)
	else
		res = (bomb:ToBomb().Flags & flag) ~= 0
	end
	return res
end

local mask
if REPENTANCE then mask = ~BitSet128(1<<36,0) end
local function GetBombSpawner(bomb)
	local bombs = Isaac.FindInRadius(bomb.Position, 100, 0xffffffff)
	local nearest
	local dist
	for _, e in pairs(bombs) do
		if e.Type == 4 and hasFlag(e, 1<<36) and GetPtrHash(bomb) ~= GetPtrHash(e) and e:IsDead() and e:ToBomb().Flags and bomb:ToBomb().Flags == (e:ToBomb().Flags & mask) then			
        	if not nearest then
          		nearest = e
          		dist = e.Position:Distance(bomb.Position)
        	else
          		local distN = e.Position:Distance(bomb.Position)
          		if distN < dist then
            		nearest = e
            		dist = distN
          		end
        	end
		end
	end
	return nearest
end

function BetterBombs:main(bomb)   -- At first, this function used code from "Blank Bombs" <3 : http://steamcommunity.com/sharedfiles/filedetails/?id=845700484
	if bomb.FrameCount == 1 then
		local spawnerIsBomb = ((not REPENTANCE and bomb.SpawnerType == EntityType.ENTITY_BOMBDROP) or (REPENTANCE and GetBombSpawner(bomb)))
		if REPENTANCE then
			if bomb.Variant == 9 or bomb.Variant == 13 or bomb.Variant == 17 or bomb.Variant == 19 or bomb.Variant == 20 then return end
			if bomb.Variant == 0 and (hasFlag(bomb, 1<<36) or hasFlag(bomb, 1<<45) or hasFlag(bomb, BitSet128(0,1<<72 % 64)) or hasFlag(bomb, BitSet128(0,1<<75 % 64)) or hasFlag(bomb, BitSet128(0,1<<78 % 64))) then return end
		end
		if bomb.Type == EntityType.ENTITY_BOMBDROP and (bomb.SpawnerType == 1 or spawnerIsBomb or bomb.Variant == BombVariant.BOMB_DECOY) and not repBomb then

			flag = bomb:ToBomb().Flags
			
			if not (REVEL and Isaac.GetPlayer(0):HasCollectible(REVEL.ITEM.MIRROR_BOMBS.id) and Isaac.GetPlayer(0):HasCollectible(REVEL.ITEM.SPONGE.id)) and not bomb:GetData().isNugget then
				
				local sprite = bomb:GetSprite()
				local BombSpawner = GetBombSpawner(bomb)
				
				for j=1, 7 do
					bFlags[2][j] = hasFlag(bomb, bFlags[1][j])
				end
				
				if REPENTANCE then
					if bomb.SpawnerEntity and bomb.SpawnerEntity.Type == 1 then		--spawner == player
						bFlags[2][8] = bomb.SpawnerEntity:ToPlayer():HasCollectible(CollectibleType.COLLECTIBLE_MR_MEGA)						
						--if bomb.Flags == BitSet128(0,0) and not bFlags[2][8] then return end
					end
					bFlags[2][9] = hasFlag(bomb, BitSet128(0,1<<126 % 64))
					bFlags[2][10] = hasFlag(bomb, BitSet128(0,1<<125 % 64))
				else if Game():GetNumPlayers() == 1 then
					local player = Isaac.GetPlayer(0)
					bFlags[2][8] = player:HasCollectible(CollectibleType.COLLECTIBLE_MR_MEGA)
					bFlags[2][9] = player:HasCollectible(CollectibleType.COLLECTIBLE_FAST_BOMBS)
					bFlags[2][10] = player:HasGoldenBomb()
				end
			end

			if matBRoom[bomb.InitSeed] == nil then   -- If bomb's seed is not found on the table (because it's a "new" bomb)...
				
				-- Set the bomb's "body" according what items you have
				
				if bomb.Variant == BombVariant.BOMB_DECOY or bomb.SpawnerVariant == BombVariant.BOMB_DECOY or (REPENTANCE and BombSpawner and BombSpawner.Variant == 2) then
					BombVar = 4
					
					if bFlags[2][2] == false and bFlags[2][5] == false and bFlags[2][7] == false then
						BodyBomb = 1
					elseif bFlags[2][2] == true then
						BodyBomb = 3
					elseif bFlags[2][2] == false and bFlags[2][5] == false and bFlags[2][7] == true then
						BodyBomb = 5
					elseif bFlags[2][2] == false and bFlags[2][5] == true then
						BodyBomb = 7
					end
					
				elseif bomb.Variant == BombVariant.BOMB_BIG or bomb.SpawnerVariant == BombVariant.BOMB_BIG or (REPENTANCE and BombSpawner and BombSpawner.Variant == 1) then
					BombVar = 3
					
					if bFlags[2][2] == false and bFlags[2][3] == false and bFlags[2][4] == false and bFlags[2][5] == false and bFlags[2][6] == false and bFlags[2][7] == false then
						BodyBomb = 1
					elseif bFlags[2][2] == true and bFlags[2][4] == false then
						BodyBomb = 3
					elseif bFlags[2][2] == false and bFlags[2][3] == true and bFlags[2][4] == false and bFlags[2][5] == false then
						BodyBomb = 5
					elseif bFlags[2][2] == false and bFlags[2][3] == false and bFlags[2][4] == true and bFlags[2][5] == false and bFlags[2][6] == false and bFlags[2][7] == false then
						BodyBomb = 7
					elseif bFlags[2][2] == true and bFlags[2][4] == true then
						BodyBomb = 9
					elseif bFlags[2][2] == false and bFlags[2][3] == true and bFlags[2][4] == true and bFlags[2][5] == false then
						BodyBomb = 11
					elseif bFlags[2][2] == false and bFlags[2][3] == false and bFlags[2][4] == false and bFlags[2][5] == false and bFlags[2][6] == true and bFlags[2][7] == false then
						BodyBomb = 13
					elseif bFlags[2][2] == false and bFlags[2][3] == false and bFlags[2][4] == true and bFlags[2][5] == false and bFlags[2][6] == true and bFlags[2][7] == false then
						BodyBomb = 15
					elseif bFlags[2][2] == false and bFlags[2][3] == false and bFlags[2][4] == false and bFlags[2][5] == false and bFlags[2][6] == false and bFlags[2][7] == true then
						BodyBomb = 17
					elseif bFlags[2][2] == false and bFlags[2][3] == false and bFlags[2][4] == true and bFlags[2][5] == false and bFlags[2][6] == false and bFlags[2][7] == true then
						BodyBomb = 19
					elseif bFlags[2][2] == false and bFlags[2][3] == false and bFlags[2][4] == false and bFlags[2][5] == false and bFlags[2][6] == true and bFlags[2][7] == true then
						BodyBomb = 21
					elseif bFlags[2][2] == false and bFlags[2][3] == false and bFlags[2][4] == true and bFlags[2][5] == false and bFlags[2][6] == true and bFlags[2][7] == true then
						BodyBomb = 23
					elseif bFlags[2][2] == false and bFlags[2][4] == false and bFlags[2][5] == true and bFlags[2][6] == false then
						BodyBomb = 25
					elseif bFlags[2][2] == false and bFlags[2][4] == true and bFlags[2][5] == true and bFlags[2][6] == false then
						BodyBomb = 27
					elseif bFlags[2][2] == false and bFlags[2][4] == false and bFlags[2][5] == true and bFlags[2][6] == true then
						BodyBomb = 29
					elseif bFlags[2][2] == false and bFlags[2][4] == true and bFlags[2][5] == true and bFlags[2][6] == true then
						BodyBomb = 31
					end
					
				elseif bomb.Variant == BombVariant.BOMB_TROLL or bomb.SpawnerVariant == BombVariant.BOMB_TROLL or (REPENTANCE and BombSpawner and BombSpawner.Variant == 3) then
					BombVar = 2
					
					if bFlags[2][2] == false and bFlags[2][3] == false and bFlags[2][6] == false and bFlags[2][7] == false and bFlags[2][5] == false then
						BodyBomb = 1
					elseif bFlags[2][2] == true then
						BodyBomb = 3
					elseif bFlags[2][2] == false and bFlags[2][3] == true and bFlags[2][5] == false then
						BodyBomb = 5
					elseif bFlags[2][2] == false and bFlags[2][3] == false and bFlags[2][6] == true and bFlags[2][7] == false and bFlags[2][5] == false then
						BodyBomb = 7
					elseif bFlags[2][2] == false and bFlags[2][3] == false and bFlags[2][6] == false and bFlags[2][7] == true and bFlags[2][5] == false then
						BodyBomb = 9
					elseif bFlags[2][2] == false and bFlags[2][3] == false and bFlags[2][6] == true and bFlags[2][7] == true and bFlags[2][5] == false then
						BodyBomb = 11
					elseif bFlags[2][2] == false and bFlags[2][6] == false and bFlags[2][5] == true then
						BodyBomb = 13
					elseif bFlags[2][2] == false and bFlags[2][6] == true and bFlags[2][5] == true then
						BodyBomb = 15
					end
					
				else
					BombVar = 1
					
					if bFlags[2][2] == false and bFlags[2][3] == false and bFlags[2][4] == false and bFlags[2][6] == false and bFlags[2][7] == false and bFlags[2][9] == false and bFlags[2][5] == false then
						BodyBomb = 1
					elseif bFlags[2][2] == true then
						BodyBomb = 3
					elseif bFlags[2][2] == false and bFlags[2][3] == true and bFlags[2][4] == false and bFlags[2][5] == false then
						BodyBomb = 5
					elseif bFlags[2][2] == false and bFlags[2][3] == false and bFlags[2][4] == true and bFlags[2][7] == false and bFlags[2][5] == false then
						BodyBomb = 7
					elseif bFlags[2][2] == false and bFlags[2][3] == true and bFlags[2][4] == true and bFlags[2][5] == false then
						BodyBomb = 9
					elseif bFlags[2][2] == false and bFlags[2][3] == false and bFlags[2][4] == false and bFlags[2][6] == true and bFlags[2][7] == false and bFlags[2][9] == false and bFlags[2][5] == false then
						BodyBomb = 11
					elseif bFlags[2][2] == false and bFlags[2][3] == false and bFlags[2][4] == false and bFlags[2][6] == false and bFlags[2][7] == true and bFlags[2][5] == false then
						BodyBomb = 13
					elseif bFlags[2][2] == false and bFlags[2][3] == false and bFlags[2][4] == true and bFlags[2][7] == true and bFlags[2][5] == false then
						BodyBomb = 15
					elseif bFlags[2][2] == false and bFlags[2][3] == false and bFlags[2][4] == false and bFlags[2][6] == true and bFlags[2][7] == true and bFlags[2][5] == false then
						BodyBomb = 17
					elseif bFlags[2][2] == false and bFlags[2][3] == false and bFlags[2][4] == false and bFlags[2][6] == false and bFlags[2][7] == false and bFlags[2][9] == true and bFlags[2][5] == false then
						BodyBomb = 19
					elseif bFlags[2][2] == false and bFlags[2][3] == false and bFlags[2][4] == false and bFlags[2][6] == true and bFlags[2][7] == false and bFlags[2][9] == true and bFlags[2][5] == false then
						BodyBomb = 21
					elseif bFlags[2][2] == false and bFlags[2][4] == false and bFlags[2][6] == false and bFlags[2][5] == true then
						BodyBomb = 23
					elseif bFlags[2][2] == false and bFlags[2][4] == true and bFlags[2][5] == true then
						BodyBomb = 25
					elseif bFlags[2][2] == false and bFlags[2][4] == false and bFlags[2][6] == true and bFlags[2][5] == true then
						BodyBomb = 27
					end				
				end
				
				if bFlags[2][8] == true then BodyBomb = BodyBomb + 1 end
				
				-- ...and saves all that build (body and effect) on the table, with it's seed as index 
				
				bFlags[2][11] = spawnerIsBomb
				matBRoom[bomb.InitSeed] = {BombVar,        -- Bomb Variant
					BodyBomb,       -- Body Id
					bFlags[2][1],   -- Bobby-Bomb
					bFlags[2][9],   -- Fast Bombs
					bFlags[2][10],  -- Golden Bombs
					bFlags[2][3],   -- Butt Bombs
					bFlags[2][4],   -- Sad Bombs
					bFlags[2][5],   -- Sticky Bombs
					bFlags[2][6],   -- Hot Bombs
					bFlags[2][7],    -- Glitter Bombs
					bFlags[2][11]
				}
				
			else -- But, it's already found on the table (because it's an "saved" bomb)...
				
				-- ...just get the build (again body and effect) using it's seed as index from the table...				
				BombVar = matBRoom[bomb.InitSeed][1]
				BodyBomb = matBRoom[bomb.InitSeed][2]
				bFlags[2][1] = matBRoom[bomb.InitSeed][3]
				bFlags[2][3] = matBRoom[bomb.InitSeed][6]
				bFlags[2][4] = matBRoom[bomb.InitSeed][7]
				bFlags[2][5] = matBRoom[bomb.InitSeed][8]
				bFlags[2][6] = matBRoom[bomb.InitSeed][9]
				bFlags[2][7] = matBRoom[bomb.InitSeed][10]
				bFlags[2][9] = matBRoom[bomb.InitSeed][4]
				bFlags[2][10] = matBRoom[bomb.InitSeed][5]
				spawnerIsBomb = matBRoom[bomb.InitSeed][11]
			end

			local baseDMG = 60
			local bonusDMG = 50
			if REPENTANCE then
				baseDMG = 100
				bonusDMG = 85
			end
			if BodyBomb % 2 == 0 and spawnerIsBomb then
				if BombVar == 2 then
					bomb:ToBomb().ExplosionDamage = baseDMG + bonusDMG
				elseif BombVar == 3 or BombVar == 4 then
					bomb:ToBomb().ExplosionDamage = baseDMG + bonusDMG*2
				end
			end

			-- ...and set up bomb's animation in real time

			if REPENTANCE and spawnerIsBomb then bomb.SpriteScale = Vector(0.5, 0.5) end

			if spawnerIsBomb then
				if bomb.SpawnerVariant == BombVariant.BOMB_DECOY or BombVar == 4 then
					sprite:Load("gfx/bbest_friend_small.anm2",false)
					sprite:Play("Idle", true)
				else
					sprite:Load("gfx/bbomb_small.anm2",false)
				end
				bombSize = "small/"
			else
				if bomb.Variant == BombVariant.BOMB_DECOY then
					sprite:Load("gfx/bbest_friend.anm2",false)
					sprite:Play("Idle", true)
				else
					sprite:Load("gfx/bbomb.anm2",false)
				end
				bombSize = ""
			end

			if BombVar == 2 and not spawnerIsBomb then
				sprite:Play("Appear", true)
			end

			if bFlags[2][10] == false then
				bombGold = ""
			else
				bombGold = "gold_"
			end

			sprite:ReplaceSpritesheet(0,"gfx/Spritesheets/" .. bombSize .. matBombVar[BombVar] .. "/body_" .. bombGold .. BodyBomb .. ".png")   -- Body

			effect = matBomb[BombVar][BodyBomb]
			local effects_path = "gfx/Spritesheets/" .. bombSize .. matBombVar[BombVar] .. "/effects_" .. matBomb[BombVar][BodyBomb] .. ".png"

			if bFlags[2][10] == false then					
				if bFlags[2][1] == true then sprite:ReplaceSpritesheet(2, effects_path) end		-- Bobby-Bomb					
				if bFlags[2][9] == true then sprite:ReplaceSpritesheet(4, effects_path) end		-- Fast Bombs
			else
				sprite:ReplaceSpritesheet(6, effects_path)										-- Golden Bombs (Glow)					
				if bFlags[2][1] == true then sprite:ReplaceSpritesheet(3, effects_path) end 	-- Bobby-Bomb (Gold)
				if bFlags[2][9] == true then sprite:ReplaceSpritesheet(5, effects_path) end 	-- Fast Bombs (Gold)
			end

			if bFlags[2][3] == true then sprite:ReplaceSpritesheet(7, effects_path) end 	-- Butt Bombs				
			if bFlags[2][4] == true then sprite:ReplaceSpritesheet(8, effects_path) end 	-- Sad Bombs				
			if bFlags[2][5] == true then sprite:ReplaceSpritesheet(9, effects_path) end 	-- Sticky Bombs				
			if bFlags[2][6] == true then sprite:ReplaceSpritesheet(10, effects_path) end 	-- Hot Bombs				
			if bFlags[2][7] == true then sprite:ReplaceSpritesheet(11, effects_path) end 	-- Glitter Bombs

			sprite:LoadGraphics()

			if sprite:IsPlaying("Explode") then				-- If bomb is exploading, it's no longer nedeed to be on the table.
				matBRoom[tostring(bomb.InitSeed)] = nil		-- ...and it's dropped from the table.
			end			
		end
	end

	if bomb.Variant == BombVariant.BOMB_HOT and bomb.SpawnerType == EntityType.ENTITY_BIG_HORN then
		local sprite = bomb:GetSprite()
		sprite:Load("gfx/bbomb.anm2",false)
		sprite:ReplaceSpritesheet(0,"gfx/Spritesheets/troll/body_7.png")
		sprite:ReplaceSpritesheet(10,"gfx/Spritesheets/troll/effects_1.png")
		sprite:Play("Appear", true)
		sprite:LoadGraphics()
	end

	if (not REPENTANCE) and bomb.Variant == BombVariant.BOMB_TROLL and bomb.SpawnerType == EntityType.ENTITY_LITTLE_HORN then
		local ColorG = bomb:GetColor().G      
		if ColorG == 0.5 then
			bomb:SetColor(Color(1, 1, 1, 1.0, 0, 0, 0),-1,1,false,false)
			local sprite = bomb:GetSprite()
			if sprite:IsPlaying("Appear") then
				sprite:Load("gfx/bbomb.anm2",false)
				sprite:ReplaceSpritesheet(0,"gfx/Spritesheets/troll/body_7.png")
				sprite:ReplaceSpritesheet(10,"gfx/Spritesheets/troll/effects_1.png")
				sprite:Play("Appear", true)
				sprite:LoadGraphics()
			end
			if sprite:IsPlaying("BombReturn") then
				sprite:Load("gfx/bbomb.anm2",false)
				sprite:ReplaceSpritesheet(0,"gfx/Spritesheets/troll/body_7.png")
				sprite:ReplaceSpritesheet(10,"gfx/Spritesheets/troll/effects_1.png")
				sprite:Play("BombReturn", true)
				sprite:LoadGraphics()
			end
		end
	end    
end
end

BetterBombs:AddCallback(ModCallbacks.MC_NPC_UPDATE, function(_, horn)
	if (not REPENTANCE) and horn.FrameCount == 1 and horn.SubType == 1 and horn.SpawnerType ~= EntityType.ENTITY_BIG_HORN then
		local sprite = horn:GetSprite()
		sprite:Load("gfx/404.000.001_littlehorn.anm2",false)
		sprite:LoadGraphics()
	end
end, 404)

BetterBombs:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, function()
	matBRoom = {}
end)

local function ShowText()  
	if show_debug == true then
		Isaac.RenderText("Last bomb's flairs",  45, 150, 255, 255 ,0 , 255)
		Isaac.RenderText("Mr Mega: ", 45, 160, 255, 255, 255, 255)
		Isaac.RenderText("Homing: ",  45, 170, 255, 255, 255, 255)
		Isaac.RenderText("Poison: ",  45, 180, 255, 255, 255, 255)
		Isaac.RenderText("Butt: ",    45, 190, 255, 255, 255, 255)
		Isaac.RenderText("Sad: ",     45, 200, 255, 255, 255, 255)
		Isaac.RenderText("Fire: ",    45, 210, 255, 255, 255, 255)
		Isaac.RenderText("Glitter: ", 45, 220, 255, 255, 255, 255)
		Isaac.RenderText("Fast: ",    45, 230, 255, 255, 255, 255)
		Isaac.RenderText("Sticky: ",  45, 240, 255, 255, 255, 255)
		Isaac.RenderText("Golden: ",  45, 250, 255, 255, 255, 255)

		Isaac.RenderText(tostring(bFlags[2][8]), 99, 160, 255, 255, 0, 255)
		Isaac.RenderText(tostring(bFlags[2][9]), 99, 230, 255, 255, 0, 255)
		Isaac.RenderText(tostring(bFlags[2][10]), 99, 250, 255, 255, 0, 255)
		Isaac.RenderText(tostring(bFlags[2][1]), 99, 170, 255, 255, 0, 255)
		Isaac.RenderText(tostring(bFlags[2][2]), 99, 180, 255, 255, 0, 255)
		Isaac.RenderText(tostring(bFlags[2][3]), 99, 190, 255, 255, 0, 255)
		Isaac.RenderText(tostring(bFlags[2][4]), 99, 200, 255, 255, 0, 255)
		Isaac.RenderText(tostring(bFlags[2][5]), 99, 240, 255, 255, 0, 255)
		Isaac.RenderText(tostring(bFlags[2][6]), 99, 210, 255, 255, 0, 255)
		Isaac.RenderText(tostring(bFlags[2][7]), 99, 220, 255, 255, 0, 255)

		Isaac.RenderText("Last bomb's build", 45, 100, 255, 255, 0, 255)
		Isaac.RenderText("BodyVar: ", 45, 110, 255, 255, 255, 255)
		Isaac.RenderText("BodyBomb: ", 45, 120, 255, 255, 255, 255)
		Isaac.RenderText("Effect: ", 45, 130, 255, 255, 255, 255)

		if BombVar ~= nil then
			Isaac.RenderText(matBombVar[BombVar] .. " (" .. BombVar .. ")", 105, 110, 255, 255, 0, 255)
		else
			Isaac.RenderText(0, 105, 110, 255, 255, 0, 255)
		end
		Isaac.RenderText(BodyBomb, 105, 120, 255, 255, 0, 255)    
		Isaac.RenderText(effect, 105, 130, 255, 255, 0, 255)
	end
end

BetterBombs:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, BetterBombs.main)
--BetterBombs:AddCallback(ModCallbacks.MC_POST_RENDER, ShowText);


-- momento porro