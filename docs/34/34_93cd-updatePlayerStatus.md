
# $34:93cd updatePlayerStatus

<summary></summary>

## (pseudo-)code:
```js
{
	for ($52 = 0;$52 != 4;$52++) {
$93d1:
		y = updatePlayerOffset();	//$a541
		$1a = ++y;
		push ( y = a = $52 << 1);
		a = $18[y]
		y = $1a
		$5b[y] |= a;
		if ((a & #80) != 0) { //$93f3
$93e9:
			$5b[y] &= #fe;
			pop a;
			goto $93ff;
		} else {
$93f3:
			y = pop a;
			a = $18[++y];
			y = $1a; y++;
			$5b[y] |= a;
		}
$93ff:
	}
$9407:
	return;
$9408:
}
```



