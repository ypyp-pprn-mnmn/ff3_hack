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

field_x.render_borders:
.in_menu_mode = $37
.left = $38
.top = $39
.offset_x = $3a
;.draw_info_index = $3a
.offset_y = $3b
.width = $3c
.height = $3d
.generated_code_base = $0780
.first_corner_parts = $07e0
.second_corner_parts = $07e8
;.middle_parts = $07f0
.widths = $80
.heights = $82
.code_offset = $84
.render_sequence = $85
	;; ------------------------------------------------------------------------
	;; generate code to upload vram.
field_x.store_PPUDATA = $f7b0
.generated_code_base = $0780
.SIZE_OF_CODE = 3
.UNROLLED_BYTES = $1f*.SIZE_OF_CODE
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

	;; ------------------------------------------------------------------------
	;; draw strategy:
	;; 1: left-top to right-top, not including rightmost
	;; 2: right-top to right-bottom, not including bottom most
	;; 3: left-top to left-bottom, not including both corners
	;; 4: left-bottom to right-bottom, not including right most
	;; 5: put right-bottom
	;; to achieve this, here needs 5-tuple info the below. 
	;; (vram addr, length, direction, 1st tile, nth tile)
	;; left top ---> right top ---> right bottom
	;; --- calc widths
	ldx #7
.init_parts:
		lda .default_first_corners,x
		sta .first_corner_parts,x
		lda .default_second_corners,x
		sta .second_corner_parts,x
		dex
		bpl .init_parts

	jsr field_x.calc_window_width_in_bg
	ldy #0
	sty <.render_sequence
	;pha	;width 1n 1st bg
	sta <.widths+1
	eor #$ff
	sec
	adc <.width
	;pha ;width in 2nd bg
	sta <.widths
	beq .calc_heights
		sty .second_corner_parts
		sty .second_corner_parts+2
;; heights ignore top/bottom border.
.calc_heights:
	;; --- calc heights
	;lda <.height
	ldx <.height
	dex
	dex
	txa
	pha	;height for upper
	clc
	adc <.top
	;cmp #30
	cmp #29
	pla
	bcc .no_wrap_y
		;;carry is always set
		;lda #30
		lda #29
		sbc <.top
.no_wrap_y:
	sta <.heights+1	;height in 1st bg
	eor #$ff
	sec
	adc <.height
	sec
	sbc #2	;border excl
	sta <.heights	;height in 2nd bg
;	beq .init_offsets
;		sty .second_corner_parts+4
;		sty .second_corner_parts+6
;---

	jsr field_x.begin_ppu_update
		jsr .render_top_and_bottom
		lda #%00000100
		jsr field_x.switch_vram_addr_mode
		jsr .render_left_and_right
		lda #%00000000
		jsr field_x.switch_vram_addr_mode
	jmp field_x.end_ppu_update

.render_top_and_bottom:
	lda <.top
	sta <.offset_y
	jsr .render_horizontal
	ldx <.height
	dex
	txa
	jsr field_x.calc_y_offset
.render_horizontal:
	lda <.left
	sta <.offset_x
	lda <.widths+1
	jsr .do_render
	jsr field_x.calc_x_offset
	lda <.widths
	jmp .do_render

.render_left_and_right:
	lda <.left
	sta <.offset_x
	jsr .render_vertical
	ldx <.width
	dex
	txa
	jsr field_x.calc_x_offset
.render_vertical:
	lda <.top
	sta <.offset_y
	inc <.offset_y	;we have skipped top border in heights calc
	lda <.heights+1
	jsr .do_render
	clc
	adc #1	;we have skipped top border in heights calc
	jsr field_x.calc_y_offset
	lda <.heights
	jmp .do_render

.do_render:
	;ldx #1
.loop:
	;txa
	;pha
;---
	;lda <.widths,x
	pha
	beq .skip_draw
	;---
		pha
		;; $3a = x
		;; $3b = y
		jsr field.setVramAddrForWindow
		;pla	;width
		;pha
		;clc
		;adc <.offset_x
		;sta <.offset_x
		;;
		pla
		eor #$ff
		sec
		adc #$1f	;;note: generated code has $1f STA's.
		sta <.code_offset

		ldx <.render_sequence
		lda .second_corner_parts,x
		pha
		beq .render_first_corner
			inc <.code_offset
	.render_first_corner:
		;; --- 1st byte (left corner)
		lda .first_corner_parts,x
		beq .render_middle
			sta $2007
			inc <.code_offset
	.render_middle:
		lda <.code_offset
		cmp #$20
		bcs .render_second_corner
			asl A
			adc <.code_offset
			sta .generated_code_base+1			
			lda .middle_parts,x
			jsr .generated_code_base
	.render_second_corner:
		pla
		beq .render_end
			sta $2007
	.render_end:
.skip_draw:
	inc <.render_sequence
	;pla
	;tax
	;dex
	;bpl .loop
	pla	;size (width or height)
	rts
.default_first_corners:
	;.db $f7,$00,$fc,$00,$f7,$00,$f9,$00
	.db $f7,$00,$fc,$00,$00,$00,$00,$00
.default_second_corners:
	;.db $f9,$f9,$fe,$fe,$fc,$fc,$fe,$fe
	.db $f9,$f9,$fe,$fe,$00,$00,$00,$00
.middle_parts:
	.db $f8,$f8,$fd,$fd,$fa,$fa,$fb,$fb

field_x.calc_x_offset:
.left = $38
.offset_x = $3a
	clc
	adc <.left
	sta <.offset_x
	rts

field_x.calc_y_offset:
.top = $39
.offset_y = $3b
	clc
	adc <.top
	cmp #30
	bcc .no_wrap_y
		sbc #30
.no_wrap_y:
	sta <.offset_y
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

	.if 0
;in: A = offset Y, X = offset X
;out: A = vram high, X = vram low
field_x.map_coords_to_vram:
;@see $3f:f40a setVramAddrForWindow
.y_to_addr_low = $f4a1
.y_to_addr_high = $f4c1
;in, out
.draw_info_index = $3a
.vram_addr_high = $07d0
.vram_addr_low = $07e0
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
	;ldy <.draw_info_index
	;sta .vram_addr_high,y
	;txa
	;sta .vram_addr_low,y
	rts
	.endif	;field_x.map_coords_to_vram

	.ifdef TEST_BLACKOUT_ON_WINDOW
field_x.blackout_1frame:
	lda #%00000110
	sta $2001

	jsr waitNmiBySetHandler
	inc <field.frame_counter
	jsr field.sync_ppu_scroll	;if omitted, noticable glithces arose in town conversations
	jsr field.callSoundDriver
	lda #%00011110
	sta $2001	
	rts
	.endif	;TEST_BLACKOUT_ON_WINDOW
;======================================================================================================
    VERIFY_PC_TO_PATCH_END textd
field_x.RENDERER_END:
    .endif  ;FAST_FIELD_WINDOW