; ff3_doFight.asm
;
;description:
;	replaces calculation for command 'fight'
;
;version:
;	0.04 (2006-11-11)
;======================================================================================================
ff3_battle_calc_begin:

	;INIT_PATCH $31,$a000,$a2b5
	INIT_PATCH $31,$a000,$a290
	INIT_PATCH $30,$9e8a,$a000

DEF_DO_FIGHT_VARS	.macro
.atkHigh = $2b
.atkLow = $25
.def = $26
.criticalBonus = $28
.criticalCount = $29
.damageDivider = $2a
.pActor = $6e
.pTarget = $70
.escapeCount = $74
.isGuarding = $7ce4
.isFarTarget = $7ce9
;[out]
.hitCount_1st = $7c
.hitCount_2nd = $7d
.protectFlag = $7edf
;[out] shared with checkSegment()
.hitCountForBlow_1st = $bb
.hitCountForBlow_2nd = $bc
;locals:
.targetHp = $3c
.actorHp = $40
.doubleArmed = $741e
.handCount = $741f
.attackProps = $7440
.defProps = $742a
;shared with cacheStatus()
.iActorCache = $62
.iTargetCache = $64
.iActor = $66
.iTarget = $68
.actorStatusCache = $f0
.targetStatusCache = $e0
;shared with sumDamage()
.damageForDisplay = $6a
.damage = $78
	.endm	;DEF_DO_FIGHT_VARS
doFight:
	DEF_DO_FIGHT_VARS
;------------------------------------------------------------------------------------------------------
	jsr cacheStatus
	ldx <.iTargetCache
	lda <.targetStatusCache,x
	bmi .bad_target
	asl a
	bmi .bad_target
	
	lda <.targetStatusCache+1,x
	lsr a	;jumping
	bcc .begin_calc

.bad_target:
.pTargetSideBase = $22

	lda #$75
	sta <.pTargetSideBase
	sta <.pTargetSideBase+1
	ldy #$30
	lda [.pActor],y
	bmi .target_enemy
;.target_player:
		lda #3
		jsr getRandomTarget
		lda <$69
		beq .cache_status
;.no_valid_target:
			ldx #0
			stx effectHandlerIndex	;7ec2
			dex
			stx targetName	;78d8
			;bug!! jmp $a264	;post calc
			jmp b31_getActor2C	
.target_enemy:
		inc <.pTargetSideBase+1
		lda #7
		jsr getRandomTarget	;a300
.cache_status:
	jsr cacheStatus

.begin_calc:
	ldx #$ff
	stx play_segmentedGroup
	inx
	stx $7ce9
	stx <.hitCount_1st
	stx <.hitCount_2nd
	stx <$6a
	stx <$6b
	stx <$42
	stx .doubleArmed
	inx
	stx .handCount

	ldy #4
.save_hp:
		lda [.pTarget],y
		sta <.targetHp,x
		lda [.pActor],y
		sta <.actorHp,x
		dey
		dex
		bpl .save_hp

	jsr b31_getActor2C
	bpl .actor_player
;actor_enemy
		lda [.pTarget],y	;y = 2c
		bmi .cache_props
			;actor_enemy && target_player
			lda <.escapeCount
			beq .cache_props
				ldy #$27
				lda [.pTarget],y
				ora #$80	;tag
				sta [.pTarget],y
				bmi .cache_props	;always
.actor_player:
		ldy #$31
		lda [.pActor],y
		cmp #2
		bcs .cache_props
		iny
		eor [.pActor],y
		bne .cache_props
			;—¼Žè‚ª‘fŽèor—¼Žè‚ª•ÐŽè•Ší
			inc .handCount
			inc .doubleArmed

.cache_props:	;$9f40
;.attackProps = $7440
;.defProps = $742a

	ldy #$24
	ldx #$04
.cache_defs:
		lda [.pTarget],y
		sta .defProps,x
		dey
		dex
		bpl .cache_defs
	;ldy #$1f
	ldx #$09
.cache_attacks:
		lda [.pActor],y
		sta $7420,x
		sta .attackProps,x
		dey
		dex
		bpl .cache_attacks
	ldy #$29
	ldx #$02
.cache_criticals:
		lda [.pActor],y
		sta $742f,x
		dey
		dex
		bpl .cache_criticals

doFight_calc_damage_for_hand:	;9f6a
	DEF_DO_FIGHT_VARS
.count = $24
.rate = $25

	lda .attackProps+1
	sta <.count
	lda .attackProps+2
	sta <.rate
	
	ldx <.iActorCache
	lda <.actorStatusCache,x
	and #$04
	beq .not_blind
		lsr <.rate
