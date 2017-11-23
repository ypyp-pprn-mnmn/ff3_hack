
# $3f:ee1d field::getWindowTilesForMiddle


### callers:
+	field::drawWindow

### code:
```js
{
	x = 1;
	$07a0 = $0780 = #fa;
	a = #ff
	for (x;x < $3c;x++) {
		$07a0.x = $0780.x = a;
	}
	x--;
	$07a0.x = $0780.x = #fb;
	return;
$ee3e:
}
```




