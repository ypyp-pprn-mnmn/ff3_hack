; ff3_commands.asm
;
; description:
;	replaces command handlers
;
; version:
;	0.08 (2006-11-12)
;
; note:
;	'ff3_executeAction.asm' and 'ff3_command_window.asm' must be included before this file
;======================================================================================================
ff3_commands_begin:

	INIT_PATCH $35,$a71c,$adaf
	;INIT_PATCH $35,$a71c,$a7df
	
DECLARE_COMMAND_VARS	.macro
.iPlayer = $52
.pBaseParam = $57
.pEquips = $59
.pBattleParam = $5b
.pTargetBase = $5d
.offset = $5f
	.endm

DECLARE_BATTLE_PTR	.macro
.pActor = $6e
.pTareget = $70
	.endm
;======================================================================================================
selectSingleTargetAndSetYto2F:
;out a : targetbit
;out y : #2f
.targetMode = $b3
.selectedTarget = $b4
	lda #0 ;single sel
	sta <.targetMode
	lda #$10	;select target
	jsr call_2e_9d53
	jsr setYtoOffset2F
	lda <.selectedTarget
	rts

getPlayerLine:
.pEquips = $59
	lda #$0f
	jsr setYtoOffsetOf
	lda [.pEquips],y
	lsr a
	rts

;$35:a7cd initMoveArrowSprite
initMoveArrowSprite:
.iPlayer = $52
	lda #0
	sta <$18
	jsr clearSprites2x2	;$8adf
	lda #$5d	;arrow
	sta $0221	;sprite.tileIndex
	lda <.iPlayer
	asl a
	asl a
	rts
;------------------------------------------------------------------------------------------------------
;ぜんしん(02)
;$35:a71c commandWindow_OnForwardSelected
commandWindow_OnForward:
	DECLARE_COMMAND_VARS
	jsr getPlayerLine
	bcc commandWindow_beepAndCancel
.ok:
	jsr initMoveArrowSprite
	tax

	lda #$80 ;rightkey
	pha ;sta $18
	ldy #$43 ;sta $0222

	lda #$02
	bne commandWindow_setupMove
;$a750:

;command 03
;$35:a750 commandWindow_OnBack
commandWindow_OnBack:
	DECLARE_COMMAND_VARS

	jsr getPlayerLine
	bcs commandWindow_beepAndCancel

	jsr initMoveArrowSprite
	clc
	adc #2
	tax

	lda #$40 ;left
	pha
	ldy #$03 ;sta $0222
	tya

;fall through
commandWindow_setupMove:
	sta <$19

	lda commandWindow_arrowCoords,x
	sta $0220	;y
	lda commandWindow_arrowCoords+1,x
	sta $0223	;x

;$35:a784 showArrowAndDecideCommand
showArrowAndDecide:
;[in] y : spriteFlag
;[in] sp+0 : cancelKey
.beginningFlag = $78ba
.cancelKey = $18
.commandId = $19
	lda .beginningFlag
	and #$08
	beq .normal
;backattack!
		tya
		eor #$40
		tay
		lda commandWindow_arrowCoords_backattack+1,x
		sta $0223
		
		pla ;cancel key
		eor #%11000000	;$80 => 40 / 40 => 80
		pha
.normal:
	sty $0222
	pla	;cancel key
	sta <.cancelKey
.get_input:	;$a7a4:
		jsr presentCharacter
		jsr getPad1Input
		lda <inputBits
		beq .get_input
		
		tax
		lsr a
		bcs .OnA
		lsr a
		bcs commandWindow_cancelReturn
		cpx <.cancelKey
		bne .get_input
		beq commandWindow_cancelReturn
.OnA:
	jsr requestSoundEffect05
	ldx <.commandId
	bne commandWindow_decideReturn
commandWindow_beepAndCancel:
	jsr requestSoundEffect06
commandWindow_nop:
commandWindow_cancelReturn:
	lda #1
	rts
commandWindow_decideToTargetAll:
;x = commandId
	jsr setYtoOffset2F
	lda #$c0	;target flag
	sta <$b5
	lda #$ff	;target bit
	bne commandWindow_setTargetAndCommand
