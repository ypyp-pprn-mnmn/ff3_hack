; encoding: utf-8
;   ff3_textd.asm
;
; description:
;   re-implementation of the text-driver 'textd' functions
;
;======================================================================================================
	
textd.patch_begin:
	.ifdef FAST_FIELD_WINDOW
	INIT_PATCH $3f,$eefa,$f38a
;; -------------------------
DECLARE_TEXTD_VARIABLES	.macro
	;; --- variables.
.output_index = $90
.text_id = $92
.text_bank = $93
.p_text_table = $94	;;stores offset from $30000(18:8000) to the text 
;; floor
.inn_charge = $61	;24 bits.
.treasure_item_id = $bb
;; textd
.p_text_line = $1c
.menu_item_continue_building = $1e
.lines_drawn = $1f
;; temporary.
.cached_param = $67
.parameter_byte = $84
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

	.endm

;; ------------------------------------------------------------------------------------------------
textd_x.seek_source_buffer:
	DECLARE_TEXTD_VARIABLES
	inc <.p_text
	bne .source_buffer_incremented
		inc <.p_text+1
.source_buffer_incremented:
	rts
;; ---------------------------------------------------------------------

;textd_x.continue_with_text:
;	jmp field_x.switch_to_text_bank
	
;; ---------------------------------------------------------------------
textd_x.handle_printables:
	DECLARE_TEXTD_VARIABLES
    ;cmp #$5C                            ; EF0A C9 5C
	cmp #CHAR.NEED_COMPOSITION_END
    ;bcc .need_composition               ; EF0C 90 19
	bcc textd_x.composite_char_and_continue
    ldy <.output_index                  ; EF0E A4 90
    ldx <.in_menu_mode                  ; EF10 A6 37
    bne .icons_supported                ; EF12 D0 06
    ;cmp #$70                            ; EF14 C9 70
	cmp #CHAR.AVAILABLE_ONLY_IN_MENU_BEGIN
    bcs .icons_supported                ; EF16 B0 02
    lda #$FF                            ; EF18 A9 FF
.icons_supported:
    sta .tile_buffer_lower,y            ; EF1A 99 A0 07
    lda #$FF                            ; EF1D A9 FF
	bne textd_x.write_upper_and_continue
    ;sta .tile_buffer_upper,y            ; EF1F 99 80 07
    ;inc <.output_index                  ; EF22 E6 90
    ;jmp textd.draw_in_box               ; EF24 4C FA EE

textd_x.composite_char_and_continue:
	DECLARE_TEXTD_VARIABLES
.need_composition: 
    sec ; EF27 38
    sbc #CHAR.REPLACEMENT_END           ; EF28 E9 28
    tax ; EF2A AA
    ldy <.output_index                  ; EF2B A4 90
    lda textd.tile_map_lower,x          ; EF33 BD E1 F4
    sta .tile_buffer_lower,y            ; EF36 99 A0 07
    lda textd.tile_map_upper,x          ; EF2D BD 15 F5
	FALL_THROUGH_TO textd_x.write_upper_and_continue
    ;sta .tile_buffer_upper,y            ; EF30 99 80 07
    ;inc <.output_index                  ; EF39 E6 90
    ;jmp textd.draw_in_box     ; EF3B 4C FA EE

textd_x.write_upper_and_continue:
	DECLARE_TEXTD_VARIABLES
    sta .tile_buffer_upper,y            ; EF1F 99 80 07
    inc <.output_index                  ; EF22 E6 90
	;FALL_THROUGH_TO textd_x.continue_with_text
	FALL_THROUGH_TO textd.draw_in_box
;; ---------------------------------------------------------------------

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
;; fixups. note: all these are recursive call (including tail recursion)
	;FIX_ADDR_ON_CALLER $3f,$eee4+1
	;FIX_ADDR_ON_CALLER $3f,$f0d8+1
	;FIX_ADDR_ON_CALLER $3f,$f33f+1
	;FIX_ADDR_ON_CALLER $3f,$ef24+1
	;FIX_ADDR_ON_CALLER $3f,$f345+1
	;FIX_ADDR_ON_CALLER $3f,$f387+1
;; variables
	DECLARE_TEXTD_VARIABLES
;; --- begin.
    ldy #$00                            ; EEFA A0 00
    lda [.p_text],y                     ; EEFC B1 3E
    beq field_x.clc_return              ; EEFE F0 F1
;    inc <.p_text                        ; EF00 E6 3E
;    bne .test_charcode                  ; EF02 D0 02
;    inc <.p_text+1                      ; EF04 E6 3F
;.test_charcode:
	jsr textd_x.seek_source_buffer
;    cmp #$28                            ; EF06 C9 28
	cmp #CHAR.REPLACEMENT_END
    ;bcc .not_printable_char             ; EF08 90 34
	;bcc textd_x.handle_ctrl_codes
	bcs textd_x.handle_printables
; ----------------------------------------------------------------------------
textd_x.handle_ctrl_codes:
	DECLARE_TEXTD_VARIABLES
.p_handler = $80
;.char_code_temp = $82
.not_printable_char:

	tax
	lda textd_x.ctrl_code_handlers.low,x
	sta <.p_handler+0
	lda textd_x.ctrl_code_handlers.high_and_flags,x
	pha
	and #$07
	clc
	adc #HIGH(textd_x.code_handlers_base)
	sta <.p_handler+1
	pla
	;bpl textd_x.invoke_handlers_with_care
	bmi textd_x.just_invoke_handlers
		;;handlers don't want to handle exit by its own
		;;it's fine to call 'field_x.switch_to_text_bank' regardless of current bank
		;and #$f0
		;pha
		jsr textd_x.just_invoke_handlers
		;pla
		;bne textd_x.continue_with_text
		;beq textd.draw_in_box
textd_x.continue_with_text:
			jsr field_x.switch_to_text_bank
			bne textd.draw_in_box
		;beq textd.draw_in_box
;.exit_handled_by_handlers:
textd_x.just_invoke_handlers:
	DECLARE_TEXTD_VARIABLES
.p_handler = $80
	txa
    cmp #$10                            ; EF3E C9 10
	pha
    ;bcc .control_char                   ; EF40 90 03
	bcc .dispatch_handler
		;jmp textd.eval_replacement          ; EF42 4C 2A F0
		;pha ; F02A 48
		ldx <.cached_param                  ; F02B A6 67
		cmp #$1D                            ; F02D C9 1D
		beq .L_F034                         ; F02F F0 03
		lda [.p_text],y                     ; F031 B1 3E
		tax ; F033 AA
	.L_F034:
		stx <.parameter_byte                ; F034 86 84
		stx <.cached_param                  ; F036 86 67
		;inc <.p_text                        ; F038 E6 3E
		;bne .L_F03E                         ; F03A D0 02
		;inc <.p_text+1                      ; F03C E6 3F
	;.L_F03E:
		jsr textd_x.seek_source_buffer
		;pla ; F03E 68
