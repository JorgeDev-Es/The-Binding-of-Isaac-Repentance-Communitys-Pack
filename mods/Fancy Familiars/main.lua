local mod = RegisterMod("Fancy Familiars", 1)

function mod:ActivateAnimations()
  if AnimatedItemsAPI then
    AnimatedItemsAPI:SetAnimationForCollectible(095, "fancyRoboBabyAnimated.anm2")
    AnimatedItemsAPI:SetAnimationForCollectible(248, "fancyHiveMindAnimated.anm2")
    AnimatedItemsAPI:SetAnimationForCollectible(267, "fancyRoboBaby20Animated.anm2")
	AnimatedItemsAPI:SetAnimationForCollectible(269, "fancyHeadlessBabyAnimated.anm2")
	AnimatedItemsAPI:SetAnimationForCollectible(320, "fancyBlueBabysOnlyFriendAnimated.anm2")
	AnimatedItemsAPI:SetAnimationForCollectible(426, "fancyObsessedFanAnimated.anm2")
	AnimatedItemsAPI:SetAnimationForCollectible(430, "fancyPapaFlyAnimated.anm2")
	AnimatedItemsAPI:SetAnimationForCollectible(431, "fancyMultidimensionalBabyAnimated.anm2")
	AnimatedItemsAPI:SetAnimationForCollectible(469, "fancyDepressionAnimated.anm2")
	AnimatedItemsAPI:SetAnimationForCollectible(528, "fancyAngelicPrismAnimated.anm2")
	AnimatedItemsAPI:SetAnimationForCollectible(693, "fancyTheSwarmAnimated.anm2")
	AnimatedItemsAPI:SetAnimationForCollectible(702, "fancyVengefulSpiritAnimated.anm2")
  end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.ActivateAnimations)