local BetterDonationMachinesMod = RegisterMod("Better Donation Machines", 1)
local game = Game()

local DonationMachineVariant = 8
local GreedDonationMachineVariant = 11

--[[
Shops: Level
    - 0: Level 1
    - 1: Level 2
    - 2: Level 3
    - 3: Level 4
    - 4: Level 5
    - 10: Rare (good)
    - 11: Rare (bad)
    - 100: Tainted Keeper L1
    - 101: Tainted Keeper L2
    - 102: Tainted Keeper L3
    - 103: Tainted Keeper L4
    - 104: Tainted Keeper L5
    - 110: Tainted Keeper rare (good)
    - 111: Tainted Keeper rare (bad)
]]

local SpriteLevelPerShopSubtypes = {
    [1] = {0, 1, 11, 100, 101, 111},
    [2] = {2, 102},
    [3] = {3, 103},
    [4] = {4, 10, 104, 110}
}

function BetterDonationMachinesMod:OnNewRoom()
    local room = game:GetRoom()

    local uniqueCoinsSuffix = ""
    if UNIQUE_COINS_MOD then
        uniqueCoinsSuffix = "_uc"
    end

    for _, donationMachine in ipairs(Isaac.FindByType(EntityType.ENTITY_SLOT, DonationMachineVariant)) do
        if not donationMachine:GetData().BetterDonationSprite then

            local spriteLevel

            if room:GetType() == RoomType.ROOM_SHOP then
                local level = game:GetLevel()
                local roomDesc = level:GetCurrentRoomDesc()
                local roomSubtype = roomDesc.Data.Subtype

                for sprlevel, subtypes in ipairs(SpriteLevelPerShopSubtypes) do
                    for _, subtype in ipairs(subtypes) do
                        if roomSubtype == subtype then
                            spriteLevel = sprlevel
                        end
                    end
                end
            else
                local shopLevel = room:GetShopLevel()

                --Do this so the shop level number is the same as the spritesheets
                shopLevel = shopLevel - 1
                spriteLevel = math.max(1, shopLevel)
            end

            local sprite = donationMachine:GetSprite()

            local spriteSheet = "/gfx/slots/donation_machine_lvl" .. spriteLevel .. uniqueCoinsSuffix .. ".png"

            for i = 0, sprite:GetLayerCount() - 1, 1 do
                if not (i == 4 and UNIQUE_COINS_MOD) then
                    sprite:ReplaceSpritesheet(i, spriteSheet)
                end
            end

            sprite:LoadGraphics()

            donationMachine:GetData().BetterDonationSprite = true
        end
    end

    for _, donationMachine in ipairs(Isaac.FindByType(EntityType.ENTITY_SLOT, GreedDonationMachineVariant)) do
        if not donationMachine:GetData().BetterDonationSprite then

            local sprite = donationMachine:GetSprite()

            local spriteSheet = "gfx/slots/donation_machine_greed" .. uniqueCoinsSuffix .. ".png"

            for i = 0, sprite:GetLayerCount() - 1, 1 do
                if not (i == 4 and UNIQUE_COINS_MOD) then
                    sprite:ReplaceSpritesheet(i, spriteSheet)
                end
            end

            sprite:LoadGraphics()

            donationMachine:GetData().BetterDonationSprite = true
        end
    end
end
BetterDonationMachinesMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, BetterDonationMachinesMod.OnNewRoom)
BetterDonationMachinesMod:AddCallback(ModCallbacks.MC_POST_UPDATE, BetterDonationMachinesMod.OnNewRoom)