.dispatch_handler:
	pla
	jmp [.p_handler]
; ----------------------------------------------------------------------------
;.control_char:
    ;cmp #$01                            ; EF45 C9 01
    ;bne .case_2                         ; EF47 D0 12
textd_x.code_handlers_base:
; ----------------------------------------------------------------------------
textd_x.on_code_01:	;;HANDLE_EXIT_IN_OWN
	DECLARE_TEXTD_VARIABLES
;;case_1: ;;eol.
    jsr field.draw_window_content       ; EF49 20 92 F6
    inc <.lines_drawn                   ; EF4C E6 1F
	bne textd_x.continue_from_next_line	;;always true, assuming lines_drawn never reaching to 0xff
; ----------------------------------------------------------------------------
textd_x.on_code_09:	;;HANDLE_EXIT_IN_OWN
	DECLARE_TEXTD_VARIABLES
.case_9:	;;pad to eol.
    ;cmp #$09                            ; EFDA C9 09
    ;bne .case_0a                        ; EFDC D0 06
    jsr field.draw_window_content       ; EFDE 20 92 F6
    ;jmp .next_line                      ; EFE1 4C 4E EF
	FALL_THROUGH_TO textd_x.continue_from_next_line

textd_x.continue_from_next_line:
	DECLARE_TEXTD_VARIABLES
;.next_line: 
    inc <.lines_drawn                   ; EF4E E6 1F
    lda <.lines_drawn                   ; EF50 A5 1F
    cmp <.window_height                 ; EF52 C5 3D
    ;bcc .continue_drawing               ; EF54 90 02
	bcc textd.draw_in_box
    sec ; EF56 38
    rts ; EF57 60
; ----------------------------------------------------------------------------
;.continue_drawing:
    ;jmp textd.draw_in_box     ; EF58 4C FA EE
; ----------------------------------------------------------------------------
textd_x.on_code_0a:	;;HANDLE_EXIT_IN_OWN
	DECLARE_TEXTD_VARIABLES
.case_0a:	;;paging.
    ;cmp #$0A                            ; EFE4 C9 0A
    ;bne .case_0b                        ; EFE6 D0 04
    lda #$09                            ; EFE8 A9 09
    clc ; EFEA 18
    rts ; EFEB 60
; ----------------------------------------------------------------------------
textd_x.on_code_03:	;;CONTINUE_WITH_TEXT
	DECLARE_TEXTD_VARIABLES
.case_3:	;;item price.
    ;cmp #$03                            ; EF6A C9 03
    ;bne .case_4                         ; EF6C D0 0E
    jsr switch_to_character_logics_bank ; EF6E 20 27 F7
    ldx <.treasure_item_id              ; EF71 A6 BB
    jsr floor.get_item_price            ; EF73 20 D4 F5
	jmp $8B78 
    ;jsr $8B78                           ; EF76 20 78 8B
    ;jmp textd.continue_with_text        ; EF79 4C 91 F2
; ----------------------------------------------------------------------------
textd_x.on_code_04:	;;CONTINUE_WITH_TEXT
	DECLARE_TEXTD_VARIABLES
.case_4:	;;inn charge.
    ;cmp #$04                            ; EF7C C9 04
    ;bne .case_5                         ; EF7E D0 15
    lda <.inn_charge                    ; EF80 A5 61
    sta <$80                            ; EF82 85 80
    lda <.inn_charge+1                  ; EF84 A5 62
    sta <$81                            ; EF86 85 81
    lda <.inn_charge+2                  ; EF88 A5 63
    sta <$82                            ; EF8A 85 82
    jsr switch_to_character_logics_bank ; EF8C 20 27 F7
	jmp $8b78
    ;jsr $8B78                           ; EF8F 20 78 8B
    ;jmp textd.continue_with_text        ; EF92 4C 91 F2
; ----------------------------------------------------------------------------
textd_x.on_code_05:	;;CONTINUE_WITH_TEXT
	DECLARE_TEXTD_VARIABLES
.case_5: 	;;party gil.
    ;cmp #$05                            ; EF95 C9 05
    ;bne .case_6                         ; EF97 D0 09
    jsr switch_to_character_logics_bank ; EF99 20 27 F7
	jmp $8b03
    ;jsr $8B03                           ; EF9C 20 03 8B
    ;jmp textd.continue_with_text        ; EF9F 4C 91 F2
; ----------------------------------------------------------------------------
textd_x.on_code_08:	;;CONTINUE_WITH_TEXT
	DECLARE_TEXTD_VARIABLES
.case_8:	;;capacity.
    ;cmp #$08                            ; EFBB C9 08
    ;bne .case_9                         ; EFBD D0 1B
    lda party.capacity                  ; EFBF AD 1B 60
    sta <$80                            ; EFC2 85 80
    lda #$00                            ; EFC4 A9 00
    sta <$81                            ; EFC6 85 81
    jsr switch_to_character_logics_bank ; EFC8 20 27 F7
    jsr $8B57                          ; EFCB 20 57 8B
    ldx <.output_index                  ; EFCE A6 90
    inc <.output_index                  ; EFD0 E6 90
    lda #$5C                            ; EFD2 A9 5C
    sta .tile_buffer_lower,x            ; EFD4 9D A0 07
    ;jmp textd.continue_with_text	; EFD7 4C 91 F2
	rts
; ----------------------------------------------------------------------------
textd_x.on_code_0d:	;;CONTINUE_WITH_TEXT
	DECLARE_TEXTD_VARIABLES
.case_0d:
    ;cmp #$0D                            ; EFFA C9 0D
    ;bne .case_0f                        ; EFFC D0 09
    jsr switch_to_character_logics_bank ; EFFE 20 27 F7
	jmp $8b34
    ;jsr $8B34                           ; F001 20 34 8B
    ;jmp textd.continue_with_text        ; F004 4C 91 F2
; ----------------------------------------------------------------------------
textd_x.on_code_02:	;;HANDLE_EXIT_IN_OWN
	DECLARE_TEXTD_VARIABLES
.case_2:	;;item name of treasure which has just been gotten. $bb := item_id
    ;cmp #$02                            ; EF5B C9 02
    ;bne .case_3                         ; EF5D D0 0B
    lda <.treasure_item_id              ; EF5F A5 BB
    sta <$84                            ; EF61 85 84
    lda #$00                            ; EF63 A9 00
    sta <$B9                            ; EF65 85 B9
    jmp textd.deref_param_text          ; EF67 4C 9D F0
; ----------------------------------------------------------------------------
textd_x.on_code_07:	;;HANDLE_EXIT_IN_OWN
	DECLARE_TEXTD_VARIABLES
