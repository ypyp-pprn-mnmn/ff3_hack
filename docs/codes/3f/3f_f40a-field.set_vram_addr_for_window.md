

# $3f:f40a field.set_vram_addr_for_window
> ウインドウ行の左端の座標($3a,$3bで指定)になるようppuのvram addrを変更する

### args:
+	[in] u8 $3a : x offset
+	[in] u8 $3b : y offset

### static references:
+	u8 $f4a1[32]: vram address low (index := Y coords)
+	u8 $f4c1[32]: vram address high (index := Y coords)

### callers:
`1F:F6B2:20 0A F4  JSR $F40A` @ $3f:f6aa field.upload_window_content
`1F:F6CE:20 0A F4  JSR $F40A` @ $3f:f6aa field.upload_window_content
`1F:F6E9:20 0A F4  JSR $F40A` @ $3f:f6aa field.upload_window_content
`1F:F705:20 0A F4  JSR $F40A` @ $3f:f6aa field.upload_window_content

### notes:
this logic wraps X around the BG boundary (0x20) and handles it correctly as in 2nd BG.
however, it doesn't wraps Y. (boundary = 0x1e)

### code:
```js
{
	a = $2002;
	x = $3a;
	y = $3b;
	if (x < 0x20) { //bcs f423
		$2006 = $f4c1.y;
		$2006 = $f4a1.y | x;
		return;
	}
$f423:
	$2006 = $f4c1.y | 0x04;
	$2006 = x & 0x1f | $f4a1.y;
	return;
$f435:
}
```


