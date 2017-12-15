; encoding: utf-8
;   ff3_field_render_x.asm
;
; description:
;   implementation of optimzied renderer code
;
;==================================================================================================
    .ifdef FAST_FIELD_WINDOW

    .ifndef textd.BULK_PATCH_FREE_BEGIN
        .fail
    .endif

    
    .ifndef _FEATURE_STOMACH_AMOUNT_1BYTE
		;;	it is needed to move and free up the buffer at $7300-$73ff,
		;;	in order for the logics implemented in this file to work correctly.
		;;	these logics rely on that buffer being stable across rendering.
    	.fail
    .endif
    
    ;RESTORE_PC textd.BULK_PATCH_FREE_BEGIN
	RESTORE_PC field.window.renderer.FREE_BEGIN

render_x.RENDERER_BEGIN:
;--------------------------------------------------------------------------------------------------
;;
;; 	the nmi handler for deferred rendering.
;;	other functions called within this function,
;;	must preserve all variables in order to keep consistency
;; 	across NMIs.
;;	if not, those functions not specially designed to variable volatility,
;;	will see undefined value and will eventually crash.
;;
render_x.deferred_renderer:
;; preserve general-purpose registers.
	pha
	txa
	pha
	tya
	pha
;; dummy read to ensure unset nmi flag.
	lda $2002	
;; preserve local variables.
;	ldx #(render_x.nmi.LOCALS_COUNT-1)
;.push_variables:
;		lda <$80,x
;		pha
;		dex
;		bpl .push_variables
;; do rendering.
	ldx #0
;	sta <render_x.nmi.sequence
	jsr render_x.render_deferred_contents
	;; as calling sound driver need change of program bank,
	;; we can't safely call the driver from within nmi handler,
	;; unless under the situation which is known
	;; that the program bank has a particular deterministic value.
	;inc <field.frame_counter
	;jsr field_x.end_ppu_update	;sync_ppu_scroll+call_sound_driver
	jsr field.sync_ppu_scroll
	jsr render_x.remove_nmi_handler

	;; there is no reliable way (found so far) to preserve program bank.
	;; so here can't safely restore banks.
	;jsr field.restore_banks

;; restore local variables.
;	ldx #~(render_x.nmi.LOCALS_COUNT-1)
;.pop_variables:
;		pla
;		sta <$80+(render_x.nmi.LOCALS_COUNT),x
;		inx
;		bne .pop_variables
	pla
	tay
	pla
	tax
	pla
	rti
;--------------------------------------------------------------------------------------------------
;; in:
;;	X = source buffer offset.
;; notes:
;;	the buffer contains variable-length structure the below:
;;	+00 vram high
;;	+01	vram low
;;	+02 buffer length
;;	+03 buffer offset, adjusted to loop boundary
render_x.render_deferred_contents:
	DECLARE_WINDOW_VARIABLES
	;; setup vram address.
	lda render_x.q.buffer,x		;;	4
	sta $2006					;;	8
	lda render_x.q.buffer+1,x	;;	12
	sta $2006					;;	16
	ldy render_x.q.buffer+2,x	;;	20
	lda render_x.q.buffer+3,x	;;	24
	tax							;;	26
	tya							;;	28
;; branch out.
;; X = offset
;; A = length
	.if render_x.UNROLL_DEPTH = 4
	lsr A				;;	2
	bcc .length_0		;;	4+(1)
.length_1:
		lsr A				;;	6
		bcc .length_01		;;	8+(1)
.length_11:
			lsr A				;;	10
			bcc .length_011	;;	12+(1)
.length_111:
				lsr A				;;	14
				tay					;;	16
				bcs .length_1111	;;	18+1
				bcc .length_0111	;;	21
.length_011:
				lsr A				;;	15
				tay					;;	17
				bcs .length_1011	;;	19+1
				bcc .length_0011	;;	22
.length_01:
			lsr A				;;	11
			bcc .length_001	;;	13+(1)
.length_101:
				lsr A				;;	15
				tay					;;	17
				bcs .length_1101	;;	19+1
				bcc .length_0101	;;	22
.length_001:
				lsr A				;;	16
				tay					;;	18
				bcs .length_1001	;;	20+1
				bcc .length_0001	;;	23
