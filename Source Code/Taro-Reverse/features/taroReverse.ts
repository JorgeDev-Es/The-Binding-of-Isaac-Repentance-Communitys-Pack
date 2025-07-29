import {
	type CollectibleType,
	ModCallback,
	SoundEffect,
} from "isaac-typescript-definitions"
import { Callback, ModFeature } from "isaacscript-common"

export class TaroReverse extends ModFeature {
	taroReverseID = Isaac.GetItemIdByName("Taro Reverse")

	@Callback(ModCallback.POST_USE_ITEM)
	onTaroReverseUse(
		collectibleType: CollectibleType,
		_rng: RNG,
		player: EntityPlayer,
	): boolean | { Discharge: boolean; Remove: boolean; ShowAnim: boolean } {
		if (collectibleType !== this.taroReverseID) return false

		const cardId = player.GetCard(0)

		if (cardId === 0) {
			return { Discharge: false, Remove: false, ShowAnim: false }
		}

		if (cardId > 0 && cardId < 23) {
			player.SetCard(0, cardId + 55)
			SFXManager().Play(SoundEffect.MENU_FLIP_DARK)
		} else if (cardId > 55 && cardId < 78) {
			player.SetCard(0, cardId - 55)
			SFXManager().Play(SoundEffect.MENU_FLIP_LIGHT)
		}

		return { Discharge: false, Remove: false, ShowAnim: false }
	}
}
