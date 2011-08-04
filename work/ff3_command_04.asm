; ff3_command_04.asm
;
;description:
;	patches calculations for command 04 ('fight')
;	implements 'counter attack' feature
;
;version:
;	0.08 (2006-11-10)
;
;======================================================================================================
ff3_command_04_begin:
	;INIT_PATCH $35,$a104,$a212
	INIT_PATCH $35,$a104,$a353
command_fight:
.actorIndex = $18
.knightHps = $1a
.cHealthyKnight = $22
.iPlayer = $52
.pPlayerBaseParams = $57
.pEquips = $59
.pPlayerParams = $5b
.playerOffset = $5f
.pActor = $6e
.pTarget = $70
.nearlyDeadFlag = $7cec	;probably (not yet confirmed)

	jsr getActor2C	;a42e
	;bpl .actor_is_player_char
	bmi .actor_is_enemy	
	jmp .actor_is_player_char
.actor_is_enemy	
		;enemy
		lda [.pTarget],y
		and #7
		sta <.actorIndex
		tax
		lda .nearlyDeadFlag
		jsr maskTargetBit
		beq .bump

		lda #$c0	;dead|stone
		ldx #$21	;confused|jumping
		jsr isTargetNotInStatus
		bcc .finish_protect_check
			;ok
			;a == 0 (naturally)
			sta <.cHealthyKnight
		.check_protect:
			ldx #3
			stx <.iPlayer
		.find_healthy_knight:
				
				lda <.iPlayer
				asl a
				tax
				sta <$24,x
				lda #0
				sta <.knightHps,x
				sta <.knightHps+1,x
				
				jsr getPlayerOffset	;a541	;x,y unchanged

				lda #EXTRA_ABILITY_OFFSET
				jsr setYtoOffsetOf
				lda [.pPlayerParams],y
				and #PASSIVE_PROTECT
				beq .find_next
				
				lda #1
				jsr setYtoOffsetOf
				;iny	;+01
				lda [.pPlayerParams],y
				and #$c1
				bne .find_next
				
				iny	;+02
				lda [.pPlayerParams],y
				and #$e0
				bne .find_next
					;ok
					iny	;setYtoOffset03
					lda [.pPlayerParams],y
					sta <.knightHps,x
					iny
					lda [.pPlayerParams],y
					sta <.knightHps+1,x
					inc <.cHealthyKnight
			.find_next:
				dec <.iPlayer
				bpl .find_healthy_knight
;$a175:
			lda <.cHealthyKnight
.bump:
			beq .finish_protect_check
				jsr getIndexOfGreatest	;a30f
				;lda #0
				;jsr flagTargetBit	;fd20
				jsr flagSingleTarget
				
				sta $7e99
				sta play_protectionTargetBits	;$7edf
				
				ldx <.actorIndex
				;lda #0
				;jsr flagTargetBit
				jsr flagSingleTarget
				sta $7ee0
				
				lda <.playerOffset
				clc
				adc #$75
				sta <.pTarget
				lda #0
				adc #$75
				sta <.pTarget+1
				
				ldy #$33
				lda [.pTarget],y
				sta $7ce3	;save
				and #$fe	;clear 'at backline' flag
				sta [.pTarget],y
.finish_protect_check:
		;extra
		jsr checkCounter
		bcc command_fight_doCalc
			rts
;a1ac
.actor_is_player_char:
command_fight_setupWeaponParam:
.iPlayer = $52
	and #7	;index
	jsr setupWeaponId
;a212:
command_fight_doCalc:
.iPlayer = $52
.pActor = $6e
.pTarget = $70
	jsr dispatchBattleFunction_03	;801e

	lda play_protectionTargetBits
	beq .sum_hit_count
		lda #$52	;"ナイトが みをていして かばった！"
		jsr addBattleMessage

		lda $7cea
		ldy #$33
		sta [.pTarget],y

.sum_hit_count:
.hitCountRight = $7c
.hitCountLeft = $7d
.targetStatusCache = $e0
.actorStatusCache = $f0
	clc
	lda <.hitCountRight
	adc <.hitCountLeft
	cmp #33
	bcc .store_count
		lda #32
.store_count:
	sta actionName	;78d7
	
	ldx <$64
	lda <.targetStatusCache,x
	bmi .target_is_dead
	;alive
	lda actionName	
	beq .consume_item	;miss
	;alive && hit
	inx
	lda <.targetStatusCache,x
	ldy #2
	and #STATUS_REMAIN_MASK	;$18
	;beq .check_death	;target is alive (already checked)
	beq .consume_item	;status unchanged
		;18 10 08
		sec
		sbc #8
		bne .update_status	;a295
;$a254:
;打撃によって回復した
			lda <.targetStatusCache,x
			pha
			and #STATUS_PETRIFY_MASK | STATUS_JUMPING
			sta <.targetStatusCache,x
			sta [.pTarget],y
			jsr isTargetActor
			bne .get_status_name
				lda <.targetStatusCache,x
				sta <.actorStatusCache,x
				ldy #BP_OFFSET_STATUS_LITE	;2
				sta [.pActor],y
		.get_status_name:
			pla
			ldx #$01
		.find_first_set:
				inx
				asl a
				bcc .find_first_set