;------------------------------------------------------------------------------------------------------
;//04:たたかう
;$35:a843 commandWindow_OnFight
;	.org $a843
;commandWindow_OnFight:
;	lda #$04
;	;fall through
commandWindow_OnFight:
commandWindow_selectSingleTargetAndNext:
;[in] u8 x : commandId
.selectedTarget = $b4
	txa
	pha
	jsr selectSingleTargetAndSetYto2F
	bne .ok
		pla
		lda #1
		rts
.ok:
	pla
	tax
	lda <.selectedTarget
	;fall through
commandWindow_setTargetAndCommand:
;[in] u8 a : targetBit
;[in] u8 x : commandId
	DECLARE_COMMAND_VARS
.targetFlag = $b5
	sta [.pBattleParam],y	;2f
		
	iny
	lda <.targetFlag
	sta [.pBattleParam],y	;30
	;fall through
commandWindow_decideReturn:
;[in] u8 X : commandId
	DECLARE_COMMAND_VARS

	;pha	;commandId
	jsr setYtoOffset2E	;9b9b
	;pla
	txa
	sta [.pBattleParam],y
	inc <.iPlayer
	lda #1
	rts
;------------------------------------------------------------------------------------------------------
;//05:ぼうぎょ
;$35:a877 commandWindow_OnGuard
;commandWindow_OnGuard:
;	lda #$05
;	bne commandWindow_decideReturn
commandWindow_OnGuard = commandWindow_decideReturn
;------------------------------------------------------------------------------------------------------
;//06:にげる
;$35:a8ab commandWindow_OnEscapeSelected
;	.org $a8ab
;commandWindow_OnEscape:
;	lda #$06
;	bne commandWindow_decideReturn
;commandWindow_OnEscape = commandWindow_decideReturn
;------------------------------------------------------------------------------------------------------
;//07:とんずら
;$35:a8b5 commandWindow_OnSneakAway
;commandWindow_OnSneakAway:
;	lda #$07
;	bne commandWindow_decideReturn
;commandWindow_OnSneakAway = commandWindow_decideReturn
commandWindow_OnEscape:
commandWindow_OnSneakAway:
	lda battleMode
	lsr a	;escape flag
	bcc commandWindow_decideReturn
	bcs commandWindow_beepAndCancel
;------------------------------------------------------------------------------------------------------
;//08:ジャンプ
;$35:a9ab commandWindow_OnJump
;	.org $a9ab
commandWindow_OnJump:
.selectedTarget = $b4
.targetFlag = $b5
	jsr selectSingleTargetAndSetYto2F
	beq commandWindow_cancelReturn
	lda <.targetFlag
	bpl commandWindow_OnJump
	
	ldx #$08
	lda <.selectedTarget
	bne commandWindow_setTargetAndCommand
;------------------------------------------------------------------------------------------------------
;//0d:みやぶる
;$35:ab07 commandWindow_OnDetect
;	.org $ab07
;commandWindow_OnDetect:
;	lda #$0d
;	bne commandWindow_selectSingleTargetAndNext
commandWindow_OnDetect = commandWindow_selectSingleTargetAndNext
;------------------------------------------------------------------------------------------------------
;//0c:しらべる
;$35:ab6e commandWindow_OnInspect
;	.org $ab6e
;commandWindow_OnInspect:
;	lda #$0c
;	bne commandWindow_selectSingleTargetAndNext
commandWindow_OnInspect = commandWindow_selectSingleTargetAndNext
;------------------------------------------------------------------------------------------------------
;//0E:ぬすむ
;$35:ab9f commandWindow_OnSteal
;	.org $ab9f
;commandWindow_OnSteal:
;	lda #$0e
;	bne commandWindow_selectSingleTargetAndNext
commandWindow_OnSteal = commandWindow_selectSingleTargetAndNext
;------------------------------------------------------------------------------------------------------
;//0F:ためる
;$35:ac65 commandWindow_OnChargeSelected
;	.org $ac65
;commandWindow_OnCharge:
;	lda #$0f
;	bne commandWindow_decideReturn
commandWindow_OnCharge = commandWindow_decideReturn
;------------------------------------------------------------------------------------------------------
;//10:うたう
;$35:acd0 commandWindow_OnSing	
;	.org $acd0
;commandWindow_OnSing:
;	lda #$10
;	bne commandWindow_selectSingleTargetAndNext
commandWindow_OnSing = commandWindow_selectSingleTargetAndNext
;------------------------------------------------------------------------------------------------------
;//11:おどかす
;$35:ad0c commandWindow_OnIntimidate	
;	.org $ad0c
;commandWindow_OnIntimidate:
;	lda #$11
;	bne commandWindow_decideReturn
commandWindow_OnIntimidate = commandWindow_decideReturn
;------------------------------------------------------------------------------------------------------
;//12:おうえん
;$35:ad6b commandWindow_OnCheer
;	.org $ad6b
;commandWindow_OnCheer:
;	lda #$12
;	bne commandWindow_decideReturn
commandWindow_OnCheer = commandWindow_decideReturn
;------------------------------------------------------------------------------------------------------
;//0b:ちけい
;$35:aa22 commandWindow_0b
;	.org $aa22
	.ifdef EXTEND_GEOMANCE
