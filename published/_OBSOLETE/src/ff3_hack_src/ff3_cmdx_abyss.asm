; ff3_cmdx_abyss.asm
;
; description:
;	implements 'abyss' command 
;
; version:
;	0.03 (2006-11-12)
;======================================================================================================
ff3_cmdx_abyss_begin:

	.ifdef GIVE_EVILSWORDMAN_ABYSS
;======================================================================================================
commandWindow_OnAbyss = commandWindow_decideToTargetAll
;------------------------------------------------------------------------------------------------------
;consumes space
	RESTORE_PC pb_free_begin

calcAbyss:
.pActor = $6e
.pTarget = $70	;in,const
.count = $7c
.rate = $24
.try = $25
.atkLow = $25
.def = $26
.attr = $27
.bonus = $28
.bonusMul = $29
.divide = $2a
.atkHigh = $2b
.succeeded = $30
.targetCache = $e0

	ldy #$13	;mevade count
	lda [.pTarget],y
	sta <.try
	iny
	lda [.pTarget],y
	sta <.rate
	jsr .callGetRandomSucceededCount
;	ˆÐ—Í = 75 + n—û“x + ¸_
	ldy #$0f
	lda [.pActor],y
	pha
	clc
	adc #75
	;sta <.atkLow

	iny
	iny
	adc [.pActor],y
	bcc .store_atk
		lda #$ff
.store_atk
	sta <.atkLow
;	‰ñ” = 1 + n—û“x/16 + ¸_/8
	lda [.pActor],y
	lsr a
	lsr a
	lsr a
	sta <.count
	pla	;joblv
	lsr a
	lsr a
	lsr a
	lsr a
	sec
	adc <.count
	;adc #2
	sec
	sbc <.succeeded
	bcs .store_count
		lda #0
.store_count:
	sta <.count
;
	ldy #$15
	lda [.pTarget],y
	sta <.def
;attr check
	ldx #0
	stx <.bonus
	stx <.bonusMul
	stx <.atkHigh
	inx
	stx <.divide	;1
	inx

	ldy #$20
	lda [.pTarget],y
	and #$02	;dark
	beq .not_strong
		ldx #1
.not_strong:
	ldy #$12
	lda [.pTarget],y
	and #$02	;dark
	beq .not_weak
		ldx #4
.not_weak:
	;x = 1(strong) 2(normal) 4(weak)
	stx <.attr
	;calcDamage(hitcount:$7c, atk:$25,2b, def:$26, 
	;	attr:$27, bonus:$28, bonusMul:$29, divide:$2a);
	jsr .callCalcDamage
.resultDamage = $1c
	jsr setXtoTargetIndex
;flag target
	lda play_effectTargetBits
	jsr flagTargetBit
	sta play_effectTargetBits

	txa
	asl a
	tax
	lda <.resultDamage
	sta play_damages,x
	lda <.resultDamage+1
	sta play_damages+1,x
;apply damage
	ldy #3
	sec
	lda [.pTarget],y
	sbc <.resultDamage
	sta [.pTarget],y
	iny
	lda [.pTarget],y
	sbc <.resultDamage+1
	sta [.pTarget],y
	dey
	ora [.pTarget],y
	beq .target_dead
	bcs .remove_segmenting_abiliy
.target_dead:
		;result minus (target dead)
		lda #0
		sta [.pTarget],y
		iny
		sta [.pTarget],y
		lda #$80
		sta <.targetCache,x
.remove_segmenting_abiliy:
	;
	ldy #$38
	lda [.pTarget],y	;actionId[0]
	cmp #$4f	;4f:segment
	bne .finish
	;remove target's segmenting ability
		lda #$34	;34: care
		sta [.pTarget],y
.finish:
	rts
.callGetRandomSucceededCount:
	lda #BF_GET_RANDOM_SUCCEEDED_COUNT
	bne .call
.callCalcDamage:
	lda #BF_CALC_DAMAGE
.call:
.functionId = $4c
	sta <.functionId
	jmp invoke_b30_battleFunction	;fdf3
calcAbyss_end:
;------------------------------------------------------------------------------------------------------
;consumes space from origin
	RESTORE_PC ff3_cmdx_abyss_begin
playEffect_abyss:
.castFlag = $cc
	inc <.castFlag	;prevent cast
	;inc <$cb	;critical flag?
	lda #$0b
	;lda #$00
	sta play_magicType	;7e9d
	;lda #$10	;'dimension'
	lda #$4a	;mega flare
	;lda #$68
	sta $7e88	;effect id


	;lda #$4a	;wavecannon
	;lda #$11	;death
	lda #$47	;sound of dimension
	;lda #$22
	sta <soundEffectId
	
	lda #PRESENT_SCENE_EX_ABYSS
	jsr setIndexAndCallPresentScene
	lda #0
	sta <.castFlag
	rts
;------------------------------------------------------------------------------------------------------
cmdx_abyss:
.pActor = $6e
.actorStatusCache = $f0
	lda #EFFECT_ABYSS
;	sta effectHandlerIndex
	jsr cmdx_setupPresentParam

;main calcs
.pTarget = $70
	INIT16 <.pTarget,$7835
	ldx #7
.for_each_enemy:
		txa
		pha
		lda #$e8	;dead | stone | toad | minimum
		ldx #$00
		jsr isTargetNotInStatus
		bcc .offset_ptr
			;ok
			jsr calcAbyss
	.offset_ptr:
		SUB16by8 <.pTarget,#$40
		pla
		tax
		dex
		bpl .for_each_enemy

	jsr damageActorByQuoterHalf	;also set x to cache index
;setup message and effect params
	lda #EXMSG_ABYSS_MESSAGE
	jmp addBattleMessage
;	sta battleMessages
;	lda .actorStatusCache,x
;	bpl .finish
;		ldx #1
;		stx battleMessageCount
;		lda #$1a	;"‚µ‚ñ‚Å‚µ‚Ü‚Á‚½"
;		sta battleMessages,x
;.finish:
;	rts
	;jsr setXtoActorIndex
	;jmp setupWeaponId

;======================================================================================================		
ff3_cmdx_abyss_end:
	VERIFY_PC ff3_magic_window_free_end
	;.if ff3_cmdx_abyss_end >= ff3_magic_window_free_end
	;	.fail
	;.endif
	
	.else	;GIVE_EVILSWORDMAN_ABYSS

cmdx_abyss = command_none
commandWindow_OnAbyss = commandWindow_cancelReturn
playEffect_abyss:
	rts

	.endif	;GIVE_EVILSWORDMAN_ABYSS
