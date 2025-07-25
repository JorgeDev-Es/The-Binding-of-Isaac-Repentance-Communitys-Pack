VHM = RegisterMod("Visible Holy Mantles", 1);

--Modules
require("vhm_mcm");
local json = require("json");

--!!! Default settings (overridden if player has MCM installed) !!!
--!!! After you edit these values, go to 'Steam\steamapps\common\The Binding of Isaac Rebirth\data' and delete the folder 'visible_lost_health' !!!
VHM.Settings = {
	["drawShieldsInline"] = true;		--Whether to draw shields in line with other hearts or not.		default: true		[true, false]
	["drawShieldsOverlapping"] = false;	--Whether to draw shields overlapping each other or not.		default: false		[true, false]
	["overrideCurse"] = false,			--Show/hide shields during Curse of the Unknown.				default: false		[true or false]
};

--Shader crash fix; credit to BasedCucco and KingBobson
VHM:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, function()
    if #Isaac.FindByType(EntityType.ENTITY_PLAYER) == 0 then
        Isaac.ExecuteCommand("reloadshaders")
    end
end);

----MAIN FUNCTIONS----

--Variables
VHM.Icon = Sprite();
VHM.Icon:Load("vhm/vhm_mantles.anm2", true);
VHM.Icon:SetFrame("HolyMantle", 0);				--the animation for the UI's Holy Mantle shield sprite
local shieldSpriteDimension = Vector(12, 0);	--the offset of a shield icon when it needs to be drawn next to another one
local isVLHInstalled = false;					--whether or not the player is using the mod Visible Lost Health for this run

