
# $36:8bb8 sound.effect.load_stream
> 効果音の音データを再生用のデータとしてロードする。

### args:
+	in u8 $7f49: sound effect id and load flags.
	- bit 7: play new. 0 on exit.
	- bit 6: play continue. 1 on exit.
	- bit 5-0: sound effect id. 0 on exit.
+	out u8 $7f4f,7f50: track control flags, track #5 / #6. 0 on exit.
+	out u8 $7f56,7f57: stream pointer low, track #5 / #6
+	out u8 $7f5e,7f5e: stream pointer high, track #5 / #6
+	out u8 $7f64,7f65: note lengeth, track #5 / #6. 0 on exit.
+	out u8 $7f80,7f81: volume, track #5 / #6. 0 on exit.
+	out u8 $7f87,7f88: sweep, track #5 / #6. 0x8 on exit.
+	out u8 $7f8e,7f8f: duty/envelope, track #5 / #6. 0x30 on exit.
+	out u8 $7f95,7f96: ?, 0xF on exit.
+	out u8 $7faa,7fab: ?
+	out u8 $7fbf,7fc0: ?
+	out u8 $7fc6,7fc7: ?
+	out u8 $7ff0,7ff1: ?

### callers:
+	$36:8b9d sound.effect.update_or_load_stream

### local variables:
+	ptr $d8: pointer to stream, which is defined as an array of track pointers.

### static references:
+	SoundEffectTrack* $92c5[# of available SEs]: pointers to streams.

		MusicTrack : {
			AudioStream* pulse1, pulse2, triangle, noise, dmc;
		};
		SoundEffectTrack: {
			AudioStream* pulse2, noise;
		};

### notes:
a stream for sound effect defined as 2 consecutive entries of pointer to an individual track.
$92c5[sound_effect_id] :
=> points to where 2 pointers are, each pointers point to...
-> track #5 (pulse #2) 
-> track #6 (noise)

### (pseudo)code:
```js
{
/*
    jsr .L_8C29   ; 8BB8 20 29 8C
    ldx #$01    ; 8BBB A2 01
.L_8BBD:
        lda #$00    ; 8BBD A9 00
        sta $7F4F,x ; 8BBF 9D 4F 7F
        sta $7F64,x ; 8BC2 9D 64 7F
        sta $7F80,x ; 8BC5 9D 80 7F
        lda #$08    ; 8BC8 A9 08
        sta $7F87,x ; 8BCA 9D 87 7F
        lda #$30    ; 8BCD A9 30
        sta $7F8E,x ; 8BCF 9D 8E 7F
        lda #$0F    ; 8BD2 A9 0F
        sta $7F95,x ; 8BD4 9D 95 7F
        lda #$FF    ; 8BD7 A9 FF
        sta $7FC6,x ; 8BD9 9D C6 7F
        sta $7FF0,x ; 8BDC 9D F0 7F
        sta $7FAA,x ; 8BDF 9D AA 7F
        sta $7FBF,x ; 8BE2 9D BF 7F
        dex             ; 8BE5 CA
        bpl .L_8BBD   ; 8BE6 10 D5
*/
	sound.effect.mute_channels();	//$8c29();
	for (x = 1; x > 0; --x) {
		$7f80.x = 0;	// volume
		$7f64.x = 0;	// note length
		$7f4f.x = 0;	// track control
		$7f87.x = 0x08;	// sweep
		$7f8e.x = 0x30;	// duty | envelope
		$7f95.x = 0x0f;	//?
		$7fc6.x = 0xff;
		$7ff0.x = 0xff;
		$7faa.x = 0xff;
		$7fbf.x = 0xff;
	}
/*
    lda $7F49   ; 8BE8 AD 49 7F
    asl a       ; 8BEB 0A
    tax             ; 8BEC AA
    lda $92C5,x ; 8BED BD C5 92
    sta <$D8     ; 8BF0 85 D8
    lda $92C6,x ; 8BF2 BD C6 92
    sta <$D9     ; 8BF5 85 D9
*/
	x = $7f49 << 1;
	u16($d8) = u16($92c5.x);	//pointer to stream pointers, which are array of pointers to each track
/*
    ldx #$01    ; 8BF7 A2 01
    ldy #$03    ; 8BF9 A0 03
.L_8BFB:
        lda [$D8],y ; 8BFB B1 D8
        sta $7F5D,x ; 8BFD 9D 5D 7F
        dey             ; 8C00 88
        lda [$D8],y ; 8C01 B1 D8
        sta $7F56,x ; 8C03 9D 56 7F
        dey             ; 8C06 88
        dex             ; 8C07 CA
        bpl .L_8BFB   ; 8C08 10 F1
*/
	for (y = 3, x = 1; x > 0; --x)  {
		$7f5d.x = $d8[y--];	//p_stream.high
		$7f56.x = $d8[y--];	//p_stream.low
	}
/*
    ldx #$01    ; 8C0A A2 01
.L_8C0C:
		lda #$FF    ; 8C0C A9 FF
		cmp $7F56,x ; 8C0E DD 56 7F
		bne .L_8C18   ; 8C11 D0 05
			cmp $7F5D,x ; 8C13 DD 5D 7F
			beq .L_8C20   ; 8C16 F0 08
.L_8C18:
				lda $7F4F,x ; 8C18 BD 4F 7F
				ora #$80    ; 8C1B 09 80
				sta $7F4F,x ; 8C1D 9D 4F 7F
.L_8C20:
		dex             ; 8C20 CA
		bpl .L_8C0C   ; 8C21 10 E9
    lda #$40    ; 8C23 A9 40
    sta $7F49   ; 8C25 8D 49 7F
    rts             ; 8C28 60
*/
	for (x = 1; x > 0; --x) {
		if ($7f56.x != 0xff || $7f5d.x != 0xff) {
			// pointer valid.
			$7f4f.x |= 0x80;
		}
	}
	$7f49 = 0x40;
	return;
}
```

