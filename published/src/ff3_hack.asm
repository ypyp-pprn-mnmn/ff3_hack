; ff3_hack.asm
;
; description:
;	master file to assmeble
;
; version:
;	0.09 (2006-10-12)
;
;----------------------------------------------------------------------------------------------------------
	.inesprg	$20		;total 512k
	.inesmap	$04		;MMC3
	.inesmir	$01		;horizontal
	.list
	.mlist
;----------------------------------------------------------------------------------------------------------
;assemble flags
REDRAW_ON_EQUIP_CHANGE
CONTINUE_ON_EQUIP_CHANGE
USE_ITOA8
GIVE_VIKING_PROVOKE
COMMAND_WINDOW_WIDTH		= 6		;original: 5
RANDOM_LCG_A				= 11	;original: 3;should be 8n+3; r[n+1] = a*r[n]+c mod #$400
UPDATE_FLAGS				= 0		;0:noupdate
;EXPERIMENTAL
;TEST_PROVOKE
;----------------------------------------------------------------------------------------------------------
	.incbin	"ff3_hack_base.nes"	;header must be stripped
	.include "ff3_asm.h"
	.bank	$00
	.org	$8000
	.include "ff3_string.asm"
	.include "ff3_item_window.asm"	;($b646 - $b4a8) bytes saved
	.include "ff3_magic_window.asm"	;($b8fd - $b886) bytes saved
	.include "ff3_command_window.asm"
	.include "ff3_rand.asm"
	;for available space reasons,
	; 'experimental' must be turned off in order to include below 2files
	.include "ff3_command_0a.asm"	;almost additional code (consumes free space)
	.include "ff3_window.asm"		;exceeds original size (consumes free space)
	.include "ff3_misc.asm"
	.ifdef EXPERIMENTAL
		.include "ff3_experimental.asm"
	.endif	
	;.include "ff3_battle_calc.asm"
;==========================================================================================================