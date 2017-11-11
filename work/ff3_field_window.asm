; ff3_field_window.asm
;
; description:
;	replaces field::draw_window_box($3f:ed02) related codes
;
; version:
;	0.2.0
;======================================================================================================
ff3_field_window_begin:

	.ifdef FAST_FIELD_WINDOW
	INIT_PATCH $3f,$ec8b,$ece5
;;$3f:ec8b field::show_message_window:
;;callers:
;;	1F:E237:20 8B EC  JSR field::show_message_window
;;
field_show_message_window:
.field_pad1_inputs = $20
	lda #0
	jsr field_draw_inplace_window		;$ecfa
	jsr field_stream_string_in_window	;$ee65
	jsr field_await_and_get_next_input	;$ecab
	lda <$7d
	;beq .leave	;$eca8
	bne .enter_input_loop
.leave:	;$eca8
		jmp $c9b6
.input_loop:	;$ec9e
	jsr field_get_next_input	
.enter_input_loop:	;$ec9a
	lda <.field_pad1_inputs
	bpl .input_loop
.on_a_button_down:	;$eca4
	lda #0
	sta <$7d
	beq .leave

;------------------------------------------------------------------------------------------------------
;;$3f:ECAB field::await_and_get_new_input:
;;callers:
;;	 1F:EC93:20 AB EC  JSR field::await_and_get_new_input ($3f:ec8b field::show_message_window)
;;	 1F:ECBA:4C AB EC  JMP field::await_and_get_new_input (tail recursion)
;;	 1F:EE6A:20 AB EC  JSR field::await_and_get_new_input ($3f:ee65 field::stream_string_in_window)
field_await_and_get_next_input:
	jsr field_X_get_input_with_result	;on exit, A have the value from $20
	beq field_get_next_input_in_this_frame
	jsr field_X_advance_frame
	jmp field_await_and_get_next_input
;------------------------------------------------------------------------------------------------------
;;$3f:ECc4 field::get_next_input:
;;callers:
;;	1F:EC9E:20 C4 EC  JSR field::get_next_input
field_get_next_input:
;.field_pad1_inputs = $20	;bit7 <- A ...  -> bit0
;;$ecc4:
	jsr field_X_advance_frame
	;;fall through
field_get_next_input_in_this_frame:
.field_input_cache = $21
;;$ecbd:
	jsr field_X_get_input_with_result	;on exit, A have the value from $20
	beq field_get_next_input
;;$eccf
	sta <.field_input_cache
	;;fall through
;------------------------------------------------------------------------------------------------------
field_X_set_bank_for_window_content_string:
.content_string_bank = $93
	lda <.content_string_bank
	jmp call_switch_2banks
;------------------------------------------------------------------------------------------------------
;;$3f:ecd8 field::advance_frame_with_sound
;;callers:
;;	 1F:EE74:20 D8 EC  JSR field::advance_frame_w_sound ($3f:ee65 field::stream_string_in_window)
field_advance_frame_and_set_bank:
	jsr field_X_advance_frame
	jmp field_X_set_bank_for_window_content_string

field_X_advance_frame:
.field_frame_counter = $f0
	jsr waitNmiBySetHandler
	inc <.field_frame_counter
	jmp field_callSoundDriver

field_X_get_input_with_result:
.field_pad1_inputs = $20	;bit7 <- A ...  -> bit0
	jsr field_get_input
	lda <.field_pad1_inputs
	rts

	VERIFY_PC $ece5

;------------------------------------------------------------------------------------------------------
	INIT_PATCH $3f,$ece5,$ecf5
;;$3f:ece5 field::draw_window_top:
;;NOTEs:
;;	called when executed an exchange of position in item window from menu
;;original code:
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
	;jsr field_init_window_attr_buffer
	nop
	nop
	nop
	jsr field_get_window_top_tiles
	jsr field_draw_window_row
	;; fall through (into $ecf5: field_restore_bank)
	VERIFY_PC $ecf5
