;; _ff3-DSfy-only-fast-window.asm
;;
;;	creates a patch merely including 'fast window rendering' feature
;;
;==================================================================================================
;; feature flags.

_OPTIMIZE_FIELD_WINDOW
_FEATURE_STOMACH_AMOUNT_1BYTE
_FEATURE_DEFERRED_RENDERING

_NO_INIT_PATCH_SPACE
_DISABLE_THIEF_LOCKPICKING
__HACK_FOR_FF3C

TREASURE_ARROW_AMOUNT = 24
JOB_AVAILABILITY.NO_CRYSTAL = $00
JOB_AVAILABILITY.WIND = $05
JOB_AVAILABILITY.FIRE = $09
JOB_AVAILABILITY.WATER = $10
JOB_AVAILABILITY.EARTH = $13
JOB_AVAILABILITY.EUREKA = $15	;;original == 30

;; TODO:
;;	add fix for 'STOMACH PAGING'

; the below should be the final line of this file
	.include "_build-master.asm"
