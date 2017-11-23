
# $3f:fd4a copyTo_$7ad7_x_Until0


## args:
+	[in] u8 A : sourceBank(per16k)
+	[in,out] u8 X : destOffset
+	[in] u16 $18 : ptr
+	[out] u8 $7ad7[] : dest
+	[out] u8 Y : len
## code:
```js
{
	switchFirst2Banks(a);
	y = 0;
	do {
		a = $18[y];
		if (0 == a) break;	
		$7ad7.x = a; x++;
	} while (++y != 0);
$fd5a:
	switchFirst2Banks(a = #1a);
}
```