.not_blind:
	ldy #$33
	lda [.pActor],y
	and #$04	;04:—¼Žè‰“‹——£ƒtƒ‰ƒO(’G‹Õ‚©–î‚ª‚ ‚é‹|‚È‚çset)
	bne .get_attack_count
		jsr b31_getActor2C
		bmi .check_actor_line
			jsr isRangedWeapon	;a397
			bcs .get_attack_count
	.check_actor_line:
		ldy #$33
		lda [.pActor],y
		lsr a
		bcc .check_target_line
			lsr <.rate
	.check_target_line:
		lda [.pTarget],y
		lsr a
		bcc .get_attack_count
			inc .isFarTarget
			lsr <.rate

.get_attack_count:	;$9fa6:
	jsr getNumberOfRandomSuccess
	sta <.hitCount_1st

	lda .defProps+1
	sta <.count
	lda .defProps+2
	sta <.rate

	ldx <.iTargetCache
	lda <.targetStatusCache,x
	pha
	and #$04
	beq .target_not_blind
		lsr <.rate
.target_not_blind:	;$9fbf:
	pla
	ldx #1
	and #$28	;toad | minimum
	bne .cannot_defend
	ldy #$27
	lda [.pTarget],y
	beq .get_evade_count
.cannot_defend:
		dex
		stx <.rate

.get_evade_count:
	txa
	pha	;can't defend flag

	jsr getNumberOfRandomSuccess
	lda .isFarTarget
	beq .calc_hit_count
		inc <$30
;$9fd9:
.calc_hit_count:
	lda <.hitCount_1st
	sec
	sbc <$30
	bcs .store_hit_count
		lda #0
.store_hit_count:
	sta <.count
	sta <.hitCount_1st
	bne .attack_hit
		pla	;undefendable flag
		jmp doFight_next_hand

.attack_hit:	;$9ff1
.attrMultiplier = $27
	ldx #4
	lda .attackProps
	ldy #$12	;weakattr
	and [.pTarget],y
	bne .store_attr_multi
	;
	ldx #2
	lda .defProps
	cmp #$02
	beq .target_strong
		and .attackProps
		beq .store_attr_multi
.target_strong:
	dex