commandWindow_OnGeomance = commandWindow_decideToTargetAll
	.else
commandWindow_OnGeomance:
.geomanceTargetFlag = $7a;$35:ab06 .db $7a	//???
	jsr getCurrentTerrain
	tax
	inx

	lda #.geomanceTargetFlag
.shift_loop:
		asl a
		dex
		bne .shift_loop
	bcc .target_all
		jsr dispatchBattleFunction_06	;802a
		ldx $7e99
		lda #$80
		bmi .store
.target_all:
		dex
		lda #$c0
.store:
.targetFlag = $b5
	sta <.targetFlag
	jsr setYtoOffset2F
	txa
	ldx #$0b
	bne commandWindow_setTargetAndCommand
	.endif	;EXTEND_GEOMANCE
;======================================================================================================
;a823
commandWindow_arrowCoords:
	.db $34,$B4,$34,$D4, $50,$B4,$50,$D4, $6C,$B4,$6C,$D4, $88,$B4,$88,$D4
;a833
commandWindow_arrowCoords_backattack:
	.db $34,$44,$34,$24, $50,$44,$50,$24, $6C,$44,$6C,$24, $88,$44,$88,$24
;$a7df:
;======================================================================================================
;//02:ぜんしん
;$35:a7df command_forward
;	.org $a7df
command_forward:
;	ldx #$39+$02
;	bne command_move
command_back:
;	ldx #$39+$03
command_move:
	DECLARE_COMMAND_VARS
.pActor = $6e

	ldy #$33
	lda [.pActor],y
	eor #$01	;invert line flag
	sta [.pActor],y
	jsr getPlayerOffsetFromActor
	clc
	adc #$0f
	tay
	lda [.pEquips],y
	eor #$01
	sta [.pEquips],y
	;fall through
setupNullTargetActionType01:
;[in] x : actionId * 2
	lda #$ff
	sta targetName	;78d8
	;fall through
setupActionType01:
;[in] x : actionId * 2
	lda #1
	sta battleProcessType
setupActionName:
;[in] x : actionId * 2
	txa
	lsr a
	clc
	adc #$39	;convert actionid to actionNameId
	sta actionName	;78d7
	rts
;$a816:
getPlayerOffsetFromActor:
	DECLARE_COMMAND_VARS
	jsr getActor2C
	and #7
	sta <.iPlayer
	jmp getPlayerOffset

;$a881
;$35:a881 command_guard
command_guard:
	DECLARE_COMMAND_VARS
.pActor = $6e
	jsr setupNullTargetActionType01

	jsr setXtoActorIndex
	ldy #$23
	lda [.pActor],y
	sta $7ce4,x
	bpl .def_under_80
		lda #$ff
		bne .store
.def_under_80:
		asl a
.store:
	sta [.pActor],y
	rts
;======================================================================================================
;$35:a8bf command_escape //06
command_escape:
	DECLARE_COMMAND_VARS
