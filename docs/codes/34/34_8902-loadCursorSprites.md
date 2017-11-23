
# $34:8902 loadCursorSprites



### args:
+ [in] $1a : destIndex (spriteIndex)
+ [out] $0220 : sprites[4]

### local variables:
	$891e(file:6892e) [4][4] = {
		F0 5A 03 F0  F0 59 03 F0
		F0 5C 03 F0  F0 5B 03 F0
	} : cursor sprites

### (pseudo-)code:
```js
{
	$4a,4b = #0220;
	y = a = $1a << 4;	//$3f:fd3e

	for (x = 0;x < 0x10;x++,y++) {
		$4a[y] = $891e.x;
	}
}
```



