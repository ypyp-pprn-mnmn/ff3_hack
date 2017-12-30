
# $36:820b sound.fetch_note_for_track
> 指定のトラックについて、次の音楽データを取得し、各種再生データと状態を更新する。

### args:
+	in u8 X: track #, [0...7). (music 5 channels + SE 2 channels)
+	in u8 $d1: channel #?
	- 4: pulse1
	- 3: pulse2
	- 2: triangle
	- 1: noise
	- 0: delta modulation

+   in u8 $7f44: master volume?
+	in,out $7f4a[x]: control flags. depending on the value of byte fetched from stream, some flags are set as follows:
	-	01: set if [00...C0)
	-	02: set if [C0...D0)
	-	unaffected: [D0...E0)
	-	depends on the handler: [E0...FF]

+	in,out ptr [$7f51.x, $7f58.x]: pointer to music stream?, its value varies in synch with music playback.

+	out u8 $7f5f[x]: note length countdown. unit = 96th of a whole note. (e.g, 24 = quarter note)
	-	value looked up in static table $8805
	-	indexed by lower 4bits of command byte (or 'note') fetched.
	-	caller of this function decrements this by 1 on each call.

+   in u8 $7f66[x]: octave value. higher value denotes higher pitch. <- low 0 ... 5 high ->

+	out u16 [$7f6d[x], $7f74[x]]: timer value.
    -   will be fed into timer register on each channel. ($4002/4003, 4006/4007, 400a/400b, 400e/400f)
	-	looked up in static table $872d or $87bd, depending on value of $d1.
	-	$872d for pulse1/2, triangle
	-	$87bd for noise
	-	unchanged for delta modulation

+   out u8 $7fba: ?, set to 0 on exit if value of the byte fetched < 0xe0.
+   out u8 $7fc8: ?, set to 0 on exit if value of the byte fetched < 0xe0.
+   out u8 $7fdd: ?, set to 0 on exit if value of the byte fetched < 0xe0.
+   out u8 $7ff2: ?, set to 0 on exit if value of the byte fetched < 0xe0.
+   out u8 $7ff9: ?, set to 0 on exit if value of the byte fetched < 0xe0.

### callers:
+	$36:81e6 sound.update_track

### local variables:
+	ptr $d3: pointer to music stream?, = [$7f51.x, $7f58.x]
+	u8 $d5: command byte (aka note) fetched from the music stream.
+	ptr $d8: pointer to some handler, = [$822f[*$d3 - 0x30]].

### static references:
+	ptr $822f[0x20]: pointer to some handler, indexed by command byte found in the stream.

        e0 8353 835C 8366 8370 837A 8384 838E 8398 
        e8 83A2 83AC 83B6 83C0 83CA 83D4 83DE 83E8 
        f0 83F2 83FC 8406 8410 841A 8424 843A 8450 
        f8 8466 8471 8485 8499 84AF 84D0 84F0 84FF 

    see `$36:8353 sound.process_note_commands` for further details.


+	u16 $872d[12x6]: (used if $d1 >= 2) timer values of the tone denoted by command byte (higher 4bits)
    -   values are defined as follows: (bytes are swapped for readability)
    -   f = 1789773 / (16 * (1 + value_below)); f = CPU / (16 * (t + 1)); 1.789773MHz NTSC
    -   e.g., 00FD = 440.396899606299 (hz)

            C    C#   D    D#   E    F    F#   G    G#   A    A#   B
            06AB 064D 05F3 059D 054C 0501 04B8 0474 0434 03F7 03BE 0388
            0355 0326 02F9 02CE 02A6 0280 025C 023A 0219 01FB 01DE 01C4 
            01AA 0193 017C 0167 0152 013F 012D 011C 010C[00FD]00EF 00E1
            00D5 00C9 00BE 00B3 00A9 009F 0096 008E 0086 007E 0077 0070 
            006A 0064 005E 0059 0054 004F 004B 0046 0042 003E 003B 0038
            0034 0031 002F 002C 0029 0027 0025 0023 0021 001F 001D 001B 