.pActor = $6e
.rate = $24
	;ldx #$39+$06
	jsr setupNullTargetActionType01
	
	lda #100
	jsr getSys1Random
	pha	;rand
	
	jsr getActor2C
	bmi command_escape_enemy
.actor_is_player:
.pEnemy = $24
	ldx #0
	txa
	tay
	stx <$18
	stx <$19
	stx <$1a
	stx <$1b
	INIT16 <.pEnemy,$7835
	ldx #7
.sum_enemy_lv:
		lda $7da7,x	;group
		bmi .next
			clc
			lda [.pEnemy],y
			adc <$18
			sta <$18
			lda #0
			adc <$19
			sta <$19
			inc <$1a
	.next:
		;SUB16 <.pEnemy,$0040
		SUB16by8 <.pEnemy,#$40
		dex
		bpl .sum_enemy_lv

	jsr div_16
	ldy #$2a
	lda [.pActor],y
	clc
	adc #25
	sec
	sbc <$1c	;average lv of enemies
	bcs .rate_plus
		lda #0
.rate_plus:
.beginningMode = $78ba
	sta <.rate
	pla	;rand
	cmp <.rate
	bcc command_escape_possible
	lda .beginningMode
	lsr a	;party surprise attack
	bcs command_escape_possible
;.fail:
command_escape_fail:
	lda #$1f	;"にげられない！"
	;sta battleMessages
	;rts
	jmp addBattleMessage

;enemy:
;a978
command_escape_enemy:
.pActor = $6e
	pla	;rand
	ldy #$22
	cmp [.pActor],y
	bcs command_escape_fail

	lda #$1e
	sta battleMessages
	jsr setXtoActorIndex
	lda #0
	jsr flagTargetBit
	pha ;sta $78d4
	txa
	asl a
	tax
	lda <$f0,x
	ora #$80
	sta <$f0,x
	;rts
	pla
	bne command_escape_succeeded
;//07
;$35:a93b command_sneakAway	//[sneak away]
command_sneakAway:
	;ldx #$39+$07
	jsr setupNullTargetActionType01
command_escape_possible:
	DECLARE_COMMAND_VARS

	lda battleMode	;7ed8
	lsr a	;escape forbidden flag
	bcs command_escape_fail

	ldx #3
.check_confused_member:
		stx <.iPlayer
		jsr getPlayerOffset
		tay
		iny
		iny
		lda [.pBattleParam],y
		and #$20
		bne command_escape_fail
		dex
		bpl .check_confused_member
;ok
	lda #2
	sta $78d3
	lda #$f0
command_escape_succeeded:
	sta $78d4
	lda #$1e	;"にげだした････"
	jmp addBattleMessage
	;sta battleMessages
	;rts
;======================================================================================================
;$a9d8
;$35:a9d8 command_jump
command_jump:
	DECLARE_COMMAND_VARS
.pActor = $6e
	;ldx #$39+$08
	jsr setupActionType01

	ldy #$01
	lda [.pActor],y
	and #$28
	beq .ok
;fail
		lda #$18
		sta effectHandlerIndex
		jmp command_setNoEffectAndReturn
.ok:
;$a9f6:
	jsr setXtoActorIndex16
	inx
	lda <$f0,x
	ora #$01
	sta <$f0,x
	iny
	iny
	lda #$09
	sta [.pActor],y	;2e
	rts
;
;$35:aa11 command_09 //landing
command_land:
.pActor = $6e
	ldy #2
	lda [.pActor],y
	and #$fe
	sta [.pActor],y
	ldy #$27
	lda #CHARGE_COUNT_JUMP
	sta [.pActor],y
	jmp dispatchBattleFunction_03	;801e
;$aa22:
;======================================================================================================

;$aa5d:
;$35:aa5d command_0b


	.ifdef EXTEND_GEOMANCE
geomance_rates:
	;	じしん りゅうさ かまいたち そこなしぬま きゅうりゅう うずしお たつまき なだれ
	.db $f0,$60,$00,$30
	.db $0f,$50,$00,$00
	.db $00,$f0,$00,$50
	.db $00,$0f,$00,$30
	.db $00,$50,$f0,$00
	.db $00,$00,$5f,$00
	.db $00,$50,$00,$f0
	.db $20,$00,$00,$08
