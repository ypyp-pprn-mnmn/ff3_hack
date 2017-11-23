
# $3e:ccbb field::getMapDataPointers


## args:
+	[out] ptr $82 : pDest
+	[out] ptr $80 : pSrc
+	[in] u8 $2c : y?
+	[in] u8 $30 : offset y from top?
+	u16 $06:9000[0x400] : linear offset from $06:9000( 0d000 )
	cc42: 90 90 92 94 96
+	u8 $78 : world (浮遊大陸//浮上前/浮上後/海中)
## code:
```js
{
	call_switch1stBank(per8k:a = #06);	//ff06
	$87 = $cc42.(x = $78);
	$86 = 0;
	a = $2c << 1;
	if (carry) { //bcc ccd2
		$87++;
	}
$ccd2:

	y = a;
	$80 = $86[y]; //*$86: linear offset from $06:9000 (0d000)
	push (a = $86[++y] + #10);
	$81 = a & #1f | #80;
	a = (pop a >> 5) + #06;
	
$cceb:
	call_switch2banks(per8kBase:a );	//ff03
	$83 = #70 | $30;
	$82 = #00;
	return;
}
```




