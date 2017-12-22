;; _ff3-DSfy-only-fast-window.asm
;;
;;	creates a patch merely including 'fast window rendering' feature
;;
;==================================================================================================
;; feature flags.

_OPTIMIZE_FIELD_WINDOW
_FEATURE_STOMACH_AMOUNT_1BYTE
_FEATURE_DEFERRED_RENDERING
; the below should be the final line of this file
	.include "_build-master.asm"
