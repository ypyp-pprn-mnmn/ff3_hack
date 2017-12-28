
# $36:89c3 sound.music.load_stream
> 指定の音楽のデータを再生用にロードする。

### args:
+	in u8 $7f43: music id
+   out u8 $7f45: bpm. set to 150 (as a default) on exit.
+   out u16 $7f46: beat counter. set to 0 on exit.
+   out u8 $7f4a[7]: track control flags.
    on exit, set to 0x80, if the track is available in the song loaded. otherwise 0.
+   out u8 $7f51[7]: pointer to stream, low.
+   out u8 $7f58[7]: pointer to stream, high.
    if both low and high are 0xff, then the track is not used for the song loaded.
+   out u8 $7f7b[7]: volume, set to 0x00 on exit.
+   out u8 $7f82[7]: sweep, set to 0x08 on exit.
+   out u8 $7f89[7]: duty/envelope, set to 0x30 on exit.
+   out u8 $7f90[7]: ?, set to 0x0f on exit. volume curve pattern? some enum used to index static curve patterns.
+   out u8 $7fa5[7]: ?, set to 0xff on exit.
+   out u8 $7fba[7]: ?, set to 0xff on exit. some looped counter related to volume control commands.
+   out u8 $7fc1[7]: ?, set to 0xff on exit. some index related to volume control commands.
+   out u8 $7feb[7]: ?, set to 0xff on exit. some enum related to pitch modulation commands.

### callers:
+	$36:8925 sound.music.update_or_load_stream

### local variables:
+	ptr $d8: pointer to stream (track pointers.)

### static references:
+	MusicTrack* $a000[]: (6e000) pointer to stream, for music_id: [0x00,0x19)
+	MusicTrack* $a000[]: (70000) pointer to stream, for music_id: [0x19,0x2B)
	- note: though the address is the same as the above, ROM address is different.
+	MusicTrack* $8c77[]: (6ac77) pointer to stream, for music_id: [0x2B,0x37)
+	MusicTrack* $b3ae[]: (733ae) pointer to stream, for music_id: [0x37,0x3B)
+	MusicTrack* $b400[]: (73400) pointer to stream, for music_id: [0x3B,...)

		MusicTrack : {
			AudioStream* pulse1, pulse2, triangle, noise, dmc;
		};
		SoundEffectTrack: {
			AudioStream* pulse2, noise;
		};

### notes:
write notes here

