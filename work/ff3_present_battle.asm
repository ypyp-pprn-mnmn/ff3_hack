; ff3_present_battle.asm
;
; description:
;	replaces presentBattle ($34:8ff7) related codes
;
; version:
;	0.6 (2017-12-17)
;======================================================================================================
ff3_present_battle_begin:

	INIT_PATCH $34,$8ff7,$9474
	;$93cd
	
battle.present:
presentBattle:
;[in]
.situation = $7ec2	; usually commandId (set by commandHandler); toadsAction=18,prizeMessage=2
.presentMode = $78d5; (commandChainId) (0-5: 0=attack 1=action 2,4=prize)
;[shared]
.commandId = $4b
.pCommandList = $62
.iCommand = $64
;--------------------------------------------------------------
	lda .situation
	beq .finish
		lda .presentMode
		asl a
		tax
		lda pb_commandLists,x
		sta <.pCommandList
		lda pb_commandLists+1,x
		sta <.pCommandList+1
		ldx #0
		stx battleMessageCount ;fromhere meaning changes to 'message index'
		stx $78ef
		stx <.iCommand
	.command_loop:
			jsr pb_initString
			ldy <.iCommand
			lda [.pCommandList],y
			sta <.commandId	;00-0e
			;cmp #$ff
			;beq .finish
			bmi .finish
			asl a
			clc
			adc #LOW(pb_handlers) ;#$4d
			sta <$19
			lda #HIGH(pb_handlers) ;#$95
			;adc #$00
			sta <$1a
			lda #$6c	;jmp (ptr)
			sta <$18
			;0018: jmp ($954d + commandId<<1)
			;jmp $0018
			jsr $0018
			inc <.iCommand
			bne .command_loop
;$9051:
;	.org $9051
;		rts
.finish: ;$9056:
	lda #$25
	jmp call_2e_9d53	;fa0e
;$905b:
pb_initString:
	lda #0
	ldx #$13
.init_string:
		sta stringCache,x
		dex
		bpl .init_string
	;rts
	jmp initTileArrayStorage	;9754
;------------------------------------------------------------------------------------------------------
;	.org	$905b

pb_loadName:
.pPlayer = $57
;indexToGroup = $7ecd
;[in] a : charIndex
	bmi .index_means_enemy
		jsr shiftLeft6
		clc
		adc #$0b
		tay
		ldx #5
	.load_player_name:
			lda [.pPlayer],y
			sta stringCache,x
			dey
			dex
			bpl .load_player_name
			bmi .finish
.index_means_enemy:
		and #$7f
		cmp #8
		bne .single_target
			jsr setBaseAddrTo_8c40
			lda #$16
			sta <$1a
			jmp .load
	.single_target:
			tax
			lda indexToGroupMap,x
			tax
			lda groupToEnemyIdMap,x
			sta <$1a
			jsr setBaseAddrTo_8a40
	.load:
		ldx #0
		lda <$1a
		jsr loadString
.finish:
	rts

pb_checkNoMessage:
	cmp #$ff
	bne .ok
		pla	;retaddr
		pla	;retaddr
.ok:
	rts
;------------------------------------------------------------------------------------------------------
pb_showActorName:	;command05
.actor = $78d6
	lda .actor
	jsr pb_checkNoMessage
	jsr pb_loadName
	lda #0
	beq pb_drawWindow
;$90a0:
;------------------------------------------------------------------------------------------------------
;	.org $9177
pb_showTargetName:	;command07
.target = $78d8	;charIndex
	lda .target
	jsr pb_checkNoMessage
	jsr pb_loadName
	lda #2
	bne pb_drawWindow
;$91ce:
;------------------------------------------------------------------------------------------------------
;	.org	$91d4
pb_showEffectMessage:	;command08
.effect = $78d9
	lda .effect
	jsr pb_checkNoMessage
	clc
	adc #$0c
	sta <$1a
	ldx #$82
	stx <$19
	ldx #0
	stx <$18
	jsr loadString
	lda #3
	;bne pb_drawWindow
pb_drawWindow:
	pha
	ldx #8
	stx <$18
	jsr strToTileArray
	pla
	jmp draw1LineWindow
	;jmp $9051	
;------------------------------------------------------------------------------------------------------
;	.org	$90a0
pb_showActionName:	;command06
.isItem = $72
.messageId = $78d7
.pTileArray = $7ac0
	lda <.isItem
	beq .not_item
;item
		ldx #0
		stx <$18
		lda #$88
		sta <$19
		lda .messageId
		jsr loadString
		ldx #$f7	;-9
	.shift_itemstr:
			lda stringCache-$f6,x
			sta stringCache-$f7,x
			inx
			bne .shift_itemstr
		lda #1
		bne pb_drawWindow
