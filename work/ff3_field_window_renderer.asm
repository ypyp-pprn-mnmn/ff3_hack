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

	.ifdef _OPTIMIZE_FIELD_WINDOW
	INIT_PATCH_EX field.window.ppu, $3f, $f40a, $f44b, textd.BULK_PATCH_FREE_BEGIN

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
field.set_vram_addr_current_xy	;;$f40a
.offsetX = $3a
	ldy <.offsetX
field_x.set_vram_addr_current_y_with_specified_x
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

	
field.window.ppu.FREE_BEGIN:
	VERIFY_PC_TO_PATCH_END field.window.ppu
	.endif	;;_OPTIMIZE_FIELD_WINDOW
;==================================================================================================
	.ifdef _OPTIMIZE_FIELD_WINDOW

	;INIT_PATCH_EX menu.erase, $3f, $f44b, $f4a1, $f44b
	INIT_PATCH_EX menu.erase, $3f, $f44b, $f4a1, field.window.ppu.FREE_BEGIN
;; 1E:AA8E:20 4B F4  JSR $F44B
menu.savefile.erase_window:	;;F44B
	FIX_ADDR_ON_CALLER $3d,$aa8e+1
;;
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
;--------------------------------------------------------------------------------------------------
;; 1E:AF76:20 61 F4  JSR $F461
menu.erase_box_1e_x_14:
	FIX_ADDR_ON_CALLER $3d,$af76+1
;;
	lda #$14 ; F461 A9 14
    bne menu.erase_box_of_width_1e ; F463 D0 02
;--------------------------------------------------------------------------------------------------
;; 1E:A693:4C 65 F4  JMP $F465
menu.erase_box_1e_x_1c:
	FIX_ADDR_ON_CALLER $3d,$a693+1
;;
	DECLARE_WINDOW_VARIABLES
	lda #$1C        ; F465 A9 1C
	FALL_THROUGH_TO menu.erase_box_of_width_1e
;--------------------------------------------------------------------------------------------------
;; 1E:9BD2:20 67 F4  JSR $F467
menu.erase_box_of_width_1e:
	FIX_ADDR_ON_CALLER $3c,$9bd2+1
;;
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
;--------------------------------------------------------------------------------------------------
;; in:
;;	A: width
menu.erase_box_from_bottom:
	DECLARE_WINDOW_VARIABLES
	.ifdef _FEATURE_DEFERRED_RENDERING
		ldx #(render_x.NO_BORDERS|render_x.PENDING_INIT|render_x.RENDER_RUNNING)
		jsr render_x.setup_deferred_rendering	;;this function preserves A.
	.endif
	
.erase_loop:
	pha							; F47A 48
	lda <.window_width      	; F47B A5 3C
	sta <.output_index      	; F47D 85 90
	sta <.width_in_1st      	; F47F 85 91

;	ldy #$1D        			; F481 A0 1D
;	lda #$00        			; F483 A9 00
;.l_F485:
;		sta $0780,y     		; F485 99 80 07
;		sta $07A0,y     		; F488 99 A0 07
;		dey 					; F48B 88
;		bpl .l_F485     		; F48C 10 F7
	;;as `field.draw_window_content` fill up the buffer with default background,
	;;it is needed to fill up with '0' for each time.
	lda #0
	jsr field_x.fill_tile_buffer_with

	jsr field.draw_window_content	; F48E 20 92 F6
	
	lda <.offset_y				; F491 A5 3B
	sec 						; F493 38
	sbc #$04        			; F494 E9 04
	sta <.offset_y         		; F496 85 3B
	pla 						; F498 68
	sec 						; F499 38
	sbc #$01        			; F49A E9 01
	;bne menu.erase_box_from_bottom     ; F49C D0 DC
	bne .erase_loop
	.ifdef _FEATURE_DEFERRED_RENDERING
		jsr render_x.finalize
	.endif
	jmp field.restore_banks  ; F49E 4C F5 EC

	VERIFY_PC_TO_PATCH_END menu.erase
menu.erase.FREE_BEGIN:

	.endif	;;_OPTIMIZE_FIELD_WINDOW
