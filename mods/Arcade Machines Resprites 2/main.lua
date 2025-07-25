local MachineRespritesMod = RegisterMod("Machine Resprites Armageddon", 1)

local GoldenMachineVariant

local function TryReplaceGoldenMachines()
    local goldenMachines = Isaac.FindByType(EntityType.ENTITY_SLOT, GoldenMachineVariant)

    for _, machine in ipairs(goldenMachines) do
        if not machine:GetData().HasBetterSpriteARMAGEDDON then
            local anim = machine:GetSprite():GetAnimation()
            machine:GetSprite():Load("gfx/better_golden_machine.anm2", true)
            machine:GetSprite():Play(anim, true)

            machine:GetData().HasBetterSpriteARMAGEDDON = true
        end
    end
end


local function TryReplaceRestockMachines()
    local restockMachines = Isaac.FindByType(EntityType.ENTITY_SLOT, 10)

    for _, machine in ipairs(restockMachines) do
        local data = machine:GetData()

        if not data.HasBetterSpriteARMAGEDDON then
            data.HasBetterSpriteARMAGEDDON = true

            local newSpritesheet = "gfx/slots/regular_restockmachine.png"
            if UNIQUE_COINS_MOD then newSpritesheet = "gfx/slots/uc_restockmachine.png" end

            local machineSpr = machine:GetSprite()

            for i = 0, machineSpr:GetLayerCount() - 1, 1 do
                if i ~= 4 or not UNIQUE_COINS_MOD then
                    machineSpr:ReplaceSpritesheet(i, newSpritesheet)
                end
            end

            machineSpr:LoadGraphics()
        end
    end
end


function MachineRespritesMod:OnFrameUpdate()
    if FiendFolio then
        if not GoldenMachineVariant then
            GoldenMachineVariant = Isaac.GetEntityVariantByName("Golden Slot Machine")
        end

        TryReplaceGoldenMachines()
    end

    TryReplaceRestockMachines()
end
MachineRespritesMod:AddCallback(ModCallbacks.MC_POST_UPDATE, MachineRespritesMod.OnFrameUpdate)


function MachineRespritesMod:OnNewRoom()
    if FiendFolio then
        if not GoldenMachineVariant then
            GoldenMachineVariant = Isaac.GetEntityVariantByName("Golden Slot Machine")
        end

        TryReplaceGoldenMachines()
    end

    TryReplaceRestockMachines()
end
MachineRespritesMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, MachineRespritesMod.OnNewRoom)