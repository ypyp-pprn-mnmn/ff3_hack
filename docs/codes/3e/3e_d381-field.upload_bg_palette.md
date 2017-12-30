
# $3e:d381 field.upload_bg_palette
> バッファ($03f0)からBG用のパレットの色データをVRAMへアップロードする。

### args:
+	in NesColors $03f0[4]: palette entry.

### callers:
+	`1F:D3D3:20 81 D3  JSR field.upload_bg_palette`
+	`1F:D3F6:20 81 D3  JSR field.upload_bg_palette`
+	`1F:D482:20 81 D3  JSR field.upload_bg_palette`

### notes:
this function is very similar to `$3e:d308 field.upload_all_palette_entries`.

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

