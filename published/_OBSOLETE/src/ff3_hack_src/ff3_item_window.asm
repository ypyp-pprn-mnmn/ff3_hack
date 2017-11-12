; ff3_item_window.asm
;
; description:
;	replaces entire item-window related codes
;
; version:
;	0.12 (2006-11-12)
;
;======================================================================================================
ff3_itemWindow_begin:

item_window_patch_begin	= $adaf	;commandWindow_OnItemSelected
item_window_patch_end	= $b646	;commandWindow_OnMagicSelected

	INIT_PATCH $35,item_window_patch_begin,item_window_patch_end
	.org ff3_itemWindow_begin
	ORIGINAL_ADDR item_window_patch_begin
;----------------------------------------------------------------------------------------------------------	
;global vars
;shared with command window
iPlayer			= $52	;
pEquips			= $59	;
pPlayer			= $5b	;
selectedAction	= $78cf	;
doesDrawActionName = $7ce8
;------------------------------------------------------------------------------
row				= $62
col				= $63
windowLeft		= $66
mode			= $67
lastRow			= $68
lastCol			= $69
backpackItems	= $60c0
cachedItems		= $7af5
equipFlags		= $7b3d	
;------------------------------------------------------------------------------
;
removeId		= $3e		;address must be $3e
removeCount		= $3f
equipId			= $40		;address must be $40
equipCount		= $41
removeIndex		= $42
equipIndex		= $43
removeFlag		= $44
equipFlag		= $45
;==========================================================================================================
;$35:adaf commandWindow_OnItemSelected()
;	[in,out] u8 $52 : playerIndex
;uses:
;	u8 $62 : cursor row index (0-3), init : 0
;	u8 $63 : cursor col index (0-7), init : 1
;	u8 $65 : background no (used in scrolling function), init : 0
;	u8 $66 : current window left (col index,equipWindow = 0), init : 1
;	u8 $67 : indicates Nth selection  (0-1)
;	u8 $68 : row index of 1st selection 
;	u8 $69 : col index of 1st selection
;	u8 $7afd[0x40] : items {id,count}
;	u8 $7b3d[0x40] : equipflags (0 = cannot use/equip,mark 'x' next to name)
;commandWindow_OnItemSelected:
commandWindow_OnItem:
.scrollX = $10
.counter = $43
	jsr updateDmaPpuScrollSyncNmi
	lda #0
	sta <$3d	;erase flag
	jsr eraseWindow

	lda #$78
	sta <.scrollX
	jsr updateDmaPpuScrollSyncNmi
	
	lda #0
	sta $7573	;erase flag
	jsr drawEquipWindow

	jsr setYtoOffset03
	ldx #0
.init_hands:
	lda [pEquips],y
	sta $7af5,x
	sta $7af7,x
	iny
	lda [pEquips],y
	sta $7af6,x
	sta $7af8,x
	iny
	inx
	inx
	inx
	inx
	cpx #8
	bne .init_hands
	
	ldx #$23
	lda #1
.init_flags:
	sta equipFlags,x
	dex
	bpl .init_flags	
	
	inx	;0
.init_items:
		lda #0
		sta <$20
		lda #$94
		sta <$21
		stx <.counter
		lda backpackItems+1,x	;count
		sta cachedItems+9,x
		lda backpackItems,x		;id
		sta cachedItems+8,x
		
		cmp #$62	;leather cap
		bcc .check_equip_valid_for_job
		cmp #$98	;magical key
		bcc .cannot_use
		cmp #$c8	;magic 'flare'
		bcs .cannot_use
		bcc .next
	.check_equip_valid_for_job:
			;weapon or shield
			sta <$18
			jsr isPlayerAllowedToUseItem	;$b8fd
			lda <$1c
			bne .next
	.cannot_use:	
		lda <.counter
		lsr a
		tax
		dec equipFlags+4,x
	.next:
		ldx <.counter
		inx
		inx
		cpx #$40
		bne .init_items
	
	ldx #0
	stx <$3d
