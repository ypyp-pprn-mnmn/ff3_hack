
# $35:a7ea command_back

<summary>03: こうたい</summary>

## (pseudo-)code:
```js
{
	$78d7 = #3c;
	setNoTargetMessage();	//$91ce
$a7f2:
	$78d5 = 1;
	a = $6e[y = #33];
	getInvertedLineFlag();	//$a816
	$6e[y] = a;
	$52 = getActor2c() & 7;
	y = updatePlayerOffset() + #f;//$a541
	a = $59[y];
	getInvertedLineFlag();	//$a816
	$59[y] = a;
	return;
$a816:
}
```