.case_7:	;; ally NPC name
    ;cmp #$07                            ; EFA9 C9 07
    ;bne .case_8                         ; EFAB D0 0E
    lda party.ally_npc                  ; EFAD AD 0B 60
    ;beq .break_case                     ; EFB0 F0 F4
	beq textd_x.nop_code_handler
    ;sec ; EFB2 38
    ;sbc #$01                            ; EFB3 E9 01
    ;clc ; EFB5 18
    ;adc #$F8                            ; EFB6 69 F8
	clc
	adc #$f7
    jmp textd.deref_text_id             ; EFB8 4C D8 F2
; ----------------------------------------------------------------------------
textd_x.on_code_0c:	;;HANDLE_EXIT_IN_OWN
	DECLARE_TEXTD_VARIABLES
.case_0c:	;;leader name
    ;cmp #$0C                            ; EFF0 C9 0C
    ;bne .case_0d                        ; EFF2 D0 06
    ldx party.leader_offset             ; EFF4 AE 0E 60
    jmp textd.draw_player_name          ; EFF7 4C 16 F3
; ----------------------------------------------------------------------------
textd_x.on_code_0f:	;;JUST_CONTINUE
	DECLARE_TEXTD_VARIABLES
.case_0f:	;;dustbox
    ;cmp #$0F                            ; F007 C9 0F
    ;bne .case_0e                        ; F009 D0 1C
    ldx <.output_index                  ; F00B A6 90
    lda #$58                            ; F00D A9 58
    sta .tile_buffer_upper,x            ; F00F 9D 80 07
    lda #$59                            ; F012 A9 59
    sta .tile_buffer_upper+1,x          ; F014 9D 81 07
    lda #$5A                            ; F017 A9 5A
    sta .tile_buffer_lower,x            ; F019 9D A0 07
    lda #$5B                            ; F01C A9 5B
    sta .tile_buffer_lower+1,x          ; F01E 9D A1 07
    txa ; F021 8A
    clc ; F022 18
    adc #$02                            ; F023 69 02
    sta <.output_index                  ; F025 85 90
	FALL_THROUGH_TO textd_x.nop_code_handler
; ----------------------------------------------------------------------------
textd_x.on_code_0b:	;;JUST_CONTINUE
	DECLARE_TEXTD_VARIABLES
.case_0b:	;;not implemented (nop)
    ;cmp #$0B                            ; EFEC C9 0B
    ;bne .case_0c                        ; EFEE D0 00
; ----------------------------------------------------------------------------
textd_x.on_code_06:	;;JUST_CONTINUE
	DECLARE_TEXTD_VARIABLES
.case_6:	;;not implemented (nop)
    ;cmp #$06                            ; EFA2 C9 06
    ;bne .case_7                         ; EFA4 D0 03
.break_case:
    ;jmp textd.draw_in_box     ; EFA6 4C FA EE
; ----------------------------------------------------------------------------
textd_x.on_code_0e:	;;JUST_CONTINUE
	DECLARE_TEXTD_VARIABLES
.case_0e: ;;not implemented (nop)
    ;jmp textd.draw_in_box     ; F027 4C FA EE
; ----------------------------------------------------------------------------
textd_x.on_code_23:	;;JUST_CONTINUE
textd_x.on_code_24:	;;JUST_CONTINUE
textd_x.on_code_25:	;;JUST_CONTINUE
textd_x.on_code_26:	;;JUST_CONTINUE
textd_x.on_code_27:	;;JUST_CONTINUE
textd_x.nop_code_handler:
	rts

; ----------------------------------------------------------------------------
textd_x.on_code_1c:	;;CONTINUE_WITH_TEXT
	DECLARE_TEXTD_VARIABLES
.case_1c:
	;; number of item of which is stored in the backpack,
	;; at the index specified by parameter
    ;cmp #$1C                            ; F13F C9 1C
    ;bne .case_1d                        ; F141 D0 09
    ldx <.parameter_byte                ; F143 A6 84
    lda party.backpack.item_count,x     ; F145 BD E0 60
    ;beq .break_case_f111                ; F148 F0 C7
	beq textd_x.nop_code_handler
    ;bne .L_F166                         ; F14A D0 1A
	bne textd.draw_item_amount
; ----------------------------------------------------------------------------
textd_x.on_code_1d:	;;CONTINUE_WITH_TEXT
	DECLARE_TEXTD_VARIABLES
.case_1d:	;;fatty choccobo. param: index in the list
    ;cmp #$1D                            ; F14C C9 1D
    ;bne .case_1e                        ; F14E D0 2A
    lda <.parameter_byte                ; F150 A5 84
    lsr a                               ; F152 4A
    lda #$0A                            ; F153 A9 0A
    bcc .L_F159                         ; F155 90 02
    lda #$18                            ; F157 A9 18
.L_F159:
    sta <.output_index                  ; F159 85 90
    ldx <.parameter_byte                ; F15B A6 84
	;; 7c00 = item_id, where x = index in the stomach.
    lda menu.available_items_in_stomach,x ; F15D BD 00 7C
    ;;beq .break_case_f111                ; F160 F0 AF
	beq textd_x.nop_code_handler
    tax ; F162 AA
	;; $6300 = number of items, where x = item_id
    lda party.item_amount_in_stomach,x  ; F163 BD 00 63
	FALL_THROUGH_TO textd.draw_item_amount

;;A = amount
textd.draw_item_amount:
	DECLARE_TEXTD_VARIABLES
.L_F166:
    sta <$80                            ; F166 85 80
    ldx <.output_index                  ; F168 A6 90
    inc <.output_index                  ; F16A E6 90
	;;c8 = ':'
    lda #$C8                            ; F16C A9 C8
    sta .tile_buffer_lower,x            ; F16E 9D A0 07
    jsr switch_to_character_logics_bank ; F171 20 27 F7
    ;jsr $8B29                           ; F174 20 29 8B
	jmp $8b29
    ;;jmp textd.continue_with_text        ; F177 4C 91 F2
	;rts	;;CONTINUE_WITH_TEXT
; ----------------------------------------------------------------------------
textd_x.on_code_21:	;;CONTINUE_WITH_TEXT
	DECLARE_TEXTD_VARIABLES
.case_21:
	;;item price listed in shop. param = index.
    ;cmp #$21                            ; F1D1 C9 21
    ;bne .case_22                        ; F1D3 D0 24
    ldx <.parameter_byte                ; F1D5 A6 84
	;;$7b80 = item list in shop
    lda menu.shop_offerings,x           ; F1D7 BD 80 7B
    ;beq .break_case_f1f6                ; F1DA F0 1A
	beq textd_x.nop_code_handler
    lda menu.shop_item_price.low,x      ; F1DC BD 90 7B
    sta <$80                            ; F1DF 85 80
    lda menu.shop_item_price.mid,x      ; F1E1 BD 98 7B
    sta <$81                            ; F1E4 85 81
    lda menu.shop_item_price.high,x     ; F1E6 BD A0 7B
    sta <$82                            ; F1E9 85 82
    jsr switch_to_character_logics_bank ; F1EB 20 27 F7
    ;jsr $8B78                           ; F1EE 20 78 8B
	jmp $8b78
    ;lda <.text_bank                     ; F1F1 A5 93
    ;jsr call_switch_2banks          ; F1F3 20 03 FF
