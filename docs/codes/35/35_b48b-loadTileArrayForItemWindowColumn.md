
# $35:b48b loadTileArrayForItemWindowColumn()

<summary></summary>

## args:
+ [in,out] u8 $3d : firstItemOffset, incremented by 8 per call
## (pseudo-)code:
```js
{
	for (x = 7;x >= 0;x--) { $7400.x = 1; }
	y = $3d;
	for (x = 0;x != 8;x++) { $34.x = $60c0.y++; }
	for (x = 0;x != 8;x+=2) {
		if (0 == (a = $34.x) {
			$34.x = #57;
		}
	}
$b4b4:
	y = a = $3d >> 1;
	for (x = 0;x != 8;x+=2,y++) {
		if (0 == (a = $7b41.y)) {
			$7400.x--;
		}
	}
$b4c9:
	y = $3d = a = $3d + 8;
	return loadTileArrayOfItemProps();
	//jmp $35:b1d8
$b4d4:
}
```



