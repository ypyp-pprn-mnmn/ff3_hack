
# $3f:fda6 loadTo7400Ex


## args:
+	[in] u8 $18 : index
+	[in] u8 $1a : dataSize
+	[in] u16 $20 : baseAddr //-> $fcf5
+	[in] u8 A : bankNo(per 16k unit)
+	[in,out] u8 X : destOffset
+	[in] u8 Y : bankToRestore
+	[out sizeis($1a)] $7400.x loadedParam
## code:
```js
{
	switchFirst2Banks(a);
	push (a = y);
	push (a = x);
	push (a = $1a);
	$19,$1b = 0;
	mul16x16();

	$1c,1d += $20,21
	$1a = popa;
	x = pop a;
	y = 0;
	do {
$fdcd:
		$7400.x = $1c[y++]; x++;
	} while (y != $1a);
	pop a;
	return switchFirst2Banks(a);
}
```



