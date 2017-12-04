

# $3e:cba4 field::loadWarpDestinationFloor

### args:
+	[in] u8 $48 : warpId
+	[in] u8 $78 : world
+	u8 $00:8a00[0x100] : warp id => floor id for "floating land"
+	u8 $00:8b00[0x100] : warp id => floor id for "under world"
+	u16 $11:8000[0x100] : linear offset from $11:8000

### code:
```js
{
	call_switch1stBank(per8k;a = 00);	//ff06
	x = $48;
	if ($78 < 2) {
		//浮遊大陸
		a = $8a00.x;
	} else {
		a = $8b00.x;
	}
	y = a;
	call_switch1stBank(per8k:a = #11);	//ff06
	x = #80;
	a = y << 1;
	if (carry) { //bcc cbc4
$cbc3:
		x++;
	}
	$87 = x; //80 or 81
	y = a;
	$86 = 0;
	//$86: 8000/8100
	$80 = $86[y];
	push (a = $86[++y] );
	$81 = a & #1f | #80;
	//$80: 16bit linear offset from $11:8000(22000)
	a = #11 + ((pop a) >> 5);
	call_switchFirst2Banks(per8kBase:a );
	//
$cbe5:
	$82,83 = #7400;
	y = 0;
	loadFloorData();	//$cbfa();
$cbf2:
	call_switch1stBank(per8k:a = #3a);
	return $3a:8503();
}
```





