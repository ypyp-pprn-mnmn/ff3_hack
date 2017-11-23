
# $3a:910b getPaletteEntriesForFloor


## args:
+	[in] WarpParam $0780
## (pseudo)code:
```js
{
	getPaletteEntries(offset:x = 1, paletteId:y = $0785);
	getPaletteEntries(offset:x = 5, paletteId:y = $0786);
	getPaletteEntries(offset:x = 9, paletteId:y = $0787);
	getPaletteEntries(offset:x = #19, paletteId:y = $0788);
	getPaletteEntries(offset:x = #1d, paletteId:y = $0789);
	$03cd = 0;
	$03ce = 2;
	$03cf = #30;
	$03d0 = $03c0 = #0f;
	return;
$914b:
}
```



