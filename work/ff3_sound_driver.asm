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
    .ifdef _OPTIMIZE_SOUND_DRIVER

sound.table.note_lengths = $8805
sound.table.pitch_periods = $872d
sound.table.noise_periods = $87bd
sound_x.saved_states = $7f30
sound_x.saved_music_id = $7f35

    .macro DECLARE_SOUND_DRIVER_VARIABLES
.track_id = $d0
.channel_id = $d1
.p_stream = $d3
.command_byte = $d5
.note_pitch = $d6
    .endm

;;$36:820b sound.fetch_note_for_track
;;
;;    指定のトラックについて、次の音楽データを取得し、各種再生データと状態を更新する。
;;
;;args:
;;
;;    in u8 X: track #, [0…7). (music 5 channels + SE 2 channels)
;;    in u8 $d1: channel #?
;;        4: pulse1
;;        3: pulse2
;;        2: triangle
;;        1: noise
;;        0: delta modulation
;;    in u8 $7f44: master volume?
;;    in,out $7f4a[x]: control flags. depending on the value of byte fetched from stream, some flags are set as follows:
;;        01: set if [00…C0)
;;        02: set if [C0…D0)
;;        unaffected: [D0…E0)
;;        depends on the handler: [E0…FF]
;;
;;    in,out ptr [$7f51.x, $7f58.x]: pointer to music stream?, its value varies in synch with music playback.
;;    out u8 $7f5f[x]: note length countdown. unit = 96th of a whole note. (e.g, 24 = quarter note)
;;        value looked up in static table $8805
;;        indexed by lower 4bits of command byte (or ‘note’) fetched.
;;        caller of this function decrements this by 1 on each call.
;;
;;    in u8 $7f66[x]: octave value. higher value denotes higher pitch. <- low 0 … 5 high ->
;;    out u16 [$7f6d[x], $7f74[x]]: timer value.
;;        will be fed into timer register on each channel. ($4002/4003, 4006/4007, 400a/400b, 400e/400f)
;;        looked up in static table $872d or $87bd, depending on value of $d1.
;;        $872d for pulse1/2, triangle
;;        $87bd for noise
;;        unchanged for delta modulation
;;    out u8 $7fba: ?, set to 0 on exit if value of the byte fetched < 0xe0.
;;    out u8 $7fc8: ?, set to 0 on exit if value of the byte fetched < 0xe0.
;;    out u8 $7fdd: ?, set to 0 on exit if value of the byte fetched < 0xe0.
;;    out u8 $7ff2: ?, set to 0 on exit if value of the byte fetched < 0xe0.
;;
;;    out u8 $7ff9: ?, set to 0 on exit if value of the byte fetched < 0xe0.
;;
;;callers:
;;
;;    $36:81e6 sound.update_track
;;
;;local variables:
;;
;;    ptr $d3: pointer to music stream?, = [$7f51.x, $7f58.x]
;;    u8 $d5: command byte (aka note) fetched from the music stream.
;;    ptr $d8: pointer to some handler, = [822f[*d3 - 0x30]].
;;
;;static references:
;;
;;    ptr $822f[0x20]: pointer to some handler, indexed by command byte found in the stream.
;;
;;    e0 8353 835C 8366 8370 837A 8384 838E 8398 
;;    e8 83A2 83AC 83B6 83C0 83CA 83D4 83DE 83E8 
;;    f0 83F2 83FC 8406 8410 841A 8424 843A 8450 
;;    f8 8466 8471 8485 8499 84AF 84D0 84F0 84FF 
;;
;;    see $36:8353 sound.process_note_commands for further details.
;;    u16 $872d[12x6]: (used if $d1 >= 2) timer values of the tone denoted by command byte (higher 4bits)
;;        values are defined as follows: (bytes are swapped for readability)
;;        f = 1789773 / (16 * (1 + value_below)); f = CPU / (16 * (t + 1)); 1.789773MHz NTSC
;;
;;        e.g., 00FD = 440.396899606299 (hz)
;;
;;        C    C#   D    D#   E    F    F#   G    G#   A    A#   B
;;        06AB 064D 05F3 059D 054C 0501 04B8 0474 0434 03F7 03BE 0388
;;        0355 0326 02F9 02CE 02A6 0280 025C 023A 0219 01FB 01DE 01C4 
;;        01AA 0193 017C 0167 0152 013F 012D 011C 010C[00FD]00EF 00E1
;;        00D5 00C9 00BE 00B3 00A9 009F 0096 008E 0086 007E 0077 0070 
;;        006A 0064 005E 0059 0054 004F 004B 0046 0042 003E 003B 0038
;;        0034 0031 002F 002C 0029 0027 0025 0023 0021 001F 001D 001B 
;;
;;    u8 $87bd[12x?]: (used if $d1 == 1) timer values of the tone denoted by command byte (higher 4bits), for noise channel.
;;    u8 $8805[< 0x10]: some enum value, indxed by lower 4bits of command byte fetched.
;;        values are: 60 48 30 24 20 18 12 10 0C 09 08 06 04 03 02 01
    INIT_PATCH_EX sound.fetch_note_for_track, $36, $820b, $831d, $820b
