
# $31:a732 decideEnemyAction

<summary>dispid:2 [battleFunction02]</summary>

## args:
+ [in,out] u8 $78b7 : special sequence
+ [in] u8 $7be2 : some  flag (checked to do barrier-change)
+ [in] u8 $7d6b : group to id map
+ [in] u8 $7da7 : index to group map
+ [in] u8 $7ed8 : battle mode ? (<0 = use specials sequencially)
## local variables:
+	u8 $53 : confused flag
+	ptr $24 : current enemy
## (pseudo-)code:
```js
{
	$69 = 0;
	for ($4a = 0;$4a != 8;$4a++) {
$a738:
		$53 = 0;
		calcDataAddress(index:$18 = $4a, size:$1a = #40, base:$20 = #7675);	// $31:be9d();
		$24,25 = $1c,1d;
		$24[y] = get24_2C() & #ef;	//a8c8
		$24[y = #2f] = 0;
		$24[++y] = 0;
		if ( ($24[y = 1] & #e8) == 0) $a774 //beq
$a76f:
		//[dead|stone|toad|minimum]
		a = 0;
		goto $a8b9;
$a774:
		if ( (a = ($24[++y] & #e0)) == 0) $a789 //beq
$a77b:		//[paralyze|sleep|confuse]
		if (( a & #20) == 0) $a784 //beq
$a77f:
		//[confuse]
		$53++;
		goto $a7c5
$a784:		//[paralyze|sleep]
		a = 1;
		goto $a8b9;
$a789:	//not dead|stone|toad|minimum && paralyze|sleep|confuse
		if ($7ed8 < 0) $a7c5 //bmi
$a78e:
		for (x = 0,y = 0;x != 4;x++) {
$a792:
			$28.x = $5b[y];
			y += #40;
		}
$a7a0:
		getHighestLvInPlayerParty();	//$a8ec();
		a = $24[y = 0] + #0f;
		if (a >= $28) $a7c5;	//bcs
		if (($7ed8 & 1) != 0) $a7c5; //bne
		a = getRandom(a = #64);	//$beb4
		if (a < $24[y = #22] ) $a7c5;	//bcc
$a7c0:
		a = 6;	//逃げる
		goto $a8b9;
$a7c5:		// normal/confuse
		x = $7da7.(x = $4a);
		a = $7d6b.x;
		if (a == #d2) $a7d6;	//d2:まどうしハイン
		if (a != #b4) $a7e9;	//b4:アモン
$a7d6:	//[#d1 || #b4]
		if ($7be2 != #2) $a7e9;
$a7dd:
		$24[y] = get24_2C() | #10;	//a8c8
		a = #4d;	//4d:バリアチェンジ
		goto $a8b9;
$a7e9:
		a = $24[y = #37];	//37:special rate
		if (a == 0) $a7fd;
		a = getRandom(a = #64);	//beb4
		if (a >= $24[y]) $a7fd;	//bcs
		goto $a85f;
$a7fd:		//[random not satisfied rate]
		if ($53 == 0) $a809;	//$53:confuse flag
		$a8cd();
		a = 4;	//たたかう
		goto $a8b9;
$a809:		//random not satisfied special rate & not confused
		a = 0;
		for (x = 4;x >= 0;x--) {
$a80d:
			$65.x = a;
		}
$a812:
		$21 = 0;
		$22 = getBattleRandom(min:x, max:a = 3);	//$fbef();
$a81f:
		do {
			a = getRandom(a = 3); //beb4
		} while (a == $22); //beq $a81f;
		$52 = $22 = a;
		updateBaseOffset();	//$be90();
		y = a; y++;
		a = $5b[y] & #c0;
		if (a != 0) $a83e;
$a837:
		a = $5b[++y] & 1;
		if (a == 0) $a855;
$a83e:	//target is [dead|stone|jumping]
		x = $22;
		$65.x = 1;
		a = $65+$66+$67+$68;
		if (a != 4) goto $a812;
$a851:
		a = 0; goto $a85c;
$a855:
		a = $52;
		setEnemyTarget();	//a8e1
		a = #4; //たたかう
$a85c:
		goto $a8b9;
$a85f:	//use special
		$24[y] = get24_2C() | #10;
		if ($7ed8 >= 0 ) $a896; //bpl
$a86b:	//use in sequence
		y = ($78b7 - 1) + #38;
		push (a = $24[y] & #7f);
		a = $24[y];
		decideEnemyActionTarget();	//$a91b();
		if ($69 != 0) $a8ad;	//bne
$a883;
		if (++$78b7 == #9) { //bne a892
			$78b7 = 1;
		}
$a892:
		pop a; //action id
		jmp $a8b9;
$a896:	//use randomly
		a = getRandom(a = 7);	//$beb4;
		y = a + #38;
		push (a = $24[y] & #7f);
		a = $24[y];
		decideEnemyActionTarget();	//$a91b();
		if ($69 == 0) $a8b8; //beq
$a8ad:
		$24[y] = get24_2c() & #ef;
		pop a ;actionId
		push (a = 0);
$a8b8:
		pop a;
$a8b9:
		$24[y = #2e] = a;	//action id
	} //jmp $a738
$a8c8:
}
```


**fall through**

