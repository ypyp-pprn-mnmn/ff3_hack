________________________________________________________________________________
# $36:8003 soundDriverEntry
<details>

## args:
+	[in] u8 $7f43 : ?
+	[in] u8 $7f49 : soundId ( =$ca | #80); #40 = playLast?
## callers:
+	$3f:faf2(irq worker)
## code:
```js
{
	if ($7f43 == #37) { //bne $8011
$800a:
		$7f49 = 0;
		//beq 8014
	} else {
$8011:
		$8b9d();
	}
$8014:
	$8925();
	$4015 |= #0f;	//4015:soundreg #0f:enable( noise | triangle | square-1 | square-0 )
	$8030();
	$80ab();

	$7f40 <<= 1;
	a = $7f42 << 1;	//
	ror $7f40;	//再生中なら最上位に1
	return;
$8030:
}
```
</details>

________________________________________________________________________________
# $36:8030 playNoiseAndSquare1
<details>

```js
{
	if ($7f49 == 0) return; //beq 80aa
	if ($7f4f >= 0) $8079 //bpl 8079
	if (($7f4f & 1) != 0) { //$8064 //beq
$803e:
		$7f4f &= #fe;
		$4004 = $7f8e|$7f80	//sq1 ctrl0
		$4005 = $7f87;		//sq1 ctrl1
		$4006 = $7f72;		//sq1 freq.low
		$4007 = $7f79;		//sq1 freq.high
		//goto $8079;
	} else {
$8064:
		$4004 = $7f8e | $7f80;
		a = $7f87 << 1;
		if (!carry) { //bcs 8079
			$4006 = $7f72;
		}
	}
$8079:
	if ($7f50 >= 0) return;	//bpl 80aa
	if (($7f50 & 1)) != 0) { //beq 809c
$8082:
		$7f50 &= #fe;
		$400c = $7f81 | #30;	//noise ctrl0; #30 = envelope decay loop | envelope decay disabled
		$400e = a = $7f73;	//noise freq.low
		$400f = a;		//noise freq.high
		return;
	}
$809c:
	$400c = $7f81 | #30;
	$400e = $7f73;
$80aa:
	return;
$80ab:
}
```
</details>

________________________________________________________________________________
# $36:80ab
<details>

## code:
```js
{
	if ($7f42 >= 0) return;	//bmi 80b1
$80b1:
	if ($7f4a >= 0) $80f5;	//bpl
	if ( ($7f4a & 1) != 0) { //beq 80e0
		$7f4a &= #fe;
		$4000 = $7f89 | $7f7b;
		$4001 = $7f82;
		$4002 = $7f6d;
		$4003 = $7f74;
		//goto $80f5;
	} else {
$80e0:
		$4000 = $7f89 | $7f7b;
		a = $7f82 << 1;
		if (!carry) {	//bcs $80f5
			$4002 = $7f6d;
		}
	}
$80f5:
	if ($7f4f < 0) $813e;	//bmi
	if ($7f4b >= 0) $813e;	//bpl
$80ff:
	//...
}
```
</details>

________________________________________________________________________________
# $36:81e6
<details>

## code
```js
{
	x = $d0;
	if ($7f4a.x >= 0) 820a
	if ($7f5f.x != 0) 81f5
	$820b();
$81f5:
	x = $d0;
	$7f5f.x--;
	if ($7f97.x != 0) 8207
$81ff:
	if ($7f9e.x == 0) 820a
	$7f9e.x--;
$8207:
	$7f97.x--;
$820a:
	return;
}
```
</details>

________________________________________________________________________________
# $36:820b
<details>

## code
```js
{
	$d3,d4 = $7f51.x,$7f58.x
	y = 0;
	a = $d3[y]; y++;
	if (a < #e0) $826f
$821e:
	x = (a - #e0) << 1;
	$d8,d9 = $822f.x,$8230.x
	(*$d8)();
}
```
</details>

________________________________________________________________________________
# $36:8925 updateMusicStream
<details>

## args:
+	[in] u8 $7f40 : soundIdPlayingOn? | #80
+	[in] u8 $7f41 : lastPlayedMusic?
+	[in] u8 $7f42 : controlFlag 01:playNew 02:playLast 04:stopMusic 40:delayedStop 80:playOn
+	[in] u8 $7f43 : soundIdToPlay?

## code:
```js
{
	switch2ndBankToSoundDataBank($7f43);	//$899f();
	x = a = $7f42;
	if ((a & 1) == 0) 895d;	//beq
	if ((a = $7f40) >= 0) 8949;	//bpl
	if ((a & #7f) == $7f43) 8956;	//beq
	if (a != #37) 8949;	//bne
$8940:
	$7f43 = a;	//(7f40&7f) = 37
	switch2ndBankToSoundDataBank($7f43);	//$899f();
	return $8956();
$8949:
	$7f41 = a;
	$7f40 = $7f43;
	$89c3();
	return;
$8956:
	$7f42 = #80;
	goto $899b; //bmi
$895d:
	a = x & 2;
	if (a == 0) 8977;
	$7f40 = $7f43 = $7f41;
	$7f42 = 1;
	switch2ndBankToSoundDataBank($7f43);	//$899f();
	$89c3();
	return;
$8977:
	a = x & 4;
	if (a == 0) 897f;
	stopMusic();	//$8aa7();	//stopMusic?

	a = $7f42 & #20;
	if (a == 0) 898c;
	$8af0();
	return $8996();
$898c:
	a = $7f42 & #40;
	if (a == 0) 8996;
	$8b11();
$8996:
	if ($7f42 < 0) { // bpl $899e;
$899b:
		$8b2d();
	}
$899e:
	return;
$899f:
}
```
</details>

________________________________________________________________________________
# $36:899f switch2ndBankToSoundDataBank
<details>

## args:
+	[in] u8 $7f43 : soundId
```js
{
	$8000 = #7;	//switch 2nd bank
	x = 0;
	if ($7f43 >= #19) { //bcc 89b8
		x++;
		if ($7f43 >= #2b) { //bcc 89b8
			x++;
			if ($7f43 >= #3b) { //bcc 89b8
				x++;
			}
		}
	}
$89b8:
	$8001 = $89bf,x
	return;
}
```
</details>

________________________________________________________________________________
# $36:8aa7 stopMusic?
<details>

```js
{
	if ((a = ($7f42 & #8)) != 0) $8ab5;
	$7f42 = a;	//0
	muteChannels();	//$8ac0();
	return;
$8ab5:
	$7f42 = #c0;
	$7f48 = 0;
	return;
}
```
</details>

________________________________________________________________________________
# $36:8ac0 muteChannels
<details>

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
</details>

________________________________________________________________________________
# $36:8b9d
<details>

```js
{
	a = $7f49;
	if (a == 0) $8bb7
	if (a == #ff) $8bb1
	a <<= 1;
	if (carry) $8bad	//msb set = soundeffect
	$8c58();	//loadMusicData?
	return;
$8bad:
	$8bb8();	//loadSoundEffectData?
	return;
$8bb1:	//#ff
	$7f49++;
	$8c29();
$8bb7:
	return;
}
```
</details>

________________________________________________________________________________
# $36:8c58 loadMusicData?
<details>

```js
{
	$d2 = #ff;
	$d0 = #03
	$d1 = #05;
	$36:81e6();
	$36:857d();
	$d0++;
	$d1 = 1;
	$36:81e6();
	$36:857d();
	return;
}
```
</details>
