--All bomb data

---Name: Name of the bomb. SpriteSheet gets replaced
---Priority: lower = renders first. higher = renders last
---Anm2: Path to the normal anm2 (non-golden)
---GoldAnm2: Path to the golden anm2 (golden bomb)
---[FIEND FOLIO COMPATIBILITY] CopperAnm2: Path to the copper anm2 (copper bomb)
---FrameName: Add later
---Frame: Frame numer in the anm2
---Condition: return if it should render. has player parameter
CustomBombHUDIcons.RenderBombsData =
{
    {
        Name = 'Blood Bombs',
        Priority = CustomBombHUDIcons.BombPriority.EARLY, --Since it has extra utility compared to other bombs, it goes first.

        Anm2 = "gfx/ui/bombSprites.anm2",
        GoldAnm2 = "gfx/ui/bombSpritesGold.anm2",
        CopperAnm2 = "gfx/ui/bombSpritesCopper.anm2",
        FrameName = "Bombs",
        Frame = 9,

        Condition = function (player)
            return player:HasCollectible(CollectibleType.COLLECTIBLE_BLOOD_BOMBS)
        end
    },
    {
        Name = 'Bobby-Bomb',
        Priority = CustomBombHUDIcons.BombPriority.DEFAULT,

        Anm2 = "gfx/ui/bombSprites.anm2",
        GoldAnm2 = "gfx/ui/bombSpritesGold.anm2",
        CopperAnm2 = "gfx/ui/bombSpritesCopper.anm2",
        FrameName = "Bombs",
        Frame = 1,

        Condition = function (player)
            return player:HasCollectible(CollectibleType.COLLECTIBLE_BOBBY_BOMB)
        end
    },
    {
        Name = 'Butt Bombs',
        Priority = CustomBombHUDIcons.BombPriority.DEFAULT,

        Anm2 = "gfx/ui/bombSprites.anm2",
        GoldAnm2 = "gfx/ui/bombSpritesGold.anm2",
        CopperAnm2 = "gfx/ui/bombSpritesCopper.anm2",
        FrameName = "Bombs",
        Frame = 2,

        Condition = function (player)
            return player:HasCollectible(CollectibleType.COLLECTIBLE_BUTT_BOMBS)
        end
    },
    {
        Name = 'Hot Bombs',
        Priority = CustomBombHUDIcons.BombPriority.DEFAULT,

        Anm2 = "gfx/ui/bombSprites.anm2",
        GoldAnm2 = "gfx/ui/bombSpritesGold.anm2",
        CopperAnm2 = "gfx/ui/bombSpritesCopper.anm2",
        FrameName = "Bombs",
        Frame = 3,

        Condition = function (player)
            return player:HasCollectible(CollectibleType.COLLECTIBLE_HOT_BOMBS)
        end
    },
    {
        Name = 'Sad Bombs',
        Priority = CustomBombHUDIcons.BombPriority.DEFAULT,

        Anm2 = "gfx/ui/bombSprites.anm2",
        GoldAnm2 = "gfx/ui/bombSpritesGold.anm2",
        CopperAnm2 = "gfx/ui/bombSpritesCopper.anm2",
        FrameName = "Bombs",
        Frame = 4,

        Condition = function (player)
            return player:HasCollectible(CollectibleType.COLLECTIBLE_SAD_BOMBS)
        end
    },
    {
        Name = 'Scatter Bombs',
        Priority = CustomBombHUDIcons.BombPriority.DEFAULT,

        Anm2 = "gfx/ui/bombSprites.anm2",
        GoldAnm2 = "gfx/ui/bombSpritesGold.anm2",
        CopperAnm2 = "gfx/ui/bombSpritesCopper.anm2",
        FrameName = "Bombs",
        Frame = 5,

        Condition = function (player)
            return player:HasCollectible(CollectibleType.COLLECTIBLE_SCATTER_BOMBS)
        end
    },
    {
        Name = 'Sticky Bombs',
        Priority = CustomBombHUDIcons.BombPriority.DEFAULT,

        Anm2 = "gfx/ui/bombSprites.anm2",
        GoldAnm2 = "gfx/ui/bombSpritesGold.anm2",
        CopperAnm2 = "gfx/ui/bombSpritesCopper.anm2",
        FrameName = "Bombs",
        Frame = 6,

        Condition = function (player)
            return player:HasCollectible(CollectibleType.COLLECTIBLE_STICKY_BOMBS)
        end
    },
    {
        Name = 'Bomber Boy',
        Priority = CustomBombHUDIcons.BombPriority.DEFAULT,

        Anm2 = "gfx/ui/bombSprites.anm2",
        GoldAnm2 = "gfx/ui/bombSpritesGold.anm2",
        CopperAnm2 = "gfx/ui/bombSpritesCopper.anm2",
        FrameName = "Bombs",
        Frame = 7,

        Condition = function (player)
            return player:HasCollectible(CollectibleType.COLLECTIBLE_BOMBER_BOY)
        end
    },
    {
        Name = 'Fast Bombs',
        Priority = CustomBombHUDIcons.BombPriority.DEFAULT,

        Anm2 = "gfx/ui/bombSprites.anm2",
        GoldAnm2 = "gfx/ui/bombSpritesGold.anm2",
        CopperAnm2 = "gfx/ui/bombSpritesCopper.anm2",
        FrameName = "Bombs",
        Frame = 8,

        Condition = function (player)
            return player:HasCollectible(CollectibleType.COLLECTIBLE_FAST_BOMBS)
        end
    },
    {
        Name = 'Ghost Bombs',
        Priority = CustomBombHUDIcons.BombPriority.DEFAULT,

        Anm2 = "gfx/ui/bombSprites.anm2",
        GoldAnm2 = "gfx/ui/bombSpritesGold.anm2",
        CopperAnm2 = "gfx/ui/bombSpritesCopper.anm2",
        FrameName = "Bombs",
        Frame = 10,

        Condition = function (player)
            return player:HasCollectible(CollectibleType.COLLECTIBLE_GHOST_BOMBS)
        end
    },
    {
        Name = 'Glitter Bombs',
        Priority = CustomBombHUDIcons.BombPriority.DEFAULT,

        Anm2 = "gfx/ui/bombSprites.anm2",
        GoldAnm2 = "gfx/ui/bombSpritesGold.anm2",
        CopperAnm2 = "gfx/ui/bombSpritesCopper.anm2",
        FrameName = "Bombs",
        Frame = 11,

        Condition = function (player)
            return player:HasCollectible(CollectibleType.COLLECTIBLE_GLITTER_BOMBS)
        end
    },
    {
        Name = 'Mr. Mega',
        Priority = CustomBombHUDIcons.BombPriority.DEFAULT,

        Anm2 = "gfx/ui/bombSprites.anm2",
        GoldAnm2 = "gfx/ui/bombSpritesGold.anm2",
        CopperAnm2 = "gfx/ui/bombSpritesCopper.anm2",
        FrameName = "Bombs",
        Frame = 12,

        Condition = function (player)
            return player:HasCollectible(CollectibleType.COLLECTIBLE_MR_MEGA)
        end
    },
    {
        Name = 'Nancy Bombs',
        Priority = CustomBombHUDIcons.BombPriority.DEFAULT,

        Anm2 = "gfx/ui/bombSprites.anm2",
        GoldAnm2 = "gfx/ui/bombSpritesGold.anm2",
        CopperAnm2 = "gfx/ui/bombSpritesCopper.anm2",
        FrameName = "Bombs",
        Frame = 13,

        Condition = function (player)
            return player:HasCollectible(CollectibleType.COLLECTIBLE_NANCY_BOMBS)
        end
    },
    {
        Name = 'Rocket in a Jar',
        Priority = CustomBombHUDIcons.BombPriority.DEFAULT,

        Anm2 = "gfx/ui/bombSprites.anm2",
        GoldAnm2 = "gfx/ui/bombSpritesGold.anm2",
        CopperAnm2 = "gfx/ui/bombSpritesCopper.anm2",
        FrameName = "Bombs",
        Frame = 14,

        Condition = function (player)
            return player:HasCollectible(CollectibleType.COLLECTIBLE_ROCKET_IN_A_JAR)
        end
    },
    {
        Name = 'Brimstone Bombs',
        Priority = CustomBombHUDIcons.BombPriority.DEFAULT,

        Anm2 = "gfx/ui/bombSprites.anm2",
        GoldAnm2 = "gfx/ui/bombSpritesGold.anm2",
        CopperAnm2 = "gfx/ui/bombSpritesCopper.anm2",
        FrameName = "Bombs",
        Frame = 15,

        Condition = function (player)
            return player:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE_BOMBS)
        end
    },
    {
        Name = "Bob's Curse",
        Priority = CustomBombHUDIcons.BombPriority.DEFAULT,

        Anm2 = "gfx/ui/bombSprites.anm2",
        GoldAnm2 = "gfx/ui/bombSpritesGold.anm2",
        CopperAnm2 = "gfx/ui/bombSpritesCopper.anm2",
        FrameName = "Bombs",
        Frame = 16,

        Condition = function (player)
            return player:HasCollectible(CollectibleType.COLLECTIBLE_BOBS_CURSE)
        end
    },
}

--Had to add them again??? why wtf idk what I did but this IS necessary. Try removing this and see if it works 
CustomBombHUDIcons:AddPriorityBombIcon(CustomBombHUDIcons.BombPriority.EARLY,
{
    Name = 'Blood Bombs',
    Priority = CustomBombHUDIcons.BombPriority.EARLY, --Since it has extra utility compared to other bombs, it goes first.

    Anm2 = "gfx/ui/bombSprites.anm2",
    GoldAnm2 = "gfx/ui/bombSpritesGold.anm2",
    CopperAnm2 = "gfx/ui/bombSpritesCopper.anm2",
    FrameName = "Bombs",
    Frame = 9,

    Condition = function (player)
        return player:HasCollectible(CollectibleType.COLLECTIBLE_BLOOD_BOMBS)
    end
}
)