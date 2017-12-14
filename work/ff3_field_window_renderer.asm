; encoding: utf-8
; ff3_field_window_renderer.asm
;
; description:
;	replaces field::draw_window_box($3f:ed02) related codes.
;	this file implements 'renderer'-like logics,
;	which renders window's content given by the callers by driving ppu.
;	these logics are originally placed around $f40a-$f700.

; version:
;	0.1.0
;==================================================================================================
ff3_field_window_renderer_begin:

;==================================================================================================
;; implementations for codes originally placed on $eefa - $f40a 'textd' will be found at "ff3_textd.asm"
;==================================================================================================

	.ifdef FAST_FIELD_WINDOW
	INIT_PATCH_EX field.window.renderer, $3f, $f40a, $f44b, textd.BULK_PATCH_FREE_BEGIN
	.ifndef _FEATURE_DEFERRED_RENDERING
;;# $3f:f40a field.set_vram_addr_for_window
;;### args:
;;+	[in] u8 $3a : x offset
;;+	[in] u8 $3b : y offset
;;
;;### callers:
;;`1F:F6B2:20 0A F4  JSR $F40A` @ $3f:f6aa field.upload_window_content
;;`1F:F6CE:20 0A F4  JSR $F40A` @ $3f:f6aa field.upload_window_content
;;`1F:F6E9:20 0A F4  JSR $F40A` @ $3f:f6aa field.upload_window_content
;;`1F:F705:20 0A F4  JSR $F40A` @ $3f:f6aa field.upload_window_content
;field.setVramAddrForWindow:	
field.set_vram_addr_for_window	;;$f40a
.offsetX = $3a
	ldy <.offsetX
;field.setVramAddrForWindowEx:
;[in] y : x offset
;[in] $3b : y offset
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
	.endif ;;_FEATURE_DEFERRED_RENDERING

;;field.get_vram_addr_of_line_above:
;;	DECLARE_WINDOW_VARIABLES
;;	ldx <.offset_y  ; F435 A6 3B
;;	dex             ; F437 CA
;;	bpl .positive   ; F438 10 02
;;	ldx <.offset_y  ; F43A A6 3B
;;.positive:
;;	lda <.offset_x  ; F43C A5 3A
;;	and #$1F        ; F43E 29 1F
;;	ora $F4A1,x     ; F440 1D A1 F4
;;	sta <$54        ; F443 85 54
;;	lda $F4C1,x     ; F445 BD C1 F4
;;	sta <$55        ; F448 85 55
;;	rts             ; F44A 60

	
field.window.renderer.FREE_BEGIN:
	VERIFY_PC_TO_PATCH_END field.window.renderer
	.endif	;;FAST_FIELD_WINDOW
;==================================================================================================
	.ifdef FAST_FIELD_WINDOW

	INIT_PATCH_EX menu.erase, $3f, $f44b, $f4a1, $f44b
menu.savefile.erase_window:
	DECLARE_WINDOW_VARIABLES
	lda #$02        ; F44B A9 02
	sta <.window_top         ; F44D 85 39
	sta <.offset_y         ; F44F 85 3B
	lda #$09        ; F451 A9 09
	sta <.window_left         ; F453 85 38
	lda #$16        ; F455 A9 16
	sta <.window_width         ; F457 85 3C
	lda #$04        ; F459 A9 04
	sta <.window_height         ; F45B 85 3D
	lda #$02        ; F45D A9 02
	bne menu.erase_box_from_bottom    ; F45F D0 19

	lda #$14 ; F461 A9 14
    bne menu.erase_box_of_width_1e ; F463 D0 02

menu.erase_box_1e_x_1c:
	DECLARE_WINDOW_VARIABLES
	lda #$1C        ; F465 A9 1C
	FALL_THROUGH_TO menu.erase_box_of_width_1e

