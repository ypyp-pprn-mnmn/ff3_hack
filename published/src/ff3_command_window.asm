; ff3_command_window.asm
;
;description:
;	command window related codes
;
;version:
;	0.03 (2006-10-12)
;======================================================================================================
ff3_commandWindow_begin:
	INIT_PATCH $34,$986c,$99fd
	
getPlayerCommandInput:
.iPlayer = $52
.cursorId = $55
.pPlayer = $5b
.playerOffset = $5f
.selectedCommands = $78cf	;[4]
.battleMode = $7ed8
;-------------------------------------
	jsr drawEnemyNamesWindow	;9d9e
.input_next:	
	ldx <.iPlayer
	cpx #4
	beq .drawHpWindow
		lda $7be1
		jsr clearTargetBit	;$fd2c
		sta $7be1
		jsr getPlayerOffset
		tay
		iny
		iny
		lda [.pPlayer],y
		lsr a
		bcc .not_jumping
			jsr setYtoOffset2F
			lda [.pPlayer],y
			sta $7e0f,x
			bne .drawHpWindow
	.not_jumping:
		lda #$ff
		sta .selectedCommands,x
		lda #0
		sta $7e0f,x
.drawHpWindow:
	jsr drawSelectedActionNames	;9ba2
	jsr $a433
	jsr getPlayerOffset	;a541
	ldx <.iPlayer
	lda $7ce4,x
	beq .check_status0
		pha
		lda #$23
		jsr setYtoOffsetOf
		pla
		sta [.pPlayer],y
		lda #0
		sta $7ce4,x
.check_status0:	;98bd
	ldy <.playerOffset
	iny
	lda [.pPlayer],y
	and #$c0	;dead|stone
	beq .check_status1
		inc <.iPlayer
		inc $7ceb
		jmp .input_next
.check_status1:	;98ce
	iny
	lda [.pPlayer],y
	lsr a
	and #$70	; (paralyze | sleep | confuse) >> 1
	beq .check_jumping
		jmp $a66c
.check_jumping:	;98d8
	bcc .create_commandWindow
		inc <.iPlayer
		bne .input_next
.create_commandWindow:	;$98e3
	jsr createCommandWindow	; $9a69
	jsr setYtoOffset2E	;$9b9b
	lda #0
	ldx #3
.init_action_params:
	sta [.pPlayer],y
	iny
	dex
	bne .init_action_params
	
	lda #$2c
	jsr setYtoOffsetOf
	lda [.pPlayer],y
	and #$f7
	sta [.pPlayer],y
	tya
	clc
	adc #$13
	tay
	lda [.pPlayer],y	;y:+3f
	bne .check_redraw_enemy_names
		jsr $9ae7
.check_redraw_enemy_names:
	lda $7cf3
	bne .move_character
		;1st phase
		jsr drawEnemyNamesWindow	;9d9e
		lda #0
		jsr call_2e_9d53
		lda .battleMode
		and #$20
		beq .check_surprise_attack
			jsr $a50b
			jmp getPlayerCommandInput
	.check_surprise_attack:
		lda $78ba
		bpl .wait_any_button
			rts
	.wait_any_button:
			jsr getPad1Input
			lda <inputBits
			beq .wait_any_button
		jsr createCommandWindow
.move_character:	;9940
	lda #2
	jsr call_2e_9d53	;fa0e
	lda <.iPlayer
	sta <$53
	lda #0
	sta <.cursorId
	sta <$24
	sta <$25
	sta <$1a
	jsr loadCursor	;8966

.input_wait:;9958
	ldy #3
.wait_loop:	
		jsr waitNmi
		dey
		bne .wait_loop
	lda #0
	sta <$1b
	lda #3
	sta <$46	

	jsr commandWindow_dispatchInput	;899e
.inputCopy = $50
.row = $23

	lda #1
	bit <.inputCopy
	bne .OnA
	lda #2
	bit <.inputCopy
	bne .OnB
	bvs .OnLeft
	bpl .input_wait
