;; encoding: utf-8
;; ff3_sound_driver.asm
;;
;;	re-implementation of the sound driver.
;;
;; version:
;;	0.1.0
;;=================================================================================================
__FF3_SOUND_DRIVER_INCLUDED__

;--------------------------------------------------------------------------------------------------
    .ifdef _FEATURE_CONTINUOUS_MUSIC   
;;$36:8353 sound.process_note_command
;;
;;    シーケンス内に表現されている各種コマンド(0xE0以上のnote)を処理し、再生状態に反映させる。
;;
;;args:
;;
;;see also $36:820b sound.fetch_note_for_track.
;;
;;    in AudioStream* $d3: pointer to music stream = [$7f51.x, $7f58.x]
;;
;;    in u8 $d5: command byte (aka note) fetched from the music stream.
;;    out u8 $7f66[7]: octaves.
;;    out u8 $7f82[7]: sweeps.
;;    out u8 $7f45: bpm.
;;    out u8 $7f90[7]: volume shift: volume goals.
;;    in,out u8 $7fa5[7]: loop control: 00: use counter#1, otherwise: use counter#2.
;;    in,out u8 $7fac[7]: loop control: counter #1
;;    in,out u8 $7fb3[7]: loop control: counter #2
;;    out u8 $7fc1[7]: volume shift: indexes of envelope table?.
;;
;;    out u8 $7feb[7]: pitch modulation: indexes of envelope table.
;;
;;local variables:
;;
;;    none.
;;
;;notes:
;;
;;command bytes are assigned as follows:
;;
;;    00…BF: play note, higher 4bits denotes pitch tone, lower 4bits denotes note length.
;;    C0…CF: rest note, lower 4bits denotes note length. higher 4bits seems to be ignored (by definition it is always 0xC).
;;    D0…DF: tie note, lower 4bits denotes (extended) note length. higher 4bits seems to be ignored (by definition it is always 0xD).
;;    E0…FF: command note, see below.
;;
;;for E0 or higher commands, each command byte are mapped to one of the following functions:
;;
;;    e0: set tempo ($7f45).
;;    e1…ee: set $7f90 to 2…F, respectively.
;;    ef…f4: set octave ($7f66) to 0…5, respectively.
;;    f5: set duty/envelope to 0x30, fetch more 2 bytes and copy them into $7fc1, $7feb.
;;    f6: set duty/envelope to 0x70, fetch more 2 bytes and copy them into into $7fc1, $7feb.
;;    f7: set duty/envelope to 0xb0, fetch more 2 bytes and copy them into into $7fc1, $7feb.
;;    f8: set sweep ($7f82) to the byte fetched.
;;    f9: set octave ($7f66) to 4, set $7f90 to 0x8,set $7fc1 to 0.
;;    fa: set octave ($7f66) to 5, set $7f90 to 0xf,set $7fc1 to 1.
;;    fb: enter loop. increment loop counter index ($7fa5), and put the extra byte fetched from stream as counter value (either $7fac or $7fb3).
;;    fc: exit loop, if counter value after decremented is 0. target is placed right after the command byte, as direct pointer.
;;    fd: exit loop, if counter value is even. target is placed right after the command byte, as direct pointer.
;;    fe: jump. reload pointer value from the stream.
;;    ff: music end. (mute channels)
;;
;;the below are handlers’ entry point.
;;
;;    e0 8353 835C 8366 8370 837A 8384 838E 8398 
;;    e8 83A2 83AC 83B6 83C0 83CA 83D4 83DE 83E8 
;;    f0 83F2 83FC 8406 8410 841A 8424 843A 8450 
;;    f8 8466 8471 8485 8499 84AF 84D0 84F0 84FF 
    INIT_PATCH_EX sound.note_handler_table, $36, $822f, $826f, $822f
    .dw $8353,$835C,$8366,$8370,$837A,$8384,$838E,$8398 
    .dw $83A2,$83AC,$83B6,$83C0,$83CA,$83D4,$83DE,$83E8 
    .dw $83F2,$83FC,$8406,$8410,$841A,$8424,$843A,$8450 
    .dw $8466,$8471,$8485,$8499,$84AF,$84D0,$84F0,$84FF   
    VERIFY_PC_TO_PATCH_END sound.note_handler_table
