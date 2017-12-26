
# $36:8c29 sound.effect.mute_channels
> 効果音に使用するチャネル(矩形#2とノイズ)をミュートし、再生状態もそのように更新する。

### args:
+	in,out u8 $7f4b: track control flags, #2 (music #2)
+	in,out u8 $7f4d: track control flags, #4 (music #4)
+	in,out u8 $7f4f: track control flags, #6 (SE #1)
+	in,out u8 $7f50: track control flags, #7 (SE #2)

### callers:
+	$36:8bb8 sound.effect.load_stream

### local variables:
none.

### notes:
write notes here

### (pseudo)code:
```js
{
	if ((a = $7f4f) < 0) {
		$7f4f = a & 0x7f;
		$4004 = 0x30;
		$7f4b |= 0x02;
	}
	if ((a = $7f50) < 0) {
		$7f50 = a & 0x7f;
		$400c = 0x30;
		$7f4d |= 0x02;
	}
	return;
$8c58:
/*
    lda $7F4F   ; 8C29 AD 4F 7F
    bpl .L_8C40   ; 8C2C 10 12
        and #$7F    ; 8C2E 29 7F
        sta $7F4F   ; 8C30 8D 4F 7F
        lda #$30    ; 8C33 A9 30
        sta $4004   ; 8C35 8D 04 40
        lda $7F4B   ; 8C38 AD 4B 7F
        ora #$02    ; 8C3B 09 02
        sta $7F4B   ; 8C3D 8D 4B 7F
.L_8C40:
    lda $7F50   ; 8C40 AD 50 7F
    bpl .L_8C57   ; 8C43 10 12
        and #$7F    ; 8C45 29 7F
        sta $7F50   ; 8C47 8D 50 7F
        lda #$30    ; 8C4A A9 30
        sta $400C   ; 8C4C 8D 0C 40
        lda $7F4D   ; 8C4F AD 4D 7F
        ora #$02    ; 8C52 09 02
        sta $7F4D   ; 8C54 8D 4D 7F
.L_8C57:
    rts             ; 8C57 60
*/
}
```

