
# $3e:de5a floor::loadPatternForTiles


### args:
+	[in] u8 $48 : warpId
+	[in] u8 $78 : world
+	$00:8c00[2][0x100] : tileSetId (index = warpId)
+	ptr $00:8e00[0x30][0x8] : pTilePattern (index = tileSetId)

### code:
```js
{
	call_switchFirst2Banks(per8k:a = 00); //ff03
	x = $48;
	if ($78 < #02) {
		a = $8c00.x;
	} else {
		a = $8d00.x;
	}
$de6d:
	$8c,8d = #8e00 + (a << 4);
	for (y = #0f;y >= 0;y--) {
		$7f00.y = $8c[y];
	}
$de8c:
	$8e = 0;
	$2002;
	$2006 = 0; $2006 = 0;
	for ($8e;$8e < 8;$8e++) {
$de9b:
		y = $8e << 1;
		$80 = $7f00.y;
		push (a = $7f01.y);
		$81 = a & #1f | #80;
		a = (pop a >> 5) + 3;
$deb7:
		call_switchFirst2Banks(per8k:a );
		x = $8e;
		x = $df00.x;	//
		y = 0;
		loadTilePatternToVram();	//$deea();
	}
$decd:
	call_switch1stBank(per8k:a = #3a); //ff06
	sec;
	$3a:8518();
$ded6:
	call_switch1stBank(per8k:a = #0d); //ff06
	$80,81 = #9700;
	x = #09;
	a = #07;
	return loadPatternToVramEx();	//$de0f();
$deea:
}
```




