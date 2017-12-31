;; _ff3-DSfy-DEV.asm
;;	creates hacked file with features under development (and sometimes unstable) included
;;
;;=================================================================================================
;;feature flags.
BALANCED_VERSION
EXTRA_MAP

EXPERIMENTAL
;EXPERIMENT_IMPL = 5	; encount test
EXPERIMENT_IMPL = 4	; sound test

;_OPTIMIZE_FIELD_WINDOW
;_FEATURE_STOMACH_AMOUNT_1BYTE
;_FEATURE_DEFERRED_RENDERING
;_FIX_POISON
;_FIX_REFLECTION
POISON_DAMAGE_SHIFT = 1
_FEATURE_MEMOIZE_BANK_SWITCH
_FEATURE_FAST_ELIGIBILITY

;JOB_AVAILABILITY.NO_CRYSTAL = $00
;JOB_AVAILABILITY.WIND = $05
;JOB_AVAILABILITY.FIRE = $09	;;original == 09
;JOB_AVAILABILITY.WATER = $10
;JOB_AVAILABILITY.EARTH = $13	;;original == 13
;JOB_AVAILABILITY.EUREKA = $30

;; the below should be the final line of this file
	.include "_ff3-DSfy.asm"
