; encoding: utf-8
; ff3_field_window.asm
;
; description:
;	replaces field::draw_window_box($3f:ed02) related codes
;
; version:
;	0.2.0
;==================================================================================================
ff3_field_window_begin:
;;# of frames waited before text lines scolled up
FIELD_WINDOW_SCROLL_FRAMES = $01

	.ifdef FAST_FIELD_WINDOW

;--------------------------------------------------------------------------------------------------
	;INIT_PATCH $3f, $eb2d, $eba9
	INIT_PATCH $3f, $eb2d, $eefa

;;# $3f:eb2d field.scrolldown_item_window
;;<details>
;;
;;## args:
;;+	[in,out] ptr $1c: pointer to text
;;+	[in,out] ptr $3e: pointer to text
;;+	[in] u8 $93: bank number of the text
;;+	[in] u8 $a3: ?
;;+	[out] u8 $b4: ? (= 0x40(if aborted) or 0xC0(if scrolled))
;;+	[in,out] u16 ($79f0,$79f2): ?
;;+	[out] bool carry: 1: scroll aborted, 0: otherwise
;;## callers:
;;+	`1E:9255:20 2D EB  JSR field.scrolldown_item_window` @ ?
field.scrolldown_item_window:	;;$3f:eb2d
;; fixups
	FIX_ADDR_ON_CALLER $3c,$9255+1
;; ---
;.text_bank = $93
.p_text = $1c
.p_text_end = $3e
	jsr field_x.switch_to_text_bank
	ldy #0
	lda [.p_text_end],y
	bne field.do_scrolldown_item_window
		lda #$40

	FALL_THROUGH_TO field.abort_item_window_scroll
;--------------------------------------------------------------------------------------------------
;;# $3f$eb3c field.abort_item_window_scroll
;;<details>
;;
;;## args:
;;+	[in] u8 $57: bank number to restore
;;+	[out] bool carry: always 1. (scroll aborted)
;;## callers:
;;+	`1F:EBA6:4C 3C EB  JMP field.abort_item_window_scroll` @ $3f$eb69 field.scrollup_item_window
;;## code:
field.abort_item_window_scroll:	;;$3f$eb3c
;; fixups
;; ---
	sta <$b4
	;sec	;;aborted scrolinng item window
field_x.restore_banks_with_carry_set:
	;php
	jsr field.restore_banks	;;note: here original implementation calls $ff03, not $ecf5
	;plp
	sec	;;aborted scrolinng item window
	rts

;--------------------------------------------------------------------------------------------------
;;# $3f$eb43 field.do_scrolldown_item_window
;;<details>
;;
;;## args:
;;+	[out] bool carry: always 0. (= scroll successful)
;;## callers:
;;+	`1F:EB36:D0 0B     BNE field.scrolldown_item_window` @ $3f$eb2d field.scrolldown_item_window
field.do_scrolldown_item_window:	;;$3f$eb43
	lda <$a3
	cmp #2
	bne .by_line
		;; ($79f0,$79f2) -= 8
		sec
		lda $79f0
		sbc #8
		sta $79f0
		bcs .low_byte_only
			dec $79f2
	.low_byte_only:
.by_line:
	jsr field.seek_text_to_next_line

field_x.reflect_item_window_scroll:
	lda #$c0
	sta <$b4

	FALL_THROUGH_TO field.reflect_window_scroll
;--------------------------------------------------------------------------------------------------
;;# $3f$eb61 field.reflect_window_scroll
;;<details>
;;
;;## args:
;;+	[in] u8 $57: bank number to restore
;;+	[out] bool carry: always 0. (= scroll successful)
;;## callers:
;;+	`1E:9F92:20 61 EB  JSR field.reflect_item_window_scro`
;;+	`1E:A889:4C 61 EB  JMP field.reflect_item_window_scro`
;;+	`1E:B436:20 61 EB  JSR field.reflect_item_window_scro`
;;+	`1E:B616:4C 61 EB  JMP field.reflect_item_window_scro`
;;+	`1E:B624:4C 61 EB  JMP field.reflect_item_window_scro`
;;+	`1E:BC0F:4C 61 EB  JMP field.reflect_item_window_scro`
;;+	`1F:EB9F:4C 61 EB  JMP field.reflect_item_window_scroll` @ $3f$eb69 field.scrollup_item_window
field.reflect_window_scroll:	;;$3f$eb61
;; fixups:
	FIX_ADDR_ON_CALLER $3c,$9f92+1
	FIX_ADDR_ON_CALLER $3d,$a889+1
	FIX_ADDR_ON_CALLER $3d,$b436+1
	FIX_ADDR_ON_CALLER $3d,$b616+1
	FIX_ADDR_ON_CALLER $3d,$b624+1
	FIX_ADDR_ON_CALLER $3d,$bc0f+1
;; ---
	jsr field.draw_string_in_window	;$eec0
	;clc	;successfully scrolled the item window
	;bcc field_x.restore_banks_with_status
	jmp field.restore_banks	;carry will be cleared by this routine

;--------------------------------------------------------------------------------------------------
;;# $3f$eb69 field.scrollup_item_window
;;<details>
;;
;;## args:
;;+	[in,out] ptr $1c: pointer to text
;;+	[in] u8 $93: bank number of the text
;;+	[in] u8 $a3: ?
;;+	[out] u8 $b4: ? (= 0xc0 if scrolled, or 0x80 if aborted)
;;+	[in,out] u16 ($79f0,$79f2): ?
;;+	[out] bool carry: 1: scroll aborted, 0: scroll successful
;;## callers:
;;+	`1E:9233:20 69 EB  JSR field.scrollup_item_window` @ ?
field.scrollup_item_window:	;;$3f$eb69
;; fixups:
	FIX_ADDR_ON_CALLER $3c,$9233+1
;; ---
.p_text = $1c
.p_text_end = $3e
;.text_bank = $93
;; ---
	jsr field_x.unseek_window_text
	jsr field_x.unseek_window_text
	jsr field_x.switch_to_text_bank
	ldy #1
	lda [.p_text],y
	beq .abort_scroll
		jsr field.unseek_text_to_line_beginning
		lda <$a3
		cmp #2
		bne field_x.reflect_item_window_scroll
			;; ($79f0,$79f2) += 8
			lda $79f0
			clc
			adc #8
			sta $79f0
			bcc field_x.reflect_item_window_scroll
				inc $79f2
				bcs field_x.reflect_item_window_scroll
.abort_scroll:	;$eba2
	lda #$80
	bne field.abort_item_window_scroll

	;VERIFY_PC $eba9
;--------------------------------------------------------------------------------------------------
	;INIT_PATCH $3f, $eba9, $ee9a
;;
;;# $3f:eba9 field::seek_text_to_next_line
;;<details>
;;
;;## args:
;;+	[in,out] ptr $1c: pointer to text to seek with
;;+	[out] ptr $3e: pointer to the text, pointing the beginning of next line
;;## callers:
;;+	`1F:EB5E:20 A9 EB  JSR field::seek_to_next_line`
;;+	$3f:ee65 field::stream_string_in_window
;;## code:
field_x.seek_text_to_next:
.p_text = $1c
	IS_PRINTABLE_CHAR
	bcs field.seek_text_to_next_line	;printable.
	;: skip operand value of the replacement char
		inc <.p_text
		bne field.seek_text_to_next_line
			inc <.p_text+1

	FALL_THROUGH_TO field.seek_text_to_next_line

field.seek_text_to_next_line:
;; fixup callers
	;FIX_ADDR_ON_CALLER $3f,$eb5e+1
;; ---
	ldy #0
field_x.find_next_eol:
.p_text = $1c
.p_out = $3e
;; ---
;.loop:
	lda [.p_text],y
	;; p_text++
	inc <.p_text
	bne .low_only
		inc <.p_text+1
.low_only:
	cmp #CHAR.EOL
	bne field_x.seek_text_to_next
.found:
	lda <.p_text
	sta <.p_out
	lda <.p_text+1
	sta <.p_out+1
	rts

;field_x.seek_window_text:
;; on exit, zero is always cleared
;; as either low byte of ptr or high byte has non-zero value after increment
;.p_text = $1c
;	inc <.p_text
;	bne .return
;		inc <.p_text+1
;.return
;	rts

;--------------------------------------------------------------------------------------------------
;;# $3f:ebd1 field::unseek_text_to_line_beginning
;;<details>
;;
;;## args:
;;+	[in,out] ptr $1c: pointer to text to seek with
;;+	[out] ptr $3e: pointer to the text, pointing the beginning of line
;;## callers:
;;+	`1F:EB81:20 D1 EB  JSR field.unseek_to_line_beginning`
;;## notes:
;;used to scroll back texts, in particular when a cursor moved up in item window.
;;
field.unseek_text_to_line_beginning:	;;$3f:ebd1
;; fixup callers:
	;FIX_ADDR_ON_CALLER $3f,$eb81+1
;; ---
;;note: in this logic this points to the byte immeditely preceding the current position
.p_text = $1c
.p_out = $3e
;; --- 
.loop:
		jsr field_x.unseek_window_text
		ldy #0
		lda [.p_text],y
		;; checking if the char at right before the pointer
		;; is a replacement code
		;jsr field_x.is_printable_char
		IS_PRINTABLE_CHAR
		bcs .printable_char	;printable.
			;; if it is, then seek back 2 chars to skip operand byte.
			;; this is bit tricky however it works.
			jsr field_x.unseek_window_text
			bne .loop	;always set
.printable_char:
		;; if the
		iny
		lda [.p_text],y
		lsr A
		bne .loop	;char is neither CHAR.NULL or CHAR.EOL
.found:
	;$3c <- ($1c + 2)
	lda #2
	clc
	adc <.p_text
	sta <.p_out
	ldy <.p_text+1
	bcc .return
		iny
.return:
	sty <.p_out+1
	rts

field_x.unseek_window_text:
.p_text = $1c
	lda <.p_text
	bne .low_byte_only
		dec <.p_text+1
