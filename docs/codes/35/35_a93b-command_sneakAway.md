
# $35:a93b command_sneakAway

<summary>07: とんずら</summary>

## code:
```js
{
	$78d5 = 1;
	$78d7 = #40;
	setNoTargetMessage();	//91ce
$a948:
	if (($7ed8 & 1) == 0) $a952;	//beq
	else goto $a935;
$a952:
	for (x = 0;x != 4;x++)
$a954:
		$0052 = x;
		updatePlayerOffset();	//a541
		y = a; y += 2;
		a = $5b[y] & #20;	//confuse (02:light bad status)
		if (a != 0) $a935;
	}
$a968:
	$78da = #1e;	//"にげだした････"
	$78d3 = 2;
	$78d4 = #f0;
	return;
$a978:	//[enemy]
	$24 = $6e[y = #22];
	if ( getSys1Random(max:100) >= $24) { //bcc a98d
$a987:
		$78da = #1f;
		return;
	}
$a98d:
	$78da = #1e;
	push ( a = (getActor2c() & 7) );	//a42e
	x = a << 1;
	$f0.x |= #80;
	x = pop a;
	$78d4 = flagTargetBit(a = 0, index:x);
	return;
$a9ab:
}
```




