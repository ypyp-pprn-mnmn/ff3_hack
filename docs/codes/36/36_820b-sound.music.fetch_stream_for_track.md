
# $36:820b sound.music.fetch_stream_for_track

### args:
+	in u8 X: track #, [0...7). (music 5 channels + SE 2 channels)
+	in u8 $d1: channel #?
	- 4: pulse1
	- 3: pulse2
	- 2: triangle
	- 1: noise
	- 0: delta modulation

+	in,out $7f4a[x]: control flags. depending on the value of byte fetched from stream, some flags are set as follows:
	-	01: set if [00...C0)
	-	02: set if [C0...D0)
	-	unaffected: [D0...E0)
	-	depends on the handler: [E0...FF]

+	in,out ptr [$7f51.x, $7f58.x]: pointer to music stream?, its value varies in synch with music playback.

+	out u8 $7f5f[x]: duration?
	-	value looked up in static table $8805
	-	indexed by lower 4bits of command byte (or 'note') fetched.
	-	caller of this function decrements this by 1 on each call.

+	out u16 [$7f6d[x], $7f74[x]]: wave length?
	-	looked up in static table $872d or $87bd, depending on value of $d1.
	-	$872d for pulse1/2, triangle
	-	$87bd for noise
	-	unchanged for delta modulation

### callers:
+	$36:81e6 sound.music.update_track

### local variables:
+	ptr $d3: pointer to music stream?, = [$7f51.x, $7f58.x]
+	u8 $d5: command byte fetched from the music stream.
+	ptr $d8: pointer to some handler, = [$822f[*$d3 - 0x30]].

### static references:
+	ptr $822f[< 0x20]: pointer to some handler, indexed by command byte found in the stream.
+	u16 $872d[12x6]: (used if $di >= 3) wave length? of the tone denoted by command byte (higher 4bits)
+	u8 $87bd[12x?]: (used if $d1 == 1) wave length? 
+	u8 $8805[< 0x10]: some enum value, indxed by lower 4bits of command byte fetched.

### code
```js
{
	$d3,d4 = $7f51.x,$7f58.x
	y = 0;
	a = $d3[y]; y++;
	if (a < #e0) $826f
$821e:
	x = (a - #e0) << 1;
	$d8,d9 = $822f.x,$8230.x
	(*$d8)();
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




