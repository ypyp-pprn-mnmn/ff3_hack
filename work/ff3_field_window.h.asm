;; encoding: utf-8
;; ff3_field_window.h.asm
;;
;; description:
;;	constant declarations for 'field.window' modules
;;
;; version:
;;	0.1.0
;==================================================================================================
;;# of frames waited before text lines scolled up
	DEFINE_DEFAULT FIELD_WINDOW_SCROLL_FRAMES, $01

;_FEATURE_BORDER_LOADER
;OMIT_COMPATIBLE_FIELD_WINDOW
;_FEATURE_DEFERRED_RENDERING

DECLARE_WINDOW_VARIABLES	.macro
.menu_item_continue_building = $1e
.lines_drawn = $1f
.in_menu_mode = $37
.window_left = $38
.window_top = $39
.offset_x = $3a
.offset_y = $3b
.window_width = $3c
.window_height = $3d
.p_text = $3e
.output_index = $90
.width_in_1st = $91
.text_id = $92
.text_bank = $93
.p_text_table = $94	;;stores offset from $30000(18:8000) to the text 
.window_type = $96
;;
.tile_buffer_upper = $0780
.tile_buffer_lower = $07a0
	.endm

	.ifdef _FEATURE_DEFERRED_RENDERING

render_x.NMI_LOCALS_COUNT = $8

;; initialization flags.
render_x.NO_BORDERS = $80
render_x.PENDING_INIT = $40
render_x.RENDER_RUNNING = $20	;;or 'completed'
render_x.SKIP_CONTENTS = $08
render_x.NEED_SPRITE_DMA = $04
render_x.NEED_TOP_BORDER = $02
render_x.NEED_BOTTOM_BORDER = $01
;render_x.BUFFER_CAPACITY = $c0
render_x.BUFFER_CAPACITY = $c0
render_x.ADDR_CAPACITY = $0c

;; buffer and addresses are shared among for name table and attributes.
render_x.q.vram.buffer = $7320	;max 0xc0 bytes = 192 titles.
;; max 16 addresses.
render_x.q.vram.high = $73e0	
render_x.q.vram.low = $73f0

render_x.q.init_flags = $7300	;;this address isn't touched by floor's logic
render_x.q.available_bytes = $7301
render_x.q.addr_index = $7302
render_x.q.stride = $7303

;; pre-calculated internal parameters.
render_x.q.1st.nt.stride = $7308
render_x.q.1st.nt.buffer_bias = $7309
render_x.q.1st.nt.uploader_addr = $730a
render_x.q.2nd.nt.stride = $730c
render_x.q.2nd.nt.buffer_bias = $730d
render_x.q.2nd.uploader_addr = $730e

    .endif  ;;_FEATURE_DEFERRED_RENDERING
