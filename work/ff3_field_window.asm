; ff3_field_window.asm
;
; description:
;	replaces field::drawWindow($3f:ed02) related codes
;
; version:
;	0.2.0
;======================================================================================================
ff3_field_window_begin:

	.ifdef FAST_FIELD_WINDOW
	INIT_PATCH $3f,$ece5,$ecf5
;field::draw_window_top:
;1F:ECE5:A5 39     LDA window_top = #$0B
;1F:ECE7:85 3B     STA window_row_in_draw = #$0F
;1F:ECE9:20 70 F6  JSR field::calc_size_and_init_buff
;1F:ECEC:20 56 ED  JSR field::init_window_attr_buffer
;1F:ECEF:20 F6 ED  JSR field::get_window_top_tiles
;1F:ECF2:20 C6 ED  JSR field::draw_window_row
field_draw_window_top:
.window_top = $39
.window_row_in_drawing = $3b
	lda <.window_top
	sta <.window_row_in_drawing
	jsr field_calc_draw_width_and_init_window_tile_buffer
	jsr field_init_window_attr_buffer
	jsr field_get_window_top_tiles
	jsr field_draw_window_row
	;; fall through (into $ecf5: field_restore_bank)
	VERIFY_PC $ecf5
;------------------------------------------------------------------------------------------------------
	;INIT_PATCH $3f,$ed02,$ed56
	INIT_PATCH $3f,$ed02,$ee65
field_draw_window_box:	;;$3f:ed02 field::drawWindow
;//	[in] u8 $3c : width (border incl)
;//	[in] u8 $3d : height
;//caller:
;//	$3c:8efd
;//	$3c:8f0e
;//	$3c:8fd5
;//	$3c:90b1
;//	$3d:aaf4 (jmp)
;{
;	push ( $3d - 2 );
;	field::getWindowTilesForTop();	//$edf6();
;	field::drawWindowLine();	//$edc6();
;	a = pop - 2;
;	if (a != 0) { //beq ed3b
;$ed23:
;		if (a < 0) { //bcs ed2a
;$ed25:
;			$3b--;
;			//jmp $ed3b
;		} else {
;$ed2a:
;			do {
;				push a;
;				field::getWindowTilesForMiddle();	//$ee1d();
;				field::drawWindowLine();	//$edc6();
;				a = pop a - 2;
;				if (a == 0) goto $ed3b
;			} while (a >= 0); //bcs ed2a
;$ed39:
;			$3b--;
;		}
;	}
;$ed3b:
;	field::getWindowTilesForBottom()//$ee3e();
;	field::drawWindowLine();	//$edc6();
;$ed41:
;	$38++; $39++;
;	$3c -= 2;
;	$3d -= 2;
;	return restoreBanksBy$57();	//jmp $ecf5();
;$ed56:
;}
.skipAttrUpdate = $37
.window_id = $96
.currentY = $3b
.beginX = $38	;loaded by field_get_window_metrics
.beginY = $39	;loaded by field_get_window_metrics
.width = $3c	;loaded by field_get_window_metrics
.height = $3d	;loaded by field_get_window_metrics
.attrCache = $0300	;128bytes. 1st 64bytes for 1st BG, 2nd for 2nd.
.newAttrBuffer = $07c0	;16bytes. only for 1 line (2 consecutive window row)

	ldx <.window_id
	jsr field_get_window_metrics	;$ed61
;---
	;jsr field_calc_draw_width_and_init_window_tile_buffer ;	$f670
;---
	lda <.skipAttrUpdate
	bne .post_attr_update
		jsr field_init_window_attr_buffer	;ed56
		lda <.height
		pha
		ldy <.beginY