;.L_F1F6:
;.break_case_f1f6:
    ;jmp textd.draw_in_box     ; F1F6 4C FA EE
; ----------------------------------------------------------------------------
    ;VERIFY_PC $f02a
    ;INIT_PATCH $3f,$f02a,$f38a
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
;textd.eval_replacement:

;;static reference
;; ---
;    pha ; F02A 48
;    ldx <.cached_param                  ; F02B A6 67
;    cmp #$1D                            ; F02D C9 1D
;    beq .L_F034                         ; F02F F0 03
;    lda [.p_text],y                     ; F031 B1 3E
;    tax ; F033 AA
;.L_F034:
;    stx <.parameter_byte                ; F034 86 84
;    stx <.cached_param                  ; F036 86 67
;    inc <.p_text                        ; F038 E6 3E
;    bne .L_F03E                         ; F03A D0 02
;    inc <.p_text+1                      ; F03C E6 3F
;.L_F03E:
;    pla ; F03E 68
;    cmp #$14                            ; F03F C9 14
;    bcs .L_F046                         ; F041 B0 03
;    jmp textd.eval_code_10_13    ; F043 4C 39 F2
; ----------------------------------------------------------------------------
;.L_F046:
;    bne .case_15_17                     ; F046 D0 07
textd_x.on_code_14:	;;JUST_CONTINUE
	DECLARE_TEXTD_VARIABLES
;;case 0x14:	;; padding, offset dest buffer by the number specified in parameter byte
    lda <.parameter_byte                ; F048 A5 84
    sta <.output_index                  ; F04A 85 90
    ;jmp textd.draw_in_box     ; F04C 4C FA EE
	rts
; ----------------------------------------------------------------------------
textd_x.on_code_15:	;;JUST_CONTINUE
textd_x.on_code_16:	;;JUST_CONTINUE
textd_x.on_code_17:	;;JUST_CONTINUE
	DECLARE_TEXTD_VARIABLES
.case_15_17:
	;; setup command window. param: space fill.
	;; 15 = (new-game; menu; equip; job)
	;; 16 = (magic setup; item target; shop offerings;)
	;; 17 = (items to equip; items to use; items to sell; (fatty choccobo))
    ;cmp #$18                            ; F04F C9 18
    ;bcs .case_18	;L_F09B             ; F051 B0 48
    sec ; F053 38
    sbc #$15                            ; F054 E9 15
    clc ; F056 18
    adc #$78                            ; F057 69 78
    sta <$81                            ; F059 85 81
    lda #$00                            ; F05B A9 00
    sta <$80                            ; F05D 85 80
    lda <.parameter_byte                ; F05F A5 84
    sta <.output_index                  ; F061 85 90
    lda [.p_text],y                     ; F063 B1 3E
    sta <$82                            ; F065 85 82
    iny ; F067 C8
    lda [.p_text],y                     ; F068 B1 3E
    sta <$83                            ; F06A 85 83
    ldy #$F1                            ; F06C A0 F1
    lda [$80],y                         ; F06E B1 80
    ldx <.menu_item_continue_building   ; F070 A6 1E
    bne .L_F077                         ; F072 D0 03
    inc <.menu_item_continue_building   ; F074 E6 1E
    txa ; F076 8A
.L_F077:
    tax ; F077 AA
    clc ; F078 18
    adc #$04                            ; F079 69 04
    sta [$80],y                         ; F07B 91 80
    txa ; F07D 8A
    tay ; F07E A8
    lda <.parameter_byte                ; F07F A5 84
    clc ; F081 18
    adc <$97                            ; F082 65 97
    sta [$80],y                         ; F084 91 80
    lda <$98                            ; F086 A5 98
    clc ; F088 18
    adc <.lines_drawn                   ; F089 65 1F
    iny ; F08B C8
    sta [$80],y                         ; F08C 91 80
    iny ; F08E C8
    lda <$82                            ; F08F A5 82
    sta [$80],y                         ; F091 91 80
    lda <$83                            ; F093 A5 83
    iny ; F095 C8
    sta [$80],y                         ; F096 91 80
    ;jmp textd.draw_in_box     ; F098 4C FA EE
	rts
; ----------------------------------------------------------------------------
textd_x.on_code_22:	;;HANDLE_EXIT_IN_OWN
	DECLARE_TEXTD_VARIABLES
.case_22:
	;;item name (with skipping the first byte), of which is stored in the backpack.
	;;parameter = index in backpack
    ;cmp #$22                            ; F1F9 C9 22
    ;bne .break_case_f1f6                ; F1FB D0 F9
    lda #$00                            ; F1FD A9 00
    sta <$B9                            ; F1FF 85 B9
    ldx <.parameter_byte                ; F201 A6 84
    lda party.backpack.item_id,x        ; F203 BD C0 60
    ;beq .break_case_f1f6                ; F206 F0 EE
	beq textd_x.just_continue_2
    sta <.parameter_byte                ; F208 85 84
    lda <.output_index                    ; F20A A5 90
    pha ; F20C 48
    jsr textd.save_text_ptr             ; F20D 20 E4 F3
    lda #$18                            ; F210 A9 18
    jsr call_switch_2banks          ; F212 20 03 FF
    lda <.parameter_byte                ; F215 A5 84
    asl a                               ; F217 0A
    tax ; F218 AA
    bcs .L_F229                         ; F219 B0 0E
    lda $8800,x                         ; F21B BD 00 88
    clc ; F21E 18
    adc #$01                            ; F21F 69 01
    sta <.p_text                        ; F221 85 3E
    lda $8801,x                         ; F223 BD 01 88
    jmp .L_F234                         ; F226 4C 34 F2
; ----------------------------------------------------------------------------
.L_F229:
    lda $8900,x                         ; F229 BD 00 89
    clc ; F22C 18
    adc #$01                            ; F22D 69 01
    sta <.p_text                             ; F22F 85 3E
    lda $8901,x                         ; F231 BD 01 89
.L_F234:
    adc #$00                            ; F234 69 00
    ;jmp textd.draw_embedded_text                          ; F236 4C C5 F0
	bcc textd.draw_embedded_text
; ----------------------------------------------------------------------------
textd_x.on_code_1b:	;;HANDLE_EXIT_IN_OWN
	DECLARE_TEXTD_VARIABLES
.case_1b:
	;;item name of which is in stomach. (of fatty choccobo).
	;;param: index in the stomach.
    ;cmp #$1B                            ; F128 C9 1B
    ;bne .case_1c                        ; F12A D0 13
    jsr textd.setup_output_ptr_to_next_column ; F12C 20 AC F3
    ldx <.parameter_byte                ; F12F A6 84
    lda menu.available_items_in_stomach,x ; F131 BD 00 7C
    ;beq .break_case_f111                ; F134 F0 DB
