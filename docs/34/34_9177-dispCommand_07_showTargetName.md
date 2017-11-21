
# $34:9177 dispCommand_07_showTargetName

<summary></summary>

## args:
+ [in] u16 $57 : playerPtr
+ [in] u8 $78d8 : targetCharIndex
+ [in] u8 $7ecd[] : enemy group id?
+ [in] u8 $7d6b[4] : enemy ids?
## (pseudo-)code:
```js
{
	a = $78d8;
	if (a < 0) {
		if (a == #ff) $91cb;
		a &= #7f;
		if (a == 8) {
			$1a = #16;	//"ぜんたい"?
			setTableBaseAddrTo$8c40();	//95c6
		} else {
$9190:			x = a; a = $7ecd.x;
			x = a; a = $7d6b.x
			if (a == #ff) $91cb;
			$1a = a;
			setTableBaseAddrTo$8a40();	//$34:95bd()
		}
$91a1:		loadString(index:a = $1a, dest:x = 0; base:$18);
	} else {
$91ab:
		a <<= 6;	//$fd3c;
		y = a + 6;
		for (x = 0;x != 6;x++) {
$91b4:
			$7ad7.x = $57[y++];
		}
	}
$91bf:
	strToTileArray($18 = 8);	//966a
	draw1RowWindow(a = 2);		//8d1b
	return;		//jmp $9051
$91ce:
}
```