.init_window:
	stx <.counter
	jsr loadTileArrayForItemWindowColumn
	ldx <.counter
	lda initWindowParams,x
	sta <$18
	inx
	lda initWindowParams,x
	sta <$19
	inx
	lda initWindowParams,x
	sta <$1a
	inx
	stx <.counter
	jsr draw8LineWindow
	ldx <.counter
	cpx #$9
	bne .init_window
	
	lda #2
	sta <$55
	lda #1
	sta <$1a
	jsr loadCursor
	
	lda #1
	sta <$1a
	lda #$f0
	sta <$1c
	sta <$1d
	jsr tileSprites2x2
	
	lda #2
	sta <$55
	lda #0
	sta <$1a
	jsr loadCursor

	ldx #0
	stx <$62	;row
	;stx <$65	;scroll toggle
	stx <$67	;mode
	inx
	stx <$63	;col
	stx <$66	;left

itemWindowInputLoop:
	jsr presentCharacter
	jsr getPad1Input
	lda <inputBits
	beq itemWindowInputLoop
	pha
	jsr requestSoundEffect18	;9b79
	pla
;itemWindow_dispatchInput:
		ldx <col
		ldy <row
		asl a
		bcs .OnRight
		asl a
		bcs .OnLeft
		asl a
		bcs .OnDown
		asl a
		bcs .OnUp
		asl a
		;bcs start
		asl a
		;bcs select
		asl a
		bcs .OnB
		asl a
		bcc itemWindowInputLoop ;($aeaa)
.OnA:
		;jmp itemWindow_OnA
		bcs itemWindow_OnA
.OnB:
		jmp itemWindow_OnB
.OnUp:	
		tya
		beq itemWindowInputLoop ;($aeaa)
		cpx #$00
		bne .nocheck_up
		dey
		beq itemWindowInputLoop
	.nocheck_up:
		dey
		bpl .update		
.OnDown:
		cpy #$03
		beq itemWindowInputLoop ;($aeaa)
		cpx #$00
		bne .nocheck_down
		iny
		cpy #$04
		beq itemWindowInputLoop ;($aeaa)
	.nocheck_down:
		iny
		bpl .update
.OnLeft:
		txa
		beq itemWindowInputLoop
		cmp <$66
		bne .noscroll_left
		jsr itemWindow_scrollLeft	;$b362
		ldx <col
		ldy <row
	.noscroll_left:
		dex
		bne .nocheck_left
		tya
		ora #1
		tay
	.nocheck_left:
		bne .update	
.OnRight:
		cpx #$08
		beq itemWindowInputLoop
		lda <$66
		cmp #$07
		beq .noscroll_right
		cmp <col
		beq .noscroll_right
		jsr itemWindow_scrollRight	;$b2a7
		inc <col
		bne .moveOnly
	.noscroll_right:
		inx
.update:
		txa
		sta <col
		tya
		sta <row
.moveOnly:
		jsr itemWindow_moveCursor
		jmp itemWindowInputLoop
;----------------------------------------------------------------------------------------------------------
initWindowParams:	DB	$10,$1e,1,	$1f,$8d,0,	$8e,$9c,0
;==========================================================================================================
;itemWindow_OnA
;------------------------------------------------------------------------------
;	.org	$af4c
itemWindow_OnA:
	lda <mode
	bne .second_item
		inc <mode
		lda <row
		sta <lastRow
		lda <col
		sta <lastCol
		jsr itemWindow_moveCursor
		lda <$1d
		clc
		adc #4
		sta <$1d
		lda #1
		sta <$1a
		jsr tileSprites2x2
		jsr requestSoundEffect05	;9b7d
		ldx #$10
.present_loop:
			jsr presentCharacter
			dex
			bne .present_loop
		jmp itemWindowInputLoop
.second_item:
	ldx <col
	ldy <row
	cpx <lastCol
	bne .exchange_item
	cpy <lastRow
	bne .exchange_item
		jmp itemWindow_OnUse
.exchange_item:
	txa
	bne .check_lastcol
	lda <lastCol
	bne .exchange_ok
	beq .cannot_exchange
