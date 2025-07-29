import {
  EntityType,
  PickupVariant,
} from "isaac-typescript-definitions"
import {
  game,
  initModFeatures,
  ModCallbackCustom,
  upgradeMod,
} from "isaacscript-common"
import { initEID } from "./compatibility/EID"
import { TaroReverse } from "./features/taroReverse"

export function main(): void {
  const DEBUG = false

  const modVanilla = RegisterMod("TaroReverse", 1)

  const mod = upgradeMod(modVanilla)
  const MOD_FEATURES = [TaroReverse] as const

  // @ts-ignore
  initEID(mod)

  initModFeatures(mod, MOD_FEATURES)

  if (DEBUG) {
    const taroReverseID = Isaac.GetItemIdByName(
      "Taro Reverse"
    )

    mod.AddCallbackCustom(
      ModCallbackCustom.POST_GAME_STARTED_REORDERED,
      () => {
        game.Spawn(
          EntityType.PICKUP,
          PickupVariant.COLLECTIBLE,
          Vector(200, 200),
          Vector(0, 0),
          undefined,
          taroReverseID,
          game.GetSeeds().GetStartSeed()
        )
      },
      undefined
    )
  }
}