+	u8 $87bd[12x?]: (used if $d1 == 1) timer values of the tone denoted by command byte (higher 4bits), for noise channel.
+	u8 $8805[< 0x10]: some enum value, indxed by lower 4bits of command byte fetched.
    -   values are:
            `60 48 30 24 20 18 12 10 0C 09 08 06 04 03 02 01`


### code
```js
{
	[$d3, $d4] = [$7f51.x, $7f58.x];
    y = 0;
$8217:
    a = $d3[y]; y++;
	if (a >= 0xe0) { 
$821e:
	    x = (a - 0xe0) << 1;
	    [$d8, $d9] = [$822f.x, $8230.x];
	    return ($d8)();
    }
$826f:
    // a < 0xE0
    $d5 = a;
    a = y;  //a == 1
    u16($d3) += a;
    u16([$7f51.x, $7f58.x]) += a;
    y = $d5 & 0x0f;
    $7f5f.x = $8805.y;  //note length. (=> beat counter)
    if ($d5 >= 0xd0) {
        return;
    } else if ($d5 >= 0xc0) {
        $7f4a.x |= 0x02;
        return;
    }
$829a:
    // $d5 < 0xc0
    $7f4a.x = ($7f4a.x | 0x01) & (~0x02);
    $7fba.x =
    $7fc8.x =
    $7fdd.x =
    $7ff9.x =
    $7ff2.x = 0;
    if ($d1 == 0) {
$8310:  //DMC
        if ($7f44 >= 0x05) {
            $4011 = 0xff;
        }
$831c:
        return;
    }
    if ($d1 != 2) {
$82bd:
        sound.udpate_keyoff_timers(); //$831d();
        if ($d1 == 1) {
$82ea:  //noise
            y = $d6 = ($7f66 * 12) + ($d5 >> 4);
            $7f6d.x = $87bd.y;  //pitch
            return;
        }
    }
$82c6:  //pulse1,pulse2,triangle
    y = $d6 = ($7f66 * 12) + ($d5 >> 4);
    $7f6d.x = $872d.y;  //pitch (=> timer legnth low)
    $7f74.x = $872e.y;  //pitch (=> timer length high)
    return;
/*
; ----------------------------------------------------------------------------
    lda $7F51,x ; 820B BD 51 7F
    sta <$D3     ; 820E 85 D3
    lda $7F58,x ; 8210 BD 58 7F
    sta <$D4     ; 8213 85 D4
    ldy #$00    ; 8215 A0 00
.L_8217:
    lda [$D3],y ; 8217 B1 D3
    iny             ; 8219 C8
    cmp #$E0    ; 821A C9 E0
    bcc .L_826F   ; 821C 90 51
        sbc #$E0    ; 821E E9 E0
        asl a       ; 8220 0A
        tax             ; 8221 AA
        lda .L_822F,x ; 8222 BD 2F 82
        sta .L_00D8   ; 8225 85 D8
        lda .L_8230,x ; 8227 BD 30 82
        sta <$D9     ; 822A 85 D9
        jmp (.L_00D8) ; 822C 6C D8 00
; ----------------------------------------------------------------------------
.L_826F:
    sta <$D5     ; 826F 85 D5
    ldx <$D0     ; 8271 A6 D0
    tya             ; 8273 98
    clc             ; 8274 18
    adc <$D3     ; 8275 65 D3
    sta <$D3     ; 8277 85 D3
    sta $7F51,x ; 8279 9D 51 7F
    lda <$D4     ; 827C A5 D4
    adc #$00    ; 827E 69 00
    sta <$D4     ; 8280 85 D4
    sta $7F58,x ; 8282 9D 58 7F
    lda <$D5     ; 8285 A5 D5
    and #$0F    ; 8287 29 0F
    tay             ; 8289 A8
    lda .L_8805,y ; 828A B9 05 88
    sta $7F5F,x ; 828D 9D 5F 7F
    lda <$D5     ; 8290 A5 D5
    cmp #$D0    ; 8292 C9 D0
    bcs .L_82E9   ; 8294 B0 53
        cmp #$C0    ; 8296 C9 C0
        bcs .L_8307   ; 8298 B0 6D
            lda $7F4A,x ; 829A BD 4A 7F
            ora #$01    ; 829D 09 01
            and #$FD    ; 829F 29 FD
            sta $7F4A,x ; 82A1 9D 4A 7F
            lda #$00    ; 82A4 A9 00
            sta $7FBA,x ; 82A6 9D BA 7F
            sta $7FC8,x ; 82A9 9D C8 7F
            sta $7FDD,x ; 82AC 9D DD 7F
            sta $7FF9,x ; 82AF 9D F9 7F
            sta $7FF2,x ; 82B2 9D F2 7F
            lda <$D1     ; 82B5 A5 D1
            beq .L_8310   ; 82B7 F0 57
                
			cmp #$02    ; 82B9 C9 02
            beq .L_82C6   ; 82BB F0 09
            
				jsr .L_831D   ; 82BD 20 1D 83
				lda <$D1     ; 82C0 A5 D1
				cmp #$01    ; 82C2 C9 01
				beq .L_82EA   ; 82C4 F0 24
        .L_82C6:
		;; $d1 >= 0x03 || $d1 == 2
            lda $7F66,x ; 82C6 BD 66 7F
            asl a       ; 82C9 0A
            asl a       ; 82CA 0A
            sta .L_00D6   ; 82CB 85 D6
			;; A / $d6 = $7f66 x 4
            asl a       ; 82CD 0A
			;; A = $7f66 x 8
            adc .L_00D6   ; 82CE 65 D6
            sta .L_00D6   ; 82D0 85 D6
			;; $d6 = $7f66 x 12
            lda <$D5     ; 82D2 A5 D5
            lsr a       ; 82D4 4A
            lsr a       ; 82D5 4A
            lsr a       ; 82D6 4A
            lsr a       ; 82D7 4A
            clc             ; 82D8 18
            adc .L_00D6   ; 82D9 65 D6
            asl a       ; 82DB 0A
            tay             ; 82DC A8
			;; $d5 := always < 0xc0.
			;; Y = (($7f66 x 12) + ($d5 >> 4)) << 1
			;; Y = pitch or note??, $7f66 = octave?
            lda .L_872D,y ; 82DD B9 2D 87
            sta $7F6D,x ; 82E0 9D 6D 7F
            lda .L_872E,y ; 82E3 B9 2E 87
            sta $7F74,x ; 82E6 9D 74 7F
.L_82E9:
    rts             ; 82E9 60
; ----------------------------------------------------------------------------
.L_82EA:
                    lda $7F66,x ; 82EA BD 66 7F
                    asl a       ; 82ED 0A
                    asl a       ; 82EE 0A
                    sta .L_00D6   ; 82EF 85 D6
                    asl a       ; 82F1 0A
                    adc .L_00D6   ; 82F2 65 D6
                    sta .L_00D6   ; 82F4 85 D6
                    lda <$D5     ; 82F6 A5 D5
                    lsr a       ; 82F8 4A
                    lsr a       ; 82F9 4A
                    lsr a       ; 82FA 4A
                    lsr a       ; 82FB 4A
                    clc             ; 82FC 18
                    adc .L_00D6   ; 82FD 65 D6
                    tay             ; 82FF A8
                    lda .L_87BD,y ; 8300 B9 BD 87
                    sta $7F6D,x ; 8303 9D 6D 7F
                    rts             ; 8306 60
; ----------------------------------------------------------------------------
.L_8307:
          lda $7F4A,x ; 8307 BD 4A 7F
          ora #$02    ; 830A 09 02
          sta $7F4A,x ; 830C 9D 4A 7F
          rts             ; 830F 60
; ----------------------------------------------------------------------------
.L_8310:
    lda $7F44   ; 8310 AD 44 7F
    cmp #$05    ; 8313 C9 05
    bcc .L_831C   ; 8315 90 05
        lda #$FF    ; 8317 A9 FF
        sta $4011   ; 8319 8D 11 40
.L_831C:
    rts             ; 831C 60
*/
}
```