.setupAttributes:
		sty <.currentY
		jsr field_updateTileAttrCache	;$c98f
		ldy <.currentY
		iny
		;; field_updateTileAttrCache() has a bug in cases that window crosses vertical boundary (which is at 0x1e)
		;; that is, if currentY > 0x1e, updated attributes are placed 1 row above where it should be in.
		;; so here handles as a wrokaround wrapping vertical coordinates.
		cpy #$1e	;; wrap around
		bne .no_wrap
			ldy #0
	.no_wrap:
		pla
		sec
		sbc #1
		pha
		bne .setupAttributes

	.update_ppu:
		pla	;dispose
		jsr do_sprite_dma_from_0200	;if omitted, sprites are shown on top of window
		jsr waitNmiBySetHandler
		jsr field_X_updateVramAttributes
		jsr field_setBgScrollTo0	;if omitted, noticable glithces arose in town conversations
		jsr field_callSoundDriver
		
.post_attr_update:
	;jsr field_X_render_borders
; adjust metrics as borders don't need further drawing...
	jsr field_X_shrink_window_metrics
	jmp field_restore_bank	;$ecf5

	;VERIFY_PC $ed56

;------------------------------------------------------------------------------------------------------
;$3f:ed56 field::fill_07c0_ff
;{
;	for (x = #f;x >= 0;x--) {
;		$07c0.x = #ff;
;	}
;	return;
;$ed61:
;}
field_init_window_attr_buffer:	;;$3f:ed56 field::fill_07c0_ff
.window_attr_buffer = $07c0
	ldx #$0f
	lda #$ff
.fill:
	sta .window_attr_buffer,x
	dex
	bpl .fill
field_window_rts_1:
	rts

	;VERIFY_PC $ed61
;------------------------------------------------------------------------------------------------------
;$3f:ed61 field::get_window_metrics
;//[in]
;// u8 $37: skipAttrUpdate
;// u8 X: window_type (0...4)
;//		0: object's message?
;//		1: choose dialog (Yes/No) (can be checked at INN)
;//		2: use item to object
;//		3: Gil (can be checked at INN)
;//		4: floor name
;//[out]
;//	u8 $38: start_x
;//	u8 $39: start_y
;//	u8 $3c: width
;//	u8 $3d: height
;{
;	if ($37 == 0) { //bne edb1
;		a = $b6 = $edb2.x
;		$97 = a - 1;
;		$98 = $b5 = a = $edb7.x + 2;
;		$b5--;
;		$38 = (($29 << 1) + $edb2.x) & #3f;
;		$39 = (($2f << 1) + $edb7.x) % #1e;
;		a = $3c = $edbc.x;
;		a = $b8 = $b6 + a; $b8--;
;		a = $3d = $edc1.x;
;		$b7 = a + $b5 - 3;
;		$ec18();
;	}
;$edb1:
;	return;
;}
	;INIT_PATCH $3f,$ed61,$edc6
field_get_window_metrics:	;;$3f:ed61 field::get_window_metrics
;; to reflect changes in screen those made by 'field_hide_sprites_around_window',
;; which is called within this function,
;; caller must update sprite attr such as:
;; lda #2
;; sta $4014	;DMA
;[in]
.scroll_x = $29	;in 16x16 unit
.scroll_y = $2f	;in 16x16 unit
.skip_attr_update = $37
;[out]
.left = $38	;in 8x8 unit
.top = $39	;in 8x8 unit
.width = $3c
.height = $3d
.offset_x = $97
.offset_y = $98
.internal_top = $b5
.internal_left = $b6
.internal_bottom = $b7
.internal_right = $b8

	lda <.skip_attr_update
	bne field_window_rts_1	;rts (original: bne $ed60)
	;; calculate left coordinates
	lda .window_attr_table_x,x
	sta <.internal_left
	sta <.offset_x
	dec <.offset_x
	lda <.scroll_x	;assert(.object_x < 0x80)
	asl a
	adc <.internal_left
	and #$3f
	sta <.left
	;; calculate top coordinates
	lda .window_attr_table_y,x
	;clc ;here always clear
	adc #2
	sta <.offset_y
	sta <.internal_top
	dec <.internal_top
	lda <.scroll_y
	asl a
	adc .window_attr_table_y,x
	cmp #$1e
	bcc .no_wrap
	;sec ;here always set
	sbc #$1e