;--------------------------------------------------------------------------------------------------
    INIT_PATCH_EX sound.process_note_command, $36, $8353, $857d, $8353
sound.process_note_command: ;;$36:8353
sound.fetch_note_for_track.continue = $8217
    lda [$D3],y ; 8353 B1 D3
    iny             ; 8355 C8
    sta sound.bpm   ; 8356 8D 45 7F
    jmp sound.fetch_note_for_track.continue   ; 8359 4C 17 82
; ----------------------------------------------------------------------------
    ldx <$D0     ; 835C A6 D0
    lda #$02    ; 835E A9 02
    sta sound.volume_envelopes.control,x ; 8360 9D 90 7F
    jmp sound.fetch_note_for_track.continue   ; 8363 4C 17 82
; ----------------------------------------------------------------------------
    ldx <$D0     ; 8366 A6 D0
    lda #$03    ; 8368 A9 03
    sta sound.volume_envelopes.control,x ; 836A 9D 90 7F
    jmp sound.fetch_note_for_track.continue   ; 836D 4C 17 82
; ----------------------------------------------------------------------------
    ldx <$D0     ; 8370 A6 D0
    lda #$04    ; 8372 A9 04
    sta sound.volume_envelopes.control,x ; 8374 9D 90 7F
    jmp sound.fetch_note_for_track.continue   ; 8377 4C 17 82
; ----------------------------------------------------------------------------
    ldx <$D0     ; 837A A6 D0
    lda #$05    ; 837C A9 05
    sta sound.volume_envelopes.control,x ; 837E 9D 90 7F
    jmp sound.fetch_note_for_track.continue   ; 8381 4C 17 82
; ----------------------------------------------------------------------------
    ldx <$D0     ; 8384 A6 D0
    lda #$06    ; 8386 A9 06
    sta sound.volume_envelopes.control,x ; 8388 9D 90 7F
    jmp sound.fetch_note_for_track.continue   ; 838B 4C 17 82
; ----------------------------------------------------------------------------
    ldx <$D0     ; 838E A6 D0
    lda #$07    ; 8390 A9 07
    sta sound.volume_envelopes.control,x ; 8392 9D 90 7F
    jmp sound.fetch_note_for_track.continue   ; 8395 4C 17 82
; ----------------------------------------------------------------------------
    ldx <$D0     ; 8398 A6 D0
    lda #$08    ; 839A A9 08
    sta sound.volume_envelopes.control,x ; 839C 9D 90 7F
    jmp sound.fetch_note_for_track.continue   ; 839F 4C 17 82
; ----------------------------------------------------------------------------
    ldx <$D0     ; 83A2 A6 D0
    lda #$09    ; 83A4 A9 09
    sta sound.volume_envelopes.control,x ; 83A6 9D 90 7F
    jmp sound.fetch_note_for_track.continue   ; 83A9 4C 17 82
; ----------------------------------------------------------------------------
    ldx <$D0     ; 83AC A6 D0
    lda #$0A    ; 83AE A9 0A
    sta sound.volume_envelopes.control,x ; 83B0 9D 90 7F
    jmp sound.fetch_note_for_track.continue   ; 83B3 4C 17 82
; ----------------------------------------------------------------------------
    ldx <$D0     ; 83B6 A6 D0
    lda #$0B    ; 83B8 A9 0B
    sta sound.volume_envelopes.control,x ; 83BA 9D 90 7F
    jmp sound.fetch_note_for_track.continue   ; 83BD 4C 17 82
; ----------------------------------------------------------------------------
    ldx <$D0     ; 83C0 A6 D0
    lda #$0C    ; 83C2 A9 0C
    sta sound.volume_envelopes.control,x ; 83C4 9D 90 7F
    jmp sound.fetch_note_for_track.continue   ; 83C7 4C 17 82
; ----------------------------------------------------------------------------
    ldx <$D0     ; 83CA A6 D0
    lda #$0D    ; 83CC A9 0D
    sta sound.volume_envelopes.control,x ; 83CE 9D 90 7F
    jmp sound.fetch_note_for_track.continue   ; 83D1 4C 17 82
