;; encoding: utf-8
;; ff3_poison.asm
;;
;;	re-implementation of logics around processing poisonous status
;;
;; version:
;;	0.1.0
;;=================================================================================================
__FF3_BATTLE_SPECIALS_INCLUDED__
    .ifdef _FIX_REFLECTION
;--------------------------------------------------------------------------------------------------
;; locating...
	;INIT_PATCH_EX battle.specials,$31,$af77,$b15f,$af77    ;;not fully patched.
    INIT_PATCH_EX battle.specials,$31,$b0d3,$b15f,$b0d3

;;# $31:af77 battle.specials.execute
;;> 特殊攻撃を実行し、その結果を実行者と対象者に反映する。
;;
;;### notes:
;;battleFunction00 (dispId : 0) (former name: "doSpecialAction")
;;this function has a bug that happens if and only if 'reflection' of some kind of magics.
;;more specifically, when a reflected magic resulted in 0 damage,
;;this function incorrectly skips logics restoring target pointer. see around $b11c for details.
;;
;;### args:
;;+ [in] u16 $6e : actorPtr
;;+ [in] u8 $cc : skipSealedCheck (item=1,although item flag directs to skip too)
;;+ [in] u8 $7e99 : selected targets (actor.+2F)
;;
;;### local variables:
;;+	u8 $62 : Index 
;;+	u8 $7e88 : actionId
;;+	u8 $7e9d : actionParam[6]
;;
;;### callers:
;;+	$30:9e58 invokeBattleFunction: dispatchBattleCommand(0)

    .if 0   ;;TODO
battle.specials.execute:
    lda #$00        ; AF77 A9 00
    sta $54         ; AF79 85 54
    ldx #$09        ; AF7B A2 09
LAF7D:  
	sta $7EB8,x     ; AF7D 9D B8 7E
    dex	            ; AF80 CA
    bpl LAF7D       ; AF81 10 FA
    lda $CC         ; AF83 A5 CC
    beq LAF8B       ; AF85 F0 04
LAF87:  
	ldy #$2C        ; AF87 A0 2C
    bne LAFD6       ; AF89 D0 4B
LAF8B:  
    jsr getActor2C  ; AF8B 20 B5 A2
    bmi LAF9A       ; AF8E 30 0A
    and #$10        ; AF90 29 10
    beq LAF9A       ; AF92 F0 06
    lda $1A         ; AF94 A5 1A
    cmp #$50        ; AF96 C9 50
    bcs LAF87       ; AF98 B0 ED
LAF9A:
    ldy #$01        ; AF9A A0 01
    lda ($6E),y     ; AF9C B1 6E
    and #$30        ; AF9E 29 30
    beq LAFC8       ; AFA0 F0 26
    and #$20        ; AFA2 29 20
    beq LAFBB       ; AFA4 F0 15
    lda $1A         ; AFA6 A5 1A
    cmp #$F6        ; AFA8 C9 F6
    beq LAFC8       ; AFAA F0 1C
    lda #$53        ; AFAC A9 53
    bne LAFBD       ; AFAE D0 0D
    jsr getActor2C  ; AFB0 20 B5 A2
    bpl LAFBB       ; AFB3 10 06
    lda $1A         ; AFB5 A5 1A
    cmp #$38        ; AFB7 C9 38
    bcs LAFC8       ; AFB9 B0 0D
LAFBB:
    lda #$50        ; AFBB A9 50
LAFBD:
    sta $78DA       ; AFBD 8D DA 78
    lda #$18        ; AFC0 A9 18
    sta $7EC2       ; AFC2 8D C2 7E
    jmp .L_B15E     ; AFC5 4C 5E B1
; ----------------------------------------------------------------------------
LAFC8:
	jsr getActor2C  ; AFC8 20 B5 A2
    and #$18        ; AFCB 29 18
    bne LAFD6       ; AFCD D0 07
    sec             ; AFCF 38
    lda $1A         ; AFD0 A5 1A
    sbc #$C8        ; AFD2 E9 C8
    sta $1A         ; AFD4 85 1A
LAFD6:
    lda ($6E),y     ; AFD6 B1 6E
    and #$E7        ; AFD8 29 E7
    sta ($6E),y     ; AFDA 91 6E
    ldx #$00        ; AFDC A2 00
    lda $1A         ; AFDE A5 1A
    sta $7E88       ; AFE0 8D 88 7E
    cmp #$5B        ; AFE3 C9 5B
    bcc LAFE8       ; AFE5 90 01
    inx             ; AFE7 E8
