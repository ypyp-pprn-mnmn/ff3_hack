; ff3_hack_only_fast_window.asm
;
; description:
;	creates a patch merely including 'fast window rendering' feature
;
;======================================================================================================
;assemble flags
;BALANCED_VERSION
;EXTRA_MAP
;EXPERIMENTAL
;EXPERIMENT_IMPL = 5	; encount test

_OPTIMIZE_FIELD_WINDOW
_FEATURE_STOMACH_AMOUNT_1BYTE
_FEATURE_DEFERRED_RENDERING
; the below should be final line of this file
	.include "ff3_hack_master.asm"