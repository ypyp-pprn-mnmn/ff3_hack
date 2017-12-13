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

;; ------------------------------------------------------------------------------------------------
;; initialization flags.
render_x.NO_BORDERS = $80
render_x.PENDING_INIT = $40
render_x.RENDER_RUNNING = $20	;;or 'completed'
render_x.SKIP_CONTENTS = $08
render_x.NEED_SPRITE_DMA = $04
render_x.NEED_TOP_BORDER = $02
render_x.NEED_BOTTOM_BORDER = $01
;; capacity limits.
;render_x.BUFFER_CAPACITY = $c0
render_x.BUFFER_CAPACITY = $80
render_x.ADDR_CAPACITY = $0c
;; the fuel denotes available cpu cycles for rendering in
;; units of which need to put 1 byte onto vram (= 8 cpu cycle in current impl.)
;; as rendering occurred in NMI, there also need bookkeeping ops so that
;; approximately the cycles below will be available for the rendering,
;; at the begininng of each NMI.
;;	18 scanlines x 113.6 cpu cycles (= 341 ppu cycles)
render_x.FULL_OF_FUEL = (2044 >> 3)	;;2044 = 18 * 113.6, 2158 = 19 * 113.6.
render_x.FUEL_FOR_OVERHEAD = ((120 >> 3) + 1)

;; ------------------------------------------------------------------------------------------------
render_x.nmi.LOCALS_COUNT = $8
render_x.nmi.STATE_VARIABLES_BASE = $c2
render_x.nmi.STATE_VARIABLES_END = $d0

render_x.nmi.eol_offset = $80
render_x.nmi.sequence = $81
render_x.nmi.sequence_index = $82
render_x.nmi.target_index = $83
;; ------------------------------------------------------------------------------------------------

;; state controls
render_x.q.init_flags = $c0	;;this address isn't touched by floor's logic
render_x.q.fuel = $c1	;;if exhausted, then flush queue (await completion of pending rendering)
render_x.q.available_bytes = $c2
render_x.q.addr_index = $c3
render_x.q.target_index = $c4	;;12bytes.
;render_x.q.attr_pending = $7308	;;2bytes. 1bit per vertical line. lower first.

;; pre-calculated internal parameters.
;; index order:
;; nambtable on 1st bg, attr on 1st bg, 
;; nambtable on 2nd bg, attr on 2nd bg, 
;render_x.q.available_bytes = $7308
render_x.q.stride = $7310
render_x.q.buffer_bias = $7314
render_x.q.start_addr.low = $7318
render_x.q.start_addr.high = $731c
;; max 16 addresses.
render_x.q.vram.low = $7320
render_x.q.vram.high = $7330
;; buffer and addresses are shared among for name table and attributes.
render_x.q.vram.buffer = $7340	;max 0xc0 bytes = 192 titles.
    .endif  ;;_FEATURE_DEFERRED_RENDERING
