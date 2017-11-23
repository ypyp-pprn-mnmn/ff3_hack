
# $30:9e8a doFight


>たたかう (dispId : 3)


### notes:
指定された攻撃側と防御側のパラメータを元に打撃の計算処理を行う
二刀流の場合はそれぞれ別個に計算し最後に足し合わせる
分裂処理もダメージ確定後行う
プレイヤー側で一人でも逃げるを試行した者がいる場合一時的に溜めている扱い
+	各パラメータを変化させる条件:
	-	攻撃側:
		-	小人か蛙: 攻撃力1
		-	対象が溜めている: 攻撃力2倍(精度16bit)
		-	自身が後列: 命中率半減
		-	対象が後列: 命中率半減
		-	暗闇: 命中率半減
	-	防御側:
		-	小人か蛙か溜めている: 防御力0，防御回数0
		-	暗闇: 回避率半減
		-	防御中: 防御力2倍(精度8bit，128以上なら255)
		-	後列: 防御成功回数1回増加

### args:
+	[in] u16 $6e : attackerPtr
+	[in] u16 $70 : targetPtr

### local variables:
+	u8 $7c : hit count (1st)
+	u8 $7d : hit count (2nd/temp)
+	u8 $bb : total hit count
+	u8 $741f : count of attacking hand
+	u8 $7440[10] : attacker's attack properties(left/right)
+	u8 $7420[5+3] : defence properties ?
+	u8 $e0[2][$64] : target status
+	u8 $f0[2][$62] : actor status
+	u8 $7ce4[4] : target defend flag (1=defending)
+	u8 $78ee : in-battle event queue count ?
+	u8 $78da[] : in-battle event queue ?

