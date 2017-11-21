
# $34:9d9e drawEnemyNamesWindow

<summary></summary>

## args:
+ [in] u8 $7dce[4] : group id
+ [in] u8 $7d6b[4] : enemy id
## (pseudo-)code:
```js
{
	initTileArrayStorage();	//$34:9754();
	for ($24 = 0;$24 != 4;$24++) {
		initString(x = 8);	//$a549 fillXbytesAt_7ad7_00ff();

		x = $24;
		a = $7dce.x;
		if (a != 0) {
			loadString(index:a = $7d6b.x, dest:x = 0, base:$18 = #8a40);
			strToTileArray(len:$18 = 8);	//$966a
			offsetTilePtr(len:a = 8);	//$a558
		}
$9dcd:
	}
$9dd5:
	return draw8LineWindow(left:$18 = #1, right:$19 = #0a,borderFlags:$1a = #3);	//$8b38
}
```



