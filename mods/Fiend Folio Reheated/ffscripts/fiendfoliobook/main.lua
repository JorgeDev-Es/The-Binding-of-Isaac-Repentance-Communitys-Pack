--mostly just wanted to get this thing organized before it devolved into a giant 2000 line file

local bentry = "ffscripts.fiendfoliobook."
FiendFolio.LoadScripts({
    bentry .. "battie",
    bentry .. "monsoon",
    bentry .. "technopin",
    bentry .. "buster",
    bentry .. "pollution",
    bentry .. "slammers",
})

--TODO: Slammer code, fix buster's commissions damaging Isaac

local mod = FiendFolio
local game = Game()
local nilvector = Vector.Zero
local sfx = SFXManager()

local fiendFolioSubs = {
    0, 1, 2, 3, 4, 5
}

mod:AddCallback(ModCallbacks.MC_USE_ITEM, function(_, ItemID, rng, player, flags)
	sfx:Play(mod.Sounds.FiendFolioBook, 1, 0, false, 1)

    mod.scheduleForUpdate(function()
        local famsub = fiendFolioSubs[math.random(#fiendFolioSubs)]
        while famsub == player:GetData().lastFiendFolioBookSpawned do
            famsub = fiendFolioSubs[math.random(#fiendFolioSubs)]
        end
        if mod.GetEntityCount(mod.FF.Battie.ID, mod.FF.Battie.Var) > 0 then
            famsub = 0
        end
        --famsub = 5
        player:GetData().lastFiendFolioBookSpawned = famsub
        local fam = Isaac.Spawn(3, FamiliarVariant.FF_BOOK_HELPER, famsub, player.Position, nilvector, player):ToFamiliar()
        fam:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
        fam:Update()
    end, 35)

    if flags & UseFlag.USE_CARBATTERY == 0 then
        mod.FFGiantBook = game:GetFrameCount()
        mod.PauseGame(35)
    end
    return true
end, mod.ITEM.COLLECTIBLE.FIEND_FOLIO)

mod:AddCallback(ModCallbacks.MC_POST_RENDER, function()
    if mod.FFGiantBook then
        local sprite = Sprite()
        sprite:Load("gfx/ui/giantbook/giantbook_ff.anm2", true)
        sprite:SetFrame("Appear", game:GetFrameCount() - mod.FFGiantBook)
        sprite:Render(Vector(Isaac.GetScreenWidth()/2, Isaac.GetScreenHeight()/2), nilvector, nilvector)
        if (game:GetFrameCount() - mod.FFGiantBook) >= 35 then
            mod.FFGiantBook = false
        end
    end
end)

mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, function(_, fam)
    local player = fam.Player
	local d = fam:GetData()
	local sprite = fam:GetSprite()
    if fam.SubType == 0 then
        mod:famBattie(fam, player, sprite, d)
    elseif fam.SubType == 1 then
        mod:famMonsoon(fam, player, sprite, d)
    elseif fam.SubType == 2 then
        mod:famPollution(fam, player, sprite, d)
    elseif fam.SubType == 3 then
        mod:famTechnopin(fam, player, sprite, d)
    elseif fam.SubType == 4 then
        mod:famBuster(fam, player, sprite, d)
    elseif fam.SubType == 5 then
        mod:famSlammer(fam, player, sprite, d)
    elseif fam.SubType > 99 and fam.SubType < 200 then
        mod:famSlammerToo(fam, player, sprite, d)
    end
end, FamiliarVariant.FF_BOOK_HELPER)