.length_0:
		lsr A				;;	7
		bcc .length_00		;;	9+(1)
.length_10:
			lsr A				;;	11
			bcc .length_010	;;	13+(1)
.length_110:
				lsr A				;;	15
				tay					;;	17
				bcs .length_1110	;;	20
				bcc .length_0110	;;	23
.length_010:
				lsr A				;;	16
				tay					;;	18
				bcs .length_1010	;;	21
				bcc .length_0010	;;	24
.length_00:
			lsr A				;;	12
			bcc .length_000	;;	14+(1)
.length_100:
				lsr A				;;	16
				tay					;;	18
				bcs .length_1100	;;	21
				bcc .length_0100	;;	24
.length_000:
				lsr A				;;	17
				tay					;;	19
				bcs .length_1000	;;	22
				bcc .length_0000
	.else ;;UNROLL_DEPTH == 4
	lsr A				;;	6
	bcc .length_01		;;	8+(1)
.length_11:
		lsr A				;;	10
		bcc .length_011	;;	12+(1)
.length_111:
			lsr A				;;	14
			tay					;;	16
			bcs .length_0111	;;	18+1
			bcc .length_0011	;;	21
.length_011:
			lsr A				;;	15
			tay					;;	17
			bcs .length_0101	;;	19+1
			bcc .length_0001	;;	22
.length_01:
		lsr A				;;	11
		bcc .length_001	;;	13+(1)
.length_101:
			lsr A				;;	15
			tay					;;	17
			bcs .length_0110	;;	19+1
			bcc .length_0010	;;	22
.length_001:
			lsr A				;;	16
			tay					;;	18
			bcs .length_0100	;;	20+1
			bcc .length_0000	;;	23
	.endif	;;UNROLL_DEPTH
;; A = scratch.
;; X = buffer offset.
;; Y = loop counter.
.render_x.upload_loop:
	.if render_x.UNROLL_DEPTH = 4
	lda render_x.q.buffer-$10,x
	sta $2007
.length_1111:
	lda render_x.q.buffer-$0f,x
	sta $2007
.length_1110:
	lda render_x.q.buffer-$0e,x
	sta $2007
.length_1101:
	lda render_x.q.buffer-$0d,x
	sta $2007
.length_1100:
	lda render_x.q.buffer-$0c,x
	sta $2007
.length_1011:
	lda render_x.q.buffer-$0b,x
	sta $2007
.length_1010:
	lda render_x.q.buffer-$0a,x
	sta $2007
.length_1001:
	lda render_x.q.buffer-$09,x
	sta $2007
.length_1000:
	.endif	;;UNROLL_DEPTH == 4
	lda render_x.q.buffer-$08,x
	sta $2007
.length_0111:
	lda render_x.q.buffer-$07,x
	sta $2007
.length_0110:
	lda render_x.q.buffer-$06,x
	sta $2007
.length_0101:
	lda render_x.q.buffer-$05,x
	sta $2007
.length_0100:
	lda render_x.q.buffer-$04,x
	sta $2007
.length_0011:
	lda render_x.q.buffer-$03,x
	sta $2007
.length_0010:
	lda render_x.q.buffer-$02,x
	sta $2007
.length_0001:
	lda render_x.q.buffer-$01,x
	sta $2007
.length_0000:
;; overhead = 15 if loop continues, 5 if loop reached the end.
;; A = scratch.
;; X = buffer offset.
;; Y = render target index.
.next:
	dey							;;	2
	bmi render_x.upload_next	;;	4(+1)
	txa							;;	6
	clc							;;	8
	;adc #$10					;;	10
	adc #(1 << render_x.UNROLL_DEPTH)	;;10
	tax							;;	12
	bne .render_x.upload_loop	;;	15

;; overhead = 5-6 cpu cycles.
;; A = scratch.
;; X = buffer offset.
;; Y = render target index.
render_x.upload_next:
	DECLARE_WINDOW_VARIABLES
	cpx <render_x.q.available_bytes			;;	3
	bcs render_x.reset_states				;;	5(+1)
		jmp render_x.render_deferred_contents	;;	8

;; out:
;;	A: #0
render_x.reset_states:
	lda #render_x.FULL_OF_FUEL
	sta <render_x.q.fuel
	lda #0
	sta <render_x.q.available_bytes	;;this will free up a waiting thread
