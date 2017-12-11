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
	INIT_PATCH_EX field.window.renderer, $3f, $f40a, $f435, textd.BULK_PATCH_FREE_BEGIN
	.ifndef DEFERRED_RENDERING
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

	.endif ;;DEFERRED_RENDERING
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
	ldx #(field_x.NO_BORDERS|field_x.PENDING_INIT|field_x.RENDER_RUNNING)
	jsr field_x.setup_deferred_rendering	;;preserves A.
	;jsr field_x.render.stack_and_setup
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
	jsr field_x.render.finalize
	;jsr field_x.render.finalize_and_unstack
	jmp field.restore_banks  ; F49E 4C F5 EC

	VERIFY_PC_TO_PATCH_END menu.erase
	.endif	;;FAST_FIELD_WINDOW
;------------------------------------------------------------------------------------------------------
	.ifdef FAST_FIELD_WINDOW
	
	INIT_PATCH $3f,$f670,$f727

field_x.calc_window_width_in_bg:
.left = $38
.width = $3c
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
	jsr field_x.calc_window_width_in_bg
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
	.ifndef DEFERRED_RENDERING
	;.if 1

		pha
		jsr waitNmiBySetHandler	;ff00
		inc <field.frame_counter
		pla
		jsr field.upload_window_content	;f6aa
		jsr field_x.end_ppu_update	;sync_ppu_scroll+call_sound_driver
		jsr field_x.switch_to_text_bank
		jmp field.init_window_tile_buffer	;f683
	
	.else	;DEFERRED_RENDERING
	
		;; 1. if required, capture attribute and write it into the buffer.
		;; 2. composite borders with content.
		;; 3. write the result into the buffer.
		;; 4. update number of available bytes to notify it of renderer.
		tax

		lda field_x.render.init_flags
		and #(field_x.RENDER_RUNNING)
		beq .oops

		lda <.lines_drawn
		pha
		txa
		pha
	.composite_top:
		lda field_x.render.init_flags
		;; mask off init-pending flag
		and #(~field_x.PENDING_INIT)
		sta field_x.render.init_flags
		bmi .composite_middle
			;; queue top border
			tax
			and #(field_x.NEED_TOP_BORDER)
			beq .composite_middle
				txa
				and #(~field_x.NEED_TOP_BORDER)
				sta field_x.render.init_flags
				jsr field_x.queue_top_border
	.composite_middle:
		pla	;; A <-- rendering disposition.
		cmp #TEXTD_WANT_ONLY_LOWER
		beq .lower_half
			lda #0
			jsr field_x.queue_content
	.lower_half:
		lda #$20
		jsr field_x.queue_content
	.composite_bottom:
		;; further optimizations could be achieved
		;; thru enabling the below line.
		;; however, the more asynchronous, the more timing issues.
		;; there indeed is a timing depedent glitches
		;; and some of callers which do scrolling are
		;; not ready for such a asynchronousity.
		;jsr field_x.set_deferred_renderer
		;;
		ldy <.lines_drawn
		cpy <.window_height
		bne .update_queue_status
			ldx field_x.render.init_flags
			txa
			and #field_x.NEED_BOTTOM_BORDER
			beq .finalize_this_rendering
				;; queue bottom border
				dex
				stx field_x.render.init_flags
				jsr field_x.queue_bottom_border
		.finalize_this_rendering:
			jsr field_x.render.finalize	
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
field_x.ensure_buffer_available:
	DECLARE_WINDOW_VARIABLES
	jsr field_x.remove_nmi_handler
	lda field_x.render.available_bytes
	clc
	adc field_x.render.stride
	cmp #field_x.BUFFER_CAPACITY
	bcs field_x.await_complete_rendering

	lda field_x.render.addr_index
	cmp #field_x.ADDR_CAPACITY	;;rendering up to X lines at once (or exceed the nmi duration)
	bcc field_x.render.rts_1

field_x.await_complete_rendering:
		jsr field_x.set_deferred_renderer
.wait_nmi:
		lda field_x.render.available_bytes
		bne .wait_nmi

field_x.render.rts_1:
	rts
	.endif ;DEFERRED_RENDERING
;--------------------------------------------------------------------------------------------------
	;VERIFY_PC $f6aa
	.endif	;FAST_FIELD_WINDOW
;--------------------------------------------------------------------------------------------------
	.ifndef DEFERRED_RENDERING
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
	.endif	;ifndef DEFERRED_RENDERING

	VERIFY_PC $f727
;======================================================================================================
	RESTORE_PC ff3_field_window_begin