.low_byte_only:
	dec <.p_text
	rts

	;VERIFY_PC $ec0c
	;INIT_PATCH $3f, $ec0c, $ee9a
;------------------------------------------------------------------------------------------------------
;;below 2 logics are moved for space optimization:
;;# $3f:ec0c field::show_sprites_on_lower_half_screen
;;# $3f:ec12 field::show_sprites_on_region7 (bug?)
;------------------------------------------------------------------------------------------------------
;;$3f:ecfa field::draw_in_place_window
;;	typically called when object's message is to be shown
;;callers:
;;	$3f:ec8d field::show_window (original implementation only)
;;	$3f:ec83 field::show_message_UNKNOWN
field.draw_inplace_window:
;; patch out external callers {
;;}
.window_id = $96
	sta <.window_id
	lda #0
	sta <$24
	sta <$25
	;;originally fall through to $3f:ed02 field::draw_window_box
	FALL_THROUGH_TO field.draw_window_box

	;VERIFY_PC $ed02
;------------------------------------------------------------------------------------------------------
	;INIT_PATCH $3f,$ed02,$ed56
	;INIT_PATCH $3f,$ed02,$ee9a
;;$3f:ed02 field::draw_window_box
;;	This logic plays key role in drawing window, both for menu windows and in-place windows.
;;	Usually window drawing is performed as follows:
;;	1)	Call this logic to fill in background with window parts
;;		and setup BG attributes if necessary (the in-palce window case).
;;		In cases of the menu window, BG attributes have alreday been setup in another logic
;;		and should not be changed.
;;	2)	Subsequently call other drawing logics which overwrites background with
;;		content (aka string) in the window, 2 consecutive window rows,
;;		which is equivalent to 1 text line, per 1 frame.
;;		These logics rely on window metrics variables, which is initially setup on this logic,
;;		and they don't change BG attributes anyway.
;;NOTEs:
;;	in the scope of this logic, it is safe to use the address range $0780-$07ff (inclusive) in a destructive way.
;;	The original code uses this area as temporary buffer for rendering purporses
;;	and discards its contents on exit.
;;	more specifically, address are utilized as follows:
;;		$0780-$07bf: used for PPU name table buffer,
;;		$07c0-$07cf: used for PPU attr table buffer,
;;		$07d0-$07ff: used for 3-tuple of array that in each entry defines
;;			(vram address(high&low), value to tranfer)
;;callers:
;;	1E:8EFD:20 02 ED  JSR field::draw_window_box	@ $3c:8ef5 ?; window_type = 0
;;	1E:8F0E:20 02 ED  JSR field::draw_window_box	@ $3c:8f04 ?; window_type = 1
;;	1E:8FD5:20 02 ED  JSR field::draw_window_box	@ $3c:8fd1 ?; window_type = 3
;;	1E:90B1:20 02 ED  JSR field::draw_window_box	@ $3c:90ad ?; window_type = 2
;;	1E:AAF4:4C 02 ED  JMP field::draw_window_box	@ $3d:aaf1 field::draw_menu_window
;;	(by falling through) @$3f:ecfa field::draw_in_place_window
field.draw_window_box:	;;$ed02
;; patch out external callers {
	FIX_ADDR_ON_CALLER $3c,$8efd+1
	FIX_ADDR_ON_CALLER $3c,$8f0e+1
	FIX_ADDR_ON_CALLER $3c,$8fd5+1
	FIX_ADDR_ON_CALLER $3c,$90b1+1
	FIX_ADDR_ON_CALLER $3d,$aaf4+1
;;}
;;[in]
.window_type = $96
	ldx <.window_type
	jsr field.get_window_region	;$ed61

field_x.draw_window_box_with_region:
.skipAttrUpdate = $37	;;or in more conceptual, 'is in menu window'
;;[in,out]
.beginX = $38	;loaded by field.get_window_region
.beginY = $39	;loaded by field.get_window_region
.currentY = $3b
.width = $3c	;loaded by field.get_window_region
.height = $3d	;loaded by field.get_window_region
.attrCache = $0300	;128bytes. 1st 64bytes for 1st BG, 2nd for 2nd.
.newAttrBuffer = $07c0	;16bytes. only for 1 line (2 consecutive window row)
;---
	;jsr field.calc_draw_width_and_init_window_tile_buffer ;	$f670
;---
	lda <.skipAttrUpdate
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

.post_attr_update:
	jsr field_x.render_borders
; adjust metrics as borders don't need further drawing...
	jsr field_x.shrink_window_metrics
	jmp field.restore_banks	;$ecf5

	;VERIFY_PC $ed56
;--------------------------------------------------------------------------------------------------
;$3f:ed61 field::get_window_region
;//[in]
;// u8 $37: skipAttrUpdate
;// u8 X: window_type (0...4)
;//		0: object's message?
;//		1: choose dialog (Yes/No) (can be checked at INN)
;//		2: use item to object
;//		3: Gil (can be checked at INN)
;//		4: floor name
	;INIT_PATCH $3f,$ed61,$edc6
;;$3f:ed61 field::get_window_region
;;callers:
;;	$3f:ed02 field::draw_window_box
;;NOTEs:
;; 1) to reflect changes in screen those made by 'field.hide_sprites_around_window',
;;	which is called within this function,
;;	caller must update sprite attr such as:
;;	lda #2
;;	sta $4014	;DMA
;; 2) this logic is very simlar to $3d:aabc field::get_menu_window_metrics.
;;	the difference is:
;;		A) this logic takes care of wrap-around unlike the other one, which does not.
;;		B) target window and the address of table where the corresponding metrics defined at
field.get_window_region:	;;$3f:ed61 field::get_window_metrics
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
	bne field_x.rts_1	;rts (original: bne $ed60)
	;; calculate left coordinates
	lda field.window_attr_table_x,x
	sta <.internal_left
	sta <.offset_x
	dec <.offset_x
	lda <.viewport_left	;assert(.object_x < 0x80)
	asl a
	adc <.internal_left
	and #$3f
	sta <.left
	;; calculate top coordinates
	lda field.window_attr_table_y,x
	;clc ;here always clear
	adc #2
	sta <.offset_y
	sta <.internal_top
	dec <.internal_top
	lda <.viewport_top
	asl a
	adc field.window_attr_table_y,x
	cmp #$1e
	bcc .no_wrap
	;sec ;here always set
	sbc #$1e
.no_wrap:
	sta <.top
	
	;; calculate right coordinates
	lda field.window_attr_table_width,x
	sta <.width
	clc
	adc <.internal_left
	sta <.internal_right
	dec <.internal_right
	;; calculate bottom coordinates
	lda field.window_attr_table_height,x
	sta <.height
	clc
	adc <.internal_top
	;sec	;here always clear
	sbc #2	;effectively -3
	sta <.internal_bottom
	;; done calcs
	;; here X must have window_type (as an argument to the call below)
	FALL_THROUGH_TO field.hide_sprites_under_window
		;jmp field.hide_sprites_under_window	;$ec18
		;rts
		;VERIFY_PC $edb2

;--------------------------------------------------------------------------------------------------
;;# $3f:ec18 field::hide_sprites_under_window
;;<details>
;;
;;## args:
;;+	[in]	u8 X: window_type (0...4)
;;## callers:
;;+	$3f$ed61 field::get_window_region
;;## code:
field.hide_sprites_under_window:
	lda #0
	FALL_THROUGH_TO field.showhide_sprites_by_region
;--------------------------------------------------------------------------------------------------
;;# $3f:ec1a field::showhide_sprites_by_region
;;## args:
;;+	[in]	u8 A: show/hide.
;;	+	1: show
;;	+	0: hide
;;+	[in]	u8 X: region_type (0..6; with 0 to 4 being shared with window_type)
;;## callers:
;;+	$3f:ec0c field::show_sprites_on_lower_half_screen
;;+	$3f:ec12 field::show_sprites_on_region7 (with X set to 7)
;;+	$3f:ec18 field::showhide_sprites_by_window_region
;;## local variables:
;;+	u8 $80: region boundary in pixels, left, inclusive.
;;+	u8 $81: region boundary in pixels, right, exclusive.
;;+	u8 $82: region boundary in pixels, top, inclusive.
;;+	u8 $83: region boundary in pixels, bottom, exclusive.
;;+	u8 $84: show/hide flag
field.showhide_sprites_by_region:
;; --- fixups
;; all callers have got replaced their implementation within this file
;; --- 
;.region_left = $80	;in pixels
;.region_right = $81	;in pixels
;.region_top = $82	;in pixels
;.region_bottom = $83;in pixels
.is_to_show = $84
.sprite_buffer.x = $0203
.sprite_buffer.y = $0200
.sprite_buffer.attr = $0202
	sta <.is_to_show
	ldy #$40	;don't change player and cursor (stored at before $0240) anyways

	.for_each_sprites:
		;; if (x < left || right <= x) { continue; }
		lda .sprite_buffer.x, y
		sec
		sbc field.region_bounds.left, x
		cmp field.region_bounds.width, x
		bcs .next
			;; if (y < top || bottom <= y) { continue; }
			lda .sprite_buffer.y, y
			;;here carry is always clear
			sbc field.region_bounds.top, x	;;top is adjusted to account carry
			cmp field.region_bounds.height, x
			bcs .next
				lda .sprite_buffer.attr, y
				and #$df	;bit 5 <- 0: sprite in front of BG
				bit <.is_to_show
				bne .update
					ora #$20	;bit 5 <- 1: sprite behind BG
			.update:
				sta .sprite_buffer.attr, y
	.next:
		iny
		iny
		iny
		iny 
		bne .for_each_sprites
field_x.rts_1:
	rts
;--------------------------------------------------------------------------------------------------
;;# $3f:ec0c field::show_sprites_on_lower_half_screen
;;<details>
;;
;;## callers:
;;+	`1F:C9B6:20 0C EC  JSR field.show_sprites_on_region6`
field.show_sprites_on_lower_half_screen:
;; --- fixup address on callers
	FIX_ADDR_ON_CALLER $3e,$c9b6+1