.check_lastcol:
	lda <lastCol
	beq .exchange_ok
.cannot_exchange:
	jsr $9b81
	jmp itemWindowInputLoop
.exchange_ok:
	lda #0
	sta $7408
	lda #1
	sta $7409
	cpx <lastCol
	bcc .no_swap
		jsr swap_current_and_last
		inc $7408
		dec $7409
.no_swap:
	lda <lastCol
	asl a
	asl a
	clc		;not neccesary
	adc <lastRow
	sta <equipFlag
	asl a
	sta <equipIndex
	ldx <equipFlag
	lda equipFlags,x
	bne .exchangeable
.fail:
		jsr $9b81
		lda $7408
		beq .no_swap_restore
			jsr swap_current_and_last
.no_swap_restore:
		jmp itemWindowInputLoop
.exchangeable:
	ldx <equipIndex
	lda cachedItems,x
	bcs .fail
	sta <equipId
	inx
	lda cachedItems,x
	sta <equipCount
	
	lda <col
	asl a
	asl a
	clc
	adc <row
	sta <removeFlag
	asl a
	sta <removeIndex
	
	tax
	lda cachedItems,x
	sta <removeId
	inx
	lda cachedItems,x
	sta <removeCount

	;jsr $b242	;checks 2-handed weapon?
	jsr isHandFreeForItem
	bcs .fail
	lda <equipId
	cmp <removeId
	bne .different_item
		cmp #0
		beq .fail
		lda #0
		ldx <removeIndex
		sta cachedItems,x
		inx
		sta cachedItems,x
		ldx <removeFlag
		lda #1
		sta equipFlags,x
		ldx <equipIndex
		inx
		clc
		lda <removeCount
		adc <equipCount
		cmp #100
		bcc .under_100
			lda #99
.under_100:
		sta cachedItems,x
		txa
		pha
		jmp .copyback	 
.different_item:
	ldy <equipCount
	cmp #0
	beq .pick_result_empty
	cmp #$4f	;wooden arrow
	bcc .not_arrow
	cmp #$57	;medusa arrow
	bcs .not_arrow
.arrow:
	;min(equipcount,20)
	cpy #21
	bcc .pick_result_empty
	ldy #20
	bne .exchange
.not_arrow:
	cpy #1
	beq .pick_result_empty
	ldy #1
.exchange:
	ldx <removeId
	beq .pick_result_empty
.count = $25
	sty <.count
	jsr getIndexToPutRemovedItem
	bcc .can_put
	jmp .fail
.can_put:	
	lda <equipId
	ldy <.count
	jsr doExchange
	pha	;col index
	jmp .copyback
.pick_result_empty:
	;here already a = equipid,y = count
	jsr doExchange
	pha	;col index
.swap_flag:
	.IFNDEF CONTINUE_ON_EQUIP_CHANGE
		ldx <removeFlag
		lda equipFlags,x
		tay
		ldx <equipFlag
		lda equipFlags,x
		ldx <removeFlag
		sta equipFlags,x
		ldx <equipFlag
		tya
		sta equipFlags,x
	.ENDIF
;here originally $b131		
;	.org $b131
.copyback:	
	ldx #$3f
	.copyloop:
		lda cachedItems+8,x
		sta backpackItems,x
		dex
		bpl .copyloop

;$b13e:		
	jsr $9b8d	;set y to offset 3
	lda $7af7
	sta [pEquips],y
	iny
	lda $7af8
	sta [pEquips],y
	iny
	
	lda $7afb
	sta [pEquips],y
	iny
	lda $7afc
	sta [pEquips],y
	iny
	jsr requestSoundEffect05
	lda $7408
	beq .no_swap_restore_req
		jsr swap_current_and_last
.no_swap_restore_req:
	pla	;updated col index
	lsr a
	lsr a
	lsr a
	pha
	
	ldx <col
	bne .not_in_equipWindow
		jsr drawEquipWindowNoErase	;$35:b5f9
		pla
		cmp #3
		bcs .finish
			tax
			dex
			jsr drawItemWindowColumn	;subsituate jsr $b601
			jmp .finish	
