
# $31:bcd2 damageHp



### args:
+	[in] u16 $78 : damage
+	[in] u16 $24 : targetPtrToApply
+	[out] u8 $7573 : deathCounter?
+	[out] bool carry : isTargetAlive

### notes:
//$31:bced processKill

### (pseudo-)code:
```js
{
	if ($78,79 == 0) return;
	y = 3;
	$24[y++] -= $78;
	$24[y]  -= $79;
	//u16 temp = ($24[3],$24[4]);

	if (temp < 0 || temp == 0) {
		$7573++;
		$24[y--] = 0; $24[y] = 0;
		clc;
	} else {
$bcfa:
		sec;
	}
}
```



