
# $31:bbe2 isTargetWeakToHoly



### args:
+	[out] bool carry : 1=yes 0=no
+	[out] u8 $27 : 2=yes 0=no

### (pseudo-)code:
```js
{
	if ($70[y = #12] <= 0) { //bbef
		$27 = #2;
		sec;
	} else {
$bbef:
		clc;
		a = 0;
	}
$bbf2:
	return;
}
```



