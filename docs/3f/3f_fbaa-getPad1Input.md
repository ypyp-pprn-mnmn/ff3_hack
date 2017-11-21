
# $3f:fbaa getPad1Input()


## args:
+	[in] u8 $13 : inputMask?
+	[out] u8 $12 : inputFlag(bit7 > < v ^ st sel b a bit0)
+	[out] u8 $14 : ?
## code:
```js
{
	$12 = $13;
	$4016 = 1;	//reset pad state
	$4016 = 0;
	for ( x = 8;x != 0;x--) {
$fbba:
		a = $4016 >> 1;
		if (!carry) {
			ror a;
		}
		ror $13;//押されていれば最上位に1
	}
	a = $12 | $13;
	if (a == 0) {
		$12 = a;
		$14 = 8;
		return;
	}
$fbd3:
	a = $12 & $13;
	if (a == 0 || --$14 != 0) {
$fbd9:
		$12 = a = $12 ~ #ff & $13;
		return;
	}
$fbe2:
	//if (--$14 != 0) goto $fbd9;	
	$14 = 4;
	$12 = $13;
	return;
}
```