menu.erase_box_of_width_1e:
	DECLARE_WINDOW_VARIABLES
	sta <.window_height         ; F467 85 3D
	lda #$1B        ; F469 A9 1B
	sta <.window_top         ; F46B 85 39
	sta <.offset_y         ; F46D 85 3B
	lda #$01        ; F46F A9 01
	sta <.window_left         ; F471 85 38
	lda #$1E        ; F473 A9 1E
	sta <.window_width         ; F475 85 3C
	lda <.window_height			; F477 A5 3D
	lsr a           ; F479 4A
	FALL_THROUGH_TO menu.erase_box_from_bottom

;; in:
;;	A: width
menu.erase_box_from_bottom:
	DECLARE_WINDOW_VARIABLES
	;pha
	ldx #(render_x.NO_BORDERS|render_x.PENDING_INIT|render_x.RENDER_RUNNING)
	jsr render_x.setup_deferred_rendering	;;preserves A.
	;jsr render_x.stack_and_setup
	;pla
.erase_loop:
	pha				; F47A 48
	lda <.window_width         ; F47B A5 3C
	sta <.output_index         ; F47D 85 90
	sta <.width_in_1st         ; F47F 85 91

;	ldy #$1D        ; F481 A0 1D
;	lda #$00        ; F483 A9 00
;.l_F485:
;		sta $0780,y     ; F485 99 80 07
;		sta $07A0,y     ; F488 99 A0 07
;		dey 			; F48B 88
;		bpl .l_F485     ; F48C 10 F7
	;;as `field.draw_window_content` fill up the buffer with default background,
	;;it is needed to fill up with '0' for each time.
	lda #0
	jsr field_x.fill_tile_buffer_with
	;; XXX:
	;;	with combined auto-rundown mechanics ('RENDER_RUNNING'), this:
	;;	1) causes crash on item window when swap or use performed
	jsr field.draw_window_content       ; F48E 20 92 F6
	
	lda <.offset_y         ; F491 A5 3B
	sec 			; F493 38
	sbc #$04        ; F494 E9 04
	sta <.offset_y         ; F496 85 3B
	pla 			; F498 68
	sec 			; F499 38
	sbc #$01        ; F49A E9 01
	;bne menu.erase_box_from_bottom     ; F49C D0 DC
	bne .erase_loop
	jsr render_x.finalize
	;jsr render_x.finalize_and_unstack
	jmp field.restore_banks  ; F49E 4C F5 EC

	VERIFY_PC_TO_PATCH_END menu.erase
	.endif	;;FAST_FIELD_WINDOW
;------------------------------------------------------------------------------------------------------
	.ifdef FAST_FIELD_WINDOW
	
	INIT_PATCH $3f,$f670,$f727

field_x.get_available_width_in_bg:
	DECLARE_WINDOW_VARIABLES
;.left = $38
;.width = $3c
	;; if window across BG boundary (left + width >= 0x20)
	;; then adjust the width to fit just enough to the BG
	lda <.window_left
	FALL_THROUGH_TO field_x.calc_available_width_in_bg
;; in
;;	A : box left
field_x.calc_available_width_in_bg
	DECLARE_WINDOW_VARIABLES
	and #$1f	;take mod of 0x20 to wrap around
	eor #$1f	;negate...
	clc			;
	adc #1		;...done. A = (0x20 - left) % 0x20
	cmp <.window_width
	bcc .store_result
		;; there is enough space to draw entirely
		lda <.window_width
.store_result:
	rts
	
;--------------------------------------------------------------------------------------------------
;;callers:
;;	1F:ECE9:20 70 F6  JSR field::calc_size_and_init_buff @ $3f:ece5 field::draw_window_top
;;	1F:EEDB:20 70 F6  JSR field::calc_size_and_init_buff @ $3f:eec0 field::draw_string_in_window
field.calc_draw_width_and_init_window_tile_buffer:
;; patch out callers {
	;FIX_ADDR_ON_CALLER $3f,$eedb+1
;; }
;;[in]
;.left = $38
;.width = $3c
.width_for_current_bg = $91
	jsr field_x.get_available_width_in_bg
.store_result:
	sta <.width_for_current_bg
	;; fall through into $3f:f683 field::init_window_tile_buffer
