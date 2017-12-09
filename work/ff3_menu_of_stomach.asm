; encoding: utf-8
;   ff3_menu_of_stomach
;
; description:
;   re-implementation of fatty choccobo's (aka 'stomach') menu.
;
;==================================================================================================

    .ifdef FAST_FIELD_WINDOW
        .ifndef STOMACH_AMOUNT_1BYTE
            .fail
        .endif
    .endif

    .ifdef STOMACH_AMOUNT_1BYTE
STOMACH_TEXT_BUFFER = $7400   ;;original = $7300
    ;; 1E:B432:A9 73     LDA #$73
        .bank $3d
        .org $b432+1
        .db HIGH(STOMACH_TEXT_BUFFER)
    .else
STOMACH_TEXT_BUFFER = $7300
    .endif
;-------------------------------------------------------------------------------------------------- 
;; locating...
	INIT_PATCH_EX menu.stomach,$3d,$b570,$b5ed,$b570

;;#### in:
;;+	u8 $6300[256]: item amount in stomach
;;
;;#### out:
;;+	u8 $7300[0x500]: text buffer, ready to be supplied into rendering logics
;;
;;### callers:
;;+	`jsr menu.stomach.build_content_text	; B427 20 70 B5` @ $3d:b383
;;
;;### local variables:
;;+	ptr $80: text buffer
;;+	u8 $82: item_id
menu.stomach.build_content_text:
;; fixups
;; ---
.p_text_buffer = $80
	ldx #$01        ; B570 A2 01
	ldy #$00        ; B572 A0 00
.push_available_items:
        lda party.item_amount_in_stomach,x     ; B574 BD 00 63
        beq .continue ; B577 F0 05
        txa             ; B579 8A
        sta menu.available_items_in_stomach,y     ; B57A 99 00 7C
        iny             ; B57D C8
    .continue:
        inx             ; B57E E8
        bne .push_available_items ; B57F D0 F3

	lda #$00        ; B581 A9 00
	;sta menu.available_items_in_stomach,y     ; B583 99 00 7C
	;cpy #$FF        ; B586 C0 FF
	;beq	.build_text
.fill_empty:
	sta menu.available_items_in_stomach,y
	iny
	bne .fill_empty
; --- build up the buffer.
    ldx #HIGH(STOMACH_TEXT_BUFFER)
    stx <.p_text_buffer+1
    lda #0
    sta STOMACH_TEXT_BUFFER
    tax
    inx
    stx <.p_text_buffer
    dex
    tay
.build_text_lines:
        lda #CHAR.ITEM_NAME_IN_STOMACH  ;#$1b
        sta [.p_text_buffer],y
        iny

        txa
        sta [.p_text_buffer],y
        iny

    .ifdef STOMACH_AMOUNT_1BYTE
        lda #CHAR_X.ITEM_AMOUNT_IN_STOMACH_1BYTE
        sta [.p_text_buffer],y
        iny
    .else
        lda #CHAR.ITEM_AMOUNT_IN_STOMACH
        sta [.p_text_buffer],y
        iny
    
        txa
        sta [.p_text_buffer],y
        iny
    .endif  ;;STOMACH_AMOUNT_1BYTE

        txa
        inx
        beq .terminate
        lsr A
        bcc .build_text_lines
        ;;item will be at right column.
        lda #CHAR.EOL
        sta [.p_text_buffer],y
    .ifdef STOMACH_AMOUNT_1BYTE
        ADD16by8 <.p_text_buffer, #7
    .else
        ADD16by8 <.p_text_buffer, #9
    .endif  ;;STOMACH_AMOUNT_1BYTE
        ldy #0
        beq .build_text_lines
.terminate:
    lda #CHAR.NULL
    sta [.p_text_buffer],y
    rts
;-------------------------------------------------------------------------------------------------- 
    VERIFY_PC_TO_PATCH_END menu.stomach
menu.stomach.BULK_PATCH_FREE_BEGIN:
