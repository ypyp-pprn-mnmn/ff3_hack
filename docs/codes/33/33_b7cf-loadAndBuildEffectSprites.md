
# $33:b7cf loadAndBuildEffectSprites

### args:
+	[in] u8 $7300[] : effectFrameParams (00-fe,ff:2byte escape)
+	[in] u8 $7e9c : frameParamOffset
+	[out] SpriteProperty $7924[]

### local variables:
+	u8 $87 : [000000ab] where
	-	a = (frameParam == #ff)
	-	b = (frameParam & #80)
+	SpriteTileParam $7900[0x24]
+	u16 $9708[ $7300[$7e9c] ]

### code:
```js
{
	$87 = 0;
	x = $7e9c;
	a = $7300.x;
	if (#ff == a) {	//bne b7e7
		$87 = 2;
		$7e9c++;
		a = $7301.x;
	}
$b7e7:
	$7e = a;
	$86 = a = a & #7f;
	rol $7e; rol $7e;
	$87 |= ($7e & 1);
	mul8x8_reg(a = $86,x = 2); //f8ea
	//ptrAddr = $00:9708+ (frameParam&#7f *2)
	memcpy(src:$7e = #9708 + (a,x),dest:$80 = #7900,len:$82 = 2,bank:$84 = 0); //f92f
	memcpy(src:$7e = $7900,dest:$80,len:$82 = #24,bank:$84);
$b82e:
	a = $7e9a & #40;
	if (a == 0) { //bne $b83c
		y = $87;
		$87 = $b7cb.y;
	}
$b83c:
	initAndTileEffectSprites(a = $87);	//$33:b8af(); 6x6
	x = 0;
	for (y = 0;y != #90;) { //90h : 24h * 4 =36 (6x6)
$b845:
		$7e = a = $7900.x;
		if (a >= 0) {	//bmi $b853
			setEffectSpriteTile();	//$33:b866();
			x++;
		} else {
$b853:
			x++;
			$80 = $7900.x;
			do {
				setEffectSpriteTile();	//$33:b866();
			} while( --$80 != 0 );
			x++;
		}
$b861:
	}
}
```


