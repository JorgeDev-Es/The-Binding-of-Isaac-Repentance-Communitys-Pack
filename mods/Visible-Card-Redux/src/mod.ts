import { ISCFeature, initModFeatures, upgradeMod } from "isaacscript-common"
import { Cards, data } from "./features/cards"

export function main(): void {
	const modVanilla = RegisterMod("VisibleCardsRedux", 1)
	const mod = upgradeMod(modVanilla, [ISCFeature.SAVE_DATA_MANAGER] as const)

	const MOD_FEATURES = [Cards] as const

	initModFeatures(mod, MOD_FEATURES)

	mod.saveDataManager("Cards", data)

	Isaac.DebugString("--------------------------")
	Isaac.DebugString("Visible Cards Redux Loaded")
}
