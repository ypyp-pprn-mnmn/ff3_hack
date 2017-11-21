
# $3f:edf6 field::getWindowTilesForTop


## args:
+	[in] u8 $3c : width (border incl)
## callers:
+	$3f:ecef
+	$3f:ed17
## code:
```js
{
	x = 1;
	$0780 = #f7;
	$07a0 = #fa;
	for (x;x < $3c;x++) {
		$0780.x = #f8;
		$07a0.x = #ff;
	}
	x--;
	$0780.x = #f9;
	$07a0.x = #fb;
	return;
$ee1d:
}
```




