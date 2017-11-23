
# $33:a0c0 effect_playerBlow 

>[effectFunction_04]

### args:
+	[in] u8 $bb : swingCountRight?
+	[in] u8 $bc : swingCountLeft?
+	[in] u8 $7e1f : righthandWeaponKind
+	[in] u8 $7e20 : lefthandWeaponKind

### code:
```js
{
	$a6c3();
	if (carry) { //bcc a0cb
		$bb = $bc = 0;
	}
$a0cb:
	$cd = 0;
	if ($7e1f == #3) { //bne a0e1
$a0d6:		if ($7e20 == #8) { //bne a0f8
$a0dd:			a = 0; goto $a0ee; //beq
		}
	} else 
$a0e1:	if ( (a == #8)		//bne a0f8
$a0e5:	  && ($7e20 == #3) )	//bne a0f8
	{
		//弓矢
$a0ec:
		a = 1;
$a0ee:
		$cd = a;
		$a24c();
		a = 3;
		return blowEffect_limitHitCountAndDispatch();	// $a094();
	}
$a0f8:
	if ($7e1f == 4) { //bne a105
$a0ff:
		//竪琴
		$a24c();
		goto a10c;
	} else {
$a105:
		if ($7e20 == 4) $a0ff;
	}
	a = $7e1f;
	blowEffect_limitHitCountAndDispatch();	//$a094();
	$cd = 1;
	a = $7e20;
	return blowEffect_limitHitCountAndDispatch();	//$a094();
}
```