sound.fetch_note_for_track: ;;$36:820b
;; fixups.
    FIX_ADDR_ON_CALLER $36,$81f2+1  ;;81F2 20 0B 82 @$36:81e6 sound.update_track
;;
    DECLARE_SOUND_DRIVER_VARIABLES
    lda sound.p_streams.low,x ; 820B BD 51 7F
    sta <.p_stream     ; 820E 85 D3
    lda sound.p_streams.high,x ; 8210 BD 58 7F
    sta <.p_stream+1     ; 8213 85 D4
    ldy #$00    ; 8215 A0 00
    FALL_THROUGH_TO sound.fetch_note_for_track.continue

sound.fetch_note_for_track.continue:
    DECLARE_SOUND_DRIVER_VARIABLES
    lda [.p_stream],y ; 8217 B1 D3
    iny             ; 8219 C8
    cmp #$E0    ; 821A C9 E0
    bcc sound.process_play_note   ; 821C 90 51
        sbc #$E0    ; 821E E9 E0
        asl a       ; 8220 0A
        tax             ; 8221 AA
        lda sound.note_handlers,x ; 8222 BD 2F 82
        sta <$D8   ; 8225 85 D8
        lda sound.note_handlers+1,x ; 8227 BD 30 82
        sta <$D9     ; 822A 85 D9
        jmp [$D8] ; 822C 6C D8 00

sound.note_handlers:
    .dw sound.note.set_tempo
    .dw sound.note.set_volume_2
    .dw sound.note.set_volume_3
    .dw sound.note.set_volume_4
    .dw sound.note.set_volume_5
    .dw sound.note.set_volume_6
    .dw sound.note.set_volume_7
    .dw sound.note.set_volume_8
    .dw sound.note.set_volume_9
    .dw sound.note.set_volume_a
    .dw sound.note.set_volume_b
    .dw sound.note.set_volume_c
    .dw sound.note.set_volume_d
    .dw sound.note.set_volume_e
    .dw sound.note.set_volume_f
    .dw sound.note.set_octave_0
    .dw sound.note.set_octave_1
    .dw sound.note.set_octave_2
    .dw sound.note.set_octave_3
    .dw sound.note.set_octave_4
    .dw sound.note.set_octave_5
    .dw sound.note.set_duty_30
    .dw sound.note.set_duty_70
    .dw sound.note.set_duty_b0
    .dw sound.note.set_sweep
    .dw sound.note.init_track_o4
    .dw sound.note.init_track_o5
    .dw sound.note.enter_loop
    .dw sound.note.end_of_loop
    .dw sound.note.break_loop
    .dw sound.note.jump
    .dw sound.note.end_of_stream

