
# $34:92db dispCommand09_sub03



can be thought as exactly like %u%s

### (pseudo-)code:
```js
{
	x = $78ef;
	$18 = a = $78e4.x; x++;
	$19 = a = $78e4.x; x++;
	$78ef = x;
	itoa_16();	//$34:95e1();
	x = y = 0;
	for (x = 0,y = 0;x != 5;x++) {
$92f4:		a = $1a.x;
		if (#ff != a) {
			$7da7.y = a; y++;
		}
$92fe:
	}
	$2a = y;
	setTableBaseAddrTo$8c40();	//$34:95c6();
	x = $78ee; 
	loadString(index:a = $78da.x, dest:x = $2a, base:$18); //a609
	strToTileArray($18 = #11); //$34:966a();
	draw1RowWindow(a = #4); //$34:8d1b();
	getPad1Input();	//$3f:fbaa();
	a = $12 & 1;
	return; //jmp $9236
$932b:
}
```



