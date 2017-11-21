
# $3e:de1a loadPatternToVram


## args:
+	[in] u8 x : len (per256bytes)
+	[in] ptr $80 : pPattern
## code:
```js
{
	y = 0;
	for (x;x != 0;x--) {
		do {
$de1c:
			$2007 = $80[y];
		} while (++y != 0);
		$81++;
	}
	return;
$de2a:
}
```



