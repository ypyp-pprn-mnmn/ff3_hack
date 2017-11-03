; ff3_cmdx_provoke.asm
;
; description:
;	implements 'provoke' command 
;
; version:
;	0.15 (2006-11-12)
;======================================================================================================
ff3_cmdx_provoke_begin:

;======================================================================================================		
;consumes space from origin

	.ifdef PROVOKE_TARGET_SINGLE
commandWindow_OnProvoke = commandWindow_selectSingleTargetAndNext
	.else
commandWindow_OnProvoke = commandWindow_decideToTargetAll
	.endif	
;======================================================================================================
;command handler
cmdx_setupPresentParam:
;[in] a : effectHanlderIndex
;[in] x : actionId * 2
	sta effectHandlerIndex
	lda #0
;	sta play_castTargetBits
	sta play_effectTargetBits
	sta play_reflectedTargetBits
	jmp setupActionType01

	.ifdef PROVOKE_TARGET_SINGLE
cmdx_provoke:
doProvokeSingle:
.pActor = $6e
.pTarget = $70
.flag = $18
.message = $22
.effectApplyTarget = $7e89
.actionIdForEffect = $7e88

	lda #EFFECT_PROVOKE
	jsr cmdx_setupPresentParam

	lda #EXMSG_PROVOKE_FAIL	;
	sta <.message
	ldy #$2c
	lda [.pTarget],y
	pha
	bpl .check_status
	;enemy
		and #7
		tax
		lda indexToGroupMap,x
		bmi .fail
.check_status:
	jsr isTargetActive
	bcc .fail
	;valid target
		jsr isProvokeSuccess
		bcs .fail
		;succeeded
			jsr getActor2C
			and #$e7
			sta <.flag
			ldy #$30
			lda [.pTarget],y
			and #$40	;multiple target
			bne .set_provoked
				;single target
				lda <.flag
				and #7
				tax
				lda #0
				sta [.pTarget],y
				jsr flagTargetBit
				dey
				sta [.pTarget],y	;2f
				sta <.flag
		.set_provoked:
		.ifdef TAG_PROVOKE_EFFECT
			pla	;target2c
			pha
			bpl .set_effect_bit
				ldy #EXSTATUS_OFFSET_PARAM	;right atk
				lda <.flag
				sta [.pTarget],y
				iny
				lda #$10 | PROVOKE_EFFECT_REMAIN ;extra effect 1 | effect remains 3 phases
				sta [.pTarget],y
		.endif ;TAG_PROVOKE_EFFECT
		.set_effect_bit:
			pla
			pha
			and #7
			tax
			lda play_effectTargetBits
			jsr flagTargetBit
			sta play_effectTargetBits
			ldy #$28	;critical rate
			lda #PROVOKE_CRITICAL_RATE
			sta [.pTarget],y
		;
			lda #EXMSG_PROVOKE_SUCCESS	;
			sta <.message
.fail:
	pla	;dispose (target 2c)
	;lda <.message
	;ldx $78ee
	;sta $78da,x	;message
	lda <.message
	jmp addBattleMessage
;------------------------------------------------------------------------------------------------------
	.else	;ifdef PROVOKE_TARGET_SINGLE

cmdx_provoke:
doProvokeAll:
.pActor = $6e
.pTarget = $70
.message = $22
;.rate = $23
.effectApplyTarget = $7e89
.actionIdForEffect = $7e88
	lda #EFFECT_PROVOKE
	jsr cmdx_setupPresentParam

	ldx #EXMSG_PROVOKE_FAIL
	stx <.message
.do_provoke:	
	;init enemy ptr .pTarget = $7675 + #0200 - #40
	lda #$35
	sta <.pTarget
	lda #$78
	sta <.pTarget+1
	
	ldx #7
.change_target:	
		txa
		pha

		lda indexToGroupMap,x
		bmi .next	;#ff

		jsr isTargetActive
		bcc .next

		ldy #$30
		lda [.pTarget],y
		and #$c0	;enemy | all
		bne .next
			;ok
		jsr isProvokeSuccess
		bcs .next

			jsr setXtoActorIndex
			jsr flagSingleTarget
			
			ldy #$2f	;target bits
			sta [.pTarget],y
	.ifdef TAG_PROVOKE_EFFECT
			ldy #EXSTATUS_OFFSET_PARAM	;righthand atk (probably unused if .pTarget represents enemy)
			sta [.pTarget],y
			iny
			lda #$10 | PROVOKE_EFFECT_REMAIN
			sta [.pTarget],y
	.endif				
			ldy #$28	;critical rate
			lda #PROVOKE_CRITICAL_RATE
			sta [.pTarget],y	;75/100 critical!
			lda #EXMSG_PROVOKE_SUCCESS
			sta <.message

			pla
			pha
			tax
			lda play_effectTargetBits
			jsr flagTargetBit
			sta play_effectTargetBits
	.next:
		;SUB16 <.pTarget,#$0040
		SUB16by8 <.pTarget,#$40
		pla
		tax
		dex
		bpl .change_target
	;setup params for display
.finish:
	lda <.message
	jmp addBattleMessage

	.endif ;PROVOKE_TARGET_SINGLE

isProvokeSuccess:
.penalty = $23
.rate = $23
.pActor = $6e
.pTarget = $70

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
	ldy #$31
	lda [.pActor],y	;righthand flag
	bpl .check_left
		lda #25
		sta <.penalty
.check_left:
	ldy #$32
	lda [.pActor],y	;lefthand flag
	clc
	bpl .store_penalty
		lda <.penalty
		adc #25
		sta <.penalty
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
playEffect_provoke:
	inc <$cc	;prevent cast motion

	lda #15		;'yyyaaa'
	sta <soundEffectId
	lda #$20	;'confuse'
	sta $7e88	;effect id
	;lda play_castTargetBits	
	;sta $7e89	;target bits
	lda #0		;effect type 0='normal (play on each target)'
	sta $7e9d
	jsr set52toIndexFromActorBit	;$8532
	lda #$1d	;magic
	jmp call_2e_9d53
;======================================================================================================
ff3_cmdx_provoke_end:
;	RESTORE_PC ff3_cmdx_provoke_begin