.no_wrap:
	sta <.top
	
	;; calculate right coordinates
	lda .window_attr_table_width,x
	sta <.width
	clc
	adc <.internal_left
	sta <.internal_right
	dec <.internal_right
	;; calculate bottom coordinates
	lda .window_attr_table_height,x
	sta <.height
	clc
	adc <.internal_top
	;sec	;here always clear
	sbc #2
	sta <.internal_bottom
	;; done calcs
	jmp field_hide_sprites_around_window	;$ec18
	;rts
	;VERIFY_PC $edb2
	;.org $edb2
.window_attr_table_x:	; = $edb2
	.db $02, $02, $02, $12, $02
.window_attr_table_y:	; = $edb7
	.db $02, $12, $12, $0e, $02
.window_attr_table_width:	; = $edbc
	.db $1c, $08, $1c, $0c, $1c
.window_attr_table_height:	; = $edc1
	.db $0a, $0a, $0a, $04, $04

	;VERIFY_PC $edc6

;------------------------------------------------------------------------------------------------------
;$3f:edc6 field::drawWindowLine
;{
;	$90 = $3c;
;	$c98f();	//field::loadWindowPalette?
;	waitNmiBySetHandler();	//$ff00();
;	$4014 = 2;
;	putWindowTiles();	//$f6aa();
;	field::setWindowPalette();	//$c9a9();
;	field::setBgScrollTo0();	//$ede1();
;	return field::callSoundDriver();
;$ede1:
;}
	;INIT_PATCH $3f,$edc6,$ede1
field_draw_window_row:	;;$3f:edc6 field::drawWindowLine
.width = $3c
.iChar = $90
	lda <.width
	sta <.iChar
	jsr field_updateTileAttrCache	;$c98f
	jsr waitNmiBySetHandler	;$ff00
	jsr do_sprite_dma_from_0200
	jsr field_drawWindowContent	;$f6aa
	jsr field_setTileAttrForWindow	;$c9a9
	jsr field_setBgScrollTo0	;$ede1
	jmp field_callSoundDriver	;$c750
	VERIFY_PC $ede1
;------------------------------------------------------------------------------------------------------
;$3f:ede1 field::setBgScrollTo0
;{
;	if ($37 == 0) { //bne ede8
;		return $e571();
;	}
;$ede8:
;	$2000 = $ff;
;	$2005 = 0; $2005 = 0;
;	return;
;$edf6:
;}
	;INIT_PATCH $3f,$ede1,$edf6
field_setBgScrollTo0:	;;$3f:ede1 field::setBgScrollTo0
.skip_attr_update = $37
.ppu_ctrl_cache = $ff
	lda <.skip_attr_update
	bne .set_ppu_ctrl
		jmp $e571
.set_ppu_ctrl:
	lda <.ppu_ctrl_cache
	sta $2000
	lda #00
	sta $2005
	sta $2005
	rts
	VERIFY_PC $edf6
;------------------------------------------------------------------------------------------------------
;$3f:edf6 field::getWindowTilesForTop
;$3f:ee1d field::getWindowTilesForMiddle
;$3f:ee3e field::getWindowTilesForBottom
;//caller:
;//	$3f:ed3b
;{
;	x = 1;
;	$0780 = #fa;
;	$07a0 = #fc;
;	for (x;x < $3c;x++) {
;		$0780.x = #ff;
;		$07a0.x = #fd;
;	}
;	x--;
;	$0780.x = #fb;
;	$07a0.x = #fe;
;	return;
;$ee65:
;}
	;.ifdef FAST_FIELD_WINDOW
	;INIT_PATCH $3f,$edf6,$ee65
field_get_window_top_tiles:		;edf6
	ldy #0
	beq field_X_get_window_tiles
field_get_window_middle_tiles:	;ee1d
	ldy #3
	bne field_X_get_window_tiles
field_get_window_bottom_tiles:	;ed3b
	ldy #6
	;fall through
field_X_get_window_tiles:
.width = $3c
.tiles_1st = $0780
.tiles_2nd = $07a0
	lda .window_parts,y
	sta .tiles_1st
	lda .window_parts+3,y
	sta .tiles_2nd
	ldx <.width
	dex
	lda .window_parts+2,y
	sta .tiles_1st,x
	lda .window_parts+5,y
	sta .tiles_2nd,x
	dex