LAFE8:
    stx $7EC3       ; AFE8 8E C3 7E
    lda $1A         ; AFEB A5 1A
    sta $18         ; AFED 85 18
    lda #$08        ; AFEF A9 08
    sta $1A         ; AFF1 85 1A
    lda #$C0        ; AFF3 A9 C0
    sta $20         ; AFF5 85 20
    lda #$98        ; AFF7 A9 98
    sta $21         ; AFF9 85 21
    ldx #$00        ; AFFB A2 00
    ldy #$18        ; AFFD A0 18
    tya             ; AFFF 98
    jsr loadTo7400Ex; B000 20 A6 FD
    lda $7406       ; B003 AD 06 74
    sta $7E9D       ; B006 8D 9D 7E
    ldx #$08        ; B009 A2 08
    ldy #$00        ; B00B A0 00
    lda $7E99       ; B00D AD 99 7E
LB010:
    asl a           ; B010 0A
    bcc LB014       ; B011 90 01
    iny             ; B013 C8
LB014:
    dex             ; B014 CA
    bne LB010       ; B015 D0 F9
    sty $2A         ; B017 84 2A
    ldy #$30        ; B019 A0 30
    lda ($6E),y     ; B01B B1 6E
    bmi LB029       ; B01D 30 0A
    lda #$75        ; B01F A9 75
    sta $70         ; B021 85 70
	lda #$75        ; B023 A9 75
	sta $71         ; B025 85 71
	bne LB031		; B027 D0 08
LB029:
		lda #$75        ; B029 A9 75
		sta $70         ; B02B 85 70
		lda #$76        ; B02D A9 76
		sta $71         ; B02F 85 71
LB031:
	jsr cacheStatus ; B031 20 BA A2
    ldx #$FF        ; B034 A2 FF
    stx $78         ; B036 86 78
    stx $79         ; B038 86 79
    stx $7A         ; B03A 86 7A
    stx $7B         ; B03C 86 7B
    inx             ; B03E E8
    stx $7574       ; B03F 8E 74 75
    stx $7573       ; B042 8E 73 75
    lda $7E9D       ; B045 AD 9D 7E
    cmp #$06        ; B048 C9 06
    beq LB065       ; B04A F0 19
    ldx $62         ; B04C A6 62
    lda $F0,x       ; B04E B5 F0
    and #$C0        ; B050 29 C0
    beq LB057       ; B052 F0 03
    jmp .L_B15E     ; B054 4C 5E B1
; ----------------------------------------------------------------------------
LB057:
	ldx $7EC1       ; B057 AE C1 7E
    lda $7E99       ; B05A AD 99 7E
    jsr maskTargetBit                   ; B05D 20 38 FD
    bne LB065       ; B060 D0 03
    jmp LB139       ; B062 4C 39 B1
; ----------------------------------------------------------------------------
LB065:
	lda $CC         ; B065 A5 CC
    bne LB0D3       ; B067 D0 6A
    lda $7405       ; B069 AD 05 74
    ldy #$10        ; B06C A0 10
    and #$10        ; B06E 29 10
    beq LB073       ; B070 F0 01
    iny             ; B072 C8
LB073:
	lda ($6E),y     ; B073 B1 6E
    sta $18         ; B075 85 18
    lsr a           ; B077 4A
    clc             ; B078 18
    adc $7401       ; B079 6D 01 74
    sta $25         ; B07C 85 25
    ldx $62         ; B07E A6 62
    lda $F0,x       ; B080 B5 F0
    and #$04        ; B082 29 04
    beq LB088       ; B084 F0 02
    lsr $25         ; B086 46 25
LB088:
    ldy #$0F        ; B088 A0 0F
    lda ($6E),y     ; B08A B1 6E
    jsr LFD44       ; B08C 20 44 FD
    sta $19         ; B08F 85 19
    ldy #$00        ; B091 A0 00
    lda ($6E),y     ; B093 B1 6E
    jsr LFD45       ; B095 20 45 FD
    sta $1A         ; B098 85 1A
	lda $18			; B09A A5 18
    jsr LFD45       ; B09C 20 45 FD
    sec             ; B09F 38
    adc $19         ; B0A0 65 19
    adc $1A         ; B0A2 65 1A
    sta $24         ; B0A4 85 24
    sta $38         ; B0A6 85 38
    jsr getNumberOfRandomSuccess        ; B0A8 20 28 BB
    sta $7C         ; B0AB 85 7C
    ldy #$33        ; B0AD A0 33
    lda ($6E),y     ; B0AF B1 6E
    and #$E0        ; B0B1 29 E0
    jsr LFD46       ; B0B3 20 46 FD
    and $7400       ; B0B6 2D 00 74
    beq LB0D3       ; B0B9 F0 18
    lda $30         ; B0BB A5 30
    sta $18         ; B0BD 85 18
    lda #$05        ; B0BF A9 05
    sta $1A         ; B0C1 85 1A
    lda #$00        ; B0C3 A9 00
    sta $19         ; B0C5 85 19
    sta $1B         ; B0C7 85 1B
    jsr div         ; B0C9 20 92 FC
    lda $1C         ; B0CC A5 1C
    clc             ; B0CE 18
    adc $30         ; B0CF 65 30
    sta $7C         ; B0D1 85 7C
    .endif  ;;TODO