;--------------------------------------------------------------------------------------------------
;;$3f:f683 field::init_window_tile_buffer:
;;caller:
;;	$3f:f692 field.draw_window_content
field.init_window_tile_buffer:
;;[in]
;.tiles_1st = $0780
;.tiles_2nd = $07a0
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
field_x.fill_tile_buffer_with:
.tile_buffer = $0780
	;ldy #$1d
	ldy #$3d
.copy_loop:
		sta .tile_buffer,y
		;sta .tiles_2nd,y
		dey
		bpl .copy_loop
	clc
	rts
	;VERIFY_PC $f692
;--------------------------------------------------------------------------------------------------
	;INIT_PATCH $3f,$f692,$f6aa
;;$3f:f692 field::draw_window_content
;; [in]
;;	u8 a: rendering disposition.
;;	u8 $f0: frame_counter
;;	u8 $93: per8k bank
;;callers:
;;	1F:EEE9:20 92 F6  JSR field::draw_window_content @ $3f:eec0 field.draw_string_in_window
;;	1F:EF49:20 92 F6  JSR field::draw_window_content @ $3f:eefa textd.draw_in_box
;;	1F:EFDE:20 92 F6  JSR field::draw_window_content @ ? (sub routine of $eefa)
;;	1F:F48E:20 92 F6  JSR field::draw_window_content @ $3f:f47a menu.erase_box_from_bottom
field.draw_window_content:
;; patch out external callers {
	;FIX_ADDR_ON_CALLER $3f,$eee9+1
	;FIX_ADDR_ON_CALLER $3f,$ef49+1
	;FIX_ADDR_ON_CALLER $3f,$efde+1
	;FIX_ADDR_ON_CALLER $3f,$f48e+1
;;}
	DECLARE_WINDOW_VARIABLES
.output_index = $90
;; ---
	.ifndef _FEATURE_DEFERRED_RENDERING
	;.if 1

		pha
		jsr waitNmiBySetHandler	;ff00
		inc <field.frame_counter
		pla
		jsr field.upload_window_content	;f6aa
		jsr field_x.end_ppu_update	;sync_ppu_scroll+call_sound_driver
		jsr field_x.switch_to_text_bank
		jmp field.init_window_tile_buffer	;f683
	
	.else	;_FEATURE_DEFERRED_RENDERING
	
		;; 1. if required, capture attribute and write it into the buffer.
		;; 2. composite borders with content.
		;; 3. write the result into the buffer.
		;; 4. update number of available bytes to notify it of renderer.
		tax

		lda render_x.q.init_flags
		and #(render_x.RENDER_RUNNING)
		beq .oops

		lda <.lines_drawn
		pha
		txa
		pha
	.composite_top:
		lda render_x.q.init_flags
		;; mask off init-pending flag
		and #(~render_x.PENDING_INIT)
		sta render_x.q.init_flags
		bmi .composite_middle
			;; queue top border
			tax
			and #(render_x.NEED_TOP_BORDER)
			beq .composite_middle
				txa
				and #(~render_x.NEED_TOP_BORDER)
				sta render_x.q.init_flags
				jsr render_x.queue_top_border
	.composite_middle:
		pla	;; A <-- rendering disposition.
		cmp #TEXTD_WANT_ONLY_LOWER
		beq .lower_half
			lda #0
			jsr render_x.queue_content
	.lower_half:
		lda #$20
		jsr render_x.queue_content
	.composite_bottom:
		;; further optimizations could be achieved
		;; thru enabling the below line.
		;; however, the more asynchronous, the more timing issues.
		;; there indeed is a timing depedent glitches
		;; and some of callers which do scrolling are
		;; not ready for such a asynchronousity.
		jsr render_x.set_deferred_renderer
		;;
		ldy <.lines_drawn
		cpy <.window_height
		bne .update_queue_status
			ldx render_x.q.init_flags
			txa
			and #render_x.NEED_BOTTOM_BORDER
			beq .finalize_this_rendering
				;; queue bottom border
				dex
				stx render_x.q.init_flags
				jsr render_x.queue_bottom_border
		.finalize_this_rendering:
			jsr render_x.finalize	
	.update_queue_status:
		pla
		sta <.lines_drawn	;restore the original
		;; reset output index. callers rely on this to continue parse
		lda #0
		sta <.output_index	;;originally, 'field.upload_window_content's role

		jsr field_x.switch_to_text_bank
		jmp field.init_window_tile_buffer
	.oops:
		brk