.not_in_equipWindow:
		dex	;based equip-window => based item0
		jsr drawItemWindowColumn
		pla
		tax	;updated col
		clc
		adc #2
		sec
		sbc <windowLeft	;a = (col - 1) - left + 3
		bmi .check_equip_redraw	; (col + 2) - left < 0 : col < left - 2
		cmp #5
		bcs .check_equip_redraw	; col + 2 - left - 5 >= 0  col >= left + 3
			dex	
			jsr drawItemWindowColumn	;subsituate jsr $b601
	.check_equip_redraw:
		lda <col
		cmp #3
		bcs .finish
			jsr drawEquipWindowNoErase

.finish:
	jsr dispatchBattleFunction_05	;$8026 => recalcParams
	.IF CONTINUE_ON_EQUIP_CHANGE
		jmp itemWindow_cancel2nd			
	.ENDIF	

; itemWindow_OnB will jump to here
itemWindow_closeAndKeepCurrentPlayer:	
	dec <iPlayer
; useItem will jump to here
;$b198
closeItemWindow:
	jsr eraseWindow	;$34:8eb0();
	lda #0
	sta <$10
	lda <$08
	and #$fe
	sta <$08
	jsr updateDmaPpuScrollSyncNmi ;$3f:f8c5();
	lda #0
	sta <$18
	jsr clearSprites2x2	 ;
	lda #1
	sta <$18
	jsr clearSprites2x2
	inc <iPlayer
	;causes window-erase bug
	;$b1d0:	dispatchBattleCommand(5); ;$34:8026();	
	lda #0
	RET_TO_GET_COMMAND_INPUT
	;jmp getCommandInput_next	;$99fd

;$b198:
;[in,out] u8 $67 : mode (0 = 1st,1=2nd selection)
itemWindow_OnB:
	lda <mode
	beq itemWindow_closeAndKeepCurrentPlayer
itemWindow_cancel2nd:	
		dec <mode
		lda #1
		sta <$1a
		lda #$f0
		sta <$1c
		sta <$1d
		jsr tileSprites2x2
		jmp itemWindowInputLoop	;$aeaa
;----------------------------------------------------------------------------------------------------------
;utilities
doExchange:
;[in] y = counttopick, a = id
;[out] a = offset to removed item's count
	jsr pickAndEquipItem
	jsr getIndexToPutRemovedItem
	bcs .itemfull
	lda <removeId
	ldy <removeCount
	jsr putItem
	txa
.itemfull:	
	rts
swap_current_and_last:
	lda <row
	pha
	lda <lastRow
	sta <row
	pla
	sta <lastRow
swap_col:
	lda <col
	pha
	lda <lastCol
	sta <col
	pla
	sta <lastCol
	rts
;----------------------------------------------------------------------------------------------------------	
pickAndEquipItem:	;y : countToPick
	ldx <equipIndex
	;dey
	tya
	eor #$ff	;NOT
	clc
	adc <equipCount
	;here A = equipCount - pickCount - 1
	bcc .pickAll	
	inx
	adc #0	;add carry (here always 1)
	;iny
	sta cachedItems,x	;update count
	bpl .putEquip
.pickAll:
	lda #0
	sta cachedItems,x
	inx
	sta cachedItems,x
	.IF UPDATE_FLAGS
		;to continue window, we must update flags properly
		ldx <equipFlag
		sta equipFlags,x
	.ENDIF
	ldy <equipCount
.putEquip:
	ldx <removeIndex
	lda <equipId	
	sta cachedItems,x
	inx
	tya	;count
	sta cachedItems,x
	rts
;----------------------------------------------------------------------------------------------------------	
putItem:
;[in] a:itemid, x:index, y:count
;[out] x : offset to put item's count
	cmp cachedItems,x
	bne .putToFree
	;there is same item,stack it
	inx
	tya
	clc
	adc cachedItems,x
	bpl .storeCount
