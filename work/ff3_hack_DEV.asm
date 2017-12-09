; ff3_hack_extra_map.asm
;
; description:
;	creates hacked file with features under development (and sometimes unstable) included
;
;======================================================================================================
;assemble flags
BALANCED_VERSION
EXTRA_MAP

EXPERIMENTAL
EXPERIMENT_IMPL = 5	; encount test

FAST_FIELD_WINDOW
STOMACH_AMOUNT_1BYTE
; the below should be final line of this file
	.include "ff3_hack_beta.asm"