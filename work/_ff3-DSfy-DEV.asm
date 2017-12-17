;; _ff3-DSfy-DEV.asm
;;	creates hacked file with features under development (and sometimes unstable) included
;;
;;=================================================================================================
;;feature flags.
BALANCED_VERSION
EXTRA_MAP

EXPERIMENTAL
EXPERIMENT_IMPL = 5	; encount test

;_OPTIMIZE_FIELD_WINDOW
_FEATURE_STOMACH_AMOUNT_1BYTE
_FEATURE_DEFERRED_RENDERING
_FIX_POISON
;; the below should be final line of this file
	.include "_ff3-DSfy.asm"