;a27e
		stx effectMessage	;78d9
		;jsr clearTargetAction
			ldy #BP_OFFSET_INDEX_AND_MODE	;$2c
			lda [.pTarget],y
			and #$e7
			sta [.pTarget],y
			iny
			iny
			lda #0
			sta [.pTarget],y
		beq .consume_item	;always satisfied (cleartargetaction)

	.update_status: ;a295
		lda <.targetStatusCache,x
		sec
		sbc #8
		sta <.targetStatusCache,x
		sta [.pTarget],y
		bcs .consume_item	;always set
.target_is_dead:
		ldy #$2c
		ldx #$1a	;"しんでしまった!"
		lda [.pTarget],y
		bpl .store_death_message
			inx		;"てきをたおした!"
	.store_death_message:
		txa
		jsr addBattleMessage

.consume_item: ;a2b7
.recalcRequired = $24
	lda #0
	sta battleProcessType	;78d5
	sta <.recalcRequired
	jsr getActor2C
	bmi .finish
;$a2c3	
		and #7
		sta <.iPlayer
		jsr getPlayerOffset
		lda #1
		jsr consumeIfArrow
		lda #2
		jsr consumeIfArrow
		lda #3
		jsr consumeIfShuriken
		lda #5
		jsr consumeIfShuriken
;$a307:
		lda <.recalcRequired
		beq .finish
			jmp dispatchBattleFunction_05
.finish:
command_fight_doReturn:
	rts
;$a30f
;------------------------------------------------------------------------------------------------------
checkCounter:	;extra
;out] bool carry : (countered : 1)
.rand = $18
.iPlayer = $52
.pPlayerBaseParams = $57
.pEquips = $59
.pPlayerParams = $5b
.pActor = $6e
.pTarget = $70
	jsr isTargetActive
	bcc command_fight_doReturn
	jsr setXtoTargetIndex
	ldy #EXTRA_ABILITY_OFFSET
	lda [.pTarget],y
	;and #PASSIVE_COUNTER = 80
	clc
	bpl command_fight_doReturn
.calc_rate:
	txa
	pha
	lda #100
	jsr getSys1Random
	sta <.rand
	;%success = 25 + joblv>>1
	pla
	tax	;index
	ldy #$0f
	lda [.pTarget],y	;joblv
	lsr a
	clc
	adc #25
	cmp <.rand
	.ifdef TEST_COUNTER_ATTACK
		nop
	.else
		bcc command_fight_doReturn
	.endif ;TEST_COUNTER_ATTACK

.doCounter:
	;x = target index
	jsr flagSingleTarget
	sta play_actorBits
	;lda play_effectTargetSide
	;ora #$c1	;original uses higher 2bit.
	lda #$41
	sta play_effectTargetSide

	lda #EXMSG_COUNTER
	jsr addBattleMessage

	jsr setXtoActorIndex
	jsr flagSingleTarget
	sta play_effectTargetBits	;damage
	sta play_castTargetBits		;blow

command_fight_counter:
.pActor = $6e
.pTarget = $70
	;jsr .swapActorAndTarget
	jsr .swapStatusCache
	
	jsr getActor2C
	tax
	
	ldy #$2f
	lda [.pActor],y	;target bit
	pha	

	iny
	lda [.pActor],y
	pha
	
	txa
	eor #$80
	and #$80
	sta [.pActor],y	;force opponent side

	ldy #$28
	lda [.pActor],y
	pha
	lda #COUNTER_CRITICAL_RATE
	sta [.pActor],y
	
	txa	;actor 2c
	jsr command_fight_setupWeaponParam;command_fight_doCalc
	
	pla
	ldy #$28
	sta [.pActor],y	;critical
	
	ldy #$30
	pla
	sta [.pActor],y	;target flag
	
	dey
	pla
	sta [.pActor],y	;target bit

.swapStatusCache:
	ldx #$0f
.swap_stats:
	ldy <$e0,x
	lda <$f0,x
	sta <$e0,x
	sty <$f0,x
	dex
	bpl .swap_stats
	sec	;[out] countered
.swapActorAndTarget:
	ldx <.pActor
	lda <.pTarget
	stx <.pTarget
	sta <.pActor
	ldx <.pActor+1
	lda <.pTarget+1
	stx <.pTarget+1
	sta <.pActor+1
.finish:
	rts
;------------------------------------------------------------------------------------------------------

setupWeaponId:
;[in] u8 a : index
.iPlayer = $52
.pEquips = $59
.pActor = $6e
.pTarget = $70
;[out]
.righthand = $7e1f
.lefthand = $7e20
;	and #7
	sta <.iPlayer
	ldx #0
	stx .lefthand
	stx .righthand
	ldy #1
	lda [.pActor],y
	and #$28
	bne .finish	;toad | minimum
		;ok
		jsr getPlayerOffset	;a541
		jsr setYtoOffset03
		lda [.pEquips],y
		jsr filterShield
		sta .righthand

		iny
		iny
		lda [.pEquips],y
		jsr filterShield
		sta .lefthand
		
		beq .either_empty
		lda .righthand
		bne .finish
