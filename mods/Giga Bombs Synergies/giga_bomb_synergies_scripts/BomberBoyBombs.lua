GigaBombsSynergiesMod.AddGigaBombSynergy(
    "GigaBomberBoyBomb",
    function (bomb)
        return bomb:HasTearFlags(TearFlags.TEAR_CROSS_BOMB)
    end
)