.putToFree
	sta cachedItems,x	;id
	.IF UPDATE_FLAGS
		;to continue window, we must update flags properly
		txa	;index to count
		pha
		lsr a
		tax
		inc equipFlags,x
		pla
		tax
	.ENDIF
	inx
	tya
.storeCount:
	sta cachedItems,x	;count
	rts
;----------------------------------------------------------------------------------------------------------
findItem_notFound = $48	
findItem:	;a : findId	
.idToFind = $24
	ldx #8
	sta <.idToFind
.find_loop:
		lda cachedItems,x
		cmp <.idToFind
		beq .found
		inx
		inx
		cpx #findItem_notFound 
		bne .find_loop
.found:		
	rts
;----------------------------------------------------------------------------------------------------------
getIndexToPutRemovedItem:
;[out] bool carry : 0=putable ,x = index
	lda <removeId
	jsr findItem
	cpx #findItem_notFound
	bne .checkCount
.tryFreeSpace:	
	lda #0
	jsr findItem
	cpx #findItem_notFound
	rts
.checkCount:
	inx
	lda <removeCount
	clc
	adc cachedItems,x
	dex
	cmp #100
	rts
;==========================================================================================================
;	.org $b1d8
;	.incbin "ff3_$35_b1d8-b4f6.bin"
;	.org $b1d8

loadTileArrayOfItemProps:	
;	[in] u8 $34[2][4] : items
;	[in] u16 $43 : ptrToDestTileArray
.items = $34
.counter = $3c
	jsr initTileArrayStorage	;$9754	;fill_7200to73ff_ff();
	lda #0
	sta <.counter
.loop:
		ldx #$0d
		jsr initString	;$35:a549
		ldx <.counter
		lda <.items,x
		cmp #$ff
		bne .check_string
			lda #$0d * 2
			bne .offset_line
	.check_string:
		sta <$1a
		lda $7400,x
		bne .load_string
			lda #$73
			sta stringCache	;$7ad7
	.load_string:
		lda #$88
		sta <$19
		lda <.items+1,x
		pha
		lda #0
		tax
		inx
		sta <$18
		lda <$1a
		jsr loadString
		
		lda #$c8
		sta stringCache+10
	.IFNDEF USE_ITOA8	
		lda #0
		sta <$19
		pla
		sta <$18	;count
		jsr itoa_16	;$34:95e1
		lda <$1d
		sta stringCache+11
		lda <$1e
		sta stringCache+12
	.ELSE
		pla	;count
		jsr itoa_8
		lda <$1b
		sta stringCache+11
		lda <$1c
		sta stringCache+12
	.ENDIF	
		lda #$0d
		sta <$18
		jsr strToTileArray
		lda #$0d
	.offset_line:
		jsr offsetTilePtr	;$35:a559
		inc <.counter
		inc <.counter
		lda <.counter
		cmp #8
	bne .loop
	rts
;==========================================================================================================
;$35:b242 isHandFreeForItem
;	[in] itemid $3e : toRemove
;	[in] itemid $40 : toEquip
;	[in] itemid $7af5 : righthand
;	[in] itemid $7af9 : lefthand
;	[out] bool carry : 0:ok 1:bad combination
;	original:65h bytes	
;(id)
;00		o	o	o	o	o	o
;01-45 		o	x	x	x	o
;46-49 			x	x	x	x
;4a-4e 				x	o	x
;4f-57 					x	x
;58-64						o
;	.ORG $b242
;	.DS $65+$172		;init original region
;
isHandFreeForItem:
.toRemove = $3e
.toEquip = $40
.right = $7af5+2	;original version uses $7af5,but it is not updated through equip change
.left = $7af9+2		;
	lda .right
	cmp <.toRemove
	bne .get_mask
		lda .left
.get_mask:
	jsr idToKind
	lda .masks,x
	pha
	lda <.toEquip
	jsr idToKind
	pla
.shift_loop:
		asl a
		dex
	bpl .shift_loop
	rts
.masks:	;0=ok 1:no
	.DB		%00000011	;00
	.DB		%00111011	;01-45
	.DB		%01111111	;46-49
	.DB		%01110111	;4a-4e
	.DB		%01101111	;4f-57
	.DB		%00111011	;58-64
	.DB		%11111111	;65-
