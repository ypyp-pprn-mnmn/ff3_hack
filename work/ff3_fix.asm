; ff3_fix.asm
;
;description:
;	small fixes
;
;version:
;	0.06 (2006-11-07)
;
;======================================================================================================
ff3_fix_begin:

	.ifdef FIX_ATTR_BOOST
		.bank	$31
		.org	$ab62
	resetAttributeBoostAndFormation:
		and #$01	;original : $f9 (this improperly keeps previous attr-boost value,seems to be bug)
		.org	$af18
	storeAttributeBoostAndFormation:
		and #$f9	;original: 1 (this masks attr-boost out, seems to be bug)
	.endif	;FIX_ATTR_BOOST
;------------------------------------------------------------------------------------------------------
	.ifdef FIX_HP_GROW
		.bank	$35
		.org	$bec3
prize_doLevelUp:
.lvBefore = $32
.hpGrowth = $24
.pBaseParam = $57
	;a = lvAfter
	;x = lvAfter
	;y = offset01 (lv)
		sta [.pBaseParam],y
		asl a
		sta <.hpGrowth
		lda #$14
		jsr setYtoOffsetOf
		lda [.pBaseParam],y	;vit
		lsr a
		jsr getSys1Random	;a564 (y is unchanged)
		clc
		adc [.pBaseParam],y
		;carry should be cleared (99+48)
		clc
		adc <.hpGrowth
		sta <.hpGrowth
		lda #0
		adc #0
		pha
		lda #$0e
		jsr setYtoOffsetOf	;9b88
		clc
		lda [.pBaseParam],y	;maxHp
		adc <.hpGrowth
		sta [.pBaseParam],y
		iny
		pla
		adc [.pBaseParam],y
		sta [.pBaseParam],y
		dey	;set y to maxHp.low
		nop
		nop
		nop
;$bef6:		
	.endif	;FIX_HP_GROW
;------------------------------------------------------------------------------------------------------
	.ifdef FIX_ITEM99
		.bank	$35
		.org	$bfc7
	branchIfItemOverflow:
		bcs $bfee
	.endif	;FIX_ITEM99
;------------------------------------------------------------------------------------------------------
	.ifdef FIX_255X_DAMAGE
	.ifndef BOOST_CHARGE

		.bank	$30
		.org	$9f15
	doFight_tagEscape:
		;original adc #01
		ora #$80

		.bank	$31
		.org	$a275
	doFight_removeEscapeTag:
		and #$7f

	.endif ;BOOST_CHARGE
	.endif ;FIX_255X_DAMAGE
;------------------------------------------------------------------------------------------------------
	.ifdef FIX_DUNGEON_FLOOR_SAVE
		.bank	$3f
		.org	$e299
	dungeon_checkStackPointer:
		tsx
		cpx #$4b	;original:$20
	.endif ;FIX_DUNGEON_FLOOR_SAVE
;======================================================================================================
	RESTORE_PC ff3_fix_begin