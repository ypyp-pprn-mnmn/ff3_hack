
# $3a:9091 getPaletteEntriesForWorld


### args:
+	[in] u8 $78 : world
+	u8 $00:b640[0x10] : paletteEntries for background

### notes:
フロアマップでも呼ばれる

### (pseudo)code:
```js
{
	y = ($78 & #06) << 3;
	for (x = 0;x < #10;x++) {
		$03c0.x = $b640.y;
	}
	y = ($78 & #04) << 2;
	for (x = 0;x < #10;x++) {
		$03d0.x = $b670.y;
	}
	//....
}
```



