
# $3f:f3fa textd.trim_name_left
> 未使用？ キャラ名(6文字分のバッファ)の左側にあるスペース(0xFF)を CHAR.NULL(0)に変換する。

### args:
+	in,out u8 $5a[6]: player character name

### callers:
none?
there is no byte patterns matched with '4c fa f3' or '20 fa f3' and
no branches pointing to the range of code nearby.

### local variables:
none.

### notes:
write notes here

### (pseudo)code:
```js
{
/*
	ldx #$05        ; F3FA A2 05
.L_F3FC:
	lda $5A,x       ; F3FC B5 5A
	cmp #$FF        ; F3FE C9 FF
	bne LF409       ; F400 D0 07
	lda #$00        ; F402 A9 00
	sta $5A,x       ; F404 95 5A
	dex 			; F406 CA
	bpl .L_F3FC       ; F407 10 F3
.L_F409:
	rts 			; F409 60
*/
	return;
$f40a:
}
```