.not_item:
	lda .messageId
	jsr pb_checkNoMessage
	ldy #5
.map_to_kind:
		cmp .bounds,y
		bcs .mapped
		dey
		bpl .map_to_kind
.mapped:
	;y = kind
	ldx #0
	cpy #1	;01 <= msgid <= 20 'n times hit'
	bne .not_hit_message
		sta <$18
		stx <$19	;0
		jsr itoa_16
		ldx #2
	.store_count_digits:
			lda <$1d,x
			sta stringCache,x
			dex
			bpl .store_count_digits
		ldx #2
		lda #$13
.not_hit_message:
.load_base:
	pha
	tya
	asl a
	tay
	lda .baseOffsets,y
	sta <$18
	lda .baseOffsets+1,y
	sta <$19
	pla
	cpy #(3*2)
	bne .load_string
			;action
			sec
			sbc #$39
	.ifdef ENABLE_EXTRA_ABILITY
			jsr getExtraAbilityNameId
	.endif	;ENABLE_EXTRA_ABILITY
			ldx #0
.load_string:
	jsr loadString
	lda #1
	bne pb_drawWindow
;	msg		base	msgToIndex	meaning
;	00:		8c40	=09		miss
;	01-20:	8c40	=13		fight
;	21-38:	8a40	+c6		summon
;	39-51:	8c40	-39		action
;	52-7f:	8200	-46		status
;	80-fe:	8990	-80		special
;	ff: no message
.bounds:
	.db $00,$01,$21,$39,$52,$80
;.messageOffsets:
;	.db $09,$00,$c6,$c7,$ba,$80
.baseOffsets:
	.dw	$8c40 + $09*2
	.dw	$8c40
	.dw	$8a40 + $c6*2
	.dw $8c40; - $39*2
	.dw $8200 - $46*2
	.dw $8990 - $80*2
;$9177:
;------------------------------------------------------------------------------------------------------
pb_showInfoMessage:	;command09
;.messages = $78da
;.messageCount = $78ee
.messageParams = $78e4
.iMessageParam = $78ef
pb_showInfoMessage_subCommands = $9575
	ldx battleMessageCount
	lda battleMessages,x
	jsr pb_checkNoMessage
	lsr a
	tax
	lda pb_showInfoMessage_subCommands,x
	;carry still remains
	bcs .even_index
		jsr $fd45	;shiftright4
.even_index:
	and #$0f
	asl a
	clc
	adc #LOW(pb_showInfoMessage_handlers) ;#$6b
 	sta <$19
 	lda #HIGH(pb_showInfoMessage_handlers) ;#$95
 	adc #0
	sta <$1a
	lda #$6c	;jmp (xxxx)
	sta <$18
	jsr $0018
;$9236	
	inc battleMessageCount
	rts
;$923c
;------------------------------------------------------------------------------------------------------
pb_loadInfoMessage:
	pha
	jsr setBaseAddrTo_8c40
	pla
	tax
	ldy battleMessageCount
	lda battleMessages,y
	jmp loadString
pb_showInfoMessage_00:
	lda #0
	;fall through
pb_loadInfoMessageAndDraw:
	jsr pb_loadInfoMessage
pb_drawInfoWindow:
	ldx #$11
	stx <$18
	jsr strToTileArray
	lda #4
	jmp draw1LineWindow	;8d1b
;------------------------------------------------------------------------------------------------------
pb_loadInfoMessageAndDrawWithWait:
pb_showInfoMessage_01:
	lda #0
	jsr pb_loadInfoMessageAndDraw
	;jmp waitForPad1AButtonDown
waitForPad1AButtonDown:
.wait_loop:
		jsr getPad1Input
		lda <inputBits	;$12
		and #1
		beq .wait_loop
	rts
;------------------------------------------------------------------------------------------------------
pb_printHp:
;.destEnd = $24
	pha
	jsr pb_getMessageParam16
	ldx #4
	pla
	tay
.copy:
		lda <$1a,x
		sta stringCache,y
		dey
		dex
		bpl .copy
	rts
;------------------------------------------------------------------------------------------------------
pb_getMessageParam16:
.iParam = $78ef
.battleMessageParams = $78e4
	ldx .iParam
	lda .battleMessageParams,x
	sta <$18
	inx
	lda .battleMessageParams,x
	sta <$19
	inx
	stx .iParam
	jmp itoa_16
;------------------------------------------------------------------------------------------------------
;$34:91ce setNoTargetMessage
	.org	$91ce
setNoTargetMessage:
	lda #$ff
	sta $78d8
	rts
;------------------------------------------------------------------------------------------------------
pb_showInfoMessage_02_message:	;"HP_?????/?????"
	.db	$77,$79,$ff,$c5,$c5,$c5,$c5,$c5,$c7,$c5,$c5,$c5,$c5,$c5
