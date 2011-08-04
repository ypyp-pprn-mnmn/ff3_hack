; ff3_cmdx_disordered_shot.asm
;
; description:
;	implements 'disordered shot' command 
;
; version:
;	0.10 (2007-08-13)
;======================================================================================================
ff3_cmdx_disorderedShot_begin:

;------------------------------------------------------------------------------------------------------
	RESTORE_PC pb_handlers_ex
		.dw pbx_doDisorderedShot
;------------------------------------------------------------------------------------------------------
cmdx_ds_damages = $7450 ;TEMP_RAM+$f0	;$0110
;cmdx_ds_missFlags = cmdx_ds_damages + $20
cmdx_ds_count = cmdx_ds_damages - 1

;------------------------------------------------------------------------------------------------------
	RESTORE_PC ff3_cmdx_disorderedShot_begin
;consumes space from origin
commandWindow_OnDisorderedShot = commandWindow_decideReturn
	;nothing to do
;------------------------------------------------------------------------------------------------------
cmdx_disorderedShot:
	;setup action params
	lda #BATTLE_PROCESS_EX_DISORDERED_SHOT
	sta battleProcessType	;$78d5
	
	lda #$39+CMDX_DISORDERED_SHOT
	sta actionName	;action name
	
	ldx #3
	stx cmdx_ds_count	;count
cmdx_initDamageCache:
	lda #$00
	ldx #($40-1)
.init_tag:
		sta cmdx_ds_damages,x
		dex
		bpl .init_tag
	rts
;------------------------------------------------------------------------------------------------------
pbx_doDisorderedShot:
.iCommand = $64
.index = $52
.pActor = $6e

	lda <$62
	pha
	lda <$63
	pha

	lda <.iCommand
	pha

	ldx #3
.reduce_atk_hit:
	stx <.index
	lda disorderedShot_offsets,x
	;weaken attack properties
		tay
		lda [.pActor],y
		pha
		tax
		
		tya
		pha
		ldy #$0f	;joblv
		lda [.pActor],y
		lsr a
		lsr a
		clc
		adc #DISORDERED_SHOT_BASE_RATE
		jsr mul_8x8_reg
		sta <$18	;low
		stx <$19	;high
		lda #$64	;
		sta <$1a
		lda #0
		sta <$1b
		jsr div_16
		;$1c = value * (70 + joblv/4) / 100
		pla
		tay
		lda <$1c
		sta [.pActor],y
	;
	ldx <.index
	dex
	bpl .reduce_atk_hit

	.ifdef FAST_DISORDERED_SHOT
;v0.6.1
		lda #$09
		jsr setIndexAndCallPresentScene
	.endif ;FAST_DISORDERED_SHOT

disorderedShot_attackRandomTarget:
.pActor = $6e
.targetBit = $62
	jsr initActorDamages	;workaround

	ldy #$30
	lda #$80	;enemy
	sta [.pActor],y

	lsr a	;lda #$40	;actor player | target enemy
	sta play_effectTargetSide
	
	dey
	dey
	lda #$04	;fight
	sta [.pActor],y

	jsr setXtoActorIndex16
	lda <$f0,x
	bmi disorderedShot_finish
;x=ff
	jsr invokePickRandomTarget

	lda <.targetBit
	beq disorderedShot_finish

.valid_target:
	txa
	pha	;target index

	jsr command_fight
	pla
	pha	;target index
	jsr cmdx_sumDamagesOfTargetAndActor

.done_hp:
;------------------------------------------------------------------------------------------------------
effect_disorderedShot:
;[in]
;.actorBits = $7e98
.iPlayer = $52
.blowTarget = $b8
.hitCount_right = $bb
.hitCount_left = $bc

	ldx #0
	stx play_arrowTarget

	pla	;target index
	sta <.blowTarget

	.ifdef FAST_DISORDERED_SHOT
		lda #PRESENT_SCENE_EX_BLOWONLY
		jsr setIndexAndCallPresentScene
	.else
		jsr targetBitToCharIndex	;x=0(actor)
		sty <.iPlayer
		lda #$12
		jsr call_2e_9d53
	.endif ;FAST_DISORDERED_SHOT

	jsr updateTargetStatusByCache
;------------------------------------------------------------------------------------------------------
pbx_loopDisorderedShot:

	lda play_segmentedGroup
	bmi .not_segmented
		sta <$7e
		lda #$0c
		jsr call_2e_9d53
		lda #$ff
		sta play_segmentedGroup