;---------------------------------------------------------------------------------------------------------
idToKind:	;a = id,x = result
	ldx #5
.loop:
		cmp .bounds,x
		bcs .return
		dex
	bpl .loop
.return:
	inx
	rts
.bounds:
	.db	$01,$46,$4a,$4f,$58,$65
;==========================================================================================================
;original:$b2a7
;scrolling functions
;	[in,out] u8 $65 : background no
;	[in,out] u8 $66 : left(colIndex,0-7)
;	[in] u8 $69 : col index of 1st selection (if avail)
;	[in] u8 $67 : mode
;	.ORG $b2a7
itemWindowScrollX	= 120
itemWindowDx		= 120/3	;orig : $14
itemWindow_scrollRight
	lda <windowLeft
	cmp #6
	bcs .do_scroll
		adc #2
		pha
		cmp #7
		bcc .draw_next_column
			jsr eraseFromLeftBottom0Bx0A	;//$34:8f0b
.draw_next_column:	
		pla
		tax
		jsr drawItemWindowColumn
.do_scroll:
	lda <windowLeft
	cmp #7
	beq .update_cursor
		inc <windowLeft
		lda #itemWindowScrollX
		ldy #itemWindowDx
		jsr scrollItemWindow
.update_cursor:
	lda <mode
	beq .return
		jsr update1stCursor
.return:
	rts
;---------------------------------------------------------------------------------------------------------	
;original:$b362
;	.ORG $b362
itemWindow_scrollLeft:
;	[in,out] u8 $65 : background no
;	[in,out] u8 $66 : left(colIndex,0-7)
;	[in] u8 $69 : col index of 1st selection (if avail)
;	[in] u8 $67 : mode
	lda <windowLeft
	cmp #2
	bcc .do_scroll
	bne .draw_next_column
		lda #0
		sta $7573
		jsr drawEquipWindow
		jmp .do_scroll
.draw_next_column:	
		;always sec
		sbc #3
		tax
		jsr drawItemWindowColumn
.do_scroll:
	lda <windowLeft
	beq .update_cursor
		dec <windowLeft
		lda #-itemWindowScrollX
		ldy #-itemWindowDx
		jsr scrollItemWindow
.update_cursor:
	lda <mode
	beq .return
		jsr update1stCursor
.return:
	rts				
;---------------------------------------------------------------------------------------------------------
drawItemWindowColumn:
;	[in] x : colIndex (equip=-1)
.left = $18
.right = $19
.drawFlag = $1a
.firstItemOffset = $3d
;.windowPos = $b636
	txa
	asl a
	pha
	asl a
	asl a
	sta <.firstItemOffset
	jsr loadTileArrayForItemWindowColumn	;$34:b48b
	pla
	tax
	beq .left_required
;check right
	cpx #14	;7*2
	beq .right_required
	lda #0
	beq .store_flag
.left_required:
	lda #1
	bne .store_flag
.right_required:	
	lda #2
.store_flag
	sta <.drawFlag		
	lda .windowPos,x
	sta <.left
	lda .windowPos+1,x
	sta <.right
	
	jmp draw8LineWindow	;$8b38
.windowPos:
	.db	$10,$1E
	.db	$1F,$8D
	.db	$8E,$9C
	.db $9D,$0B
	.db $0C,$1A
	.db $1B,$89
	.db $8A,$98
	.db $99,$07	
;---------------------------------------------------------------------------------------------------------	
scrollItemWindow:
;	[in] s8 a : scrollX
;	[in] s8 y : dx
.scrollTo = $64
.invert = $65
;.windowLeft = $66
.ppuFlag1 = $08
.currentX = $10
	tax
	bmi .scroll_left
	lda #%00000000
	beq .store_invert
.scroll_left:
	lda #%00000001
.store_invert:
	sta <.invert
	txa
	clc
	adc <.currentX
	sta <.scrollTo
