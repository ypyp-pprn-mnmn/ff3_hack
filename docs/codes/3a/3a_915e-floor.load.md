

# $3a:915e floor.load

### args:
+	[in] u8 $48 : warpId
+	WarpParams $02:a000[0x10][0x100]:

### (pseudo)code:
```js
{
	call_switch2ndBank(per8k:a = #02);	//ff09
	$80,81 = #a000 | ($48 << 4);
	y = #0f;
	if ($78 != 0) { //beq 9182
$917b:
		$81 += #10;
	}
$9182:
	for (y;y >= 0;y--) {
		$0780.y = $80[y];
	}
	floor::init();	//$9267();
$918d:
	a = 0;
	for (x = #3f;x >= 0;x--) {
		$0740 = a;
	}
$9197:
	y = 0;
	$80,81 = #7400;

	for ($80,81; $80,81 <= #7800; $80,81++) {
$91a0:
		a = $80[y = 0];
		if (a < #60) 91bb;
		elif (a < #64) 91b4;
		elif (a < #70) 91bb;
		elif (a >= #7d) 91bb;
$91b4:
		//60 <= a < 64 || 70 <= a < 7d
		floor::getDynamicChip();	//$91c8();
		$80[y = 0] = a;
$91bb:
	}
	return;
$91c8:
}
```




