
# $3f:fd60 get2byteAtBank18


## args:
+	[in] u16 $18 : baseOffset
+	[in] u8 $1a : index
+	[out] u16 $18 : 2byte-value
## code:
```js
{
	switch_16k_synchronized(a = 0x0c);	//$3f:fb87();
	$1b = 0;
	$1a,1b <<= 1;
	$1a,1b += $18,19;
	$18,19 = *($1a,1b);
	switch_16k_synchronized(a = 0x1a);
}
```




