
# $33:a379 doSwing

### args:
+	[in] u8 $bd : hitCount

### code:
```js
{
	$a438();	//getWeaponSprite?
	$a40f();	//copySpriteProps?
	x = $95;
	$a3f9();	//clearWeaponSprite?
$a384:
	beginSwingFrame();	//$a059();
	$b9 = a;	//a = 0
	$7f49 = #b6;
$a38e:
	while (($b6 & 8) == 0) {
		fill_A0hBytes_f0_at$0200andSet$c8_0();	//$a05e();
$a393:
		if (($b6 & 4) == 0) { //bne a3af
$a397:
		//前半(4フレーム)
			if ($cd != 0) { //beq $a3a5
$a39b:
				x = 2; a = 7;
				$a065();
				//goto $a3c8();
			} else {
$a3a5:
				x = 5; a = 0;
				$a06e();
			} //goto $a3c8();
		} else {
$a3af:
		//後半
			if ($cd != 0) { //beq $a3bd
$a3b3:
				x = 3;a = 6;
				$a065();
				goto $a3c3;
			} else {
$a3bd:
				a = x = 1;
				$a06e();
			}
$a3c3:
			a = $ba;
			$97b2();
		}
$a3c8:
		updatePpuDmaScrollSyncNmiEx();	//$f8b0
		incrementEffectFrame();	//$8ae6();
$a3ce:
		//if ((a & 8) == 0) $a38e; //beq
	}
	if ($bd == 0) $a3da;
	if (--$bd != 0) $a384;
$a3da:
	return $ac35();	//jmp
}
```