;------------------------------------------------------------------------------------------------------
	;INIT_PATCH $3f,$ed02,$ed56
	INIT_PATCH $3f,$ed02,$ee65
;;$3f:ed02 field::draw_window_box
;;callers:
;;	$3c:8efd
;;	$3c:8f0e
;;	$3c:8fd5
;;	$3c:90b1
;;	$3d:aaf4 (jmp) in $3d:aaf1 field::drawWindowOf
;;
;;	This logic plays key role in drawing window, both for menu windows and in-place windows.
;;	Usually window drawing is performed as follows:
;;	1)	Call this logic to fill in background with window parts
;;		and setup BG attributes if necessary (the in-palce window case).
;;		In cases of the menu window, BG attributes have alreday been setup in another logic
;;		and should not be changed.
;;	2)	Subsequently call other drawing logics which overwrites background with
;;		content (aka string) in the window, 2 consecutive window rows per 1 frame.
;;		These logics rely on window metrics variables, which is initially setup on this logic,
;;		and don't change BG attributes anyway.
;;NOTEs:
;;	in the scope of logic, it is safe to use the address range $0780-$07ff (inclusive) in a destructive way.
;;	The original code uses this area as temporary buffer for rendering purporses
;;	and discards its contents on exit.
;;	more specifically, address are utilized as follows:
;;		$0780-$07bf: used for PPU name table buffer,
;;		$07c0-$07cf: used for PPU attr table buffer,
;;		$07d0-$07ff: used for 3-tuple of array that in each entry defines
;;			(vram address(high&low), value to tranfer)
field_draw_window_box:
;;[in]
.window_id = $96
.skipAttrUpdate = $37	;;or in more conceptual, 'is in menu window'
;;[in,out]
.beginX = $38	;loaded by field_get_window_metrics
.beginY = $39	;loaded by field_get_window_metrics
.currentY = $3b
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
		jsr waitNmiBySetHandler
		jsr do_sprite_dma_from_0200	;if omitted, sprites are shown on top of window
		jsr field_X_update_ppu_attr_table
		;jsr field_sync_ppu_scroll	;if omitted, noticable glithces arose in town conversations
		;jsr field_callSoundDriver
		jsr field_X_end_ppu_update

.post_attr_update:
	jsr field_X_render_borders
; adjust metrics as borders don't need further drawing...
	jsr field_X_shrink_window_metrics
	jmp field_restore_bank	;$ecf5

	;VERIFY_PC $ed56

field_X_update_ppu_attr_table:
.left = $38
.top = $39	;in 8x8
.offset_x = $3a
.offset_y = $3b
.width = $3c
.height = $3d
.attr_cache = $0300
	lda <.top
	and #$1c	;capping valid height (0x1e) and mask off lower bits to align 32x32 boundary
	asl A	; (top >> 2) << 3 : 8 bytes per row
	sta <.offset_x

	lda <.height
	adc <.top
	cmp #30
	bcc .no_wrap
		adc #1	;effectively +2. to fill gap between screen boundary and attr boundary
.no_wrap:
	adc #3	;round up to next attr boundary (4n)
	and #$1c
	asl A
	sta <.offset_y

	ldy #$23
	jsr .field_X_upload_attributes
	ldy #$27
.field_X_upload_attributes:
	lda <.offset_x
.loop:
	;A = offset into attr table
	;X = index of attr table (taken target bg in account)
		cpy #$23
		beq .on_1st_bg
		ora #$40	;on 2nd bg, offset into cache started at .attr_cache + $40
.on_1st_bg:
		tax
		sty $2006
		ora #$c0
		sta $2006
	.upload_loop:
			lda .attr_cache,x
			sta $2007
			inx
			txa
			and #$07
			bne .upload_loop
		txa
		and #$38	;wraps if crosses bg boundary ($40)
		cmp <.offset_y
		bne .loop
	rts

