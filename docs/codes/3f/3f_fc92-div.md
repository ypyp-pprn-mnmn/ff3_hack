
# $3f:fc92 div 
<summary>筆算的に割り算</summary>

## args:
+	[in] u16 $18 dividend
+	[in] u16 $1a divisor
+	[out] u16 $1c quotient (result)
+	[out] u16 $1e modulo (remainder)
## code:
```js
{
	$1c,1d,1e,1f = 0;
	a = $18 | $19;
	if (a == 0) return;
	a = $1a | $1b;
	if (a == 0) return;

	for (x = 0x10;x > 0;x--) {
		rol $18,19,1e,1f
		$1e,1f -= $1a,1b;	//とりあえず引いてみる
		if ($1f < 0) {	
			//マイナスになっちゃったから無かった事にする
			$1e,1f += $1a,1b;	
			$1c,1d <<= 1;
		} else {
			//引けた
			//rol $1c,1d
			$1c,1d <<= 1;
			$1c |= 1;
		}
	}
}
```



