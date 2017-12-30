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
	INIT_PATCH_EX sys.switch_bank, $3f,$ff0c,$ff2a,$ff0c

switch_1st_page:
    pha             ; FF0C 48
    lda #$06    ; FF0D A9 06
    sta $8000   ; FF0F 8D 00 80
    pla             ; FF12 68
    sta $8001   ; FF13 8D 01 80
    rts             ; FF16 60

switch_2pages:
    pha             ; FF17 48
    jsr switch_1st_page             ; FF18 20 0C FF
    pla             ; FF1B 68
    clc             ; FF1C 18
    adc #$01    ; FF1D 69 01
    FALL_THROUGH_TO switch_2nd_page
    
switch_2nd_page:
    pha             ; FF1F 48
    lda #$07    ; FF20 A9 07
    sta $8000   ; FF22 8D 00 80
    pla             ; FF25 68
    sta $8001   ; FF26 8D 01 80
    rts             ; FF29 60
;==================================================================================================
	VERIFY_PC_TO_PATCH_END sys.switch_bank
    .endif  ;;_FEATURE_MEMOIZE_BANK_SWITCH
