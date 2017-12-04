

# $3e:d381 field.upload_palette

### args:
+	in nes_palette_entry $03f0[16]: palette entry.

### code:
```js
{
	$2002;
	$2006 = 0x3f;
	$2006 = 0x00;	
	for (x = 0;x < 0x10;x++) {
$d390:
		$2007 = $03f0.x;
	}
	$2002;
	$2006 = 0x3f; $2006 = 0x00;
	$2006 = 0x00; $2006 = 0x00;
	return;
$d3af:
}
```





