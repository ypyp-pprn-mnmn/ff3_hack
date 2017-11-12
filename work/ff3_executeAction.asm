; ff3_executeAction.asm
;
;description:
;	replaces executeAction()
;
;version:
;	0.02 (2017-11-12)
;		special thanks to the owner of FF3C (aka 966)
;
;======================================================================================================
ff3_executeAction_begin:

	;INIT_PATCH $34,$9de4,$9fac
	.bank	$34
	.org	$9de4
executeAction:
;[in]
.currentActor = $7ac2
.ordinalToIndex = $7acb
;[local]
.pActor = $6e
.pTarget = $70

	ldx .currentActor
	lda .ordinalToIndex,x
	pha
	
	bpl .actor_is_player_char
		clc
		and #$7f
		adc #4
.actor_is_player_char:
;$9df3:
	sta <$18
	sta <$26
	
	lda #$40
	sta <$1a
	INIT16 <$20,$7575
	
	jsr dispatchBattleFunction_07	;802e => calcDataAddress

	lda <$1c
	sta <.pActor
	lda <$1d
	sta <.pActor+1

	lda <$26
	cmp #$0c
	bcc .actor_valid
		;?
		pla
		bne .check_status	;$9e5f
.actor_valid:
	pla
	tay
	and #$87
	sta $78d6	;actor name
	and #$7f
	tax
	;lda #0
	;jsr flagTargetBit
	jsr flagSingleTarget
	sta $7e98
	tya	;actor index|flag

	bpl .check_status
		;actor enemy
		lda $7e9a
		ora #$80
		sta $7e9a
		
		;a = $7ced;
		;if( ((#55 == $7ced) && ($7cee == 0))
		;	|| ( ((#79 == $7ced) || (#90 == $7ced)) && ($7cee != 0) ) )
		lda $7ced
		ldx $7cee
		bne ._7cee_not_0
			cmp #$55
			bne .check_status
			beq .heal_hp
	._7cee_not_0:
			cmp #$79
			beq .heal_hp
			cmp #$90
			bne .check_status
	.heal_hp:
			ldy #6
			lda [.pActor],y
			ldy #4
			sta [.pActor],y
.check_status:	;$9e5f:
	ldy #1
	lda [.pActor],y
	and #$c0	;dead|stone
	bne .actor_status_bad
		;check more
		iny
		lda [.pActor],y
		and #$c0	;paralyzed | sleeping
		beq .actor_status_ok
			lda #1
			jsr setActorActionAndClearMode	;$9f7b
			jsr setNoTargetMessage	;$91ce
			jsr setActionTargetToSelf	;$9f87
;$9e93:
	.actor_status_ok:
		ldy #$2f
		lda [.pActor],y
		sta $7e99
		sta $7e9b
		bne .target_valid
			jsr setActionTargetToSelf
	.target_valid:
		ldx #0
	.target_bit_to_index:
			asl a
			bcs .got_index
			inx
			bne .target_bit_to_index
	.got_index:
		txa
		pha
		
		iny
		lda [.pActor],y	;+30
		tay
		
		bpl .target_player
			lda play_effectTargetSide	;$7e9a
			ora #$40
			sta play_effectTargetSide	;$7e9a
			
			pla
			ora #$80
			pha	;sta $78d8

			clc
			txa
			adc #4
			tax
			;bne .set_target_name
	.target_player:
	.set_target_name:
		stx <$18	;actor ordinal
		pla	;target index
		tax
		
		tya	;target flag
		asl a
		bpl .target_single
			ldx #$88
	.target_single:
		stx $78d8

		lda #$40
		sta <$1a
		INIT16 <$20,$7575
		jsr dispatchBattleFunction_07	;$802e
		
		lda <$1c
		sta <.pTarget
		lda <$1d
		sta <.pTarget+1
		bne .check_action_mode	;target address should be $75xx-$77xx
		;bne
.actor_status_bad
		dey
		tya
		sty effectHandlerIndex	;$7ec2
		sty $7e98
		dey
		sty $7ceb
		sty $78d8
		sty $78d6
		jsr setActorActionAndClearMode	;$9f7b
;$9eec:
;-----------------------------
.check_action_mode:
.actionId = $1a
	ldy #$2e
	lda [.pActor],y
	sta <.actionId	;actionid
	
	jsr getActor2C
	tax
	and #$10	;special
	bne .special_attack	;$9f5a
	txa
	and #$08
	bne .use_item	;$9f19
;$9f0b:
	lda <.actionId
	.ifdef ENABLE_EXTRA_ABILITY
		cmp #CMDX_ID_END
	.else
		cmp #$13
	.endif
	bcc .dispatch
	cmp #$46
	bcs .check_caster
	;invalid action id
.use_item:
	lda #$13
	bne .dispatch
.check_caster:
	;jsr getActor2C
	txa
	bmi .special_attack
;decrement mp
.iPlayer = $52
		and #7
		tax
		lda selectedMagicLv,x
		clc
		adc #7
		tay
		sec
		lda [.pActor],y	;mp
		sbc #1
		sta [.pActor],y
		
		lda <.actionId
		ldx #7
	.check_summon_id:
			cmp .summonMagicIds,x
			bne .check_summon_next
				jmp executeAction_summon
		.check_summon_next:
			dex
			bpl .check_summon_id
.special_attack:	;$9f5a
	lda #$14
.dispatch:	;$9f5c
	sta effectHandlerIndex	;$7ec2

	asl a
	tax
	lda executeAction_handlers,x
	sta <$18
	lda executeAction_handlers+1,x
	sta <$19
	jmp [$0018]
.summonMagicIds:
	.db $ce,$d5,$dc,$e3,$ea,$f1,$f8,$ff
executeAction_end:
;======================================================================================================
command_none		= $9fa8
command_01			= $a68a
;command_forward	= $a7df
;command_back		= $a7ea
;command_fight		= $a104
;command_guard		= $a881
;command_escape		= $a8bf
;command_sneakAway	= $a93b
;command_jump		= $a9d8
;command_land		= $aa11
;command_0A			= $a89f
;command_geomance	= $aa5d
;command_inspect	= $ab73
;command_detect		= $ab0c
;command_steal		= $aba4
;command_charge		= $ac6f
;command_sing		= $acd5
;command_intimidate	= $ad16
;command_cheer		= $ad75
command_item		= $a3bb
command_magic		= $a367
;------------------------------------------------------------------------------------------------------
;	.org	$9fac
	INIT_PATCH $34,$9fac,$9fac+($02*$15)
	RESTORE_PC executeAction_end

executeAction_handlers:	;$9fac:	//function table
	.dw	command_none		;$9fa8
	.dw command_01			;$a68a
	.dw command_forward		;$a7df
	.dw command_back		;$a7ea
	.dw command_fight		;$a104
	.dw command_guard		;$a881
	.dw command_escape		;$a8bf
	.dw command_sneakAway	;$a93b
	.dw command_jump		;$a9d8
	.dw command_land		;$aa11
	.dw command_none		;$9fa8
	.dw command_geomance	;$aa5d
	.dw command_inspect		;$ab73
	.dw command_detect		;$ab0c
	.dw command_steal		;$aba4
	.dw command_charge		;$ac6f
	.dw command_sing		;$acd5
	.dw command_intimidate	;$ad16
	.dw command_cheer		;$ad75
	.dw command_item		;$a3bb
	.dw command_magic		;$a367
	;extension to original
	.dw 0	;dummy
	.dw cmdx_provoke
	.dw cmdx_disorderedShot
	.dw cmdx_abyss
	.dw cmdx_raid
executeAction_free_begin:
;$9f7b
;======================================================================================================
;$34:9f7b setActorCommandIdAndClearMode

;$34:9f87 setActionTargetToSelf //setActionTargetBitAndFlags

;$34:9fa8 handleCommand00_0a //do nothing
;======================================================================================================
	;INIT_PATCH $34,$9fa6,$a000
	INIT_PATCH $34,$9fa8,$a000
;------------------------------------------------------------------------------------------------------
setXtoTargetIndex:
.pTarget = $70
	ldy #$2c
	lda [.pTarget],y
	jmp maskToIndex
;	and #$07
;	tax
;	rts

setXtoActorIndex:
	jsr getActor2C
maskToIndex:
	and #7
	tax
	rts

setXtoActorIndex16:
	jsr setXtoActorIndex
	asl a
	tax
	rts

flagSingleTarget:
;[in] x = targetIndex
	lda #0
	jmp flagTargetBit

addBattleMessage:
;[in] a : msg
;[in,out] x : count
	ldx battleMessageCount
	sta battleMessages,x
	inx
	stx battleMessageCount
	;inc battleMessageCount
	rts

swapDamages:
	ldx #$0f
.swap:
		lda play_damages,x
		pha
		lda play_damages+$10,x
		sta play_damages,x
		pla
		sta play_damages+$10,x
		dex
		bpl .swap
	rts

swapHitCounts:
.hitCount = $bb
.temp = TEMP_RAM
	ldx #1
.save:
		ldy <.hitCount,x
		lda .temp,x
		sta <.hitCount,x
		tya
		sta .temp,x
		dex
		bpl .save
	rts

;workaround for doFight behavior
initAllDamages:
	ldx #$e0
	bne initDamage
initActorDamages:
	ldx #$f0
	;fall through
initDamage:
	lda #$ff
.fill:
		sta play_damages+$10-$f0,x
		inx
		bne .fill
	rts
;------------------------------------------------------------------------------------------------------
	INIT_PATCH $35,$a000,$a104

executeAction_summon:
.magicParamsCache = $18
;.actionId = $26
;.targetBit = $27
;.targetFlag = $28
.summonType = $30
.iPlayer = $52
.pActor = $6e

	ldx #$3f
	lda #0
	sta $7e93
.init_char_struct:
		sta $7875,x
		dex
		bpl .init_char_struct
	lda #2
	sta <.summonType
;original checks job == #13 || #14
	ldy #EXTRA_ABILITY_OFFSET
	lda [.pActor],y
	and #PASSIVE_SUMMON_FUSION
	bne .summon_fusion
;$9ffc:
		lda #99
		jsr getSys1Random	;a564
		cmp #50
		bcs .summon_black
			dec <.summonType
	.summon_black:
		dec <.summonType
.summon_fusion:
;$a009:
	;.bank $35
	
	;jsr getActor2C
	;and #7
	;sta <.iPlayer
	;tax
	jsr setXtoActorIndex
	lda selectedMagicLv,x
	pha
	
	jsr $fd3e	;a<<=4
	ora <.summonType
	sta $7e94

;	INIT16 <.pActor,$7875
;	setYtoOffsetOf(a = #0f);	//$9b88
	ldy #$0f
	ldx #2
.load_params:
		lda [.pActor],y
		asl a
		sta <.magicParamsCache,x
		iny
		dex
		bpl .load_params

	ldy #1
	lda [.pActor],y
	and #$30	;toad|sealed
	pha
	
	INIT16 <.pActor,$7875

	pla
	sta [.pActor],y
	;
	dey
	lda <.magicParamsCache+2	;joblv
	sta [.pActor],y

	ldy #$0f
	ldx #2
.store_params:
		lda <.magicParamsCache,x
		sta [.pActor],y
		iny
		dex
		bpl .store_params
	ldy #3
	tya
	sta [.pActor],y	;hp
	
	ldx $7ac2
	lda #$88
	sta $7acb,x

	;$6e[y] = getActor2C() | #90;
	ldy #$2c
	lda #$90
	sta [.pActor],y
;$a065:
	pla	;selectedMagicLv
	sta <$18
	asl a
	clc
	adc <$18
	adc <.summonType
	tax	; a = selectedMagicLv*3 + summonType

	clc
	adc #$78
	sta battleMessages
	
	txa
	clc
	adc #$21
	sta effectMessage

	txa
	adc #$5b
	sta <$18
	pha	;sta <.actionId
	
	lda #8
	sta <$1a
	INIT16 <$20,$98c0
	ldx #0
	jsr loadTo7400FromBank30	;$ba3a
	
.actionParams = $7400
	
	bit .actionParams+5
	bpl .target_enemy
		lda #$f0
		pha
		lda #$40
		bne .store_action_params
.target_enemy:
		bvc .target_single
			lda #$ff
			pha
	.target_all:
			lda #$c0
			bne .store_action_params
	.target_single:
	
.targetBit = $62

			jsr invokePickRandomTarget
			lda <.targetBit
			pha
			lda #$80
.store_action_params:
	ldy #$30
	sta [.pActor],y	;target flag
	dey
	pla
	sta [.pActor],y	;target bit
	dey
	pla
	sta [.pActor],y	;action id

	INIT16 <$5d,$7675
;$a0ea:
	jmp executeAction
	;jmp $9de4	;executeAction
;------------------------------------------------------------------------------------------------------
invokePickRandomTarget:
.battleFunctionId = $4c
	lda #BF_PICK_RANDOM_TARGET
	sta <.battleFunctionId
	jmp invoke_b30_battleFunction
;$a104:

;======================================================================================================
	RESTORE_PC ff3_executeAction_begin