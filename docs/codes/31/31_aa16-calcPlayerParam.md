
# $31:aa16 calcPlayerParam()



>dispatchId : 5


### args:
+ [in] u16 $57 : playerBaseParam(=$6100)
+ [in] u16 $59 : playerEquips(=$6200)
+ [in] u16 $5b : playerBattleParam(=$7575)
+ [in] u8 $52 : playerIndex
	-	アイテムをキャンセルした場合	: 該当キャラ
	-	装備を変えた場合		: 該当キャラ
	-	使用した場合			: 次のキャラ 
		-	(もし4番目のキャラの場合4,有効なindexは00-03hなのでバグだが運よく各構造体のサイズが40hのため1番目のキャラのアドレスにループする)

### notes:
>属性ボーナスが適用されないのはこの関数が正しくフラグを設定しないせい

### local variabless:
+ u8 $24[5] : equips (head,body,wrest,right,left)
+ u8 $7433[5] : equips
+ u8 $2c[5] : baseParams (str,agi,vit,int,men)
+ u8 $7400[8][5] : equipParams ( head, body, accessory, right, left )
+ WeaponType $48[2] : {right, left}
	(80:盾 08:竪琴 04:矢(弓装備時) 02:弓(矢装備時)  01:片手武器 00:それ以外)