;; ---
	ldx #6
	bne	field.show_sprites_by_region
;--------------------------------------------------------------------------------------------------
;;# $3f:ec12 field::show_sprites_on_region7 (bug?)
;;<details>
;;
;;## callers:
;;+	`1F:C9C1:20 12 EC  JSR field.show_sprites_on_region7`
field.show_sprites_on_region7:
;; --- fixup address on callers
	FIX_ADDR_ON_CALLER $3e,$c9c1+1
;; --- begin
	ldx #7	;;invalid region type. seems to be a bug.
field.show_sprites_by_region:
	lda #1
	bne	field.showhide_sprites_by_region
;------------------------------------------------------------------------------------------------------
field.region_bounds.left:	;$ec67 left (inclusive)
	DB $0A,$0A,$0A,$8A,$0A,$0A,$0A
;field.region_bounds.right:	;$ec6e right (excludive, out of the box)
	;DB $EF,$4F,$EF,$EF,$EF,$EF,$EF	
field.region_bounds.width:
	DB $E5,$45,$E5,$65,$E5,$E5,$E5	;width
field.region_bounds.top:		;$ec75 top (inclusive)
	;DB $0A,$8A,$8A,$6A,$0A,$0A,$6A
	DB $09,$89,$89,$69,$09,$09,$69	;top - 1.(accounted for optimization)
;field.region_bounds.bottom:	;$ec7c bottom (exclusive)
	;DB $57,$D7,$D7,$87,$2A,$57,$D7	
field.region_bounds.height:
	DB $4d,$4d,$4d,$1d,$20,$4d,$6d	;height

	;VERIFY_PC $ec83
;------------------------------------------------------------------------------------------------------
	;.org $edb2
field.window_attr_table_x:	; = $edb2
	.db $02, $02, $02, $12, $02
field.window_attr_table_y:	; = $edb7
	.db $02, $12, $12, $0e, $02
field.window_attr_table_width:	; = $edbc
	.db $1c, $08, $1c, $0c, $1c
field.window_attr_table_height:	; = $edc1
	.db $0a, $0a, $0a, $04, $04

	;VERIFY_PC $edc6
;------------------------------------------------------------------------------------------------------
	;INIT_PATCH $3f,$ec83,$ee9a

;;$3f:ec83 field::show_message_UNKNOWN:
;; 1F:EC83:A9 00     LDA #$00
;; 1F:EC85:20 FA EC  JSR field::draw_inplace_window
;; 1F:EC88:4C 65 EE  JMP field::stream_string_in_window
field.show_off_message_window:
	lda #0
field_x.show_off_window:
	jsr field.draw_inplace_window		;$ecfa
	jmp field.stream_string_in_window	;$ee65
;------------------------------------------------------------------------------------------------------
;;$3f:ec8b field::show_message_window:
;;callers:
;;	1F:E237:20 8B EC  JSR field::show_message_window
;;
field.show_message_window:
;;patch out callers
	FIX_ADDR_ON_CALLER $3f,$e237+1
;;
	lda #0
	FALL_THROUGH_TO field.show_window
;------------------------------------------------------------------------------------------------------
;;$3f:ec8d field::show_window:
;;callers:
;;	 1F:E264:20 8D EC  JSR $EC8D
;;in:
;;	u8 A : window_type
field.show_window:
;;patch out external callers {
	FIX_ADDR_ON_CALLER $3f,$e264+1
;;}
.field.pad1_inputs = $20
	;jsr field.draw_inplace_window		;$ecfa
	;jsr field.stream_string_in_window	;$ee65
	jsr field_x.show_off_window
	jsr field.await_and_get_next_input	;$ecab
	lda <$7d
	;beq .leave	;$eca8
	bne .enter_input_loop
.leave:	;$eca8
		jmp $c9b6
.input_loop:	;$ec9e
	jsr field.get_next_input	
.enter_input_loop:	;$ec9a
	lda <.field.pad1_inputs
	bpl .input_loop
.on_a_button_down:	;$eca4
	lda #0
	sta <$7d
	beq .leave	;always met
;------------------------------------------------------------------------------------------------------
;;$3f:ECAB field::await_and_get_new_input:
;;callers:
;;	 1F:EC93:20 AB EC  JSR field::await_and_get_new_input ($3f:ec8b field::show_message_window)
;;	 1F:ECBA:4C AB EC  JMP field::await_and_get_new_input (tail recursion)
;;	 1F:EE6A:20 AB EC  JSR field::await_and_get_new_input ($3f:ee65 field::stream_string_in_window)
field.await_and_get_next_input:
	jsr field_x.get_input_with_result	;on exit, A have the value from $20
	beq field.get_next_input_in_this_frame
	jsr field_x.advance_frame
	jmp field.await_and_get_next_input
;------------------------------------------------------------------------------------------------------
;;$3f:ECc4 field::get_next_input:
;;callers:
;;	1F:EC9E:20 C4 EC  JSR field::get_next_input
field.get_next_input:
;.field.pad1_inputs = $20	;bit7 <- A ...  -> bit0
;;$ecc4:
	jsr field_x.advance_frame
	;;fall through
field.get_next_input_in_this_frame:
.field.input_cache = $21
;;$ecbd:
	jsr field_x.get_input_with_result	;on exit, A have the value from $20
	beq field.get_next_input
;;$eccf
	sta <.field.input_cache
	bne field_x.switch_to_text_bank
;------------------------------------------------------------------------------------------------------
;;$3f:ecd8 field::advance_frame_with_sound
;;callers:
;;	 1F:EE74:20 D8 EC  JSR field::advance_frame_w_sound ($3f:ee65 field::stream_string_in_window)
field.advance_frame_and_set_bank:
	jsr field_x.advance_frame
	;;jmp field_x.switch_to_text_bank
	FALL_THROUGH_TO field_x.switch_to_text_bank
;------------------------------------------------------------------------------------------------------
field_x.switch_to_text_bank:
.content_string_bank = $93
	lda <.content_string_bank
	jmp call_switch_2banks

field_x.advance_frame:
	jsr waitNmiBySetHandler
	inc <field.frame_counter
	jmp field.callSoundDriver

field_x.get_input_with_result:
.field.pad1_inputs = $20	;bit7 <- A ...  -> bit0
	jsr field.get_input
	lda <.field.pad1_inputs
	rts

	;VERIFY_PC $ece5

;------------------------------------------------------------------------------------------------------
	;INIT_PATCH $3f,$ece5,$ecf5
;;$3f:ece5 field::draw_window_top:
;;NOTEs:
;;	called when executed actions the below in item window from menu
;;	1) exchange of position
;;	2) use of item
;;callers:
;;	 1E:AAA3:4C E5 EC  JMP field::draw_window_top
;;original code:
;1F:ECE5:A5 39     LDA window_top = #$0B
;1F:ECE7:85 3B     STA window_row_in_draw = #$0F
;1F:ECE9:20 70 F6  JSR field::calc_size_and_init_buff
;1F:ECEC:20 56 ED  JSR field::init_window_attr_buffer
;1F:ECEF:20 F6 ED  JSR field::get_window_top_tiles
;1F:ECF2:20 C6 ED  JSR field::draw_window_row
field.draw_window_top:
;; patch out callers external to current implementation {
	FIX_ADDR_ON_CALLER $3d,$aaa3+1
;;}
.window_top = $39
.window_row_in_drawing = $3b
	lda <.window_top
	sta <.window_row_in_drawing
	jsr field.calc_draw_width_and_init_window_tile_buffer
	;jsr field.init_window_attr_buffer	;;unnecessary
	jsr field.get_window_top_tiles
	jsr field.draw_window_row
	;; fall through (into $ecf5: field.restore_banks)
	;jmp field.restore_banks	;$ecf5
	FALL_THROUGH_TO field.restore_banks

	;VERIFY_PC $ecf5
;------------------------------------------------------------------------------------------------------
;;$3f:ecf5 restoreBanksBy$57
;;callers:
;;	 1F:EB64:20 F5 EC  JSR field::restore_banks (in $3f:eb61 field::drawEncodedStringInWindowAndRestoreBanks)
;;	 1F:F49E:4C F5 EC  JMP field::restore_banks
;;	field::draw_window_top (by falling thourgh)
;;	field::draw_window_box
field.restore_banks:
;; patch out external callers {
	;FIX_ADDR_ON_CALLER $3f,$eb64+1
	FIX_ADDR_ON_CALLER $3f,$f49e+1
;;}
.program_bank = $57
	lda <.program_bank
	jmp call_switch_2banks
	;VERIFY_PC $ecfa
;------------------------------------------------------------------------------------------------------
;;$3f:ed56 field::fill_07c0_ff
;;callers:
;;	$3f:ece5 field::draw_window_top
;;	$3f:ed02 field::draw_window_box
field.init_window_attr_buffer:
.window_attr_buffer = $07c0
	ldx #$0f
	lda #$ff
.fill:
	sta .window_attr_buffer,x
	dex
	bpl .fill
	rts

	;VERIFY_PC $ed61

;;for optimzation,
;;$3f$ed61 field.get_window_metrics is relocated to nearby $3f$ec1a field.showhide_sprites_by_region

;------------------------------------------------------------------------------------------------------
	;INIT_PATCH $3f,$edc6,$ede1
field.draw_window_row:	;;$3f:edc6 field::draw_window_row
;;callers:
;;	$3f:ece5 field::draw_window_top
;;	$3f:ed02 field::draw_window_box (only the original implementation)
.width = $3c
.iChar = $90
	lda <.width
	sta <.iChar
	;jsr field.updateTileAttrCache	;$c98f
	jsr field_x.begin_ppu_update
	jsr field.upload_window_content	;$f6aa
	;jsr field.setTileAttrForWindow	;$c9a9
	;;fall through.
