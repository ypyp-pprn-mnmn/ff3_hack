
# $35:adaf commandWindow_OnItemSelected()



>14: アイテム


### args:
+ [in,out] u8 $52 : playerIndex

### local variables:
+	u8 $62 : cursor row index (0-3), init : 0
+	u8 $63 : cursor col index (0-7), init : 1
+	u8 $65 : background no (used in scrolling function), init : 0
+	u8 $66 : current window left (col index,equipWindow = 0), init : 1
+	u8 $67 : indicates Nth selection  (0-1)
+	u8 $68 : row index of 1st selection 
+	u8 $69 : col index of 1st selection
+	u8 $7afd[0x40] : items {id,count}
+	u8 $7b3d[0x40] : equipflags (0 = cannot use/equip,mark 'x' next to name)

### (pseudo-)code:
```js
{
	updatePpuDmaScrollSyncNmi();	//$3f:f8c5();
	$3d = 0;
	eraseWindow();	//$34:8eb0();	//disp

	$10 = #78;
	updatePpuDmaScrollSyncNmi();	//$3f:f8c5();
	createEquipWindow(erase:$7573 = 0);	//$35:b419();

	for (x = 0;x != 0x40;x++) {
		$7afd.x = $60c0.x; //$60c0 = backpackItems[0x20]
	}
	for (x = 0x23;x >= 0;x--) {
		$7b3d.x = 1;
	}
	setYtoOffset03();//$34:9b8d();
	$7af5,7af7 = $59[y++];//righthand
	$7af6,7af8 = $59[y++];
	$7af9,7afb = $59[y++];//lefthand
	$7afa,7afc = $59[y++];
	$42,43 = 0;
	for ($43 = 0;$43 != 0x20;$43++,$42+=2) {
$ae0b:
		$20 = #$9400;
		x = $42;
		a = $60c0.x;
		if (a >= 0x62) { //62=皮の帽子
			if (a >= 0x98) {	//98=魔法の鍵
				if (a < 0xc8) {	//c8=フレア
					continue;//goto $ae34;消耗品
				} else {
					goto $ae2f;//魔法
				}
			} else {
				goto $ae2f;//防具
			}	
		} else {
$ae26:			//武器か盾
			$18 = a;
			$35:b8fd();//checkEquipableFlags?
			if (0 != (a = $1c)) {
				cotinue;//goto $ae34
			}
		}
$ae2f:
		x = $43;
		$7b41.x--;
$ae34:
	}
$ae40:
	$3d = 0;
	loadTileArrayForItemWindowColumn();//$35:b48b();
	draw8LineWindow(left:$18 = #10, right:$19 = #1e, behavior:$1a = #1); //$34:8b38();
	
	loadTileArrayForItemWindowColumn();
	draw8LineWindow(left:$18 = #1f, right:$19 = #8d, behavior:$1a = #0); //$34:8b38();
	
	loadTileArrayForItemWindowColumn();
	draw8LineWindow(left:$18 = #8e, right:$19 = #9c, behavior:$1a = #0); //$34:8b38();
	//
$ae7a:
	loadAndInitCursorPos(type:$55 = 2, dest:$1a = 1);	//$34:8966();
	tileSprites2x2(index:$1a = 1, top:$1c = #f0, right:$1d = #f0);	//$34:892e()
	loadAndInitCursorPos(type:$55 = 2, dest:$1a = 0);	//$34:8966();
	$62,65,67 = 0;	//$62:cursor.y
	$63,66 = 1;	//$63:cursor.x
$aeaa:	//itemWindowInputLoop
	while (true) {
		do {
			presentCharacter();	//$34:8185();
			getPad1Input();		//$35:fbaa();
		} while ($12 == 0);
$aeb4:
		push a; //=$12=inputflag
		setSoundEffect18();	//set$ca_and_increment_$c9(#18);	//$35:9b79()
		pop a;
$aeb9:		switch (a) {
		case 0x01: //A
			goto $af4c;
		case 0x02: //B
$aec4:			goto $b198;
		case 0x10: //up
$aee0:			//
			if (0 != (a = $63)) $aeec;
			if (1 == (a = $62)) break;	//$aef5;
			$62--;
$aeec:			if (0 == (a = $62)) break;	//$aef5;
$aef0:			$62--;
			itemWindow_moveCursor();	//$35:b4d4
$aef5:			break;	//jmp $aeaa
		case 0x20: //down
$aef8:			//goto $aef8;
			if (3 != (a = $62)) {
				if (0 == (a = $63)) $62++;
$af04:				$62++;
				itemWindow_moveCursor();	//$35:b4d4();
			}
$af09:			break;	//jmp $aeaa
		case 0x40: //left
$af0c:			if (0 != (a = $63)) {
				if ($63 == (a = $66)) itemWindow_scrollLeft();	//$35:b362();
$af19:				$63--;
				if ( (0 == (a = $63))
				 && (0 == (a = ($62 & 1))) ) {
					$62 |= 1;
				}
$af2b:				itemWindow_moveCursor();	//$35:b4d4();
			}
$af2e:			break;	//jmp $aeaa
		case 0x80: //right
$af31:			if (8 != (a = $63)) {
				if ( (7 != (a = $66))
					&& ($63 != a) ) {
					itemWindow_scrollRight();	//$35:b2a7();
				}
$af44:				$63++;
$af49:				itemWindow_moveCursor();	//$35:b4d4();
$af4c:
			}
$af49:			break;	//jmp $aeaa
$af4c:
		default:
$aede:			break;	//goto $aeaa;
		}
	}
}
```



