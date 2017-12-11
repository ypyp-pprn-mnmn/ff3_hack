; encoding: utf-8
;   ff3_field_x_window_renderer.asm
;
; description:
;   implementation of optimzied renderer code
;
;==================================================================================================
    .ifdef FAST_FIELD_WINDOW

    .ifndef textd.BULK_PATCH_FREE_BEGIN
        .fail
    .endif
    RESTORE_PC textd.BULK_PATCH_FREE_BEGIN

field_x.RENDERER_BEGIN:
;--------------------------------------------------------------------------------------------------
field_x.deferred_renderer:
.addr_index = $83
	pha
	txa
	pha
	tya
	pha

	lda $2002	;dummy read to ensure unset nmi flag 
	inc <field.frame_counter
	;; do rendering.
	lda #0
	sta <.addr_index
	jsr field_x.render_deferred_contents
	;;
	jsr field_x.end_ppu_update	;sync_ppu_scroll+call_sound_driver
	jsr field_x.remove_nmi_handler

	jsr field.restore_banks

	pla
	tay
	pla
	tax
	pla
	rti

field_x.render_deferred_contents:
	DECLARE_WINDOW_VARIABLES
.eol_offset = $82
.p_jump = $84
.addr_index = $83
	pha
	ldy <.addr_index
	lda field_x.render.vram.high,y
	sta $2006
	lda field_x.render.vram.low,y
	sta $2006
	inc <.addr_index
	pla
	pha
	clc
;	adc <.window_width
	adc field_x.render.stride
;	bit field_x.render.init_flags
;	bmi .skip_borders
;		clc
;		adc #($2)
;.skip_borders:
	clc
	adc #($10)
	sta <.eol_offset
	pla
	pha
	clc
	adc field_x.render.buffer_bias
	tax
	jmp [field_x.render.uploader_addr]

field_x.render.upload_next:
	DECLARE_WINDOW_VARIABLES
	pla
;	bit field_x.render.init_flags
;	bmi .skip_borders
;	clc
;	adc #$2
;.skip_borders:
	clc
;	adc <.window_width
	adc field_x.render.stride
	;cpx field_x.render.available_bytes
	cmp field_x.render.available_bytes
	bcc field_x.render_deferred_contents

	lda #0
	sta field_x.render.addr_index
	sta field_x.render.available_bytes	;;this frees up a waiting thread
	rts

field_x.render.upload_loop:
.eol_offset = $82
.p_jump = $84
	lda field_x.render.tile_buffer-$10,x
	sta $2007
	lda field_x.render.tile_buffer-$0f,x
	sta $2007
	lda field_x.render.tile_buffer-$0e,x
	sta $2007
	lda field_x.render.tile_buffer-$0d,x
	sta $2007
	lda field_x.render.tile_buffer-$0c,x
	sta $2007
	lda field_x.render.tile_buffer-$0b,x
	sta $2007
	lda field_x.render.tile_buffer-$0a,x
	sta $2007
	lda field_x.render.tile_buffer-$09,x
	sta $2007
	lda field_x.render.tile_buffer-$08,x
	sta $2007
	lda field_x.render.tile_buffer-$07,x
	sta $2007
	lda field_x.render.tile_buffer-$06,x
	sta $2007
	lda field_x.render.tile_buffer-$05,x
	sta $2007
	lda field_x.render.tile_buffer-$04,x
	sta $2007
	lda field_x.render.tile_buffer-$03,x
	sta $2007
	lda field_x.render.tile_buffer-$02,x
	sta $2007
	lda field_x.render.tile_buffer-$01,x
	sta $2007

	txa
	clc
	adc #$10
	tax
	cpx <.eol_offset
	bne field_x.render.upload_loop
	beq field_x.render.upload_next
;--------------------------------------------------------------------------------------------------
field_x.begin_queueing:
;; --- check if there enough space remaining in the buffer.
	jsr field_x.ensure_buffer_available
;; --- attr check.
	jsr field_x.queue_attributes
;; --- queue the addr to render.
	jmp field_x.queue_vram_addr	

field_x.queue_vram_addr:
	DECLARE_WINDOW_VARIABLES
	;lda field_x.render.next_line
	lda <.offset_y
	ldx <.window_left
	bit field_x.render.init_flags
	bmi .skip_borders
		dex
.skip_borders
	jsr field_x.map_coords_to_vram
	ldy field_x.render.addr_index
	sta field_x.render.vram.high,y
	txa
	sta field_x.render.vram.low,y
	;sta $2006
	;stx $2006
	;inc field_x.render.next_line
	inc field_x.render.addr_index
	rts

