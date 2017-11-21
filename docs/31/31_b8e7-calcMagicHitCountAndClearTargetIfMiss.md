
# $31:b8e7 calcMagicHitCountAndClearTargetIfMiss

<summary></summary>

## (pseudo-)code:
```js
{
	if ((getActor2C() < 0)  //$a2b5(); bmi b8f4
		|| ($70[y] < 0) //bmi b8f4;y = #2c
		|| ($7c == 0) //bne b91f
	{
$b8f4:
		$24 = $70[y = #13];	//mdef.count
		$25 = $70[++y];		//mdef.evade
		a = $70[y = 1] & 4;	//blind
		if (a != 0) { //beq b909
			$25 >>= 1;
		}
$b909:
		a = $70[y] & #28; //toad|minimum
		if (a != 0) { //beq b913
			$24 = 0;
		}
$b913:
		getNumberOfRandomSuccess(try:$24, rate:$25);	//$bb28();
		if (a = ($7c - $30) < 0) { //bcs b91f
$b91d:
			a = 0;
		}
	}
$b91f:
	$7c = a;
	//fall through
$b921:
}
```


**fall through**