field_X_render_borders:
	rts


	.ifdef TEST_BLACKOUT_ON_WINDOW
field_X_blackout_1frame:
	lda #%00000110
	sta $2001

	jsr waitNmiBySetHandler
	inc <field_frame_counter
	jsr field_sync_ppu_scroll	;if omitted, noticable glithces arose in town conversations
	jsr field_callSoundDriver
	lda #%00011110
	sta $2001	
	rts
	.endif	;TEST_BLACKOUT_ON_WINDOW

	.if 0
field_X_render_borders:
	;; 1: left-top to right-top, not including rightmost
	;; 2: right-top to right-bottom, not including bottom most
	;; 3: left-top to left-bottom, not including
	;	lda A
	;	sta $2007;
	;	bne unroll_offset
	;put_middle:
	;	lda B
	;	(sta $2007) x 8	;8C 07 20
	;	dex bne put_middle
.skipAttrUpdate = $37
.left = $38
.top = $39
.offset_x = $3a
.offset_y = $3b
.width = $3c
.height = $3d
.ppu_ctrl_cache = $ff

field_X_generate_uploader_code:
;.template_code_start = field_X_update_ppu_attr_table_end - 8	
;.template_code_end = field_X_update_ppu_attr_table_end - 5
field_X_store_PPUDATA = $f7b0
.generated_code_base = $0780
.SIZE_OF_CODE = 3
.UNROLLED_BYTES = $1f*.SIZE_OF_CODE
	ldy #-.UNROLLED_BYTES	;dest
.wrap_x:
		ldx #-.SIZE_OF_CODE	;src
.generate_loop:
		;lda .template_code_start-$0100+.SIZE_OF_CODE,x
		lda (field_X_store_PPUDATA)-$0100+.SIZE_OF_CODE,x
		sta .generated_code_base-($0100-.UNROLLED_BYTES),y
		iny
		beq .generate_epilog
		inx
		beq .wrap_x
		bne .generate_loop
.generate_epilog:
	lda #$60	;rts
	sta .generated_code_base+.UNROLLED_BYTES
	rts
;.template_code_start:
	;sta $2007
;.template_code_end:
	.endif ;0
;------------------------------------------------------------------------------------------------------
;;$3f:ed56 field::fill_07c0_ff
;;callers:
;;	$3f:ece5 field::draw_window_top
;;	$3f:ed02 field::draw_window_box
field_init_window_attr_buffer:
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
	;INIT_PATCH $3f,$ed61,$edc6
;;$3f:ed61 field::get_window_metrics
;;callers:
;;	$3f:ed02 field::draw_window_box
;;NOTEs:
;; 1) to reflect changes in screen those made by 'field_hide_sprites_around_window',
;;	which is called within this function,
;;	caller must update sprite attr such as:
;;	lda #2
;;	sta $4014	;DMA
;; 2) this logic is very simlar to $3d:aabc field::get_menu_window_metrics.
;;	the difference is:
;;		A) this logic takes care of wrap-around unlike the other one, which does not.
;;		B) target window and the address of table where the corresponding metrics defined at
field_get_window_metrics:
;[in]
.viewport_left = $29	;in 16x16 unit
.viewport_top = $2f	;in 16x16 unit
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
	lda <.viewport_left	;assert(.object_x < 0x80)
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
	lda <.viewport_top
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
	sbc #2	;effectively -3
	sta <.internal_bottom
	;; done calcs
	;; here X must have window_type (field_hide_sprites_around_window expects it)
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
;	field::sync_ppu_scroll();	//$ede1();
;	return field::callSoundDriver();
;$ede1:
;}
	;INIT_PATCH $3f,$edc6,$ede1
