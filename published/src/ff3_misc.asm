; ff3_misc_asm
;
;description:
;	miscellenious code
;
;version:
;	0.01 (2006-10-07)
;
;======================================================================================================
ff3_misc_begin:
	.bank	$35
	.org	$b8fd
	.ds		$b953 - $b8fd
	.org	$b8fd
	;.org	ff3_misc_begin
isPlayerAllowedToUseItem:
;	[in] u8 $18 : itemid
;	[in] u16 $20 : ? itemDataBase = #$9400
;	[out] u8 $1c : allowed (1:ok 0:not)
;uses:
;	u8 $7478[8] : itemParams
.itemId = $18
.baseAddress = $20
.allowed = $1c
.itemParam = $7478
.userType = $38
.userFlags = $3b
.pPlayerBaseParam = $57
	lda #8
	sta <$1a
	ldx #$78
	jsr loadTo7400FromBank30	;$ba3a
	lda .itemParam+7
	and #$7f
	sta <.userType
	asl a
	;clc always clearted (&7f ed)
	adc <.userType
	tax
	jsr $fd8b	;loadUserFlags
	jsr getPlayerOffset	;$a541
	tay
	lda [.pPlayerBaseParam],y	;job
	;$b93e();
	pha
	lsr a
	lsr a
	lsr a
	sta <$38
	lda #2
	sec
	sbc <$38
	tax
	pla
	and #7
	tay
	lda <.userFlags,x
.move_flag:	
		lsr a
		dey
		bpl .move_flag
	rol a
	and #1
	sta <.allowed
	rts
;$b93e:
	;RESTORE_PC	ff3_misc_begin