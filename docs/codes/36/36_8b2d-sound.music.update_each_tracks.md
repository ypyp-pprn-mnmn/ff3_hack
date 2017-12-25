

# $36:8b2d sound.music.update_each_tracks
> それぞれのトラックについて、BPMに従って音楽の再生データを更新する。

### args:
+	in u8 $7f45: BPM. beat counter delta.
        
        bpm = (delta / 150) / 96 * (60 sec * 60 NMIs/s)
        = (delta * 3600) / (150 * 96)
        = (delta) / 4 (if a counter value of 96 denotes a quater note)
        = (delta) (if a counter value of 96 denotes a whole note)
    -   maximum number of internal counter for a note is 96 (0x60).
+	in,out u16 $7f46: beat counter, decremented by 150 on each call.
+	out u8 $d0: track #, [0...7). music 5 channels + SE 2 channels. set to 3 on exit.

### callers:
+	$36:8925 sound.music.update_stream

### local variables:
+	u8 $d1: channel index.
    -   0: DMC
    -   1: noise
    -   2: triangle
    -   3: pulse2
    -   4: pulse1
+	u8 $d2: 0?

### notes:
lengths of notes have been encoded in lower 4-bits of music stream,
which indexes predefined length lookup table (at $8805).
The table is defined as follows:
    `60 48 30 24 20 18 12 10 0C 09 08 06 04 03 02 01`

exact playback timing is depending on how frequently this logic is called,
and may vary in tempo if callers don't make callouts periodically.

### (pseudo)code:
```js
{
/*
    lda #$00    ; 8B2D A9 00
    sta <$D2     ; 8B2F 85 D2
    lda $7F45   ; 8B31 AD 45 7F
    clc             ; 8B34 18
    adc $7F46   ; 8B35 6D 46 7F
    sta $7F46   ; 8B38 8D 46 7F
    bcc .L_8B40   ; 8B3B 90 03
    inc $7F47   ; 8B3D EE 47 7F
*/
/*
.L_8B40:
    lda $7F46   ; 8B40 AD 46 7F
    sec             ; 8B43 38
    sbc #$96    ; 8B44 E9 96
    tay             ; 8B46 A8
    lda $7F47   ; 8B47 AD 47 7F
    sbc #$00    ; 8B4A E9 00
    bcc .L_8B86   ; 8B4C 90 38
*/
	$d2 = 0;
	u16($7f46) += $7f45;
	while (u16($7f46) >= 0x96) {
		u16($7f46) -= 0x96;
		$d1 = 0;
		sound.music.update_track({track_no:$d0 = 4});	//$81e6
		
		$d1 = 1;
		sound.music.update_track({track_no: --$d0});	//$81e6
		
		$d1 = 2;
		sound.music.update_track({track_no: --$d0});	//$81e6

		$d1 = 3;
		sound.music.update_track({track_no: --$d0});	//$81e6

		$d1 = 4;
		sound.music.update_track({track_no: --$d0});	//$81e6
	}
$8bb6:
	sound.music.update_volume({track_no:$d0 = 0});	//$857d
	sound.music.update_volume({track_no: ++$d0});	//$857d
	sound.music.update_volume({track_no: ++$d0});	//$857d
	sound.music.update_volume({track_no: ++$d0});	//$857d
	return;
/*
    sta $7F47   ; 8B4E 8D 47 7F
    sty $7F46   ; 8B51 8C 46 7F
    lda #$04    ; 8B54 A9 04
    sta <$D0     ; 8B56 85 D0
    lda #$00    ; 8B58 A9 00
    sta <$D1     ; 8B5A 85 D1
    jsr .L_81E6   ; 8B5C 20 E6 81
    dec <$D0     ; 8B5F C6 D0
    lda #$01    ; 8B61 A9 01
    sta <$D1     ; 8B63 85 D1
    jsr .L_81E6   ; 8B65 20 E6 81
    dec <$D0     ; 8B68 C6 D0
    lda #$02    ; 8B6A A9 02
    sta <$D1     ; 8B6C 85 D1
    jsr .L_81E6   ; 8B6E 20 E6 81
    dec <$D0     ; 8B71 C6 D0
    lda #$03    ; 8B73 A9 03
    sta <$D1     ; 8B75 85 D1
    jsr .L_81E6   ; 8B77 20 E6 81
    dec <$D0     ; 8B7A C6 D0
    lda #$04    ; 8B7C A9 04
    sta <$D1     ; 8B7E 85 D1
    jsr .L_81E6   ; 8B80 20 E6 81
    jmp .L_8B40   ; 8B83 4C 40 8B
; ----------------------------------------------------------------------------
.L_8B86:
    lda #$00    ; 8B86 A9 00
    sta <$D0     ; 8B88 85 D0
    jsr .L_857D   ; 8B8A 20 7D 85
    inc <$D0     ; 8B8D E6 D0
    jsr .L_857D   ; 8B8F 20 7D 85
    inc <$D0     ; 8B92 E6 D0
    jsr .L_857D   ; 8B94 20 7D 85
    inc <$D0     ; 8B97 E6 D0
    jsr .L_857D   ; 8B99 20 7D 85
    rts             ; 8B9C 60
*/
}
```