.center_tiles:
		lda .window_parts+1,y
		sta .tiles_1st,x
		lda .window_parts+4,y
		sta .tiles_2nd,x
		dex
		bne .center_tiles
	rts
.window_parts:
	db $f7, $f8, $f9
	db $fa, $ff, $fb
	db $fa, $ff, $fb
	db $fc, $fd, $fe
;-----------
field_X_updateVramAttributes:
	ldx #0
	lda #$23
	jsr .field_X_copyAttributes
	;ldx #$40	;on exit from above, X will have #$40
	lda #$27
	;fall through
;[in]
;	u8 a: vram address high
;	u8 x: offset into attr table cache
;	attr_value[128] $0300: attr table cache
.field_X_copyAttributes:
	bit $2002
	sta $2006
	lda #$c0
	sta $2006
.field_X_updateTileAttrEntirely:
.attr_cache = $0300
	ldy #$40	;update entire attr table in target BG (64 bytes)
.copy:
		lda .attr_cache,x
		sta $2007
		inx
		dey
		bne .copy
	rts
;-----------

	VERIFY_PC $ee65
	.endif	;FAST_FIELD_WINDOW
;======================================================================================================
;$3f:f40a setVramAddrForWindow
;//	[in] u8 $3a : x offset
;//	[in] u8 $3b : y
	INIT_PATCH $3f,$f40a,$f435
field_setVramAddrForWindow:
.offsetX = $3a
	ldy <.offsetX
field_setVramAddrForWindowEx:
;[in] a : widthInCurrentBg
;[in] y : offsetX
;[out] y : offsetX & #20 ^ #20
;[in]
.offsetX = $3a
.offsetY = $3b
;[ref]
.vramAddrLow = $f4a1
.vramAddrHigh = $f4c1
;--------------------------------------
	tya
	pha
	ldy <.offsetY
	and #$20
	tax
	beq .left_on_1st_bg
		lda #$04
.left_on_1st_bg:
	ora .vramAddrHigh,y
	sta $2006

	pla
	and #$1f
	ora .vramAddrLow,y
	sta $2006

;x = left & #20
	txa
	eor #$20
	tay

	rts

	VERIFY_PC $f435
;------------------------------------------------------------------------------------------------------
	.ifdef FAST_FIELD_WINDOW
	INIT_PATCH $3f,$f670,$f692