textd_x.just_continue_2:
	DECLARE_TEXTD_VARIABLES

	beq textd_x.just_continue_stepstone_1
    sta <.parameter_byte                ; F136 85 84
    lda #$00                            ; F138 A9 00
    sta <$B9                            ; F13A 85 B9
    ;jmp textd.deref_param_text          ; F13C 4C 9D F0
	beq textd.deref_param_text
; ----------------------------------------------------------------------------
textd.deref_param_text:
textd_x.on_code_18:	;;HANDLE_EXIT_IN_OWN
	DECLARE_TEXTD_VARIABLES
.case_18:
	;; reference to anothert text.
	;; parameter = text_id.
    ;bne .case_19                        ; F09B D0 53
.L_F09D:
;;textd.f09d_deref_param_text
;;in $b9?
    lda <.parameter_byte                ; F09D A5 84
    ;beq .L_F0ED                         ; F09F F0 4C
	;beq textd_x.nop_code_handler
	beq textd_x.just_continue_stepstone_1
	FALL_THROUGH_TO textd.deref_param_text_unsafe

;;F0A1
textd.deref_param_text_unsafe:
	DECLARE_TEXTD_VARIABLES
    lda <.output_index                  ; F0A1 A5 90
    pha ; F0A3 48
    jsr textd.save_text_ptr             ; F0A4 20 E4 F3
    lda #$18                            ; F0A7 A9 18
    jsr call_switch_2banks              ; F0A9 20 03 FF
    lda <.parameter_byte                ; F0AC A5 84
    asl a                               ; F0AE 0A
    tax ; F0AF AA
    bcs .L_F0BD                         ; F0B0 B0 0B
    lda $8800,x                         ; F0B2 BD 00 88
    sta <.p_text                        ; F0B5 85 3E
    lda $8801,x                         ; F0B7 BD 01 88
    ;jmp textd.draw_embedded_text        ; F0BA 4C C5 F0
	bcc textd.draw_embedded_text
; ----------------------------------------------------------------------------
.L_F0BD:
    lda $8900,x                         ; F0BD BD 00 89
    sta <.p_text                        ; F0C0 85 3E
    lda $8901,x                         ; F0C2 BD 01 89
.L_F0C5:
	FALL_THROUGH_TO textd.draw_embedded_text

textd.draw_embedded_text:
	DECLARE_TEXTD_VARIABLES
;;textd.draw_embedded_text?
    pha ; F0C5 48
    and #$1F                            ; F0C6 29 1F
    ora #$80                            ; F0C8 09 80
    sta <.p_text+1                      ; F0CA 85 3F
    pla ; F0CC 68
    ;lsr a                               ; F0CD 4A
    ;lsr a                               ; F0CE 4A
    ;lsr a                               ; F0CF 4A
    ;lsr a                               ; F0D0 4A
    ;lsr a                               ; F0D1 4A
	jsr shiftRight6+1
    clc ; F0D2 18
    adc #$18                            ; F0D3 69 18
    jsr call_switch_2banks          ; F0D5 20 03 FF
    jsr textd.draw_in_box     ; F0D8 20 FA EE
    jsr textd.restore_text_ptr          ; F0DB 20 ED F3

	;;pla => output index.
    pla ; F0DE 68
    tax ; F0DF AA
    lda <$B9                            ; F0E0 A5 B9
    beq .L_F0ED                         ; F0E2 F0 09
    lda #$00                            ; F0E4 A9 00
    sta <$B9                            ; F0E6 85 B9
    ;;73 == 'X' (unusable mark)
    lda #$73                            ; F0E8 A9 73
    sta .tile_buffer_lower,x            ; F0EA 9D A0 07
.L_F0ED:
textd_x.just_continue_stepstone_1:
    jmp textd.draw_in_box     ; F0ED 4C FA EE
	;bne textd.draw_in_box	;;HANDLE_EXIT_IN_OWN
	;rts
; ----------------------------------------------------------------------------
textd_x.on_code_19:	;;HANDLE_EXIT_IN_OWN
	DECLARE_TEXTD_VARIABLES
.case_19:
	;;item name of which is listed in the shop.
	;;param: index in the shop offerings list.
    ;cmp #$19                            ; F0F0 C9 19
    ;bne .case_1a                        ; F0F2 D0 20
    ldx <.parameter_byte                ; F0F4 A6 84
    lda menu.shop_offerings,x           ; F0F6 BD 80 7B
    sta <.parameter_byte                ; F0F9 85 84
    bne .L_F10A                         ; F0FB D0 0D
    lda $79F1                           ; F0FD AD F1 79
    sec ; F100 38
    sbc #$04                            ; F101 E9 04
    sta $79F1                           ; F103 8D F1 79
    lda #$FF                            ; F106 A9 FF
    clc ; F108 18
    rts ; F109 60
; ----------------------------------------------------------------------------
.L_F10A:
    lda #$00                            ; F10A A9 00
    sta <$B9                            ; F10C 85 B9
    ;jmp textd.deref_param_text          ; F10E 4C 9D F0
	beq textd.deref_param_text 
; ----------------------------------------------------------------------------
;.break_case_f111:
    ;jmp textd.draw_in_box     ; F111 4C FA EE
; ----------------------------------------------------------------------------
textd_x.on_code_1a:	;;HANDLE_EXIT_IN_OWN
	DECLARE_TEXTD_VARIABLES
.case_1a:
	;; item name of which is stored in the backpack,
	;; at the index specified by parameter
    ;cmp #$1A                            ; F114 C9 1A
    ;bne .case_1b                        ; F116 D0 10
    lda #$00                            ; F118 A9 00
    sta <$B9                            ; F11A 85 B9
    ldx <.parameter_byte                ; F11C A6 84
    lda party.backpack.item_id,x        ; F11E BD C0 60
    ;beq .break_case_f111                ; F121 F0 EE
	beq textd_x.just_continue_stepstone_1
    sta <.parameter_byte                ; F123 85 84
    ;jmp textd.deref_param_text          ; F125 4C 9D F0
	bne textd.deref_param_text
; ----------------------------------------------------------------------------
textd_x.on_code_1e:	;;HANDLE_EXIT_IN_OWN
	DECLARE_TEXTD_VARIABLES
.case_1e:
	;;available job name. param = job_id
    ;cmp #$1E                            ; F17A C9 1E
    ;bne .case_1f                        ; F17C D0 1C
    jsr field.get_max_available_job_id  ; F17E 20 8A F3
    cmp <.parameter_byte                ; F181 C5 84
    bcs .L_F192                         ; F183 B0 0D
    lda $78F1                           ; F185 AD F1 78
    sec ; F188 38
    sbc #$04                            ; F189 E9 04
    sta $78F1                           ; F18B 8D F1 78
    lda #$FF                            ; F18E A9 FF
    clc ; F190 18
    rts ; F191 60