field_draw_window_row:	;;$3f:edc6 field::draw_window_row
;;callers:
;;	$3f:ece5 field::draw_window_top
;;	$3f:ed02 field::draw_window_box (only the original implementation)
.width = $3c
.iChar = $90
	lda <.width
	sta <.iChar
	;jsr field_updateTileAttrCache	;$c98f
	jsr waitNmiBySetHandler	;$ff00
	jsr do_sprite_dma_from_0200
	jsr field_upload_window_content	;$f6aa
	;jsr field_setTileAttrForWindow	;$c9a9
	;;fall through.
field_X_end_ppu_update:
	jsr field_sync_ppu_scroll	;$ede1
	jmp field_callSoundDriver	;$c750
	;VERIFY_PC $ede1
;------------------------------------------------------------------------------------------------------
;$3f:ede1 field::sync_ppu_scroll
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
;;$3f:ede1 field::sync_ppu_scroll
;;callers:
;;	$3f:edc6 field::draw_window_row
;;	$3f:f692 field::draw_window_content
field_sync_ppu_scroll:
.skip_attr_update = $37
.ppu_ctrl_cache = $ff
	lda <.skip_attr_update
	bne .set_ppu_ctrl
		jmp field_sync_ppu_scroll_with_player	;$e571
.set_ppu_ctrl:
	lda <.ppu_ctrl_cache
	sta $2000
	lda #00
	sta $2005
	sta $2005
	rts
	;VERIFY_PC $edf6
;------------------------------------------------------------------------------------------------------
	;.ifdef FAST_FIELD_WINDOW
	;INIT_PATCH $3f,$edf6,$ee65
;;$3f:edf6 field::getWindowTilesForTop
;;callers:
;;	$3f:ece5 field::draw_window_top
;;	$3f:ed02 field::draw_window_box
field_get_window_top_tiles:		
	lda #$00
	jsr field_X_get_window_tiles
	;lda #$07
	;;fall through
field_X_get_window_tiles:
.width = $3c
.eol = $3c
.window_tiles_buffer_upper_row = $0780
;.window_tiles_buffer_lower_row = $07a0
;;in: A := lower 1bits:  0: fill in upper row; 1: fill in lower row
;;	higher 7bits: offset into tile table
	lsr A
	tay
	ldx #0
	bcc .save_width
	ldx #$20
.save_width:
	lda <.width
	pha	;width
.left_tile:
	lda field_X_window_parts,y
	sta .window_tiles_buffer_upper_row,x
	txa
	clc
	adc <.width
	sta <.eol	;width + offset
	inx
.center_tiles:
		lda field_X_window_parts+1,y
		sta .window_tiles_buffer_upper_row,x
		inx
		cpx <.eol
		bcc .center_tiles
.right_tile:
	lda field_X_window_parts+2,y
	sta .window_tiles_buffer_upper_row-1,x
	pla	;original width
	sta <.width
	tya
	;here always carry is set
	;adc #$22	;effectively +23
	adc #$06
	rts
field_X_window_parts:
	db $f7, $f8, $f9
	db $fa, $ff, $fb
	db $fc, $fd, $fe
	.ifdef IMPL_BORDER_LOADER
;;$3f:ee1d field::getWindowTilesForMiddle
;;callers:
;;	$3f:ed02 field::draw_window_box
field_get_window_middle_tiles:	;ee1d
	lda #$03<<1
	jsr field_X_get_window_tiles
	lda #$03<<1|1
	bne field_X_get_window_tiles
;;$3f:ee3e field::getWindowTilesForBottom
;;callers:
;;	$3f:ed02 field::draw_window_box
field_get_window_bottom_tiles:	;ed3b
	lda #$03<<1
	jsr field_X_get_window_tiles
	bne field_X_get_window_tiles
	.endif	;.ifdef IMPL_BORDER_LOADER
;======================================================================================================
	VERIFY_PC $ee65
	.endif	;FAST_FIELD_WINDOW
;======================================================================================================
	.ifdef FAST_FIELD_WINDOW
	INIT_PATCH $3f,$ee65,$ee9a
