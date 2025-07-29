import { EntityType, FireplaceVariant } from "isaac-typescript-definitions"
import {
	CallbackCustom,
	game,
	ModCallbackCustom,
	ModFeature,
} from "isaacscript-common"

export class Fires extends ModFeature {
	@CallbackCustom(
		ModCallbackCustom.ENTITY_TAKE_DMG_FILTER,
		EntityType.FIREPLACE,
		FireplaceVariant.NORMAL,
	)
	fireplaceTakeDamage(entity: Entity): boolean | undefined {
		if (game.GetRoom().IsClear()) {
			entity.Die()
		}

		return true
	}
}