### (pseudo-)code:
```js
{
	y = updateBaseOffset();	//$31:be90(); //$5f = a = $52 << 6
	for (x = 0;x != 6;x++) {
		$24.x = $742f.x = $59[y++];
	}
	for (x = 2;x >= 0;x--) {
		if (0 == (a = $24.x) ) {
			$24.x = #57;
		}
	}
	$7433 = $28 = $29;
	$48 = $49 = 0;
	//$27:equips+3 (righthand)
	//$28:equips+5 (lefthand)
	if (0 == (a = ($27 | $28)) ) {
		a = 0;
		//goto $ab0a;
	} else {
$aa4e:
		if (0 == $27) {	
			if ($28 < 0x46) {a = 2; $49 = 1;}	//[00-46) 46:マドラの竪琴
			else if ($28 < 0x4a) {a = 4; $49 = 8;}	//[46-4a) 4a:ゆみ
			else if ($28 < 0x4f) {a = 2; $28 = 0;}	//[4a-4f) 4f:きのや
			else if ($28 < 0x58) {a = 2; $28 = 0;}	//[4f-58) 58:かわのたて
$aa88:			else {
				$49 = #80;
				a = 2;
			}
		} else {
$aa90:			
			if ($27 >= #46) aaae;
				$48 = 1;
				if ($28 == 0) aaaa;
$aa9c:
					if($28 >= #58) aaa6;
						$49 = 1;
						goto aaaa;
$aaa6:
			$49 = #80;
$aaaa:			a = 2;
			goto $ab0a;
$aaae:
			if (a >= #4a) aaba;
				//[46-4a):竪琴
				$48 = 8;
				a = 4; goto $ab0a;
$aaba:
			if (a >= #4f) aad6;
				if ($28 == 0) $aace;
$aac2:
					$48 = 2;	//弓
					$49 = 4;	//矢
					a = 6; goto $ab0a;
$aace:
				$27 = 0;	//弓だけど他方が素手
				a = 2; goto $ab0a;
$aad6:
			if (a >= #58) $aaf2;
				//矢
				if ($28 == 0) $aaea;
$aade:
					$48 = 4;	//矢
					$49 = 2;	//弓
					a = 6;goto $ab0a;
$aaea:
			//矢で他方が素手
				$27 = 0;	
				a = 2; goto $ab0a;
$aaf2:
			$48 = #80;
			if ($28 == 0) $ab08;
$aafa:
				if ($28 >= #58) $ab04;
					$49 = 1; goto $ab08
$ab04:
				$49 = #80;
$ab08:
			a = 2;
		}
	}
$ab0a:
	push a;	//素手0 片手2 竪琴4 弓(矢装備時)6
	$7570,7571 = x = 0;
	for ($7570 = 0;$7570 != 5;$7570++) {
$ab13:		$20 = #$9400;
		x = $7570;
		$18 = $24.x;
		$1a = 8;
		x = $7571;
		y = a = #18;
		loadTo7400Ex(index:$18, size:$1a, base:$20
			, bank:a, dest:x, restoreBank:y); //$3f:fda6();
		$7571 = x;
	}
	for (x = 0x13;x >= 0;x--) {
		$34.x = 0;
	}
$ab45:
	a = ($7406 | $740e | $7416 | $741e | $7e26) & 7;	//属性ブースタ
	$24 = a << 5;	//$3f:fd3d();
	setYtoOffsetOf(a = #f) ;	//$31:be98(); //{ y = a + $5f }
	$59[y] = $59[y] & #f9 | $24
	setYtoOffsetOf(a = #12);	//$31:be98();
	for (x = 0;x != 5;x++) {
		$2c.x = $57[y++];
	}
$ab79:
	addItemBonus($7406);	//$31:af63($7406);
	addItemBonus($740e);	//$31:af63($740e);
	addItemBonus($7416);	//$31:af63($7416);
	addItemBonus($741e);	//$31:af63($741e);
	addItemBonus($7426);	//$31:af63($7426);
$ab97:	//here y = #17
	for (x = 0;x != 5;x++) {
		if (99 >= (a = $2c.x) ) {
			a = 99;
		}
		$7428.x = $57[y] = a;
		y++;
	}
$abac:
	pop a; //装備武器で振り分けた値
	$32 = a;
	$38 = ($741f >= 0) ? $7418 : 0;
	$3d = ($7427 >= 0) ? $7420 : 0;
	y = $5f + 1;
	$742e = a = $57[y];	//Lv
	$26 = a >> 4;		//$3f:fd45() { a >>= 4; }
	a = $7429 >> 4; //$7429 = param[1] = agi
	$3e = $39 = $26 + a + 1; //sec adc$26
	y = $5f + #10; //be98();
	$742d = a = $57[y]; //joblv
	$25 = a = a >> 2; //fd47();	
	$24 = a = $7429 >> 2;	//agi
$abfc:
	a = $32 & 6;
	if (a == 6) {
		//bow & arrow set
		a = $48 & 2;
		if (a != 0 && $7419 != 0) {
			a = $7419;
		} else {
$ac0f:
			a = $7421;
		}
		a += $24 + $25; //agi/4 + joblv/4
	} else {
$ac25:
	}
	//...
$ac55:
	setYtoOffsetOf(a = #38);
	$5b[y] = $741d & #7f;	//righthand.param[5]
	$5b[++y] = $7425 & #7f;	//lefthand.param[5]
$ac69:
	if ( ($57[y = $5f] == #02 //beq ac76
		|| $57[y] == #0d ) //bne aca2
$ac76:		&&  (($32 & #06) == 0) ) //bne aca2
	{  	//モンクor空手家 and 素手
$ac7c:
		$24 = $7428 >> 2;	//fd47
		$25 = $742e >> 1 + $742e;
		$40 = $3b = $24 + $25 + $742d >> 2;	//fd47
		//jmp $ad3d
	} else {
$aca2:
		//...
	}
$ad3d:
	if ( ($39|$3a|$3b) == 0 ) { //bne ad59
$ad45:
		$39,3a,3b = $3e,3f,40;
	}
$ad59:
	if ( $48 >= 0 ) { //bmi ad62
		$3c = $741b;
	}
$ad62:
	if ( $49 >= 0 ) { //bmi ad75
$ad66:
		$41 = $7423;
		if ( ($49 & #08) != 0) { //beq ad75
$ad71:
			$3c = $41;
		}
	}
$ad75:
	if ( ($32 & #06) == #06 ) { //bne ad89
$ad7d:
		$38 |= $3d;
		$3c |= $41;
	}
$ad89:
	//a = $32 & 6
	setYtoOffsetOf(a); //be98;
	for (x = 0;x != 2;x++) {
$ad8e:
		$24.x = $5b[y++];
	}
$ad98:
	//....
$ae30:	//calc physical evade.
	$24 = $25 = 0;
	if ( $48 <= 0) { //bpl ae3f
$ae3a:
		$24 = $7419; //righthand.+01 (hit/evade)
	}
$ae3f:
	if ( $49 <= 0) { //bpl ae48
$ae43:
		$25 = $7421; //lefthand.+01 (hit/evade)
	}
	a = shiftRight2(a = $7429); //fd47
	a += $24 + $25 + $7401 + $7409 + $7411;
	$44 = a <= 99 ? a : 99; //bcc ae62
$ae64:
	//...
$af11:
	setYtoOffsetOf(a = #f);//be98
	push (a = $59[y] & #1 | $32);	//59:pEquips
	$59[y] = a;
	setYtoOffsetOf(a = #33);
	$5b[y] = pop a;
$af27:
	setYtoOffsetOf(a = #12);
	for (x = 0; x != #14;x++) {
$af2e:
		$5b[y] = $34.x;	//5b = $7575 (battleChar*)
		push (a = y);
		y = a + #a;
		$57[y] = $34.x;	//57 = $6100 (fieldChar*)
		y = pop a;
		y++;
	}
$af44:
	//...
$af54:
	setYtoOffsetOf(a = #31);	//be98
	$5b[y] = $48;	//片手武器01 竪琴08 盾80 弓02 矢04
	$5b[++y] = $49;
$af62:
}
```



