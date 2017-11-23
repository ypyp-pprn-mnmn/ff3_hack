
# $33:a1a5 blowEffect_type04	

>[harp]

### code:
```js
{
	$a11c();
	x = $95;
	$a3f9();
	$7f49 = #8b;
$a1b2:
	beginSwingFrame();	//$a059();
	$b9 = a;
$a1b7:
	$a05e();
	if ($cd != 0) { //beq a1c8
		x = 6;
		a = #0f;
		$a06e();
		//goto a1cf
	} else {
$a1c8:
		x = #0e;
		a = #07;
		$a065();
	}
$a1cf:
	if (($b6 & 8) != 0) { //beq a1da
		a = 1;
		$97b2();
	}
$a1da:
	updatePpuDmaScrollSyncNmiEx();	//f8b0
	incrementEffectFrame();	//$8ae6
	if ((a & #10) == 0) $a1b7;
	if ($bd == 0) $a1ec;
	if (--$bd != 0) $a1b2;
	return $ac3a;	//jmp
$a1ef:
}
```