; ----------------------------------------------------------------------------
.L_F192:
    lda <.parameter_byte                ; F192 A5 84
    clc ; F194 18
    adc #$E2                            ; F195 69 E2
    jmp textd.deref_text_id             ; F197 4C D8 F2
; ----------------------------------------------------------------------------
textd_x.on_code_1f:	;;CONTINUE_WITH_TEXT
	DECLARE_TEXTD_VARIABLES
.case_1f:
	;;capacity needed to change job to which is in the available job list.
	;;param: index in the list.(ie, job_id)
    ;cmp #$1F                            ; F19A C9 1F
    ;bne .case_20                        ; F19C D0 1D
    ldx <.parameter_byte                ; F19E A6 84
    lda $7200,x                         ; F1A0 BD 00 72
    sta <$80                            ; F1A3 85 80
    ldx <.output_index                  ; F1A5 A6 90
    inc <.output_index                  ; F1A7 E6 90
    lda #$C8                            ; F1A9 A9 C8
    sta .tile_buffer_lower,x            ; F1AB 9D A0 07
    lda #$00                            ; F1AE A9 00
    sta <$81                            ; F1B0 85 81
    jsr switch_to_character_logics_bank ; F1B2 20 27 F7
    ;jsr $8B57                           ; F1B5 20 57 8B
	jmp $8b57
    ;jmp textd.continue_with_text        ; F1B8 4C 91 F2
; ----------------------------------------------------------------------------
textd_x.on_code_20:	;;HANDLE_EXIT_IN_OWN
	DECLARE_TEXTD_VARIABLES
.case_20:
	;;item name referenced in equip selection window
    ;cmp #$20                            ; F1BB C9 20
    ;bne .case_21                        ; F1BD D0 12
    ldx <.parameter_byte                ; F1BF A6 84
    lda party.backpack.item_id,x        ; F1C1 BD C0 60
    ;beq .break_case_f1f6                ; F1C4 F0 30
	beq textd_x.just_continue_stepstone_1
    sta <.parameter_byte                ; F1C6 85 84
    tax ; F1C8 AA
    lda $7200,x                         ; F1C9 BD 00 72
    sta <$B9                            ; F1CC 85 B9
    jmp textd.deref_param_text          ; F1CE 4C 9D F0

;------------------------------------------------------------------------------------------------------
textd_x.on_code_10:	;;HANDLE_EXIT_IN_OWN
textd_x.on_code_11:	;;HANDLE_EXIT_IN_OWN
textd_x.on_code_12:	;;HANDLE_EXIT_IN_OWN
textd_x.on_code_13:	;;HANDLE_EXIT_IN_OWN
	DECLARE_TEXTD_VARIABLES
;textd.eval_code_10_13:
;; --- variables.
;; A = char code
;; X = param byte
    lsr a                               ; F239 4A
    ror a                               ; F23A 6A
    ror a                               ; F23B 6A
    and #$C0                            ; F23C 29 C0
    sta <.cached_param                            ; F23E 85 67
    lda <.parameter_byte                             ; F240 A5 84
    cmp #$30                            ; F242 C9 30
    bcc .case_below_30                  ; F244 90 53
.L_F246:
    cmp #$FF                            ; F246 C9 FF
    bne .case_30_fe                     ; F248 D0 3F
;;case 0xff:
    ldx <.cached_param                            ; F24A A6 67
    lda player.level,x                  ; F24C BD 01 61
    cmp #$62                            ; F24F C9 62
    ;bcs textd.continue_with_text       ; F251 B0 3E
	bcs .continue_with_text
    sta <$80                            ; F253 85 80
    asl a                               ; F255 0A
    clc ; F256 18
    adc <$80                            ; F257 65 80
    sta <$84                            ; F259 85 84
    lda #$00                            ; F25B A9 00
    adc #$80                            ; F25D 69 80
    sta <$85                            ; F25F 85 85
    lda #$39                            ; F261 A9 39
    jsr call_switch1stBank              ; F263 20 06 FF
    ldy #$B0                            ; F266 A0 B0
    lda [$84],y                         ; F268 B1 84
    sec ; F26A 38
    sbc player.exp,x                    ; F26B FD 03 61
    sta <$80                            ; F26E 85 80
    iny ; F270 C8
    lda [$84],y                         ; F271 B1 84
    sbc player.exp+1,x                  ; F273 FD 04 61
    sta <$81                            ; F276 85 81
    iny ; F278 C8
    lda [$84],y                         ; F279 B1 84
    sbc player.exp+2,x                  ; F27B FD 05 61
    sta <$82                            ; F27E 85 82

    jsr switch_to_character_logics_bank ; F280 20 27 F7
    jsr $8B78                           ; F283 20 78 8B
.continue_with_text:
    ;jmp textd.continue_with_text        ; F286 4C 91 F2
	jmp textd_x.continue_with_text
; ----------------------------------------------------------------------------
.case_30_fe:
    pha ; F289 48
    jsr switch_to_character_logics_bank ; F28A 20 27 F7
    pla ; F28D 68
    jsr $8998                           ; F28E 20 98 89
	jmp textd_x.continue_with_text
;;textd.continue_with_text
.L_F291:
    ;lda <.text_bank                             ; F291 A5 93
    ;jsr call_switch_2banks          ; F293 20 03 FF
    ;jmp textd.draw_in_box     ; F296 4C FA EE
; ----------------------------------------------------------------------------
.case_below_30:
    cmp #$00                            ; F299 C9 00
    bne textd_x.code_10_13.param_01                        ; F29B D0 64
;;case 0x00:	;;status
    ldx <.cached_param                  ; F29D A6 67
    lda player.status,x                 ; F29F BD 02 61
    and #$FE                            ; F2A2 29 FE
    bne .L_F2BB                         ; F2A4 D0 15
    ldx <.output_index                    ; F2A6 A6 90
    inc <.output_index                    ; F2A8 E6 90
    inc <.output_index                    ; F2AA E6 90
    lda #$5E                            ; F2AC A9 5E
    sta .tile_buffer_lower,x            ; F2AE 9D A0 07
    lda #$5F                            ; F2B1 A9 5F
    sta .tile_buffer_lower+1,x          ; F2B3 9D A1 07
    lda #$3e                            ; F2B6 A9 3E
    jmp .L_F246                         ; F2B8 4C 46 F2
; ----------------------------------------------------------------------------
.L_F2BB:
    ldy #$16                            ; F2BB A0 16
    asl a                               ; F2BD 0A
    bcs .L_F2D7                           ; F2BE B0 17
    ldy #$17                            ; F2C0 A0 17
    asl a                               ; F2C2 0A
    bcs .L_F2D7                           ; F2C3 B0 12
    ldy #$1B                            ; F2C5 A0 1B
    asl a                               ; F2C7 0A
    bcs .L_F2D7                           ; F2C8 B0 0D
    iny ; F2CA C8
    asl a                               ; F2CB 0A
    bcs .L_F2D7                           ; F2CC B0 09
    iny ; F2CE C8
    asl a                               ; F2CF 0A
    bcs .L_F2D7                           ; F2D0 B0 05
    iny ; F2D2 C8
    asl a                               ; F2D3 0A
    bcs .L_F2D7                           ; F2D4 B0 01
    iny ; F2D6 C8