field_calc_draw_width_and_init_window_tile_buffer:
;field_init_window_tile_buffer:
;;[in]
.left = $38
.width = $3c
.width_for_current_bg = $91
;$3f:f670
;{
;	$91 = $3c;
;	if ( ($38 & #1f) ^ #1f + 1 < $3c) {
;		$91 = a;
;	}
;$f683:
;}
	;; if window across BG boundary (left + width >= 0x20)
	;; then adjust the width to fit just enough to the BG
	lda <.left
	and #$1f	;take mod of 0x20 to wrap around
	eor #$1f	;negate...
	clc			;
	adc #1		;...done. A = (0x20 - left) % 0x20
	cmp <.width
	bcc .store_result
		;; there is enough space to draw entirely
		lda <.width
.store_result:
	sta <.width_for_current_bg
	;; fall through
field_init_window_tile_buffer:	;;f683
;;[in]
.tiles_1st = $0780
.tiles_2nd = $07a0
;$f683
;	a = #ff
;	for (y = #1d;y >= 0;y--) {
;		$0780,y = a;
;		$07a0,y = a;
;	}
;	clc;
;	return;
;$f692:
	lda #$ff
	ldy #$1d
.copy_loop:
		sta .tiles_1st,y
		sta .tiles_2nd,y
		dey
		bpl .copy_loop
	clc
	rts
	VERIFY_PC $f692
;------------------------------------------------------------------------------------------------------
	INIT_PATCH $3f,$f692,$f6aa
field_drawStringInWindow:
;$3f:f692 field::drawStringInWindow
;{
;	push a;
;	waitNmiBySetHandler();	//$ff00
;	$f0++;
;	pop a;
;	putWindowTiles();	//$f6aa
;$f69c
;	field::setBgScrollTo0();	//$ede1();
;	field::callSoundDriver();
;	call_switchFirst2Banks(per8kbank:a = $93);	//$ff03
;	return $f683();	//??? a= ($93+1)
;$f6aa:
;}
;; [in]
;;	u8 a: ?
;;	u8 $f0: frame_counter
;;	u8 $93: per8k bank
.bank = $93
	pha
	jsr waitNmiBySetHandler	;ff00
	inc <field_frame_counter
	pla
	jsr field_drawWindowContent	;f6aa
	jsr field_setBgScrollTo0	;ede1
	jsr field_callSoundDriver	;c750
	lda <.bank
	jsr call_switch_2banks		;ff03
	jmp field_init_window_tile_buffer	;f683

	VERIFY_PC $f6aa
	.endif	;FAST_FIELD_WINDOW
;------------------------------------------------------------------------------------------------------
;$3f:f6aa putWindowTiles
;//	[in] u8 $38 : offset x
;//	[in] u8 $39 : offset per 2 line
;//	[in,out] u8 $3b : offset y (wrap-around)
	INIT_PATCH	$3f,$f6aa,$f727
;; call tree:
;;	$eb43: ?
;;		$eec0: field::drawEncodedStringInWindow
;;			$eefa: field::decodeStringAndDrawInWindow
;;				$f692: field::drawStingInWindow
;;	
;;	$ed02: field::drawWindowBox
;;		$edc6: field::drawWindowLine
field_drawWindowContent:
;[in]
.left = $38
.width = $3c
.offsetX = $3a
.offsetString = $3a
.offsetY = $3b
.iChar = $90
.widthIn1stBg = $91
.tileArray = $0780
.upperLineString = $0780
.lowerLineString = $07a0

;-----------------------------------------
	cmp #9
	beq .draw_lower_line
		lda #0
		jsr .draw_line
.draw_lower_line:
	lda #$20
.draw_line:
;[in] a  = index offset
	pha
	sta <.offsetString

	bit $2002
	lda <.widthIn1stBg
	ldy <.left
	jsr .putTiles	;[out] y = offsetX & #20 ^ #20, $3a = offsetString

	clc
	pla
	adc <.width
	sec
	sbc <.offsetString
	bcc .next_line
	beq .next_line
		jsr .putTiles

.next_line:
	ldy <.offsetY
	iny
	cpy #30
	bne .no_wrap
		ldy #0
.no_wrap:
	sty <.offsetY
	lda #0
	sta <.iChar	;$90
	rts

.putTiles:
	pha

	jsr field_setVramAddrForWindowEx
.beginOffset = .offsetString
.endOffset = .beginOffset
	pla	;widthInCurrentBg
	ldx <.offsetString
	pha
	clc
	adc <.offsetString
	sta <.endOffset
	pla
	lsr a
	ror a
	bpl .length_even
;odd
.length_odd:
	bcc .copy_loop_1
	bcs .copy_loop_3
;even
.length_even:
	bcs .copy_loop_2
.copy_loop_0:
	lda .tileArray,x
	sta $2007
	inx
.copy_loop_3:
	lda .tileArray,x
	sta $2007
	inx
.copy_loop_2:
	lda .tileArray,x
	sta $2007
	inx
.copy_loop_1:
	lda .tileArray,x
	sta $2007
	inx
	
	cpx <.offsetString
	bne .copy_loop_0

	rts
	;VERIFY_PC $f727
field_X_shrink_window_metrics:
.left = $38	;loaded by field_getWindowMetrics
.top = $39	;loaded by field_getWindowMetrics
.width = $3c	;loaded by field_getWindowMetrics
.height = $3d	;loaded by field_getWindowMetrics
	inc <.left
	inc <.top
	dec <.width
	dec <.width
	dec <.height
	dec <.height
	rts
	VERIFY_PC $f727
;======================================================================================================
	RESTORE_PC ff3_field_window_begin