### (pseudo)code:
```js
{
	sound.music.mute_channels();	//$8ac0

	for (x = 4; x > 0; --x) {
		$7f4a.x = 0;	//track control
		$7f5f.x = 0;	//note length
		$7f7b.x = 0;	//volume
		$7f82.x = 0x08;	//sweep
		$7f89.x = 0x30;	//duty/envelope
		$7f90.x = 0x0f;	//
		$7fc1.x = 0xff;	//
		$7feb.x = 0xff;	//
		$7fa5.x = 0xff;	//
		$7fba.x = 0xff;	//
	}
	$7f45 = 150;			//bpm, 0x96
	u16($7f46) = 0x0000;	//beat counter

	a = $7f43;
	if (a < 0x19) {
		x = a << 1
		u16($d8) = u16($a000.x)	//bank 37
	} else if (a < 0x2b) {
		x = (a - 0x19) << 1;
		u16($d8) = u16($a000.x)	//bank 38
	} else if (a < 0x37) {
		x = (a - 0x2b) << 1;
		u16($d8) = u16($8c77.x)	//bank 39
	} else if (a < 0x3b) {
		x = (a - 0x2b) << 1;
		u16($d8) = u16($b3ae.x)	//bank 39
	} else {
		x = (a - 0x3b) << 1;
		u16($d18) = u16($b400.x) //bank 09
	}

	for (x = 4, y = 9; x > 0; --x) {
		$7f58.x = $d8[y--];	//stream pointer high
		$7f51.x = $d8[y--];	//stream pointer low
	}
	for (x = 4; x > 0; --x) {
		if ($7f51.x != 0xff || $7f58.x != 0xff) {
			$7f4a.x |= 0x80;	// track control
		}
	}

	sound.music.cue_up();	//$8a87();
	return;
/*
    jsr muteChannels                ; 89C3 20 C0 8A
*/
/*
    ldx #$04    ; 89C6 A2 04
.L_89C8:
        lda #$00    ; 89C8 A9 00
        sta $7F4A,x ; 89CA 9D 4A 7F
        sta $7F5F,x ; 89CD 9D 5F 7F
        sta $7F7B,x ; 89D0 9D 7B 7F
        lda #$08    ; 89D3 A9 08
        sta $7F82,x ; 89D5 9D 82 7F
        lda #$30    ; 89D8 A9 30
        sta $7F89,x ; 89DA 9D 89 7F
        lda #$0F    ; 89DD A9 0F
        sta $7F90,x ; 89DF 9D 90 7F
        lda #$FF    ; 89E2 A9 FF
        sta $7FC1,x ; 89E4 9D C1 7F
        sta $7FEB,x ; 89E7 9D EB 7F
        sta $7FA5,x ; 89EA 9D A5 7F
        sta $7FBA,x ; 89ED 9D BA 7F
        dex             ; 89F0 CA
        bpl .L_89C8   ; 89F1 10 D5
*/
/*
    lda #$96    ; 89F3 A9 96
    sta $7F45   ; 89F5 8D 45 7F
    lda #$00    ; 89F8 A9 00
    sta $7F46   ; 89FA 8D 46 7F
    sta $7F47   ; 89FD 8D 47 7F
*/
/*
    lda $7F43   ; 8A00 AD 43 7F
    cmp #$19    ; 8A03 C9 19
    bcc .L_8A0E   ; 8A05 90 07

    cmp #$2B    ; 8A07 C9 2B
    bcs .L_8A1D   ; 8A09 B0 12
        sec             ; 8A0B 38
        sbc #$19    ; 8A0C E9 19
.L_8A0E:
        asl a       ; 8A0E 0A
        tax             ; 8A0F AA
        lda $A000,x ; 8A10 BD 00 A0
        sta <$D8     ; 8A13 85 D8
        lda $A001,x ; 8A15 BD 01 A0
        sta <$D9     ; 8A18 85 D9
        jmp .L_8A57   ; 8A1A 4C 57 8A
; ----------------------------------------------------------------------------
.L_8A1D:
    cmp #$37    ; 8A1D C9 37
    bcs .L_8A33   ; 8A1F B0 12
        sec             ; 8A21 38
        sbc #$2B    ; 8A22 E9 2B
        asl a       ; 8A24 0A
        tax             ; 8A25 AA
        lda $8C77,x ; 8A26 BD 77 8C
        sta <$D8     ; 8A29 85 D8
        lda $8C78,x ; 8A2B BD 78 8C
        sta <$D9     ; 8A2E 85 D9
        jmp .L_8A57   ; 8A30 4C 57 8A
; ----------------------------------------------------------------------------
.L_8A33:
    cmp #$3B    ; 8A33 C9 3B
    bcs .L_8A49   ; 8A35 B0 12
        sec             ; 8A37 38
        sbc #$37    ; 8A38 E9 37
        asl a       ; 8A3A 0A
        tax             ; 8A3B AA
        lda $B3AE,x ; 8A3C BD AE B3
        sta <$D8     ; 8A3F 85 D8
        lda $B3AF,x ; 8A41 BD AF B3
        sta <$D9     ; 8A44 85 D9
        jmp .L_8A57   ; 8A46 4C 57 8A
; ----------------------------------------------------------------------------
.L_8A49:
    sbc #$3B    ; 8A49 E9 3B
    asl a       ; 8A4B 0A
    tax             ; 8A4C AA
    lda $B400,x ; 8A4D BD 00 B4
    sta <$D8     ; 8A50 85 D8
    lda $B401,x ; 8A52 BD 01 B4
    sta <$D9     ; 8A55 85 D9
*/
/*
.L_8A57:
    ldx #$04    ; 8A57 A2 04
    ldy #$09    ; 8A59 A0 09
.L_8A5B:
        lda [$D8],y ; 8A5B B1 D8
        sta $7F58,x ; 8A5D 9D 58 7F
        dey             ; 8A60 88
        lda [$D8],y ; 8A61 B1 D8
        sta $7F51,x ; 8A63 9D 51 7F
        dey             ; 8A66 88
        dex             ; 8A67 CA
        bpl .L_8A5B   ; 8A68 10 F1
    ldx #$04    ; 8A6A A2 04
.L_8A6C:
        lda #$FF    ; 8A6C A9 FF
        cmp $7F51,x ; 8A6E DD 51 7F
        bne .L_8A78   ; 8A71 D0 05
            cmp $7F58,x ; 8A73 DD 58 7F
            beq .L_8A80   ; 8A76 F0 08
    .L_8A78:
                lda $7F4A,x ; 8A78 BD 4A 7F
                ora #$80    ; 8A7B 09 80
                sta $7F4A,x ; 8A7D 9D 4A 7F
    .L_8A80:
        dex             ; 8A80 CA
        bpl .L_8A6C   ; 8A81 10 E9
*/
/*
    jsr .L_8A87   ; 8A83 20 87 8A
    rts             ; 8A86 60
*/
$8a87:
}
```