field_x.end_ppu_update:
	jsr field.sync_ppu_scroll	;$ede1
	jmp field.callSoundDriver	;$c750

field_x.begin_ppu_update:
	jsr waitNmiBySetHandler	;$ff00
	jmp ppud.do_sprite_dma
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
;;	$3f:edc6 field.draw_window_row
;;	$3f:f692 field.draw_window_content
field.sync_ppu_scroll:
.skip_attr_update = $37
.ppu_ctrl_cache = $ff
	lda <.skip_attr_update
	bne .set_ppu_ctrl
		jmp field.sync_ppu_scroll_with_player	;$e571
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
field.get_window_top_tiles:		
	lda #$00
	jsr field_x.get_window_tiles
	;lda #$07
	;;fall through
field_x.get_window_tiles:
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
	lda field_x.window_parts,y
	sta .window_tiles_buffer_upper_row,x
	txa
	clc
	adc <.width
	sta <.eol	;width + offset
	inx
.center_tiles:
		lda field_x.window_parts+1,y
		sta .window_tiles_buffer_upper_row,x
		inx
		cpx <.eol
		bcc .center_tiles
.right_tile:
	lda field_x.window_parts+2,y
	sta .window_tiles_buffer_upper_row-1,x
	pla	;original width
	sta <.width
	tya
	;here always carry is set
	;adc #$22	;effectively +23
	adc #$06
	rts
field_x.window_parts:
	db $f7, $f8, $f9
	db $fa, $ff, $fb
	.ifdef IMPL_BORDER_LOADER
	db $fc, $fd, $fe
;;$3f:ee1d field::getWindowTilesForMiddle
;;callers:
;;	$3f:ed02 field::draw_window_box
field.get_window_middle_tiles:	;ee1d
	lda #$03<<1
	jsr field_x.get_window_tiles
	lda #$03<<1|1
	bne field_x.get_window_tiles
;;$3f:ee3e field::getWindowTilesForBottom
;;callers:
;;	$3f:ed02 field::draw_window_box
field.get_window_bottom_tiles:	;ed3b
	lda #$03<<1
	jsr field_x.get_window_tiles
	bne field_x.get_window_tiles
	.endif	;.ifdef IMPL_BORDER_LOADER

	;VERIFY_PC $ee65
;------------------------------------------------------------------------------------------------------
	;INIT_PATCH $3f,$ee65,$ee9a
;;$3f:ee65 field::stream_string_in_window
;;callers:
;;	1E:9109:4C 65 EE  JMP $EE65 @ $3c:90ff	? 
;;	1E:A675:4C 65 EE  JMP $EE65	@ $3d:a666	? (load menu)
;;	1F:EC88:4C 65 EE  JMP $EE65 @ $3f:ec83 field::show_off_message_window
;;	1F:EC90:20 65 EE  JSR $EE65 @ $3f:ec8b field::show_message_window
field.stream_string_in_window:
;; patch out callers external to this implementation {
	FIX_ADDR_ON_CALLER $3c,$9109+1
	FIX_ADDR_ON_CALLER $3d,$a675+1
;; }
.viewport_left = $29	;in 16x16 unit
.viewport_top = $2f	;in 16x16 unit
.in_menu_mode = $37
.window_left = $38	;in 8x8 unit
.window_top = $39	;in 8x8 unit
.window_width = $3c
.window_height = $3d
.offset_x = $97
.offset_y = $98
	jsr field.load_and_draw_string	;$ee9a.
	;; on exit from above, carry has a boolean value.
	;; 1: more to draw, 0: completed drawing.
	bcc .do_return	
	.paging:
		jsr field.await_and_get_next_input
		lda <.window_height
		clc
		adc #1	;round up to next mod 2
		lsr A
	.streaming:
		sec
		sbc #1
		pha	;# of text lines available to draw
		lda #0
		sta <field.frame_counter
		.delay_loop:
			jsr field.advance_frame_and_set_bank	;$ecd8
			lda <field.frame_counter
			and #FIELD_WINDOW_SCROLL_FRAMES	;;originally 1
			bne .delay_loop
		jsr field.seek_text_to_next_line	;$eba9
		jsr field.draw_string_in_window		;$eec0
		;; on exit from above, carry has a boolean value.
		;; 1: more to draw, 0: completed drawing.
		pla	;# of text lines available to draw
		bne .streaming	;there is more space to fill in
		bcs .paging	;there is more text to draw
		;;content space is filled with reaching end of text 
.do_return:
	rts
;======================================================================================================
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
;.vram_addr_high = $07d0
;.vram_addr_low = $07e0
;.widths = $07d0
;.heights = $07e0
;.draw_flags = $07f0
.widths = $80
.heights = $82
.code_offset = $84
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
	jsr field_x.calc_window_width_in_bg
	;pha	;width 1n 1st bg
	sta <.widths+1
	eor #$ff
	sec
	adc <.width
	;pha ;width in 2nd bg
	sta <.widths
	;; --- calc heights
	lda <.height
	pha	;height for upper
	clc
	adc <.top
	cmp #30
	pla
	bcc .no_wrap_y
		lda #30
		sbc <.top
.no_wrap_y:
	sta <.heights+1
	eor #$ff
	sec
	adc <.height
	sta <.heights
;---
	lda <.left
	sta <.offset_x
	lda <.top
	sta <.offset_y

	jsr field_x.begin_ppu_update
	ldx #1
.loop:
	txa
	pha
;---
	lda <.widths,x
	beq .skip_draw
	;---
		pha
		jsr field.setVramAddrForWindow
		pla
		pha
		eor #$ff
		sec
		adc #$20	;;note: generated code has only $1f STA's. this is done for accounting 1st byte

		sta <.code_offset
		asl A
		adc <.code_offset
		sta .generated_code_base+1		
		;update
		pla
		;clc
		adc <.offset_x
		sta <.offset_x
	;---
		;; ---
		lda #$f7
		sta $2007
		;lda #$f8
		lda #$72
		jsr .generated_code_base
.skip_draw:
	pla
	tax
	dex
	bpl .loop
;---
	jmp field_x.end_ppu_update

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
	;VERIFY_PC $ee9a
;======================================================================================================

	;INIT_PATCH $3f,$ee9a,$eec0
;------------------------------------------------------------------------------------------------------
;;# $3f:ee9a field::load_and_draw_string
;;### args:
;;
;;#### in:
;;+	u8 $92: string_id
;;+	ptr $94: offset to string ptr table
;;
;;#### out:
;;+	bool carry: more_to_draw	//flagged cases could be tested at サロニアの図書館(オーエンのほん1)
;;+	ptr $3e: offset to the string, assuming the bank it to be loaded is at 1st page (starting at $8000)
;;+	u8 $93: bank number which the string would be loaded from
;;
;;### callers:
;;+	`1F:C036:20 9A EE  JSR field::load_and_draw_string`
;;+	`1F:EE65:20 9A EE  JSR field::load_and_draw_string` @ $3f:ee65 field::stream_string_in_window
;;+	`3c:9116  jmp $EE9A `   
;;+	`3d:a682  jmp $EE9A `
field.load_and_draw_string:	;;$ee9a
;; fixups.
	FIX_ADDR_ON_CALLER $3c, $9116+1
	FIX_ADDR_ON_CALLER $3d, $a682+1
	FIX_ADDR_ON_CALLER $3e, $c036+1
;; ---
.p_text = $3e
.text_id = $92
.text_bank = $93
.p_text_table = $94	;;stores offset from $30000(18:8000) to the text 
;; ---
	lda #$18
	jsr call_switch1stBank
	lda <.text_id
	asl A
	tay
	bcc .lower_half
	inc <.p_text_table+1
.lower_half:
	lda [.p_text_table],Y
	sta <.p_text
	iny
	lda [.p_text_table],Y
	pha
	and #$1F
	ora #$80
	sta <.p_text+1	;store pointer as an offset from $8000, the bank will be always mapped to there.
	pla	;high byte of the offset (from $30000 == $18:8000)
	;lsr A
	;lsr A
	;lsr A
	;lsr A
	;lsr A
	jsr shiftRight6+1	;; A >> 5
	clc
	adc #$18
	sta <.text_bank
	;;fall through.
	FALL_THROUGH_TO field.draw_string_in_window

;------------------------------------------------------------------------------------------------------
	;INIT_PATCH $3f,$eec0,$eefa
;;# $3f:eec0 field.draw_string_in_window
;;
;;
;;### args:
;;+	[in] ptr $3e : string offset
;;+	[in] u8 $93 : string bank
;;+	[out] bool carry: more_to_draw
;;
;;### callers:
;;+	`1F:EB61:20 C0 EE  JSR field::draw_string_in_window` @ $3f:eb61 field.reflect_window_scroll
;;+	`1F:EE80:20 C0 EE  JSR field::draw_string_in_window` @ $3f:ee65 field::stream_string_in_window
;;+	`1F:EEBE:85 93     STA field.window_text_bank = #$18` (fall through)@ $3f:ee9a field::load_and_draw_string
field.draw_string_in_window:	;;$eec0
;; fixups.
	;; every caller is implemented within this file.
;; ---
.text_index = $90
.text_bank = $93
.p_text = $3e
.p_text_line = $1c
.lines_drawn = $1f
;; ---
.program_bank = $57
;; --- window related
.in_menu_mode = $37
.window_left = $38
.window_top = $39
.offset_x = $3a
.offset_y = $3b
.window_width = $3c
.window_height = $3d
;; ---
	lda <.text_bank
	jsr call_switch_2banks	;$FF03
	;lda #$00
	;sta <$1e
	lda <.p_text
	sta <.p_text_line
	lda <.p_text+1
	sta <.p_text_line+1
	;sta <$1D ;;???
	lda <.window_left	;$38
	sta <.offset_x		;$3A
	lda <.window_top	;$39
	sta <.offset_y		;$3B
	jsr field.calc_draw_width_and_init_window_tile_buffer	;$f670
	lda #$00
	sta <.text_index
	sta <.lines_drawn	;$1F
	sta <$1e
	jsr textd.draw_in_box	;$eefa
	;bcs .more_to_draw	;$EEF3
	bcc .completed