field_x.queue_top_border:
	DECLARE_WINDOW_VARIABLES
	ldy <.window_top
	dey
	tya
	ldx #2
	jsr field_x.queue_border
	ldy <.window_top
	sty <.offset_y
	rts

field_x.queue_bottom_border:
	DECLARE_WINDOW_VARIABLES
	lda <.window_top
	clc
	adc <.window_height
	ldx #8
	FALL_THROUGH_TO field_x.queue_border

field_x.queue_border:
	DECLARE_WINDOW_VARIABLES
	sta <.offset_y
.put_borders:
	ldy #3
.get_parts:
		lda field_x.window_parts,x
		pha
		dex
		dey
		bne .get_parts

	jsr field_x.begin_queueing
;; --- queue tiles.
	
	ldx field_x.render.available_bytes
	pla
	jsr field_x.queue_byte

	pla
	ldy <.window_width
.put_middles:
		jsr field_x.queue_byte
		dey
		bne .put_middles
	pla
	;jmp field_x.queue_byte
	FALL_THROUGH_TO field_x.queue_byte

field_x.queue_byte:
	sta field_x.render.tile_buffer,x
	inx
	stx field_x.render.available_bytes
	;inc field_x.render.available_bytes
field_x.render.rts_2:
	rts

field_x.queue_content:
	DECLARE_WINDOW_VARIABLES
.p_source = $80		;; nmi handler potentially modify this
	pha
	jsr field_x.begin_queueing

	pla
	clc
	adc #$80
	sta <.p_source
	lda #$07
	sta <.p_source+1
;; --- 
	inc <.offset_y	;;originally 'field.upload_window_content's role
	inc <.lines_drawn	;;originally caller's responsibility, it remains true but for bottom border we need prospective value
;; --- queue tiles.
	ldx field_x.render.available_bytes


	ldy #0
	bit field_x.render.init_flags
	php
	bmi .put_middles
		lda #$fa
		jsr field_x.queue_byte

.put_middles:
		lda [.p_source],y
		jsr field_x.queue_byte
		iny
		cpy <.window_width
		bne .put_middles


	plp
	bmi field_x.render.rts_2
		lda #$fb
		jmp field_x.queue_byte

;; on entry, offset_y will have valid value.
field_x.queue_attributes:
	DECLARE_WINDOW_VARIABLES
	lda <.in_menu_mode
	bne .done
		;; in-place window. need attr updates
		lda <.offset_y
		lsr A
		bcs .done
			;; only update attr if the line on even boundary
			jsr field.init_window_attr_buffer	;ed56
			jsr field.update_window_attr_buff	;$c98f
			;field.bg_attr_table_cache
.done:
	rts
;--------------------------------------------------------------------------------------------------
;field_x.render.init:
;	lda #0
;	sta field_x.render.init_flags
;	rts
;;make sure the init flag have 'clean' value before use
;;1F:E1DC:A9 00     LDA #$00
;;1F:E1DE:20 EC E7  JSR floor.load_data
;;1F:E1E1:A9 3A     LDA #$3A
field_x.render.on_floor_enter:
	FIX_ADDR_ON_CALLER $3f,$e1de+1
    ;a = #0;
    ;dungeon::loadFloor();   //$e7ec();
	;;assume A == 0
	sta field_x.render.init_flags
	jmp floor.load_data	;;$e7ec

;;1E:A534:A9 00     LDA #$00
;;1E:A536:85 25     STA $0025 = #$00
;;1E:A538:8D 01 20  STA PPU_MASK = #$00
;;1E:A53B:8D F0 79  STA $79F0 = #$00
;;1E:A53E:8D F0 7A  STA $7AF0 = #$00
;;1E:A541:20 06 DD  JSR $DD06
field_x.render.on_menu_enter:
	FIX_ADDR_ON_CALLER $3d,$a541+1
	;;assume A == 0
	sta field_x.render.init_flags
	jmp $dd06	;;? $dfd6() + call sounddriver + $dff8()

;;1F:C08E:A9 00     LDA #$00
;;1F:C090:20 9E C4  JSR $C49E
field_x.render.on_opening_enter:
	FIX_ADDR_ON_CALLER $3e,$c090+1
	;;assume A == 0
	sta field_x.render.init_flags
	jmp $C49E	;;some ppu initialiation

;--------------------------------------------------------------------------------------------------
field_x.render.finalize:
	lda field_x.render.available_bytes
	beq .completed
		jsr field_x.await_complete_rendering
.completed:
	;; XXX:
	;;  in cases of paging in window,
	;;	the rendering continues even if it reached the bottom of window.
	;lda #0
	;sta field_x.render.init_flags
	rts
;--------------------------------------------------------------------------------------------------
;; in X: init flags
field_x.setup_deferred_rendering:
	DECLARE_WINDOW_VARIABLES
