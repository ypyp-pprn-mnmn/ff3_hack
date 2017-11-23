
# $34:86ab targetBitToCharIndex



### args:
+ [in] u8 $7e98.x : ?
+ [in] u8 X : side
+ [out] u8 Y : result index 

### (pseudo-)code:
```js
{
	y = 0;
	do {
		a = $7e98.x;
		if (a == $fd24.y) break;
	} while (++y != 0);
$86b8:
}
```




