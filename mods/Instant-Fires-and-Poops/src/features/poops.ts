import {
	GridEntityType,
	ModCallback,
	type PoopState,
} from "isaac-typescript-definitions"
import {
	Callback,
	CallbackCustom,
	game,
	getGridEntities,
	ModCallbackCustom,
	ModFeature,
} from "isaacscript-common"

export class Poops extends ModFeature {
	isRoomEmpty: boolean = false
	poops = new Map<Seed, PoopState>()

	@Callback(ModCallback.POST_UPDATE)
	onUpdate(): void {
		this.isRoomEmpty = game.GetRoom().IsClear()
	}

	@CallbackCustom(ModCallbackCustom.POST_NEW_ROOM_REORDERED)
	onNewRoomReordered(): void {
		this.registerPoops()
	}

	@CallbackCustom(ModCallbackCustom.POST_POOP_UPDATE)
	poopTakeDamage(poop: GridEntityPoop): void {
		const seed = poop.GetRNG().GetSeed()
		const state = poop.State

		if (!this.isRoomEmpty) {
			this.poops.set(seed, state)
			return
		}

		if (!this.poops.has(seed)) {
			poop.Destroy(false)
			this.poops.delete(seed)
			return
		}

		if (state !== this.poops.get(seed)) {
			poop.Destroy(false)
			this.poops.delete(seed)
		}
	}

	registerPoops() {
		this.poops.clear()
		for (const entity of getGridEntities(GridEntityType.POOP)) {
			const poop = entity.ToPoop()

			if (poop === undefined) {
				continue
			}

			const seed = poop.GetRNG().GetSeed()
			const state = poop.State

			this.poops.set(seed, state)
		}
	}
}
