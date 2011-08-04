; ff3_magic_window.asm
;
;description:
;	replaces magic-selection-window 
;
;version:
;	0.06 (2006-10-29)
;
;======================================================================================================
ff3_magic_window_begin:
;------------------------------------------------------------------------------------------------------
	INIT_PATCH $35,$b646,$b979
	.org ff3_magic_window_begin
;------------------------------------------------------------------------------------------------------
;commandWindow_OnMagicSelected:
commandWindow_OnMagic:
.pPlayerBaseParam = $57	;[in]
.pPlayerEquips = $59	;[in]
.pPlayer = $5b			;[in]
.magicIdOffset = $18
.magicSlot = $24
.magicIndex = $26
.currentMagicLv = $27
.maxMagicLv = $46
;---------------------------------------
	bit $7ed8	;status_2?
	bvc	.castable	;bit6 is clear
		jsr requestSoundEffect06
		lda #1
		RET_TO_GET_COMMAND_INPUT
		;jmp getCommandInput_next
.castable:		
	ldx #$17
	lda #$ff
.init_7400:
		sta $7400,x
		dex
		bpl .init_7400
	lda #$3f
	jsr setYtoOffsetOf
	ldx #7
.find_max_lv:	
		lda [.pPlayerBaseParam],y
		bne .found_lv
		dex
		dey
		dey
		bne .find_max_lv	;y shouldn't be 0
.found_lv:		
	stx <.currentMagicLv
	stx <.maxMagicLv
	;txa
	;pha
	lda #7
	sec
	sbc <.currentMagicLv
	;$18 = (7- currentMagicLv)*7
	sta <.magicIdOffset
	asl a
	asl a
	asl a
	sec
	sbc <.magicIdOffset
	sta <.magicIdOffset
	lda #0
	sta <.magicIndex
.getMagicIds:
		sta <.magicSlot
		pha	;magicslot
		lda #7
		tax	;x:index
		clc
		adc <.currentMagicLv
		jsr setYtoOffsetOf
		lda [.pPlayerEquips],y
	.find_equipped_magic:	;$b69e
			lsr a
			bcc .find_equipped_next
				pha
				ldy <.magicSlot
				lda <.magicIdOffset
				sta $7400,y
				inc <.magicSlot
				pla
		.find_equipped_next:
			inc <.magicIdOffset
			dex
			bne .find_equipped_magic
		pla	;magicslot
		clc
		adc #3
		dec <.currentMagicLv
		ldx <.currentMagicLv
		bpl .getMagicIds
;$b6cc:
.magicLv = $24
	jsr initTileArrayStorage	;$9754
	ldx <.maxMagicLv
	stx <.magicLv
;$b6dc:
.loadMagicNames:
.dest = $27
		ldx #$1c
		jsr initString	;a549
		lda #8
		sta <.dest
		lda #$81	;'1'
		clc
		adc <.magicLv
		sta stringCache+0
		lda #$c7
		sta stringCache+4
		lda #7
		;clc always clear
		adc <.magicLv
		jsr setYtoOffsetOf	;9b88
		lda [pPlayer],y	;currentMp
		jsr itoa_8
		lda <$1b
		sta stringCache+2
		lda <$1c
		sta stringCache+3
		;
		lda <.magicLv
		asl a
		;clc always cleared (0 <= magicLv < 8)
		adc #$31
		jsr setYtoOffsetOf	;9b88
		lda [.pPlayerBaseParam],y	;maxMp
		jsr itoa_8
		lda <$1b
		sta stringCache+5
		lda <$1c
		sta stringCache+6
;$b734
		lda #3
	.loadMagicNamesOfCurrentLv:
			pha	;index (means slot)
			ldx <.magicIndex
			lda $7400,x
			cmp #$ff	;empty
			beq .load_next