.L_F2D7:
    tya ; F2D7 98
;;textd.deref_text_id

textd.deref_text_id:
	DECLARE_TEXTD_VARIABLES
.L_F2D8:
    tax ; F2D8 AA
    jsr textd.save_text_ptr             ; F2D9 20 E4 F3
    lda #$18                            ; F2DC A9 18
    jsr call_switch_2banks          ; F2DE 20 03 FF
    txa ; F2E1 8A
    asl a                               ; F2E2 0A
    tax ; F2E3 AA
    bcs .L_F2F1                           ; F2E4 B0 0B
    lda textd.status_and_area_names,x   ; F2E6 BD 00 82
    sta <.p_text                        ; F2E9 85 3E
    lda textd.status_and_area_names+1,x ; F2EB BD 01 82
    jmp .L_F2F9                           ; F2EE 4C F9 F2
; ----------------------------------------------------------------------------
.L_F2F1:
    lda textd.status_and_area_names+$100,x  ; F2F1 BD 00 83
    sta <.p_text                             ; F2F4 85 3E
    lda textd.status_and_area_names+$101,x  ; F2F6 BD 01 83
.L_F2F9:
    tax ; F2F9 AA
    lda <.output_index                             ; F2FA A5 90
    pha ; F2FC 48
    txa ; F2FD 8A
    jmp textd.draw_embedded_text           ; F2FE 4C C5 F0
	;jmp textd_x.draw_embedded_text_and_continue
; ----------------------------------------------------------------------------
textd_x.code_10_13.param_01:	;;job name
	DECLARE_TEXTD_VARIABLES
    cmp #$01                            ; F301 C9 01
    ;bne .case_02                        ; F303 D0 0B
	bne textd_x.code_10_13.param_02
    ldx <.cached_param                  ; F305 A6 67
    lda player.job,x                    ; F307 BD 00 61
    clc ; F30A 18
    adc #$E2                            ; F30B 69 E2
    jmp textd.deref_text_id             ; F30D 4C D8 F2
	;jmp textd_x.deref_text_id_and_continue
; ----------------------------------------------------------------------------
textd_x.code_10_13.param_02:	;;player name
	DECLARE_TEXTD_VARIABLES
    cmp #$02                            ; F310 C9 02
    ;bne .case_03_07                     ; F312 D0 34
	bne textd_x.code_10_13.param_03_07
    ldx <.cached_param                            ; F314 A6 67

textd.draw_player_name:
	DECLARE_TEXTD_VARIABLES
;;in x : offset
    lda player.name+0,x                 ; F316 BD 06 61
    sta <$5A                            ; F319 85 5A
    lda player.name+1,x                 ; F31B BD 07 61
    sta <$5B                            ; F31E 85 5B
    lda player.name+2,x                 ; F320 BD 08 61
    sta <$5C                            ; F323 85 5C
    lda player.name+3,x                 ; F325 BD 09 61
    sta <$5D                            ; F328 85 5D
    lda player.name+4,x                 ; F32A BD 0A 61
    sta <$5E                            ; F32D 85 5E
    lda player.name+5,x                 ; F32F BD 0B 61
    sta <$5F                            ; F332 85 5F
    jsr textd.save_text_ptr             ; F334 20 E4 F3
    lda #$5A                            ; F337 A9 5A
    sta <.p_text                        ; F339 85 3E
    lda #$00                            ; F33B A9 00
    sta <.p_text+1                      ; F33D 85 3F
    jsr textd.draw_in_box               ; F33F 20 FA EE
    jsr textd.restore_text_ptr          ; F342 20 ED F3
    jmp textd.draw_in_box               ; F345 4C FA EE
; ----------------------------------------------------------------------------
textd_x.code_10_13.param_03_07:
	DECLARE_TEXTD_VARIABLES
.case_03_07:	;;equipped item
    cmp #$08                            ; F348 C9 08
    bcs .case_gte_08                    ; F34A B0 27
    sec ; F34C 38
    sbc #$03                            ; F34D E9 03
    cmp #$04                            ; F34F C9 04
    bne .L_F356                           ; F351 D0 03
    clc ; F353 18
    adc #$01                            ; F354 69 01
.L_F356:
    ora <.cached_param                            ; F356 05 67
    tax ; F358 AA
    lda player.equips,x                 ; F359 BD 00 62
    bne .L_F368                           ; F35C D0 0A
    txa ; F35E 8A
    and #$07                            ; F35F 29 07
    tax ; F361 AA
    lda .L_F36D,x                         ; F362 BD 6D F3
    jmp textd.deref_text_id             ; F365 4C D8 F2
	;jmp textd_x.deref_text_id_and_continue
; ----------------------------------------------------------------------------
.L_F368:
    sta <.parameter_byte                ; F368 85 84
    jmp textd.deref_param_text_unsafe   ; F36A 4C A1 F0
	;jmp textd_x.deref_param_text_unsafe_and_continue
; ----------------------------------------------------------------------------
.L_F36D:
    .db $dd, $de, $df, $e0, $e1, $e1
    ;cmp $DFDE,x                         ; F36D DD DE DF
    ;cpx #$E1                            ; F370 E0 E1
    ;.byte $E1                             ; F372 E1
; ----------------------------------------------------------------------------
.case_gte_08:
    sec ; F373 38
    sbc #$08                            ; F374 E9 08
    tax ; F376 AA
    lda $7C00,x                         ; F377 BD 00 7C
    beq .break_case_f387                ; F37A F0 0B
    sta <$84                            ; F37C 85 84
    tax ; F37E AA
    lda $7200,x                         ; F37F BD 00 72
    sta <$B9                            ; F382 85 B9
    jmp textd.deref_param_text          ; F384 4C 9D F0
; ----------------------------------------------------------------------------
.break_case_f387:
    jmp textd.draw_in_box     ; F387 4C FA EE

