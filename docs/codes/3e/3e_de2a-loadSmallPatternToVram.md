
# $3e:de2a loadSmallPatternToVram


## args:
+	[in] ptr $80 : pattern
+	[in] u8 x : len
+	[in] u8 y : offset
## code:
```js
{
	do {
		$2007 = $80[y++];
	} while (--x != 0);
	return;
$de34:
}
```



