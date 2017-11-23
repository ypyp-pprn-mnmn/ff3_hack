
# $31:a400 loadBattlePlayers 

<summary></summary>

## args:
+ [in] u16 $5b : playerPtr
+ [in] u16 $5d : enemyPtr?
//uses:
//	u8 $5f : offset
## (pseudo-)code:
```js
{
	//for (x = 3;x > 0;x--) {
	//	for (y = 0;y < 0x100;y++) {
	//		$5b[y] = 0;
	//	}
	//	$5c++;
	//}
	//$5c = 75h;
	memset($7500,0,0x300);
	for($52 = 0;$52 < 4;$52++) {
a418:
		for (x = 33h;x >= 0;x--) { $18.x = 0; }

		loadPlayer(); //jsr $31:a482
		push (a);	//a = jobparam.+4

		for (x = 0,y = $5f; x < 34h; x++,y++) {
			$5b[y] = $18.x; //copy 18~4b
		}
		pop (a);
		y++;
		$5b[y] = a;	// player.+35 = jobparam.+4 ($39:bb1a.[job*5+4])
	}
a43f:
	for ($4b = 0;$4b < 8;$4b++) {
a443:
		y = $4b;
		a = $7da7.y;
		if (a == ffh) {	//敵id?
			y = 1;
			$5d[y] = a = #80;
			y = #2c;
			$5d[y] = a = ($4b | 80h);
			x = $4b;
			$7ec4.x = a;	//80|index
			if ( x == 0 ) {
				loadMobParam(); //$31:a4f6();
			}	
		} else {
			loadMobParam();	//$31:a4f6();
		}
a461:
		$5d,5e += 40h;
	}
a479:
	$5d,5e = #$7675;
}
```