; ----------------------------------------------------------------------------
sound.process_play_note:
    DECLARE_SOUND_DRIVER_VARIABLES
    sta <.command_byte     ; 826F 85 D5
    ldx <.track_id     ; 8271 A6 D0
    tya             ; 8273 98
    clc             ; 8274 18
    adc <.p_stream     ; 8275 65 D3
    sta <.p_stream     ; 8277 85 D3
    sta sound.p_streams.low,x ; 8279 9D 51 7F
    lda <.p_stream+1     ; 827C A5 D4
    adc #$00    ; 827E 69 00
    sta <.p_stream+1     ; 8280 85 D4
    sta sound.p_streams.high,x ; 8282 9D 58 7F
    lda <.command_byte     ; 8285 A5 D5
    and #$0F    ; 8287 29 0F
    tay             ; 8289 A8
    lda sound.table.note_lengths,y ; 828A B9 05 88
    sta sound.note_lengths,x ; 828D 9D 5F 7F
    lda <.command_byte     ; 8290 A5 D5
    cmp #$D0    ; 8292 C9 D0
    bcs .L_82E9   ; 8294 B0 53
        cmp #$C0    ; 8296 C9 C0
        bcs .L_8307   ; 8298 B0 6D
            lda sound.track_controls,x ; 829A BD 4A 7F
            ora #$01    ; 829D 09 01
            and #$FD    ; 829F 29 FD
            sta sound.track_controls,x ; 82A1 9D 4A 7F
            lda #$00    ; 82A4 A9 00
            sta sound.volume_envelopes.type,x ; 82A6 9D BA 7F
            sta sound.volume_envelopes.phase,x ; 82A9 9D C8 7F
            sta sound.volume_envelopes.timer,x ; 82AC 9D DD 7F
            sta sound.pitch_modulations.timer,x ; 82AF 9D F9 7F
            sta sound.pitch_modulations.phase,x ; 82B2 9D F2 7F
            lda <.channel_id     ; 82B5 A5 D1
            beq .L_8310   ; 82B7 F0 57
                cmp #$02    ; 82B9 C9 02
                beq .L_82C6   ; 82BB F0 09
                    jsr sound.udpate_keyoff_timers   ; 82BD 20 1D 83
                    lda <.channel_id     ; 82C0 A5 D1
                    cmp #$01    ; 82C2 C9 01
                    beq .L_82EA   ; 82C4 F0 24
        .L_82C6:
            lda sound.note_octaves,x ; 82C6 BD 66 7F
            asl a       ; 82C9 0A
            asl a       ; 82CA 0A
            sta <.note_pitch  ; 82CB 85 D6
            asl a       ; 82CD 0A
            adc <.note_pitch  ; 82CE 65 D6
            sta <.note_pitch  ; 82D0 85 D6
            lda <.command_byte     ; 82D2 A5 D5
            lsr a       ; 82D4 4A
            lsr a       ; 82D5 4A
            lsr a       ; 82D6 4A
            lsr a       ; 82D7 4A
            clc             ; 82D8 18
            adc <.note_pitch  ; 82D9 65 D6
            asl a       ; 82DB 0A
            tay             ; 82DC A8
            lda sound.table.pitch_periods,y ; 82DD B9 2D 87
            sta sound.note_pitch_timers.low,x ; 82E0 9D 6D 7F
            lda sound.table.pitch_periods+1,y ; 82E3 B9 2E 87
            sta sound.note_pitch_timers.high,x ; 82E6 9D 74 7F
.L_82E9:
    rts             ; 82E9 60
; ----------------------------------------------------------------------------
.L_82EA:
                    lda sound.note_octaves,x ; 82EA BD 66 7F
                    asl a       ; 82ED 0A
                    asl a       ; 82EE 0A
                    sta <.note_pitch  ; 82EF 85 D6
                    asl a       ; 82F1 0A
                    adc <.note_pitch  ; 82F2 65 D6
                    sta <.note_pitch  ; 82F4 85 D6
                    lda <.command_byte     ; 82F6 A5 D5
                    lsr a       ; 82F8 4A
                    lsr a       ; 82F9 4A
                    lsr a       ; 82FA 4A
                    lsr a       ; 82FB 4A
                    clc             ; 82FC 18
                    adc <.note_pitch  ; 82FD 65 D6
                    tay             ; 82FF A8
                    lda sound.table.noise_periods,y ; 8300 B9 BD 87
                    sta sound.note_pitch_timers.low,x ; 8303 9D 6D 7F
                    rts             ; 8306 60
; ----------------------------------------------------------------------------
.L_8307:
          lda sound.track_controls,x ; 8307 BD 4A 7F
          ora #$02    ; 830A 09 02
          sta sound.track_controls,x ; 830C 9D 4A 7F
          rts             ; 830F 60
; ----------------------------------------------------------------------------
.L_8310:
    lda sound.master_volume   ; 8310 AD 44 7F
    cmp #$05    ; 8313 C9 05
    bcc .L_831C   ; 8315 90 05
        lda #$FF    ; 8317 A9 FF
        sta $4011   ; 8319 8D 11 40