### (pseudo-)code:
```js
{
	cacheStatus();//$31:a2ba();
	x = $64;
	a = $e0.x & #c0;
	if (0 == a) {
		x++;
		a = $e0.x & 1;
		if (0 == a) { goto $9ed5; }
	}
$9e9f:	//死んでるか石化かジャンプ中
	y = #30;
	a = $6e[y];
	if (a < 0) {
		//target:enemy party
		$22 = #$7675;
		a = 7;
		$31:a300();
		goto $9ed2;
	} else {
$9eb5:
		//target:player party
		$22 = #7575;
		a = 3;
		$a300();
		if (0 != $69) {// beq $9ed2
			$7ec2 = x = 0;
			$78d8 = --x;
			goto $a264;
		}
	}
$9ed2:
	cacheStatus();//$31:a2ba();
$9ed5:
	$7ee1 = x = #ff;
	$42 = $6b = $6a = $741e = $7d = $7c = $7ce9 = ++x;
	$741f = ++x;	//1
	y = 3;
	$3c,3d = $70[y];	//target.hp
	$40,41 = $6e[y];	//actor.hp
	//if ( getActor2C() < 0
	//	|| (($74 != 0) && (getTarget2C() >= 0) && 
	if (getActor2C() < 0) {	//msb==1
		//敵
		if (0 != (a = $74) ) {	//$74 = escape count
			if (getTarget2C() >= 0) {//$31:bc25()
$9f10:
				$70[y = #27] += 1;
				if (a != 0) $9f40; // //bne $9f40
			}
		}
	} else {
$9f1b:
		a = $6e[y = #31];
		if (a < 0) $9f37;	//bmi	//80:盾
$9f21:		if ((a & 1) == 0) $9f37; //beq	//01:片手武器flag
$9f25:
		a = $6e[++y];
		if (a < 0) $9f37;
		if ((a & 1) != 0) {	//beq $9f37;
$9f2e:		//両手が素手or両手が片手武器
			$741f++;
			$741e++;
			goto $9f40:
		}
$9f37:
		a = $6e[y = #31] | $6e[++y];
		if (a == 0) $9f2e;
	}
$9f40:
	y = #16;
	for (x = 0;x != 0xa;x++) {
		$7440.x = $7420.x = $6e[y++]; //atk (left/right)
	}
	for (x;x != 0xf;x++) {	//x:a-f
		$7420.x = $70[y++];	//def
	}
	y = #27;
	for (x;x != 0x12;x++) {	//x:f-12
		$7420.x = $6e[y++];	//$742f~7431 = 27,28,29
	}
$9f6a:	//for($741f-;$741f!=0;$741f--){ //$a15a
	$24,25 = $7441,7442;
	x = $62;	//attackerIndex*2
	a = $f0.x & 4;	//4=status.blind
	if (a != 0) {
		$25 >>= 1;
	}
$9f7e:
	if (0 == (a = $6e[y = #33]) & 4) {	//04:両手遠距離フラグ(竪琴か矢がある弓ならset)
		a = $6e[y = #2c];
		if (a >= 0) {
			//味方
			isRangedWeapon();	//$31:a397();
			if (carry) goto $9fa6;
		}
$9f91:
		a = $6e[y = #33] & 1;	//後列判定?
		if (0 != a) {
			$25 >>= 1;
		}
$9f9b:
		a = $70[y] & 1;		//後列判定?
		if (0 != a) {
			$7ce9++;
			$25 >>= 1;
		}
	}
$9fa6:
	$7c = getNumberOfRandomSuccess(try:$24, rate:$25);	//$31:bb28(); $24=回数,$25成功率
//
	$24,25 = $742b,742c;	//def,evade
	x = $64;		//targetIndex*2
	a = $e0.x & 4;		//target.status0.blind
	if (a != 0) { //beq 9fbf
		$25 >>= 1;
	}
$9fbf:
	//if (($e0.x & #28) == 0) {//bne 9fcb
	//	if ($70[y = #27] == 0) beq 9fcf
	//}
	if (($e0.x & #28) != 0 || $70[y = #27] != 0) {
$9fcb:
		$24 = 0;	//対象が蛙か小人か溜めている
	}
$9fcf:
	getNumberOfRandomSuccess(try:$24, rate:$25 );	//$bb28();
	if ((a = $7ce9) != 0) { //beq $9fd9;
		$30++;	//防御側が後列なら防御成功回数1回保証
	}
$9fd9:
	$7c = $24 = a = atkCount - defCount > 0 ? atkCount - defCount : 0;//$7c=atkcount $30=defcount
	if (a == 0) {	//miss!
		//carry:0
		$6e[y = #27] = 0;
		goto $31:a139;
	}
$9ff1:	//hit!
	a = $70[y = #12] & $7440;	//$70[12]:防御側弱点属性 $7440:攻撃属性
	if (0 != a) {
		a = 4;
	} else {
$9ffe:
		a = $742a;	//$742a:耐性属性
		if (a != 2) {
			a &= $7440;
			if (a == 0) {
$a00e:
				a = 2;
				goto $a010;
			}
		}
$a00a:
		a = 1;
	}
$a010:
	$27 = a;	//耐:1 普:2 弱:4
	$2b = x = 0;
	$2a = ++x;	//=1
	$28 = $7431;	//=$6e[#29]
	$29 = a = 0;
	$25 = $7443;	//atk
$a027:
	if (getActor2C() >= 0) { //$a2b5
		addValueAtOffsetToAttack(y = #38);	//y = #38; $a389();
		addValueAtOffsetToAttack(++y);	//y++; $a389();
	}
$a035:
	$26 = $742d;	//def
	if (getTarget2C() >= 0) {	//$bc25
$a03f:
		x = a & 7;
		//防御中なら$26(防御)2倍(128以上なら255)
		if ($7ce4.x != 0) { //beq a055
$a047:
			if ($26 >= #80) { //bcc $a053
$a04d:
				$26 = #ff;
			} else {
$a053:
				$26 <<= 1;
			}
		}
	}
$a055:
	a = $f0.(x = $62) & #28; //actor.status0 & toad|minimum
	if (a != 0) { //beq a061
		$25 = 1;
	}
$a061:
	a = $e0.(x = $64) & #28; //target.status0 & toad|minimum
	if (a != 0 || $70[y = #27] != 0) {
$a06f:
		$25,2b <<= 1;
		$26 = 0;
	}
$a077:
	getRandom(#63);//$beb4()
	if (a < $7430) { //$7430 = $6e[#28]
		$29++; $cb++;
	}
$a085:
	x = $62;
	a = $f0.x & 0x28;
	if (0 != a) {
		$cb = $29 = 0;
	}
$a093:
	calcDamage();	//$31:bb44(); result:$1c,1d
	if ($29 != 0) {
		x = $78ee;
		$78da.x = #34;	//critical hit!
		$78ee++;
	}
$a0a5:
	a = $6e[y = #27];
	if (0 != a) {
		x = a;x++;
		$18 = x;
		$19 = $6e[y] = a = 0;
		$1a,1b = $1c,1d;
		mul16x16();	//$3f:fcf5
	}
$a0c0:
	if ($1c,1d == 0) { $1c++; }
$a0c8:
	$78,79 = $1c,1d;
	$24,25 = $70,71;
	y = #12; a = $7440 & 1;
	if (a != 0) { //吸収属性あり
		isTargetWeakToHoly();	//$bbe2();
		if (!carry) { 
			sumDamageForDisplay(damage:$78);	//$a368();
		}
		getTarget2C();	//$bc25();
		$18 = a & 0x87;
		getActor2C();	//$a2b5();
		a &= 0x87;
$a0f7:
		if (a != $18) {	//target!=actor
$a0f9:
			spoilHp();	//$bd67();
			goto $a10d;
$a10d:
			a = $26;
			if (a == 0) goto $a129;		//both target and actor alive
			else if (a < 0) goto $a11e;	//actor dead
			goto $a113;	//target dead
		}
	} else {
$a0ff:
		$26 = 0;
		sumDamageForDisplay();//$a368();
	}
$a106:
	damageHp();	//$bcd2();
	if (!carry) {
$a113:		//dead
		$e0.(x = $64) |= #80;
		goto $a139;
$a11e:
		$f0.(x = $62) |= #80;
		goto $a139;
	} else {
$a129:		//alive
		a = $7ed8;
		if (a >= 0) {
			a = $6e[y = 1] & 0x28;
			if (0 == a) {
				checkStatusEffect();//$31:be14();
			}
		}
	}
$a139:	//hit数0(=ミス)ならここまで飛んでくる
	a = --$741f;
	if (0 != a) {
		for (x = 0;x != 5;x++) {
			$7440.x = $7425.x;
		}
		$7d = $7c; 
		$79 = $78 = $7c = 0;
		goto $9f6a;
	}
$a15d:
	a = $741e;	//二刀流なら1(両手が素手/両手が片手武器)
	if (0 != a) {
		push (a = $7c);
		$7c = a = $7d;
		$7d = pop a;
	}
$a16c:
	y = $64;
	$bb = a = $7c;	//hit count (1st hand)
	a |= $7d;
	if (a == 0) { //bne a184
		$7e4f.y = $bc = a;
		y++;
		$7e4f.y = #40;	//miss
		//goto $a264;
	} else {
$a184:
		$bc = $7d;	//hit count (2nd)
		$78,79 = $6e[y = #3],$6e[++y];	//actor.hp
		x = $62;
		getActor2C();	//$a2b5();
		$18 = a & #87;
		if (($70[y] & #87) == $18) beq $a203;
$a1a4:
		if ($40,41 >= $78,79) { //bcc $a1da;	//actorHpBeforeAttack >= actor.hp
$a1af:
			$7e5f.x = ($40,41 - $78,79);
			a = ($6e[y = #16] | $6e[y = #1b]) & 1;	//左手と右手の攻撃属性
			if (a == 0) beq $a1d7;
$a1cf:
			$78da.(x = $78ee) = #27;	//"HPをぎゃくにすいとられた!"
$a1d7:
			//goto $a203;
		} else {
$a1da:			//攻撃者のHPが攻撃前より増えている
			$7e5f.x = ($78,79 - $40,41) | #8000;
$a1ec:
			getActor2C();	//$a2b5();
			if (a >= 0) { //bmi $a1fb
				$78da.(x = $78ee) = #25; //"HPをきゅうしゅうした!"
			} else {
$a1fb:
				$78da.(x = $78ee) = #26; //"HPをすいとられた!"
			}
$a203:		}
		$43 = 0;
		a = $78da.(x = $78ee);
		if (a != #ff) {
			$43++; $78ee++;
		}
$a216:
		x = $62;
		a = ($7e5f.(++x) & #7f) | $7e5f.(--x);
		if (a == 0) { //bne $a23c
$a224:
			$7e5f.x = #ffff;
			if ($43 != 0) {
				x = --$78ee;
				$78da.x = #ff;
			}
		}
$a23c:
		x = $64;
		if ($42 != 0) { //beq $a259
			$7e4f.x = ($70[y = 3,4] - $3c,3d) | #8000;	//$3c: targetHpBeforeAttack
			//bne a264 (always satisfied)
		} else {
$a259:
			$7e4f.x = $6a,6b
		}
	} //$7c | $7d == 0 (whether miss or not)
$a264:
	//$74:count of char who try to escape
	if ($74 != 0) { //beq a288
		if (getActor2C() < 0) {	//bpl a288
			//secが無い
			//ミスの場合最後にcarryに影響を与えるのは$9fdc
			//$9fdcは攻撃成功回数から防御成功回数を引いている
			//よってミス(命中回数0= 攻撃成功回数<=防御成功回数)の場合
			//carryはクリアされていることがある(その結果1余計に引く)
			//
			$70[y = #27] -= 1;	
			if ($7c != 0) { //beq a288
				$78da.(x = $78ee) = #55; //"にげごしで ぼうぎょできなかった!"
				$78ee++;
			}
		}
	}
$a288:	
	if (getActor2C() < 0) return getActor2C();//bmi a2b5
$a28d:
	checkSegmentation();	//$bf53();
	//if ((a = $6e[y = #31]) >= 0) {	//bmi a29a
	//	if ((a & 1) == 0) { //bne a2a6
	if ((a = $6e[y = #31] < 0)
		|| (a & 1) != 0)
	{
$a29a:
		if ($7d == 0) {
$a29e:
			$bc = $7c;
			$bb = 0;
		}
	}
$a2a6:
	a = $6e[y = #33] & 4;
	if (a != 0) {
		$bb = $7c + $7d;
	}
$a2b5:
	return getActor2C(); //fall through
}
```



