
# $33:a2fb blowEffect_type09	

>claw

### code:
```js
{
	$a11c();
	x = $95;
	$a3f9();
$a303:
	beginSwingFrame();	//$a059();
	$7f49 = #8a;
$a30b:	
	fill_A0hBytes_f0_at$0200andSet$c8_0();	//$a05e();
	if ($cd != 0) { //beq a32a
$a312:
		a = 6;
		$a2d9();
		getSys0Random_00_ff();	//$a44f();
		$7e = a & 1;
		getSys0Random_00_ff();	//$a44f();
		$7f = a & 1;
		a = #0d;
		goto $a33f;
	} else {
$a32a:
		a = 5;
		$a2d9();
		getSys0Random_00_ff();	//$a44f();
		$7e = a & 1;
		getSys0Random_00_ff();	//$a44f();
		$7f = a & 1;
		a = #04;
	}
$a33f:
	push a;
	$a2cf();
	if (a == 0) { //bne a34a
$a345:
		pop a; push a;
		$92a1();
	}
	pop a;
	a = 2;
	$97b2();
	updatePpuDmaScrollSyncNmiEx();	//f8b0
	incrementEffectFrame();	//$8ae6();
	if ((a & 8) == 0) $a30b
	if ($bd == 0) $a362
	if (--$bd != 0) $a303
$a362:
	return $ac35();
$a365:
}
```