.L_831C:
    rts             ; 831C 60
;--------------------------------------------------------------------------------------------------
    VERIFY_PC_TO_PATCH_END sound.fetch_note_for_track
;==================================================================================================
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
;--------------------------------------------------------------------------------------------------
    INIT_PATCH_EX sound.process_note_command, $36, $8353, $857d, $8353
;--------------------------------------------------------------------------------------------------
;; case 0xe0:
sound.note.set_tempo:
    DECLARE_SOUND_DRIVER_VARIABLES
    lda [.p_stream],y ; 8353 B1 D3
    iny             ; 8355 C8
    sta sound.bpm   ; 8356 8D 45 7F
    jmp sound.fetch_note_for_track.continue   ; 8359 4C 17 82
;--------------------------------------------------------------------------------------------------
;; case 0xe1...ee:
sound.note.set_volume_2:
sound.note.set_volume_3:
sound.note.set_volume_4:
sound.note.set_volume_5:
sound.note.set_volume_6:
sound.note.set_volume_7:
sound.note.set_volume_8:
sound.note.set_volume_9:
sound.note.set_volume_a:
sound.note.set_volume_b:
sound.note.set_volume_c:
sound.note.set_volume_d:
sound.note.set_volume_e:
sound.note.set_volume_f:
    DECLARE_SOUND_DRIVER_VARIABLES
    inx
    inx
    txa ;;a = ((command_byte - 0xE0) << 1 + 2)
    lsr A
    ldx <.track_id     ; 835C A6 D0
    ;lda #$02    ; 835E A9 02
    sta sound.volume_envelopes.control,x ; 8360 9D 90 7F
    jmp sound.fetch_note_for_track.continue   ; 8363 4C 17 82
;--------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------
;; case 0xef:
sound.note.set_octave_0:
sound.note.set_octave_1:
sound.note.set_octave_2:
sound.note.set_octave_3:
sound.note.set_octave_4:
sound.note.set_octave_5:
    DECLARE_SOUND_DRIVER_VARIABLES
    txa ;;x := [1e...28]
    lsr A
    ;;here carry is always 'clear'
    ;; A := 0f...14
    sbc #($0f-1)
    ldx <.track_id     ; 83E8 A6 D0
    ;lda #$00    ; 83EA A9 00
    sta sound.note_octaves,x ; 83EC 9D 66 7F
    jmp sound.fetch_note_for_track.continue   ; 83EF 4C 17 82
;--------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------
;; case 0xF5:
sound.note.set_duty_30:
sound.note.set_duty_70:
sound.note.set_duty_b0:
    DECLARE_SOUND_DRIVER_VARIABLES
    txa ;; x := [2a...2e]
    lsr A
    ;;here carry is always 'clear'
    sbc #($15-1)
    ;; A := [0...2]
    lsr A
    ror A
    ror A
    ora #$30
    ldx <.track_id     ; 8424 A6 D0
    ;lda #$30    ; 8426 A9 30
    sta sound.duty_controls,x ; 8428 9D 89 7F
    lda [.p_stream],y ; 842B B1 D3
    iny             ; 842D C8
    sta $7FC1,x ; 842E 9D C1 7F
    lda [.p_stream],y ; 8431 B1 D3
    iny             ; 8433 C8
    sta sound.pitch_modulations.type,x ; 8434 9D EB 7F
    jmp sound.fetch_note_for_track.continue   ; 8437 4C 17 82
;--------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------
;; case 0xF8:
sound.note.set_sweep:
    DECLARE_SOUND_DRIVER_VARIABLES
    ldx <.track_id     ; 8466 A6 D0
    lda [.p_stream],y ; 8468 B1 D3
    iny             ; 846A C8
    sta sound.sweep_controls,x ; 846B 9D 82 7F
    jmp sound.fetch_note_for_track.continue   ; 846E 4C 17 82
