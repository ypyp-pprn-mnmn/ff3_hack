;; _ff3-DSfy-fix-and-optimization-only.asm
;;	creates a patch without any extensions to the behaviors of the original version.
;;
;; version:
;;	0.4(2017-12-17)
;;
;;=================================================================================================
;assemble flags
ENABLE_strToTileArray

REDRAW_ON_EQUIP_CHANGE
CONTINUE_ON_EQUIP_CHANGE
USE_ITOA8
FIX_ATTR_BOOST
FIX_HP_GROW
FIX_ITEM99
COMMAND_WINDOW_WIDTH = 6 ;original: 5
RANDOM_LCG_A = 11 ;original: 3;should be 8n+3; r[n+1] = a*r[n]+c mod #$400

PROVOKE_EFFECT_REMAIN = 1

UPDATE_FLAGS = 0 ;0:noupdate
;==================================================================================================
	.include "_build-master.asm"
