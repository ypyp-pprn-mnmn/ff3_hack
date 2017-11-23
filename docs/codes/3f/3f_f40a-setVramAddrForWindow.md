
# $3f:f40a setVramAddrForWindow


## args:
+	[in] u8 $3a : x offset
+	[in] u8 $3b : y
## code:
```js
{
	a = $2002;
	x = $3a;
	y = $3b;
	if (x < #20) { //bcs f423
		$2006 = $f4c1.y;
		$2006 = $f4a1.y | x;
		return;
	}
$f423:
	$2006 = $f4c1.y | #04;
	$2006 = x & #1f | $f4a1.y;
	return;
$f435:
}
```