.store_attr_multi:
	stx <.attrMultiplier

	ldx #0
	stx <.atkHigh
	stx <.criticalCount
	inx
	stx <.damageDivider
	lda $7431	; $6e[y = #29]
	sta <.criticalBonus
	lda $7443
	sta <.atkLow
	
	jsr b31_getActor2C
	bmi .store_def
		ldy #$38
		jsr addValueAtOffsetToAttack
		iny
		jsr addValueAtOffsetToAttack

.store_def:
	nop


	.bank $31
	.org $a000

doFight_setupProps:
	DEF_DO_FIGHT_VARS

	lda .defProps+3
	sta <.def
	jsr b31_getTarget2C
	bmi .check_target_defendable
		and #7
		tax
		lda .isGuarding,x
		beq .check_target_defendable
			asl <.def
			bcc .check_target_defendable
				lda #$ff
				sta <.def

.check_target_defendable:
	pla	;defendable flag
	bne .check_actor_toad_minimum
		sta <.def
		asl <.atkLow
		rol <.atkHigh

.check_actor_toad_minimum:	;a055
	ldx <.iActorCache
	lda <.actorStatusCache,x
	and #$28
	beq .apply_charge
		lda #$01
		sta <.atkLow
		bne .get_damage
.apply_charge:
	.ifdef BOOST_CHARGE
		jsr applyCharge
	.endif;BOOST_CHARGE
.randomize_critical:
	lda #99
	jsr b31_getBattleRandom	;beb4
	cmp $7430	;$6e[#28]
	bcs .get_damage
		;critical
		inc <.criticalCount
		inc <$cb

.get_damage:	;$a093:
	jsr calcDamage	;bb44
	lda <.criticalCount
	beq .setup_effect_and_message
		lda #$34	;"ƒNƒŠƒeƒBƒJƒ‹ƒqƒbƒgI"
		jsr b31_queueBattleMessage

.setup_effect_and_message:
.pCalc = $24
	jsr set24ToTarget

	lda <$1c
	sta <.damage
	lda <$1d
	sta <.damage+1
	ora <$1c
	bne .check_absorb
		inc <.damage

.check_absorb:
.deadFlag = $26
	;ldy #$12
	lda .attackProps
	lsr a
	bcc .attr_not_absorb
		jsr isTargetWeakToHoly
		bcs .check_is_target_actor
			jsr sumDamage
	.check_is_target_actor:
		jsr b31_getActor2C
		eor [.pTarget],y
		and #$87
		beq .do_damage
			;target != actor
			jsr spoilHp	;bd67
			lda <.deadFlag
			beq .both_alive
			bmi .actor_dead
			bpl .target_dead
.attr_not_absorb:
	lda #0
	sta <.deadFlag
	jsr sumDamage
.do_damage:
	jsr damageHp
	bcs .both_alive
.target_dead:
		ldx <.iTargetCache
		lda <.targetStatusCache,x
		ora #$80
		sta <.targetStatusCache,x
		bmi .next_hand
.actor_dead:
		ldx <.iActorCache
		lda <.actorStatusCache,x
		ora #$80
		sta <.actorStatusCache,x
		bmi .next_hand
.both_alive:
	lda battleMode
	bmi .next_hand	;ƒ{ƒXí‚È‚ç’Ç‰ÁŒø‰Ê”»’è‚ð‚µ‚È‚¢
		ldy #1
		lda [.pActor],y
		and #$28
		bne .next_hand	;UŒ‚ŽÒ‚ªŠ^‚©¬l‚È‚ç”»’è‚µ‚È‚¢
			;fix --->
			ldx <.iTargetCache
			lda <.targetStatusCache,x
			and #$e8	;dead|stone|toad|minimum
			bne .next_hand	;‘ÎÛ‚ªª‚Ìó‘Ô‚È‚ç”»’è‚µ‚È‚¢(“G‚È‚çŠù‚ÉŽ€–Sˆµ‚¢)
			;<--- fix
			jsr checkEnchantedStatus	;be14 ’Ç‰ÁŒø‰Ê”»’è

.next_hand:
doFight_next_hand:	;$a139:	//hit”0(=ƒ~ƒX)‚È‚ç‚±‚±‚Ü‚Å”ò‚ñ‚Å‚­‚é
	DEF_DO_FIGHT_VARS

	dec .handCount
	beq .setup_damages
		ldx #4
	.update_props_to_another_hand:
			lda $7425,x
			sta $7440,x
			dex
			bpl .update_props_to_another_hand

		lda <.hitCount_1st
		sta <.hitCount_2nd
		inx	;0
		stx <.hitCount_1st
		stx <.damage
		stx <.damage+1
		jmp doFight_calc_damage_for_hand	;9f6a

.setup_damages:
	ldy #$27
	lda [.pTarget],y
	and #$7f	;clear undefendable tag
	sta [.pTarget],y

	lda #0
	sta [.pActor],y	;clear charge count

	lda .doubleArmed
	beq .store_damages
		lda <.hitCount_1st
		ldx <.hitCount_2nd
		stx <.hitCount_1st
		sta <.hitCount_2nd
.store_damages:
	ldy <.iTargetCache
	lda <.hitCount_1st
	sta <.hitCountForBlow_1st
	ora <.hitCount_2nd
	bne .not_miss
		sta <.hitCountForBlow_2nd
		sta play_damages,y
		lda #$40	;miss
		sta play_damages+1,y
		jmp .add_cannot_defend_message
.not_miss:
		lda <.hitCount_2nd
		sta <.hitCountForBlow_2nd

		lda #0
		sta <$43

		ldy #3
		lda [.pActor],y
		sta <.damage
		iny
		lda [.pActor],y
		sta <.damage+1
		
		jsr b31_getActor2C
		eor [.pTarget],y
		and #$87
		beq .no_message	;a203 => a216

		ldx <.iActorCache
		sec
		lda <.actorHp
		sbc <.damage
		sta play_damages+$10,x
		lda <.actorHp+1
		sbc <.damage+1
		sta play_damages+$11,x
		bcc .actor_healed
			;actorHpBeforeAttack >= actor.hp
			ora play_damages+$10,x
			bne .actually_healed
				;heal0pt
				dec play_damages+$10,x
				dec play_damages+$11,x
				bmi .no_message
		.actually_healed:
			ldy #$16
			lda [.pActor],y
			ldy #$1b
			ora [.pActor],y
			lsr a
			bcc .no_message
				ldx #$27	;"HP‚ð‚¬‚á‚­‚É‚·‚¢‚Æ‚ç‚ê‚½!"
				bne .add_absorb_message
	.actor_healed:
			lda play_damages+$11,x
			eor #$7f
			sta play_damages+$11,x
			
			lda play_damages+$10,x
			eor #$ff
			tay
			iny
			bne .store_heal_low
				inc play_damages+$11,x
		.store_heal_low:
			tya
			sta play_damages+$10,x
				
			ldx #$25
			jsr b31_getActor2C
			bpl .player_is_healed
				inx
	.player_is_healed:
	.add_absorb_message:
		txa
		jsr b31_queueBattleMessage
		inc <$43
.no_message:
	ldx <.iTargetCache
	lda <$42
	beq .store_target_damage
		ldy #3
		sec
		lda [.pTarget],y
		sbc <.targetHp
		sta play_damages,x
		iny
		lda [.pTarget],y
		sbc <.targetHp+1
		ora #$80
		bne .store_target_damage_high
	.store_target_damage:
		lda <$6a
		sta play_damages,x
		lda <$6b
.store_target_damage_high:
	sta play_damages+1,x

.add_cannot_defend_message:	;$a264:
	jsr b31_getActor2C
	bpl .check_segment

		lda <.escapeCount
		beq .finish

		lda <.hitCount_1st
		beq .finish

			lda #$55	;"‚É‚°‚²‚µ‚Å ‚Ú‚¤‚¬‚å‚Å‚«‚È‚©‚Á‚½!"
			jsr b31_queueBattleMessage
	.finish:
		jmp b31_getActor2C

.check_segment:	;a28d
	jsr checkSegment	;bf53
	jmp $a290

b31_queueBattleMessage:
	ldx battleMessageCount
	sta battleMessages,x
	inc battleMessageCount
	rts

applyCharge:
.atkLow = $25
.atkHigh = $2b
.tempAtk = $18	;
.pActor = $6e
	lda <.atkLow
	sta <.tempAtk
	lda <.atkHigh
	sta <.tempAtk+1

	ldx #4
.shift_left_atk:
		asl <.atkLow
		rol <.atkHigh
		dex
		bne .shift_left_atk
	ldy #$27
	lda [.pActor],y
	tax
	beq .restore
.add_charge_bonus:
		clc
		lda <.atkLow
		adc <.tempAtk
		sta <.atkLow
		lda <.atkHigh
		adc <.tempAtk+1
		sta <.atkHigh
		dex
		bne .add_charge_bonus
.restore:
	ldx #4
.shift_right_atk:
		lsr <.atkHigh
		ror <.atkLow
		dex
		bne .shift_right_atk
	rts

	VERIFY_PC $a28d
;
;$a28d:
;	checkSegmentation();	//$bf53();
;	//if ((a = $6e[y = #31]) >= 0) {	//bmi a29a
;	//	if ((a & 1) == 0) { //bne a2a6
;	if ((a = $6e[y = #31] < 0)
;		|| (a & 1) != 0)
;	{
;$a29a:
;		if ($7d == 0) {
;$a29e:
;			$bc = $7c;
;			$bb = 0;
;		}
;	}
;$a2a6:
;	a = $6e[y = #33] & 4;
;	if (a != 0) {
;		$bb = $7c + $7d;
;	}
;$a2b5:
;	return getActor2C(); //fall through
;}
;------------------------------------------------------------------------------------------------------
	INIT_PATCH $31,$bd67,$bdaa
;$31:bd67 spoilHp
spoilHp:
.deadFlag = $26
.undead = $42
.damage = $78
.pCalc = $24
.pActor = $6e
.pTarget = $70
;
	lda #0
	sta <.deadFlag
	jsr isTargetWeakToHoly	;bbe2
	bcc .normal_target
	;undead
		lda <.pTarget
		pha
		lda <.pTarget+1
		pha
		jsr set24ToActor
		inc <.undead
		lda #$81
		bne .do_damage
.normal_target:
		lda <.pActor
		pha
		lda <.pActor+1
		pha
		lda #$01
.do_damage:
	pha
	jsr damageHp	;bcd2
	pla
	bcs .alive
	;dead
		sta <.deadFlag
.alive:
	ldy #$2e
	lda [.pActor],y
	cmp #$04	;fight
	bne .do_heal
		jsr shiftRightDamageBy2	;bdaa
.do_heal:
	pla
	sta <.pCalc+1
	pla
	sta <.pCalc
	jmp healHp
;$bdaa

;------------------------------------------------------------------------------------------------------
	INIT_PATCH $31,$bcc9,$bcd2
applyStatus_addStoneMessage:
	lda #$28
	jmp b31_queueBattleMessage

;======================================================================================================
	RESTORE_PC ff3_battle_calc_begin