--Display the shield sprites
function VHM:DisplaySprites(shaderName)
	--Only display sprites when evaluating our custom empty shader, credit to KingBobson
	if shaderName ~= "EmptyShader" then return end

	--[BUG: This prevents the shield appearing for Esau's HUD, since he is not considered player 0]
	local player = Isaac.GetPlayer(0);

	--Display the appropriate sprite
	if VHM:ShoulDisplayIcon(player) then
		--Check if the player has shields
		local shieldCount = player:GetEffects():GetCollectibleEffectNum(CollectibleType.COLLECTIBLE_HOLY_MANTLE);
		
		--See how far apart to place each shield
		local spriteOffsetMultiplier = 1;		--used to control how far apart to draw each shield
		if VHM.Settings["drawShieldsOverlapping"] then		--if the shields should overlap, reduce the offset multiplier
			spriteOffsetMultiplier = 0.5;
		end
		local spriteOffset = shieldSpriteDimension * spriteOffsetMultiplier;

		--Get the correct position to display the first shield
		local inlinePosition, belowPosition = VHM:GetSpritePositions(player);
		local spritePosition = inlinePosition;
		if not VHM.Settings["drawShieldsInline"] then
			spritePosition = belowPosition;
		end

		local alreadyMovedDown = false;
		--Draw the shields
		for i=1,shieldCount do
			VHM.Icon:Render(spritePosition, Vector(0,0), Vector(0,0));
			--Update the default sprite position
			if
			(
				VHM:ShouldWrapToNextRow(player)			--should check for UI wrapping
				and (not alreadyMovedDown)				--didn't already move down
			)
			then
				--Determine where in the heart UI the sprite we just drew is located
				local currentHeartPosition = VHM:GetHearts(player) + (i * spriteOffsetMultiplier);
				if VHM.Settings["drawShieldsOverlapping"] then		--add 1/2 if the shields are overlapping (to compensate for the starting shield being full width)
					currentHeartPosition = currentHeartPosition + 0.5;
				end
				--Move the sprite position down a row if...
				if
				(
					(currentHeartPosition == 6 or currentHeartPosition == 12)			--...it would exceed the UI row limit of 6 hearts
					or (player:GetExtraLives() ~= 0 and currentHeartPosition <= 6)		--...it would collide with the extra lives counter
				)
				then
					spritePosition = belowPosition;
					alreadyMovedDown = true;
				--Otherwise, just move the sprite over and continue on
				else
					spritePosition = spritePosition + spriteOffset;
				end
			--If not drawing inline or you already moved down a row, just move the sprite over and continue on
			else
				spritePosition = spritePosition + spriteOffset;
			end
		end
	end
end

----/MAIN FUNCTIONS----

----HELPER FUNCTIONS----

--Returns the HUD Offset of the game as an int in range [0,10]
function VHM:GetHudOffsetLevel()
	local raw = Options.HUDOffset;
	raw = raw * 10;
	if (raw % 1) < 0.5 then
		return math.floor(raw);
	else
		return math.ceil(raw);
	end
end

--Returns Boolean whether the character is The Lost
function VHM:IsCharacterLost(player)
	return player:GetPlayerType() == PlayerType.PLAYER_THELOST
		or player:GetPlayerType() == PlayerType.PLAYER_THELOST_B;
end

--Returns Boolean whether the character is The Forgotten
function VHM:IsCharacterForgotten(player)
	return player:GetPlayerType() == PlayerType.PLAYER_THEFORGOTTEN
		or player:GetPlayerType() == PlayerType.PLAYER_THESOUL;
end

--Returns Boolean whether the character can gain red hearts or not
function VHM:IsCharacterSoulHeartsOnly(player)
	return player:GetPlayerType() == PlayerType.PLAYER_BLUEBABY
		or player:GetPlayerType() == PlayerType.PLAYER_BLUEBABY_B
		or player:GetPlayerType() == PlayerType.PLAYER_BETHANY_B;
end

--Returns Boolean whether the level has Curse of the Unknown or not
function VHM:IsLevelCursed()
	return (Game():GetLevel():GetCurses() & LevelCurse.CURSE_OF_THE_UNKNOWN) == LevelCurse.CURSE_OF_THE_UNKNOWN;
end

--Returns Boolean whether or not the icon should be displayed
function VHM:ShoulDisplayIcon(player)
	local level = Game():GetLevel();
	
	--Check if the HUD is currently visible
	local isHUDVisible = Game():GetHUD():IsVisible();
	
	--Check if the level has Curse of the Unknown
	local isCursed = VHM:IsLevelCursed() and not VHM.Settings["overrideCurse"];

	--Check if the character is Lost and the player has Visible Lost Health mod installed
	local isLostHandled = isVLHInstalled and VHM:IsCharacterLost(player);
	
	--Check if MCM is currently open
	local isMCMOpen = false;
	if ModConfigMenu and ModConfigMenu.IsVisible then
		isMCMOpen = true;
	end
	
	return isHUDVisible and not isCursed and not isLostHandled and not isMCMOpen;
end

--Gets the number of heart spaces that the player currently has in the UI
function VHM:GetHearts(player)
	local hearts = math.ceil((player:GetEffectiveMaxHearts() + player:GetSoulHearts()) / 2);	--get heart containers and soul hearts

	if not VHM:IsCharacterLost(player) then			--if not a Lost character, get broken hearts
		hearts = hearts + player:GetBrokenHearts();
	else											--otherwise, ignore the half soul heart that The Lost/The Tainted Lost both have
		hearts = hearts - 1;
	end

	if VHM:IsCharacterSoulHeartsOnly(player) then	--if character can't gain red hearts, you need to manually count bone hearts
		hearts = hearts + player:GetBoneHearts()
	end

	return hearts;
end

--Returns Bool of whether shields should try to wrap to the next health row
function VHM:ShouldWrapToNextRow(player)
	return VHM.Settings["drawShieldsInline"]		--drawing inline
		and (not VHM:IsLevelCursed())				--level isn't under Curse of the Unknown
		and (not VHM:IsCharacterForgotten(player))	--player isn't The Forgotton
end

--Returns true for certain characters whose health needs to be handled specially for rows
function VHM:RowHeightSpecialCharacters(player)
	return player:GetPlayerType() == PlayerType.PLAYER_THELOST
		or player:GetPlayerType() == PlayerType.PLAYER_THELOST_B
		or player:GetPlayerType() == PlayerType.PLAYER_KEEPER
		or player:GetPlayerType() == PlayerType.PLAYER_KEEPER_B;
end

--Returns two Vectors corresponding to where to draw the first shield (first vector is inline, second vector is below)
function VHM:GetSpritePositions(player)
	--Get the player's HUD offset
	local hudOffset = VHM:GetHudOffsetLevel();

	local DEFAULTPOS = Vector(48, 12);		--the default position at HUD offset 0 (i.e. where the first heart in the UI is)
	local ROWHEIGHT = Vector(0, 10);		--the offset when moving the sprite down a row
	if VHM:RowHeightSpecialCharacters(player) then
		ROWHEIGHT = ROWHEIGHT + Vector(0, 3);	--move down an extra few px to get no overlapping of shields with special health bars
	end

	local inlinePosition = DEFAULTPOS;					--start inline sprites at the default position
	local belowPosition = DEFAULTPOS + ROWHEIGHT;		--start below sprites down a row

	local hearts = VHM:GetHearts(player);				--the number of heart containers / soul hearts the player has

	--If the level has Curse of the Unknown...
	if VHM:IsLevelCursed() then
		--Draw the inline sprite next to the curse symbol
		inlinePosition = inlinePosition + shieldSpriteDimension;
	--Otherwise, we need to calculate the sprite positions
	else
		--For inline sprites...
		local tempHearts = hearts;
		if VHM:ShouldWrapToNextRow(player) then
			while tempHearts >= 6 do			--whenever the player has a full row of hearts, move the inline sprite position down a row if need be
				tempHearts = tempHearts - 6;
				inlinePosition = inlinePosition + ROWHEIGHT;
			end
		end
		for i=1,(tempHearts) do				--move the inline sprite position over so it's to the right of any hearts
			inlinePosition = inlinePosition + shieldSpriteDimension;
		end
		--For below sprites...
		if hearts > 6 then						--if the player has more than a full row of hearts, move the below sprite position down another row
			belowPosition = belowPosition + ROWHEIGHT;
		end
	end

	--Shift the position over according to MCM's HUD offset
	local offsetVector = Vector(2, 1.2) * hudOffset;
	inlinePosition = inlinePosition + offsetVector;
	belowPosition = belowPosition + offsetVector;

	return inlinePosition, belowPosition;
end

----/HELPER FUNCTIONS----

----SAVE DATA----

local SaveState = {};
--Saves the mod's data into a .dat file
function VHM:SaveModData(_, shouldSave)
	--Default values
	SaveState["drawShieldsInline"] = VHM.Settings["drawShieldsInline"];
	SaveState["drawShieldsOverlapping"] = VHM.Settings["drawShieldsOverlapping"];
	SaveState["overrideCurse"] = VHM.Settings["overrideCurse"];
	--Save the data
	VHM:SaveData(json.encode(SaveState));
end

--Loads the mod's data from the .dat file
function VHM:LoadModData()
	--Only run this when there are no players initialized, so at the start of a run
	local totalPlayers = #Isaac.FindByType(EntityType.ENTITY_PLAYER);
	if totalPlayers == 0 then
		--Load the saved data into SaveState variable
		if VHM:HasData() then
			SaveState = json.decode(VHM:LoadData());
			--Update the MCM settings to match the saved settings (you need to check if saved value is nil or not in case it's a Boolean that equals false)
			VHM.Settings["drawShieldsInline"] = (SaveState["drawShieldsInline"] == nil and VHM.Settings["drawShieldsInline"]) or SaveState["drawShieldsInline"];
			VHM.Settings["drawShieldsOverlapping"] = (SaveState["drawShieldsOverlapping"] == nil and VHM.Settings["drawShieldsOverlapping"]) or SaveState["drawShieldsOverlapping"];
			VHM.Settings["overrideCurse"] = (SaveState["overrideCurse"] == nil and VHM.Settings["overrideCurse"]) or SaveState["overrideCurse"];
		end
	end
end

----/SAVE DATA----

----MOD APIS----

--Sets whether or not the mod Visible Lost Health is installed
function VHM:IsVLHInstalled()
	if VLH then
		isVLHInstalled = true;
	end
end
--Call this function only after the player starts a run
VHM:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, VHM.IsVLHInstalled);

----/MOD APIS----

----CALLBACKS----

--Draw the heart sprite after shaders are set (this mod uses an empty shader, credit to KingBobson, to ensure that the sprites are drawn over the HUD elements)
VHM:AddCallback(ModCallbacks.MC_GET_SHADER_PARAMS, VHM.DisplaySprites);
--Save the mod's data before exiting the game
VHM:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, VHM.SaveModData);
--Load the mod's data when starting the game (function only runs if there are 0 players initialized)
VHM:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, VHM.LoadModData);

----/CALLBACKS----
