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
_OPTIMIZE_SOUND_DRIVER
;_FEATURE_STOMACH_AMOUNT_1BYTE
;_FEATURE_DEFERRED_RENDERING
;_FEATURE_MEMOIZE_BANK_SWITCH
;_FEATURE_FAST_ELIGIBILITY
;_FEATURE_FAST_BATTLE_WINDOW
;_FEATURE_FAST_BATTLE_WINDOW_ERASE
_FEATURE_CONTINUOUS_MUSIC
;_FIX_POISON
;_FIX_REFLECTION
POISON_DAMAGE_SHIFT = 1

;JOB_AVAILABILITY.NO_CRYSTAL = $00
;JOB_AVAILABILITY.WIND = $05
;JOB_AVAILABILITY.FIRE = $09	;;original == 09
;JOB_AVAILABILITY.WATER = $10
;JOB_AVAILABILITY.EARTH = $13	;;original == 13
;JOB_AVAILABILITY.EUREKA = $30

;; usually the below would be the final line of this file
	.include "_ff3-DSfy.asm"
;;
	.bank $3f
	.org $e1bc
	;; palette entries for menu.
	;; --- BG.
	;.db $0F,$00,$01,$2A
	.db $03,$00,$03,$35
	;.db $0F,$00,$01,$27
	.db $0F,$00,$03,$27
	;.db $0F,$00,$01,$24
	.db $0F,$00,$03,$24
	;.db $0F,$00,$01,$30
	.db $0F,$13,$03,$20
	;; --- sprites.
	.db $0F,$36,$30,$16
	.db $0F,$27,$18,$21
	.db $0F,$36,$17,$2A
	.db $0F,$00,$10,$30
;;