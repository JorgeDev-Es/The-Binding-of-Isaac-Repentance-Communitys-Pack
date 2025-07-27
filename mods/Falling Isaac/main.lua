local FallingIsaac = 
RegisterMod("FallingIsaac",1)
local sfx = SFXManager()

-- SOUNDS --
local fallingsound = Isaac.GetSoundIdByName ("Falling")
local GroundHit = Isaac.GetSoundIdByName ("GroundHit")
local Reroll = Isaac.GetSoundIdByName ("Reroll")
local Lazer = Isaac.GetSoundIdByName ("Lazer")
local BitTouch = Isaac.GetSoundIdByName ("BitTouch")
local LazDeath = Isaac.GetSoundIdByName ("LazDeath")
local LazRevive = Isaac.GetSoundIdByName ("LazRevive")
local MeatDrop = Isaac.GetSoundIdByName ("MeatDrop")
local WingSound = Isaac.GetSoundIdByName ("WingSound")
local Wind = Isaac.GetSoundIdByName ("Wind")
local GroundDrill = Isaac.GetSoundIdByName ("GroundDrill")
local RopeSwing = Isaac.GetSoundIdByName ("RopeSwing")
local CutRope = Isaac.GetSoundIdByName ("CutRope")
local PortalOpen = Isaac.GetSoundIdByName ("PortalOpen")
local PortalSpit = Isaac.GetSoundIdByName ("PortalSpit")
local PortalClose = Isaac.GetSoundIdByName ("PortalClose")
local BookFlying = Isaac.GetSoundIdByName ("BookFlying")
local BookCrash = Isaac.GetSoundIdByName ("BookCrash")
local GTBeth = Isaac.GetSoundIdByName ("GTBeth")
local Advance = Isaac.GetSoundIdByName ("Advance")
local JumpM = Isaac.GetSoundIdByName ("JumpM")
local HitM = Isaac.GetSoundIdByName ("HitM")
local ENDeath = Isaac.GetSoundIdByName ("ENDeath")
local Ok = Isaac.GetSoundIdByName ("Ok")
local Great = Isaac.GetSoundIdByName ("Great")
local Land = Isaac.GetSoundIdByName ("Land")

-- SOUNDS --

-- Isaac Sounds --
function FallingIsaac:Sounds(Player)

    if Player:GetSprite():IsEventTriggered("Falling") then 
		sfx:Play(fallingsound,2,2,false,1,0)
    end
    if Player:GetSprite():IsEventTriggered("GroundHit") then
        sfx:Play(GroundHit,4,2,false,1,0)
    end
	if Player:GetSprite():IsEventTriggered("Reroll") then
        sfx:Play(Reroll,0.7,1,false,1,0)
    end
	
-- Blue Baby Sounds --
	if Player:GetSprite():IsEventTriggered("Lazer") then 
		sfx:Play(Lazer,0.5,2,false,1,0)
    end
	
	if Player:GetSprite():IsEventTriggered("BitTouch") then 
		sfx:Play(BitTouch,0.5,2,false,1,0)
    end
	
-- Azazel Sounds --
	if Player:GetSprite():IsEventTriggered("WingSound") then 
		sfx:Play(WingSound,1.2,2,false,1,0)
    end
	
-- Lazarus Sounds --	
	if Player:GetSprite():IsEventTriggered("LazDeath") then 
		sfx:Play(LazDeath,0.7,2,false,1,0)
    end
	
	if Player:GetSprite():IsEventTriggered("LazRevive") then 
		sfx:Play(LazRevive,1.2,2,false,1,0)
    end
	
	if Player:GetSprite():IsEventTriggered("MeatDrop") then 
		sfx:Play(MeatDrop,5,2,false,1,0)
    end
	
-- The Lost Sounds --
    if Player:GetSprite():IsEventTriggered("Wind") then
        sfx:Play(Wind,4,2,false,1,0)
    end
	
    if Player:GetSprite():IsEventTriggered("GroundDrill") then
        sfx:Play(GroundDrill,4,2,false,1,0)
    end
	
-- Keeper Sounds --	
	if Player:GetSprite():IsEventTriggered("RopeSwing") then 
		sfx:Play(RopeSwing,1,2,false,1,0)
    end
	
	if Player:GetSprite():IsEventTriggered("CutRope") then 
		sfx:Play(CutRope,1,2,false,1,0)
    end
	
-- Apollyon Sounds --
	if Player:GetSprite():IsEventTriggered("Portal_Open") then 
		sfx:Play(PortalOpen,0.3,2,false,1,0)
    end
	if Player:GetSprite():IsEventTriggered("Portal_Spit") then 
		sfx:Play(PortalSpit,0.5,2,false,1,0)
	end
	
	if Player:GetSprite():IsEventTriggered("Portal_Close") then 
		sfx:Play(PortalClose,0.2,2,false,1,0)
	end

-- Beth Sounds --
    if Player:GetSprite():IsEventTriggered("BookFlying") then 
		sfx:Play(BookFlying,2,2,false,1,0)
    end
    if Player:GetSprite():IsEventTriggered("BookCrash") then
        sfx:Play(BookCrash,4,2,false,1,0)
    end
	
	if Player:GetSprite():IsEventTriggered("GTBeth") then
        sfx:Play(GTBeth,4,2,false,1,0)
    end