command_geomance:
	DECLARE_COMMAND_VARS
.pActor = $6e
.rates = $18
	jsr getActor2C
	ora #$10
	sta [.pActor],y
	jsr getCurrentTerrain
	tay
	iny
	tya
	asl a
	asl a
	tay
	dey
	ldx #7
.cache_rates:
		lda geomance_rates,y
		pha
		and #$0f
		sta <.rates,x
		dex
		pla
		jsr $fd45	;a>>=4
		sta <.rates,x
		dey
		dex
		bpl .cache_rates
	ldx #7
	lda #0
.sum_rates:
.bounds = $7400
		clc
		adc <.rates,x
		sta .bounds,x
		dex
		bpl .sum_rates
	;a = sum of rates
	jsr getSys1Random
	ldx #7
.find_id:
		cmp .bounds,x
		bcc .found
		dex
		bpl .find_id
.found:
.geomanceTargetFlag = $7a
.pTarget = $70
	;x = terrain index
	txa
	pha
	lda #.geomanceTargetFlag
.shift_loop:
		asl a
		dex
		bpl .shift_loop
	bcc .target_all	;no more processing
		jsr dispatchBattleFunction_06	;802a
		ldx #1
		jsr targetBitToCharIndex	;y = index from $7e99
		tya
		pha
		INIT16 <.pTarget,$7675
	.get_target_ptr:
			ADD16by8 <.pTarget,#$40
			dey
			bne .get_target_ptr
		lda #$80
		ldy #$30
		sta [.pActor],y
		dey
		pla
		sta [.pActor],y
.target_all:
	pla
	clc
	adc #$50
	.else ;EXTEND_GEOMANCE

command_geomance:
	DECLARE_COMMAND_VARS
.pActor = $6e
	jsr getActor2C
	ora #$10
	sta [.pActor],y
	jsr getCurrentTerrain	;aac3
	clc
	adc #$50

	.endif ;EXTEND_GEOMANCE

	ldy #$2e
	sta [.pActor],y
	sta <$1a
	.ifdef BOOST_GEOMANCER
		ldy #$0
		lda [.pActor],y
		pha
		ldy #$0f
		clc
		adc [.pActor],y
		ldy #0
		sta [.pActor],y
		jsr command_magic
		pla
		ldy #$0
		sta [.pActor],y
	.else
		jsr command_magic
	.endif	;BOOST_GEOMANCER
	inc <$cc
	lda #$14
	sta effectHandlerIndex
	
	lda play_effectTargetBits	;7e9b
	bne command_doReturn
;failed. nature bites player
	lda #3
	sta <$54
;$aac3:
damageActorByQuoterHalf:
;[out] x : cacheIndex
.maxhp = $18
.pActor = $6e
.actorStatusCache = $f0
	jsr setXtoActorIndex16

	ldy #5
	lda [.pActor],y
	sta $7e5f,x
	iny
	lda [.pActor],y
	lsr a
	ror $7e5f,x
	lsr a
	sta $7e60,x
	ror $7e5f,x

	ldy #3
	sec
	lda [.pActor],y
	sbc $7e5f,x
	sta [.pActor],y
	iny
	lda [.pActor],y
	sbc $7e60,x
	sta [.pActor],y
	dey
	ora [.pActor],y
	;a9d4
	beq .result_dead
	bcs .finish
.result_dead:
		lda #$80
		sta <.actorStatusCache,x
		asl a
		sta [.pActor],y
		iny
		sta [.pActor],y
.finish:
command_doReturn:
	rts
;$35:aac3 getCurrentTerrain
getCurrentTerrain:
	lda $7ce3
	cmp #$08
	bcc .finish
		ldx #$05
		cmp #$12
		beq .use_low
		;bne .load_param
		;	;lda #$55
		;	lda #$05
		;	rts
	.load_param:
		clc
		lda $74c8	;field $48
		adc #$4e
		sta <$46
		lda #0
		adc #$a2
		sta <$47
		
		lda #$1a	
		sta <$4a	;current bank
		lda #1
		sta <$4b	;size
		lda #0		;src bank
		jsr copyTo7400

		ldx $7400
		lda battleMode	;$7ed8
		and #8

		bne .use_high
	.use_low:
			txa
			and #$0f
	.finish:
			rts
	.use_high:
		txa
		jmp $fd45	;a>>4
