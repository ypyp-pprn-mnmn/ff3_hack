
# $3e:deea loadTilePatternToVram


## args:
+	[in] x : tileCount
+	[in] ptr $80 : pPattern
## code:
```js
{
	for (x;x != 0;x--) {
$deee:
		for ($82 = #10;$82 != 0;$82--) {
			$2007 = $80[y];
			if (++y == 0) { //bne def8
				$81++;
			}
$def8:
		}
$defc:
	}
	return;
$df00:
}
```




