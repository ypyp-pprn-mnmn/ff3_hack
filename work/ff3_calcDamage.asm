; ff3_calcDamage.asm
;
;description:
;	replaces damage calculation function
;
;version:
;	0.01 (2007-08-22)
;======================================================================================================
ff3_calcDamage_begin:

	INIT_PATCH $31,$bb44,$bbe2

calcDamage:
;	$1c,1d = ((($25*(1.0~1.5)*($27/2)+$28*$29)-$26)*$7c)/$2a
;	[in] u16 $25,2b : attack power?
;	[in] u8 $26 : defence power?
;	[in] u8 $27 : attr multiplier
;	[in] u8 $28 : additional damage (critical modifier)
;	[in] u8 $29 : critical count(0/1)
;	[in] u8 $2a : damage divider (target count)
;	[in] u8 $007c : damage multiplier (hit count)
;	[out] u16 $1c : final damage (0-9999)
.atkLow = $25
.atkHigh = $2b
.def = $26
.attrMultiplier = $27
.criticalBonus = $28
.criticalMultiplier = $29
.damageDivider = $2a
.damageMultiplier = $7c
.pActor = $6e
.pTarget = $70

	lda <.atkHigh
	lsr a
	lda <.atkLow
	ror a
	jsr b31_getBattleRandom
	clc
	adc <.atkLow
	sta <$18
	lda <.atkHigh
	adc #0
	sta <$19

	lda <.attrMultiplier
	lsr a
	bne .multiply_atk
	;
		lda <$19
		lsr a
		pha	;sta <$1d
		lda <$18
		ror a
		pha	;sta <$1c
		jmp .apply_critical
.multiply_atk:
		sta <$1a
		lda #0
		sta <$1b
		jsr mul_16x16
		lda <$1d
		pha
		lda <$1c
		pha
.apply_critical:	;$bb75:
	lda <.criticalMultiplier
	ldx <.criticalBonus
	jsr mul_8x8		;fcd6
	clc
	pla
	adc <$1a
	sta <$18
	pla
	adc <$1b
	sta <$19
	jsr b31_getActor2C	;a2b5
	ldx #0
	ora	[.pTarget],y
	bpl .player_to_player
		sec
		lda <$18
		sbc <$26
		sta <$18
		bcs .atk_positive
			dec <$19
			bpl .atk_positive
				stx <$19
				stx <$18
.atk_positive:
.player_to_player:
	;here a = 0
	stx <$1b
	lda <.damageMultiplier
	sta <$1a
	jsr mul_16x16
	
	lda <$1c
	sta <$18
	lda <$1d
	sta <$19

	lda <.damageDivider
	sta <$1a
	lda #0
	sta <$1b
	jsr div_16

	.ifdef CHARGE_BREAK_DAMAGE_LIMIT
		ldy #BP_OFFSET_ATTACK_MULTIPLIER
		lda [.pActor],y
		bne .finish
	.endif
	sec
	lda <$1c
	sbc #LOW(9999)
	lda <$1d
	sbc #HIGH(9999)
	bcc .finish
		INIT16 <$1c,#9999
.finish:
	rts

	VERIFY_PC $bbe2
;=====================================================================================================
	RESTORE_PC ff3_calcDamage_begin