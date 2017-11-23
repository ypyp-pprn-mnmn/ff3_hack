
# $34:8adf init4SpritesAt$0220



### (pseudo-)code:
```js
{
+ [in] u8 $18 : sprite index
+ [out] u8 $0220[0x10][$18<<4] : filled with #f0

	$4a,4b = #0220;
	a = $18;
	a <<= 4;	//$3f:fd3e();
	y = a;
	a = #f0;
	for (x = 0;x != 0x10;x++) {
		$4a[y++] = a;
	}
}
```