;	ldy #(render_x.nmi.STATE_VARIABLES_END - render_x.nmi.STATE_VARIABLES_BASE)
;.reset:
;		sta render_x.nmi.STATE_VARIABLES_BASE-1,y
;		;sta <render_x.q.available_bytes
;		dey
;		bne .reset
	rts

;--------------------------------------------------------------------------------------------------
render_x.remove_nmi_handler:
	pha
	lda #$40	;RTI
	sta nmi_handler_entry
	pla
	rts

render_x.set_deferred_renderer:
	jsr render_x.remove_nmi_handler
	lda #HIGH(render_x.deferred_renderer)
	sta nmi_handler_entry+2
	lda #LOW(render_x.deferred_renderer)
	sta nmi_handler_entry+1
	lda #$4c	;JMP
	sta nmi_handler_entry
render_x.rts_1:
	rts

;--------------------------------------------------------------------------------------------------
;; in A: bytes to ensure
render_x.ensure_buffer_available:
	DECLARE_WINDOW_VARIABLES
	jsr render_x.remove_nmi_handler	;; preserves A.

	;pha
	;clc
	;adc #14
	;clc
	;adc <render_x.q.available_bytes
	;adc <render_x.q.stride
	;cmp #render_x.BUFFER_CAPACITY
	;pla
	;bcs render_x.await_complete_rendering

	clc
	adc #render_x.FUEL_FOR_OVERHEAD
	eor #$ff
	tax
	adc <render_x.q.fuel
	bcs .available	;;ok. carry set = adding negative value resulted in overflow.
		txa
		pha
		jsr render_x.await_complete_rendering
		pla
		clc
		adc <render_x.q.fuel
.available:
	sta <render_x.q.fuel
	bit $2002
	;bmi render_x.on_nmi_completed
	bpl render_x.rts_1
		jmp field_x.advance_frame_no_wait

	;rts
;--------------------------------------------------------------------------------------------------
render_x.finalize:
	lda <render_x.q.available_bytes
	;beq .completed
	beq render_x.rts_1
		;;jsr render_x.await_complete_rendering
.completed:
	;; XXX:
	;;  in cases of paging in window,
	;;	the rendering continues even if it reached the bottom of window.
	;lda #0
	;sta <render_x.q.init_flags
	;rts
;--------------------------------------------------------------------------------------------------
render_x.await_complete_rendering:
	jsr render_x.set_deferred_renderer
.wait_nmi:
	lda <render_x.q.available_bytes
	bne .wait_nmi
render_x.on_nmi_completed:
	;; FIXME: this is a temporary measure to workaround PRG bank mismatch on nmi
	jmp field_x.advance_frame_no_wait	;;inc <.frame_counter + call sound driver
;--------------------------------------------------------------------------------------------------
render_x.queue_content:
	DECLARE_WINDOW_VARIABLES
.p_source = $80
	clc
	adc #$80
	sta <.p_source
	lda #$07
	sta <.p_source+1

	bit <render_x.q.init_flags
	;php
	;bmi .put_middles
	bmi .do_queue
		;; --- build final contents onto temporary buffer.
		ldy #0
		ldx #0
		lda #$fa
		jsr render_x.build_temp_buffer

.put_middles:
		lda [.p_source],y
		jsr render_x.build_temp_buffer
		iny
		cpy <.window_width
		bne .put_middles

	;plp
	;bmi .do_queue
		lda #$fb
		jsr render_x.build_temp_buffer

		lda #LOW(render_x.temp_buffer)
		sta <.p_source
	;FALL_THROUGH_TO render_x.queue_bytes_from_buffer
.do_queue:
	jsr render_x.queue_bytes_from_buffer
	jsr render_x.queue_attributes
	;; --- 
	inc <.offset_y	;;originally 'field.upload_window_content's role
	inc <.lines_drawn	;;originally caller's responsibility, it remains true but for bottom border we need prospective value
	rts
;--------------------------------------------------------------------------------------------------
render_x.queue_top_border:
	DECLARE_WINDOW_VARIABLES
	ldy <.window_top
	dey
	;tya
	ldx #2
	jsr render_x.queue_border
	ldy <.window_top
	sty <.offset_y
	rts
