; ff3_command_0a.asm
;
; description:
;	replaces originally unimplemented command 
;
; version:
;	0.05 (2006-10-12)
;======================================================================================================
command_0a_begin:
;replace tables
;$34:9a16(file:69a26) ptr commandWindowHandlers[15]
	FILEORG	$69a16 + ($0a * 2)
	commandWindowHandlers_0A:
		.dw	commandWindow_OnCommand0A
;$34:9b21(file:69b31) actionId jobActionLists[4][22]
	FILEORG	$69b21
	job_commands:
		.db		$04,$05,$06,$14	;00 onion
		.db		$04,$05,$06,$14	;01 fighter
		.db		$04,$05,$06,$14	;02 monk
		.db		$04,$15,$06,$14	;03 priest (white
		.db		$04,$15,$06,$14	;04 mage (black
		.ifdef TEST_PROVOKE
			.db		$04,$15,$0A,$14	;05 red
		.else	
			.db		$04,$15,$06,$14	;05 red
		.endif	
		.db		$04,$05,$15,$14	;06 hunter
		.db		$04,$05,$06,$14	;07
		.db		$04,$0E,$07,$14	;08
		.db		$04,$0C,$0D,$14	;09
		.db		$04,$0B,$05,$14	;0a
		.db		$04,$08,$05,$14	;0b
		.ifdef GIVE_VIKING_PROVOKE
			.db		$04,$0A,$05,$14	;0c viking
		.else
			.db		$04,$05,$06,$14	;0c viking
		.endif	
		.db		$04,$0F,$05,$14	;0d	martialist
		.db		$04,$05,$15,$14	;0e
		.db		$04,$15,$06,$14	;0f
		.db		$10,$11,$12,$14	;10	bard
		.db		$04,$15,$06,$14	;11
		.db		$04,$15,$06,$14	;12
		.db		$04,$15,$06,$14	;13
		.db		$04,$15,$06,$14	;14 sage
		.db		$04,$05,$06,$14	;15 ninja
		
	FILEORG $73b1a + ($0c * 5 + 4)	;viking job param +04 (actionJobExp)
	jobParams_viking_04:
		.db %11111010	;12 12 8 8
;------------------------------------------------------------------------------------------------------
	.bank	$34
effect_handler_table = $843e
	.org effect_handler_table + ($03*2)
		.dw effect_for_command_00_01_0a_0b_0c_0d_0e
	;----------------------------------------------------------------------------------------	
	FILEORG	commandHandlers + ($0a*2)
		;originally 'nop'
		.dw command_provoke
	;----------------------------------------------------------------------------------------	
	FILEORG	$3cbbd
	command0a_message_fail:
		.db	$8a,$8b,$9c,$9f,$94,$b3,$9e,$8f,$7c,$99,$c4,$00
		
	FILEORG	$3de12
	command0a_message:
		.db $9c,$90,$29,$8e,$93,$7c,$99,$c4,$00
		
	FILEORG	$3dabd	;string for command 0A (original:$3dafd)
	command0a_name:
		.db $9a,$7f,$8c,$a3,$9b,$00	;
	;----------------------------------------------------------------------------------------	
	.bank	stringPtrTable >> 13
	.org	$8000 + (stringPtrTable & $7fff) + $0c40; + ($87 * 2)
	battleMessageOffsets:
.nullstr = $de21	
	.org	battleMessageOffsets + ($0a * 2)	;string ptr for command 0A
		.dw (command0a_name & $ffff)
	.org	battleMessageOffsets + ($87 * 2)	;message
		.dw (command0a_message & $ffff)
		.dw	(command0a_message_fail & $ffff)
		.dw .nullstr, .nullstr
		.dw	.nullstr, .nullstr, .nullstr, .nullstr
;======================================================================================================		
	.bank	BANK(command_0a_begin)
	.org	command_0a_begin
commandWindow_OnCommand0A:	
	jsr setYtoOffset2E
	dey
	dey
	lda [pPlayer],y	; index and flags (+2c)
	and #$e7
	sta [pPlayer],y
	iny
	iny
	lda #$0a		;
	sta [pPlayer],y	;action id (+2e)
	ldx <iPlayer
	;sta selectedAction,x	;already set by getCommandInput
	iny
	lda #$ff
	sta [pPlayer],y	;target (+2f)
	iny
	lda #$c0	;enemy|all
	sta [pPlayer],y	;target flag (+30)
	;
	inc iPlayer
	lda #1		;prevent redraw enemy names
	jmp getCommandInput_next
;======================================================================================================
;command handler
;handleCommand_0a:
command_provoke:
.messageSuccess = $87
.messageFail = $88
.pActor = $6e
.pTarget = $70
.message = $22
;.successFlags = $21
;.rate = $23
.effectApplyTarget = $7e89
.actionIdForEffect = $7e88
	ldx #.messageFail
	stx <.message
	;clear target bit
	ldx #$0
	stx play_castTargetBits
	stx play_effectTargetBits
	stx play_reflectedTargetBits
.do_provoke:	
	;init enemy ptr .pTarget = $7675 + #0200 - #40
	lda #$35
	sta <.pTarget
	lda #$78
	sta <.pTarget+1
	
	ldx #7
.change_target:	
		lda indexToGroupMap,x
		bmi .next	;#ff
		ldy #$01
		lda [.pTarget],y
		;lda enemyStatusCache,x
		and #$e8	;dead | stone | toad
		bne .next
		iny
		lda [.pTarget],y
		;lda enemyStatusCache+1,x
		and #$60	; sleep | confuse
		bne .next
		
		ldy #$30
		lda [.pTarget],y
		and #$c0	;enemy | all
		bne .next
			;ok
			txa
			pha
			jsr .isProvokeSuccess
			pla
			tax
			bcs .next
				pha
				jsr getActor2C	;$a42e
				and #$07	;mask to index
				tax
				lda #0
				jsr flagTargetBit	;$fd20
				ldy #$2f	;target bits
				sta [.pTarget],y
				ldy #$28	;critical rate
				lda #99
				sta [.pTarget],y	;99/99 critical!
				lda #.messageSuccess
				sta <.message
				pla
				tax
				lda play_effectTargetBits
				jsr flagTargetBit
				sta play_effectTargetBits
	.next:
		SUB16 <.pTarget,#$0040
		dex
		bpl .change_target			
	;setup params for display
.finish:
	lda #1
	sta $78d5	;display type (1=magic)
	lda #$39 + $0a
	sta $78d7	;action name
	lda <.message
	ldx $78ee
	sta $78da,x	;message
	rts
.isProvokeSuccess:
.penalty = $23
.rate = $23
	ldy #$0f
	lda [.pActor],y	;joblv
	ldy #0
	sty <.penalty
	clc
	adc [.pActor],y	;lv
	clc
	adc #75
	bcc .calc_shield_penalty
		lda #$ff
.calc_shield_penalty:
	pha
	lda [.pTarget],y	;lv
	pha
	ldy #$17
	lda [.pActor],y	;left atk count
	bne .left_ok
		lda #25
		sta <.penalty
.left_ok:
	ldy #$1c
	lda [.pActor],y	;right
	clc
	bne .right_ok
		lda <.penalty
		adc #25
		sta <.penalty
.right_ok:
.store_penalty:	
	pla
	adc <.penalty
	sta <.penalty
	pla
	sec
	sbc <.penalty
	bcs .store_rate
		lda #1
.store_rate:
	sta <.rate
	;check for position
	ldy #$33
	lda [.pActor],y
	and #1
	beq .get_rand
		lsr <.rate
.get_rand:		
	lda #100
	jsr getSys1Random
	cmp <.rate
	rts
;======================================================================================================
effect_for_command_00_01_0a_0b_0c_0d_0e:
;original = $8576

	lda effectHandlerIndex;	$7ec2
	cmp #$0a
	beq .command_0a
	rts
.command_0a:
	lda #15		;'yyyaaa'
	sta <soundEffectId
	lda #$20	;'confuse'
	sta $7e88	;effect id
	lda play_castTargetBits	
	sta $7e89	;target bits
	lda #0		;effect type 0='normal (play on each target)'
	sta $7e9d
	jsr set52toIndexFromActorBit	;$8532
	lda #$1d	;magic
	jmp call_2e_9d53
;======================================================================================================
command_0a_end: