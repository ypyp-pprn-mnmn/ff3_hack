
# $35:b4f7 itemWindow_OnUse



### local variables:
+	u8 $26 : offsetToSelectedItem
+	u8 $27 : idOfSelectedItem

### notes:
(see also itemWindow_OnA)

### (pseudo-)code:
```js
{
$b4f7:
	a = $63 << 3;	//$3f:fd3f();
	a += $62 + $62;
	$26 = x = a;	//a:2*(col*4+row)
	a = $7af5.x	//items[selectedIndex].id
	if (a == 0) {	//空欄を選択決定した
$b509:
		setYtoOffset2E();	//$34:9b9b();
		$5b[y] = 0;
		requestSoundEffect06();	//set$ca_and_increment_$c9(#6);	//$34:9b81();
		return itemWindow_InputLoop;	//$aeaa
	}
$b516:
	push a;
	requestSoundEffect05();	//set$ca_and_increment_$c9(#5);	//$34:9b7d();
	pop a; push a;
	setYtoOffset2E();	//$34:9b9b();
	pop a; push a;
	$5b[y] = a;	//item id
	//potion,high potion,elixir
	if (a == #a6 || a == #a7 || a == #a8) { $7ce8 = a = #ff; }
	y -= 2;
	$5b[y] |= 8;	//'use item' flag
	$27 = pop a;	//item id
$b53f:
	if (a >= #c8) $b509;
	if (a < #98) {
		if (a >= #57) $b509;
		//itemid:[00-56]
		loadTo7400FromBank30(index:$18 = a,size:$1a = 8,base:$20 = #9400,dest:x = #78);	//$ba3a
$b55e:
		y = $747c;	//itemparam.+04
		//clc bcc $b58b;
	} else {
$b564:	
		//itemid:[98-c7]
		push (a = $7400);
		copyTo7400(bank:a = #17,base:#91a0 + (a - #98), size:$4b = 1, restore:$4a = #1a):	//$fddc
		y = $7400;
		$7400 = pop a;
	}
$b58b:
	//here y: effect type?
	//equip=itemparam.+04; item=consumeParam(91a0+a-#98)

	x = a = $63 << 2 + $62;	// (col*4) + row
	if ((a = $7b3d.x) == 0) goto $b509;	//flag (0=disallowed to use)
$b59c:
	if (y == #7f) { //bne $b5a7
$b59e:	
		$747d = #9;	//itemparam.+05
		//bne $b5ba;
	} else {
$b5a7:	
		//$30:98c0 = magicParams
		loadTo7400FromBank30(index:$18 = y, size:$1a = 8, base:$20 = #98c0, dest:x = #78);
	}
$b5ba:
	//itemの対象を決定、必要($748d&#18 != 0) ならプレイヤーに入力させる (2 == cancel)
	setItemEffectTarget();	//$35:b979()
	if (a == 2) {
		$52--;
$b5c3:		closeItemWindow();	//$b1b0
	}
$b5c6:
	setYtoOffsetOf(a = #3f);	//$34:9b88
	$5b[y] = $27;	//item id
	if ((a = $63) == 0) {	//bne $b5d8
		y--;
		$5b[y] = 1;	//selected item is equipment
	}
$b5d8:
	x = $26;	//$26: 2*(col*4+row)
	x++;
	if ((a = --$7af5.x) == 0) { //bne b5e9
		//アイテムを消費したら無くなったので空欄にする
		x--;
		$7af5.x = 0;	//
	}
$b5e9:
	for (x = 0;x != 0x40;x++) {
		$60c0.x = $7afd.x;
	}
$b5f6:
	closeItemWindow();	//goto $b1b0;
$b5f9:
}
```



