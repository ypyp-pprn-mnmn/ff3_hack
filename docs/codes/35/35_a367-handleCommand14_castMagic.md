
# $35:a367 handleCommand14_castMagic



### (pseudo-)code:
```js
{
	a = $1a;	//actionid
	push a; push a;
	a = getActor2C() & 0x10;	//a42e()
	if (a != 0) {	//"enemy action"flag
		$78d7 = 0x80 | $1a;
	} else {
$ae7b:
		pop a;
		a = $1a - #c8;
		push a;
		$78d7 = 0x80 | a;
	}
$ae87:
	pop a;//actionid
	switch (a) {
	case 0x04:	//アレイズ
	case 0x19:	//レイズ
		goto $a3a1;
	case 0x12:	//ストナ
	case 0x0b:	//エスナ
		goto $a398;
	default:
		goto $a39e;
	}
$a398:
	a = $70[y = 1];
	if (a < 0) {
$a39e:
		$35:a3d7();
	}
$a3a1:
	$1a = pop a;//action id
	$78d5 = a = 1;	//commandListId(1 = magic)
	a = $78d9;
	if (#ff != a) {
		$78d7 = a;
		$78d9 = #ff;
	}
$a3b8:	
	return dispatchBattleFunction_00();	//doSpecialAttack jmp $34:8012()
}
```