;------------------------------------------------------------------------------------------------------
	;.org	$91d4
pb_showInfoMessage_02:
.pActor = $6e	;
	ldx #$0d
.init_string:
		; 0123456789abcd
		;"HP_?????/?????"
		lda pb_showInfoMessage_02_message,x
		sta stringCache,x
		dex
		bpl .init_string
	ldy #$30
	lda [.pActor],y
	bpl .get_hp
	lda battleMode
	bmi .show
.get_hp:
		lda #$07
		;sta <$24
		jsr pb_printHp
		lda #$0d
		;sta <$24
		jsr pb_printHp
.show:
	;fall through
pb_drawAndWait:
	jsr pb_drawInfoWindow
	jmp waitForPad1AButtonDown
;$92b5
;------------------------------------------------------------------------------------------------------
;$92db:
pb_showInfoMessage_03:
;	%u + message
	jsr pb_getMessageParam16
	ldx #0
	ldy #0
.copy:
		lda <$1a,x
		cmp #$ff
		beq .next
			sta stringCache,y
			iny
	.next:
		inx
		cpx #5
		bne .copy
	tya
	jsr pb_loadInfoMessageAndDraw
	jmp waitForPad1AButtonDown
;------------------------------------------------------------------------------------------------------
;$932b
pb_showInfoMessage_04:
	lda #0
	jsr pb_loadInfoMessage
	;stx <$2a
	INIT16 <$18,$8800
	lda $78e4
	;ldx <$2a
	jsr loadString
	lda #$ff
	sta stringCache+5
	;jmp pb_drawAndWait
	bne pb_drawAndWait
;$934e
;------------------------------------------------------------------------------------------------------
;$34:934e dispCommand_0B
pb_showDamage:	;command0C
	lda #$17
	;fall through
pb_storeAndPlayEffect:
	sta $7ec2
	;fall through
pb_playEffect:
	jmp playEffect	;8411
;------------------------------------------------------------------------------------------------------
pb_showDyingEffect:	;command0D
.pActor = $6e
;	[in] u8 $78d3 : ?
	lda $78d3
	and #2
	bne pb_doReturn
;actor:		player			enemy
;target:
; player	f0/93cd-e0/93cd	f0/9408-e0/93cd
; enemy		f0/93cd-e0/9408 f0/9408-e0/9408
	jsr $95d8	;$18 = $00f0
	jsr getActor2C	;a42e
	bmi .actor_is_enemy	
		jsr pb_updatePlayerStatus	;$93cd
		jmp .update_target
.actor_is_enemy:
		jsr pb_updateEnemyStatus	;$9408
.update_target:
	;todo: check actor != target 
	jsr $95cf	;$18 = $00e0
	ldy #$30
	lda [.pActor],y
	bmi .target_is_enemy
		jsr pb_updatePlayerStatus	;$93cd
		jmp .show_effect
.target_is_enemy:
		jsr pb_updateEnemyStatus	;$9408
.show_effect:
	jsr $9474
	jsr $9d06
pb_setEffect16:
	lda #$16
	bne pb_storeAndPlayEffect
pb_doReturn:
	rts
;------------------------------------------------------------------------------------------------------
;$34:93c4 dispCommand_0E
pb_updateTargetCache:	;command0E
	;jsr $95cf
	;jsr pb_updateEnemyStatus	;$9408
	jsr updateEnemyStatusByTargetCache
	jmp pb_setEffect16
;$93cd
updateEnemyStatusByTargetCache:
	jsr set18toTargetCache	;$95cf
	jmp pb_updateEnemyStatus	;$9408
;------------------------------------------------------------------------------------------------------
;$34:93cd updatePlayerStatus
pb_updatePlayerStatus:
.pCache = $18
.iPlayer = $52
.pBattleParam = $5b
.offset = $5f

	ldx #3
.for_each_player:
		stx <.iPlayer
		jsr getPlayerOffset	;a541

		lda <.iPlayer
		asl a
		tax
		tay
		lda [.pCache],y	;y = player * 2
		ldy <.offset
		iny
		ora [.pBattleParam],y	;y = offset 01
		sta [.pBattleParam],y
		bpl .player_alive
			;lda [.pBattleParam],y
			and #$fe
			bmi .next	;always satisfied
	.player_alive:
			iny
			sty <$1a
			txa
			tay
			iny
			lda [.pCache],y
			ldy <$1a
			ora [.pBattleParam],y
	.next:
		sta [.pBattleParam],y
		ldx <.iPlayer
		dex
		bpl .for_each_player
	rts
;------------------------------------------------------------------------------------------------------
;$34:9408 updateEnemyStatus
pb_updateEnemyStatus:
.pCache = $18
.pEnemy = $1e
.status = $7ec4

	INIT16 <.pEnemy,$7835
	ldx #7