; ----------------------------------------------------------------------------
    ldx <$D0     ; 83D4 A6 D0
    lda #$0E    ; 83D6 A9 0E
    sta sound.volume_envelopes.control,x ; 83D8 9D 90 7F
    jmp sound.fetch_note_for_track.continue   ; 83DB 4C 17 82
; ----------------------------------------------------------------------------
    ldx <$D0     ; 83DE A6 D0
    lda #$0F    ; 83E0 A9 0F
    sta sound.volume_envelopes.control,x ; 83E2 9D 90 7F
    jmp sound.fetch_note_for_track.continue   ; 83E5 4C 17 82
; ----------------------------------------------------------------------------
    ldx <$D0     ; 83E8 A6 D0
    lda #$00    ; 83EA A9 00
    sta sound.note_octaves,x ; 83EC 9D 66 7F
    jmp sound.fetch_note_for_track.continue   ; 83EF 4C 17 82
; ----------------------------------------------------------------------------
    ldx <$D0     ; 83F2 A6 D0
    lda #$01    ; 83F4 A9 01
    sta sound.note_octaves,x ; 83F6 9D 66 7F
    jmp sound.fetch_note_for_track.continue   ; 83F9 4C 17 82
; ----------------------------------------------------------------------------
    ldx <$D0     ; 83FC A6 D0
    lda #$02    ; 83FE A9 02
    sta sound.note_octaves,x ; 8400 9D 66 7F
    jmp sound.fetch_note_for_track.continue   ; 8403 4C 17 82
; ----------------------------------------------------------------------------
    ldx <$D0     ; 8406 A6 D0
    lda #$03    ; 8408 A9 03
    sta sound.note_octaves,x ; 840A 9D 66 7F
    jmp sound.fetch_note_for_track.continue   ; 840D 4C 17 82
; ----------------------------------------------------------------------------
    ldx <$D0     ; 8410 A6 D0
    lda #$04    ; 8412 A9 04
    sta sound.note_octaves,x ; 8414 9D 66 7F
    jmp sound.fetch_note_for_track.continue   ; 8417 4C 17 82
; ----------------------------------------------------------------------------
    ldx <$D0     ; 841A A6 D0
    lda #$05    ; 841C A9 05
    sta sound.note_octaves,x ; 841E 9D 66 7F
    jmp sound.fetch_note_for_track.continue   ; 8421 4C 17 82
; ----------------------------------------------------------------------------
    ldx <$D0     ; 8424 A6 D0
    lda #$30    ; 8426 A9 30
    sta sound.duty_controls,x ; 8428 9D 89 7F
    lda [$D3],y ; 842B B1 D3
    iny             ; 842D C8
    sta $7FC1,x ; 842E 9D C1 7F
    lda [$D3],y ; 8431 B1 D3
    iny             ; 8433 C8
    sta sound.pitch_modulations.type,x ; 8434 9D EB 7F
    jmp sound.fetch_note_for_track.continue   ; 8437 4C 17 82
; ----------------------------------------------------------------------------
    ldx <$D0     ; 843A A6 D0
    lda #$70    ; 843C A9 70
    sta sound.duty_controls,x ; 843E 9D 89 7F
    lda [$D3],y ; 8441 B1 D3
    iny             ; 8443 C8
    sta $7FC1,x ; 8444 9D C1 7F
    lda [$D3],y ; 8447 B1 D3
    iny             ; 8449 C8
    sta sound.pitch_modulations.type,x ; 844A 9D EB 7F
    jmp sound.fetch_note_for_track.continue   ; 844D 4C 17 82
; ----------------------------------------------------------------------------
    ldx <$D0     ; 8450 A6 D0
    lda #$B0    ; 8452 A9 B0
    sta sound.duty_controls,x ; 8454 9D 89 7F
    lda [$D3],y ; 8457 B1 D3
    iny             ; 8459 C8
    sta $7FC1,x ; 845A 9D C1 7F
    lda [$D3],y ; 845D B1 D3
    iny             ; 845F C8
    sta sound.pitch_modulations.type,x ; 8460 9D EB 7F
    jmp sound.fetch_note_for_track.continue   ; 8463 4C 17 82