;$eef3
.more_to_draw:
	jmp field_x.restore_banks_with_carry_set
	;lda <.program_bank	; $57
	;jsr call_switch_2banks	;$FF03
	;sec
	;rts
.completed:
	jsr field.draw_window_content	;$f692
	;lda <.program_bank	; $57
	;jsr call_switch_2banks	;$FF03
	jmp field.restore_banks	;carry will be implictly cleared
;$eef1
field_x.clc_return:
	FIX_OFFSET_ON_CALLER $3f,$eefe+1
	clc
	rts

	
	VERIFY_PC $eefa
	.endif	;FAST_FIELD_WINDOW
;======================================================================================================
	
	.ifdef FAST_FIELD_WINDOW
	;INIT_PATCH $3f,$eefa,$f38a
	INIT_PATCH $3f,$eefa,$f02a
;;# $3f:eefa textd.draw_in_box
;;
;;### args:
;;+	[in] $37: in_menu_mode (1: menu, 0: floor)
;;+	[in, out] string* $3e: ptr to string
;;+	[in, out] u8 $1f: number of lines drawn (in 8x8 unit)
;;+	[out] u8 $90: destOffset
;;+	[out] bool carry: more_to_draw
;;
;;### callers:
;;+	`1F:EEE4:20 FA EE  JSR textd.draw_in_box` @ $3f:eec0 field.draw_string_in_window
;;+	`1F:F0D8:20 FA EE  JSR textd.draw_in_box` @ $3f:f02a textd.eval_replacement (recurse)
;;+	`1F:F33F:20 FA EE  JSR textd.draw_in_box` @ ?
;;+	`1F:EF24:4C FA EE  JMP textd.draw_in_box` @ $3f:eefa textd.draw_in_box(recurse)
;;+	`1F:F345:4C FA EE  JMP textd.draw_in_box` @ ?
;;+	`1F:F387:4C FA EE  JMP textd.draw_in_box` @ ?
textd.draw_in_box:
;; fixups.
	;FIX_ADDR_ON_CALLER $3f,$eee4+1
	;FIX_ADDR_ON_CALLER $3f,$f0d8+1
	;FIX_ADDR_ON_CALLER $3f,$f33f+1
	;FIX_ADDR_ON_CALLER $3f,$ef24+1
	;FIX_ADDR_ON_CALLER $3f,$f345+1
	;FIX_ADDR_ON_CALLER $3f,$f387+1
;; --- variables.
.text_index = $90
.text_id = $92
.text_bank = $93
.p_text_table = $94	;;stores offset from $30000(18:8000) to the text 
;; textd
.p_text_line = $1c
.lines_drawn = $1f
;; ---
.program_bank = $57
;; --- window related
.in_menu_mode = $37
.window_left = $38
.window_top = $39
.offset_x = $3a
.offset_y = $3b
.window_width = $3c
.window_height = $3d
.p_text = $3e
;;
.tile_buffer_upper = $0780
.tile_buffer_lower = $07a0
;;static reference


;; --- begin.
        ldy     #$00                            ; EEFA A0 00
        lda     [.p_text],y                         ; EEFC B1 3E
        beq     field_x.clc_return              ; EEFE F0 F1
        inc     <.p_text                             ; EF00 E6 3E
        bne     .lEF06                          ; EF02 D0 02
        inc     <.p_text+1                             ; EF04 E6 3F
.lEF06: cmp     #$28                            ; EF06 C9 28
        bcc     .lEF3E                          ; EF08 90 34
        cmp     #$5C                            ; EF0A C9 5C
        bcc     .lEF27                          ; EF0C 90 19
        ldy     <.text_index                             ; EF0E A4 90
        ldx     <.in_menu_mode                             ; EF10 A6 37
        bne     .lEF1A                          ; EF12 D0 06
        cmp     #$70                            ; EF14 C9 70
        bcs     .lEF1A                          ; EF16 B0 02
        lda     #$FF                            ; EF18 A9 FF
.lEF1A: sta     .tile_buffer_lower,y                         ; EF1A 99 A0 07
        lda     #$FF                            ; EF1D A9 FF
        sta     .tile_buffer_upper,y                         ; EF1F 99 80 07
        inc     <.text_index                             ; EF22 E6 90
        jmp     textd.draw_in_box     ; EF24 4C FA EE
; ----------------------------------------------------------------------------
.lEF27: sec                                     ; EF27 38
        sbc     #$28                            ; EF28 E9 28
        tax                                     ; EF2A AA
        ldy     <.text_index                             ; EF2B A4 90
        lda     textd.tile_map_upper,x                         ; EF2D BD 15 F5
        sta     .tile_buffer_upper,y                         ; EF30 99 80 07
        lda     textd.tile_map_lower,x                         ; EF33 BD E1 F4
        sta     .tile_buffer_lower,y                         ; EF36 99 A0 07
        inc     <.text_index                             ; EF39 E6 90
        jmp     textd.draw_in_box     ; EF3B 4C FA EE
; ----------------------------------------------------------------------------
.lEF3E: cmp     #$10                            ; EF3E C9 10
        bcc     .lEF45                          ; EF40 90 03
        jmp     textd.eval_replacement   ; EF42 4C 2A F0
; ----------------------------------------------------------------------------
.lEF45: cmp     #$01                            ; EF45 C9 01
        bne     .lEF5B                          ; EF47 D0 12
        jsr     field.draw_window_content       ; EF49 20 92 F6
        inc     <.lines_drawn                             ; EF4C E6 1F
.next_line: 
		inc     <.lines_drawn                             ; EF4E E6 1F
        lda     <.lines_drawn                             ; EF50 A5 1F
        cmp     <.window_height                             ; EF52 C5 3D
        bcc     .lEF58                          ; EF54 90 02
        sec                                     ; EF56 38
        rts                                     ; EF57 60
; ----------------------------------------------------------------------------
.lEF58: jmp     textd.draw_in_box     ; EF58 4C FA EE
; ----------------------------------------------------------------------------
.lEF5B: cmp     #$02                            ; EF5B C9 02
        bne     .lEF6A                          ; EF5D D0 0B
        lda     <$BB                             ; EF5F A5 BB
        sta     <$84                             ; EF61 85 84
        lda     #$00                            ; EF63 A9 00
        sta     <$B9                             ; EF65 85 B9
        jmp     $F09D                          ; EF67 4C 9D F0
; ----------------------------------------------------------------------------
.lEF6A: cmp     #$03                            ; EF6A C9 03
        bne     .lEF7C                          ; EF6C D0 0E
        jsr     switch_to_character_logics_bank ; EF6E 20 27 F7
        ldx     <$BB                             ; EF71 A6 BB
        jsr     floor.get_item_price            ; EF73 20 D4 F5
        jsr     $8B78                          ; EF76 20 78 8B
        jmp     $F291                          ; EF79 4C 91 F2
; ----------------------------------------------------------------------------
.lEF7C: cmp     #$04                            ; EF7C C9 04
        bne     .lEF95                          ; EF7E D0 15
        lda     <$61                             ; EF80 A5 61
        sta     <$80                             ; EF82 85 80
        lda     <$62                             ; EF84 A5 62
        sta     <$81                             ; EF86 85 81
        lda     <$63                             ; EF88 A5 63
        sta     <$82                             ; EF8A 85 82
        jsr     switch_to_character_logics_bank ; EF8C 20 27 F7
        jsr     $8B78                          ; EF8F 20 78 8B
        jmp     textd.switch_to_text_bank_and_continue_drawing	; EF92 4C 91 F2
; ----------------------------------------------------------------------------
.lEF95: cmp     #$05                            ; EF95 C9 05
        bne     .lEFA2                          ; EF97 D0 09
        jsr     switch_to_character_logics_bank ; EF99 20 27 F7
        jsr     $8B03                          ; EF9C 20 03 8B
        jmp     textd.switch_to_text_bank_and_continue_drawing	; EF9F 4C 91 F2
; ----------------------------------------------------------------------------
.lEFA2: cmp     #$06                            ; EFA2 C9 06
        bne     .lEFA9                          ; EFA4 D0 03
.lEFA6: jmp     textd.draw_in_box     ; EFA6 4C FA EE
; ----------------------------------------------------------------------------
.lEFA9: cmp     #$07                            ; EFA9 C9 07
        bne     .lEFBB                          ; EFAB D0 0E
        lda     $600B                           ; EFAD AD 0B 60
        beq     .lEFA6                          ; EFB0 F0 F4
        sec                                     ; EFB2 38
        sbc     #$01                            ; EFB3 E9 01
        clc                                     ; EFB5 18
        adc     #$F8                            ; EFB6 69 F8
        jmp     textd.deref_text_id             ; EFB8 4C D8 F2
; ----------------------------------------------------------------------------
.lEFBB: cmp     #$08                            ; EFBB C9 08
        bne     .lEFDA                          ; EFBD D0 1B
        lda     $601B                           ; EFBF AD 1B 60
        sta     <$80                             ; EFC2 85 80
        lda     #$00                            ; EFC4 A9 00
        sta     <$81                             ; EFC6 85 81
        jsr     switch_to_character_logics_bank ; EFC8 20 27 F7
        jsr     $8B57                          ; EFCB 20 57 8B
        ldx     <.text_index                             ; EFCE A6 90
        inc     <.text_index                             ; EFD0 E6 90
        lda     #$5C                            ; EFD2 A9 5C
        sta     .tile_buffer_lower,x                         ; EFD4 9D A0 07
        jmp     textd.switch_to_text_bank_and_continue_drawing	; EFD7 4C 91 F2
