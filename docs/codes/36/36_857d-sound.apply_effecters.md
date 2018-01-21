
# $36:857d sound.apply_effecters
> 指定のトラックについてエフェクタの状態を更新して、再生用の状態データに反映する。

### args:
+	in u8 $d0: track #, [0...7). music 5 channels + SE 2 channels.
+	in u8 $7f4a[7]: track control flags. where:
	- 0x01: feed next wave data. set when a play note has just been fetched.
	- 0x02: in rest note. set when a rest note has just been fetched.
	- 0x80: track enable.
+	in u8 $7f7b[7?]: ?, set to 0 if the track is disabled,
	will be fed into duty/volume register on each channel. ($4000,4004,4008,400c,4010)

### callers:
+	$36:8b2d sound.music.update_each_track
+	$36:8c58 sound.effect.update_each_track

### local variables:
none.

### notes:
write notes here

### (pseudo)code:
```js
{
/*
; ----------------------------------------------------------------------------
    ldx <$D0     ; 857D A6 D0
    lda $7F4A,x ; 857F BD 4A 7F
    bpl .L_8594   ; 8582 10 10
		and #$02    ; 8584 29 02
		bne .L_858F   ; 8586 D0 07
			jsr .L_8595   ; 8588 20 95 85
			jsr .L_86D5   ; 858B 20 D5 86
			rts             ; 858E 60
; ----------------------------------------------------------------------------
.L_858F:
    lda #$00    ; 858F A9 00
    sta $7F7B,x ; 8591 9D 7B 7F
.L_8594:
    rts             ; 8594 60
*/
	x = $d0;
	a = $7f4a.x;
	if (a < 0) {
		if (!(a & 0x02)) {
			sound.apply_volume_effects();	//8595
			sound.apply_pitch_modulation();	//86d5
		} else {
$858f:
			$7f7b.x = 0;
		}
	}
$8594:
	return;
$8595:
}
```


