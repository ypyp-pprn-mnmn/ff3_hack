; ff3_enemy_target.asm
;
;description:
;	replaces enemy's action related codes
;
;version:
;	0.03 (2006-10-25)
;
;======================================================================================================
ff3_enemy_target_begin:
	INIT_PATCH $31,$a732,$a8c8
	
battleFunction_02:
decideEnemyAction:
;[in]
.pPlayer = $5b
.barrierChangeFlag = $7be2
;groupToIdMap = $7d6b
.indexToGroupMap = $7da7
.battleMode = $7ed8
;[in,out]
.sequence = $78b7
;[local]
.confused = $53
.pEnemy = $24
.iEnemy = $4a
;-------------------------------------------------
	ldx #0
	stx <$69
.for_each_enemy:
		stx <.iEnemy
		stx <$18
		lda #$40
		sta <$1a
		INIT16 <$20,$7675
		jsr calcDataAddress
		lda <$1c
		sta <.pEnemy
		lda <$1d
		sta <.pEnemy+1
		jsr $a8c8	;get2c
		and #$ef	;clear action mode
		sta [.pEnemy],y
		lda #0
		ldy #$2f	;target
		sta [.pEnemy],y
		iny			;target mode
		sta [.pEnemy],y
		sta <.confused
		tax
		ldy #1
		lda [.pEnemy],y
		and #$e8	;dead|stone|toad|minimum
		beq .check_status_2nd
			;can't move
			lda #0
			jmp .next		;a8b9
	.check_status_2nd:
		iny
		lda [.pEnemy],y
		and #$20	;confuse
		bne .status_confused
		and #$c0	;paralyzed|sleeping
		beq .status_good
	;paralyzed|sleeping
			lda #1
			jmp .next		;a8b9
	.status_confused:
		lda #$80
		sta <.confused
		bne .select_action	;a7c5
	.status_good:
		lda .battleMode
		bmi .select_action	;a7c5
		lsr a
		bcs .select_action	;a7c5	if (($7ed8 & 1) != 0) $a7c5; //bne
			;
			ldy #0
.lv = $28
		.cache_lv:
				lda [.pPlayer],y	;lv
				sta <.lv,x
				inx
				tya
				clc
				adc #$40
				tay
				bne .cache_lv
		lda [.pEnemy],y	;y=0
		clc
		adc #15
		pha
		jsr $a8ec	;getLeastLvInPlayerParty
		pla
		cmp <.lv
		bcs .select_action
			;try to escape
			lda #100
			jsr b31_getBattleRandom	;beb4
			ldy #$22
			cmp [.pEnemy],y	;evade
			bcc .select_action
				lda #6
				jmp .next
	.select_action:	;$a7c5
		ldx <.iEnemy
		lda .indexToGroupMap
		tax
		lda groupToEnemyIdMap,x
		cmp #$d2	;d2:‚Ü‚Ç‚¤‚µƒnƒCƒ“
		beq .check_barrier_change
		cmp #$b4	;b4:ƒAƒ‚ƒ“
		bne .check_special
	.check_barrier_change:
			lda .barrierChangeFlag
			cmp #2
			bne .check_special
				jsr $a8c8
				ora #$10
				sta [.pEnemy],y
				lda #$4d	;4d:barrier-change
				jmp .next
	.check_special:	;a7e9
		ldy #$37
		lda [.pEnemy],y
		beq .decide_to_fight
			lda #100
			jsr b31_getBattleRandom
			cmp [.pEnemy],y
			bcc .select_special
	.decide_to_fight:	;a7fd
		lda <.confused
		beq .select_fight_target
			jsr $a8cd	;?
			lda #4
			jmp .next	;a8b9
	.select_fight_target:
		;select valid target (must not be dead/stone/jumping)
		;if there no valid target,then action0 (do nothing)
		lda #4
		;pha
		sta <$46
		lda #0
		jsr decideEnemyTarget
		beq .fail_to_target
		;pla
		lda #4
		bne .next
	.select_special:	;$a85f
		jsr $a8c8	;get24_2c
		ora #$10
		sta [.pEnemy],y
		lda .battleMode
		bpl .select_randomly
	;sequencial	
			lda .sequence
			clc
			adc #$37
			jsr .setTarget
			bne .fail_to_target	;$a8ad
			ldy .sequence
			iny
			cpy #9
			bne .update_sequence
				ldy #1
		.update_sequence:
			sty .sequence
	.id_and_next:
		txa
	.next:	;$a8b9
		ldy #$2e
		sta [.pEnemy],y
		ldx <.iEnemy
		inx
		cpx #8
		beq .finish	;$a8c8	;get24_2c
		jmp .for_each_enemy
		;bne .for_each_enemy	;$a8c8;.finish
		;	jmp $a8c8	;finish
	.select_randomly:	;$a896
			lda #7
			jsr b31_getBattleRandom
			clc
			adc #$38
			jsr .setTarget	;if failed, ZF = 0
			beq .id_and_next
	.fail_to_target:
			jsr $a8c8	;get24_2c
			and #$ef
			sta [.pEnemy],y
			lda #0
			beq .next
	.setTarget:
			tay
			lda [.pEnemy],y
			and #$7f
			pha
			lda [.pEnemy],y
			jsr decideEnemyActionTarget	;a91b
			pla
			tax
			lda <$69
			rts
.finish:
	jmp $a8c8
;======================================================================================================
;ex battle function
pickRandomTargetFromEnemyParty:
;[in]
;[out] u8 $62 : targetbit; x = index
.targetBit = $62
.candidateCount = $64
.pTarget = $70
	lda #8
	ldx #4
	jsr buildTargetCandidateList
