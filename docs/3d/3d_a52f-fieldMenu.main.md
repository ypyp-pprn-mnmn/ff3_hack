
# $3d:a52f fieldMenu::main


## (pseudo)code:
```js
{
	$78f0 = 0;
	$25 = 0;
	$2001 = 0;
	$79f0 = $7af0 = 0;
	
	$dd06();
	$f7bb();
	$c486();
	$ff00();
	$4014 = 2;
	$d308();
$a555:
	$fd = $ff = #88;
	$959f();
	$7f49 = #ff;
	$57 = #3c;
$a567:
	$9599();
	$37 = 1;
$a56e:
	$a3 = $a4 = $b4 = x = 0;
	a = #30;
	$a666();
	x = 1; a = #31;
	$a666();
	x = 2; a = #32;
	$a666();
	x = 3; a = #33;
	$a666();
	x = 4; a = #34;
	$a666();
$a597:
	$a2 = 1;
	a = $2d >> 1;	
	if (carry) { //bcc a5a9
$a5a0:
		//(($2d & 1) == 1) : セーブ不可
		$78f1 -= 4; 
	}
$a5a9:
	do {
		$a7cd();
		a = 0;
		$8000();
		a = 0;
		$80cb();

		fieldMenu_updateCursorPos(incr:a = 4);	//$91a3();
$a5bb:
		if ($25 != 0) goto $a646; //beq a5c2
$a5c2:
	} while ($24 != 0) //beq a5a9
$a5c6:
	//$78f0: cursor pos (4/row)
	$8f74();
	$a654();
	if ((a = $78f0) == 0) { //bne a5d7
$a5d1:	//アイテム
		$9ec2();
		goto $a567;
	}
$a5d7:
	if (a == 4) { //bne a5ef
	//まほう
		selectCharacter();	//$a6b4();
		if (carry) goto $a5a9; //bcs
		x = $7f;
		a = $6102.x & #c0;	//status
		if (a == 0) { //bne a622
			$9761();
			goto $a567;
		}
	} 
$a5ef:	
	else if (a == 8) { //bne $a5fe
	//そうび
		selectCharacter();	//$a6b4();
		if (carry) $a5a9; //bcs
		$9bb5();
		goto $a567;
	}
$a5fe:
	else if (a == #c) { //bne $a60d
$a602:	//ステータス
		selectCharacter();	//$a6b4();
		if (carry) $a5a9;
		$a83b();
		goto $a567;
	}
$a60d:
	else if (a == #10) { //bne $a617
	//ならびかえ
		$a696();
		goto $a5a9;
	}
$a617:
	else if (a == #14) { //bne $a640
$a61b:	//ジョブ
		if ( ($6021 & #1f) == 0) { //bne a62c
$a622:		//まほう→死亡or石化もここにくる
			$d529();
			$a3 = 0;
			goto $a5a9;
		}
$a62c:
		selectCharacter();	//$a6b4();
		if (carry) $a5a9;
		x = $7f;	//7f=char offset
		if (($6102.x & #c0) != 0) $a622; //bne $a622
$a63a:
		jobMenu_entry();	//$962f();
		goto $a534;
	}
$a640:
	$a897();
	goto $a567;
$a646:
	//OnB (closeMenu)
	$a685();
	$2001 = 0;
	$a654();
	return $8f58();
}
```



