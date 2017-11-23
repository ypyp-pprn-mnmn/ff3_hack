
# $31:b3f1 handleToadMinimum



>specialHandler07: トード・ミニマム


### (pseudo-)code:
```js
{
	if ( (getActor2C() < 0)  //a2b5 bmi b3fa
		|| $70[y] < 0)) //bpl b3ff
	{
$b3fa:
		//少なくとも一方が敵側
		calcMagicHitCountAndClearTargetIfMiss();	//$b8e7();
		if (equal) b473;
	}
$b3ff:
	if ( (getTarget2c() < 0)  //bpl b40f
		&& ($7ed8 < 0)) //bpl b40f
	{
		//対象が敵でかつボス戦
		clearEffectTarget();	//$b926();
		goto $b473;
	}
$b40f:
	$18 = $70[y = #1];
	$19 = $70[y] = a ^ $7403;	//param03
	x = $64;
	a = $19 & #28;	//toad|minimum
	if (a != 0) { //beq b427
		a = $70[y] | $7403;
	}
$b427:
	$e0.x = a;
	if (($19 & #20) != 0) { //beq b43c
$b42f:
		if (($18 & #20) == 0) { //bne b473
			$78d9 = #0f;
		} //bne b473
	} else {
$b43c:
		if (($19 & #08) != 0) //beq b44f
			&& ($18 & #08) == 0) { //bne b473
			$78d9 = #11;
			//bne b473
		}
	}
$b44f:
	//...
$b473:
}
```