;--------------------------------------------------------------------------------------------------
render_x.queue_bottom_border:
	DECLARE_WINDOW_VARIABLES
	lda <.window_top
	clc
	adc <.window_height
	tay
	ldx #5
	;;FALL_THROUGH_TO render_x.queue_border
;--------------------------------------------------------------------------------------------------
render_x.queue_border:
	DECLARE_WINDOW_VARIABLES
.p_source = $80
	sty <.offset_y
.put_borders:
	ldy #3
.get_parts:
		lda field_x.window_parts,x
		pha
		dex
		dey
		bne .get_parts
;; ---
	;; this will update buffer at $7c0-7ff.
	;; as the temp buffer this logic using is at $7d0-7ef
	;; it is needed to use the buffer before/after
	;; attr update completed.
	jsr render_x.queue_attributes

;; --- queue tiles.
	ldx #0
	pla
	jsr render_x.build_temp_buffer

	pla
	ldy <.window_width
.put_middles:
		jsr render_x.build_temp_buffer
		dey
		bne .put_middles
	pla
	jsr render_x.build_temp_buffer

	lda #LOW(render_x.temp_buffer)
	sta <.p_source
	lda #HIGH(render_x.temp_buffer)
	sta <.p_source+1
	;FALL_THROUGH_TO render_x.queue_bytes_from_buffer
;--------------------------------------------------------------------------------------------------
render_x.queue_bytes_from_buffer:
	DECLARE_WINDOW_VARIABLES
.source_index = $85
	ldx <.window_left
	bit <render_x.q.init_flags
	bmi .queue_bytes
		dex
.queue_bytes:
	txa
	pha	;; left
	;tax
	;;	A: left
	;;	X: left
	;;	Y: index into precalculated metrics
	ldy #0
	sty <.source_index
	jsr render_x.begin_queueing
	pla
	
	;; A <-- windowleft
	clc
	adc render_x.q.strides+0	;;1st bg
	and #$3f
	ldy #2
	;tax
	;jmp render_x.begin_queueing

;--------------------------------------------------------------------------------------------------
render_x.begin_queueing:
	DECLARE_WINDOW_VARIABLES
.temp_left = .offset_x
;; in:
;;	Y: target index
;;	A: left
	ldx render_x.q.strides,y
	beq render_x.rts_2

	sta <.temp_left
	txa
	pha	;;width
;; --- check if there enough space remaining in the buffer.
	jsr render_x.ensure_buffer_available
;; --- queue the addr to render.
	ldx <.temp_left
	lda <.offset_y
	;; X = window left
	jsr field_x.map_coords_to_vram

;;	A = vram high
;;	X = vram low
;;	S[0] = body length
render_x.queue_head_and_body:
.source_index = $85
.bias = $84
	;sta $2006
	;stx $2006
	ldy <render_x.q.available_bytes
	sta render_x.q.buffer,y
	iny
	txa
	sta render_x.q.buffer,y
	iny
	pla	;;width
	sta render_x.q.buffer,y
	iny
	pha	;;width
	;; calc ajusted offset
	;and #$f
	and #((1 << render_x.UNROLL_DEPTH) - 1)
	sta <.bias
	iny	;;offset should point the byte immediately after the tag bytes
	tya
	tax
	clc
	adc <.bias
	sta render_x.q.buffer-1,y
	;; ----
	pla	;; width
	clc
	adc <.source_index
	ldy <.source_index
	sta <.source_index
render_x.queue_bytes:
.source_index = $85
.p_buffer = $80
.temp_buffer = $7d0
	;ldx <render_x.q.available_bytes
.loop:
		;lda .temp_buffer,x
		lda [.p_buffer],y
		sta render_x.q.buffer,x
		inx
		iny
		cpy <.source_index
		bne .loop
	stx <render_x.q.available_bytes
render_x.rts_2:
	rts
;--------------------------------------------------------------------------------------------------
;; on entry, offset_y will have a valid value.
render_x.queue_attributes
	DECLARE_WINDOW_VARIABLES
