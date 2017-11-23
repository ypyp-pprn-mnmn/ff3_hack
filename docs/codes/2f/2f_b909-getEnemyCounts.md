
# $2f:b909 getEnemyCounts

### args:
+	[out] u8 $80 : total enemy count

### code:
```js
{
	$80 = y = 0;
	for (y;y != 4;y++) {
$b90d:
		countEnemyInSameGroup($7e = y); //$b927();
		$7dce.y = a = $7f;
		$80 += a;
	}
$b921:
	$7dd2 = $80;
	return;
$b927:
}
```