;$35:ab06 .db $7a	//???
;======================================================================================================
;setEffectHandlerTo18 = $ab66
;$35:ab0c command_detect
command_detect:
.pTarget = $70
	;ldx #$39+$0d
	jsr setupNoMotionType01

	ldy #1
	lda [.pTarget],y
	bmi command_setNoEffectAndReturn
.ok:
;$ab27:
.count = $18
	ldy #$12
	lda [.pTarget],y

	ldy #0
	;ldx battleMessageCount
	sty <.count
.queue_weak_points:
		asl a
		bcc .next
			inc <.count
			pha
			;pha
			;tya
			;;clc (always set)
			;adc #$47
			;sta battleMessages,x
			;pla
			;inx
			;stx battleMessageCount
			tya
			;carry always be set
			adc #$47
			jsr addBattleMessage
			pla
	.next:
		iny
		cpy #7
		bne .queue_weak_points
	lda <.count
	bne .finish
		lda #$43
		jsr addBattleMessage
		;sta battleMessages,x
.finish:
	rts

command_setNoEffectAndReturn:
	;ldx #$3b
	;stx battleMessages
	;rts
	lda #$3b
	jmp addBattleMessage
;======================================================================================================
;$35:ab73 command_inspect
command_inspect:
.pTarget = $70
	;jsr setEffectHandlerTo18
	ldy #6
	ldx #3
.copy_hp:
		lda [.pTarget],y
		sta $78e4,x
		dey
		dex
		bpl .copy_hp
	
	ldy #1
	ldx #$3f
	lda [.pTarget],y
	bpl .ok
		ldx #$3b
.ok:
	stx battleMessages
	ldx #$0c*2
	;fall through
setupNoMotionType01:
;[in] x : actionId * 2 (initial value on handler entry)
	jsr setupActionType01
setEffectHandlerTo18	;18=do nothing
	lda #$18
	sta effectHandlerIndex
	inc <$cc
	rts
;======================================================================================================
;$35:aba4 command_steal
command_steal:
.pActor = $6e
.pTarget = $70
	;ldx #$39+$0E
	jsr setupNoMotionType01

	ldy #$2c
	lda [.pTarget],y
	bmi .target_is_enemy
.fail:
		lda #$35 ;"ぬすみそこなった"
		jmp addBattleMessage
		;sta battleMessages
		;rts
.target_is_enemy:
	ldy #1
	lda [.pTarget],y
	and #$e8
	bne .fail

.rate = $24
	clc
	dey
	lda [.pActor],y
	ldy #$0f
	adc [.pActor],y
	sta <.rate
	lda #$ff
	jsr getSys1Random
	cmp <.rate
	bcs .fail

.dropTableIndex = $18
	ldy #$36
	lda [.pTarget],y
	and #$1f
	sta <.dropTableIndex
	;
	lda #$08
	sta <$1a
	INIT16 <$20,$9b80
	lda #$08
	ldx #$00
	ldy #$1a
	jsr loadTo7400Ex
.dropList = $7400
	lda #$ff
	jsr getSys1Random
	ldx #3
.get_index:
		cmp .bounds,x
		bcs .found_index
		dex
		bpl .get_index
.found_index:
	lda .dropList,x
	tay
	beq .fail

	jsr .findItem
	bmi .put_drop
	lda #0
	jsr .findItem
	bpl .fail
.put_drop:
	inc backpackItems-$c0+1,x
	lda backpackItems-$c0+1,x
	cmp #100
	bcc .store_id
		lda #99
		sta backpackItems-$c0+1,x
.store_id:
	tya	;itemid
	sta backpackItems-$c0,x
.finish:
	sta $78e4
	lda #$29
	jmp addBattleMessage
	;sta battleMessages
	;rts
.findItem:
;[in] a : itemid to find
	ldx #$c0
.find_loop:
		cmp backpackItems-$c0,x
		beq .found
		inx
		inx
		bne .find_loop