; ----------------------------------------------------------------------------
.lEFDA: cmp     #$09                            ; EFDA C9 09
        bne     .lEFE4                          ; EFDC D0 06
        jsr     field.draw_window_content       ; EFDE 20 92 F6
        jmp     .next_line                          ; EFE1 4C 4E EF
; ----------------------------------------------------------------------------
.lEFE4: cmp     #$0A                            ; EFE4 C9 0A
        bne     .lEFEC                          ; EFE6 D0 04
        lda     #$09                            ; EFE8 A9 09
        clc                                     ; EFEA 18
        rts                                     ; EFEB 60
; ----------------------------------------------------------------------------
.lEFEC: cmp     #$0B                            ; EFEC C9 0B
        bne     .lEFF0                          ; EFEE D0 00
.lEFF0: cmp     #$0C                            ; EFF0 C9 0C
        bne     .lEFFA                          ; EFF2 D0 06
        ldx     $600E                           ; EFF4 AE 0E 60
        jmp     $f316                          ; EFF7 4C 16 F3
; ----------------------------------------------------------------------------
.lEFFA: cmp     #$0D                            ; EFFA C9 0D
        bne     .lF007                          ; EFFC D0 09
        jsr     switch_to_character_logics_bank ; EFFE 20 27 F7
        jsr     $8B34                          ; F001 20 34 8B
        jmp     textd.switch_to_text_bank_and_continue_drawing	; F004 4C 91 F2
; ----------------------------------------------------------------------------
.lF007: cmp     #$0F                            ; F007 C9 0F
        bne     .lF027                          ; F009 D0 1C
        ldx     <.text_index                             ; F00B A6 90
        lda     #$58                            ; F00D A9 58
        sta     .tile_buffer_upper,x                         ; F00F 9D 80 07
        lda     #$59                            ; F012 A9 59
        sta     .tile_buffer_upper+1,x                         ; F014 9D 81 07
        lda     #$5A                            ; F017 A9 5A
        sta     .tile_buffer_lower,x                         ; F019 9D A0 07
        lda     #$5B                            ; F01C A9 5B
        sta     .tile_buffer_lower+1,x                         ; F01E 9D A1 07
        txa                                     ; F021 8A
        clc                                     ; F022 18
        adc     #$02                            ; F023 69 02
        sta     <.text_index                    ; F025 85 90
.lF027: jmp     textd.draw_in_box     ; F027 4C FA EE
; ----------------------------------------------------------------------------
	VERIFY_PC $f02a

	.if 0
;------------------------------------------------------------------------------------------------------
;;# $3f:f02a textd.eval_replacement
;;### args:
;;+	[in] a: charcode
;;+	[in] y: offset into the string pointed to by $3e.
;;+	[in, out] u8 $1f: number of lines drawn (in 8x8 unit)
;;+	[in] string * $3e: ptr to text to evaluate.
;;	On entry, this will point to the parameter byte of replacement code.
;;+	[in,out] u8 $67: ?
;;+	[in,out] u8 $90: offset into the tile buffer ($0780/$07a0)
;;+	[out] u8 $0780[32]: tile (or name table) buffer for upper line
;;+	[out] u8 $07a0[32]: tile (or name table) buffer for lower line
;;
;;### local variables:
;;+	u8 $80,81,82,83: scratch.
;;+	u8 $84: parameter byte
;;+	u8 $97,98
;;
;;### notes:
;;charcodes ranged [10...28) are defined as opcodes (or 'replacement'),
;;given that the codes have followed by additional one byte for parameter.
;;
;;#### code meanings:
;;+	10-13: status of a player character. lower 2-bits represents an index of character.
;;+	15-17: left-align text by paramter,increment menu-item count by 4
;;+	1e: get job name
; ----------------------------------------------------------------------------
; bank $3f
textd.eval_replacement:
        pha                                     ; F02A 48
        ldx     $67                             ; F02B A6 67
        cmp     #$1D                            ; F02D C9 1D
        beq     LF034                           ; F02F F0 03
        lda     ($3E),y                         ; F031 B1 3E
        tax                                     ; F033 AA
LF034:  stx     $84                             ; F034 86 84
        stx     $67                             ; F036 86 67
        inc     $3E                             ; F038 E6 3E
        bne     LF03E                           ; F03A D0 02
        inc     $3F                             ; F03C E6 3F
LF03E:  pla                                     ; F03E 68
        cmp     #$14                            ; F03F C9 14
        bcs     LF046                           ; F041 B0 03
        jmp     field.string.eval_code_10_13    ; F043 4C 39 F2
; ----------------------------------------------------------------------------
LF046:  bne     LF04F                           ; F046 D0 07
        lda     $84                             ; F048 A5 84
        sta     $90                             ; F04A 85 90
        jmp     textd.draw_in_box     ; F04C 4C FA EE
; ----------------------------------------------------------------------------
LF04F:  cmp     #$18                            ; F04F C9 18
        bcs     LF09B                           ; F051 B0 48
        sec                                     ; F053 38
        sbc     #$15                            ; F054 E9 15
        clc                                     ; F056 18
        adc     #$78                            ; F057 69 78
        sta     $81                             ; F059 85 81
        lda     #$00                            ; F05B A9 00
        sta     $80                             ; F05D 85 80
        lda     $84                             ; F05F A5 84
        sta     $90                             ; F061 85 90
        lda     ($3E),y                         ; F063 B1 3E
        sta     $82                             ; F065 85 82
        iny                                     ; F067 C8
        lda     ($3E),y                         ; F068 B1 3E
        sta     $83                             ; F06A 85 83
        ldy     #$F1                            ; F06C A0 F1
        lda     ($80),y                         ; F06E B1 80
        ldx     $1E                             ; F070 A6 1E
        bne     LF077                           ; F072 D0 03
        inc     $1E                             ; F074 E6 1E
        txa                                     ; F076 8A
LF077:  tax                                     ; F077 AA
        clc                                     ; F078 18
        adc     #$04                            ; F079 69 04
        sta     ($80),y                         ; F07B 91 80
        txa                                     ; F07D 8A
        tay                                     ; F07E A8
        lda     $84                             ; F07F A5 84
        clc                                     ; F081 18
        adc     $97                             ; F082 65 97
        sta     ($80),y                         ; F084 91 80
        lda     $98                             ; F086 A5 98
        clc                                     ; F088 18
        adc     $1F                             ; F089 65 1F
        iny                                     ; F08B C8
        sta     ($80),y                         ; F08C 91 80
        iny                                     ; F08E C8
        lda     $82                             ; F08F A5 82
        sta     ($80),y                         ; F091 91 80
        lda     $83                             ; F093 A5 83
        iny                                     ; F095 C8
        sta     ($80),y                         ; F096 91 80
        jmp     textd.draw_in_box     ; F098 4C FA EE
; ----------------------------------------------------------------------------
LF09B:  bne     LF0F0                           ; F09B D0 53
LF09D:  lda     $84                             ; F09D A5 84
        beq     LF0ED                           ; F09F F0 4C
        lda     $90                             ; F0A1 A5 90
        pha                                     ; F0A3 48
        jsr     LF3E4                           ; F0A4 20 E4 F3
        lda     #$18                            ; F0A7 A9 18
        jsr     call_switchFirst2Banks          ; F0A9 20 03 FF
        lda     $84                             ; F0AC A5 84
        asl     a                               ; F0AE 0A
        tax                                     ; F0AF AA
        bcs     LF0BD                           ; F0B0 B0 0B
        lda     $8800,x                         ; F0B2 BD 00 88
        sta     $3E                             ; F0B5 85 3E
        lda     $8801,x                         ; F0B7 BD 01 88
        jmp     LF0C5                           ; F0BA 4C C5 F0
; ----------------------------------------------------------------------------
LF0BD:  lda     $8900,x                         ; F0BD BD 00 89
        sta     $3E                             ; F0C0 85 3E
        lda     $8901,x                         ; F0C2 BD 01 89
LF0C5:  pha                                     ; F0C5 48
        and     #$1F                            ; F0C6 29 1F
        ora     #$80                            ; F0C8 09 80
        sta     $3F                             ; F0CA 85 3F
        pla                                     ; F0CC 68
        lsr     a                               ; F0CD 4A
        lsr     a                               ; F0CE 4A
        lsr     a                               ; F0CF 4A
        lsr     a                               ; F0D0 4A
        lsr     a                               ; F0D1 4A
        clc                                     ; F0D2 18
        adc     #$18                            ; F0D3 69 18
        jsr     call_switchFirst2Banks          ; F0D5 20 03 FF
        jsr     textd.draw_in_box     ; F0D8 20 FA EE
        jsr     LF3ED                           ; F0DB 20 ED F3
        pla                                     ; F0DE 68
        tax                                     ; F0DF AA
        lda     $B9                             ; F0E0 A5 B9
        beq     LF0ED                           ; F0E2 F0 09
        lda     #$00                            ; F0E4 A9 00
        sta     $B9                             ; F0E6 85 B9
        lda     #$73                            ; F0E8 A9 73
        sta     $07A0,x                         ; F0EA 9D A0 07
LF0ED:  jmp     textd.draw_in_box     ; F0ED 4C FA EE
; ----------------------------------------------------------------------------
LF0F0:  cmp     #$19                            ; F0F0 C9 19
        bne     LF114                           ; F0F2 D0 20
        ldx     $84                             ; F0F4 A6 84
        lda     $7B80,x                         ; F0F6 BD 80 7B
        sta     $84                             ; F0F9 85 84
        bne     LF10A                           ; F0FB D0 0D
        lda     $79F1                           ; F0FD AD F1 79
        sec                                     ; F100 38
        sbc     #$04                            ; F101 E9 04
        sta     $79F1                           ; F103 8D F1 79
        lda     #$FF                            ; F106 A9 FF
        clc                                     ; F108 18
        rts                                     ; F109 60
; ----------------------------------------------------------------------------
LF10A:  lda     #$00                            ; F10A A9 00
        sta     $B9                             ; F10C 85 B9
        jmp     LF09D                           ; F10E 4C 9D F0
