
# $36:8925 updateMusicStream


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



