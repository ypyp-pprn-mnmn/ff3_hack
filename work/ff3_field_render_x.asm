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
	ldx #(render_x.nmi.LOCALS_COUNT-1)
.push_variables:
		lda <$80,x
		pha
		dex
		bpl .push_variables
;; do rendering.
	lda #0
	sta <render_x.nmi.sequence
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
	ldx #~(render_x.nmi.LOCALS_COUNT-1)
.pop_variables:
		pla
		sta <$80+(render_x.nmi.LOCALS_COUNT),x
		inx
		bne .pop_variables
	pla
	tay
	pla
	tax
	pla
	rti
;--------------------------------------------------------------------------------------------------
;; A = scratch.
;; X = buffer offset.
;; Y = sequence index.
render_x.upload_loop:
	lda render_x.q.vram.buffer-$10,x
	sta $2007
	lda render_x.q.vram.buffer-$0f,x
	sta $2007
	lda render_x.q.vram.buffer-$0e,x
	sta $2007
	lda render_x.q.vram.buffer-$0d,x
	sta $2007
	lda render_x.q.vram.buffer-$0c,x
	sta $2007
	lda render_x.q.vram.buffer-$0b,x
	sta $2007
	lda render_x.q.vram.buffer-$0a,x
	sta $2007
	lda render_x.q.vram.buffer-$09,x
	sta $2007
	lda render_x.q.vram.buffer-$08,x
	sta $2007
	lda render_x.q.vram.buffer-$07,x
	sta $2007
	lda render_x.q.vram.buffer-$06,x
	sta $2007
	lda render_x.q.vram.buffer-$05,x
	sta $2007
	lda render_x.q.vram.buffer-$04,x
	sta $2007
	lda render_x.q.vram.buffer-$03,x
	sta $2007
	lda render_x.q.vram.buffer-$02,x
	sta $2007
	lda render_x.q.vram.buffer-$01,x
	sta $2007

;; overhead = 13-14 cpu cycles
;; A = scratch.
;; X = buffer offset.
;; Y = render target index.
.next:
	txa
	clc
	adc #$10
	tax
	cpx <render_x.nmi.eol_offset
	bne render_x.upload_loop
	;beq render_x.upload_next

;; overhead = 32 cpu cycles.
;; A = scratch.
;; X = buffer offset.
;; Y = render target index.
render_x.upload_next:
	DECLARE_WINDOW_VARIABLES
	pla	;;bytes have been uploaded.
	clc
	adc render_x.q.stride,y
	cmp render_x.q.available_bytes
	bcc render_x.render_deferred_contents

;; out:
;;	A: #0
render_x.reset_states:
	lda #render_x.FULL_OF_FUEL
	sta render_x.q.fuel
	lda #0
	ldy #(render_x.nmi.STATE_VARIABLES_END - render_x.nmi.STATE_VARIABLES_BASE)
.reset:
		sta render_x.nmi.STATE_VARIABLES_BASE-1,y
		;sta render_x.q.available_bytes	;;this frees up a waiting thread
		dey
		bne .reset
	rts

;; overhead = 46 cpu cycles.
;; in:
;;	A = bytes uploaded, as loop counter
render_x.render_deferred_contents:
	DECLARE_WINDOW_VARIABLES
	pha								;;	3
	;; setup vram address.
	ldy <render_x.nmi.sequence		;;	6
	lda render_x.q.vram.high,y		;;	10
	sta $2006						;;	14
	lda render_x.q.vram.low,y		;;	18
	sta $2006						;;	22
	inc <render_x.nmi.sequence		;;	27
	;; determine the target.
	;lsr render_x.q.is_2nd+1			;;	33
	;ror render_x.q.is_2nd			;;	39
	;rol A							;;	41
	;lsr render_x.q.is_attr+1		;;	47
	;ror render_x.q.is_attr			;;	53
	;rol A							;;	55
	;and #3							;;	57
	lda render_x.q.target_index,y	;;	31
	tay								;;	33
	pla								;;	37
	
	pha								;;	3
	clc								;;	5
	adc render_x.q.stride,y			;;	9
	clc								;;	11
	adc #($10)						;;	13
	sta <render_x.nmi.eol_offset	;;	16
	pla								;;	20
	pha								;;	23
	clc								;;	25
	adc render_x.q.buffer_bias,y	;;	29
	tax								;;	31
	;; do indirect jump.
	lda render_x.q.start_addr.high,y
	pha
	lda render_x.q.start_addr.low,y
	pha
	rts	;;indirect jump
	;jmp [render_x.q.1st.nt.uploader_addr]
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
	rts
