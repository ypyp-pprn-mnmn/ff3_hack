

# $36:8c58 sound.effect.update_each_track
> 効果音(SE)の各トラックの再生データを更新する。

### args:

### local variables:
+	u8 $d0: track #. for SEs, 5 and 6.
+	u8 $d1: channel id. where:
	- 03: pulse#2
	- 01: noise
+	u8 $d2: ?, something related to volume. ($8595, $86d5. see `$36:857d sound.update_volume`.)

### callers:
+	$36:8b9d sound.effect.update_or_load_stream

### notes:
unlike the siblings for music playback (`$36:8b2d sound.music.update_each_track`),
this function doesn't count any tempo.
in other words, sound effects are always played in the fixed tempo, which is equivalent of bpm 150.

### code:
```js
{
/*
    lda #$FF    ; 8C58 A9 FF
    sta <$D2     ; 8C5A 85 D2
    lda #$05    ; 8C5C A9 05
    sta <$D0     ; 8C5E 85 D0
    lda #$03    ; 8C60 A9 03
    sta <$D1     ; 8C62 85 D1
    jsr sound.music.update_track    ; 8C64 20 E6 81
    jsr sound.music.update_volume   ; 8C67 20 7D 85
    inc <$D0     ; 8C6A E6 D0
    lda #$01    ; 8C6C A9 01
    sta <$D1     ; 8C6E 85 D1
    jsr sound.music.update_track    ; 8C70 20 E6 81
    jsr sound.music.update_volume   ; 8C73 20 7D 85
    rts             ; 8C76 60
*/
	sound.update_track({track_no:$d0 = 0x05, channel_id:$d1 = 0x03});
	sound.volume({track_no:$d0, unknown:$d2 = 0xff});

	sound.update_track({track_no: ++$d0, channel_id:$d1 = 0x01});
	sound.volume({track_no:$d0, unknown:$d2 });

	return;
}
```

