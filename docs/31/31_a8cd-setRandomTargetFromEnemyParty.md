
# $31:a8cd setRandomTargetFromEnemyParty

<summary></summary>

## args:
+ [in] BattleChar *$24
## (pseudo-)code:
```js
{
	$24[y = #30] = #80;
	do {
$a8d3:
		x = getBattleRandom(a = #07);	//beb4
	} while ( $78d7.x == #ff);
$a8e0:
	a = x;
	//fall through
}
```



