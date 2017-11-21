
# $31:b51f handleSuicidalExplosion

<summary>自爆</summary>

## (pseudo-)code:
```js
{
	$18,19 = $6e[3,4];
	if (0 != ($6e[3,4] - $6e[5,6])) {
		//現HP-MaxHP != 0
		$78,$79 = $18,19 << 2;
		setCalcTargetPtrToOpponent();	$31:bdbc();
		damageHp();	//$31:bcd2();
		$6e[3,4] = 0; //HP = 0;
		$6e[y = 1] = #80;	//status0 = dead
	} else {
$b55a:
		$78d7,78d9 = x = #ff;
		$7e99 = 0;
		$78da = #44;
	}
}
```