; ----------------------------------------------------------------------------
LF111:  jmp     textd.draw_in_box     ; F111 4C FA EE
; ----------------------------------------------------------------------------
LF114:  cmp     #$1A                            ; F114 C9 1A
        bne     LF128                           ; F116 D0 10
        lda     #$00                            ; F118 A9 00
        sta     $B9                             ; F11A 85 B9
        ldx     $84                             ; F11C A6 84
        lda     $60C0,x                         ; F11E BD C0 60
        beq     LF111                           ; F121 F0 EE
        sta     $84                             ; F123 85 84
        jmp     LF09D                           ; F125 4C 9D F0
; ----------------------------------------------------------------------------
LF128:  cmp     #$1B                            ; F128 C9 1B
        bne     LF13F                           ; F12A D0 13
        jsr     LF3AC                           ; F12C 20 AC F3
        ldx     $84                             ; F12F A6 84
        lda     $7C00,x                         ; F131 BD 00 7C
        beq     LF111                           ; F134 F0 DB
        sta     $84                             ; F136 85 84
        lda     #$00                            ; F138 A9 00
        sta     $B9                             ; F13A 85 B9
        jmp     LF09D                           ; F13C 4C 9D F0
; ----------------------------------------------------------------------------
LF13F:  cmp     #$1C                            ; F13F C9 1C
        bne     LF14C                           ; F141 D0 09
        ldx     $84                             ; F143 A6 84
        lda     $60E0,x                         ; F145 BD E0 60
        beq     LF111                           ; F148 F0 C7
        bne     LF166                           ; F14A D0 1A
LF14C:  cmp     #$1D                            ; F14C C9 1D
        bne     LF17A                           ; F14E D0 2A
        lda     $84                             ; F150 A5 84
        lsr     a                               ; F152 4A
        lda     #$0A                            ; F153 A9 0A
        bcc     LF159                           ; F155 90 02
        lda     #$18                            ; F157 A9 18
LF159:  sta     $90                             ; F159 85 90
        ldx     $84                             ; F15B A6 84
        lda     $7C00,x                         ; F15D BD 00 7C
        beq     LF111                           ; F160 F0 AF
        tax                                     ; F162 AA
        lda     $6300,x                         ; F163 BD 00 63
LF166:  sta     $80                             ; F166 85 80
        ldx     $90                             ; F168 A6 90
        inc     $90                             ; F16A E6 90
        lda     #$C8                            ; F16C A9 C8
        sta     $07A0,x                         ; F16E 9D A0 07
        jsr     switch_to_character_logics_bank ; F171 20 27 F7
        jsr     L8B29                           ; F174 20 29 8B
        jmp     LF291                           ; F177 4C 91 F2
; ----------------------------------------------------------------------------
LF17A:  cmp     #$1E                            ; F17A C9 1E
        bne     LF19A                           ; F17C D0 1C
        jsr     getLastValidJobId               ; F17E 20 8A F3
        cmp     $84                             ; F181 C5 84
        bcs     LF192                           ; F183 B0 0D
        lda     $78F1                           ; F185 AD F1 78
        sec                                     ; F188 38
        sbc     #$04                            ; F189 E9 04
        sta     $78F1                           ; F18B 8D F1 78
        lda     #$FF                            ; F18E A9 FF
        clc                                     ; F190 18
        rts                                     ; F191 60
; ----------------------------------------------------------------------------
LF192:  lda     $84                             ; F192 A5 84
        clc                                     ; F194 18
        adc     #$E2                            ; F195 69 E2
        jmp     textd.deref_text_id             ; F197 4C D8 F2
; ----------------------------------------------------------------------------
LF19A:  cmp     #$1F                            ; F19A C9 1F
        bne     LF1BB                           ; F19C D0 1D
        ldx     $84                             ; F19E A6 84
        lda     $7200,x                         ; F1A0 BD 00 72
        sta     $80                             ; F1A3 85 80
        ldx     $90                             ; F1A5 A6 90
        inc     $90                             ; F1A7 E6 90
        lda     #$C8                            ; F1A9 A9 C8
        sta     $07A0,x                         ; F1AB 9D A0 07
        lda     #$00                            ; F1AE A9 00
        sta     $81                             ; F1B0 85 81
        jsr     switch_to_character_logics_bank ; F1B2 20 27 F7
        jsr     L8B57                           ; F1B5 20 57 8B
        jmp     LF291                           ; F1B8 4C 91 F2
; ----------------------------------------------------------------------------
LF1BB:  cmp     #$20                            ; F1BB C9 20
        bne     LF1D1                           ; F1BD D0 12
        ldx     $84                             ; F1BF A6 84
        lda     $60C0,x                         ; F1C1 BD C0 60
        beq     LF1F6                           ; F1C4 F0 30
        sta     $84                             ; F1C6 85 84
        tax                                     ; F1C8 AA
        lda     $7200,x                         ; F1C9 BD 00 72
        sta     $B9                             ; F1CC 85 B9
        jmp     LF09D                           ; F1CE 4C 9D F0
; ----------------------------------------------------------------------------
LF1D1:  cmp     #$21                            ; F1D1 C9 21
        bne     LF1F9                           ; F1D3 D0 24
        ldx     $84                             ; F1D5 A6 84
        lda     $7B80,x                         ; F1D7 BD 80 7B
        beq     LF1F6                           ; F1DA F0 1A
        lda     $7B90,x                         ; F1DC BD 90 7B
        sta     $80                             ; F1DF 85 80
        lda     $7B98,x                         ; F1E1 BD 98 7B
        sta     $81                             ; F1E4 85 81
        lda     $7BA0,x                         ; F1E6 BD A0 7B
        sta     $82                             ; F1E9 85 82
        jsr     switch_to_character_logics_bank ; F1EB 20 27 F7
        jsr     L8B78                           ; F1EE 20 78 8B
        lda     $93                             ; F1F1 A5 93
        jsr     call_switchFirst2Banks          ; F1F3 20 03 FF
LF1F6:  jmp     textd.draw_in_box     ; F1F6 4C FA EE
; ----------------------------------------------------------------------------
LF1F9:  cmp     #$22                            ; F1F9 C9 22
        bne     LF1F6                           ; F1FB D0 F9
        lda     #$00                            ; F1FD A9 00
        sta     $B9                             ; F1FF 85 B9
        ldx     $84                             ; F201 A6 84
        lda     $60C0,x                         ; F203 BD C0 60
        beq     LF1F6                           ; F206 F0 EE
        sta     $84                             ; F208 85 84
        lda     $90                             ; F20A A5 90
        pha                                     ; F20C 48
        jsr     LF3E4                           ; F20D 20 E4 F3
        lda     #$18                            ; F210 A9 18
        jsr     call_switchFirst2Banks          ; F212 20 03 FF
        lda     $84                             ; F215 A5 84
        asl     a                               ; F217 0A
        tax                                     ; F218 AA
        bcs     LF229                           ; F219 B0 0E
        lda     $8800,x                         ; F21B BD 00 88
        clc                                     ; F21E 18
        adc     #$01                            ; F21F 69 01
        sta     $3E                             ; F221 85 3E
        lda     $8801,x                         ; F223 BD 01 88
        jmp     LF234                           ; F226 4C 34 F2
; ----------------------------------------------------------------------------
LF229:  lda     $8900,x                         ; F229 BD 00 89
        clc                                     ; F22C 18
        adc     #$01                            ; F22D 69 01
        sta     $3E                             ; F22F 85 3E
        lda     $8901,x                         ; F231 BD 01 89
LF234:  adc     #$00                            ; F234 69 00
        jmp     LF0C5                           ; F236 4C C5 F0
; ----------------------------------------------------------------------------

;------------------------------------------------------------------------------------------------------
field.string.eval_code_10_13:
        lsr     a                               ; F239 4A
        ror     a                               ; F23A 6A
        ror     a                               ; F23B 6A
        and     #$C0                            ; F23C 29 C0
        sta     $67                             ; F23E 85 67
        lda     $84                             ; F240 A5 84
        cmp     #$30                            ; F242 C9 30
        bcc     LF299                           ; F244 90 53
LF246:  cmp     #$FF                            ; F246 C9 FF
        bne     LF289                           ; F248 D0 3F
        ldx     $67                             ; F24A A6 67
        lda     $6101,x                         ; F24C BD 01 61
        cmp     #$62                            ; F24F C9 62
        bcs     LF291                           ; F251 B0 3E
        sta     $80                             ; F253 85 80
        asl     a                               ; F255 0A
        clc                                     ; F256 18
        adc     $80                             ; F257 65 80
        sta     $84                             ; F259 85 84
        lda     #$00                            ; F25B A9 00
        adc     #$80                            ; F25D 69 80
        sta     $85                             ; F25F 85 85
        lda     #$39                            ; F261 A9 39
        jsr     call_switch1stBank              ; F263 20 06 FF
        ldy     #$B0                            ; F266 A0 B0
        lda     ($84),y                         ; F268 B1 84
        sec                                     ; F26A 38
        sbc     $6103,x                         ; F26B FD 03 61
        sta     $80                             ; F26E 85 80
        iny                                     ; F270 C8
        lda     ($84),y                         ; F271 B1 84
        sbc     $6104,x                         ; F273 FD 04 61
        sta     $81                             ; F276 85 81
        iny                                     ; F278 C8
        lda     ($84),y                         ; F279 B1 84
        sbc     $6105,x                         ; F27B FD 05 61
        sta     $82                             ; F27E 85 82
        jsr     switch_to_character_logics_bank ; F280 20 27 F7
        jsr     L8B78                           ; F283 20 78 8B
        jmp     LF291                           ; F286 4C 91 F2
; ----------------------------------------------------------------------------
LF289:  pha                                     ; F289 48
        jsr     switch_to_character_logics_bank ; F28A 20 27 F7
        pla                                     ; F28D 68
        jsr     L8998                           ; F28E 20 98 89

