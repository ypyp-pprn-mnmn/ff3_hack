# $3f:e1b0 menu.init_palette_buffer
> メニュー用のデフォルトのパレット設定をバッファへロードする。

### args:
+	out NesColors[8] $03c0: palette buffer

### callers:
there found to be only one callers for this function:

+	`1F:E08A:20 B0 E1  JSR $E1B0` @ ?

### local variables:
none.

### static references:
+	NesColors[8] $e1bc: palette entries for menu.
	
		0F 00 01 2A, 0F 00 01 27, 0F 00 01 24, 0F 00 01 30	//BG
		0F 36 30 16, 0F 27 18 21, 0F 36 17 2A, 0F 00 10 30	//Sprites

### notes:
write notes here

### (pseudo)code:
```js
{
/*
	ldx #$1F    ; E1B0 A2 1F
.L_E1B2:
		lda .L_E1BC,x 	; E1B2 BD BC E1
		sta $03C0,x 	; E1B5 9D C0 03
		dex             ; E1B8 CA
		bpl .L_E1B2   	; E1B9 10 F7
	rts             	; E1BB 60
*/
}
```

