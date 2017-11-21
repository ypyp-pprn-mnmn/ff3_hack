
# $35:ad16 command_intimidate

<summary>11: おどかす</summary>

## (pseudo-)code:
```js
{
	$78d5 = 1;
	$78d7 = #4a;
	if (($7ed8 & 1) != 0) { //beq ad2d
		$78da = #3b;
		return;
	}
$ad2d:
	$25 = 7;
	y = 0;
	$24 = a >> 1; //=3
	y = 0;
	a = $5d[y] - $24;
	if (a < 0) { //bcs ad41
		a = 0;
	}
$ad41:
	$24 = a;
	for ($25;$25 >= 0;$25--) {
$ad43:
		$5d[y] = $24;
		$5d += #0040;
	}	//bpl ad43
$ad5a:
	$5d,5e = #7675;
	$78da = #32;
	setNoTargetMessage();	//$91ce()
	return;
$ad6b:
}
```