.scroll_loop:
		jsr updateDmaPpuScrollSyncNmi	;$3f:f8c5 (y is unchanged)
		tya
		clc
		adc <.currentX
		sta <.currentX
		rol	a	;take carry
		and #1	;mask
		eor <.invert	;invert if scroll to left
		;a = 01 if overflow
		eor <.ppuFlag1
		sta <.ppuFlag1
		lda <.currentX
		cmp <.scrollTo
	bne .scroll_loop
	rts
;---------------------------------------------------------------------------------------------------------
update1stCursor:
	;if (lastCol == left || lastCol == left + 1)
	ldx <windowLeft
	cpx <lastCol
	beq .move_cursor
	inx
	cpx <lastCol
	bne .hide_cursor
	lda #$84
	bne .store_x
.move_cursor:
	lda #$0c
.store_x:	
	sta <$1d	;#$84 or #0c
	lda <lastRow
	jsr $fd3e	;asl * 4
	adc #$a8
	sta <$1c
	lda #1
	sta <$1a
	jmp tileSprites2x2
	;jsr tileSprites2x2
	;rts
.hide_cursor:	
	lda <$1c
	pha
	lda #$f0
	sta <$1c
	lda #1
	sta <$1a
	jsr tileSprites2x2
	pla
	sta <$1c
	rts	
;$b419:
;==========================================================================================================
;$35:b5f9 drawEquipWindowNoErase
drawEquipWindowNoErase:
.eraseFlag = $7573	
	lda #$ff
	sta .eraseFlag
	;jmp drawEquipWindow
;==========================================================================================================
;$35:b419 drawEquipWindow
;	[in] u16 $59 : ptrToEquips ($6200)
;	[in] bool $7573 : eraseFlag 
drawEquipWindow:
.items = $34
	ldx #7
.initloop:
		lda #1
		sta $7400,x
		lda #$ff
		sta <.items,x
		dex
		bpl .initloop
	jsr getPlayerOffset
	adc #3
	tay	

	lda [pEquips],y
	sta <.items+2
	iny
	lda [pEquips],y
	sta <.items+3
	iny
	lda [pEquips],y
	sta <.items+6
	iny
	lda [pEquips],y
	sta <.items+7

	jsr loadTileArrayOfItemProps

	ldy #8
.putText:
		ldx .putOffsets,y
		;tax
		lda .text,y
		sta TILE_ARRAY_BASE,x
		dey
		bpl .putText

	lda $7573
	cmp #$ff
	beq .draw
		jsr eraseFromLeftBottom0Bx0A
.draw:	
	lda #1
	sta <$18	;left
	lda #$0f
	sta <$19	;right
	lda #$03
	sta <$1a
	jmp draw8LineWindow
.putOffsets:
	.db $01,$35,$0f,$44,$0d,$0e,$41,$42,$43
.text:
	.db $c0,$c0,$9c,$9c,$a9,$90,$a4,$99,$b1
	;b184
;$b48b
;==========================================================================================================
;$35:b48b loadTileArrayForItemWindowColumn()
;	[in,out] u8 $3d : firstItemOffset, incremented by 8 per call
loadTileArrayForItemWindowColumn:
.firstItem = $3d
.items = $34
	lda #7
	tax
	clc
	adc <.firstItem
	tay
.init_loop:
		lda #1
		sta $7400,x
		lda $60c0,y
		sta .items,x
		dey
		dex
		bpl .init_loop
	
	inx	;x => 0
	lda <.firstItem
	lsr a
	tay
.replace_loop:
		lda .items,x
		bne .check_flag
			lda #$57	;bare fist
			sta .items,x
	.check_flag:
		lda $7b41,y
		bne .next
			dec $7400,x
	.next:
		iny
		inx
		inx
		cpx #8
		bne .replace_loop
	
	clc
	lda <.firstItem
	adc #8
	sta <.firstItem
	tay
	jmp loadTileArrayOfItemProps
;$b4d4:
;==========================================================================================================
;$35:b4d4 itemWindow_moveCursor
itemWindow_moveCursor:
	lda <row
	jsr $fd3e	;a <<= 4
	adc #$a8
	sta <$1c
	lda #8
	ldx <col
	cpx <windowLeft
	beq .store_x
		lda #$80
