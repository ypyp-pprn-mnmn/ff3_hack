
# $31:a368 sumDamageForDisplay



### args:
+	[in,out] u16 $6a,6b : resultDamage
+	[in] u16 $78 : damageToAdd

### (pseudo-)code:
```js
{
	clc;
	$6a,6b += $78,79;
	if ($6a,6b > 9999) { $6a,6b = 9999; }
}
```