.for_each_enemy:
		txa
		asl a
		pha
		
		tay
		lda [.pCache],y
		ldy #1
		ora [.pEnemy],y
		sta [.pEnemy],y
		and #$e8	;dead|stone|toad|minimum
		beq .enemy_alive
			ora #$80
			sta [.pEnemy],y
			sta .status,x
	.enemy_alive:
		pla
		tay
		iny
		lda [.pCache],y
		ldy #2
		ora [.pEnemy],y
		sta [.pEnemy],y
		
		;SUB16 <.pEnemy,$0040
		SUB16by8 <.pEnemy,#$40
		dex
		bpl .for_each_enemy
	rts
;$9450:
;======================================================================================================
;	.org	$9450
	;$34:9450 dispCommand_0A //[waitForAButtonDownOrMessageTimeOut]
pb_waitConfirmOrTimeout:	;command0A
.messageSpeed = $6010
.timeout = $24
	lda #8
	sec
	sbc .messageSpeed
	asl a
	asl a
	asl a
	sta <.timeout
	beq .finish
.wait_loop:
		jsr presentCharacter
		jsr getPad1Input
		lda <inputBits
		and #1
		bne .finish
		dec <.timeout
		bne .wait_loop
.finish:
	rts
;$9474
pb_free_begin:
pb_free_end = $9474
;------------------------------------------------------------------------------------------------------
	;.org	$94d6
	INIT_PATCH $34,$94d6,$9575
pb_closeWindow:	;command00,01,02,04
.commandId = $4b
.params = $78d6
	ldx <.commandId
	lda .params,x
	jsr pb_checkNoMessage
	txa
	jmp $8e14
;$94e7:
;------------------------------------------------------------------------------------------------------
pb_backCommand:	;command03
.iCommand = $64
	ldx battleMessageCount
	lda battleMessages,x
	cmp #$ff
	beq pb_closeWindow

	ldx #4
	lda battleProcessType
	beq .decrement
		inx
.decrement:
		dec <.iCommand
		dex
		bne .decrement
.finish:
	rts
;$950d:

;======================================================================================================
;	.org	$950d
	;INIT_PATCH $34,$950d,$9575
pb_commandLists:
	.dw	pb_processType_00
	.dw	pb_processType_01
	.dw	pb_processType_02
	.dw	pb_processType_03
	.dw	pb_processType_04
	.dw	pb_processType_05
	.dw pb_processEx_00
;	.org	$9519
pb_processType_00:
	.db $05,$07,$0B,$06,$0C,$08,$0D,$09,$0A,$04,$03,$01,$02,$00,$FF
pb_processType_01:
	.db $05,$06,$07,$0B,$0C,$08,$09,$0D,$0A,$04,$03,$02,$01,$00,$FF
pb_processType_02:
	.db $09,$0A,$04,$FF
pb_processType_03:	;fire cannon
	.db $09,$0B,$0C,$0E,$0A,$04,$FF
pb_processType_04:
	.db $05,$09,$0A,$04,$00,$FF
pb_processType_05:
	.db $09,$0C,$0A,$04,$FF
pb_processEx_00:
	.db $05
	.db $06
	.db $0f	;processDisorderedShot (ex)
	.ifndef SHOW_INFO_ON_DISORDERED_SHOT
		.db $0c	;damage
		.db $0D	;dying
		.db $04
	.endif	;SHOW_INFO_ON_DISORDERED_SHOT
	.db $01
	.db $00
	.db $FF	;end

;	.org	$954d
pb_handlers:
	.dw	pb_closeWindow	;00 $94d6
	.dw	pb_closeWindow	;01 $94d6
	.dw pb_closeWindow	;02 $94d6
	.dw pb_backCommand	;03 $94e7
	.dw pb_closeWindow	;04 $94d6
	.dw pb_showActorName		;05 905b
	.dw	pb_showActionName		;06 90a0
	.dw	pb_showTargetName		;07 9177
	.dw	pb_showEffectMessage	;08 91d4
	.dw pb_showInfoMessage		;09 $91fe
	.dw pb_waitConfirmOrTimeout	;0a $9450
	.dw pb_playEffect			;0b $934e
	.dw pb_showDamage			;0c $9354
	.dw pb_showDyingEffect		;0d $935f
	.dw pb_updateTargetCache	;0e $93c4
pb_handlers_ex:
	.dw 0	;0f extenstion
	.dw 0	;10
;	.org	$956b
pb_showInfoMessage_handlers:
	.dw pb_showInfoMessage_00
	.dw pb_showInfoMessage_01
	.dw pb_showInfoMessage_02
	.dw pb_showInfoMessage_03
	.dw pb_showInfoMessage_04
;$9575:
;======================================================================================================
	RESTORE_PC ff3_present_battle_begin