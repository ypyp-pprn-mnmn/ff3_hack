
# $3f:f435 field.get_vram_addr_of_line_above
> (未使用?) 現ウインドウ行($3bで指定)の1行上の左端のVRAMアドレスを($54に)取得する

### args:
+	in u8 $3a: offset x
+	in u8 $3b: offset y
+	out u8 $54: vram low
+	out u8 $55: vram high

### callers:
none.
there is no byte patterns matched with '4c 35 f4' or '20 35 f4' and
no branches pointing to the range of code nearby.

### local variables:
none.

### static references:
+	u8 $f4a1[32]: vram address low (index := Y coords)
+	u8 $f4c1[32]: vram address high (index := Y coords)

### notes:
this logic doesn't handle bg boundaries.

### (pseudo)code:
```js
{
/*
	ldx $3B         ; F435 A6 3B
	dex             ; F437 CA
	bpl LF43C       ; F438 10 02
	ldx $3B         ; F43A A6 3B
LF43C:
	lda $3A         ; F43C A5 3A
	and #$1F        ; F43E 29 1F
	ora $F4A1,x     ; F440 1D A1 F4
	sta $54         ; F443 85 54
	lda $F4C1,x     ; F445 BD C1 F4
	sta $55         ; F448 85 55
	rts             ; F44A 60
*/
}
```

