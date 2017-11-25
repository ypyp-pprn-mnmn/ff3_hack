;; encoding: utf-8
; ff3_command_window.asm
;
;description:
;	command window related codes
;	implements 'extra ability' feature ready mechanism
;
;version:
;	0.15 (2017-11-25)
;======================================================================================================
ff3_commandWindow_begin:
	INIT_PATCH $34,$986c,$99fd

	.ifdef BETA
RET_TO_GET_COMMAND_INPUT	.macro
	rts
	.endm
	
	.else
RET_TO_GET_COMMAND_INPUT	.macro
	jmp $99fd	;getCommandInput_next
	.endm
	
	.endif	;beta

	.ifdef BETA
getPlayerCommandInput:
.iPlayer = $52
.cursorId = $55
.pPlayer = $5b
.playerOffset = $5f
.beginningMode = $78ba	;08:backattack 01:escapable? 80:enemy surprise attack
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
	jsr drawInfoWindow	;9ba2
	jsr $a433	;endCommandInputIfDone
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
	beq .check_redraw_enemy_names
		jsr putCanceledItem	;$9ae7
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
		lda .beginningMode ;$78ba
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
	ldy #3	;to keep input accepted in 3 frames interval 
.wait_loop:	
		jsr ppud.await_nmi_completion
		dey
		bne .wait_loop
	lda #0
	sta <$1b
	lda #3
	sta <$46	

	jsr getInputAndUpdateCursorWithSound	;899e
.inputCopy = $50
;.invert = $18
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
		ldy #0
		ldx <$25
		bne .change_position
			sty <$24
			inc <$25
			bpl .input_wait
.OnB:
	lda <.iPlayer
	beq .back_input_char
		jsr $9a42
.back_input_char:
	lda #1
	bne .go_next_char
	;jmp getCommandInput_next
.OnLeft:
		ldy #1
		ldx <$24
		bne .change_position
			sty <$24
			dey
			sty <$25
			beq .input_wait
	.change_position:
		lda #8
		bit $78ba	;backattack flag
		beq .back
			lda #4
			bne .store_command
	.back:
			lda #5
	.store_command:
		sta <.row
		tya
		eor <.row
		sta <.row
.OnA:	;99c6
	jsr requestSoundEffect05	;9b7d
	;v0.6.2 fix
	;lda #0
	;sta <$18
	;<--
	;jsr clearSprites2x2		;8adf
	jsr clearCursor0
	
	ldx <.row
	lda $7400,x
	pha
	ldx <.iPlayer
	sta .selectedCommands,x
	lda <.row
	sta $7ac3,x
	pla		;commandId
	;v0.6.3 --->
	tax
	;<---
	asl a
	clc
	adc #LOW(commandWindow_handlers)
	sta <$19
	lda #0
	adc #HIGH(commandWindow_handlers)
	sta <$1a
	lda #$6c	;jmp (addr)
	sta <$18
;99c7:
	jsr $0018	;invoke commandWindowHandler (x = handlerIndex = commandId)
;$99fd
;getCommandInput_next:
.go_next_char:
	pha
	lda <.iPlayer
	pha
	lda <$53
	sta <.iPlayer
	lda #1
	jsr call_2e_9d53
	pla
	sta <.iPlayer
	pla
	beq .redraw
		jmp getPlayerCommandInput+3	;986f
.redraw:
	jmp getPlayerCommandInput	;986c
clearCursor0:
	;v0.6.2 fix
	lda #0
	sta <$18
	;<--
	jmp clearSprites2x2		;8adf
;$9a16
;=======================================================================================================
;original addresses
;commandWindow_nop	= $9a68
;01
;commandWindow_OnForward	= $a71c
;commandWindow_OnBack	= $a750
;commandWindow_OnFight	= $a843
;commandWindow_OnGuard	= $a877
;commandWindow_OnEscape	= $a8ab
;commandWindow_OnSneakAway	= $a8b5
;commandWindow_OnJump	= $a9ab
;09
;commandWindow_OnA	;hacked
;commandWindow_OnGeomance	= $aa22
;commandWindow_OnInspect		= $ab6e
;commandWindow_OnDetect		= $ab07
;commandWindow_OnSteal		= $ab9f
;commandWindow_OnCharge		= $ac65
;commandWindow_OnSing		= $acd0
;commandWindow_OnIntimidate	= $ad0c
;commandWindow_OnCheer		= $ad6b
;13
;commandWindow_OnItem	= $adaf	;14
;commandWindow_OnMagic	= $b646	;15
;------------------------------------------------------------------------------------------------------
;	.org $9a16
	ALIGN_EVEN

commandWindow_handlers:
	.dw	commandWindow_nop	;$9a68
	.dw	commandWindow_nop	;$9a68
	.dw commandWindow_OnForward	;$a71c
	.dw commandWindow_OnBack	;$a750
	.dw commandWindow_OnFight	;$a843
	.dw commandWindow_OnGuard	;$a877
	.dw commandWindow_OnEscape	;$a8ab
	.dw commandWindow_OnSneakAway	;$a8b5
	.dw commandWindow_OnJump	;$a9ab
	.dw commandWindow_nop	;$9a68
	.dw commandWindow_nop	;$9a68
	.dw commandWindow_OnGeomance	;$aa22
	.dw commandWindow_OnInspect		;$ab6e
	.dw commandWindow_OnDetect		;$ab07
	.dw commandWindow_OnSteal		;$ab9f
	.dw commandWindow_OnCharge		;$ac65
	.dw commandWindow_OnSing		;$acd0
	.dw commandWindow_OnIntimidate	;$ad0c
	.dw commandWindow_OnCheer		;$ad6b
	.dw commandWindow_nop		;$9a68
	.dw commandWindow_OnItem	;$adaf
	.dw commandWindow_OnMagic	;$b646
	;extra
	;	more commands can be added, as long as capacity here remains.
	.dw commandWindow_OnProvoke	;extra
	.dw commandWindow_OnDisorderedShot	;extra
	.dw commandWindow_OnAbyss	;abyss
	.dw commandWindow_OnRaid
;$9a40
;=======================================================================================================
getCommandInput_end:
getCommandInput_free_end = $9a40
;=======================================================================================================
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
		INIT16 <$18,$8c40
		tya
	.ifdef ENABLE_EXTRA_ABILITY
		jsr getExtraAbilityNameId
	.endif
		ldx #1
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
	.endif ;beta
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