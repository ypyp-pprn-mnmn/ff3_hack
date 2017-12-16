; _ff3-DSfy-extra-map.asm
;
; description:
;	creates hacked file based off a version with 'extra' maps added
;
;======================================================================================================
;assemble flags
BALANCED_VERSION
EXTRA_MAP
EXPERIMENTAL
EXPERIMENT_IMPL = 5	; encount test
	.include "_ff3-DSfy.asm"
