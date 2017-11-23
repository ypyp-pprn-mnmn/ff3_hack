
# $3f:e982 OnTreasure


## args:
+	[in] u8 $ba : 00: chipId=d0-df ff:chipId=e0-ef
## code:
```js
{
	$7f49 = #bf;
	if ($ba >= 0) { //bmi e98e
		$e6f0();
	}
	push16 ($80);
	getTreasure(); //f549
	x = a;
	$80 = pop16;
	a = x;
	if (a == #50) { //bne e9ad
		$0d = $44 = 0;
		a = #50;
$e9ab:
		sec;
		return;
	}
$e9ad:
	if ($ba < 0) return $e9ab; //bmi e9ab
	x = a;
	$80[y = 0] = #7d;
	a = x;
	sec;
	return;
$e9bb:
}
```