;==================================================================================================
	.ifdef _OPTIMIZE_FIELD_WINDOW
	
	INIT_PATCH_EX field.window.renderer,$3f,$f670,$f727,$f670

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
render_x.calc_available_width_in_bg
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
		cmp #textd.WANT_ONLY_LOWER
		beq .lower_half
			lda #0
			jsr render_x.queue_content
	.lower_half:
		lda #$20
		jsr render_x.queue_content
	.composite_bottom:
		;; note:
		;;	on next nmi the handler will be executed in somewhere
		;;	in another function sit on top of this function,
		;;	at arbitrary context. 
		;;	therefore the handler never could safely destory
		;;	any values neither in regsiters nor memory.
		;;	this also implies the following restrictions apply to all of the callers:
		;;	1) if a caller removes the handler,
		;;	then rest of contents pending rendering will be discarded.
		;;	2) if a caller re-initilizes the queue this function utilizes,
		;;	before the handler executed, then the handler will see
		;;	unintentional re-init'd values and probably result in system crash.
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
	.endif	;;_FEATURE_DEFERRED_RENDERING

;--------------------------------------------------------------------------------------------------
	.ifdef _FEATURE_DEFERRED_RENDERING
render_x.fill_to_bottom.loop:
.lines_drawn = $1f
.window_height = $3d
	ldx #textd.WANT_ONLY_LOWER
	lsr A
	beq .do_half
		ldx #0
.do_half:
	txa
	FALL_THROUGH_TO render_x.fill_to_bottom

render_x.fill_to_bottom:
.lines_drawn = $1f
.window_height = $3d
.p_text = $3e
	pha
	jsr field.draw_window_content
	pla
	tax
	;; XXX:
	;;	there no need to check the text end since
	;;	this call is made only under situations that is
	;;	safe and right to fill up to the bottom of window.
	;;	there are cases even if the text hasn't been read thru the end
	;;	but still need to fill, namely cases that
	;;	the following charcodes aborts processing due to empty item:
	;;		CHARCODE.ITEM_NAME_IN_SHOP (0x19)
	;;		CHARCODE.JOB_NAME (0x1e)
	;; ---------
	;; checks if this call is made on the text end
	;ldy #0
	;lda [.p_text],y
	;bne .done

	inc <.lines_drawn
	cpx #textd.WANT_ONLY_LOWER
	beq .test_end
		inc <.lines_drawn
.test_end:
	lda <.window_height
	sec
	sbc <.lines_drawn
	bne render_x.fill_to_bottom.loop
.done:
	rts
	.endif	;;_FEATURE_DEFERRED_RENDERING
;--------------------------------------------------------------------------------------------------
	;VERIFY_PC $f6aa
;--------------------------------------------------------------------------------------------------
	.ifndef _FEATURE_DEFERRED_RENDERING
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
field.upload_window_content:
	DECLARE_WINDOW_VARIABLES
	cmp #textd.WANT_ONLY_LOWER 
	beq .draw_lower_line
		lda #0
		jsr .draw_line
.draw_lower_line:
	lda #$20
.draw_line:
;[in] a  = index offset
	pha
	sta <.offset_x

	bit $2002
	lda <.width_in_1st
	ldy <.window_left
	jsr field_x.upload_tiles	;[out] y = offsetX & #20 ^ #20, $3a = offsetString

	clc
	pla
	adc <.window_width
	sec
	sbc <.offset_x
	bcc .next_line
	beq .next_line
		jsr field_x.upload_tiles

.next_line:
	ldy <.offset_y
	iny
	cpy #30
	bne .no_wrap
		ldy #0
.no_wrap:
	sty <.offset_y
	lda #0
	sta <.output_index
	rts

;; in:
;;	Y : vram high
field_x.upload_tiles:
	DECLARE_WINDOW_VARIABLES
	pha
	jsr field_x.set_vram_addr_current_y_with_specified_x
;.beginOffset = .offsetString
;.endOffset = .beginOffset
	pla	;widthInCurrentBg
	ldx <.offset_x
	pha
	clc
	adc <.offset_x
	sta <.offset_x
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
	lda .tile_buffer_upper,x
	sta $2007
	inx
.copy_loop_3:
	lda .tile_buffer_upper,x
	sta $2007
	inx
.copy_loop_2:
	lda .tile_buffer_upper,x
	sta $2007
	inx
.copy_loop_1:
	lda .tile_buffer_upper,x
	sta $2007
	inx
	
	cpx <.offset_x
	bne .copy_loop_0

	rts
	.endif	;;ifndef _FEATURE_DEFERRED_RENDERING

	;VERIFY_PC $f727
	VERIFY_PC_TO_PATCH_END field.window.renderer
;--------------------------------------------------------------------------------------------------
	.endif	;;_OPTIMIZE_FIELD_WINDOW
;======================================================================================================
	RESTORE_PC ff3_field_window_driver_begin