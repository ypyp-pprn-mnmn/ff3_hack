
# $36:8ac0 muteChannels


## code
```js
{
	for (x = 3;x >= 0;x--) {
		if ($7f4a.x >= 0) continue;	//bpl 8aec
		if (x == 1) {	//bne 8ad2
			//square-wave 1
			if ($7f4f < 0) continue;	//bmi 8aec
			//bpl 8adb
		} else {
$8ad2:
			if (x == 3) { //bne 8adb
$8ad6:
				//noise
				if ($7f50 < 0) continue; //bmi 8aec
			}
		}
$8adb:
		a = x;
		y = a << 2;
		if (x == 2) { // bne 8ae7
$8ae3:			//tri-wave channel
			a = #80;	//linear counter start
			//bne 8ae9
		} else {
$8ae7:			a = #30;	//envelope decay loop | envelope decay disabled
		}
$8ae9:
		$4000.y = a;	//each channel's ctrl0
$8aec:
	}
$8aef:
	return;
}
```



