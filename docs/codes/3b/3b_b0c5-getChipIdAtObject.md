
# $3b:b0c5 getChipIdAtObject


### args:
+	[in] u8 $4c : default chip id? (warpparam.+03 = $0783)
+	[in] u8 $84 : object.x?
+	[in] u8 $85 : object.y?
+	[in] mapdata $7400[0x20*0x20]
+	[in] chipattr $0400[0x100]

### (pseudo)code:
```js
{
	y = $4c;
	a = ($84 | $85) & #20;
	if (a == 0) { //bne b0eb
		//マップの範囲内なので座標にあるチップIDをマップデータから取得
		$80,81 = (($85 << 5) + #7400 | $84);
		$67 = y = $80[y = 0];
	}
$b0eb:
	a = $0400.y;
	if (a < 0) {
$b106:		sec; return;
	}
	a &= 7;
	if ( (a & #07) == 0) {
$b108:
		$86 = 0; clc; return;
	}
	if ( a >= #04 
		|| ( (a != #03) && ((a |= $86) != #03) ) )
	{
$b104:
		clc; return;
	}
$b106:
	sec; return;
}
```



