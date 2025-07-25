local function TMplusCompatibility()
	TMplus.TMPSlotIndex = { --Vanilla machines
		[1] = {"Slot Machine", true}, 
		[2] = {"Blood Donation Machine", true}, 
		[3] = {"Fortune Telling Machine", true}, 
		[4] = {"Beggar", true}, 
		[5] = {"Devil Beggar", true}, 
		[6] = {"Shell Game", true}, 
		[7] = {"Key Master", true}, 
		[8] = {"Donation Machine", false}, 
		[9] = {"Bomb Bum", true}, 
		[10] = {"Restock Machine", true}, 
		[11] = {"Greed Donation Machine", false}, 
		[12] = {"Mom's Dressing Table", true}, 
		[13] = {"Battery Bum", true}, 
		[15] = {"Hell Game", true}, 
		[16] = {"Crane Game", true}, 
		[17] = {"Confessional", true},
		[18] = {"Rotten Beggar", true}, 
		[19] = {"Revive Machine", false}, 
	}
	TMplus:AddCompatibility("Vanilla", TMplus.version, TMplus.TMPSlotIndex)
	if FiendFolio then
		if not TMplus.FiendFolioTMPSlotIndex then
			TMplus.FiendFolioTMPSlotIndex = { --Fiend Folio Machines
				[1037] = {"Hug Beggar", false}, 
				[1033] = {"Evil Beggar", false}, 
				[1031] = {"Zodiac Beggar", true}, 
				[1036] = {"Cell Game", true}, 
				[1030] = {"Blacksmith", false}, 
				[1034] = {"Fake Beggar", false}, 
				[1035] = {"Dealer", false}, 
				[160] = {"Poker Table", false}, 
				[880] = {"Grid Restock Machine", false}, 
				[1032] = {"Robot Fortune Teller", true}, 
				[1100] = {"Vending Machine (Vanilla)", true}, 
				[1101] = {"Vending Machine (Fiend Folio)", true}, 
				[1040] = {"Golden Slot Machine", true}, 
			}
		end
		TMplus:AddCompatibility("Fiend Folio", 2.85, TMplus.FiendFolioTMPSlotIndex)
	end
	if Retribution then
		if not TMplus.RetributionTMPSlotIndex then
				TMplus.RetributionTMPSlotIndex = { --Retribution Machines
				[1873] = {"Swine Beggar", true}, 
				[1874] = {"Angelic Swine Beggar", true}, 
				[1875] = {"Demonic Swine Beggar", true}, 
				[1876] = {"Gashapon", true}, 
				[1877] = {"Butapon", true}, 
				[1878] = {"Daedalus Statue", true}, 
				[1879] = {"Curse Trader", true}, 
				[1881] = {"Bougie Pedestal", false}, 
				[1882] = {"Restock Machine (RETRIBUTION)", false}, 
			}
		end
		TMplus:AddCompatibility("Retribution", 3.3, TMplus.RetributionTMPSlotIndex)
	end
	if Epiphany then
		if not TMplus.EpiphanyTMPSlotIndex then
			TMplus.EpiphanyTMPSlotIndex = { --Epiphany Machines
				[1001] = {"Dice Machine", true}, 
				[1002] = {"Converter Beggar", true}, 
				[1003] = {"Glitch Machine", true}, 
				[1004] = {"Pain-o-matic Machine", true}, 
				[1005] = {"Golden Restock Machine", false}, 
				[1006] = {"Tithe Box", true}, 
			}
		end
		TMplus:AddCompatibility("Epiphany", Epiphany.WAVE_NUMBER, TMplus.EpiphanyTMPSlotIndex)
	end
	if RepentancePlusMod then
		if not TMplus.RepPlusTMPSlotIndex then
			TMplus.RepPlusTMPSlotIndex = { --Repentance Plus Machine
				[335] = {"Stargazer", true}, 
			}
		end
		TMplus:AddCompatibility("Rep. Plus!", 1.34, TMplus.RepPlusTMPSlotIndex)
	end
	if MilkshakeVol1 then
		if not TMplus.Reshaken1TMPSlotIndex then
			TMplus.Reshaken1TMPSlotIndex = { --Reshaken Vol 1 Machine
				[504] = {"Brenda's Spirit Klin [sic]", true}, 
			}
		end
		TMplus:AddCompatibility("Reshaken #1", 1.0, TMplus.Reshaken1TMPSlotIndex)
	end
	if ARACHNAMOD then
		if not TMplus.ArachnaTMPSlotIndex then
			TMplus.ArachnaTMPSlotIndex = { --The variable doesn't exist if I check for it here, thus not creating the table, but it does exist when I check for it in the compatibility function, thus causing a crash when trying to process the nonexistent table. Words cannot describe my confusion
				[2000] = {"Spider Boi", true}, 
			}
		end
		TMplus:AddCompatibility("Arachna", 1.1, TMplus.ArachnaTMPSlotIndex)
	end
end
TMplus:AddCallback("TM+_REQUEST_COMPATIBILITY_DATA", TMplusCompatibility) --Sends over all built-in data when the main mod asks for it