
# $34:905b dispCommand_05_showActorName



### args:
+ [in] u16 $57 : playerPtr
+ [in] u8 $78d6 : charIndex
+ [in] u8 $7ecd[] : enemy group id?
+ [in] u8 $7d6b[4] : enemy ids

### (pseudo-)code:
```js
{
	if ((a = $78d6) < 0) {
		if (a == #ff) $909d;
		x = a & #7f;
		x = a = $7ecd.x;
		$1a = $7d6b.x;
		setTableBaseAddrTo$8a40();	//$34:95bd()
		loadString(index:a = $1a, dest:x = 0, base:$18);
	} else {
$907d:
		a <<= 6;	//$3f:fd3c();
		y = a + 6;
		for (x = 0;x != 6;x++) {
$9086:			
			$7ad7.x = $57[y++];
		}
	}
$9091:
	strToTileArray($18 = 8);	//966a
	draw1RowWindow(a = 0);		//8d1b
$909d:
	return;	//jmp $9051
$90a0:
}
```



