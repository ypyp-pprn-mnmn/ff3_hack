; ff3_hack.asm
;
; description:
;	creates hacked file without yet-unstable features
;
; version:
;	0.03(2006-10-20)
;
;======================================================================================================
;assemble flags
ENABLE_strToTileArray

REDRAW_ON_EQUIP_CHANGE
CONTINUE_ON_EQUIP_CHANGE
USE_ITOA8
FIX_ATTR_BOOST
FIX_HP_GROW
FIX_ITEM99
COMMAND_WINDOW_WIDTH		= 6		;original: 5
RANDOM_LCG_A				= 11	;original: 3;should be 8n+3; r[n+1] = a*r[n]+c mod #$400

;TEST_PROVOKE
GIVE_VIKING_PROVOKE
;TAG_PROVOKE_EFFECT
;PROVOKE_TARGET_SINGLE
PROVOKE_EFFECT_REMAIN = 1

UPDATE_FLAGS				= 0		;0:noupdate
;EXPERIMENTAL
;======================================================================================================
	.include "ff3_hack_master.asm"