;$b73f:
				sta <$18
				pha	;magic id
				INIT16 <$20,$98c0
				jsr isPlayerAllowedToUseItem	;$b8fd
				lda <$1c
				bne .load_name
					ldx <.dest
					lda #$73	;'x'
					sta stringCache,x
					ldx <.magicIndex
					lda #$ff
					sta $7400,x
			.load_name:
				ldx <.dest
				inx
				INIT16 <$18,$8990
				pla	;magic id
				jsr loadString	;a609 loadString(index:a, dest:x, src:$18 )
		.load_next:
			lda <.dest
			clc
			adc #7
			sta <.dest
			inc <.magicIndex
			pla	;index (means slot)
			;sec	always clear (dest < 6 * 3)
			sbc #0
			bne .loadMagicNamesOfCurrentLv
;$b77e:
		lda #$1c
		sta <$18
		jsr strToTileArray	;966a
		lda #$1c
		jsr offsetTilePtr
		dec <.magicLv
		lda <.magicLv
		bmi .create_window
			jmp .loadMagicNames
;$b793:
.create_window:
	jsr eraseWindow
	lda #1
	sta <$18
	sta <$55	;cursor id
	lda #$1e
	sta <$19
	lda #$3	;left|right
	sta <$1a
	jsr draw8LineWindow	;draw8LineWindow(left = 1, right = #$1e, border = #3); //$34:8b38
	lda #0
	sta <$1a
	jsr loadCursor	;8966
;---------------------------
magicWindow_getInput:
.cursorId = $1a
.row = $24
.cursorRow = $25
.col = $26
.rowMax = $46
	ldx #0
	stx <.row
	stx <.cursorRow
	stx <.col
;$b7b8
.magicWindow_inputLoop:
.magicWindow_inputHandlerTable = $ba2a
	ldx #0
	stx <$38
	stx <.cursorId
	lda #2
	sta <$1b
	jsr getInputAndUpdateCursorWithSound	;commandWindow_dispatchInput	;899e
	INIT16 <$1e, .magicWindow_inputHandlerTable
	lda <inputBits
;getInputAndUpdateCursorWithSound processes input bit from lsb
	ldx <.col
	ldy <.row

	lsr a
	bcc .not_a
		jmp .magicWindow_OnA
.not_a:
	lsr a
	bcs .magicWindow_OnB
	lsr a	;sel
	lsr a	;start
	lsr a
	bcs .magicWindow_OnUp
	lsr a
	bcs .magicWindow_OnDown
	lsr a
	bcs .magicWindow_OnLeft
	lsr a
	;bcs .magicWindow_OnRight
	bcc .magicWindow_inputLoop
;------------------------------------------------------------------------------------------------------
.magicWindow_OnRight:
	cpx #2
	beq .magicWindow_inputLoop
	inc <.col
	bpl .magicWindow_inputLoop
;------------------------------------------------------------------------------------------------------	
.magicWindow_OnLeft:
	txa
	beq .magicWindow_inputLoop
	dec <.col
	bpl .magicWindow_inputLoop
;------------------------------------------------------------------------------------------------------	
.magicWindow_OnUp:
	tya
	beq .magicWindow_inputLoop
	dec <.row
	dec <.cursorRow
	bpl .magicWindow_inputLoop
	inc <.cursorRow	;keep 0
	SUB16by8 $7ac0,#$38
	jmp .magicWindow_redraw
;------------------------------------------------------------------------------------------------------	
.magicWindow_OnDown:	
	cpy #7
	beq .magicWindow_inputLoop
	cpy <.rowMax
	beq .magicWindow_inputLoop
	inc <.row
	inc <.cursorRow
	lda <.cursorRow
	cmp #4
	bcc .magicWindow_inputLoop
	dec <.cursorRow	;keep 3
	ADD16by8 $7ac0,#$38
.magicWindow_redraw:	
	lda #1
	sta <$18
	lda #$1e
	sta <$19
	lda #3
	sta <$1a
	jsr draw8LineWindow
	jmp .magicWindow_inputLoop
;------------------------------------------------------------------------------------------------------
.magicWindow_OnB:
.magicWindow_close:
	jsr clearCursor0
	jsr eraseWindow
	lda #0	;redraw
	RET_TO_GET_COMMAND_INPUT
	;jmp getCommandInput_next
;------------------------------------------------------------------------------------------------------	
.magicWindow_OnA:
.magicIdList = $7400
;.col = $26	;x
;.row = $24	;y
.maxLv = $46
.lv = $47
.iPlayer = $52
.pPlayer = $5b
.playerOffset = $5f
	tya
	asl a
	adc <.row
	adc <.col
	tax
	lda .magicIdList,x
	cmp #$ff
	beq .bad_selection
	
	pha
	lda $7ed8
	and #$10
	beq .check_mp
	
	pla
	cmp #$2f
	beq .bad_selection	
	pha
	
.check_mp:
	lda <.maxLv
	sec
	sbc <.row
	sta <.lv
	;pha
	ldx <.iPlayer
	sta $7ac7,x
	;pla
	clc
	adc #7
	adc <.playerOffset	;offset
	tay
	lda [.pPlayer],y	;mp
	bne .cast_allowed
.bad_selection_pop:	
		pla	;magic id
.bad_selection:
		jsr requestSoundEffect06	;9b81
		jmp .magicWindow_inputLoop
;$b8bb
.cast_allowed:
	jsr requestSoundEffect05	;9b7d
	pla
	pha
	jsr getMagicTarget	;$b953	;get target?
	tax
	beq .store_command
		pla
		cpx #1
		beq .bad_selection
		bne .magicWindow_close
.store_command:
	jsr setYtoOffset2E	;9b9b
	ldx <.iPlayer
	pla
	clc
	adc #$c8
	sta $78cf,x
	sta [pPlayer],y
	cmp #$ff
	bne .finish
		lda $7be1
		jsr flagTargetBit	;$fd20
		sta $7be1
.finish:
	inc <.iPlayer
	bne .magicWindow_close
;======================================================================================================
ff3_misc_begin:
	.bank	$35
	.org	$b8fd
	.ds		$b953 - $b8fd
	;.org	$b8fd
	.org	ff3_misc_begin
isPlayerAllowedToUseItem:
;	[in] u8 $18 : itemid
;	[in] u16 $20 : ? itemDataBase = #$9400
;	[out] u8 $1c : allowed (1:ok 0:not)
;uses:
;	u8 $7478[8] : itemParams
.itemId = $18
.baseAddress = $20
.allowed = $1c
.itemParam = $7478
.userType = $38
.userFlags = $3b
.pPlayerBaseParam = $57
	lda #8
	sta <$1a
	ldx #$78
	jsr loadTo7400FromBank30	;$ba3a
	lda .itemParam+7
	and #$7f
	sta <.userType
	asl a
	;clc always clearted (&7f ed)
	adc <.userType
	tax
	jsr $fd8b	;loadUserFlags
	jsr getPlayerOffset	;$a541
	tay
	lda [.pPlayerBaseParam],y	;job
	;$b93e();
	pha
	lsr a
	lsr a
	lsr a
	sta <$38
	lda #2
	sec
	sbc <$38
	tax
	pla
	and #7
	tay
	lda <.userFlags,x
.move_flag:	
		lsr a
		dey
		bpl .move_flag
	rol a
	and #1
	sta <.allowed
	rts
;$b93e:
;$b953
;======================================================================================================
;$35:b953 setMagicTarget
getMagicTarget:
;[in] a
.magicParams = $7478
	sec	;??
	sta <$18
	sta $7ce8
	INIT16 <$20,$98c0
	jsr isPlayerAllowedToUseItem	;b8fd
	ldx .magicParams+4
	dex
	bne .ok
		dex	
		stx $7ce8 ;x = $ff
.ok:
	lda <$1c
	beq .finish
		jmp setActionTargetByParam	;b979
.finish	
	lda #1
	rts
	;bne $ba29	;do return
;$b979
;======================================================================================================
ff3_magic_window_free_begin:
ff3_magic_window_free_end = $b979
;------------------------------------------------------------------------------------------------------
;quickfix
	.bank	$34
	.org	$8064
	jsr isPlayerAllowedToUseItem
;======================================================================================================
	RESTORE_PC ff3_magic_window_free_begin
ff3_magic_window_size = ff3_magic_window_free_begin - ff3_magic_window_begin