;--------------------------------------------------------------------------------------------------
;LB0D3:
    jsr battle.specials.invoke_handler  ; B0D3 20 5F B1
battle.specials.post_execution:
.damage_index = $64
.p_actor = $6e
.p_target = $70
.damage_value = $78
    ldx <.damage_index         ; B0D6 A6 64
    lda <.damage_value+1         ; B0D8 A5 79
    cmp #HIGH(effect.DAMAGE_NONE)        ; B0DA C9 FF
    ;beq LB129       ; B0DC F0 4B
    beq .finalize_status
		ldx <.damage_index         ; B0DE A6 64
		lda battle.reflected      ; B0E0 AD 74 75
		;bne LB0F3       ; B0E3 D0 0E
        bne .push_damage_value_as_2nd_phase
			lda <.damage_value         ; B0E5 A5 78
			sta effect.damages_to_show_1st,x     ; B0E7 9D 4F 7E
			inx             ; B0EA E8
			lda <.damage_value+1         ; B0EB A5 79
			sta effect.damages_to_show_1st,x     ; B0ED 9D 4F 7E
			;jmp LB129       ; B0F0 4C 29 B1
            jmp .finalize_status
; ----------------------------------------------------------------------------
;LB0F3:
        .push_damage_value_as_2nd_phase:
			jsr battle.action_target.get_2c ; B0F3 20 25 BC
			and #$07        ; B0F6 29 07
			asl a           ; B0F8 0A
			tax             ; B0F9 AA
			inx             ; B0FA E8
			lda effect.damages_to_show_2nd,x     ; B0FB BD 5F 7E
			cmp #HIGH(effect.DAMAGE_NONE)        ; B0FE C9 FF
			beq .just_put_value       ; B100 F0 16
				dex             ; B102 CA
				clc             ; B103 18
				lda effect.damages_to_show_2nd,x     ; B104 BD 5F 7E
				adc <.damage_value         ; B107 65 78
				sta effect.damages_to_show_2nd,x     ; B109 9D 5F 7E
				inx             ; B10C E8
				lda effect.damages_to_show_2nd,x     ; B10D BD 5F 7E
				adc <.damage_value+1         ; B110 65 79
				sta effect.damages_to_show_2nd,x     ; B112 9D 5F 7E
				;jmp LB11C       ; B115 4C 1C B1
                jmp .restore_target_ptr
; ----------------------------------------------------------------------------
;LB118:
            .just_put_value:
				dex             ; B118 CA
				jsr battle.push_damage_for_2nd_phase; B119 20 1C BB
;LB11C:
        .restore_target_ptr:
			lda battle.p_reflector       ; B11C AD B5 78
			sta <.p_target         ; B11F 85 70
			lda battle.p_reflector+1       ; B121 AD B6 78
			sta <.p_target+1         ; B124 85 71
			;jmp LB131       ; B126 4C 31 B1
            jmp .finalize_actor_status
; ----------------------------------------------------------------------------
;LB129:
.finalize_status:
	jsr battle.set_target_as_affected    ; B129 20 BC BD
    lda #$00        ; B12C A9 00
    jsr battle.update_status_cache       ; B12E 20 C5 BD
;LB131:
.finalize_actor_status:
	jsr battle.set_actor_as_affected     ; B131 20 B3 BD
    lda #$01        ; B134 A9 01
    jsr battle.update_status_cache       ; B136 20 C5 BD
    
;;LB139:
    ;FIX_ADDRESS_ON_CALLER $b062+1  ;;B062 4C 39 B1
;;
	inc effect.target_index       ; B139 EE C1 7E
    lda effect.target_index       ; B13C AD C1 7E
    cmp #$08        ; B13F C9 08
    ;beq .L_B15E     ; B141 F0 1B
    beq .done

    cmp #$04        ; B143 C9 04
    ;bne LB14E       ; B145 D0 07
    bne .next_target
    lda effect.side_flags       ; B147 AD 9A 7E
    and #effect.TARGET_ENEMY     ; B14A 29 40
    ;beq .L_B15E     ; B14C F0 10
    beq .done
;LB14E:
.next_target:
	clc             ; B14E 18
    lda <.p_target         ; B14F A5 70
    adc #$40        ; B151 69 40
    sta <.p_target         ; B153 85 70
    lda <.p_target+1         ; B155 A5 71
    adc #$00        ; B157 69 00
    sta <.p_target+1         ; B159 85 71
    jmp $B031       ; B15B 4C 31 B0
;.L_B15E
.done
    rts             ; B15E 60

;--------------------------------------------------------------------------------------------------
    VERIFY_PC_TO_PATCH_END battle.specials
    .endif ;;_FIX_REFLECTION