;--------------------------------------------------------------------------------------------------
;; case 0xF9:
sound.note.init_track_o4:
sound.note.init_track_o5:
    DECLARE_SOUND_DRIVER_VARIABLES
    txa
    lsr A
    sbc #($19-1)
    pha
    ldx <.track_id     ; 8471 A6 D0
    ;lda #$04    ; 8473 A9 04
    ora #$04
    sta sound.note_octaves,x ; 8475 9D 66 7F
    ;lda #$00    ; 8478 A9 00
    pla
    sta $7FC1,x ; 847A 9D C1 7F
    lda #$08    ; 847D A9 08
    sta sound.volume_envelopes.control,x ; 847F 9D 90 7F
    jmp sound.fetch_note_for_track.continue   ; 8482 4C 17 82
;--------------------------------------------------------------------------------------------------
;;; case 0xFA:
;sound.note.init_track_o5:
;    DECLARE_SOUND_DRIVER_VARIABLES
;    ldx <.track_id     ; 8485 A6 D0
;    lda #$05    ; 8487 A9 05
;    sta sound.note_octaves,x ; 8489 9D 66 7F
;    lda #$01    ; 848C A9 01
;    sta $7FC1,x ; 848E 9D C1 7F
;    lda #$0F    ; 8491 A9 0F
;    sta sound.volume_envelopes.control,x ; 8493 9D 90 7F
;    jmp sound.fetch_note_for_track.continue   ; 8496 4C 17 82
;--------------------------------------------------------------------------------------------------
;; case 0xFB:
sound.note.enter_loop:
    DECLARE_SOUND_DRIVER_VARIABLES
    lda [.p_stream],y ; 8499 B1 D3
    iny             ; 849B C8
    ldx <.track_id     ; 849C A6 D0
    inc sound.loops.control,x ; 849E FE A5 7F
    bne .L_84A9   ; 84A1 D0 06
    sta sound.loops.counter_1,x ; 84A3 9D AC 7F
    jmp sound.fetch_note_for_track.continue   ; 84A6 4C 17 82
; ----------------------------------------------------------------------------
.L_84A9:
    sta sound.loops.counter_2,x ; 84A9 9D B3 7F
    jmp sound.fetch_note_for_track.continue   ; 84AC 4C 17 82
;--------------------------------------------------------------------------------------------------
;; case 0xFC:
sound.note.end_of_loop:
    DECLARE_SOUND_DRIVER_VARIABLES
    ldx <.track_id     ; 84AF A6 D0
    lda sound.loops.control,x ; 84B1 BD A5 7F
    bne .L_84C3   ; 84B4 D0 0D
    dec sound.loops.counter_1,x ; 84B6 DE AC 7F
    bne sound.note.jump   ; 84B9 D0 35
    iny             ; 84BB C8
    iny             ; 84BC C8
    dec sound.loops.control,x ; 84BD DE A5 7F
    jmp sound.fetch_note_for_track.continue   ; 84C0 4C 17 82
; ----------------------------------------------------------------------------
.L_84C3:
    dec sound.loops.counter_2,x ; 84C3 DE B3 7F
    bne sound.note.jump   ; 84C6 D0 28
    iny             ; 84C8 C8
    iny             ; 84C9 C8
    dec sound.loops.control,x ; 84CA DE A5 7F
    jmp sound.fetch_note_for_track.continue   ; 84CD 4C 17 82
;--------------------------------------------------------------------------------------------------
;; case 0xFD:
sound.note.break_loop:
    DECLARE_SOUND_DRIVER_VARIABLES
    ldx <.track_id     ; 84D0 A6 D0
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
;--------------------------------------------------------------------------------------------------
;; case 0xFE:
sound.note.jump:
    DECLARE_SOUND_DRIVER_VARIABLES
.L_84F0:
    lda [.p_stream],y ; 84F0 B1 D3
    iny             ; 84F2 C8
    tax             ; 84F3 AA
    lda [.p_stream],y ; 84F4 B1 D3
    sta <.p_stream+1     ; 84F6 85 D4
    stx <.p_stream     ; 84F8 86 D3
    ldy #$00    ; 84FA A0 00
    jmp sound.fetch_note_for_track.continue   ; 84FC 4C 17 82
;--------------------------------------------------------------------------------------------------
;; case 0xFF:
sound.note.end_of_stream:
    DECLARE_SOUND_DRIVER_VARIABLES
    ldx <.track_id     ; 84FF A6 D0
    lda sound.track_controls,x ; 8501 BD 4A 7F
    and #$7F    ; 8504 29 7F
    sta sound.track_controls,x ; 8506 9D 4A 7F
    lda <.channel_id     ; 8509 A5 D1
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
;--------------------------------------------------------------------------------------------------
    .if 0