.either_empty:
			;at least either lefthand or righthand is empty or shield
			lda .lefthand
			jsr filterBowArrow
			sta .lefthand
			lda .righthand
			jsr filterBowArrow
			sta .righthand
.finish:
	rts
;------------------------------------------------------------------------------------------------------
consumeIfArrow:
;a = 1 : right, 2 : left
.pPlayerParams = $5b
	tax
	clc
	adc #$30
	jsr setYtoOffsetOf
	lda [.pPlayerParams],y
	and #$04	;arrow flag
	beq $a366	;.finish
		inx
		txa
		asl a
		bne consumeEquippedItem
;------------------------------------------------------------------------------------------------------
consumeIfShuriken:
.pEquips = $59
	tax
	jsr setYtoOffsetOf
	lda [.pEquips],y
	cmp #$41	;shuriken
	bne $a366 ;.finish
		inx
		txa
		bne consumeEquippedItem
;$a353
;------------------------------------------------------------------------------------------------------
	RESTORE_PC	genCode_end
;------------------------------------------------------------------------------------------------------
	;INIT_PATCH $35,$a30f,$a353
getIndexOfGreatest:	;original:a30f
.values = $1a
.indices = $24
.iPlayer = $52
	ldy #5
	ldx #7
.find_max:
		sec
		lda <.values-1,x
		sbc .values-1,y
		lda <.values,x
		sbc .values,y
		bcs .next
		;16bit value at y is greater than value at x
			tya
			tax
	.next:
		dey
		dey
		bpl .find_max
;now x is index of the greatest value
	lda <.indices-1,x
	lsr a
	sta <.iPlayer
	tax
	jmp getPlayerOffset
;------------------------------------------------------------------------------------------------------
filterBowArrow:
	ldx #3
	bne filterByItemKind
filterShield:
	ldx #5	
filterByItemKind:
;a :itemid
;x : bound
.bound = $18
	stx <.bound
	pha
	jsr idToKind
	cpx <.bound
	bcc .valid
		pla
		lda #0
		rts
.valid:
	pla
	rts
;------------------------------------------------------------------------------------------------------
set52toEffectTargetIndex:
	ldx #1
	jsr targetBitToCharIndex
	sty <$52
	rts

	VERIFY_PC genCode_free_end
;------------------------------------------------------------------------------------------------------
	RESTORE_PC	getCommandInput_end
isTargetActor:
.pActor = $6e
.pTarget = $70
;.actor = $18
	ldy #$2c
	lda [.pActor],y
	eor [.pTarget],y
	and #$87
	rts
;------------------------------------------------------------------------------------------------------
isTargetActive:
	lda #$c0	;dead | stone
	ldx #$e1	;paralyzed | sleeping | confused | jumping
isTargetNotInStatus:
;[in] a = status00, x = status01
;[out] carry : 
.pTarget = $70
	clc
	ldy #1
	and [.pTarget],y
	bne .finish
	
	iny
	txa
	and [.pTarget],y
	bne .finish
	sec
.finish:
	rts

	VERIFY_PC getCommandInput_free_end
;$9a40
;======================================================================================================
	INIT_PATCH $34,$8613,$8689
playEffect_fight:	;function00
	ldx #0
	stx $7e96
	jsr targetBitToCharIndex	;86ab
	lda play_effectTargetSide	;7e9a
	bpl .actor_is_player_char
		jsr dispatchPresentScene_1f	;8545
		lda #$20
		jsr .showBlowEffect
		jsr set52toEffectTargetIndex
.show_hit_effect:
		lda #$14
		jmp call_2e_9d53
.actor_is_player_char:	;8647
		sty <$52
		and #1
		beq .do_usually
			lda play_actorBits
			pha
			lda play_effectTargetBits
			sta play_actorBits
			jsr dispatchPresentScene_1f	;
			pla
			sta play_actorBits
	.do_usually:
		lda #$12
		jsr .showBlowEffect
		
		inc $7e96
		lda <$bb
		pha
		lda <$bc
		pha
		lda #0
		sta <$bb
		sta <$bc
		lda #$12
		jsr call_2e_9d53
		
		jsr set52toEffectTargetIndex
		
		pla
		sta <$bc
		pla
		sta <$bb
		ora <$bc
		bne .show_hit_effect
		rts
;------------------------------------------------------------------------------------------------------
.showBlowEffect:
;[in] a : type ( enemy = 20, player = 12
	ldx $7e6f
	beq .finish
		pha
		ldx #1
		jsr targetBitToCharIndex	;86ab
		sty <$b8
		pla
		jsr call_2e_9d53
		pla	;retaddr
		pla	;retaddr
.finish:
	rts
;$868a:
;======================================================================================================
ff3_command_04_end:
	RESTORE_PC ff3_command_04_begin