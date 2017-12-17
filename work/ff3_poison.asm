;; encoding: utf-8
;; ff3_poison.asm
;;
;;	re-implementation of logics around processing poisonous status
;;
;; version:
;;	0.1.0
;;=================================================================================================
    ;.ifndef __FF3_POISON_INCLUDED__
__FF3_POISON_INCLUDED__
    .ifdef _FIX_POISON
;-------------------------------------------------------------------------------------------------- 
;; locating...
	INIT_PATCH_EX battle.poison,$35,$ba41,$badc,$ba41

;;# $35:ba41 battle.process_poison
;;> 敵味方全員の毒状態を処理し、HP・ステータスの更新と表示を行う
;;
;;### args:
;;
;;+	in,out BattleCharacter $7575[12]: characters
;;
;;### local variables:
;;
;;+	u8 $24: character index
;;+	BattleCharacter* $28: target
;;+	u8 $64: number of available damage values
;;+	u16 $7400[12]: damages over poison
;;+	u8 $78d5: command_chain_id. 0x05 == [$09,$0C,$0A,$04,$FF] where
;;	- 09: show info message
;;	- 0c: show damage
;;	- 0a: await input (of A button) or timeout
;;	- 04: close info message window
;;	- FF: end of chain
;;+	u8 $78da: battle messages queue. 0x41 == "どくのダメージ!" (TBC)
;;+	u16 $7e4f[12]: damage values to be presented
;;+	u8 $7e98: actor bits. 0x80 == actor is enemy
;;+	u8 $7e99: effect target bits. 0x80 == target is enemy
;;+	u8 $7e9a: effect_target_side. 0x40 == target is enemy side
;;+	u8 $7ec2: scene_id. where
;;	- 0x16: mapped to effect_handler 0F == show damage effect
;;	- 0x17: mapped to effect_handler 0E == show dying effect
;;+	u8 $7ec4[8]: character status (only for enemies)
;;
;;### notes:
;;there are 2 bugs found to be caused by this function.
;;1.	in the situations when right after 'proliferation' has occurred,
;;	the screen effect for that is incorrectly played again after damages over poison shown.
;;2.	when 'landing' is executed with a poisoned character, it never gets 'landed'.
battle.process_poison:  ;;$35:ba41
.damages = $7400
.character_index = $24
.p_character = $28
.damage_index = $64
;; --- fixup callers
;; not needed as located in the same address as the ogirinal.
;; ---
    ldx #$1F                ; BA41 A2 1F
    lda #$FF                ; BA43 A9 FF
    sta effect.proliferated_group
.init_damages:
        sta .damages,x          ; BA45 9D 00 74
        dex                     ; BA48 CA
        bpl .init_damages       ; BA49 10 FA
    ;lda #$00                ; BA4B A9 00
    inx
    ;sta <.damage_index     ; BA4D 85 64
    stx <.damage_index
    lda #$08                ; BA4F A9 08
    sta <.character_index   ; BA51 85 24
    lda #$75                ; BA53 A9 75
    sta <.p_character       ; BA55 85 28
    ;lda #$75               ; BA57 A9 75
    sta <.p_character+1     ; BA59 85 29
.apply_poisons_to_players:
        ;jsr battle.apply_poison_damage      ; BA5B 20 DC BA
        ;clc                     ; BA5E 18
        ;lda <.p_character       ; BA5F A5 28
        ;adc #$40                ; BA61 69 40
        ;sta <.p_character       ; BA63 85 28
        ;lda <.p_character+1     ; BA65 A5 29
        ;adc #$00                ; BA67 69 00
        ;sta <.p_character+1     ; BA69 85 29
        ;ADD16by8 <.p_character, #$40
        ;inc <.character_index   ; BA6B E6 24
        ;lda <.character_index   ; BA6D A5 24
        jsr .apply_poison
        ;; X := current character index
        ;cmp #$0C                ; BA6F C9 0C
        cpx #$0b
        bne .apply_poisons_to_players   ; BA71 D0 E8
    jsr battle.cache_players_status     ; BA73 20 06 9D
    lda #$00                ; BA76 A9 00
    sta <.character_index   ; BA78 85 24
    ;lda #$75                ; BA7A A9 75
    ;sta <.p_character       ; BA7C 85 28
    ;lda #$76                ; BA7E A9 76
    ;sta <.p_character+1     ; BA80 85 29
.apply_poisons_to_enemies:
        jsr .apply_poison
        ;cmp #$08            ; BA9F C9 08
        cpx #$07
        bne .apply_poisons_to_enemies             ; BAA1 D0 DF
    lda <.damage_index      ; BAA3 A5 64
    beq .done               ; BAA5 F0 34
    ldx #$1F                ; BAA7 A2 1F
.setup_damages:
        lda .damages,x      ; BAA9 BD 00 74
        sta effect.damages_to_show_1st,x     ; BAAC 9D 4F 7E
        dex                 ; BAAF CA
        bpl .setup_damages  ; BAB0 10 F7
    lda #$80                ; BAB2 A9 80
    sta effect.actor_flags  ; BAB4 8D 98 7E
    sta effect.target_flags ; BAB7 8D 99 7E
    lsr a                   ; BABA 4A
    sta effect.side_flags   ; BABB 8D 9A 7E
    lda #$05                ; BABE A9 05
    sta battle.command_chain_id       ; BAC0 8D D5 78
    lda #$41                ; BAC3 A9 41
    sta battle.messages     ; BAC5 8D DA 78
    lda #$17                ; BAC8 A9 17
    sta effect.scene_id     ; BACA 8D C2 7E
    jsr battle.present      ; BACD 20 F7 8F
    lda #$16                ; BAD0 A9 16
    sta effect.scene_id     ; BAD2 8D C2 7E
    jsr battle.play_effect  ; BAD5 20 11 84
    jsr canPlayerPartyContinueFighting  ; BAD8 20 58 A4
.done:
    rts                     ; BADB 60

.apply_poison:
    jsr battle.apply_poison_damage      ; BA82 20 DC BA
    ldx <.character_index   ; BA85 A6 24
    cpx #8
    bcs .add_offset
        ldy #$01                ; BA87 A0 01
        lda [.p_character],y   ; BA89 B1 28
        sta effect.enemy_status,x     ; BA8B 9D C4 7E
.add_offset:
    ;clc                     ; BA8E 18
    ;lda <.p_character       ; BA8F A5 28
    ;adc #$40                ; BA91 69 40
    ;sta <.p_character       ; BA93 85 28
    ;lda <.p_character+1     ; BA95 A5 29
    ;adc #$00                ; BA97 69 00
    ;sta <.p_character+1     ; BA99 85 29
    ADD16by8 <.p_character, #$40
    inc <.character_index   ; BA9B E6 24
    ;lda <.character_index   ; BA9D A5 24
    rts
;--------------------------------------------------------------------------------------------------
    VERIFY_PC_TO_PATCH_END battle.poison
    .endif ;;_FIX_POISON
    ;.endif ;;__FF3_POISON_INCLUDED__