; ----------------------------------------------------------------------------
    ldx <$D0     ; 8466 A6 D0
    lda [$D3],y ; 8468 B1 D3
    iny             ; 846A C8
    sta sound.sweep_controls,x ; 846B 9D 82 7F
    jmp sound.fetch_note_for_track.continue   ; 846E 4C 17 82
; ----------------------------------------------------------------------------
    ldx <$D0     ; 8471 A6 D0
    lda #$04    ; 8473 A9 04
    sta sound.note_octaves,x ; 8475 9D 66 7F
    lda #$00    ; 8478 A9 00
    sta $7FC1,x ; 847A 9D C1 7F
    lda #$08    ; 847D A9 08
    sta sound.volume_envelopes.control,x ; 847F 9D 90 7F
    jmp sound.fetch_note_for_track.continue   ; 8482 4C 17 82
; ----------------------------------------------------------------------------
    ldx <$D0     ; 8485 A6 D0
    lda #$05    ; 8487 A9 05
    sta sound.note_octaves,x ; 8489 9D 66 7F
    lda #$01    ; 848C A9 01
    sta $7FC1,x ; 848E 9D C1 7F
    lda #$0F    ; 8491 A9 0F
    sta sound.volume_envelopes.control,x ; 8493 9D 90 7F
    jmp sound.fetch_note_for_track.continue   ; 8496 4C 17 82
; ----------------------------------------------------------------------------
    lda [$D3],y ; 8499 B1 D3
    iny             ; 849B C8
    ldx <$D0     ; 849C A6 D0
    inc sound.loops.control,x ; 849E FE A5 7F
    bne .L_84A9   ; 84A1 D0 06
    sta sound.loops.counter_1,x ; 84A3 9D AC 7F
    jmp sound.fetch_note_for_track.continue   ; 84A6 4C 17 82
; ----------------------------------------------------------------------------
.L_84A9:
    sta sound.loops.counter_2,x ; 84A9 9D B3 7F
    jmp sound.fetch_note_for_track.continue   ; 84AC 4C 17 82
; ----------------------------------------------------------------------------
;; case 0xFC:
    ldx <$D0     ; 84AF A6 D0
    lda sound.loops.control,x ; 84B1 BD A5 7F
    bne .L_84C3   ; 84B4 D0 0D
    dec sound.loops.counter_1,x ; 84B6 DE AC 7F
    bne .L_84F0   ; 84B9 D0 35
    iny             ; 84BB C8
    iny             ; 84BC C8
    dec sound.loops.control,x ; 84BD DE A5 7F
    jmp sound.fetch_note_for_track.continue   ; 84C0 4C 17 82
; ----------------------------------------------------------------------------
.L_84C3:
    dec sound.loops.counter_2,x ; 84C3 DE B3 7F
    bne .L_84F0   ; 84C6 D0 28
    iny             ; 84C8 C8
    iny             ; 84C9 C8
    dec sound.loops.control,x ; 84CA DE A5 7F
    jmp sound.fetch_note_for_track.continue   ; 84CD 4C 17 82
; ----------------------------------------------------------------------------
;; case 0xFD:
    ldx <$D0     ; 84D0 A6 D0
    lda sound.loops.control,x ; 84D2 BD A5 7F
    bne .L_84E2   ; 84D5 D0 0B
    lda sound.loops.counter_1,x ; 84D7 BD AC 7F
    lsr a       ; 84DA 4A
    bcs .L_84ED   ; 84DB B0 10
    iny             ; 84DD C8
    iny             ; 84DE C8
    jmp sound.fetch_note_for_track.continue   ; 84DF 4C 17 82
; ----------------------------------------------------------------------------
.L_84E2:
    lda sound.loops.counter_2,x ; 84E2 BD B3 7F
    lsr a       ; 84E5 4A
    bcs .L_84ED   ; 84E6 B0 05
    iny             ; 84E8 C8
    iny             ; 84E9 C8
    jmp sound.fetch_note_for_track.continue   ; 84EA 4C 17 82
; ----------------------------------------------------------------------------
.L_84ED:
    dec sound.loops.control,x ; 84ED DE A5 7F
