
# $35:af4c itemWindow_OnAButton

<summary></summary>

## args:
+ [in,out] u8 $1d : cursor.x
+ [in,out] u8 $52 : currentPlayerIndex
+ [in] u16 $59 : playerEquipsPtr
+ [in] u16 $5e : playerPtr
+ [in] u8 $62,63 : currentSelection {row,col}
+ [in,out] u8 $67 : mode
+ [in,out] u8 $68,69 : lastSelection {row,col}
+ [in] u8 $7af5[2][0x20+4] : items {id,count}
+ [in] u8 $7b3d[0x20+4] : isEquipmentForHand?
## (pseudo-)code:
```js
{
	if (0 == (a = $67)) {
		$67++;
		$68 = $62;
		$69 = $63;
		itemWindow_moveCursor();	//$35:b4d4();
		//選択位置にカーソルを設置する
		$1d += 4;
		tileSprites2x2(index:$1a = 1, top:$1c, right:$1d );	//$34:892e()
		setSoundEffect05();	//set$ca_and_increment_$c9(#5);	//$34:9b7d();
		for (x = 0x10;x != 0;x--) {
			presentCharacter();	//$34:8185();
		}
		backToItemWindowInputLoop();
	}
$af79:	//on 2nd item selected
	if ($63 == $69 && $62 == $68) {
		return itemWindow_OnUse;	//jmp $b4f7
	} else {
$af88:		//1個目と2個目の選択アイテムが違う(いれかえようとしている)
		if ( (0 == ($63 | $69)) {
			|| ( (0 != (a = $63)) && (0 != (a = $69)) )
		{
$af96:		//左右の装備を入れ替えたか選択のどちらも装備欄じゃない
			setSoundEffect06();	//set$ca_and_increment_$c9(#6);	//$34:9b81();
			return backToItemWindowInputLoop();
		} 
$af9c:		//装備を替えようとした
		$7408 = x = 0;
		$7409 = ++x;
		if (($63 = a) >= $69) {	//bcc $afc3;
			push (a); $63 = $69; $69 = pop a;	//swap($63,$69)
			push (a = $62); $62 = $68; $68 = pop a;	//swap($62,$68)
			$7408++; $7409--;
		}
$afc3:		a = $69 << 3;	//$3f:fd3f
		a += $68 + $68
		$43 = a;
		a = $69 << 2;	//$3f:fd40
		x = $45 = a + $68;
		a = $783d.x;
		if (a == 0) { //bne $affe;
$afdf:			$34:9b81();
			if (0 != (a = $7408)) { // beq $affb;
				push (a = $63); $63 = $69; $69 = pop a;
				push (a = $62); $62 = $68; $68 = pop a;
			}
$affb:			return backToItemWindowInputLoop(); //jmp $aeaa
		}
$affe:		//盾か剣だった(入れ替えられるかもしれない)
		x = $43;	//$43 : 2*(col*4+row)
		a = $7af5.x;
		if (a >= #62) $afdf;	//にもかかわらずIDが"皮の帽子"以上だった
		$40 = a; x++;		//id (着ける方)
		$41 = $7af5.x;		//count
		$42 = x = a = ($63 << 3) + $62 + $62;	//$3f:fd3f
		$3e = $7af5.x; x++;	//id (外す方:装備欄)
		$3f = $7af5.x;		//count
		$44 = ($63 << 2) + $62;	//(col * 4 + row)
$b031:		
		isHandFreeForItem(remove:$3e,equip:$40);	//$34:b242();
		if (carry) $afdf;
		if ((a = $3e) == $40) {	//bne $b066
			if ((a | $40) == 0) $afdf;
			a = 0;x = $42;
			$7af5.x = a; x++;
			$7af5.x = a;
			x = $44;
			$7b3d.x = 1;
			x = $43; x++;
			a = $41 + $3f;
			if (a >= #64) a = #63; //bcc $b060
			$7af5.x = a;
			//jmp $b131
		} else {
$b066:			if ((a = $41) == 1
				|| (a = $40) == 0) goto $b101;
$b076:
			for ($25 = x = 0;x != #40; x += 2) {
$b07a:				a = $7afd.x;
				$24 = x;
				if (a == 0) $b089;
			}
$b087:
			$25++;
$b089:			if ((a = $40) < #4f	//bcc $b0cd #4f = "きのや"
				|| a >= #57) 	//bcs $b0cd #56 = "メデューサの矢"
				goto $b0cd;
$b093:
			if ((a = $41) < #15) $b101;	//bcc
			if ((a = $3e) == 0) $b0b1;	//beq
			if ((a = $25) != 0) goto $afdf;	//beq $b0a4
$b0a4:		//21本以上持ってる矢を着けた
			x = $24;	//index of free space (from $7afd)
			$7afd.x = $3e; x++;	//id (外した方)
			$7afd.x = $3f;		//count
$b0b1:			x = $42;
			$7af5.x = $40; x++;	//id
			$7af5.x = #14;		//count
			x = $43; x++;
			$7af5.x -= #14;		//count (つけようとしたアイテムの元の数)
			goto $b131;
$b0cd:		//矢以外
			if ((a = $3e) == 0) $b0e5;	//beq
			if ((a = $25) == 0) $b0d8;	//beq $25:空欄がなければ1
			goto $afdf;
$b0d8:
			x = $24;	//空欄
			$7afd.x = $3e; x++;
			$7afd.x = $3f;
$b0e5:			x = $42;	//装備欄
			$7af5.x = $40; x++;
			$7af5.x = 1;
			x = $43; x++;	//着けようとしたアイテムの位置
			$7af5.x -= 1;
			goto $b131;
$b101:		//1個しかないアイテムか空欄か20本以下の矢を装備した	
			x = $43;
			$7af5.x = $3e; x++;
			$7af5.x = $3f;
			x = $42;
			$7af5.x = $40; x++;
			$7af5.x = $41;
			x = $44;
			push (a = $7b3d.x)
			x = $45; a = $7b3d.x;
			x = $44; $7b3d.x = a;
			pop a; x = $45;
			$7b3d.x = a;
		}
$b131:
		for (x = 0;x != #40;x++) {
$b133:			$60c0.x = $7afd.x;
		}
$b13e:		
		setYtoOffset03();	//$34:9b8d();
		$59[y++] = $7af7;
		$59[y++] = $7af8;
		$59[y++] = $7afb;
		$59[y++] = $7afc;
		setSoundEffect05();	//set$ca_and_increment_$c9(#5);	//$34:9b7d
		if ((a = $7408) != 0) { //beq $b16a
			push (a = $63); $63 = $69; $69 = pop a;
		}
$b16a:
		if ((x = $63) == 0) { //bne $b187
			createEquipWindowNoErase();	//$35:b5f9();
			if ((a = $69) < 3) {	//bcs $b193
				push (a = $63); $63 = x = $69;
				$35:b601();
				$63 = pop a;
			} //clc bcc $b193
		} else {
$b187:
			$35:b601();
			if ((a = $63) < 3) {	//bcs $b193
				createEquipWindowNoErase();	//$35:b5f9();
			}
		}
$b193:		
		$52--;
$b195:		endItemWindow(); //goto $b1b0;
	}
$b198:
}
```



