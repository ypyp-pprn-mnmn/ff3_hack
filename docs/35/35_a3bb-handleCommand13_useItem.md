
# $35:a3bb handleCommand13_useItem

<summary></summary>

## (pseudo-)code:
```js
{
	push (a = $1a);
	if (a != #a9) { //beq a3cf
		if ( (a != #aa) //bne a3cc
		   ||  ($70[y = #1] < 0) ) //bpl a3cf
		{
$a3cc:
			$a3d7();
		}
	}
$a3cf:
	$1a = pop a;
	$cc++;
	return dispatchBattleFunction_04();	//jmp $8022
}
```



