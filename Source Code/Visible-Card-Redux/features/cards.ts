import {
	CardType,
	EntityType,
	ModCallback,
	PickupVariant,
} from "isaac-typescript-definitions"
import {
	Callback,
	CallbackCustom,
	ModCallbackCustom,
	ModFeature,
} from "isaacscript-common"

export const data = {
	level: {
		collectedCards: new Set<number>(),
	},
}

export class Cards extends ModFeature {
	shouldReplaceCard = new Set([
		1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21,
		22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 42, 44, 46, 48, 52, 53, 54, 56, 57,
		58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76,
		79,
	])
	cardAnm = "gfx/VisibleCard.anm2"
	pendingReplacementCards: EntityPickup[] = []

	@CallbackCustom(ModCallbackCustom.POST_PEFFECT_UPDATE_REORDERED)
	onPostPeffectUpdateOrdered(): void {
		for (const card of this.pendingReplacementCards) {
			const isVisible = data.level.collectedCards.has(card.InitSeed)

			if (isVisible) {
				const sprite = card.GetSprite()
				const spritesheet = `gfx/ui/Card_${card.SubType.toString().padStart(2, "0")}.png`
				const appear = sprite.IsPlaying("Appear")

				sprite.Load(this.cardAnm, false)
				sprite.ReplaceSpritesheet(0, spritesheet)
				sprite.ReplaceSpritesheet(1, spritesheet)
				sprite.LoadGraphics()
				if (appear) {
					sprite.Play("Appear", true)
				} else {
					sprite.Play("Idle", true)
				}
				sprite.Update()
			}
		}
		this.pendingReplacementCards = []
	}

	@Callback(ModCallback.POST_PICKUP_INIT, PickupVariant.CARD)
	onPostPickupInit(pickup: EntityPickup): void {
		if (
			pickup.Variant === PickupVariant.CARD &&
			CardType[pickup.SubType] != null &&
			this.shouldReplaceCard.has(pickup.SubType)
		) {
			const spawnerEntity = pickup.SpawnerEntity
			this.pendingReplacementCards.push(pickup)

			if (spawnerEntity && spawnerEntity.Type === EntityType.PLAYER) {
				data.level.collectedCards.add(pickup.InitSeed)
			}
		}
	}
}
