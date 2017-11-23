
# $31:a482 loadPlayer



### args:
+ [in] u8 $52 : playerIndex
+ [in] u8 $5f : offset
+ [out] u8 A : jobParam.+4 (of this player)
+ [out] u8 $18 : player.lv
+ [out] u8 $19 : player.status
+ [out] u16 $1b,1d : player.hp ,player.maxHp
+ [out] u8 $1f[8] : player.mp
+ [out] u8 $27 : player.jobLv
+ [out] u8 $40[4] : jobParam.+0~3
+ [out] u8 $44 : = $0052
+ [out] u8 $46[2] : 0

### (pseudo-)code:
```js
{
	//jsr $31:be90 { $5f = a = $52 << 6 }
	$18 = player.lv;	//+01
	$19 = player.status;	//+02
	a = #c;
	//jsr $31:be98 { Y = a + $5f }
	$1b,x  = player.hp; 	//(+0C)
	$1b,x = player.maxHp; 	//(+0E)
	$27 = player.joblevel; 	//(+10)
	Y = (#30 + $5f); //be98()
	for (x = 0;x < 8;x++,y+=2) { $1f.x = player.mp[x]; }

	a = player.job + player.job << 2; //fd40();
	$46,47 = a + #1a,#bb;	//jobは15hまでなので+#1aで桁上がりすることはない筈だが

	copyTo7400(bank:a=#1c, base:$46, restore:$4a=#18, size:$4b=5); //jsr $3f:fddc();
	//$7400~7404 = $39:bb1a.(job*5)
	for (x = 0;x < 5;x++) { $40.x = $7400.x; }

	push(a = $44);
	$44 = a = $0052;
	$46,47 = 0;
	pop(a);	//=jobParam.4
}
```