.found:
	txa
	rts
.bounds:
	.db $00,$30,$60,$90
;$ac65
;======================================================================================================
;$35:ac6f command_charge //0F
command_charge:
.pActor = $6e
	;ldx #$39+$0f
	jsr setupActionType01

	ldx #$3b ;"こうかがなかった"
	ldy #1
	lda [.pActor],y
	and #$28
	bne .fail
		ldy #$27
		lda [.pActor],y
		clc
		adc #CHARGE_INCREMENT
		cmp #CHARGE_MAX
		bcs .bomb
		;ok
			sta [.pActor],y
			lda #0
			sta $7e93
			rts
.bomb:
		;bomb
		lda #0
		sta [.pActor],y
		ldy #4
		lda [.pActor],y
		lsr a
		sta [.pActor],y
		dey
		lda [.pActor],y
		ror a
		sta [.pActor],y
		iny
		ora [.pActor],y
		bne .bomb_alive
			;jsr setXtoActorIndex
			;asl a
			;tax
			jsr setXtoActorIndex16
			lda <$f0,x
			ora #$80
			sta <$f0,x
	.bomb_alive:
		lda #1
		sta $7e93
		ldx #$2f	;"ためすぎてじばくした!"
.fail:
	stx battleMessages
	rts
;======================================================================================================
;$35:acd5 command_sing
command_sing:
.pActor = $6e
;竪琴チェック オリジナルは装備欄のIDによる
	ldy #$31
	lda [.pActor],y
	iny
	ora [.pActor],y
	and #$08	;harp
	beq .fail
		jmp command_fight
.fail:
	lda #1
	sta battleProcessType
	lda #$42	;"たてごとがないのでうたえない"
	sta battleMessages
	lda #$18
	sta effectHandlerIndex
	rts
;======================================================================================================
;$35:ad16 command_intimidate
command_intimidate:
	DECLARE_COMMAND_VARS

	lda battleMode
	lsr a	;escape forbidden
	bcc .ok
		jmp command_setNoEffectAndReturn
.ok:
	ldy #0
	
	.ifdef BOOST_INTIMIDATE
		ldx #7
	.set_lv:
			lda [.pTargetBase],y
			lsr a
			sta [.pTargetBase],y
			lsr a
			clc
			adc [.pTargetBase],y
			sta [.pTargetBase],y
			;ADD16 <.pTargetBase,$0040
			ADD16by8 <.pTargetBase,#$40
			dex
			bpl .set_lv
	.else
		sec
		lda [.pTargetBase],y
		sbc #3
		bcs .diff_plus
			tya	;0
	.diff_plus:
		ldx #7
	.set_lv:
			pha
			sta [.pTargetBase],y
			;ADD16 <.pTargetBase,$0040
			ADD16by8 <.pTargetBase,#$40
			pla
			dex
			bpl .set_lv
	.endif	;BOOST_INTIMIDATE
	
	INIT16 <.pTargetBase,$7675
	lda #$32
	sta battleMessages
	lda #$ff
	sta targetName	;$78d8
	;ldx #$39+$11
	ldx #$11*2
	jmp setupActionType01

;$ad6b:
;}
;======================================================================================================
;$35:ad75 command_cheer
command_cheer:
	DECLARE_COMMAND_VARS
	ldx #3
.for_each_player:
		stx <.iPlayer
		jsr getPlayerOffset
		clc
	.ifdef BOOST_CHEER
		adc #$38	;bonus atk
		tay
		lda [.pBattleParam],y
		;clc	;always cleared
		adc #$20
		bcc .next
			lda #$ff
			sta targetName
	.else
		adc #$19
		tay
		lda [.pBattleParam],y
		;clc
		adc #10
		bcc .next
			lda #$ff
			sta targetName
	.endif	;BOOST_CHEER
	.next:
		sta [.pBattleParam],y
		dex
		bpl .for_each_player
	ldx #$31
	stx battleMessages
	;ldx #$39+$12
	ldx #$12*2
	jmp setupActionType01

ff3_commands_end:
;======================================================================================================
;	RESTORE_PC ff3_commands_begin