; -------------------------------------------------------------------------------------------------
textd_x.ctrl_code_handlers.low:
	.db 0
	.db LOW(textd_x.on_code_01)
	.db LOW(textd_x.on_code_02)
	.db LOW(textd_x.on_code_03)
	.db LOW(textd_x.on_code_04)
	.db LOW(textd_x.on_code_05)
	.db LOW(textd_x.on_code_06)
	.db LOW(textd_x.on_code_07)
	.db LOW(textd_x.on_code_08)
	.db LOW(textd_x.on_code_09)
	.db LOW(textd_x.on_code_0a)
	.db LOW(textd_x.on_code_0b)
	.db LOW(textd_x.on_code_0c)
	.db LOW(textd_x.on_code_0d)
	.db LOW(textd_x.on_code_0e)
	.db LOW(textd_x.on_code_0f)
	.db LOW(textd_x.on_code_10)
	.db LOW(textd_x.on_code_11)
	.db LOW(textd_x.on_code_12)
	.db LOW(textd_x.on_code_13)
	.db LOW(textd_x.on_code_14)
	.db LOW(textd_x.on_code_15)
	.db LOW(textd_x.on_code_16)
	.db LOW(textd_x.on_code_17)
	.db LOW(textd_x.on_code_18)
	.db LOW(textd_x.on_code_19)
	.db LOW(textd_x.on_code_1a)
	.db LOW(textd_x.on_code_1b)
	.db LOW(textd_x.on_code_1c)
	.db LOW(textd_x.on_code_1d)
	.db LOW(textd_x.on_code_1e)
	.db LOW(textd_x.on_code_1f)
	.db LOW(textd_x.on_code_20)
	.db LOW(textd_x.on_code_21)
	.db LOW(textd_x.on_code_22)
	.db LOW(textd_x.on_code_23)
	.db LOW(textd_x.on_code_24)
	.db LOW(textd_x.on_code_25)
	.db LOW(textd_x.on_code_26)
	.db LOW(textd_x.on_code_27)
	
textd_x.JUST_CONTINUE = $00
textd_x.CONTINUE_WITH_TEXT = $01
;textd_x.CONTINUE_FROM_NEXT_LINE = $02
;textd_x.CLC_RTS = $08 | $00
;textd_x.SEC_RTS = $08 | $01
textd_x.HANDLE_EXIT_IN_OWN = $08

;;lower 3bits = higher address of the handler,
;;higher 4bits = exit disposition.
textd_x.ctrl_code_handlers.high_and_flags:
	.db 0
	.db ((HIGH(textd_x.on_code_01) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.HANDLE_EXIT_IN_OWN)<<4)
	;.db ((HIGH(textd_x.on_code_02) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.JUST_CONTINUE)<<4)
	.db ((HIGH(textd_x.on_code_02) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.HANDLE_EXIT_IN_OWN)<<4)
	.db ((HIGH(textd_x.on_code_03) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.CONTINUE_WITH_TEXT)<<4)
	.db ((HIGH(textd_x.on_code_04) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.CONTINUE_WITH_TEXT)<<4)
	.db ((HIGH(textd_x.on_code_05) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.CONTINUE_WITH_TEXT)<<4)
	.db ((HIGH(textd_x.on_code_06) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.JUST_CONTINUE)<<4)
	;.db ((HIGH(textd_x.on_code_07) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.JUST_CONTINUE)<<4)
	.db ((HIGH(textd_x.on_code_07) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.HANDLE_EXIT_IN_OWN)<<4)
	.db ((HIGH(textd_x.on_code_08) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.CONTINUE_WITH_TEXT)<<4)
	.db ((HIGH(textd_x.on_code_09) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.HANDLE_EXIT_IN_OWN)<<4)
	.db ((HIGH(textd_x.on_code_0a) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.HANDLE_EXIT_IN_OWN)<<4)
	.db ((HIGH(textd_x.on_code_0b) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.JUST_CONTINUE)<<4)
	;.db ((HIGH(textd_x.on_code_0c) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.JUST_CONTINUE)<<4)
	.db ((HIGH(textd_x.on_code_0c) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.HANDLE_EXIT_IN_OWN)<<4)
	.db ((HIGH(textd_x.on_code_0d) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.CONTINUE_WITH_TEXT)<<4)
	.db ((HIGH(textd_x.on_code_0e) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.JUST_CONTINUE)<<4)
	.db ((HIGH(textd_x.on_code_0f) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.JUST_CONTINUE)<<4)
	.db ((HIGH(textd_x.on_code_10) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.HANDLE_EXIT_IN_OWN)<<4)
	.db ((HIGH(textd_x.on_code_11) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.HANDLE_EXIT_IN_OWN)<<4)
	.db ((HIGH(textd_x.on_code_12) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.HANDLE_EXIT_IN_OWN)<<4)
	.db ((HIGH(textd_x.on_code_13) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.HANDLE_EXIT_IN_OWN)<<4)
	.db ((HIGH(textd_x.on_code_14) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.JUST_CONTINUE)<<4)
	.db ((HIGH(textd_x.on_code_15) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.JUST_CONTINUE)<<4)
	.db ((HIGH(textd_x.on_code_16) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.JUST_CONTINUE)<<4)
	.db ((HIGH(textd_x.on_code_17) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.JUST_CONTINUE)<<4)
	;.db ((HIGH(textd_x.on_code_18) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.JUST_CONTINUE)<<4)
	.db ((HIGH(textd_x.on_code_18) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.HANDLE_EXIT_IN_OWN)<<4)
	.db ((HIGH(textd_x.on_code_19) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.HANDLE_EXIT_IN_OWN)<<4)
	;.db ((HIGH(textd_x.on_code_1a) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.JUST_CONTINUE)<<4)
	.db ((HIGH(textd_x.on_code_1a) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.HANDLE_EXIT_IN_OWN)<<4)
	;.db ((HIGH(textd_x.on_code_1b) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.JUST_CONTINUE)<<4)
	.db ((HIGH(textd_x.on_code_1b) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.HANDLE_EXIT_IN_OWN)<<4)
	.db ((HIGH(textd_x.on_code_1c) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.CONTINUE_WITH_TEXT)<<4)
	.db ((HIGH(textd_x.on_code_1d) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.CONTINUE_WITH_TEXT)<<4)
	.db ((HIGH(textd_x.on_code_1e) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.HANDLE_EXIT_IN_OWN)<<4)
	.db ((HIGH(textd_x.on_code_1f) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.CONTINUE_WITH_TEXT)<<4)
	;.db ((HIGH(textd_x.on_code_20) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.JUST_CONTINUE)<<4)
	.db ((HIGH(textd_x.on_code_20) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.HANDLE_EXIT_IN_OWN)<<4)
	.db ((HIGH(textd_x.on_code_21) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.CONTINUE_WITH_TEXT)<<4)
	;.db ((HIGH(textd_x.on_code_22) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.JUST_CONTINUE)<<4)
	.db ((HIGH(textd_x.on_code_22) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.HANDLE_EXIT_IN_OWN)<<4)
	.db ((HIGH(textd_x.on_code_23) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.JUST_CONTINUE)<<4)
	.db ((HIGH(textd_x.on_code_24) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.JUST_CONTINUE)<<4)
	.db ((HIGH(textd_x.on_code_25) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.JUST_CONTINUE)<<4)
	.db ((HIGH(textd_x.on_code_26) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.JUST_CONTINUE)<<4)
	.db ((HIGH(textd_x.on_code_27) - HIGH(textd_x.code_handlers_base)) & $07) | ((textd_x.JUST_CONTINUE)<<4)
; -------------------------------------------------------------------------------------------------
	VERIFY_PC $f38a
textd.patch_end:

	.endif	;FAST_FIELD_WINDOW