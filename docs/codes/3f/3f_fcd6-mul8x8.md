
# $3f:fcd6 mul8x8


>筆算的掛け算(8bit*8bit)


### args:
+	[in] u8 a : multicand
+	[in] u8 x : multiplier
+	[out] u16 $1a : product

### code:
```js
{
	$18 = a;
	$19 = x;
	$1a,1b = 0;
	for (x = 8;x > 0;x--) {
		ror $19;	//注目桁をずらす
		if (carry) {	//最下位が1だった
			clc;
			$1b += 18	//この桁について加算する
		}
		ror $1b,1a	//結果の桁をシフトする
	}
}
```



