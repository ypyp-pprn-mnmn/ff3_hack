
# $33:a251 blowEffect_type03	

>[bow]

### code:
```js
{
	$a245();
	push (a = $7e17);
	$7e17 = $7e18;
	$7e19 = pop a;
	$a438();

	$a40f();
	x = $95;
	$a3f9();
$a26d:
	beginSwingFrame();	//$a059();
	$74f9 = #af;
$a275:
	$a05e();
	if (($b6 & 8) == 0) { //bne a2a0
		//前半(frame0-7)
	} else {
$a2a0:
		//...
	}
$a2bf:
	updatePpuDmaScrollSyncNmiEx();	//f8b0
	incrementEffectFrame();	//8ae6
$a2c5:
	if ((a & #10) == 0) $a275;
	$a6d2();
	return $ac35();

}
```


