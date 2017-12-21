; macro.h.asm
;
; macro definitions
;======================================================================================================
INIT16	.macro	;addr,val
	lda #LOW(\2)
	sta \1
	lda #HIGH(\2)
	sta \1+1
		.endm

INIT16_x	.macro	;addr,val
	ldx #LOW(\2)
	stx \1
	ldx #HIGH(\2)
	stx \1+1
		.endm
			
ADD16	.macro	;addr,val		
	lda \1
	clc
	adc #LOW(\2)
	sta \1
	lda \1+1
	adc #HIGH(\2)
	sta \1+1
		.endm

ADD16by8	.macro
	lda \1
	clc
	adc \2
	sta \1
	bcc .add16by8_\@
		inc \1+1
	.add16by8_\@:
	.endm

SUB16	.macro	;addr,val		
	lda \1
	sec
	sbc #LOW(\2)
	sta \1
	lda \1+1
	sbc #HIGH(\2)
	sta \1+1
		.endm

SUB16by8	.macro	;addr,val
	lda \1
	sec
	sbc \2
	sta \1
	bcs .sub16by8_\@
		dec \1+1
	.sub16by8_\@:
	.endm
;------------------------------------------------------------------------------
FILEORG	.macro
	.bank	(\1) >> 13
	.org	($8000 | ((\1) & $7fff))
		.endm
		
RESTORE_PC	.macro
	.bank	BANK(\1)
	.org	\1
		.endm

	.ifdef _NO_INIT_PATCH_SPACE
RESERVE_PATCH_SPACE	.macro
			._reserve_\@:
			.org ._reserve_\@ + \1
		.endm
	.else
RESERVE_PATCH_SPACE	.macro
			.ds	\1
		.endm
	.endif

INIT_PATCH	.macro
	.bank	\1
	.org	\2
	__patch_begin_\@:
	;.ds		((\3) - (\2))
	RESERVE_PATCH_SPACE ((\3) - (\2))
	__patch_end_\@:
	.org	\2
		.endm
;; ------------------------------------------------------------------------------------------------
;tag, bank, start, end, org
INIT_PATCH_EX	.macro
		.bank	\2
		.if \5 > \3
			.org	\5
			__patch_begin_\1:
			;.ds		((\4) - (\5))
			RESERVE_PATCH_SPACE	((\4) - (\5))
			__patch_end_\1:
		.else
			.org	\3
			__patch_begin_\1:
			;.ds		((\4) - (\3))
			RESERVE_PATCH_SPACE	((\4) - (\3))
			__patch_end_\1:
		.endif
		.org	\5
	.endm

VERIFY_PC_TO_PATCH_END	.macro
		VERIFY_PC __patch_end_\1
	.endm

RESTORE_PC_TO_PATCH_END	.macro
		RESTORE_PC __patch_end_\1
	.endm

;; ------------------------------------------------------------------------------------------------
	.ifdef RESPECT_ORIGINAL_ADDR
ORIGINAL_ADDR	.macro
	.org	\1
	.endm
	.else
ORIGINAL_ADDR	.macro
		.endm
	.endif
	
ALIGN_EVEN	.macro	;value to align
	.check_align_\@:
	.if (.check_align_\@ & 1) != 0
		nop	;pad
	.endif
	.endm	;ALIGN_EVEN

VERIFY_PC	.macro
	.verify_pc_\@:
	.if (.verify_pc_\@ > \1)
		.fail
	.endif
	.endm	;VERIFY_PC

FIX_ADDR_ON_CALLER	.macro
	__patch_addr_\@:
	.bank \1
	.org \2
	;;sanity checks
	.if ((\2 >> 13) & 1) != (\1 & 1)
		.fail	;even banks would fall in address ranges starting at $8000 or $c000, and for odd ones it would be $a000 or $e000.
	.endif;
	;;ok
	.dw __patch_addr_\@
	RESTORE_PC __patch_addr_\@
	.endm

FIX_OFFSET_ON_CALLER .macro
	__patch_addr_\@:
	.bank \1
	.org \2
	__branch_opcode_\@:
	;;sanity checks
	.if ((\2 >> 13) & 1) != (\1 & 1)
		.fail	;even banks would fall in address ranges starting at $8000 or $c000, and for odd ones it would be $a000 or $e000.
	.endif;
	.if (__patch_addr_\@ < (-$80 + 1 + __branch_opcode_\@))
		.fail	;relative offset must be fall in signed byte range (-128 ... +127)
	.endif
	.if (($7f + 1 + __branch_opcode_\@) <= __patch_addr_\@)
		.fail	;relative offset must be fall in signed byte range (-128 ... +127)
	.endif
	;;ok
	.db (__patch_addr_\@ - (1 + __branch_opcode_\@))
	RESTORE_PC __patch_addr_\@
	.endm

;;length label will be trunacted and might be resulting in false duplicates
FALL_THROUGH_TO	.macro
	__ft_\1:
	;.if (__ft_\1 < \1)
	;	.ds (\1 - __ft_\1)
	;.endif
	.endm	;FALL_THROUGH_TO

;; label, value
DEFINE_DEFAULT	.macro
		.ifndef \1
\1 = \2
		.endif
	.endm

NOP_PAD_TO .macro
		.__pad_\@:
		.if .__pad_\@ < \1
			nop
			NOP_PAD_TO \1
		.endif
	.endm