.not_segmented:
	ldx cmdx_ds_count
	dex
	bmi disorderedShot_finish
		stx cmdx_ds_count

	.find_end_of_message:
			ldx battleMessageCount
			lda battleMessages,x
			cmp #$ff
			beq .message_ok
			inc battleMessageCount
			bne .find_end_of_message
	.message_ok:
		jmp disorderedShot_attackRandomTarget

disorderedShot_finish:
.iCommand = $64
.commandId = $4b
.pActor = $6e
	.ifdef FAST_DISORDERED_SHOT
		lda #$08
		jsr setIndexAndCallPresentScene
	.endif ;FAST_DISORDERED_SHOT

	jsr pb_showEffectMessage
	
	.ifdef SHOW_INFO_ON_DISORDERED_SHOT

	jsr pb_showDamage
	jsr pb_showDyingEffect
	ldx #0
	stx battleMessageCount
.show_messages:
		jsr pb_initString
		jsr pb_showInfoMessage
		jsr pb_waitConfirmOrTimeout
		
		lda #$04
		sta <.commandId
		jsr pb_closeWindow
	
		ldx battleMessageCount
		lda battleMessages,x
		cmp #$ff
	bne .show_messages

	lda #$03
	sta <.commandId
	jsr pb_closeWindow

	.endif	;SHOW_INFO_ON_DISORDERED_SHOT
;restore
	ldx #$fc
.restore_atk_hit:
		ldy disorderedShot_offsets-$fc,x
		pla
		sta [.pActor],y
		inx
		bne .restore_atk_hit
;restore ptr
	pla
	sta <.iCommand
	pla
	sta <$63
	pla
	sta <$62

	rts

disorderedShot_offsets:
	.db $18,$19,$1d,$1e
;======================================================================================================

cmdx_sumDamage:
;[in] a : index
;[out] carry : 1=damage0 
.statusCache = $e0
.low = $18
	asl a
	tax

	lda play_damages,x
	tay

	lda play_damages+1,x
	pha
	cmp #$ff
	bne .valid_damage
		pla
		lda #0
		tay
		pha
.valid_damage:
	pla
	and #$bf	;clear miss
	bpl .not_heal
		jsr .neg15_y_a
.not_heal:
	pha	;high
	clc
	tya
	adc cmdx_ds_damages,x
	tay	;low
	pla	;high
	adc cmdx_ds_damages+1,x
.check_negative:
	bpl .result_damage
;healed
		jsr .neg15_y_a
.result_damage:
	pha
	tya
	sec
	sbc #LOW(10000)
	pla
	pha
	and #$7f
	sbc #HIGH(10000)
	bcc .store_result
		ldy #LOW(9999)
		pla
		and #$80
		ora #HIGH(9999)
		pha
.store_result:
	tya
	sta play_damages,x
	pla
	pha
	ora play_damages,x
	bne .store_high
		;result0. heal0 or miss
		lda play_damages+1,x
		cmp #$ff
		bne .not_missed
			lda #0
	.not_missed:
		and #$bf
		ora cmdx_ds_damages,x
		ora cmdx_ds_damages+1,x
		bne .heal_0pt
	.miss:
			sec
			lda #$40
			sta play_damages+1,x
			pla
			beq .check_result_negative
	.heal_0pt:
			;heal 0pt
			pla
			lda #$80
			pha
.store_high:
	clc	;result (miss flag)
	pla
	sta play_damages+1,x
.check_result_negative:
	bpl .store_cache
		jsr .neg15_y_a
		ora #$80
.store_cache:
	sta cmdx_ds_damages+1,x
	tya
	sta cmdx_ds_damages,x
	rts
.neg15_y_a:
;[in] a : high, y: low
	pha
	tya
	eor #$ff
	clc
	adc #1
	tay
	pla
	eor #$7f
	adc #0
	;
	;ora #$80
	rts

cmdx_sumDamagesOfTargetAndActor:
;[in] a = target index
	jsr cmdx_sumDamage
	;fall through
cmdx_sumActorDamage:
	jsr setXtoActorIndex
	clc
	adc #8
	jsr cmdx_sumDamage
	bcc .finish
		;actor's hp not varied
		lda #$ff
		sta play_damages+1,x
		sta play_damages,x
.finish:
	rts
;-------------------------------------------------------------------------------------------------------
;$b979
ff3_cmdx_disorderedShot_end:
	VERIFY_PC ff3_magic_window_free_end
	;.if ff3_cmdx_disorderedShot_end > ff3_magic_window_free_end
	;	.fail
	;.endif