;;$3f:ee65 field::stream_string_in_window
;;callers:
;;	$3c:90ff	? 1E:9109:4C 65 EE  JMP $EE65
;;	$3d:a666	? 1E:A675:4C 65 EE  JMP $EE65	(load menu)
;;	$3f:ec83	? 1F:EC88:4C 65 EE  JMP $EE65
;;	$3f:ec8b	? 1F:EC90:20 65 EE  JSR $EE65
field_stream_string_in_window:
.viewport_left = $29	;in 16x16 unit
.viewport_top = $2f	;in 16x16 unit
.in_menu_mode = $37
.window_left = $38	;in 8x8 unit
.window_top = $39	;in 8x8 unit
.window_width = $3c
.window_height = $3d
.offset_x = $97
.offset_y = $98
.field_frame_counter = $f0
	jsr field_load_and_draw_string	;$ee9a.
	;; on exit from above, carry has a boolean value.
	;; 1: more to draw, 0: completed drawing.
	bcc .do_return	
	.paging:
		jsr field_await_and_get_next_input
		lda <.window_height
		clc
		adc #1	;round up to next mod 2
		lsr A
	.streaming:
		sec
		sbc #1
		pha	;# of text lines available to draw
		lda #0
		sta <.field_frame_counter
		.delay_loop:
			jsr field_advance_frame_and_set_bank	;$ecd8
			lda <.field_frame_counter
			and #$01
			bne .delay_loop
		jsr field_seek_string_to_next_line	;$eba9
		jsr field_draw_string_in_window		;$eec0
		;; on exit from above, carry has a boolean value.
		;; 1: more to draw, 0: completed drawing.
		pla	;# of text lines available to draw
		bne .streaming	;there is more space to fill in
		bcs .paging	;there is more text to draw
		;;content space is filled with end of text 
.do_return:
	rts

	VERIFY_PC $ee9a
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
;[out] y : (offsetX & #$20) ^ #$20
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
;;$3f:f683 field::init_window_tile_buffer:
;;caller:
;;	$3f:f692 field::draw_window_content
field_init_window_tile_buffer:
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
	;ldy #$1d
	ldy #$3d
.copy_loop:
		sta .tiles_1st,y
		;sta .tiles_2nd,y
		dey
		bpl .copy_loop
	clc
	rts
	VERIFY_PC $f692
;------------------------------------------------------------------------------------------------------
	INIT_PATCH $3f,$f692,$f6aa
field_draw_window_content:
;$3f:f692 field::draw_window_content
;{
;	push a;
;	waitNmiBySetHandler();	//$ff00
;	$f0++;
;	pop a;
;	putWindowTiles();	//$f6aa
;$f69c
;	field::sync_ppu_scroll();	//$ede1();
;	field::callSoundDriver();
;	call_switchFirst2Banks(per8kbank:a = $93);	//$ff03
;	return $f683();	//??? a= ($93+1)
;$f6aa:
;}
;; [in]
;;	u8 a: ?
;;	u8 $f0: frame_counter
;;	u8 $93: per8k bank
;.string_bank = $93
	pha
	jsr waitNmiBySetHandler	;ff00
	inc <field_frame_counter
	pla
	jsr field_upload_window_content	;f6aa
	;jsr field_sync_ppu_scroll	;ede1
	;jsr field_callSoundDriver	;c750
	jsr field_X_end_ppu_update	;sync_ppu_scroll+call_sound_driver
	;lda <.string_bank
	;jsr call_switch_2banks		;ff03
	jsr field_X_set_bank_for_window_content_string
	jmp field_init_window_tile_buffer	;f683

	VERIFY_PC $f6aa
	.endif	;FAST_FIELD_WINDOW
;------------------------------------------------------------------------------------------------------
;$3f:f6aa field::upload_window_content
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
field_upload_window_content:
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