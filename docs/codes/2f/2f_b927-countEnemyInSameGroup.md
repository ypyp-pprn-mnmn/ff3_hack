
# $2f:b927 countEnemyInSameGroup

### args:
+	[in] u8 $7e : groupId

### code:
```js
{
	for (x = 0;x != 8;x++) {
		$7f = x;
		if ($7da7.x == $7e) {
			$7f++;
		}
	}
	return;
$b93a:
}
```


