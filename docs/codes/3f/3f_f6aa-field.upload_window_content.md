

# $3f:f6aa field.upload_window_content
> uploads tile (i.e., name table) buffer into vram.

### args:
+	in u8 A : text drawing disposition.
	- 0x09: draw only lower line (skip upper line)
+	[in] u8 $38 : offset x
+	[in] u8 $39 : offset per 2 line
+	[in,out] u8 $3b : offset y (wrap-around)

### notes:
the disposition code 0x09 will be returned from `textd.draw_in_box` when char code 0x0a has encountered during processing.

### code:
```js
{
	if (a != 9) { //beq f6e5
		$3a = $38;
		setVramAddrForWindow();	//$f40a();
		for (x = 0;x < $91;x++) {
$f6b7:
			$2007 = $0780.x;
		}
$f6c2:
		if (x < $3c) { //bcs f6de
			$3a = $3a & #20 ^ #20;
			setVramAddrForWindow();	//$f40a();
			for (x = $91;x < $3c;x++) {
				$2007 = $0780.x;
			}
		}
$f6de:
		$3b += 1;
	}
$f6e5:
	$3a = $38;
	setVramAddrForWindow();	//$f40a();
	for (x = 0;x < $91;x++) {
		$2007 = $07a0.x;
	}
$f6f9:
	if (x < $3c) { //bcs f715
		$3a = $3a & #20 ^ #20;
		setVramAddrForWindow();	//$f40a();
		for (x = $91;x < $3c;x++) {
$f70a:
			$2007 = $07a0.x;
		}
	}
$f715:
	$90 = 0;
	if ( (a = $3b + 1) >= #1e) {
		a -= #1e;
	}
	$3b = a;
	return;
}
```