sound_x.load_dummy_sample:
.null_delta_modulation_data = $e9c0
    lda #((.null_delta_modulation_data & $3fc0) >> 6)
    sta $4012   ;;sample address
    lda #0
    sta $4013   ;;sample length
    rts

sound_x.set_dmc_irq_handler:
    lda #($80 | $0f)    ;;pitch index = 0f / interrupt requested (80), loop disabled
    sta $4010   ;; 
    jsr sound_x.load_dummy_sample
    lda #$10    ;;enable DMC
    sta $4015
    ;; set handler address
    lda #HIGH(sound_x.on_dmc_irq)
    sta irq_handler_entry+2
    lda #LOW(sound_x.on_dmc_irq)
    sta irq_handler_entry+1

    lda #$4c    
    cli
sound_x.update_irq_entry:
    sta irq_handler_entry+0
    rts

sound_x.remove_dmc_irq_handler:
    sei
    lda #$40    ;;rti
    bne sound_x.update_irq_entry

sound_x.test:
    FIX_ADDR_ON_CALLER $36,$8022+1  ;;8022 20 AB 80 @ $36:8003 sound.update_playback
    
    lda irq_handler_entry
    cmp #$40    ;;rti
    bne .have_handler
        lda #0
        sta $7f30
        sta $7f31
        sta $7f32
        sta $7f33
        sta $7f34
        jmp sound_x.set_dmc_irq_handler
.have_handler:
    lda #$10    ;;enable DMC
    sta $4015
    rts
    
sound_x.update_dmc:
    ldx sound.note_pitch_timers.low     ;;unit = 16 CPU cycles.
    ldy sound.note_pitch_timers.high
    cpx $7f30
    bne .pitch_chnaged
    cpy $7f31
    beq .pitch_unchanged
.pitch_chnaged:
        stx $7f30
        sty $7f31
        ;stx $7f32
        ;sty $7f33
        lda #0
        sta $7f34
        beq .output_waveform