.p_jump = $80
;; init deferred drawing.
	pha
	;bit field_x.render.init_flags
	lda field_x.render.init_flags
	asl A
	bmi	.done	;; already requested init

	asl A
	bpl .store_init_flags
		;jsr field_x.render.finalize
	;txa
	;ldx <.in_menu_mode
	;bne .store_init_flags
	;	ora #(field_x.NEED_SPRITE_DMA)
.store_init_flags:
	stx field_x.render.init_flags

	lda <.window_width
	pha
	tax
	bit field_x.render.init_flags
	bmi .no_borders
		inx
		inx
.no_borders:
	stx <.window_width
	stx field_x.render.stride
	jsr field_x.calc_window_width_in_bg
	sta field_x.render.width_1st
;;
	lda <.window_width
	pha
	clc
	and #$f
	bne .align
		ora #$10
.align:
	sta field_x.render.buffer_bias
	pla
	eor #$0f
	clc
	adc #1
	and #$0f
	;sta <.p_jump
	;tax
	;lda <.p_jump
	;asl A
	;clc
	;adc <.p_jump
	;asl A
	asl A
	sta <.p_jump	;;x2
	asl A
	adc <.p_jump	;;x2+x4
	adc #LOW(field_x.render.upload_loop)
	sta field_x.render.uploader_addr
	lda #0
	sta field_x.render.available_bytes
	sta field_x.render.addr_index
	adc #HIGH(field_x.render.upload_loop)
	sta field_x.render.uploader_addr+1

	pla
	sta <.window_width
.done:
	pla
	rts
;--------------------------------------------------------------------------------------------------
field_x.remove_nmi_handler:
	lda #$40	;RTI
	sta nmi_handler_entry
	rts

field_x.set_deferred_renderer:
	jsr field_x.remove_nmi_handler
	lda #HIGH(field_x.deferred_renderer)
	sta nmi_handler_entry+2
	lda #LOW(field_x.deferred_renderer)
	sta nmi_handler_entry+1
	lda #$4c	;JMP
	sta nmi_handler_entry
	rts

;==================================================================================================
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

field_x.fill_to_bottom.loop:
.lines_drawn = $1f
.window_height = $3d
	ldx #TEXTD_WANT_ONLY_LOWER
	lsr A
	beq .do_half
		ldx #0
.do_half:
	txa
	FALL_THROUGH_TO field_x.fill_to_bottom

field_x.fill_to_bottom:
.lines_drawn = $1f
.window_height = $3d
.p_text = $3e
	pha
	jsr field.draw_window_content
	pla
	tax
	;; checks if this call is made on the text end
	ldy #0
	lda [.p_text],y
	bne .done

	inc <.lines_drawn
	cpx #TEXTD_WANT_ONLY_LOWER
	;cmp #TEXTD_WANT_ONLY_LOWER
	beq .test_end
		inc <.lines_drawn
.test_end:
	lda <.window_height
	sec
	sbc <.lines_drawn
	bne field_x.fill_to_bottom.loop
.done:
	rts

;==================================================================================================
	.if 0
field_x.update_ppu_attr_table:
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
	jsr .field_x.upload_attributes
	ldy #$27
.field_x.upload_attributes:
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

field_x.switch_vram_addr_mode:
	pha
	lda <field.ppu_ctrl_cache
	and #%11111011
	sta <field.ppu_ctrl_cache
	pla
	and #%00000100
	ora <field.ppu_ctrl_cache
	sta <field.ppu_ctrl_cache
	sta $2000
	rts
	.endif
;==================================================================================================
	.if 0
	lda <.in_menu_mode
	bne .post_attr_update
		jsr field.init_window_attr_buffer	;ed56
		lda <.height
		pha
		ldy <.beginY
.setupAttributes:
		sty <.currentY
		jsr field.update_window_attr_buff	;$c98f
		ldy <.currentY
		iny
		;; field.updateTileAttrCache() isn't prepared for cases that window crosses vertical boundary (which is at 0x1e)
		;; that is, if currentY > 0x1e, updated attributes are placed 1 row above where it should be in.
		;; so here handles as a wrokaround wrapping vertical coordinates.
		cpy #30	;; wrap around
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
		jsr field_x.begin_ppu_update	;wait_nmi+do_dma. if omitted dma, sprites are shown on top of window
		jsr field_x.update_ppu_attr_table
		jsr field_x.end_ppu_update	;sync_ppu_scroll+call_sound_driver
	.endif ;0
;==================================================================================================
    VERIFY_PC_TO_PATCH_END textd
field_x.RENDERER_END:
    .endif  ;FAST_FIELD_WINDOW