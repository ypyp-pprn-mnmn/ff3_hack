; ff3_b34_play_effect.asm
;
; description:
;	replaces code for controling various effects
;
; version:
;	0.05 (2006-11-30)
;======================================================================================================
ff3_b34_play_effect_begin:
	;INIT_PATCH $34,$8411,$843e
	;INIT_PATCH $34,$83f8,$8460
	INIT_PATCH $34,$8411,$8460
playEffect:
;[in]
; u8 $7e9a :	action side flag (80:actor enemy 40:target enemy)
; u8 $7ec2 : effectType; set by commandHandler, usually commandId
; u8 $7ec3 : (0 or 1?)
;playEffect_handlerIndices = $83f8
;playEffect_handlers = $843e
	ldx #0
	bit play_effectTargetSide
	bvc .target_player
		inx
.target_player:
	stx play_damageTarget
	
	ldy effectHandlerIndex
	lda playEffect_handlerIndices,y
	cmp #1
	bne .not_handler_01
		clc
		adc effectHandlerFlag
.not_handler_01
	sta $7e97
	asl a
	tay
	lda playEffect_handlers,y
	sta <$18
	lda playEffect_handlers+1,y
	sta <$19
	jmp [$0018]
playEffect_handlerIndices:
	.db $03,$03,$04,$05,$00,$06,$0D,$0D
	.db $07,$08,$03,$03,$03,$03,$03,$09
	.db $00,$0A,$0B,$01,$01,$0C,$0E,$0F
	.db $10
	;extention to original
	.db $11
	.db $12
;$843e
playEffect_handlers:
	.dw $8613
	.dw $8577
	.dw $85ed
	.dw $8576	;effect_for_command_00_01_0a_0b_0c_0d_0e	;$8576

	.dw playEffect_04	;$853b
	.dw playEffect_05	;$8540
	.dw playEffect_06	;$8528
	.dw playEffect_07	;$852d

	.dw playEffect_08	;$8516
	.dw playEffect_09	;$850a
	.dw playEffect_0a	;$8505
	.dw playEffect_0b	;$84fb

	.dw playEffect_0c		;$84f6
	.dw playEffect_escape	;$84d7
	.dw playEffect_die		;$8470
	.dw playEffect_damage	;$8460

	.dw $8555
playEffect_handlers_end:
;$8460:
	.dw playEffect_provoke
	.dw playEffect_abyss
	;.ds $04 ;reserve 4bytes
;------------------------------------------------------------------------------------------------------
	;.org	(playEffect_handlers_end + 4)
	
playEffect_damage	;effect 0f
.segmentatedEnemyGroup = $7ee1
.pActor = $6e
	jsr $868a	;showDamage
.do_usually:
	lda .segmentatedEnemyGroup
	;cmp #$ff
	bmi playEffect_doReturn_00
		sta <$7e
		lda #$0c
		bne playEffect_call_2e_9d53

;$34:8470 playEffect_0e
playEffect_die:
	lda play_effectTargetSide
	bpl .actor_is_player
		jsr playEffect_0E_worker	;$8481
		jmp playEffect_8496
.actor_is_player:
	jsr playEffect_8496
	;fall through
playEffect_0E_worker:
	ldx #0
	;ldx #$f8
.loop:
		;lda $78bb - $f8,x
		;cmp $7d9b - $f8,x
		lda $78bb,x
		cmp $7d9b,x
		bne playEffect_present07
		inx
		cpx #8
		bne .loop
playEffect_doReturn_00:
	rts

playEffect_present07:
	lda #$07
	bne playEffect_call_2e_9d53

playEffect_0a:	;8505
	lda #$1a
	bne playEffect_set52toActorAndCall
;8528 effect06
playEffect_06:	;8528
	lda #$15
	bne playEffect_set52toActorAndCall
;852d effect07 {
playEffect_07:	;852d
	lda #$18
	bne playEffect_set52toActorAndCall

playEffect_04: ;853b
	lda #$04
	bne playEffect_set52toActorAndCall 

playEffect_05:	;8540
	lda #$03
	bne playEffect_set52toActorAndCall

playEffect_0b:
	lda #$1b
;fall
playEffect_set52toActorAndCall:	;84fd
	pha
	jsr set52toIndexFromActorBit	;8532
	pla
;fall
playEffect_call_2e_9d53:
	jmp call_2e_9d53
;------------------------------------------------------------------------------------------------------
;$34:8496
playEffect_8496:
.enemyIds = $7da7
	ldx #7
.for_each_enemy:
		ldy .enemyIds,x
		lda effect_enemyStatus,x
		bmi .dead
			iny
			bne .next
				;enemyId == #$ff
				jsr playEffect_buildDeadBits
				lda <$7e
				eor #$ff
				sta <$7e
				lda #$0b
				bne playEffect_call_2e_9d53
	.dead:
			;cpy #$ff
			;bne .do_die
			iny
			bne .do_die
	.next:
		dex
		bpl .for_each_enemy
	rts
.do_die:
	jsr playEffect_buildDeadBits
	lda #$0a
	bne playEffect_call_2e_9d53
	
playEffect_buildDeadBits:	;$84c7
.deadBits = $7e
	ldx #7
.loop:
		lda effect_enemyStatus,x
		asl a
		ror <.deadBits
		dex
		bpl .loop
playEffect_doReturn_01:
	rts
;$84d7:
;------------------------------------------------------------------------------------------------------
;$34:84d7 playEffect_0d
playEffect_escape:	;0d
	lda play_effectTargetSide
	bmi .actor_enemy
		lda $78d4
		beq playEffect_doReturn_01
			lda #$21
			bne playEffect_call_2e_9d53
.actor_enemy:
		jsr $8545 ;dispatchPresenetScene_1f();
		lda $78d4
		beq playEffect_doReturn_01
			sta <$7e
			lda #$0d
			bne playEffect_call_2e_9d53
;$84f6
;------------------------------------------------------------------------------------------------------
;$34:84f6 playEffect_0c
playEffect_0c:
	lda #$24
	bne playEffect_call_2e_9d53
;$84fb
;------------------------------------------------------------------------------------------------------
playEffect_09:	;850a
	jsr set52toIndexFromActorBit;8532
	clc
	lda $7e93
	adc #$16
	bne playEffect_call_2e_9d53
;$8516
;$34:8516 effect08
playEffect_08:	;8516
	jsr set52toIndexFromActorBit
	ldx #1
	jsr targetBitToCharIndex
	sty <$b8
	lda #$19
	jsr call_2e_9d53
	jmp $8689
	;.org $8532
set52toIndexFromActorBit:	;8532
	ldx #0
	jsr targetBitToCharIndex ;86ab
	sty <$52
	rts
;8545
;------------------------------------------------------------------------------------------------------
;quickfix
	.bank	$35
	.org	$bad5
		jsr playEffect
	.bank	$34
	.org	$858d
		jsr set52toIndexFromActorBit
	.bank	$34
	.org	$85f0
		jsr set52toIndexFromActorBit
;======================================================================================================
	RESTORE_PC ff3_b34_play_effect_begin