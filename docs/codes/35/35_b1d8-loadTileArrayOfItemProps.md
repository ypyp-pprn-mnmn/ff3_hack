
# $35:b1d8 loadTileArrayOfItemProps



### args:
+ [in] u8 $34[2][4] : items
+ [in] u16 $43 : ptrToDestTileArray

### (pseudo-)code:
```js
{
	initTileArrayStorage();	//$34:9754();
	for ($3c = 0;$3c != 8;$3c += 2) {
$b1df:
		fillXbytesAt_7ad7_00ff(x = #d);	//$35:a549
		x = $3c;
		$1a = a =$34.x;
		if (a == #ff) { //bne $b1f6
			offset$4E_16(a = #d);	//$35:a558
			//clc bcc $b232
		} else {
$b1f6:
			if ((a = $7400.x) == 0) {	//bne $b200
				$7ad7 = #73;
			}
$b200:
			loadString(index:a = $1a,dest:x,  base:$18 = #8800);	//$a609
			$7ae1 = #c8;
			$19 = 0;
			x = $3c;
			itoa_16(value:$18 = $35.x);	//$34:95e1();
			$7ae2,7ae3 = $1d,1e;	//下2桁
			strToTileArray($18 = #0d);	//$34:966a();
$b232:		}
		offset$4e_16(a = #0d);
	}
$b241:	return;
$b242:
}
```