;	jsr verifyCandidatesByStatusCache
;verifyCandidatesByStatusCache:
.targetStatusCache = $e0
.candidateBits = $62
	ldx #7
	lda <.candidateBits
	pha
.verify:
		pla
		asl a
		pha
		bcc .verify_next
;marked as candidate. verify status cache
		txa
		asl a
		tay
		lda .targetStatusCache,y
		and #$e8	;dead|stone|toad|minimum
		beq .verify_next

			dec <.candidateCount
			lda <.candidateBits
			jsr clearTargetBit
			sta <.candidateBits
	.verify_next:
		dex
		bpl .verify
		pla	;dispose

	lda <.candidateCount
	beq .no_valid_target_there
		jsr pickOneOfCandidate
		;convert target bit to index
		lda <.targetBit
		ldx #7
	.to_index:
			lsr a
			bcs .calc_addr
			dex
			bpl .to_index
	.calc_addr:
		txa
		pha
		
		stx <$1a	;index
		lda #$40
		jsr mul_8x8
		;$1a,1b = offset to enemy
		clc
		lda <$1a
		adc #$75
		sta <.pTarget
		lda <$1b
		adc #$76
		sta <.pTarget+1
		
		pla
		tax
.no_valid_target_there:
	rts
;------------------------------------------------------------------------------------------------------
	VERIFY_PC $a8c8
;$a8c8
;======================================================================================================
	;.org	$a91b
	INIT_PATCH $31,$a91b,$a9f7
decideEnemyActionTarget:
.actionId = $46
.actionParams = $7400
	sta <.actionId
	and #$7f
	sta <$18
	lda #8
	sta <$1a
	INIT16 <$20,$98c0
	lda #$18
	tay
	ldx #0
	jsr loadTo7400Ex	;fda6
	lda .actionParams+5
	;fall through
decideEnemyTarget:
.pEnemy = $24
.confused = $53	;$80:confused
;[out]
.failed = $69
;local
.actionId = $46
.targetBits = $62
.targetFlags = $63
.candidateCount = $64
	pha
	ora <.confused	;eor is ideal, but some enemy specials are intended to target enemy party even when confused
	bpl .select_from_player_party
.select_from_enemy_party:
		lda #8
		ldx #4
		jsr buildTargetCandidateList
		lda <.candidateCount
		beq .no_valid_target_there
		ldx #$ff
		pla
		and #$40
		ora #$80
		bmi .set_target
.select_from_player_party:
		;build candidate list
		lda #4
		ldx #0
		jsr buildTargetCandidateList
		lda <.candidateCount
		beq .no_valid_target_there
		ldx #$f0
		pla
		and #$40
.set_target:
	sta <.targetFlags
	bit <.targetFlags
	bvs .target_multiple
	lda <.actionId
	bmi .target_multiple
.target_single:
	.ifdef TAG_PROVOKE_EFFECT
		ldy #$1f	;enchanted status(lefthand)
		lda [.pEnemy],y
		and #$1f
		beq .do_usual
			sec
			sbc #1
			sta [.pEnemy],y
			and #$0f
			bne .change_target
				;clear effects
				sta [.pEnemy],y
				ldy #$28
				lda #5
				sta [.pEnemy],y	;critical rate
				bne .do_usual
		.change_target:
			dey
			lda [.pEnemy],y
			beq .do_usual
			sta <.targetBits
			bne .store_result
	.do_usual:
	.endif	;TAG_PROVOKE_EFFECT
		jsr pickOneOfCandidate
		bne .store_result	;always (a = targetbit
.target_multiple:
		stx <.targetBits
.store_result:
	ldy #$30
	lda <.targetFlags
	sta [.pEnemy],y
	dey
	lda <.targetBits
	sta [.pEnemy],y
	rts
.no_valid_target_there:
	pla	;dispose (actionParam[5] )
	ldx #0
	stx <.targetBits
	stx <.targetFlags
	inx
	stx <.failed
	bne .store_result
;------------------------------------------------------------------------------------------------------
buildTargetCandidateList:
;[in]
;a = count
;x = indexOffset
.indexOffset = $65	;enemy = 4
;[out]
.candidateCount = $64
.candidateBits = $62
;
.candidateLast = $63
	sta <.candidateLast
	stx <.indexOffset
	ldx #0
	stx <.candidateBits
	stx <.candidateCount
.build_candidates:
		txa
		pha
		clc
		adc <.indexOffset
		jsr isValidTarget	;a9f7
		bne .build_next
			inc <.candidateCount
			pla
			pha
			tax
			lda <.candidateBits
			jsr flagTargetBit
			sta <.candidateBits
	.build_next:
		pla
		tax
		inx
		cpx <.candidateLast
		bne .build_candidates
	rts	
;------------------------------------------------------------------------------------------------------
pickOneOfCandidate:
.candidateBits = $62
.candidateCount = $64
	lda <.candidateCount
	sec 
	sbc #1
	jsr b31_getBattleRandom	;beb4
	tay
	iny
	;y = (0-count]
	;lda <.candidateBits
	ldx #0
.find_nth_set:
		asl <.candidateBits
		inx
		bcc .find_nth_set
		dey
		bne .find_nth_set
	;x = bit index(reversed) of Nth set
	dex
	lda #0
	jsr flagTargetBit
	sta <.candidateBits
	rts
;$a9f7	
;======================================================================================================
	RESTORE_PC	ff3_enemy_target_begin