;--------------------------------------------------------------------------------------------------
;; in A: bytes to ensure
render_x.ensure_buffer_available:
	DECLARE_WINDOW_VARIABLES
	jsr render_x.remove_nmi_handler	;; preserves A.

	;lda render_x.q.available_bytes
	;clc
	;adc render_x.q.stride
	;cmp #render_x.BUFFER_CAPACITY
	;bcs render_x.await_complete_rendering

	;lda render_x.q.addr_index
	;cmp #render_x.ADDR_CAPACITY	;;rendering up to X lines at once (or exceed the nmi duration)
	;bcc render_x.rts_1
	clc
	adc #render_x.FUEL_FOR_OVERHEAD
	eor #$ff
	tax
	adc render_x.q.fuel
	bcs .available	;;ok. carry set = adding negative value resulted in overflow.
		txa
		pha
		jsr render_x.await_complete_rendering
		pla
		clc
		adc render_x.q.fuel
.available:
	sta render_x.q.fuel
render_x.rts_1:	
	rts

render_x.await_complete_rendering:
	jsr render_x.set_deferred_renderer
.wait_nmi:
	lda render_x.q.available_bytes
	bne .wait_nmi
	;; FIXME: this is a temporary measure to workaround PRG bank mismatch on nmi
	jmp field_x.advance_frame_no_wait	;;inc <.frame_counter + call sound driver

;--------------------------------------------------------------------------------------------------
render_x.begin_queueing:
	DECLARE_WINDOW_VARIABLES
;; --- check if there enough space remaining in the buffer.
	ldx <.window_left
	bit render_x.q.init_flags
	bmi .skip_borders
		dex
.skip_borders:
	txa

	pha
	ldy #0
	ldx render_x.q.stride+0	;;1st bg
	jsr .push_addrs
	pla
	
	;; A <-- windowleft
	clc
	adc render_x.q.stride+0	;;1st bg
	and #$3f
	ldy #2
	ldx render_x.q.stride+2	;;2nd bg

;; in:
;;	A: left
;;	X: width
;;	Y: target index
;;	P: result of bit test against the width
.push_addrs:
;.temp_target = $83
	beq render_x.rts_2
	pha
	
	tya
	ldy render_x.q.addr_index
	sta render_x.q.target_index,y

	txa
	jsr render_x.ensure_buffer_available
;; --- attr check.
	jsr render_x.queue_attributes
;; --- queue the addr to render.
	pla
	tax

	FALL_THROUGH_TO render_x.queue_vram_addr

;; X = window left
;; $80 = target index
render_x.queue_vram_addr:
.temp_target = $83
	DECLARE_WINDOW_VARIABLES
	lda <.offset_y
	jsr field_x.map_coords_to_vram
	ldy render_x.q.addr_index
	sta render_x.q.vram.high,y
	txa
	sta render_x.q.vram.low,y
	;sta $2006
	;stx $2006
	inc render_x.q.addr_index
	rts

render_x.queue_top_border:
	DECLARE_WINDOW_VARIABLES
	ldy <.window_top
	dey
	tya
	ldx #2
	jsr render_x.queue_border
	ldy <.window_top
	sty <.offset_y
	rts