.addr_offset = $84
.p_source = $80
.source_index = $85
	lda <.in_menu_mode
	bne .done
		;; in-place window. need attr updates
		lda <.offset_y
		cmp #30
		bcc .no_wrap
			sbc #30
			sta <.offset_y
	.no_wrap:
		lsr A
		bcs .done
			;; only update attr if the line on even boundary
			;pha
			;jsr render_x.is_attr_have_updated
			;pla
			;bcs .done
			lsr A
			asl A
			asl A
			asl A
			;sta <.addr_offset
			pha
			;; --- get attr cache updated.
			jsr field_x.inflate_window_metrics
			jsr field.init_window_attr_buffer	;ed56
			jsr field.update_window_attr_buff	;$c98f

			jsr field_x.shrink_window_metrics

			;; here field.bg_attr_table_cache ($0300) will have merged attributes
			lda #HIGH(field.bg_attr_table_cache)
			sta <.p_source+1
			lda #LOW(field.bg_attr_table_cache)
			sta <.p_source

			pla
			sta <.source_index
			pha
			lda #$23
			jsr .queue_attr
			pla
			ora #$40
			sta <.source_index
			lda #$27
.queue_attr:
			pha	;;vram high
			lda #8
			jsr render_x.ensure_buffer_available

			lda <.source_index			
			ora #$c0
			tax	;;vram low
			pla	;;vram high
			tay
			lda #8
			pha	;;width
			tya
			jmp render_x.queue_head_and_body
.skip_update:
.done:
	rts
;--------------------------------------------------------------------------------------------------
;; A = row in 16x16 unit
	;;TODO
	.if 0
render_x.is_attr_have_updated:
	pha
	and #1
	tax
	pla
	lsr A
	tay
	lda <render_x.q.done_attrs,x
	and floor_setBitMask,y
	eor floor_setBitMask,y
	sec
	beq .skip_update
		clc
		sta <render_x.q.done_attrs,x
.skip_update:
	rts
	.endif ;;TODO
;--------------------------------------------------------------------------------------------------
render_x.build_temp_buffer:
	sta render_x.temp_buffer,x
	inx
	rts
;--------------------------------------------------------------------------------------------------
render_x.init_as_no_borders:
	ldx #(render_x.NO_BORDERS|render_x.PENDING_INIT|render_x.RENDER_RUNNING)
	FALL_THROUGH_TO render_x.setup_deferred_rendering
;; in X: init flags
render_x.setup_deferred_rendering:
	DECLARE_WINDOW_VARIABLES
;; init deferred drawing.
	pha

	lda <render_x.q.init_flags
	asl A
	bmi	.done	;; already requested init

.first_init:
	;asl A
	;bpl .store_init_flags
		;jsr render_x.q.finalize
	;txa
	;ldx <.in_menu_mode
	;bne .store_init_flags
	;	ora #(render_x.NEED_SPRITE_DMA)
.store_init_flags:
	stx <render_x.q.init_flags
	
	jsr render_x.reset_states

	ldy <.window_left
	lda <.window_width
	pha	;;width

	tax
	bit <render_x.q.init_flags
	bmi .no_borders
		inx
		inx
		dey
.no_borders:
	stx <.window_width
	tya
	jsr field_x.calc_available_width_in_bg
	;; A = width 1st
	ldy #0
	sty <render_x.q.done_attrs
	;pha	;;width_1st
	;jsr render_x.precalc_params
	sta <render_x.q.strides+0
	;pla	;width_1st
	eor #$ff
	sec
	adc <.window_width
	;; A = width 2nd
	;jsr render_x.precalc_params
	sta <render_x.q.strides+2
	
	pla
	sta <.window_width
.done:
	pla	;;initial A
	rts
	VERIFY_PC_TO_PATCH_END field.window.renderer
;==================================================================================================
	RESTORE_PC floor.treasure.FREE_BEGIN
;--------------------------------------------------------------------------------------------------
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

;--------------------------------------------------------------------------------------------------
field_x.shrink_window_metrics:
	DECLARE_WINDOW_VARIABLES
	inc <.window_left
	inc <.window_top
	dec <.window_width
	dec <.window_width
	dec <.window_height
	dec <.window_height
	rts

field_x.inflate_window_metrics:
	DECLARE_WINDOW_VARIABLES
	dec <.window_left
	dec <.window_top
	inc <.window_width
	inc <.window_width
	inc <.window_height
	inc <.window_height
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

	VERIFY_PC_TO_PATCH_END floor.treasure
render_x.RENDERER_END:
    .endif  ;FAST_FIELD_WINDOW