;textd.switch_to_text_bank_and_continue_drawing
LF291:  lda     $93                             ; F291 A5 93
        jsr     call_switchFirst2Banks          ; F293 20 03 FF
        jmp     textd.draw_in_box     ; F296 4C FA EE
; ----------------------------------------------------------------------------
LF299:  cmp     #$00                            ; F299 C9 00
        bne     LF301                           ; F29B D0 64
        ldx     $67                             ; F29D A6 67
        lda     $6102,x                         ; F29F BD 02 61
        and     #$FE                            ; F2A2 29 FE
        bne     LF2BB                           ; F2A4 D0 15
        ldx     $90                             ; F2A6 A6 90
        inc     $90                             ; F2A8 E6 90
        inc     $90                             ; F2AA E6 90
        lda     #$5E                            ; F2AC A9 5E
        sta     $07A0,x                         ; F2AE 9D A0 07
        lda     #$5F                            ; F2B1 A9 5F
        sta     $07A1,x                         ; F2B3 9D A1 07
        lda     #$3E                            ; F2B6 A9 3E
        jmp     LF246                           ; F2B8 4C 46 F2
; ----------------------------------------------------------------------------
LF2BB:  ldy     #$16                            ; F2BB A0 16
        asl     a                               ; F2BD 0A
        bcs     LF2D7                           ; F2BE B0 17
        ldy     #$17                            ; F2C0 A0 17
        asl     a                               ; F2C2 0A
        bcs     LF2D7                           ; F2C3 B0 12
        ldy     #$1B                            ; F2C5 A0 1B
        asl     a                               ; F2C7 0A
        bcs     LF2D7                           ; F2C8 B0 0D
        iny                                     ; F2CA C8
        asl     a                               ; F2CB 0A
        bcs     LF2D7                           ; F2CC B0 09
        iny                                     ; F2CE C8
        asl     a                               ; F2CF 0A
        bcs     LF2D7                           ; F2D0 B0 05
        iny                                     ; F2D2 C8
        asl     a                               ; F2D3 0A
        bcs     LF2D7                           ; F2D4 B0 01
        iny                                     ; F2D6 C8
LF2D7:  tya                                     ; F2D7 98
;textd.deref_text_id
LF2D8:  tax                                     ; F2D8 AA
        jsr     LF3E4                           ; F2D9 20 E4 F3
        lda     #$18                            ; F2DC A9 18
        jsr     call_switchFirst2Banks          ; F2DE 20 03 FF
        txa                                     ; F2E1 8A
        asl     a                               ; F2E2 0A
        tax                                     ; F2E3 AA
        bcs     LF2F1                           ; F2E4 B0 0B
        lda     $8200,x                         ; F2E6 BD 00 82
        sta     $3E                             ; F2E9 85 3E
        lda     $8201,x                         ; F2EB BD 01 82
        jmp     LF2F9                           ; F2EE 4C F9 F2
; ----------------------------------------------------------------------------
LF2F1:  lda     $8300,x                         ; F2F1 BD 00 83
        sta     $3E                             ; F2F4 85 3E
        lda     $8301,x                         ; F2F6 BD 01 83
LF2F9:  tax                                     ; F2F9 AA
        lda     $90                             ; F2FA A5 90
        pha                                     ; F2FC 48
        txa                                     ; F2FD 8A
        jmp     LF0C5                           ; F2FE 4C C5 F0
; ----------------------------------------------------------------------------
LF301:  cmp     #$01                            ; F301 C9 01
        bne     LF310                           ; F303 D0 0B
        ldx     $67                             ; F305 A6 67
        lda     $6100,x                         ; F307 BD 00 61
        clc                                     ; F30A 18
        adc     #$E2                            ; F30B 69 E2
        jmp     textd.deref_text_id             ; F30D 4C D8 F2
; ----------------------------------------------------------------------------
LF310:  cmp     #$02                            ; F310 C9 02
        bne     LF348                           ; F312 D0 34
        ldx     $67                             ; F314 A6 67
        lda     $6106,x                         ; F316 BD 06 61
        sta     $5A                             ; F319 85 5A
        lda     $6107,x                         ; F31B BD 07 61
        sta     $5B                             ; F31E 85 5B
        lda     $6108,x                         ; F320 BD 08 61
        sta     $5C                             ; F323 85 5C
        lda     $6109,x                         ; F325 BD 09 61
        sta     $5D                             ; F328 85 5D
        lda     $610A,x                         ; F32A BD 0A 61
        sta     $5E                             ; F32D 85 5E
        lda     $610B,x                         ; F32F BD 0B 61
        sta     $5F                             ; F332 85 5F
        jsr     LF3E4                           ; F334 20 E4 F3
        lda     #$5A                            ; F337 A9 5A
        sta     $3E                             ; F339 85 3E
        lda     #$00                            ; F33B A9 00
        sta     $3F                             ; F33D 85 3F
        jsr     textd.draw_in_box     ; F33F 20 FA EE
        jsr     LF3ED                           ; F342 20 ED F3
        jmp     textd.draw_in_box     ; F345 4C FA EE
; ----------------------------------------------------------------------------
LF348:  cmp     #$08                            ; F348 C9 08
        bcs     LF373                           ; F34A B0 27
        sec                                     ; F34C 38
        sbc     #$03                            ; F34D E9 03
        cmp     #$04                            ; F34F C9 04
        bne     LF356                           ; F351 D0 03
        clc                                     ; F353 18
        adc     #$01                            ; F354 69 01
LF356:  ora     $67                             ; F356 05 67
        tax                                     ; F358 AA
        lda     $6200,x                         ; F359 BD 00 62
        bne     LF368                           ; F35C D0 0A
        txa                                     ; F35E 8A
        and     #$07                            ; F35F 29 07
        tax                                     ; F361 AA
        lda     LF36D,x                         ; F362 BD 6D F3
        jmp     textd.deref_text_id             ; F365 4C D8 F2
; ----------------------------------------------------------------------------
LF368:  sta     $84                             ; F368 85 84
        jmp     LF0A1                           ; F36A 4C A1 F0
; ----------------------------------------------------------------------------
LF36D:  cmp     $DFDE,x                         ; F36D DD DE DF
        cpx     #$E1                            ; F370 E0 E1
        .byte   $E1                             ; F372 E1
LF373:  sec                                     ; F373 38
        sbc     #$08                            ; F374 E9 08
        tax                                     ; F376 AA
        lda     $7C00,x                         ; F377 BD 00 7C
        beq     LF387                           ; F37A F0 0B
        sta     $84                             ; F37C 85 84
        tax                                     ; F37E AA
        lda     $7200,x                         ; F37F BD 00 72
        sta     $B9                             ; F382 85 B9
        jmp     LF09D                           ; F384 4C 9D F0
; ----------------------------------------------------------------------------
LF387:  jmp     textd.draw_in_box     ; F387 4C FA EE
; ----------------------------------------------------------------------------
	.endif	;0

	VERIFY_PC $f38a
	.endif	;FAST_FIELD_WINDOW
;======================================================================================================
;$3f:f40a setVramAddrForWindow
;//	[in] u8 $3a : x offset
;//	[in] u8 $3b : y
	INIT_PATCH $3f,$f40a,$f435
field.setVramAddrForWindow:
.offsetX = $3a
	ldy <.offsetX
field.setVramAddrForWindowEx:
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
	;INIT_PATCH $3f,$f670,$f692
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
;$3f:f670
;{
;	$91 = $3c;
;	if ( ($38 & #1f) ^ #1f + 1 < $3c) {
;		$91 = a;
;	}
;$f683:
;}
	jsr field_x.calc_window_width_in_bg
.store_result:
	sta <.width_for_current_bg
	;; fall through into $3f:f683 field::init_window_tile_buffer
;------------------------------------------------------------------------------------------------------
;;$3f:f683 field::init_window_tile_buffer:
;;caller:
;;	$3f:f692 field.draw_window_content
field.init_window_tile_buffer:
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
	;VERIFY_PC $f692
;------------------------------------------------------------------------------------------------------
	;INIT_PATCH $3f,$f692,$f6aa
;;$3f:f692 field::draw_window_content
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
;;callers:
;;	1F:EEE9:20 92 F6  JSR field::draw_window_content @ $3f:eec0 field.draw_string_in_window
;;	1F:EF49:20 92 F6  JSR field::draw_window_content @ $3f:eefa textd.draw_in_box
;;	1F:EFDE:20 92 F6  JSR field::draw_window_content @ ? (sub routine of $eefa)
;;	1F:F48E:20 92 F6  JSR field::draw_window_content @ 
field.draw_window_content:
;; patch out external callers {
	;FIX_ADDR_ON_CALLER $3f,$eee9+1
	FIX_ADDR_ON_CALLER $3f,$ef49+1
	FIX_ADDR_ON_CALLER $3f,$efde+1
	FIX_ADDR_ON_CALLER $3f,$f48e+1
;;}
	pha
	jsr waitNmiBySetHandler	;ff00
	inc <field.frame_counter
	pla
	jsr field.upload_window_content	;f6aa
	;jsr field.sync_ppu_scroll	;ede1
	;jsr field.callSoundDriver	;c750
	jsr field_x.end_ppu_update	;sync_ppu_scroll+call_sound_driver
	;lda <.string_bank
	;jsr call_switch_2banks		;ff03
	jsr field_x.switch_to_text_bank
	jmp field.init_window_tile_buffer	;f683

	;VERIFY_PC $f6aa
	.endif	;FAST_FIELD_WINDOW
;------------------------------------------------------------------------------------------------------
	.ifndef FAST_FIELD_WINDOW
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
	;VERIFY_PC $f727
field_x.shrink_window_metrics:
.left = $38	;loaded by field.getWindowMetrics
.top = $39	;loaded by field.getWindowMetrics
.width = $3c	;loaded by field.getWindowMetrics
.height = $3d	;loaded by field.getWindowMetrics
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