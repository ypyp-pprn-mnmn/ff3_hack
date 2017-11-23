
# $34:90a0 dispCommand_06_showActionName



### args:
+ [in] u8 $72 : isEquipmentUsed
+ [in] u8 $78d7 : messageId (#ff : no display,#80> : specialAction)

### (pseudo-)code:
```js
{
	a = $72;
	if (a != 0) {
		//アイテム
		loadString(index:a = $78d7, dest:x = 0, base:$18 = #8800);
		for (x = 0;x != 9;x++) {
$90b6:			$7ad7.x = $7ad8.x;	//先頭の記号スペースを飛ばす
		}
		strToTileArray($18 = 8);//966a
		draw1RowWindow(a = 1);	//8d1b
		return;	//jmp $9051
	}
$90d0:
	a = $78d7;
	if (a < 0) goto $9150;
$90d8:	elif (a == 0) $9143;
	elif (a < #21) $9121;
	elif (a < #39) $910f;
	elif (a < #52) $90fd;
$90e6:	else {	//[#52-#7f]	//"そせい" "せきかかいふく" etc
		a -= #46; $1a = a;
		loadString(index:a = $1a, dest:x = 0, base:$18 = #8200);
		goto $34:9168;
	}
$90fd:	{	//[#39-#51]	//行動名
		a -= #39; $1a = a;
		setTableBaseAddrTo$8c40();	//95c6()
		loadString(index:a = $1a, dest:x = 0, base:$18);
		goto $34:9168;
	}
$910f:	{	//[#21-#38]  	//召還
		a += #c6; $1a = a;
		setTableBaseAddrTo$8a40();	//$34:95bd()
		loadString(index:a = $1a, dest:x = 0, base:$18);
		goto $34:9168;
	}
$9121:	{	//[#01-#20]	//"かいヒット"
		$18 = a; $19 = 0;
		itoa_16();	//$34:95e1();
		for (x = 0;x != 3;x++) {
			$7ad7.x = $1d.x;
		}
$9136:		setTableBaseAddrTo$8c40();	//95c6
		loadString(index:a = #13, dest:x = 2, base:$18);
		goto $9168;
	}
$9143:	{	//[#00]	//"ミス!"
		setTableBaseAddrTo$8c40();
		loadString(index:a = #09, dest:x = 0, base:$18);
		goto $9168;
	}
$9150:	{	//[#80-#ff]	//行動名(魔法・特殊)
		if (a == #ff) return;
		a -= #80; $1a = a;
		loadString(index:a = $1a, dest:x = 0, base:$18 = #8990);
	}
$9168:
	strToTileArray($18 = 8);	//966a
	draw1RowWindow(a = 1);		//8d1b
$9174:	return;	//jmp $9051
$9177:
}
```