render_x.queue_bottom_border:
	DECLARE_WINDOW_VARIABLES
	lda <.window_top
	clc
	adc <.window_height
	ldx #8
	FALL_THROUGH_TO render_x.queue_border

render_x.queue_border:
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

	jsr render_x.begin_queueing
;; --- queue tiles.
	
	ldx render_x.q.available_bytes
	pla
	jsr render_x.queue_byte

	pla
	ldy <.window_width
.put_middles:
		jsr render_x.queue_byte
		dey
		bne .put_middles
	pla
	;jmp render_x.queue_byte
	FALL_THROUGH_TO render_x.queue_byte

render_x.queue_byte:
	sta render_x.q.vram.buffer,x
	inx
	stx render_x.q.available_bytes
	
render_x.rts_2:
	rts

render_x.queue_content:
	DECLARE_WINDOW_VARIABLES
.p_source = $80
	pha
	jsr render_x.begin_queueing

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
	ldx render_x.q.available_bytes


	ldy #0
	bit render_x.q.init_flags
	php
	bmi .put_middles
		lda #$fa
		jsr render_x.queue_byte

.put_middles:
		lda [.p_source],y
		jsr render_x.queue_byte
		iny
		cpy <.window_width
		bne .put_middles


	plp
	bmi render_x.rts_2
		lda #$fb
		jmp render_x.queue_byte

;; on entry, offset_y will have valid value.
render_x.queue_attributes:
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

;--------------------------------------------------------------------------------------------------
render_x.finalize:
	lda render_x.q.available_bytes
	beq .completed
		jsr render_x.await_complete_rendering
.completed:
	;; XXX:
	;;  in cases of paging in window,
	;;	the rendering continues even if it reached the bottom of window.
	;lda #0
	;sta render_x.q.init_flags
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

	lda render_x.q.init_flags
	asl A
	bmi	.done	;; already requested init

.first_init:
	asl A
	bpl .store_init_flags
		;jsr render_x.q.finalize
	;txa
	;ldx <.in_menu_mode
	;bne .store_init_flags
	;	ora #(render_x.NEED_SPRITE_DMA)
.store_init_flags:
	stx render_x.q.init_flags
	
	jsr render_x.reset_states

	ldy <.window_left
	lda <.window_width
	pha	;;width

	tax
	bit render_x.q.init_flags
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
	pha	;;width_1st
	jsr render_x.precalc_params
	pla	;width_1st
	eor #$ff
	sec
	adc <.window_width
	;; A = width 2nd
	jsr render_x.precalc_params
	
	pla
	sta <.window_width
.done:
	pla	;;initial A
	rts

;; in A = bytes needed
;; in,out Y = sequence index
render_x.precalc_params:
	DECLARE_WINDOW_VARIABLES
.p_jump = $80

	pha
	;; calc params for nametable.
	;; even-numberd index (here stored in Y) represents nametable.
	jsr .calc_and_store
	pla
	;; calc params for attributes.
	;; odd-numberd index (here stored in Y) represents attrtable.
	clc
	adc #1
	lsr A
	;; fall through.
.calc_and_store:
	sta render_x.q.stride,y
	pha
	clc
	and #$f
	bne .align
		ora #$10
.align:
	sta render_x.q.buffer_bias,y

	pla
	eor #$0f
	clc
	adc #1
	and #$0f
	asl A
	sta <.p_jump	;;x2
	asl A
	adc <.p_jump	;;x2+x4
	adc #LOW(render_x.upload_loop-1)
	sta render_x.q.start_addr.low,y
	lda #0
	;;here A == 0
	adc #HIGH(render_x.upload_loop-1)
	sta render_x.q.start_addr.high,y
	iny
	rts



;==================================================================================================

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
    ;VERIFY_PC_TO_PATCH_END textd
	VERIFY_PC_TO_PATCH_END field.window.renderer
render_x.RENDERER_END:
    .endif  ;FAST_FIELD_WINDOW