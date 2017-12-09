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

;;$f388
field_x.render_borders:

field_x.generate_uploder_code:
	;; ------------------------------------------------------------------------
	;; generate code to upload vram.
field_x.store_PPUDATA = $f7b0
.generated_code_base = $0780
.SIZE_OF_CODE = 3
.UNROLLED_BYTES = $1c*.SIZE_OF_CODE	;;maximum mid-part length == 1c.
	ldy #-.UNROLLED_BYTES	;dest
.wrap_x:
		ldx #-.SIZE_OF_CODE	;src
.generate_loop:
		;lda .template_code_start-$0100+.SIZE_OF_CODE,x
		lda (field_x.store_PPUDATA)-$0100+.SIZE_OF_CODE,x
		sta (2+.generated_code_base)-($0100-.UNROLLED_BYTES),y
		iny
		beq .generate_epilog
		inx
		beq .wrap_x
		bne .generate_loop
.generate_epilog:
	lda #$60	;rts
	sta (2+.generated_code_base)+.UNROLLED_BYTES
	lda #$D0	;bne
	sta (.generated_code_base)
	FALL_THROUGH_TO field_x.setup_paramters

field_x.setup_paramters:
.generated_code_base = $0780
.uploader_offset = $07e0
.vram_addr.low = $07d8
.vram_addr.high = $07e8
.first_corner_parts = $07f0
.second_corner_parts = $07f8
.render_sequence = $85
.width_temp = $80
.height_temp = $81
.right_x = $82
.bottom_y = $83
;---
.in_menu_mode = $37
.left = $38
.top = $39
.offset_x = $3a
.offset_y = $3b
.width = $3c
.height = $3d
;---
	ldx #7
