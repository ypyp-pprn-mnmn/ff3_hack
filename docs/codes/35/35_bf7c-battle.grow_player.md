
# $35:bf7c battle.grow_player


## args:
+ [in] u8 A: lvupInfo
+ [in] u16 $57 : playerParamBasePtr
+ [in] u8 $5f : playerOffsetBase
## (pseudo-)code:
```js
{
	$19 = a;
	$18 = a & 7;
	setYtoOffsetOf(a = #12);	//$9b88
	for (x = 5;x >0;x--) {
$bf89:
		$19 <<= 1;
		if (carry) {
			clc;
			a = $57[y] + $18;
			if (a >= 100) a = 99;
			$57[y] = a;
			a = y;
			var temp = a;//pha
			y = a + 5
			a = $57[y] + $18;
			if (a >= 100) a = 99;
			$57[y] = a;
			y = temp; //pla
		}
		y++;
	}
$bfb3:
}
```



