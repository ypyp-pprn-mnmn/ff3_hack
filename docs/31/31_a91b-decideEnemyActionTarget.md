
# $31:a91b decideEnemyActionTarget

<summary></summary>

## (pseudo-)code:
```js
{
	$46 = a;
	$18 = a & #7f;
	loadTo7400Ex(index:$18, size:$1a = 8, base:$20 = #98c0
		, bank:a = #18, dest:x = 0, restore:y = #18); //fda6
	a = 0;
	for (x = 7; x >= 0; x--) {
		$62.x = a;
	}
	if ($7405 < 0) $a9b8;	//bmi; actionParam[5]
$a943:
	if ($53 != 0) $a9b8;	//bne; confuse flag
$a947:
	if (($7405 & #40) == 0) $a975; //beq
$a94e:
	$63 = a;
$a950:
	for ($64; $64 != 4;$64++) {
		a = $64;
		isValidTarget();	//$a9f7();
		if (notEqual) $a960 //bne
$a957:
		a = $62;
		$62 = flagTargetBit(x = $64);
$a960:
	}
$a968:
	if ($62 == 0) { //bne a96e
		$69++;
	}
$a96e:
	$62 = #f0
	goto $a9eb;
$a975:
	if ($46 < 0) { //bpl $a97d
		lda #40;
		goto $a94e;
	}
$a97d:
	$22 = getRandom(a = 3); //beb4
	do {
$a984:
		a = getRandom(a = 3);
	} while (a == $22); //beq a984
$a98d:
	x = a;
	$65.x = 1;
	push (a = x);
	isValidTarget();	//$a9f7();
	if (notEqual) { //beq a9ac
$a999:		pop a;
		a = $65+$66+$67+$68;
		if (a != 4) goto $a975; //bne
$a9a7:
		$69++;
		goto $a9b5;
	}
$a9ac:
	x = pop a;
	a = $62;
	$62 = flagTargetBit(x); //fd20
	goto $a9eb;
$a9b8:	//confused || (actionparam[5] < 0)
	$63 = #80;
	if (($7405 & #40) == 0) $a9ce;
$a9c3:
	$63 |= a;	//action to all
	$62 = #ff;	//set all target
	goto $a9eb;
	do {
		do {
$a9ce:
			a = getRandom(a = #0c);	//beb4
		} while (a < 4) ; //bcc $a9ce
		$22 = a;
		isValidTarget();	//$a9f7();
	} while (notEqual); //bne $a9ce
$a9de:
	x = $22 - 4;
	a = $62;
	$62 = flagTargetBit(x);	//fd20
$a9eb:
	$24[y = #2f] = $62;	//target
	$24[++y] = $63;		//action target flag
	return;
}
```



