
# $2f:ba8e put16hTilesFrom$7e

### code:
```js
{
	setVramAddr(high:a = $81, low:x = $80);	//f8e0
	for (y = 0;y != #16;y++) {
$ba97:
		$2007 = $7e[y];
	}
	return;
}
```