.OnRight:
		lda #0
		sta <.row
		ldx <$25
		bne .change_position
			inc <$25
			lda #0
			sta <$24
			beq .input_wait
.OnB:
	lda <.iPlayer
	beq .back_input_char
		jsr $9a42
.back_input_char:
	lda #1
	jmp getCommandInput_next
.OnLeft:
		lda #1
		sta <.row
		ldx <$24
		bne .change_position
			inc <$24
			lda #0
			sta <$25
			beq .input_wait
	.change_position:
		lda #8
		bit $78ba
		beq .back
			lda #4
			bne .store_command
	.back:
			lda #5
	.store_command:
		eor <.row
		sta <.row
.OnA:	;99c6
	jsr playSoundEffect05	;9b7d
	jsr clearSprites2x2		;8adf
	
	ldx <.row
	lda $7400,x
	pha
	ldx <.iPlayer
	sta .selectedCommands,x
	lda <.row
	sta $7ac3,x
	pla		;commandId
	asl a	
	clc
	adc #$16
	sta <$19
	lda #0
	adc #$9a
	sta <$1a
	lda #$6c	;jmp (addr)
	sta <$18
	jmp $0018
;------------------------------------------------------------------------------------------------------
	.org $99fd
getCommandInput_next:
;$99fd:
;	push a;
;	push (a = $52);
;	$52 = $53;
;	call_2d9e53(a = #1);//$3f:fa0e(); “ü—ÍŠ®—¹‚µ‚½ƒLƒƒƒ‰‚ª‰º‚ª‚é
;	$52 = pop a;
;	pop a;	//a: draw enemy window ?
;	if (a != 0) goto $986f;
;	else goto $986c;
;$9a16:	//jump table (for command)
;}
;------------------------------------------------------------------------------------------------------
	INIT_PATCH $34,$9a69,$9ae7
createCommandWindow:
;[in]
.width = COMMAND_WINDOW_WIDTH	;original:5
.pPlayerBaseParam = $57
.playerOffset = $5f
.beginningMode = $78ba
.jobCommandList = $9b21
;[out]
.emptyCount = $38
.commandIdList = $7400
;---------------------------------------------------
	ldx #2
	stx .commandIdList+4
	inx
	stx .commandIdList+5
	ldy <.playerOffset
	lda [.pPlayerBaseParam],y
	asl a
	asl a
	tay
	ldx #$fc
.load_loop:
		lda .jobCommandList,y
		sta .commandIdList - $fc,x
		iny
		inx
		bne .load_loop
	jsr initTileArrayStorage
;.counter = $2d
	stx <.emptyCount
	;stx <.counter
	lda #$fc
.create_tiles:
		pha
		ldx #.width
		jsr initString
		pla
		tax
		lda .commandIdList - $fc,x
		inx
		;cmp #$ff
		;bne .load_command_name
		;	inc <.emptyCount
		;	lda #0
	.load_command_name:
		tay
		txa
		pha
		ldx #1
		INIT16 <$18,$8c40
		tya
		jsr loadString
		ldx #.width
		stx <$18
		jsr strToTileArray
		lda #.width
		jsr offsetTilePtr

		pla	;counter
		bne .create_tiles
	lda #($0a - (.width + 1))
	sta <$18
	lda #$0a
	sta <$19
	lda #3
	sta <$1a
	jmp draw8LineWindow
;$9ae7:
;------------------------------------------------------------------------------------------------------
	;FILEORG	$68b00
	.org	$8b00
commandWindow_cursorPos:
.cursorX = ($50 - ($08 * COMMAND_WINDOW_WIDTH))
		.db	$a8, .cursorX
		.db	$b8, .cursorX
		.db	$c8, .cursorX
		.db	$d8, .cursorX
	RESTORE_PC ff3_commandWindow_begin