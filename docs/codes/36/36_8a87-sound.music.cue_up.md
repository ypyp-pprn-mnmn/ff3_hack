
# $36:8a87 sound.music.cue_up
> リクエストされた曲を、要求フラグ($7f42)に応じて、開始状態またはフェードイン状態へ移行させる。

### args:
+	in,out u8 $7f42: request flags. see also `$36:80ab sound.play_music`.

		01: play next music. (at 7f43)
		02: play previous music. (at 7f41,saved when 01)
		04: stop.
		08: soft transition.
		10: ? (the driver clears this flag)
		20: fade in (counts up the volume (at $7f44) until it reaches to 0xF)
		40: fade out (counts down the volume (at $7f44) and stops playback once it reached to 0)
		80: continue playback.

### callers:
+	$36:89c3 sound.music.load_stream

### local variables:
none.

### notes:
write notes here

### (pseudo)code:
```js
{
	if (!($7f42 & 0x08)) {
		$7f42 = 0x80;	//play new
		$7f44 = 0x0f;	//max volume
	} else {
		$7f42 = 0xa0;	//play new | fade-in
		$7f44 = 0x00;	//mute (min. volume)
		$7f48 = 0;		//?
	}
	return;
/*
    lda $7F42   ; 8A87 AD 42 7F
    and #$08    ; 8A8A 29 08
    bne .L_8A99   ; 8A8C D0 0B
        lda #$80    ; 8A8E A9 80
        sta $7F42   ; 8A90 8D 42 7F
        lda #$0F    ; 8A93 A9 0F
        sta $7F44   ; 8A95 8D 44 7F
        rts             ; 8A98 60
; ----------------------------------------------------------------------------
.L_8A99:
    lda #$A0    ; 8A99 A9 A0
    sta $7F42   ; 8A9B 8D 42 7F
    lda #$00    ; 8A9E A9 00
    sta $7F44   ; 8AA0 8D 44 7F
    sta $7F48   ; 8AA3 8D 48 7F
    rts             ; 8AA6 60
*/
}
```