.store_x:
	sta <$1d
	lda #0
	sta <$1a
	jmp tileSprites2x2
;==========================================================================================================
;$b4f7	
;	.ORG $b4f7
itemWindow_OnUse:
.index = $26
.itemId = $27
.itemParams = $7478
	lda <col
	asl a
	asl a
	clc
	adc <row
	sta <.index
	tax
	lda equipFlags,x
	beq .fail
	asl <.index
	ldx <.index
	lda cachedItems,x
	bne .use_ok
.fail:	
		jsr setYtoOffset2E	;$9b9b
		lda #0
		sta [pPlayer],y
		jsr requestSoundEffect06	;9b81
		jmp itemWindowInputLoop
.use_ok:
	sta <.itemId		
	tax
	jsr requestSoundEffect05	;9b7d
	jsr setYtoOffset2E	;$9b9b
	txa
	sta [pPlayer],y
	cmp #$a6
	bcc .not_heal
	cmp #$a9
	bcs .not_heal
	lda #$ff
	sta $7ce8
.not_heal:	
	dey
	dey
	lda #8
	ora [pPlayer],y
	sta [pPlayer],y
	;here x = id
	;[00-56] ok
	;[57-97]
	;[98-c7] ok
	;[c8-ff]
	cpx #$57
	bcc .use_equip
	cpx #$98
	bcc .fail
	cpx #$c8
	bcs .fail
	;[98-c7] $b564:
		lda $7400
		pha
		txa	;id
		;clc here always clear
		adc #8		;$46 = #$91a0 + (a - #$98)
		sta <$46
		lda #0
		adc #$91
		sta <$47
		lda #1
		sta <$4b
		lda #$1a
		sta <$4a
		lda #$17
		jsr $fddc	;copyTo7400(bank:a = #17 base:$46 = #91a0 + (a - #98), size:$4b = 1, restore:$4a = #1a):	;$fddc
		ldy $7400
		pla
		sta $7400
		clc
		bcc .check_flag
.use_equip:		
	;itemid:[00-56]
		txa	;id
		sta <$18
		lda #8
		sta <$1a
		lda #$00
		sta <$20
		lda #$94
		sta <$21
		ldx #$78
		jsr $ba3a	;loadTo7400FromBank30(index:$18 = a,size:$1a = 8,base:$20 = #9400,dest:x = #78);	;$ba3a
		
		ldy .itemParams+4 ;$747c
.check_flag
	;here y: effect type? $b58b
	;ldx <.index
	;lda equipFlags,x
	;beq .fail
	cpy #$7f
	bne .load_param
		lda #9
		sta .itemParams+5
		bne .select_target
.load_param:
		sty <$18
		lda #8
		sta <$1a
		lda #$c0
		sta <$20
		lda #$98
		sta <$21
		ldx #$78
		jsr $ba3a
.select_target:
	jsr $b979 ;	;‘ÎÛ‘I‘ð? (2 == cancel)
	cmp #2
	bne .consume
		;dec <iPlayer
		;jmp closeItemWindow
		jmp itemWindow_closeAndKeepCurrentPlayer
.consume:
	lda #$3f
	jsr $9b88
	lda <.itemId
	sta [pPlayer],y
	lda <col
	bne .not_equip
		dey
		lda #1
		sta [pPlayer],y
.not_equip:
	ldx <.index
	inx
	dec cachedItems,x
	lda cachedItems,x
	bne .copyback
		;as cosumed,item count reached 0.so clear id
		dex
		sta cachedItems,x
.copyback:		
	ldx #$3f
.copyloop:	
		lda cachedItems+8,x
		sta backpackItems,x
		dex
		bpl .copyloop
	jmp closeItemWindow
;==========================================================================================================
;$b601
;$35:b601 redrawColumn
;//	[in] u8 x : col
;==========================================================================================================
;$b636
ff3_itemWindow_end:
ff3_itemWindow_size = ff3_itemWindow_end - ff3_itemWindow_begin

