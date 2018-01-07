;; _ff3-DSfy-only-fast-window.asm
;;
;;	creates a patch merely including 'fast window rendering' feature
;;
;==================================================================================================
;; feature flags.
__HACK_FOR_FF3C

_OPTIMIZE_FIELD_WINDOW
_FEATURE_STOMACH_AMOUNT_1BYTE
_FEATURE_DEFERRED_RENDERING
_FEATURE_MEMOIZE_BANK_SWITCH
_FEATURE_FAST_ELIGIBILITY
_FEATURE_FAST_BATTLE_WINDOW_ERASE

_NO_INIT_PATCH_SPACE
_DISABLE_THIEF_LOCKPICKING

TREASURE_ARROW_AMOUNT = 24
JOB_AVAILABILITY.NO_CRYSTAL = $00
JOB_AVAILABILITY.WIND = $05
JOB_AVAILABILITY.FIRE = $09
JOB_AVAILABILITY.WATER = $10
JOB_AVAILABILITY.EARTH = $13
JOB_AVAILABILITY.EUREKA = $15	;;original == 30

items.CONSUMABLES_BEGIN = $a2	;;original = $98
items.CONSUMABLES_END = $c8	;;original = $c8

;; the below should be the final line of this file
	.include "_build-master.asm"
