
# $34:9408 updateEnemyStatus



### args:
+ [in] u16 $18 : ptr to status to apply
+ [out] u8 $7ec4[8] : status

### local variables:
+	u16 $1e : enemyptr

### (pseudo-)code:
```js
{
	$1c = 0;
	$1e,1f = #7675;
	for ($1c = 0;$1c != 8;$1c++) {
$9414:
		$1a = $1c << 1;
		a = $18[y = $1a] | $1e[y = 1];
		$1e[y] = a;
		a &= #e8;
		if (0 != a) {
			x = $1c;
			$7ec4.x = $1e[y] = a | #80;
		}
$942f:	
		y = $1a; y++;
		a = $18[y];
		$1e[y = 2] |= a;
		$1e,1f += #40;
	}
$944f:
	return;
$9450:
}
```




