

# $3f:f897 ppud.upload_palette

### args:
-	in u8 $7cf7[0x20]: NES color indexes

### code:
```js
{
	setVramAddr({high: a = 0x3f, low: x = 0});	//f8e0
	for (x;x != 0x20;x++) {
		$2007 = $7cf7.x;
	}
	return;
$f8aa:
}
```