;--------------------------------------------------------------------------------------------------
;in: A = offset Y, X = offset X
;out: A = vram high, X = vram low
field_x.map_coords_to_vram:
;@see $3f:f40a setVramAddrForWindow
.y_to_addr_low = $f4a1
.y_to_addr_high = $f4c1
	cmp #30
	bcc .no_wrap_y
		sbc #30	;here carry is always set	
	.no_wrap_y:
	tay
	txa
	and #$3f	;wrap around
	cmp #$20	;check which BG X falls in
	and #$1f	;turn into offset within that BG
	ora .y_to_addr_low,y
	tax
	lda .y_to_addr_high,y
	bcc .bg_1st
.bg_2nd:
		ora #4
.bg_1st:
	rts
;--------------------------------------------------------------------------------------------------
;render_x.init:
;	lda #0
;	sta render_x.q.init_flags
;	rts
;;make sure the init flag have 'clean' value before use
;;1F:E1DC:A9 00     LDA #$00
;;1F:E1DE:20 EC E7  JSR floor.load_data
;;1F:E1E1:A9 3A     LDA #$3A
render_x.on_floor_enter:
	FIX_ADDR_ON_CALLER $3f,$e1de+1
    ;a = #0;
    ;dungeon::loadFloor();   //$e7ec();
	;;assume A == 0
	sta render_x.q.init_flags
	jmp floor.load_data	;;$e7ec

;;1E:A534:A9 00     LDA #$00
;;1E:A536:85 25     STA $0025 = #$00
;;1E:A538:8D 01 20  STA PPU_MASK = #$00
;;1E:A53B:8D F0 79  STA $79F0 = #$00
;;1E:A53E:8D F0 7A  STA $7AF0 = #$00
;;1E:A541:20 06 DD  JSR $DD06
render_x.on_menu_enter:
	FIX_ADDR_ON_CALLER $3d,$a541+1
	;;assume A == 0
	sta render_x.q.init_flags
	jmp $dd06	;;? $dfd6() + call sounddriver + $dff8()

;;1F:C08E:A9 00     LDA #$00
;;1F:C090:20 9E C4  JSR $C49E
render_x.on_opening_enter:
	FIX_ADDR_ON_CALLER $3e,$c090+1
	;;assume A == 0
	sta render_x.q.init_flags
	jmp $C49E	;;some ppu initialiation

	.endif ;_FEATURE_DEFERRED_RENDERING
;--------------------------------------------------------------------------------------------------
	;VERIFY_PC $f6aa
	.endif	;FAST_FIELD_WINDOW
;--------------------------------------------------------------------------------------------------
	.ifndef _FEATURE_DEFERRED_RENDERING
	INIT_PATCH	$3f,$f6aa,$f727
	.endif	;ifndef FAST_FIELD_WINDOW
;$3f:f6aa field::upload_window_content
;//	[in] u8 $38 : offset x
;//	[in] u8 $39 : offset per 2 line
;//	[in,out] u8 $3b : offset y (wrap-around)
;; call tree:
;;	$eb43: ?
;;		$eec0: field.draw_string_in_window
;;			$eefa: textd.draw_in_box
;;				$f692: field.draw_window_content
;;	
;;	$ed02: field.draw_window_box
;;		$edc6: field.draw_window_row
;;callers:
;;	$3f:edc6 field.draw_window_row
;;	$3f:f692 field.draw_window_content
	;.ifndef OMIT_COMPATIBLE_FIELD_WINDOW
	.if 0
field.upload_window_content:
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
	cmp #TEXTD_WANT_ONLY_LOWER 
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

	jsr field.setVramAddrForWindowEx
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
	.endif	;ifndef _FEATURE_DEFERRED_RENDERING

	VERIFY_PC $f727
;======================================================================================================
	RESTORE_PC ff3_field_window_driver_begin