.pitch_unchanged:
    ;;27 * 16 = 432 = 54 * 8 ($0f = 54 CPU cycles / output level changes
    ;SUB16by8 $7f32,#27
    sec
    lda $7f32
    ;sbc #27
    sbc #108
    sta $7f32
    lda $7f33
    sbc #0
    sta $7f33
    bcs .leave_interrupt
.output_waveform:
        stx $7f32
        sty $7f33
        jsr sound_x.load_dummy_sample
        ldx $7f34
        lda sound_x.waveform,x
        lda #$7f
        sta $4011
        inx
        txa
        ;and #$1f
        and #$1f
        sta $7f34
.leave_interrupt:
    lda $4015
    and #$1f
    sta $4015
    rts

sound_x.waveform:
;020030605070506050607F5868340002
    .db $3f,$7f,$3f,$1f
    .db $04,$02,$10,$20, $30,$3b,$32,$41
    .db $3c,$3a,$32,$3b, $30,$37,$3d,$39
    .db $33,$40,$49,$4c, $46,$40,$39,$3c
    .db $42,$32,$24,$16, $08,$00,$04,$03
    .endif ;;0

    .if 0
    FIX_ADDR_ON_CALLER $36,$8014+1  ;;8014 20 25 89 @ $36:8003 sound.update_playback
.length_counter.low = $d4
.length_counter.high = $d5
.pitch.low = $d6
.pitch.high = $d7
.timer.low = $d8
.timer.high = $d9
    ldy #0
.play_notes:
        tya
        and #$7
        tay
        ldx .notes,y
        lda sound.table.pitch_periods+0,x
        sta <.pitch.low
        lda sound.table.pitch_periods+1,x
        sta <.pitch.high

        lsr <.pitch.high
        ror <.pitch.low
        lsr <.pitch.high
        ror <.pitch.low
        lsr <.pitch.high
        ror <.pitch.low
        sec
        ;lda <.pitch.low
        ;sbc #3
        ;sta <.pitch.low
        ;lda <.pitch.high
        ;sbc #0
        ;sta <.pitch.high
        
        lda #$00
        sta <.length_counter.low
        lda #$10
        sta <.length_counter.high
    .generate_sound:
            ldx #32
        .generate_waveform:
                lda .waveform,x
                sta $4011
                lda <.pitch.low
                sta <.timer.low
                lda <.pitch.high
                sta <.timer.high
            .delay:
                    bit <.timer.low
                    dec <.timer.low ;2
                    bne .delay  ;3 (if taken)
                    lda <.timer.high
                    beq .next
                    dec <.timer.high
                    jmp .delay
            .next:
                dex
                bne .generate_waveform
            sec
            lda <.length_counter.low
            sbc <.pitch.low
            sta <.length_counter.low
            lda <.length_counter.high
            sbc <.pitch.high
            sta <.length_counter.high
            bcs .generate_sound
            
    .next_note:
        iny
        bne .play_notes
.notes:
    .db 2*(12*3+0)
    .db 2*(12*3+2)
    .db 2*(12*3+4)
    .db 2*(12*3+5)
    .db 2*(12*3+7)
    .db 2*(12*3+9)
    .db 2*(12*3+11)
    .db 2*(12*4+0)
    .endif  ;;0
;--------------------------------------------------------------------------------------------------
    .if 0
    ;.ifdef _FEATURE_CONTINUOUS_MUSIC
sound_x.offsets:
    .db sound.loops.control - $7f40
    .db sound.loops.counter_1 - $7f40
    .db sound.loops.counter_2 - $7f40
    .db sound.p_streams.high - $7f40
    .db sound.p_streams.low - $7f40

sound_x.music.on_load:
    FIX_ADDR_ON_CALLER $36,$8952+1  ;;jsr .L_89C3   ; 8952 20 C3 89
    FIX_ADDR_ON_CALLER $36,$8973+1  ;;jsr .L_89C3   ; 8973 20 C3 89
;;
    lda sound.next_music_id
    ;and #$7f
    cmp sound.previous_music_id
    beq .just_load_music
    cmp sound_x.saved_music_id
    beq .just_load_music
        ldx #4
    .save_playback_states:
            ldy sound_x.offsets,x
            lda $7f40,y
            sta sound_x.saved_states,x
            dex
            bpl .save_playback_states
        lda sound.previous_music_id
        sta sound_x.saved_music_id
.just_load_music:
    jmp sound.music.load_stream ;;$89c3
;;$36:8a87 sound.music.cue_up
;;    リクエストされた曲を、要求フラグ($7f42)に応じて、開始状態またはフェードイン状態へ移行させる。
;;args:
;;    in,out u8 $7f42: request flags. see also $36:80ab sound.play_music.
;;callers:
;;    $36:89c3 sound.music.load_stream
sound_x.music.on_cue:
    FIX_ADDR_ON_CALLER $36,$8a83+1      ;;jsr .L_8A87   ; 8A83 20 87 8A
;;---
    lda sound.next_music_id
    ;and #$7f
    cmp sound_x.saved_music_id
    bne .cue

    ;lda sound.next_music_id
    cmp sound.previous_music_id
    ;and #$7f
    beq .cue
    ;beq .fast_forward
    bne .fast_forward
    
    .do_forward:
        jsr sound.music.update_each_track   ;;8b2d
    ;;fast forward to saved state.
    .fast_forward:
        ldx #4
        .check_loop:
            ldy sound_x.offsets,x
            lda $7f40,y
            cmp sound_x.saved_states,x
            bne .do_forward
            dex
            bpl .check_loop
.cue:
    jmp sound.music.cue_up
    .endif  ;;_FEATURE_CONTINUOUS_MUSIC
;--------------------------------------------------------------------------------------------------
    VERIFY_PC_TO_PATCH_END sound.process_note_command
;--------------------------------------------------------------------------------------------------
    .if 0
    RESTORE_PC floor.treasure.FREE_BEGIN
sound_x.on_dmc_irq:
    pha
    txa
    pha
    tya
    pha

    lda <sys_x.last_bank.1st
    pha
    lda #$36
    jsr thunk.switch_1st_bank

    jsr sound_x.update_dmc

    pla
    jsr thunk.switch_1st_bank

    pla
    tay
    pla
    tax
    pla
    rti
    VERIFY_PC_TO_PATCH_END floor.treasure
    .endif ;;0
;--------------------------------------------------------------------------------------------------
    .endif ;;_OPTIMIZE_SOUND_DRIVER
;==================================================================================================
