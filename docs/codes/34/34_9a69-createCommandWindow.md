
# $34:9a69 createCommandWindow



### args:
+ [in] u8 $5f : playerOffset
+ [in] u8 $78ba : begginingFlag (surpriseAttack/backAttack)
+ [out] u8 $7400[6] : commandIdList (index=cursor pos)

### (pseudo-)code:
```js
{
	a = $78ba;
	if (0 != (a & 0x8)) ) {
		x = 3;
		$7404 = x--;	//3
		$7405 = x;	//2
	}
$9a79:	//上の条件で分岐しても結局はこの値に上書きする
	$7404 = x = 2;
	$7405 = ++x;
	y = $5f;	//
	y = a = $57[y] << 2;	//$fd40()
	for (x = 0;x != 4;x++) {
		$7400.x = $9b21.y; //y = job*4
	}
$9a98:
	initTileArrayStorage();	//$34:9754();

	$38 = 0;
	for ($2d = 0;$2d != 4;$2d++) {
$9aa1:
		fillXbytesAt_7ad7_00ff(x = 5);	//$35:a549();
		a = $7400.(x = $2d);
		if (a == #ff) {
			$38++;
			a = 0;
		}
$9ab3:
		$1a = a;
		loadString(index:a = $1a,dest:x = 1,base:$18 = #8c40);	// $35:a609();
$9ac4:		strToTileArray($18 = 5);	//$34:966a();
$9acb:		offset$4e_16(a = 5);	//$35:a558();
$9acd:
	}
$9ad8:
	$18 = 4;	//left
	$19 = #a;	//right
	$1a = 3;	//border
	return draw8LineWindow();	//$34:8b38();
$9ae7:
}
```



