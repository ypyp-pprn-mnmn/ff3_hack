
# $35:aa22 commandWindow_0b_geomance



>0b: ちけい


### (pseudo-)code:
```js
{
	setYtoOffset2E();	//9b9b
	$5b[y] = #0b;
	getCurrentTerrain();	//$aac3();
	x = a - #50;
	x++;
	a = $ab06;
	for (x;x != 0;x--) {
$aa34:
		a <<= 1;
	}
	if (carry) { //bcc aa44
		dispatchBattleFunction_06();	//$802a();	//getrandomtarget?
		a = $7e99;
		x = #80
	} else {
$aa44:
		a = #ff;
		x = #c0;
	}
$aa48:
	push a;
	setYtoOffset2F();	//9b94
	$5b[y] = pop a;
	$5b[++y] = x;
	return getCommandInput_goNextCharacter();	//jmp aa56
$aa56:
}
```