.init_struct:
		lda .default_first_corners,x
		sta .first_corner_parts,x
		lda .default_second_corners,x
		sta .second_corner_parts,x
		;lda <.left
		;sta .vram_addr.low,x
		;lda <.top
		;sta .vram_addr.high,x
		dex
		bpl .init_struct

	;;required addresses:
	;;(left, top), (left+width_1st, top),
	;;(left, top+height-1), (left+width_1st, top+height-1)
	;;(left, top+1), (left, 0 //top+1+height_1st)
	;;(left+width-1, top+1), (left+width-1, 0 //top+1+height_1st)
	;; 0-2-1-3-4-5-6-7
;; --- calc widths
	jsr field_x.calc_window_width_in_bg
	tay	;;temp save

	;; 0, 2, 4, 5 <- left
	;; 1, 3 <- left + width_1st
	;; 6, 7 <- left + width - 1

	sta <.width_temp
	lda <.left
	pha	;.vram_addr.low+0
	pha ;.vram_addr.low+2

	clc
	adc <.width_temp
	pha ;.vram_addr.low+1
	pha ;.vram_addr.low+3

	lda <.left
	pha	;.vram_addr.low+4
	pha ;.vram_addr.low+5

	clc
	adc <.width	
	sbc #0	;; here carry is always cleared, as left+width will never overflow
	pha	;.vram_addr.low+6
	pha	;.vram_addr.low+7

	tya	;; A <- Y: width in 1st.
	eor #$ff
	sec
	adc <.width
	;; A = width in 2nd.
	ldy #0
	tax	;; X <- width in 2nd.
	beq .store_x_mid_length
		;;required 2nd bg rendering.
		sty .second_corner_parts
		sty .second_corner_parts+1
		inc <.width_temp
.store_x_mid_length:
	;;Y <- width in 1st
	ldy <.width_temp
	dey
	dey	;; Y <- width in 1st, excluding both corners.
	dex	;; X <- width in 2nd, excluding 2nd corner.

	tya
	pha	;.uploader_offset+0
	pha	;.uploader_offset+2

	txa
	pha	;.uploader_offset+1
	pha	;.uploader_offset+3

;; --- calc heights.
;; heights ignore top/bottom border.
.calc_heights:
	ldy <.height
	dey
	tya ;; A <- Y: height, excluding top corner.
	dey	;; Y <- overall height, excluding both corners.
	clc
	adc <.top
	sta <.height_temp	;;<- bottom = (top + height -1)
	cmp #30
	tya	;;A <- Y: height
	bcc .no_wrap_y
		lda #29	;;as crossed the boundary, bottom corner must not be excluded
		;;carry is always set
		sbc <.top
.no_wrap_y:
	;;A = height in 1st bg (excluding both corners)
	pha	;.uploader_offset+4
	tay ;;Y <- A: height in 1st bg

	eor #$ff
	sec
	adc <.height
	sec	
	sbc #2	;border excl (the height includes both border)
	;;A = height in 2nd bg (excluding both corners)
	pha	;.uploader_offset+5
	tax	;; X <- A:height in 2nd bg
	tya	;; A <- Y:height in 1st bg
	pha ;.uploader_offset+6
	txa	;; A <- X:height in 2nd bg
	pha	;.uploader_offset+7

;	beq .init_offsets
;		sty .second_corner_parts+4
;		sty .second_corner_parts+6
	lda <.top
	pha	;.vram_addr.high+0
	tay ;;Y <- A: top
	;;A = (top + height - 1)
	lda <.height_temp
	cmp #30
	bcc .bottom_not_wrapped
		;;carry is always set
		sbc #30
.bottom_not_wrapped:
	;;A = bottom = (top + height) % 30
	pha	;.vram_addr.high+2
	tax
	tya
	pha ;vram_addr.high+1
	txa
	pha	;.vram_addr.high+3

	ldy <.top
	iny
	tya
	pha ; .vram_addr.high+4

	ldx #0
	txa
	pha ;.vram_addr.high+5

	tya
	pha ; .vram_addr.high+6

	txa
	pha ;.vram_addr.high+7
	
	ldy #$17
.pull_stack:
		pla
		sta .vram_addr.low,y
		dey
		bpl .pull_stack

;; here these tuples have:
;; vram.high = Y, vram.low = X, uploader_offset = length
	ldy #7
.map_raw_values:
		sty <.render_sequence
		;; map length into the offset into generater code.
		lda .uploader_offset,y
		bmi .continue
			eor #$ff
			sec
			adc #$1c
			sta <.width_temp
			asl A
			adc <.width_temp
			sta .uploader_offset,y
			;; map x,y coordinates into vram address.
			ldx .vram_addr.low,y
			lda .vram_addr.high,y
			jsr field_x.map_coords_to_vram
			ldy <.render_sequence
			sta .vram_addr.high,y
			txa
			sta .vram_addr.low,y
	.continue:
		dey
		bpl .map_raw_values

.start_rendering:
	jsr field_x.begin_ppu_update
		lda #%00000100
		jsr field_x.render_loop
		lda #%00000000
		jsr field_x.render_loop
	jmp field_x.end_ppu_update
;; 1: left-top, horz;
;; 2: left-bottom horz;
;; 3: right-top horz; skipped if border completed within 1st bg
;; 4: right-bottom horz; skipped if border completed within 1st bg
;; 5: left-top, vert;
;; 6: left-bottom, vert; skipped if border not across screen boundary
;; 7: right-top, vert;
;; 8: right-bottom, vert; skipped if border not across screen boundary
.default_first_corners:
	;.db $f7,$00,$fc,$00,$f7,$00,$f9,$00
	.db $f7,$fc,$00,$00,$00,$00,$00,$00
.default_second_corners:
	;.db $f9,$f9,$fe,$fe,$fc,$fc,$fe,$fe
	.db $f9,$fe,$f9,$fe,$00,$00,$00,$00
field_x.middle_parts:
	.db $f8,$fd,$f8,$fd,$fa,$fa,$fb,$fb

field_x.render_loop:
	pha
	ldy #4
.render_loop:
		jsr field_x.do_render_border	
		dey
		bne .render_loop
	
	pla
	jmp field_x.switch_vram_addr_mode

;; ------------------------------------------------------------------------
;; draw strategy:
;; split up border parts into 8 individual sections:
;;	1: horizontal, left-top, always on 1st bg
;;	3: horizontal, left-botttom, always on 1st bg
;;	needed if the window span across the bg boundary:
;;	2: horizontal, right-top, either on 1st bg or on 2nd bg
;;	4: horizontal, right-bottom, either on 1st bg or on 2nd bg
;;	--- switch vram addr mode to vertical
;;	5: vertical, left-top, always on 1st bg
;;	7: vertical, right-top, either on 1st bg or on 2nd bg
;;	needed if the window span across the bg boundary:
;;	6: vertical, left-bottom, always on 1st bg, maybe wrapped around from bottom to top
;;	8: vertical, right-bottom, either on 1st bg or on 2nd bg, maybe wrapped around.
;; required information to draw each parts:
;;	{
;;		u16 vram_address:15,
;;		u16 skip_rendering:1,
;;		u8 uploader_offset (3 x length of mid-parts),
;;		u8 first_corner_parts,
;;		u8 second_corner_parts,
;;		u8 middle_parts,	//static
;;	}
field_x.do_render_border:
.generated_code_base = $0780
.uploader_offset = $07e0
.vram_addr.low = $07d8
.vram_addr.high = $07e8
.first_corner_parts = $07f0
.second_corner_parts = $07f8
.render_sequence = $85
	ldx <.render_sequence
	lda .uploader_offset,x
	sta .generated_code_base+1
	;;if no rendering to be happen in this address,
	;;offset won't have real offset but the negative length value
	;;indicating there is nothing to render.
	bmi .render_end
		;; setup vram addr.
		lda .vram_addr.high,x
		sta $2006
		lda .vram_addr.low,x
		sta $2006
		;; upload name table values.
		lda .first_corner_parts,x
		beq .render_middle
			sta $2007
	.render_middle:
		lda field_x.middle_parts,x
		jsr .generated_code_base
	.render_second_corner:
		lda .second_corner_parts,x	
		beq .render_end
			sta $2007
.render_end:
	inc <.render_sequence
	rts

	.endif ;0

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