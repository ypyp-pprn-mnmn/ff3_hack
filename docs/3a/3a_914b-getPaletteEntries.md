
# $3a:914b getPaletteEntries


## args:
+	[in] x : dest offset
+	[in] y : paletteId
+	$00:b100[3][0x100] : colorIds
## (pseudo)code:
```js
{
	$03c0.x = $b100.y;
	$03c1.x = $b200.y;
	$03c2.x = $b300.y;
	return;
}
```