-- JnE Sounds --
    if Player:GetSprite():IsEventTriggered("Advance") then 
		sfx:Play(Advance,1,2,false,1,0)
    end
	
    if Player:GetSprite():IsEventTriggered("JumpM") then
        sfx:Play(JumpM,1,2,false,1,0)
    end
	
	if Player:GetSprite():IsEventTriggered("HitM") then
        sfx:Play(HitM,0.7,2,false,1,0)
    end
	
	if Player:GetSprite():IsEventTriggered("ENDeath") then
        sfx:Play(ENDeath,0.7,2,false,1,0)
    end
	
	if Player:GetSprite():IsEventTriggered("Ok") then
        sfx:Play(Ok,1.3,2,false,1,0)
    end
	
	if Player:GetSprite():IsEventTriggered("Great") then
        sfx:Play(Great,1.7,2,false,1,0)
    end
	
	if Player:GetSprite():IsEventTriggered("Land") then
        sfx:Play(Land,1,2,false,1,0)
    end
	
end

FallingIsaac:AddCallback(ModCallbacks.MC_POST_PLAYER_UPDATE,FallingIsaac.Sounds, PlayerType.PLAYER_ISAAC)

-- Animations --
-- Isaac --
local function IsaacFalling(_, player, cacheFlag)
    local s = player:GetSprite()
    if player:GetPlayerType() == PlayerType.PLAYER_ISAAC then
      
        if s:GetFilename() ~= "gfx/IsaacFalling.anm2" then
            s:Load("gfx/IsaacFalling.anm2", true)
            s:Update()
        end
    end
end

FallingIsaac:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, IsaacFalling,0)

-- Blue Baby --
local function BlueBabyFalling(_, player, cacheFlag)
    local s = player:GetSprite()
    if player:GetPlayerType() == PlayerType.PLAYER_BLUEBABY then
      
        if s:GetFilename() ~= "gfx/BlueBabyFalling.anm2" then
            s:Load("gfx/BlueBabyFalling.anm2", true)
            s:Update()
        end
    end
end

FallingIsaac:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, BlueBabyFalling)

-- Azazel --
local function AzazelFalling(_, player, cacheFlag)
    local s = player:GetSprite()
    if player:GetPlayerType() == PlayerType.PLAYER_AZAZEL then
      
        if s:GetFilename() ~= "gfx/AzazelFalling.anm2" then
            s:Load("gfx/AzazelFalling.anm2", true)
            s:Update()
        end
    end
end

FallingIsaac:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, AzazelFalling)

-- Lazarus --
local function LazarusFalling(_, player, cacheFlag)
    local s = player:GetSprite()
    if player:GetPlayerType() == PlayerType.PLAYER_LAZARUS then
      
        if s:GetFilename() ~= "gfx/LazarusFalling.anm2" then
            s:Load("gfx/LazarusFalling.anm2", true)
            s:Update()
        end
    end
end

FallingIsaac:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, LazarusFalling)

-- Eden --
local function EdenFalling(_, player, cacheFlag)
    local s = player:GetSprite()
    if player:GetPlayerType() == PlayerType.PLAYER_EDEN then
      
        if s:GetFilename() ~= "gfx/EdenFalling.anm2" then
            s:Load("gfx/EdenFalling.anm2", true)
            s:Update()
        end
    end
end

FallingIsaac:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, EdenFalling)

 -- The Lost --
local function TheLostFalling(_, player, cacheFlag)
    local s = player:GetSprite()
    if player:GetPlayerType() == PlayerType.PLAYER_THELOST then
      
        if s:GetFilename() ~= "gfx/TheLostFalling.anm2" then
            s:Load("gfx/TheLostFalling.anm2", true)
            s:Update()
        end
    end
end

FallingIsaac:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, TheLostFalling)

-- The Keeper --
local function TheKeeperFalling(_, player, cacheFlag)
    local s = player:GetSprite()
    if player:GetPlayerType() == PlayerType.PLAYER_KEEPER then
      

        if s:GetFilename() ~= "gfx/TheKeeperFalling.anm2" then
            s:Load("gfx/TheKeeperFalling.anm2", true)
            s:Update()
        end
    end
end

FallingIsaac:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, TheKeeperFalling)

-- Apollyon --
local function ApollyonFalling(_, player, cacheFlag)
    local s = player:GetSprite()
    if player:GetPlayerType() == PlayerType.PLAYER_APOLLYON then
      
        if s:GetFilename() ~= "gfx/ApollyonFalling.anm2" then
            s:Load("gfx/ApollyonFalling.anm2", true)
            s:Update()
        end
    end
end

FallingIsaac:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, ApollyonFalling)

-- Beth --
local function BethFalling(_, player, cacheFlag)
    local s = player:GetSprite()
    if player:GetPlayerType() == PlayerType.PLAYER_BETHANY then
      
        if s:GetFilename() ~= "gfx/BethFalling.anm2" then
            s:Load("gfx/BethFalling.anm2", true)
            s:Update()
        end
    end
end

FallingIsaac:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, BethFalling)

-- Jacob --
local function JNEFalling(_, player, cacheFlag)
    local s = player:GetSprite()
    if player:GetPlayerType() == PlayerType.PLAYER_JACOB then
      
        if s:GetFilename() ~= "gfx/JNEFalling.anm2" then
            s:Load("gfx/JNEFalling.anm2", true)
            s:Update()
        end
    end
end

FallingIsaac:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, JNEFalling)

-- Esau --
local function EsauHide(_, player, cacheFlag)
    local s = player:GetSprite()
    if player:GetPlayerType() == PlayerType.PLAYER_ESAU then
      
        if s:GetFilename() ~= "gfx/Esauhide.anm2" then
            s:Load("gfx/Esauhide.anm2", true)
            s:Update()
        end
    end
end

FallingIsaac:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, EsauHide)