;; _ff3-DSfy-only-fast-window.asm
;;
;;	creates a patch merely including 'fast window rendering' feature
;;
;==================================================================================================
;; feature flags.

_OPTIMIZE_FIELD_WINDOW
_FEATURE_STOMACH_AMOUNT_1BYTE
_FEATURE_DEFERRED_RENDERING
_FIX_POISON
POISON_DAMAGE_SHIFT = 3

JOB_AVAILABILITY.NO_CRYSTAL = $00
JOB_AVAILABILITY.WIND = $05
JOB_AVAILABILITY.FIRE = $0a	;;original == 09
JOB_AVAILABILITY.WATER = $10
JOB_AVAILABILITY.EARTH = $30	;;original == 13
JOB_AVAILABILITY.EUREKA = $30

MAX_PLAYER_LV = 65
; the below should be the final line of this file
	.include "_build-master.asm"
