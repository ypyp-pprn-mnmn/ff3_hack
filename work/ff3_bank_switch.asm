;; encoding: utf-8
;; ff3_bank_switch.asm
;;
;;	re-implementation of logics around switching of PRG ROM banks
;;
;; version:
;;	0.1.0
;;=================================================================================================
__FF3_BANK_SWITCH_INCLUDED__
	.ifdef _FEATURE_MEMOIZE_BANK_SWITCH
;--------------------------------------------------------------------------------------------------
	INIT_PATCH_EX sys.switch_bank, $3f,$ff03,$ff2a,$ff03

sys_x.last_bank.1st = $ce
sys_x.last_bank.2nd = $cf

;; these 3 functions are public endpoints called directly from other codes.
thunk.switch_2banks:
    jmp switch_2banks               ; FF03 4C 17 FF

thunk.switch_1st_bank:
    jmp switch_1st_bank             ; FF06 4C 0C FF

thunk.switch_2nd_bank:
    jmp switch_2nd_bank             ; FF09 4C 1F FF

;; the following functions are NOT directly referred to by codes other than here.

switch_1st_bank:
    pha             ; FF0C 48
    sta <sys_x.last_bank.1st
    lda #$06    ; FF0D A9 06
    bne sys_x.switch_bank
    ;sta $8000   ; FF0F 8D 00 80
    ;pla             ; FF12 68
    ;sta $8001   ; FF13 8D 01 80
    ;rts             ; FF16 60

switch_2banks:
    ;pha             ; FF17 48
    jsr switch_1st_bank             ; FF18 20 0C FF
    ;pla             ; FF1B 68
    clc             ; FF1C 18
    adc #$01    ; FF1D 69 01
    FALL_THROUGH_TO switch_2nd_bank

switch_2nd_bank:
    pha             ; FF1F 48
    sta <sys_x.last_bank.2nd
    lda #$07    ; FF20 A9 07

sys_x.switch_bank:
    sta $8000   ; FF22 8D 00 80
    pla             ; FF25 68
    sta $8001   ; FF26 8D 01 80
    rts             ; FF29 60
;==================================================================================================
	VERIFY_PC_TO_PATCH_END sys.switch_bank
    .endif  ;;_FEATURE_MEMOIZE_BANK_SWITCH
