
# $36:8aa7 sound.music.end
> 現在再生中の曲を、要求フラグ($7f42)にもとづいて、停止状態またはフェードアウト状態へ移行させる。

### args:
+	in u8 $7f42: request flag. see also `$36:80ab sound.play_music`.
	- 0x08: soft transition.

### code:
```js
{
	if (a = ($7f42 & 0x8)) {
		$7f42 = a;	//0
		sound.music.mute_channels();	//$8ac0();
	} else {
		$7f42 = 0xc0;	// play continue | fading out
		$7f48 = 0;
	}
	return;
/*
    lda $7F42   ; 8AA7 AD 42 7F
    and #$08    ; 8AAA 29 08
    bne .L_8AB5   ; 8AAC D0 07
    sta $7F42   ; 8AAE 8D 42 7F
    jsr sound.music.mute_channels   ; 8AB1 20 C0 8A
    rts             ; 8AB4 60
; ----------------------------------------------------------------------------
.L_8AB5:
    lda #$C0    ; 8AB5 A9 C0
    sta $7F42   ; 8AB7 8D 42 7F
    lda #$00    ; 8ABA A9 00
    sta $7F48   ; 8ABC 8D 48 7F
    rts             ; 8ABF 60
*/
}
```