;; case 0xFE:
.L_84F0:
    lda [$D3],y ; 84F0 B1 D3
    iny             ; 84F2 C8
    tax             ; 84F3 AA
    lda [$D3],y ; 84F4 B1 D3
    sta <$D4     ; 84F6 85 D4
    stx <$D3     ; 84F8 86 D3
    ldy #$00    ; 84FA A0 00
    jmp sound.fetch_note_for_track.continue   ; 84FC 4C 17 82
; ----------------------------------------------------------------------------
;; case 0xFF:
    ldx <$D0     ; 84FF A6 D0
    lda sound.track_controls,x ; 8501 BD 4A 7F
    and #$7F    ; 8504 29 7F
    sta sound.track_controls,x ; 8506 9D 4A 7F
    lda <$D1     ; 8509 A5 D1
    beq .L_8559   ; 850B F0 4C
    cmp #$03    ; 850D C9 03
    beq .L_8520   ; 850F F0 0F
    cmp #$02    ; 8511 C9 02
    beq .L_853A   ; 8513 F0 25
    cmp #$01    ; 8515 C9 01
    beq .L_8541   ; 8517 F0 28
    lda #$30    ; 8519 A9 30
    sta $4000   ; 851B 8D 00 40
    bne .L_8559   ; 851E D0 39
.L_8520:
    lda <$D2     ; 8520 A5 D2
    beq .L_852E   ; 8522 F0 0A
    lda sound.track_controls+sound.TRACK_MUSIC_PULSE2   ; 8524 AD 4B 7F
    ora #$02    ; 8527 09 02
    sta sound.track_controls+sound.TRACK_MUSIC_PULSE2   ; 8529 8D 4B 7F
    bne .L_8533   ; 852C D0 05
.L_852E:
    lda sound.track_controls+sound.TRACK_EFFECT_PULSE2   ; 852E AD 4F 7F
    bmi .L_8559   ; 8531 30 26
.L_8533:
    lda #$30    ; 8533 A9 30
    sta $4004   ; 8535 8D 04 40
    bne .L_8559   ; 8538 D0 1F
.L_853A:
    lda #$80    ; 853A A9 80
    sta $4008   ; 853C 8D 08 40
    bne .L_8559   ; 853F D0 18
.L_8541:
    lda <$D2     ; 8541 A5 D2
    beq .L_854F   ; 8543 F0 0A
    lda sound.track_controls+sound.TRACK_MUSIC_NOISE   ; 8545 AD 4D 7F
    ora #$02    ; 8548 09 02
    sta sound.track_controls+sound.TRACK_MUSIC_NOISE   ; 854A 8D 4D 7F
    bne .L_8554   ; 854D D0 05
.L_854F:
    lda sound.track_controls+sound.TRACK_EFFECT_NOISE   ; 854F AD 50 7F
    bmi .L_8559   ; 8552 30 05
.L_8554:
    lda #$30    ; 8554 A9 30
    sta $400C   ; 8556 8D 0C 40
.L_8559:
    lda <$D2     ; 8559 A5 D2
    bne .L_856D   ; 855B D0 10
    ldx #$04    ; 855D A2 04
.L_855F:
    lda sound.track_controls,x ; 855F BD 4A 7F
    bmi .L_857C   ; 8562 30 18
    dex             ; 8564 CA
    bpl .L_855F   ; 8565 10 F8
    lda #$00    ; 8567 A9 00
    sta sound.request   ; 8569 8D 42 7F
    rts             ; 856C 60
; ----------------------------------------------------------------------------
.L_856D:
    lda sound.track_controls+sound.TRACK_EFFECT_PULSE2   ; 856D AD 4F 7F
    bmi .L_857C   ; 8570 30 0A
    lda sound.track_controls+sound.TRACK_EFFECT_NOISE   ; 8572 AD 50 7F
    bmi .L_857C   ; 8575 30 05
    lda #$00    ; 8577 A9 00
    sta sound.effect_id   ; 8579 8D 49 7F
.L_857C:
    rts             ; 857C 60
; ----------------------------------------------------------------------------
    VERIFY_PC_TO_PATCH_END sound.process_note_command
;--------------------------------------------------------------------------------------------------
    .endif ;;_FEATURE_CONTINUOUS_MUSIC
;==================================================================================================
