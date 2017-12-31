;; encoding: utf-8
;; ff3_menu_utils.asm
;;
;;	re-implementation of utility functions around menu handling
;;
;; version:
;;	0.1.0
;;=================================================================================================
__FF3_MENU_UTILS_INCLUDED__
	
    DEFINE_DEFAULT eligibility.CONSUMABLES_BEGIN, $98
    DEFINE_DEFAULT eligibility.CONSUMABLES_END, $c8
;;-------------------------------------------------------------------------------------------------
	INIT_PATCH_EX menu.eligibility, $3d,$aee3,$af1f,$aee3

;;# $3d:aee3 menu.get_eligibility_for_item_for_all
;;> 指定したアイテムの装備可能フラグを取得し、各プレイヤーキャラクターのステータスに反映する。
;;
;;### args:
;;+	in u8 A: item_id
;;+	out u8 $6102, $6142, $6182, $61c2: status of player characters. bit0 = eligibilty, in context of menu-mode.
;;
;;### callers:
;;+	`jsr .L_AEE3   ; B49F 20 E3 AE` @ $3d:b492 menu.stomach.get_eligibility_for_all_characters
;;+   `lda $7B80,x ; AEE0 BD 80 7B` (fall through) @ $3d:aed5 menu.shop.update_eligiblity_for_item
menu.get_eligibility_for_item_for_all:
;; fixups.
;; ---
    .ifdef _FEATURE_FAST_ELIGIBILITY
        jmp field_x.get_and_update_eligibility_flags
    ;; A = user type
menu_x.get_eligibility_flags:
.result_flags = $80
        pha ;;user type.
        ldy #0
    .for_each_characters:
            pla ;;user type.
            tax
            pha

            tya
            pha ;;byte offset.
            lda player.job,y
            pha ;;job_id
            lsr A
            lsr A
            lsr A
            tay
            ;; note: elibibility flags are stored in big endian order.
            ;; that is, the higher job_id, the lower the address.
            inx
        .seek_to_flag:
                dex
                dey
                bpl .seek_to_flag
            pla ;; job_id
            and #$7
            tay
            lda ((rom.eligibility_flags & $7fff) | $8000)+2,x
        .get_flag_bit:
                lsr A
                dey
                bpl .get_flag_bit
            pla ;;byte offset
            bcc .next_character
                ;; update_status here.
                tay
                lda player.status,y
                ora #STATUS_ELIGIBLE
                sta player.status,y
                tya
        .next_character:
            clc
            adc #$40
            tay
            bne .for_each_characters
        pla ;;dispose. (user type)
        rts
    .else ;;_FEATURE_FAST_ELIGIBILITY
        jsr field.get_eligibility_flags   ; AEE3 20 13 D1
        lda <$80     ; AEE6 A5 80
        and #$08    ; AEE8 29 08
        bne .L_AEF4   ; AEEA D0 08
        lda player.status   ; AEEC AD 02 61
        ora #$01    ; AEEF 09 01
        sta player.status   ; AEF1 8D 02 61
    .L_AEF4:
        lda <$80     ; AEF4 A5 80
        and #$04    ; AEF6 29 04
        bne .L_AF02   ; AEF8 D0 08
        lda player.status+$40   ; AEFA AD 42 61
        ora #$01    ; AEFD 09 01
        sta player.status+$40   ; AEFF 8D 42 61
    .L_AF02:
        lda <$80     ; AF02 A5 80
        and #$02    ; AF04 29 02
        bne .L_AF10   ; AF06 D0 08
        lda player.status+$80  ; AF08 AD 82 61
        ora #$01    ; AF0B 09 01
        sta player.status+$80   ; AF0D 8D 82 61
    .L_AF10:
        lda <$80     ; AF10 A5 80
        and #$01    ; AF12 29 01
        bne .L_AF1E   ; AF14 D0 08
        lda player.status+$c0  ; AF16 AD C2 61
        ora #$01    ; AF19 09 01
        sta player.status+$c0   ; AF1B 8D C2 61
    .L_AF1E:
        rts             ; AF1E 60
    .endif  ;;_FEATURE_FAST_ELIGIBILITY
;;-------------------------------------------------------------------------------------------------
    VERIFY_PC_TO_PATCH_END menu.eligibility
;;=================================================================================================
    INIT_PATCH_EX field.get_eligibility_flags, $3e,$d113,$d142,$d113
;;# $3e:d113 field.get_eligibility_flags
;;> 指定したアイテムの装備可能フラグを各プレイヤーキャラクターごとに1bitで表すようにまとめた値を取得する。
;;
;;### args:
;;+	in u8 A: item_id
;;+	out u8 $80: eligibility flags for characters,
;;	where bit 3 denotes character #0, bit2 for char #1, and so forth.
;;
;;### callers:
;;+	`jsr .L_D113   ; AEE3 20 13 D1` @ $3d:aee3 menu.get_eligibility_of_item_for_all
field.get_eligibility_flags:
    .ifdef _FEATURE_FAST_ELIGIBILITY
field_x.get_and_update_eligibility_flags:
.user_type = $80
.p_item_data = $80
        ;; --- get user type of item
        cmp #eligibility.CONSUMABLES_BEGIN    ;;$98
        bcc .calc_offset
            cmp #eligibility.CONSUMABLES_END  ;;$c8
            bcc .do_return
        .magic:
            sbc #(eligibility.CONSUMABLES_END - eligibility.CONSUMABLES_BEGIN);
    .calc_offset:
        jsr menu_x.get_item_data_ptr
        lda #(rom.item_params >> 13)   ;;$30
        jsr thunk.switch_1st_bank   ;;preserves X.
        ldy #7  ;;user type.
        lda [.p_item_data],y   ;;user type.
        and #$7f
        sta <.user_type
        asl A
        ;clc ;;always clear.
        adc <.user_type
        ;; A = user type x 3
        pha
        lda #(rom.eligibility_flags >> 13)
        jsr thunk.switch_1st_bank   ;;preserves X.
        ;; --- check job number against eligiblity flags
        pla ;;user type
        jsr menu_x.get_eligibility_flags
    .do_return:
        jmp field.switch_to_floor_logics_bank

    .else ;;_FEATURE_FAST_ELIGIBILITY
        pha             ; D113 48
        ldx #$00    ; D114 A2 00
        jsr thunk.call_get_eligibility_for_item   ; D116 20 06 F8
        cmp #$01    ; D119 C9 01
        rol <$80     ; D11B 26 80
        pla             ; D11D 68
        pha             ; D11E 48
        ldx #$40    ; D11F A2 40
        jsr thunk.call_get_eligibility_for_item   ; D121 20 06 F8
        cmp #$01    ; D124 C9 01
        rol <$80     ; D126 26 80
        pla             ; D128 68
        pha             ; D129 48
        ldx #$80    ; D12A A2 80
        jsr thunk.call_get_eligibility_for_item   ; D12C 20 06 F8
        cmp #$01    ; D12F C9 01
        rol <$80     ; D131 26 80
        pla             ; D133 68
        ldx #$C0    ; D134 A2 C0
        jsr thunk.call_get_eligibility_for_item   ; D136 20 06 F8
        cmp #$01    ; D139 C9 01
        rol <$80     ; D13B 26 80
        lda #$3C    ; D13D A9 3C
        jmp thunk.switch_2banks         ; D13F 4C 03 FF
    .endif  ;;_FEATURE_FAST_ELIGIBILITY
;;-------------------------------------------------------------------------------------------------
    VERIFY_PC_TO_PATCH_END field.get_eligibility_flags
;==================================================================================================

