
# $3f:fcf5 mul16x16


>筆算の要領で掛け算をする(16bit*16bit)


### args:
+	[in] u16 $18 multicand
+	[in] u16 $1a multiplier
+	[out] u32 $1c = $18 * $1a

### code:
```js
{ 
	$1c,1d,1e,1f=0;
	for (x = 10h;x >0;x--) {
		if (($1a,$1b >> 1)) != 0) {
			$1e += $18;
			$1f += $19;
		}
		$1c,1d,1e,1f >> 1;
	}
}
```



