
# $33:a1ef blowEffect_type07	

>[shuriken]

### code:
```js
{
	$a11c();
	x = $95;
	$a3f9();
$a1f7:	
	beginSwingFrame();	//$a059();
	$7f49 = #af;
$a1ff:
	$a05e();
	if (($b6 & #08) == 0) { //bne a220
		if ($cd != 0) { //beq a216
			x = #7;
			a = #1e;
			$a06e();
			// goto a235
		} else {
$a216:
			x = 5;
			a = #18;
			$a06e();
			//goto a235();
		}
	} else {
$a220:
		if ($cd != 0) { //beq a22e
			x = 6;
			a = #1f;
			$a06e();
			//goto a235;
		} else {
$a22e:
			x = 1;
			a = #19;
			$a06e();
		}
	}
$a235:
	updateDmaPpuScrollSyncNmiEx();	//$f8b0
	incrementEffectFrame();	//8ae6
	if ((a & #10) == 0) a1ff;
$a23f:
	$a5fe();
	return $ac35();	//jmp
$a245:
}
```


