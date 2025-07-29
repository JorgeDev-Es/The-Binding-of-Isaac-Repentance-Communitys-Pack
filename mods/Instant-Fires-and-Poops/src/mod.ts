import { initModFeatures, upgradeMod } from "isaacscript-common"
import { Fires } from "./features/fires"
import { Poops } from "./features/poops"

export function main(): void {
	const modVanilla = RegisterMod("InstantFiresAndPoops", 1)

	const mod = upgradeMod(modVanilla)
	const MOD_FEATURES = [Fires, Poops] as const

	initModFeatures(mod, MOD_FEATURES)
}
