____________________
# $30:9e58 invokeBattleFunction
<details>
<summary></summary>

### args:
+ [in] u8 $4c : functionId
	-	0 then doAction //ex.ほのお
	-	3 then たたかう
	-	5 then recalcBattleParams (OnCloseItemWindow etc)
	-	7 then calcDataAddress($31:be9d) (OnExecuteAction)

### notes:
	least value of S = $12 = $20 - ($0a + $06) (original:$14)
		(dungeon_mainLoop - dungeon_mainLoop - beginBattle - call_doBattle - battleLoop)
			+(presentBattle - pb_disorderedShot)
			+(getPlayerCommandInput - commandWindow_OnItem)
			+(executeAction>command_fight - doCounter - command_fight_doFight)



### (pseudo-)code:
```js
{
	a = $4c << 1;
	$4c = #9e76 + a;
	$4c = *$4c;
	(*$4c)();	//funcptr
$9e76:
}
```
</details>



____________________
# $30:9e8a doFight
<details><summary>

>たたかう (dispId : 3)
</summary>

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
</details>

____________________
# $31:a2b5 getActor2C
<details>
<summary></summary>

### args:
+ [in] u16 $6e : actorPtr
+ [out] u8 A : target.+2c
+ [out] u8 Y : #2c 

### (pseudo-)code:
```js
{
	a = $6e[y = #2c];
}
```
</details>

____________________
# $31:a2ba cacheStatus
<details>
<summary></summary>

### args:
+ [in] u16 $6e : actorPtr?
+ [in] u16 $70 : targetPtr?
+ [out] u8 $(e0+id*2)[2] : status of $70
+ [out] u8 $(f0+id*2)[2] : status of $6e
+ [out] u8 $62 : ? ($6e.#2c & 7) * 2
+ [out] u8 $64 : ? ($70.#2c & 7) * 2
+ [out] u8 $66 : $6e.#2c & 7)
+ [out] u8 $68 : $70.#2c & 7)

### (pseudo-)code:
```js
{
	$66 = a = getActor2C() & 7;
	$62 = a << 1; //battleCharIndex*2
	$68 = a = $70[y] & 7;
	$64 = a << 1;

	$f0.(x = $62) = $6e[1,2]
	$e0.(x = $64) = $70[1,2];
}
```
</details>

____________________
# $31:a2e9 getRandomTargetFromEnemyParty
<details>
<summary>

>battleFunction06
</summary>

### notes:

### args:
+ [in] BattleChar *$5b : player party base
+ [in] u8 $5f : player offset (in bytes)
+ [out] BattleChar *$6e : current player
+ [out] BattleChar *$70 : randomly selected target

### (pseudo-)code:
```js
{
	$22,23 = #7675;
	$6e,6f = $5b,5c + $5f;
	a = #7;
	//fall through
}
```
</details>

**fall through**
____________________
# $31:a300 getRandomTarget
<details>
<summary></summary>

### args:
+ [in] a : maximum index (inclusive)
+ [in] ptr $22 : pTargetSideBase (= $7575 or $7675)
+ [in] BattleChar* $6e : actor
+ [out] $69 : failed (01=failed)
+ [out] BattleChar* $70 : selected target

### (pseudo-)code:
```js
{
	$4a = a;
	push (a = $1a);
	for ( a = 0,x = 4; x > 0;x--) {
$a309:
		$65.x = a;
	}
$a30e:
	do {
		$30 = getBattleRandom(a = $4a);	//$beb4();
		mul_8x8(a, x = #$40);	// $fcd6();
		$70,71 = $1a,1b + $22,23;
$a327:
		if ( 0 == ($70[y = #1] & #c0)  //bne a336
			&& 0 == ($70[++y] & 1) ) //beq a34e
		{
$a34e:
			$78d8 = getIndexAndMode(ptr : $70) & #87;//$bc25()
			flagTargetBit(a = 0, x = $30); //fd20
			$7e99 = $6e[y = #2f] = a;
			goto $a364;
		}
$a336:
		//target is ( dead | stone | jumping)
		$65.(x = $30) = 1;
	} while ( $65+$66+$67+$68 != 4 );
	$69++;
$a364:
	$1a = pop a;
	return;
$a368:
}
```
</details>


____________________
# $31:a368 sumDamageForDisplay
<details>
<summary></summary>

### args:
+	[in,out] u16 $6a,6b : resultDamage
+	[in] u16 $78 : damageToAdd

### (pseudo-)code:
```js
{
	clc;
	$6a,6b += $78,79;
	if ($6a,6b > 9999) { $6a,6b = 9999; }
}
```
</details>

____________________
# $31:a389 addToAttackOffsetOf
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$25,2b += $6e[y],0;
}
```
</details>

____________________
# $31:a397 isRangedWeapon
<details>
<summary></summary>

### args:
+ [in] u8 $741e : isDouble
+ [in] u8 $741f : countOfWeaponHand
+ [out] bool carry : ranged

### notes:
竪琴フラグがどちらかの手に立っているか
装備武器のidが3f,40,41ならtrue

### (pseudo-)code:
```js
{
	$52 = a & 7
	a = $6e[y = #31] | $6e[++y] & #08;	//08:竪琴フラグ
	if (a != 0) return true;

	y = updatePlayerOffset();	//$be90
	y += 3;
	$18 = $59[y]; y += 2;
	$19 = $59[y];
	if (($18 | $19) == 0) return false;	//beq $a3fb;
$a3bb:
	if ($741e == 0) { //bne a3de
		//二刀流でない
		if ( ((a = $18) != 0) //beq a3d2
			&& (a < #57) //bcs a3d2
		{
$a3c8:			//盾以外を右手に持っている
			if (a >= #42 || a < #3f) return false; //a3fb
			return true; //a3fe
		}
$a3d2:		//右手は盾か素手
		if ( (a = $19) >= #42 || a < #3f) return false; a3fb
		return true;
	}
$a3de:
	if ($741f == 2) { //bne a3f1
$a3e5:		//2=二刀流の最初の攻撃(=右手)
		if ((a = $18) >= #42 || a < #3f) return false;
		return true;
	}
$a3f1:
	if ((a = $19) >= #42 || a < #3f) return false;
$a3fb:
	return false;
$a3fe:
	return true;
}
```
</details>

____________________
# $31:a400 loadBattlePlayers 
<details>
<summary></summary>

### args:
+ [in] u16 $5b : playerPtr
+ [in] u16 $5d : enemyPtr?

### local variables:
+	u8 $5f : offset

### (pseudo-)code:
```js
{
	//for (x = 3;x > 0;x--) {
	//	for (y = 0;y < 0x100;y++) {
	//		$5b[y] = 0;
	//	}
	//	$5c++;
	//}
	//$5c = 75h;
	memset($7500,0,0x300);
	for($52 = 0;$52 < 4;$52++) {
a418:
		for (x = 33h;x >= 0;x--) { $18.x = 0; }

		loadPlayer(); //jsr $31:a482
		push (a);	//a = jobparam.+4

		for (x = 0,y = $5f; x < 34h; x++,y++) {
			$5b[y] = $18.x; //copy 18~4b
		}
		pop (a);
		y++;
		$5b[y] = a;	// player.+35 = jobparam.+4 ($39:bb1a.[job*5+4])
	}
a43f:
	for ($4b = 0;$4b < 8;$4b++) {
a443:
		y = $4b;
		a = $7da7.y;
		if (a == ffh) {	//敵id?
			y = 1;
			$5d[y] = a = #80;
			y = #2c;
			$5d[y] = a = ($4b | 80h);
			x = $4b;
			$7ec4.x = a;	//80|index
			if ( x == 0 ) {
				loadMobParam(); //$31:a4f6();
			}	
		} else {
			loadMobParam();	//$31:a4f6();
		}
a461:
		$5d,5e += 40h;
	}
a479:
	$5d,5e = #$7675;
}
```
</details>

____________________
# $31:a482 loadPlayer
<details>
<summary></summary>

### args:
+ [in] u8 $52 : playerIndex
+ [in] u8 $5f : offset
+ [out] u8 A : jobParam.+4 (of this player)
+ [out] u8 $18 : player.lv
+ [out] u8 $19 : player.status
+ [out] u16 $1b,1d : player.hp ,player.maxHp
+ [out] u8 $1f[8] : player.mp
+ [out] u8 $27 : player.jobLv
+ [out] u8 $40[4] : jobParam.+0~3
+ [out] u8 $44 : = $0052
+ [out] u8 $46[2] : 0

### (pseudo-)code:
```js
{
	//jsr $31:be90 { $5f = a = $52 << 6 }
	$18 = player.lv;	//+01
	$19 = player.status;	//+02
	a = #c;
	//jsr $31:be98 { Y = a + $5f }
	$1b,x  = player.hp; 	//(+0C)
	$1b,x = player.maxHp; 	//(+0E)
	$27 = player.joblevel; 	//(+10)
	Y = (#30 + $5f); //be98()
	for (x = 0;x < 8;x++,y+=2) { $1f.x = player.mp[x]; }

	a = player.job + player.job << 2; //fd40();
	$46,47 = a + #1a,#bb;	//jobは15hまでなので+#1aで桁上がりすることはない筈だが

	copyTo7400(bank:a=#1c, base:$46, restore:$4a=#18, size:$4b=5); //jsr $3f:fddc();
	//$7400~7404 = $39:bb1a.(job*5)
	for (x = 0;x < 5;x++) { $40.x = $7400.x; }

	push(a = $44);
	$44 = a = $0052;
	$46,47 = 0;
	pop(a);	//=jobParam.4
}
```
</details>

____________________
# $31:a4f6 loadMobParam
<details>
<summary></summary>

### args:
+ [in] u8 A : groupNo?
+ [in] u8 Y : enemyNo
+ [in] u8 $7d6b.x : enemyIds

### (pseudo-)code:
```js
{
	u16 base (=$30:8000)
 	mobid = $26 where $7d6b,x where x = initial A
	u16 $24 dataPtr = base + mobid * 10h
	u16 $5d destPtr = $7675 + $27 * 40h where $27 = initital Y

	dest[0x2c] = $27 | 0x80 & 0xe7
	dest[0] = data[0]	//lv
	$18 = data[1]		//hp.low
	$19 = data[2]		//hp.high
	dest[3,5] = $18
	dest[4,6] = $19	
	dest[0x37] = data[3]
	dest[0xf] = data[4]
	//jsr a614 {
		[in] u16 $24 srcPtr
		[in] u16 $5d destPtr
		[in] u8 $49 destOffset
		[in,out] u8 $4a srcOffset
		dest[$49++] = data[$4a++]
		$1c = $9000 + 3*data[$4a++]
		$18,19,1a = $1c[0,1,2]
		dest[$49++] = $18
		dest[$49++] = $19
		dest[$49++] = $1a
		dest[$49] = data[$4a++]
	}
	$4a = 0x05;
	$49 = 0x12; a614();	//mdef
	$49 = 0x16; a614();	//atk
	$49 = 0x20; a614();	//def
	dest[0x29] = dest[0x19] >> 1
	dest[0x28] = 5
	$18 = (data[7] & 0x0f)*(2+4)
	dest[0x10] = $18
	$18 = ((data[7]&0xf0)>>3)*3	//A = data[7] & 0xf0	//fd47 : A >>= 2
	dest[0x11] = $18
	
	$1c = $9200 + data[0xE] * 8	//bank:30
	for (x = 0;x < 8;x++) 
		dest[0x38+x] = $26+x = $1c[x]
	dest[0x36] = data[0xF]
	dest[0x35] = $26
	dest[0x1] = 0
}
```
</details>

____________________
# $31:a65e useItem
<details>
<summary>

>dispid:04 [battleFunction04]
</summary>

### (pseudo-)code:
```js
{
	$78d5 = #1;
	$7ec2 = #14;
	$72 = 1;
	a =$78d7 = $1a;	//actionId(=itemId)
	if (a < #98) { //bcs a69d
		//装備を使った
		mul8x8(a,x = #8)
		$1a,1b += #9400;
		a = $1a[y = #4] & #7f;
		if (a == #7f) { //bne a694
$a691:
			goto $a722;
		}
$a694:
		$1a = a & #7f;
		a = #1;
		//jmp a71b
	} else if (a < #c8) { //bcs a691
$a69d:
$a6a1:
		$46,47 = (a - #98) + #91a0;
		$4a = #18
		$4b = #01
		a = #17
		copyTo7400();	//fddc
$a6bc:
		a = $1b = $7400;
		if (a != #7f) { //beq a722
$a6c5:
			//if (($7ed8 & #10) != 0) { //beq a6d2
			//	if ($1a == #ad) goto a722; //beq a722
			//}
			if (($7ed8 & #10) == 0) || ($1a != #ad)) {
$a6d2:
				x = 0;
				while ($60c0.x != $1a) { x += 2;}
$a6df:
				x++;
				$60c0.x--;
				if ($60c0.x == 0) {
					x--;
					$60c0.x = 0;
				}
$a6ee:
				$1a = $1b;
				if ($78d7 < #a6) {//bcs $a6fd
					//a6:ポーション より前(イベントアイテム)
					a = 0; goto $a71b;	//beq
				}
$a6fd:
				$46,47 = #a35e + (a - #a6);
				$4a = #18;
				a = x = 0;
				$4b = ++x;
				copyTo7400();	//fddc
$a718:
				a = $7400;
			}
		}
	}
$a71b:
	$7c = $30 = a;
	//$1a = actionId
	return doSpecialAction();	//$af77();
$a722:
	$78d5 = 1;
	$7ec2 = #18;
	$78da = #51;	//"なにも おこらなかった"
	return;
}
```
</details>


____________________
# $31:a732 decideEnemyAction
<details>
<summary>

>dispid:2 [battleFunction02]
</summary>

### args:
+ [in,out] u8 $78b7 : special sequence
+ [in] u8 $7be2 : some  flag (checked to do barrier-change)
+ [in] u8 $7d6b : group to id map
+ [in] u8 $7da7 : index to group map
+ [in] u8 $7ed8 : battle mode ? (<0 = use specials sequencially)

### local variables:
+	u8 $53 : confused flag
+	ptr $24 : current enemy

### (pseudo-)code:
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
</details>

**fall through**
____________________
# $31:a8c8 getEffectTarget2C
<details>
<summary></summary>
//or $24_2c

### (pseudo-)code:
```js
{
	return a = $24[y = #2c];
	//ldy	 #$2c
	//lda	[$24],y
	//rts
}
```
</details>

____________________
# $31:a8cd setRandomTargetFromEnemyParty
<details>
<summary></summary>

### args:
+ [in] BattleChar *$24

### (pseudo-)code:
```js
{
	$24[y = #30] = #80;
	do {
$a8d3:
		x = getBattleRandom(a = #07);	//beb4
	} while ( $78d7.x == #ff);
$a8e0:
	a = x;
	//fall through
}
```
</details>

____________________
# $31:a8e1 setEnemyTarget
<details>
<summary></summary>

### args:
+ [in] x : index of target
+ [in] BattleChar* $24

### (pseudo-)code:
```js
{
	x = a;
	a = 0;
	flagTargetBit(a,x);	//$fd20
	$24[y = #2f] = a;
	return;
}
```
</details>

____________________
# $31:a91b decideEnemyActionTarget
<details>
<summary></summary>

### (pseudo-)code:
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
</details>

____________________
# $31:a9f7 isValidTarget
<details>
<summary></summary>

### args:
+ [in] u8 a : targetIndex
+ [out] bool zero : (1:valid, 0:invalid(dead|stone|jumping) )

### (pseudo-)code:
```js
{
	$18 = a;
	calcDataAddress(index:$18, size:$1a = #40, base:$20 = #7575);	//$be9d();
	if (($1c[y = 1] & #c0) == 0) { //bne aa15
		a = $1c[++y] & 1;
	}
$aa15:
	return;
$aa16:
}
```
</details>

____________________
# $31:aca2
<details><summary></summary>

### args:
+ [in] u16 $57 : playerBasePtr ($6100)
+ [in] u16 $59 : playerEquipBasePtr ($6200)
+ [in] u16 $5b : battleParamBasePtr ($7575)

### (pseudo-)code:
```js
{
$31:aeed
	$37 = $7404 + $740c + $7414;
	if (0 <= (a = $48)) { $37 += $741c; }
$af05:	if (0 <= (a = $49)) { $37 += $7424; }
$af11:
	setYtoOffset(#0f);
	a = $59[y] & 1 | $32;
	push (a);
	$59[y] = a;
	setYtoOffset(#33);
	$5b[y] = pop a;
	setYtoOffset(#12);
	for (x = 0;x != 0x14;x++) {
		$5b[y] = a = $34.x;
		push (a = y);
		a += 10; y = a;
		$57[y] = a = $34.x;
		pop a;y = a; y++;
	}
$af44:
	setYtoOffset(#10);	//be98
	$5b[y] = $742b,742c;
	//...
}
```
</details>


____________________
# $31:aa16 calcPlayerParam()
<details>
<summary>

>dispatchId : 5
</summary>

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
属性ボーナスが適用されないのはこの関数が正しくフラグを設定しないせい

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
</details>

____________________
# $31:af63 addItemBonus
<details>
<summary></summary>

### args:
+ [in] u8 A : bonusFlag
+ [in,out] u8 $2c[5] : params

### (pseudo-)code:
```js
{
	for (x = 0;x != 5;x++) {
		a <<= 1;
		if (carry) {
			push a;
			$2c.x += 5;
			pop a;
		}
	}
}
```
</details>

____________________
# $31:af77 doSpecialAction
<details>
<summary>

>battleFunction00 (dispId : 0)
</summary>

### notes:

### args:
+ [in] u16 $6e : actorPtr
+ [in] u8 $cc : skipSealedCheck (item=1,although item flag directs to skip too)
+ [in] u8 $7e99 : selected targets (actor.+2F)

### local variables:
+	u8 $62 : Index 
+	u8 $7e88 : actionId
+	u8 $7e9d : actionParam[6]

### callers:
+	dispatchBattleCommand(0)

### (pseudo-)code:
```js
{
	$54 = 0;
	for (x = 9;x >= 0;x--) {
		$7eb8.x = 0;
	}
$af8b:
	//getOffset2Cat6E(); //$a2b5(); //{ a = $6e[y = #2c]; }
	if (	(0 == $cc)
		&& ( (0 >= $6e[#2c] )
		|| ( (0 != ($6e[#2c] & 0x10)) && (0x50 > (a = $1a))  )
	) {
	//if (a >= 0) {//player
	//	if (0 != (a & 0x10) ) {	//ptr[2C].bit4
	//		a = $1a;//actionid
	//		if (a < 0x50) {
$af9a:
		a = $6e[1] & 0x30;
		if (0 != a) {	//沈黙か蛙
			if (0 == (a & 0x20)	//
				|| (0xf6 != (a = $1a) //#f6:トード(item)
			) {	
			//蛙がトードを使おうとしている場合以外
$afbb:			
				$78da = #50;	//'ちんもくしていて こうかがでない！'
				$7ec2 = #18;
$afc5:				return;	//goto $31:b15e();	
			}
		}
$afc8:		//cast allowed
		a = getActor2C();
		if (0 == (a & 0x18)) {
			$1a -= 0xc8;
		}
	} else {
$af87:
		y = #2c;
	}
$afd6:
	$6e[y] &= 0xe7;	//clearMode (#18)
	x = 0;
	$7e88 = a = $1a;
	if (a >= #5b) { x++; }
	$7ec3 = x;
	
	//memcpy($7400+x,$30:98c0[$18*8],8);
	$18 = $1a;
	$1a = 8;
	$20 = #$98c0;
$b000:	loadTo7400Ex(a=#18,x=0,y=#18);	//$3f:fda6
	$7e9d = $7406; //actionParam[6];
	a = $7e99;
	for (x = 8,y = 0; x != 0;x--) {
		a <<= 1;
		if (carry) y++;
	}
$b017:
	$2a = y;	//$7e99のビットの立ってる数
	a = $6e[y = #30];	//target flag
	if (a >= 0) {
		$70,71 = #7575;
	} else {
$b029:
		$70,71 = #7675;
	}
$b031:	//----
	copyStatus();	//$31:a2ba();
	$78,79,7a,7b = x = #ff;
	$7573,7574 = x = 0;
	a = $7e9d;	//actionParam[6]
	if (6 != a) {	//分裂系の技でないなら
$b04c:
		x = $62;
		a = $f0.x & #c0;	//status of $70
		if (0 != a) {	//対象が死んでるor石化してる
			return;	//goto $b15e;
		}
$b057:
		//andNthBit(a = $7e99, bit:x = $7ec1);  //$3f:fd38();
		maskTargetBit(a = $7e99, target:x = $7ec1);
		if (a == 0) goto $b139;	//次の対象へ beq $b139;
	}
$b065:
	if (0 == (a = $cc)) {	//$cc : 行使技タイプ? 0:通常魔法 1:item
		a = $7405; //actionParam[5]
		y=#10;
		a &= 0x10;
		if (0 != a) y++;
$b073:		$18 = a = $6e[y];	//知性or精神
//b073:
//b1 6e		lda ($6e),y
//85 18		sta $18
//4a		lsr a
//18		clc
//6d 01 74	adc $7401
		$25 = $7401 + (a >> 1);	//actionParam[1] + (知性or精神)/2
		x = $62;	//$62:invokerIndex
		if (0 != (a = ($f0.x & 4)) ) {
			//くらやみ
$b086:			$25 >>= 1;
		}
$b088:
		$19 = a = ($6e[y = #f]) >> 5;	//jobLv/32 fd44();
		$1a = a = ($6e[y = 0]) >> 4; //lv/16 fd45();
		a = $18 >> 4;	//int or men / 16

		$38 = $24 = $19 + $1a + a + 1;//+1:sec
		$7c = getNumberOfRandomSuccess(try:$24, rate:$25);	//$31:bb28();
		a = $7400 & (($6e[y = #33] & #e0) >> 3) ; //使用技属性とand?
$b0b6:		if (0 != a) {
			//$18 = $30;	//hitcount
			//$1a = 5;	//divisor
			//$19,1b = 0;
			//div16(); $3f:fc92();
$b0c1:
			$7c = $30 + $30/5; //hit回数2割増
		}
	}
$b0d3:
	//$7c = hitCount(withBonus)
	//$30 = hitCount
	//$38 = attackCount
	invokeActionHandler();	//$31:b15f();
$b0d6:
	x = $64; a = $79;
	if (#ff != a) {
		x = $64;
		if (0 == (a = $7574)) {
			$7e4f.x = $78,79;	//damage
		} else {
$b0f3:
			getTarget2c();	//$31:bc25()
			x = a = (a & 7) << 1;
			x++;
			if (#ff != (a = $7e5f.x)) {
				x--;
				$7e5f.x += $78,79
			} else {
$b118:				x--;
				$31:bb1c();
			}
$b11c:			$70,71 = $78b5,78b6
		}
	} else {
$b129:
		setEffectTargetToOpponent();//$31:bdbc();
		a = 0;
		checkForEffectTargetDeath();	//$31:bdc5();
	}
$b131:
	setEffectTargetToActor();	//$31:bdb3();
	a = 1;
	checkForEffectTargetDeath();	//$31:bdc5();
	
$b139:	$7ec1++;
	if (8 != $7ec1) {
		if (4 != $7ec1 || (0 != $7e9a & #40) ){
$b147: $b14e:
			$70,71 += #0040;
			goto $b031;
		}
	}
$b15e:
	return;
}
```
</details>

____________________
# $31:b15f invokeActionHandler
<details>
<summary></summary>

### args:
+	[in] u8 $7404 : handlerType (from actionParam[4])
	-	分裂=11

### (pseudo-)code:
```js
{
	$18,19 = ($7404 << 1) + #ba9c;
	$1a,1b = *($18,$19)
	(*$1a)();	//funcptr
$b17c:
}
```
</details>

____________________
# $31:b17c handleDamageMagic
<details>
<summary>

>specialHandler00: ダメージ魔法
</summary>

### notes:

### (pseudo-)code:
```js
{
	if ($70[y = #26] != 0) { //beq b185
		$b9fa();
	}
$b185:
	$b88f();
	if ($b8e7() != 0) { //beq b1b1
		if (($7403 & 1) == 0) //beq b199
			|| ($7ed8 >= 0) //bmi b1ae
		{
$b199:
			if (($7403 & 2) == 0) b1b4; //beq
			if ($7ed8 < 0 ) $b1ae ;//bmi
$b1a5:
			if ($70[y = 1] < $7403) b1b4; //bcc
		}
$b1ae:
		clearEffectTarget();	//$b926();
	}
	return $b21c();
$b1b4:
	$26 = $70[y = #15];
	y = #10;
	if (($7405 & #10) != 0) y++; //beq b1c4
$b1c4:
	//(int or men)/2 + param[2]
	$25,2b = ($6e[y] >> 1) + $7402
	if ( (( $e0.(x = $64) & #28) != 0)  // bne b1e1 toad|minimum
		|| ($70[y = #27] != 0) //beq b1e9
	}
$b1db:
		$25,2b <<= 1;
		$26 = 0;
	}
$b1e9:
	if (($7405 & #40) == 0) { //beq b1f4
		$2a = 1；
	}
$b1f4:
	$28,29 = 0;
	$24 = $7c;
	calcDamage(hitcount:$7c, atk:$25,2b, def:$26, attr:$27, bonus:$28, bonusMul:$29, divide:$2a); // $bb44();
$b201:
	if ( ($1c | $1d) == 0) $1c++; //bne b209
$b209:
	$78,79 = $1c,1d
	$bdbc();
	damageHp();	//$bcd2()
	if (carry) { //bcc b21c
		$be43();
	}
$b21c:
	if ( ($7574 != 0)  //beq b232
		&& ( ($70[y = 3] | $70[++y]) == 0) ) //bne b232
	{ 
$b22a:
		$70[y = 1] |= #80;	//dead
	}
$b232:
	return;
}
```
</details>

____________________
# $31:b233 handleHealingMagic	
<details>
<summary>

>specialHandler01: 回復魔法
</summary>

### notes:

### (pseudo-)code:
```js
{
	isTargetWeakToHoly();	//$bbe2();
	if (carry) {
		$54 = 1;
		return handleDamageMagic();
	}
	if (clearEffectTargetIfMiss() != 0) { //beq b275
		a = $7405 & 7;
		if ((a == 6) // bne b266
			&& ($2a == 1) //bne b266
		{
$b253:
			//HP = maxHP
			$70[y = 3] = $70[y = 5];
			$70[y = 4] = $70[y = 6];
		} else {
$b266:
			calcHealAmount();	//$b6dd();
			setCalcTargetPtrToTarget();	//$bdbc();
			healHP();	//$bd24();
			$79 |= #80;
		}
	}
$b275:
	return;
$b276:
}
```
</details>

____________________
# $31:b30c handleStatusMagic
<details>
<summary>

>specialHandler04: バステ魔法
</summary>

### notes:

### (pseudo-)code:
```js
{
	if (isTargetWeakToHoly() ) { //$bbe2(); bcc b31f
$b311:
		if ($7e88 == #01) { //bne b31f
			$54 = #05;
			return $b23f();
		}
	}
$b31f:
	calcMagicHitCountAndClearTargetIfMiss();	//$b8e7();
	if (!equal) { //beq b379
		//hitcount > 0
		if ((getTarget2c() < 0) //$bc25(); bpl b334
			&& ($7ed8 < 0) ) //bpl b334
		{
$b32e:
			clearEffectTarget();	//$b926();
			goto $b379;
		} else {
$b334:
			$24 = a = $7403;	//actionparam[3] (enchant)
			if ((a & #20) != 0) { // beq b34c
				//[toad/confuse]
				a = $00e0.(x = $64) & #40;	//stone
				if (a != 0) { //beq b34c
$b346:
					clearEffectTarget();	//$b926();
					goto $b379;
				}
			}
$b34c:
			isTargetNotResistable(); //$b875();
			if (!carry) { //bcs b357
$b351:
				//target resisted to implant status
				clearEffectTarget();	//$b926();
				goto $b379;
			} else {
$b357:
				if (($7e88 != #16)  //bne b373	//16:キル
$b35e:
					|| ($70[y = 0] < ($18 = ($6e[y = 0]>>1 + $6e[y = 0]>>2)) //bcs b346
				{
$b373:
					applyStatus();	//$bbf3();
					goto $b379;
				}
			}
		}
	}
$b379:
	return;
}
```
</details>

____________________
# $31:b3f1 handleToadMinimum
<details>
<summary>

>specialHandler07: トード・ミニマム
</summary>

### (pseudo-)code:
```js
{
	if ( (getActor2C() < 0)  //a2b5 bmi b3fa
		|| $70[y] < 0)) //bpl b3ff
	{
$b3fa:
		//少なくとも一方が敵側
		calcMagicHitCountAndClearTargetIfMiss();	//$b8e7();
		if (equal) b473;
	}
$b3ff:
	if ( (getTarget2c() < 0)  //bpl b40f
		&& ($7ed8 < 0)) //bpl b40f
	{
		//対象が敵でかつボス戦
		clearEffectTarget();	//$b926();
		goto $b473;
	}
$b40f:
	$18 = $70[y = #1];
	$19 = $70[y] = a ^ $7403;	//param03
	x = $64;
	a = $19 & #28;	//toad|minimum
	if (a != 0) { //beq b427
		a = $70[y] | $7403;
	}
$b427:
	$e0.x = a;
	if (($19 & #20) != 0) { //beq b43c
$b42f:
		if (($18 & #20) == 0) { //bne b473
			$78d9 = #0f;
		} //bne b473
	} else {
$b43c:
		if (($19 & #08) != 0) //beq b44f
			&& ($18 & #08) == 0) { //bne b473
			$78d9 = #11;
			//bne b473
		}
	}
$b44f:
	//...
$b473:
}
```
</details>

____________________
# $31:b474 handleProtect
<details>
<summary>

>specialHandler08: プロテス
</summary>

### (pseudo-)code:
```js
{
	clearEffectTargetIfMiss(); //b921
	if (!equal) { //beq b47f
		calcHealAmount();	//$b6dd();
		$b704();
	}
$b47f:
	return;
}
```
</details>

____________________
# $31:b480 handleHaste
<details>
<summary>

>specialHandler09: ヘイスト
</summary>

### (pseudo-)code:
```js
{
	clearEffectTargetIfMiss(); //b921
	if (!equal) { //beq b48b
		calcHealAmount();	//$b6dd();
		$b752();
	}
$b48b:
	return;
}
```
</details>

____________________
# $31:b49b handleErase
<details>
<summary>

>specialHandler0B: イレース
</summary>

### (pseudo-)code:
```js
{
	calcMagicHitCountAndClearTargetIfMiss();	//$b8e7();
	if (!equal) { //beq b4b8 //equal=miss
		if ( (getTarget2c() < 0) //bpl $b4b0
			&& ($7ed8 < 0) //bpl $b4b0
	{
		//対象が敵でかつボス戦
		clearEffectTarget();	//$b926();
		goto b4b8;
	} else {
$b4b0:
		$70[y = #20] &= #03;	//20:defAttr
	}
$b4b8:
	return;
}
```
</details>

____________________
# $31:b4d4 handleSegmentation
<details>
<summary>

>specialHandler11: 分裂
</summary>

### (pseudo-)code:
```js
{
	//if ($6e[y = 3] != $6e[y = 5])	//bne $b4eb
	//if ($6e[y = 4] != $6e[y = 6])	//bne $b4eb
	if ($6e[y = 3] == $6e[y = 5] && $6e[y = 4] == $6e[y = 5]) {
$b4e8:	//[HP==maxHP]
		$31:b98b();
	}
$b4eb:
	$31:b936();
	$31:b9a0();
	return $b4cf();
}
```
</details>

____________________
# $31:b51f handleSuicidalExplosion
<details>
<summary>

>自爆
</summary>

### (pseudo-)code:
```js
{
	$18,19 = $6e[3,4];
	if (0 != ($6e[3,4] - $6e[5,6])) {
		//現HP-MaxHP != 0
		$78,$79 = $18,19 << 2;
		setCalcTargetPtrToOpponent();	$31:bdbc();
		damageHp();	//$31:bcd2();
		$6e[3,4] = 0; //HP = 0;
		$6e[y = 1] = #80;	//status0 = dead
	} else {
$b55a:
		$78d7,78d9 = x = #ff;
		$7e99 = 0;
		$78da = #44;
	}
}
```
</details>

____________________
# $31:b6dd calcHealAmount
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$28,29,2b = 0;
	$27 = 2;	//attr mul(2 = normal)
	$24 = $7c;	//hitcount
	$25 = $7402;	//power = param[2]
	$26 = $70[y = #15];	//def = mdef
	calcDamage();	//$bb44
	$78,79 = $1c,1d
	return;
$b704:
}
```
</details>

____________________
# $31:b704 magic_protect
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	if ( ($70[y = #23] != #ff)  //bne b714
		|| ($70[y = #15] != #ff) //beq b745
	{
$b714:
		$70[y = #23] = max(255, $70[y = #23] + $78,79);
$b72b:
		$70[y = #15] = max(255, $70[y = #15] + $79,79);
$b742:
		return setResultDamageInvalid();
	}
$b745:
	setResultDamageInvalid();	//$b74b();
	return clearEffectTarget();	//$b926();
$b74b:
}
```
</details>

____________________
# $31:b74b setResultDamageInvalid
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$78,79 = #ff;
	return;
$b752:
}
```
</details>

____________________
# $31:b752 doMagicHaste
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	if ($70[y = #19] != #ff) //beq b7c1
		&& ($79[y = #1e] != #ff) //beq b7c1
		&& ($70[y = #10] < #10) //bcs b7c1
		&& ($70[y = #1c] < #10) //bcs b7c1
	{
$b772:
		u16 temp = $70[y = #19] + $78,79;
		$70[y = #19] = (u8) temp;
		if (temp >= 0x100) { //beq b789
			$70[y = #19] = #ff;
		}
$b789:
		//y = #1eについてb772-と同じ
$b7a0:
		$70[y = #17] = max(16, $70[y = #17] + $7c);
$b7af:
		$70[y = #1c] = max(16, $70[y = #1c] + $7c);
		return setResultDamageInvalid(); //b74b
	} else {
$b7c1:
		setResultDamageInvalid();
		return clearEffectTarget();
	}
}
```
</details>

____________________
# $31:b875 isTargetNotResistable
<details>
<summary></summary>

### args:
+ [in] u8 status
+ [out] bool carry : (1=yes)

### (pseudo-)code:
```js
{
	clearEffectTargetIfMiss();	//$b921();
	a = $70[y = #24] & $24;	//#24:resistStatus
	if (a == 0) { //bne b883
		sec
	} else {
		clc
	}
	return;
}
```
</details>

____________________
# $31:b8e7 calcMagicHitCountAndClearTargetIfMiss
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	if ((getActor2C() < 0)  //$a2b5(); bmi b8f4
		|| ($70[y] < 0) //bmi b8f4;y = #2c
		|| ($7c == 0) //bne b91f
	{
$b8f4:
		$24 = $70[y = #13];	//mdef.count
		$25 = $70[++y];		//mdef.evade
		a = $70[y = 1] & 4;	//blind
		if (a != 0) { //beq b909
			$25 >>= 1;
		}
$b909:
		a = $70[y] & #28; //toad|minimum
		if (a != 0) { //beq b913
			$24 = 0;
		}
$b913:
		getNumberOfRandomSuccess(try:$24, rate:$25);	//$bb28();
		if (a = ($7c - $30) < 0) { //bcs b91f
$b91d:
			a = 0;
		}
	}
$b91f:
	$7c = a;
	//fall through
$b921:
}
```
</details>

**fall through**
____________________
# $31:b921 clearEffectTargetIfMiss
<details>
<summary></summary>

### args:
+	[in] u8 $7c : hitCount
+	[in,out] u8 $7e9b : playEffectTargetBit
+	[in] u8 $7ec1 : targetIndex

### (pseudo-)code:
```js
{
	if ($007c == 0)  //bne b932
}
```
</details>

**fall through**
____________________
# $31:b926 clearEffectTarget
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$7e9b = clearTargetBit(a = $7e9b, target:x = $7ec1); //fd2c  $7e9b &= ~(#80 >> x)
$b932:
	a = $007c;
	return;
}
```
</details>

____________________
# $31:b9ab segmentate
<details>
<summary>

>分裂
</summary>

### args:
+ [in] u8 $18 : enemyIdOfSegmentating
+ [in] u8 $1c : enemyIdOfTargetSpace
+ [out] ptr $20 : pNewlyGeneratedEnemy

### (pseudo-)code:
```js
{
	$1e,1f = #7675 + mul_8x8(a = $18,x = #40);	//fcd6
	$20,21 = #7675 + mul_8x8(a = $1c,x = #40);
	for (y = #3f;y > 0;y--) {	
		$20[y] = $1e[y];
	}
$b9dc:
	$20[y = #2c] = $1c | #80 & #e7; y += 2;
	$20[y] = 0;
	return;
$b9ed:
}
```
</details>

____________________
# $31:bb28 getNumberOfRandomSuccess
<details>
<summary></summary>

### args:
+ [in] u8 $24 : countToTry ?
+ [in] u8 $25 : percentSuccess
+ [out] u8 $30 : resultCount
+ [out] u8 A : resultCount

### (pseudo-)code:
```js
{
	$30 = 0;
	for ($24;$24 != 0;$24--) {
		getRandom(#63);//$31:beb4
		if (a < $25) { //bcs $bb3b
			$30++;
		}
$bb3b:
	}
	return $30;
}
```
</details>

____________________
# $31:bb44 calcDamage
<details>
<summary></summary>

### notes:
$1c,1d = ((($25*(1.0~1.5)*($27/2)+$28*$29)-$26)*$7c)/$2a

### args:
+	[in] u16 $25,2b : attack power?
+	[in] u8 $26 : defence power?
+	[in] u8 $27 : attr multiplier
+	[in] u8 $28 : additional damage (critical modifier)
+	[in] u8 $29 : critical count(0/1)
+	[in] u8 $2a : damage divider (target count)
+	[in] u8 $007c : damage multiplier (hit count)
+	[out] u16 $1c : final damage (0-9999)

### (pseudo-)code:
```js
{
	a = $25,2b >>= 1;	//hibyte:2b
	getRandom(a);	//$31:beb4();
	$18,19 = (a + $25,$2b);
	$1b = 0;
	a = $27;
	a >>= 1;
	if (0 == a) {
		$18,19 >>= 1;
		$1c,1d = $18,19;
	} else {
$bb70:
		$1a = a;
		mul16x16();	//$3f:fcf5
	}
$bb75:
	$30,31 = $1c,1d
	x = $28; a = $29;
	mul8x8(a,x);	//$3f:fcd6
	$18,19 = ($30,31) + ($1a,1b);
$bb91:	a = get$6E_2C(); //$30:a2b5();
	//if (a >= 0) {
	//	a = $70[y]; //y=#2c
	//} else {
	if (a < 0 || $70[y] < 0) { //攻撃側か防御側どちらかは敵
$bb9a:
		$18,19 -= $26,#00;
		if ($18,19 < 0) { $18,19 = 0; }
	}
$bbaf:
	$1a,1b = $007c,#00;
	mul16x16();
	$18,19 = $1c,1d;
	$1a,1b = $2a,#00;
	div16();	//$3f:fc92
	if ($1c,1d > #270f) { $1c,1d = #270f; }
}
```
</details>

____________________
# $31:bbe2 isTargetWeakToHoly
<details>
<summary></summary>

### args:
+	[out] bool carry : 1=yes 0=no
+	[out] u8 $27 : 2=yes 0=no

### (pseudo-)code:
```js
{
	if ($70[y = #12] <= 0) { //bbef
		$27 = #2;
		sec;
	} else {
$bbef:
		clc;
		a = 0;
	}
$bbf2:
	return;
}
```
</details>

____________________
# $31:bbf3 applyStatus
<details>
<summary></summary>

### args:
+ [in] u8 $24 : status to apply
+ [in,out] u8 $e0 : applied status
+ [in,out] u8 $78ee : queue index?
+ [out] u8 $78d9 : status index?
+ [out] u8 $78da~ : battle event queue?
+ [out] u8 a : $70[0x2c]

### (pseudo-)code:
```js
{
	x = a = (get$70_2C() & 7) << 1;	//bc25()
	if (0 == (a = ($24 & 1)) ) {
		//heavy bad status
		a = $e0.x;
		//より重いステータスになっている場合はなにもしない
		if (a >= $24) return clearEffectTarget(); //jmp $b926;
$bc09:
		$e0.x |= $24;
		x = 0;a = $24;
$bc11:		do {
			a <<= 1;
			if (carry) break;
			x++;
		} while (x != 0);
$bc17:
		a = x;
		if (a >= 0) {
			clc;
			a += 3;
		}
$bc1f:		clc;
		a += 10;
		$78d9 = a;
$bc25:		a = $70[y = #2c];
		return ;
	}
$bc2a:	//($24 & 1) == 1

	//if (0 != (a = ($24 & 0x20)) ) {
	if ((a = $7ed8) >= 0) 
		|| (0 == ($24 & 0x20)) )
	{
$bc35:
		x++;
		a = $24 & 6;	//graduallyPetrify
		if (0 == a) {
			$25 = $e0.x;
			$18 = $25 & 0xE0;	//paralyzed | sleeping | confused
			$19 = $24 & 0xE0;	//
			//より重かったらなにもしない
			if ($18 > $19) return clearEffectTarget();	//jmp $b926;
			
			$18 = $25 & 7;	//石化度|ステータス種
			$18 |= $0024 & 0xfe;
			$e0.x = $18;
			if (0 != (a = ($18 & 0x20)) ) {
$bc66:
				//混乱したので行動をキャンセル
				$70[y = #2e] = 0;
				get$70_2C();	//$bc25
				$70[y] = a & 0xE7; 
			}
$bc73:
			x = 0; a = $24;
			do {
$bc77:				a <<= 1;
				if (carry) break;
			} while (x != 0);
$bc7d:
			$78d9 = a = x + 0x0c;
			return ;
		}
$bc85:
		//徐々に石化
		$18 = $24 & 0x7E;
		$25 = $e0.x;
		$19 = $25 & 0x06;
		a = $18 + $19;
		if (a < 8) {
$bc9c:
			$e0.x = $18 + $25;
			a = $6e[y = #2e];	//action id?
			if (a == 4) {
				//行動id04(たたかう)によって徐々に石化した
				x = $78ee;
				$78da.x = #3c;	//"からだがじょじょにせきかする"
				$78ee++;
			}
$bcb6:
			return;
		}
$bcb7:
		$e0.x = a = $25 & 0xf9; x--;
		$e0.x |= #40;
		$78d9 = #0b;	//"いし"
		x = $78ee;
$bcc9:
		$78da.x = #28;	//28:"いしになりくだけちった!"
	} else {
$bc50:
		return clearEffectTarget();	//jmp $b926;
	}
}
```
</details>

____________________
# $31:bc25 getTarget2C
<details>
<summary></summary>

### args:
+	[in] u16 $70 : targetPtr
+	[out] u8 a : $70[#2c]

### (pseudo-)code:
```js
{
	a = $70[y = #2c];
}
```
</details>

____________________
# $31:bcd2 damageHp
<details>
<summary></summary>

### args:
+	[in] u16 $78 : damage
+	[in] u16 $24 : targetPtrToApply
+	[out] u8 $7573 : deathCounter?
+	[out] bool carry : isTargetAlive

### notes:
`$31:bced processKill`

### (pseudo-)code:
```js
{
	if ($78,79 == 0) return;
	y = 3;
	$24[y++] -= $78;
	$24[y]  -= $79;
	//u16 temp = ($24[3],$24[4]);

	if (temp < 0 || temp == 0) {
		$7573++;
		$24[y--] = 0; $24[y] = 0;
		clc;
	} else {
$bcfa:
		sec;
	}
}
```
</details>

____________________
# $31:bd24 healHp
<details>
<summary></summary>

### args:
+ [in,out] u16 $78,79 : [in] healAmount [out] actuallyHealedAmount
+ [in] ptr $24 : healTarget

### (pseudo-)code:
```js
{
	$1a,1b = $24[3,4];
	$24[3,4] += $78,79
	$18,19 = $24[5,6];
	if ($24[5,6] - $24[3,4] < 0) { bcs bd66
$bd4f:
		$24[3,4] = $18,19;
		$78,79 = $24[3,4] - $1a,1b;	//maxHP - hpBeforeHeal
	}
$bd66:
	return;
}
```
</details>

____________________
# $31:bd67 spoilHp
<details>
<summary></summary>

### args:

#### in:
+	u16 $78,79 : damage

#### out:
+	u8 $26 : dead flag (00:both alive 01:target dead 81:actor dead)
+	u8 $42 : undead flag

### (pseudo-)code:
```js
{
	$26 = 0;
	if (isTargetWeakToHoly() ) { //$bbe2(); bcc bd8f
$bd70:
		//undead
		$42++;
		setCalcTargetToActor();	//$bdb3
		damageHp();	//bcd2
		if (!carry ) {	// bcs bd7e
$bd7a:	
			//damage target(= actor) dead
			$26 = #81
		}
$bd7e:
		if ($6e[y = #2e] == #04) { //bne bd89
			shiftRightDamageBy2();	//$bdaa();
		}
		healHp();	//$bd24();
		//goto bda9
	} else {
$bd8f:
		damageHp();	//bcd2
		if ( !carry ) { //bcs bd98
			$26 = #01
		}
		setCalcTargetToActor();	//bdb3
		if ($6e[y = #2e] == #04) { //bne bda6
			shiftRightDamageBy2();	//$bdaa();
		}
$bda6:
		healHp();	//$bd24();
	}
$bda9:
	return;
}
```
</details>

____________________
# $31:bdaa shiftRightDamageBy2
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$78,79 >>= 2;
	return;
}
```
</details>

____________________
# $31:bdb3 setCalcTargetToActor
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$24,25 = $6e,$6f;
}
```
</details>

____________________
# $31:bdbc setCalcTargetPtrToOpponent
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$24,25 = $70,71;
}
```
</details>

____________________
# $31:bdc5 checkForEffectTargetDeath
<details>
<summary></summary>

### args:
+ [in] u8 A : sideToCheck (0=player 1=mob)?

### (pseudo-)code:
```js
{
	push a;push a;
	$18 = #80;
	if ((a = getEffectTarget2C()) < 0)	{ //$31:a8c8();
		push a;
		$18 = #e0;	//死石蛙
		pop a;
	}
$bdd6:
	x = (a & 7) << 1;
	pop a;
	if (0 == a) {
$bddd:		a = $e0.x & $18;
		if (0 == a)  $bdf6;
		else $bdeb;
	} else {
$bde5:
		a = $f0.x & $18;
		if (0 == a) $bdf6;
	}
$bdeb:	if (0 != a) {
		//プレイヤーキャラ:死 or 敵:死石蛙 
		//y = 3;a = 0;
		$24[3,4] = 0;
		//beq $be12
	} else {
$bdf6:
		if ($24[3,4] == 0) {
			pop a;
			if (0 == a) {
				$e0.x |= #80;	
			} else {
$be0a:				$f0.x |= #80;
			}
		} else {
$be12:			pop a;
		}
	}
$be13:
	return;
}
```
</details>

____________________
# $31:be14 checkStatusEffect
<details>
<summary></summary>

### args:
+ [in] u8 $742c : physical evade
+ [in] u8 $742e : status resist
+ [in] u8 $7442 : hit
+ [in] u8 $7444 : status to apply
+ [in] u8 $7c : hit count

### (pseudo-)code:
```js
{
	$25 = $7444;	//=$6e[#1a]
	if ($25 == 0) return;
	
	$24 = $7c;
	if ($24 == 0) return;

	a = $742e & $25;
	if (a != 0) return; //resisted

	a = $7442 - $742c;
	if (a < 0) { a = 0;}
$be33:
	$25 = a;
	getNumberOfRandomSuccess($24,$25);//$bb28()
	if (0 != a) {
		$24 = $7444;
		applyStatus();	//$31:bbf3();
	}
}
```
</details>

____________________
# $31:be90 updateBaseOffset
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	return $5f = a = $52 << 6;
}
```
</details>

____________________
# $31:be98 setYtoOffsetOf
<details>
<summary></summary>

### args:
+ [in] u8 a : memberOffsetToSet
+ [in] u8 $5f : basePtr
+ [out] u8 a,y : resultOffsetFromBasePtr

### (pseudo-)code:
```js
{ 
	y = a + $5f;
}
```
</details>

____________________
# $31:be9d calcDataAddress
<details>
<summary>

>battleFunction07
</summary>

### args:
+ [in] u8 $18 size (in bytes)
+ [in] u8 $1a index	
+ [in] u16 $20 baseAddr 
+ [out] u16 $1c dataAddr

### (pseudo-)code:
```js
{
	$1c = $20 + $18*$1a
}
```
</details>


____________________
# $31:bebf rebuildBackpackItems 
<details>
<summary>

>battleFunction08
</summary>

### (pseudo-)code:
```js
{
	a = 0;x = 0;
	do {
$bec3:
		$7280.x = $7380.x = a;
	} while (++x != 0);
$becc:
	for (y = 0;y != #40;y++) {
$bece:
		x = a = $60c0.y;	//itemid (in battle allocation)
		$7280.x = a;
		y++;
		a = $7380.x + $60c0.y;	//itemcount (battle)
		if (a >= 100) { //bcc bee3
			a = 99;
		}
$bee3:
		$7380.x = a;
	}
$beeb:
	a = 0;
	for (x = #3f;x > 0;x--) {
		$60c0.x = a;
	}
$bef5:
	for (y = #ff, x = 0; y != 0; y--) {
$bef9:
		if ((a = $7280.y) != 0) { //beq bf13
$befe:
			$60c0.x = a; x++;
			if ((a = $7380.y) == 0) { //bne bf0f
				x--;
				$60c0.x = 0;
			} else {
$bf0f:
				$60c0.x = a; x++;
			}
		}
$bf13:
	}
	return;
}
```
</details>

____________________
# $31:bf53 checkSegmentation	
<details>
<summary>

>分裂判定
</summary>

### args:
+ [in] u8 $7da7 : indexToIdMap
+ [out] u8 $7ee1 : segmenated enemy's id

### notes:
使用技リストの1個目が#$4fの敵に
暗黒属性以外の攻撃が1回以上命中した場合
分裂処理を行う
なお二刀流の場合は命中した手がどちらかによらず両手が暗黒でないと分裂する

### (pseudo-)code:
```js
{
	$18 = 0;
	if ( (getTarget2C() < 0) //bpl bfbc
		&& ( ($e0.(x = $64) & #e8) == 0) //bne bfbc
		&& ( ($e0.(++x) & #e0) == 0) ) //bne bfbc
		&& ( $70[y = #38] == #4f) //bne bfbc
		&& ( $bb|$bc != 0) //beq bfbc
		)
	{
$bf7b:
		if (($6e[y = #31] > 0) { //beq/bmi bf9d
			if (($6e[y = #16] & 2) == 0) $bfae; //beq
$bf8b:
			if ($6e[y = #32] <= 0) goto $bfbc; //beq/bmi bfbc
$bf93:
			if (($6e[y = #1b] & 2) == 0) $bfae:
			goto $bfbc;	//bne
		} else {
$bf9d:		
			if ($6e[++y] > 0) { //beq/bmi bfae
$bfa4:
				if (($6e[y = #1b] & 2) != 0) goto $bfbc; //bne
			}
		}
$bfae:
		for (x = 0;x != 6;x++) {
$bfb0:
			if ($7da7.x == #ff) goto $bfbd;
		}
	}
$bfbc:
	return;
$bfbd:
	$1c = x;
	$7ec4.x = 0;
	x <<= 1;
	$e0.x = 0;
	x = $68;
	a = $7be1;
	$7be1 = andNotBitX();	//$fd2c();
	x = $18 = getTarget2C() & 7;	//bc25
	$7ee1 = $7da7.x;
	segmentate();	//$b9ab();
$bfe8:
	a = y = 0;
	$20[++y] = a;	//status0
	$20[++y] = a;	//status1
	$78da.(x = $78ee) = #6f; //"ぶんれつした!"
	return;
$bffa:
}
```
</details>

____________________
# $34:8000 
<details>

### (pseudo-)code:
```js
{
	return battleLoop();	//$8074;
}
```
</details>

____________________
# $34:8003 
<details>

### (pseudo-)code:
```js
{ return $9ce3; }
```
</details>

____________________
# $34:8006 
<details>

### (pseudo-)code:
```js
{ return $803d; }
```
</details>

____________________
# $34:8009 
<details>

### (pseudo-)code:
```js
{ return $8043; }	//フィールドの装備メニューから呼ばれる
```
</details>

____________________
# $34:800c 
<details>

### (pseudo-)code:
```js
{ return strToTileArray(); //$966a; }
```
</details>

____________________
# $34:800f 
<details>

### (pseudo-)code:
```js
{ return loadString(); //$a609; }
```
</details>

____________________
# $34:8012 dispatchBattleFunction
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	a = 0; goto $8038; //ex.ほのお
$8016:	a = 1; goto $8038;
$801a:	a = 2; goto $8038; //decide enemy action
$801e:	a = 3; goto $8038; //たたかう
$8022:	a = 4; goto $8038;
$8026:	a = 5; goto $8038; //on cancel item window
$802a:	a = 6; goto $8038;
$802e:	a = 7; goto $8038;
$8032:	a = 8; goto $8038;
$8036:	a = 9; goto $8038;
$8038:
	$4c = a;
	call_bank30_9e58(); //$3f:fdf3();
}
```
</details>

____________________
# $34:803d
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$806c();
	return dispatchBattleFunction(5); //recalcBattleParams
}
```
</details>

____________________
# $34:8043
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	a = $18;
	if (a >= #c8) //bcs 8053
	if (a >= #98) { //bcc 8058
$804d:
		$1c = 0; //beq 8067
$8053:
	$18 = a - #30;
$8058:
	a = x;
$8059:
	setCurrentPlayerPtrs();//806c
$805c
	$20,21 = #9400;
$8064:
	isPlayerAllowedToUseItem();
}
```
</details>

____________________
# $34:806c setCurrentPlayerPtrs
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$52 = a >> 6; //fd43
	return setPlayerPtrs();	//$88e1();
}
```
</details>

____________________
# $34:8160 endBattle
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	prize(); //bb49
	updatePlayerBaseParams();	//$8306();
	if (($78ba & #08) != 0) {
		//backattack
		$88a4();
	}
$8170:
	dispatchBattleFunction08();	//$8032 [rebuildBackpackItems]
	if ( ($7ced == #79)  //bne 8184
		&& ($7cee != 0) //beq $8184
	{
	//79:くらやみのくも
		$78d3 = 0;
	}
$8184:
	return;
}
```
</details>

____________________
# $34:8185 presentCharacter
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	push a;	push (a = y); push (a = x);
	if ( 0 != (a = $7cf3)) {
		call_2e_9d53(a = #13);	//$3f:fa0e
		updatePpuDmaScrollSyncNmi();	//$3f:f8c5();
	}
$8197:
	x = pop a; y = pop a; pop a;
}
```
</details>

____________________
# $34:8213 initBattleVars
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	a = #ff;
	for (x = #1f; x >= 0; x--) {
$8217:		$7e4f.x = a;
	}
	$78d6 = $78d7 = $78d8 = $78d9 = $7e88 = a;
	for (x = 9; x >= 0; x--) {
$822e:		$78da.x = a;
	}
	$7ee1 = x;	//x:#ff
	x++;
	$78ee = x;
	$7e98 = $7e99 = $7e9a = x;
	$7e1f = $7e20 = x;
	$bb = $bc = x;
	$7e93 = $78d4 = $7ec2 = x;
	$7e0f = $7e10 = $7e11 = $7e12 = x;
	$72 = $7edf = x;
	a = x;
	for (x = #1f; x >= 0; x--) {
$826b:		$e0.x = a;
	}
}
```
</details>


___________________
# $34:8271 battle.increment_number_of_command_selection
<details>

### notes:
there seems to be a bug checking conditions not to increment the selection count:
@see http://966-yyff.cocolog-nifty.com/blog/2013/06/ff3-d544.html

### (pseudo-)code:
```js
{
 1A:8271:A2 00     LDX #$00
 1A:8273:86 52     STX $0052 = #$00
 1A:8275:A6 52     LDX $0052 = #$00
 1A:8277:BD C3 7A  LDA $7AC3,X @ $7AC3 = #$FF
 1A:827A:85 18     STA $0018 = #$09
 1A:827C:C9 FF     CMP #$FF
 1A:827E:F0 0C     BEQ $828C
	 1A:8280:18        CLC
	 1A:8281:A5 52     LDA $0052 = #$00
	 1A:8283:20 40 FD  JSR $FD40	;//asl x 2
	 1A:8286:65 18     ADC $0018 = #$09
	 1A:8288:AA        TAX
	 1A:8289:FE F0 78  INC $78F0,X @ $78F0 = #$01
 1A:828C:E6 52     INC $0052 = #$00
 1A:828E:A5 52     LDA $0052 = #$00
 1A:8290:C9 04     CMP #$04
 1A:8292:D0 E1     BNE $8275
 1A:8294:60        RTS -----------------------------------------
}
```
</details>

____________________
# $34:8306 updatePlayerBaseParams
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	for ($52 = 0;$52 != 4;$52++) {
$830a:
		$8026();
	}
$8315:
	for ($0052 = 0;$52 != 4;$52++) {
$831a:
		y = updatePlayerOffset();	//a541
		$18 = $5b[++y] & #fe;
		setYtoOffset03();	//$9b8d();
		//hp
		$19,1a = $5b[y,++y];
		x = 0;
		setYtoOffsetOf(a = #7);	//$9b88
		for (x;x != 8;x++) {
$8338:
			$1b.x = $5b[y++];	//mp
		}
$8342:
		setYtoOffsetOf(a = #2);
		$57[y] = $18;	//status
		setYtoOffsetOf(a = #c);
		$57[y] = $19;	//hp
		$57[++y] = $1a;
		
		x = 0;
		setYtoOffsetOf(a = #30);
		for (x;x != 8;x++) {
$8360:
			$57[y] = $1b.x;	//mp
			y += 2;
		}
$836b:
	}
$8373:
	return;
}
```
</details>

____________________
# $34:8374 beginBattlePhase
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$74 = 0;
	for ($52 = 0;$52 < 4;$52++) {
		a = updatePlayerOffset();	//$35:a541()
		y = a + #3f;
		if (0 != $5b[y] ) {
			$34:9ae7();
		}
$8388:
		setYtoOffset2E();	//$34:9b9b();
$838b:
		a = $5b[y];	//y=2e=commandId
		if (a == 6 || a == 7) {//"逃げる"か"とんずら"
$8395:
			$74++;
		}
$8397:
	}
	
}
```
</details>

____________________
# $34:8411 playEffect
<details>
<summary></summary>

### args:
+ [in] u8 $7e9a :	action side flag (80:actor enemy 40:target enemy)
+ [in] u8 $7ec2 : effectType; set by commandHandler, usually commandId
+ [in] u8 $7ec3 : (0 or 1?)

### (pseudo-)code:
```js
{
	a = $7e9a;
	rol a;rol a;rol a; a &= 1;
	$7e6f = a;	//bit6 of $7e9a
	y = $7ec2; a = $83f8.y;
	if (1 == a) a += $7ec3;
$842a:
	$7e97 = a;
	y = a << 1;
	$18,19 = $843e.y,$843f.y;
	(*$18)();	//jumptable
$843e:
//	func	addr	$7ec2
	00	8613	4,10	//たたかう うたう
	01	8577	13,14	//? アイテム/まほう
	02	85ed
	03	8576	0,1,a,b,c,d,e	//? ? ? しらべる みやぶる ぬすむ
	04	853b	2	//ぜんしん
	05	8540	3	//こうたい
	06	8528	5	//ぼうぎょ
	07	852d	8	//ジャンプ
	08	8516	9	//(着地)
	09	850a	f	//ためる
	0a	8505	11	//おどかす
	0b	84fb	12	//おうえん
	0c	84f6	15	//
	0d	84d7	6,7	//にげる とんずら
	0e	8470	16	//死亡エフェクト (dispCommand_0D)
	0f	8460	17	//ダメージ表示(dispCommand_0C)
	10	8555	18	//かえるアクション
$8460:
}
```
</details>

____________________
# $34:8460 playEffect_0F
<details>
<summary></summary>

### args:
+ [in] u8 $7ee1 : segmentated enemy id (ff: none)

### (pseudo-)code:
```js
{
	showDamage();	//$34:868a();
	if ((a = $7ee1) >= 0) { //bmi 846f
		$7e = a;
		call_2e_9d53(a = #0c);	//fa0e
	}
$846f:	return;
}
```
</details>

____________________
# $34:8470 playEffect_0e
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	if ($7e9a >= 0) {
		$8496();
		return $8481();
	} else {
		$8481();
		return $8496();
	}
$8481:
}
```
</details>

____________________
# $34:8481
<details>

### (pseudo-)code:
```js
{
	for (x= 0;x != 8;x++) {
		if ($78bb.x != $7d9b.x) goto $8491;	//bne
	}
	return;
$8491:
	call_2e_9d53(a = #7);
$8496:
}
```
</details>

____________________
# $34:8496 buildEnemyDeadBits
<details>
<summary></summary>

### args:
+ [in] u8 $7da7[8] : indexToGroup
+ [in] u8 $7ec4[8] : enemyStatus

### (pseudo-)code:
```js
{
	for (x = 0;x != 8; x++) {
$8498:
		if ( $7ec4.x >= 0) { //bmi $84b2
			if ($7da7.x == #ff) { //bne $84b9
				$84c7();
				$7e ^= #ff;
				call_2e_9d53(a = #0b);
			}
		} else {
$84b2:
			if ($7da7.x != #ff) goto $84bf //bne $84bf
		}
$84b9:
	}
	return;

$84bf:
	$84c7();
	call_2e_9d53(a = #0a);
$84c7:
	$7e = x = 0;
	for (x;x != 8;x++) {
$84cb:
		a = $7ec4.x;
		a <<= 1; rol $7e;
	}
	return;
$84d7:
}
```
</details>

____________________
# $34:84d7 playEffect_0d
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	if ($7e9a >= 0) { //bmi 84e6
		if ($78d4 != 0) { //beq 84f5
			call_2e_9d53(a = #21); //fa0e
		}
	} else {
$84e6:
		dispatchPresenetScene_1f();	//$8545();
		if ($78d4 != 0) { //beq 84f5
			$7e = a;
			call_2e_9d53(a = #0d);
		}
	}
$84f5:
	return;
}
```
</details>

____________________
# $34:84f6 playEffect_0c
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	call_2e_9d53(a = #24);	//jmp $fa0e
}
```
</details>

____________________
# $34:84fb playEffect_0b
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$84fd(a = #1b);	//here $84fd:
}
```
</details>

____________________
# $34:84fd
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	push a;
	set52toActorIndexFromEffectBit();	//$34:8532();
	pop a;
	call_2e_9d53(a);
}
```
</details>

____________________
# $34:8505 
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	a = #1a;
	jmp $84fd;
}
```
</details>

____________________
# $34:850a playEffect_09 //charge (command0F)
<details>
<summary></summary>

### args:
+ [in] u8 $7e93 : effectFlag (1=ためすぎ 0=通常)

### (pseudo-)code:
```js
{
	set52toActorIndexFromEffectBit();	//$8532
	a = $7e93 + #16;
	return call_2e_9d53(); //fa0e
}
```
</details>

____________________
# $34:8516 effect08
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	set52toActorIndexFromEffectBit();//$8532
	targetBitToCharIndex(x = 1); //86ab
	$b8 = y;
	a = #19;
	call_2e_9d53(); //fa0e
	return $8689();
}
```
</details>

____________________
# $34$8528 effect06
<details>

### (pseudo-)code:
```js
{
	a = #15;
	return $84fd();
}
```
</details>

____________________
# $34$852d effect07
<details>

### (pseudo-)code:
```js
{
	a = #18;
	return $84fd();
}
```
</details>

____________________
# $34:8532 set52toActorIndexFromEffectBit
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	targetBitToCharIndex(x = #0);	//$34:86ab();
	$0052 = y;
}
```
</details>

____________________
# $34:853b playEffect_04
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$84fd(a = #4);	//jmp
}
```
</details>

____________________
# $34:8540 playEffect_05
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$84fd(a = #3);	//jmp
}
```
</details>

____________________
# $34:8545 dispatchPresentScene_1f
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$7e8f = $7e98;
	$7e90 = 3;
	return call_2e_9d53(a = #1f);
}
```
</details>

____________________
# $34:8576 playEffect_03
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	return;
}
```
</details>

____________________
# $34:8577 playEffect_01 
<details>
<summary></summary>

### args:
+ [in] u8 $7e88 : actionId
+ [in] u8 $7e98 : actors char bit?
+ [in] u8 $7e99 : selected targets ($6e[#2f])
+ [in] u8 $7e9a :	effect side
+ [in] u8 $7e9d : actionParam[6]; see $31:af77

### local variables:
+	$00c9 : playSoundFlag
+	$00ca : soundEffectId

### (pseudo-)code:
```js
{
	y = $7e88;
	$00ca = a = $83a0.y;
	$00c9 = 0;
	a = $7e9a;	//effect side
	if (a < 0) dispatchPresentScene_1f();	//$34:8545(); 
$858d:
	set52toActorIndexFromEffectBit();	//$34:8532();
	$7e89 = $7e99;	
	call_2e_9d53(a = #1d);
	doNothing_8689();	//$34:8689()
	a = $7e9a & #40;
	if (a == 0) return;  //beq $85ec

	a = $7e9d;	
	switch (a) {
	case 6:	//分裂系?
		a = $7e99;
		if (#ff == a) break;	//beq $85ec;
		$7e = a;
		return call_2e_9d53(a = #0c);
	case 7:
		$7e8f = $7e9b;
		$7e90 = 3;
		return call_2e_9d53(a = #22);
	case 8:
	case 0xd:
$85d2:		a = $7e9b;
		if (0 == a) break;	//beq $85ec;
		tagetBitToCharIndex(x = 3);	//$34:86ab();
		$b8 = y;
		$7e = $7e9b;
		return call_2e_9d53(a = #23);
	}
$85ec:	
	return;
}
```
</details>

____________________
# $34:8613 playEffect_00
<details>
<summary>

>たたかう・うたう
</summary>

### args:
+ [in] u8 $7e6f : targetside (0 = player)
+ [in] u8 $7e9a : effectSideFlags
+ [in] u8 $7e9b : targetBit
+ [in] u8 $bb,bc : hitCount

### (pseudo-)code:
```js
{
	$7e96 = x = 0;
	targetBitToCharIndex();	//$86ab();
	//if ((a = $7e9a) >= 0) $8647;
	if ($7e9a < 0) {
$8620:
		dispatchPresentScene_1f();	//$8545();
		//if ((a = $7e6f) == 0) $8637;
		if ($7e6f != 0) {
$8628:
			targetBitToCharIndex(x = 1);	//$86ab();
			$b8 = y;
			call_2e_9d53(a = #20);	//$fa0e
			return;	//jmp $8689
		}
$8637:
		targetBitToCharIndex(x = 1);	//$86ab();
		$0052 = y;
		call_2e_9d53(a = #14);
		return;	//jmp $8689
	} else {
$8647:
		$0052 = y;	//actor index
		//if ((a = $7e6f) == 0) $865e;
		if ($7e6f != 0) {
			targetBitToCharIndex(x = 1);	//$86ab();
			$b8 = y;
			call_2e_9d53(a = #12);
			return;	//jmp $8689
		}
$865e:
		$7e96++;
		push (a = $bb)
		push (a = $bc);
		$bb = $bc = 0;	//強制空振り
		call_2e_9d53(a = #12);
		x = 1;
		targetBitToCharIndex();	//$86ab();
		$0052 = y;
		$bc = pop a; //ヒット回数
		$bb = pop a;
		if ((a | $bc) != 0) { // beq 8689
$8684:
			call_2e_9d53(a = #14);
		}
	}
$8689:
	return;
$898a:
}
```
</details>

____________________
# $34:8689 doNothing_8689
<details>

### (pseudo-)code:
```js
{ return; }
```
</details>

____________________
# $34:868a showDamage
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	call_2e_9d53(a = #1c);
	$7e6f = ($7e9a rol 2) & 1
	for (x = 0;x != #10;x++) {
		$7e4f.x = $7e5f.x;
	}
	return call_2e_9d53(a = #1c);
$86ab:
}
```
</details>

____________________
# $34:86ab targetBitToCharIndex
<details>
<summary></summary>

### args:
+ [in] u8 $7e98.x : ?
+ [in] u8 X : side
+ [out] u8 Y : result index 

### (pseudo-)code:
```js
{
	y = 0;
	do {
		a = $7e98.x;
		if (a == $fd24.y) break;
	} while (++y != 0);
$86b8:
}
```
</details>


____________________
# $34:87be set_encounter_mode
<details>
<summary></summary>

### args:
+   [in] u8 $7ed8 : battle_mode (situation)
	- bit7 : boss
	- bit6 : magic forbidden
	- bit5 : on invincible
	- bit4 : freeze minimum status
	- bit0 : escape forbidden
+   [out] u8 $78ba :
+	[out] u8 $78c3 : battle_mode

### (pseudo-)code:
```js
{
    // omitted..
$87fb:
    $2a = $2b = $78c3 = $78ba = 0;
    if ( $7ed8 >= 0 && !($7ed8 & 0x20) ) { // bmi $886e and #$20 bne $886e
        $26 = 0x04;
        $28 = $886f();  //jsr $886f sta $28
        get_series1_random(a = 0x64);   //$a564()
        if ( a <= $28 ) {    //bcs $8824
            $2a++;
        }
$8824:        
        $24,25 = 0x7600;
        $26 = 0x08;
        $29 = $886f();
        get_series1_random(a = 0x64);
        if ( a <= $29 ) {   //bcs $8840
            $2b++;
        }
$8840:
        $2a++; $2b++;
        if ( $2a != $2b ) { //beq $886e
            if ( $2a <= $2b ) { //bcs $8852
                $78ba++;
                //jmp $886e
            } else {
$8852:
                $29 >>= 2;
                get_series1_random(a = $28);
                if ( a > $29 ) {    //bcc $8863
                    a = 0x80;
                    //bmi $8868
                } else {
                    $88a4();
                    a = 0x88;
                }
$8868:
                $78ba = $78c3 = a;
            }
        }
    }
$886e:
    return;
}
```
</details>

____________________
# $34:88e1 setPlayerPtrs
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$57,58 = #6100;
	$59,5a = #6200;
	$5b,5c = #7575;
	$5d,5e = #7675;
	return;
}
```
</details>

____________________
# $34:8902 loadCursorSprites
<details>
<summary></summary>

### args:
+ [in] $1a : destIndex (spriteIndex)
+ [out] $0220 : sprites[4]

### local variables:
	$891e(file:6892e) [4][4] = {
		F0 5A 03 F0  F0 59 03 F0
		F0 5C 03 F0  F0 5B 03 F0
	} : cursor sprites

### (pseudo-)code:
```js
{
	$4a,4b = #0220;
	y = a = $1a << 4;	//$3f:fd3e

	for (x = 0;x < 0x10;x++,y++) {
		$4a[y] = $891e.x;
	}
}
```
</details>

____________________
# $34:892e tileSprites2x2
<details>
<summary></summary>

### args:
+ [in] u8 $1a : spriteIndex
+ [in] u8 $1c : top
+ [in] u8 $1d : right
+ [out] u8 X : $1a << 4
+ [out] u8 $0220,$0223,$0224,$0227,$022b : ?

### (pseudo-)code:
```js
{
	x = $1a << 4; //fd3e()
	$0220.x = $1c;	//sprite[0].y
	$0223.x = $1d;	//sprite[0].x
$893e:	jmp $8941
$8941:
	x = $1a << 4; //fd3e()
	$0224.x = a = $0220.x;		//sprite[1].y = sprite[0].y
	a += 8;				
	$022c.x = $0228.x = a;		//sprite[2].y sprite[3].y
	$022b.x = a = $0223.x;		//sprite[2].x = sprite[0].x
	a -= 8;	
	$0227.x = $022f.x = a;		//sprite[1].x sprite[3].x
}
```
</details>

____________________
# $34:8966 loadAndInitCursorPos
<details>
<summary></summary>

### args:
+ [in] u8 $1a : destIndex (spriteIndex)
+ [in] u8 $55 : cursorPositioningType
+ [in] u16 $34:8afa(file:68b0a) : initCursorParamPtrs { right,top }
+ [out] u8 $22,23,0050,0051 : 0
+ [out] u8 $0220+(destIndex*4) : cursorSprites
+ [out] u8 X : destOffset

### (pseudo-)code:
```js
{
	$55,56 = #8afa + ($55 << 1);
	push (a = $55[y = 0] );
	$56 = $55[++y]; $55 = pop a;
	$22,$23,$0050,$0051 = 0;

	loadCursorSprites();	//$34:8902();

	y = 0;
	$1c = $55[y++];
	$1d = $55[y];
	return tileSprites2x2(dest:$1a, top:$1c, right:$1d);	//jmp $892e
}
```
</details>

____________________
# $34:8990
<details>

### (pseudo-)code:
```js
{
	$1c = $55[y = 0];
	$1d = $55[++y];
	return tileSprites2x2();	//jmp $892e
}
```
</details>

____________________
# $34:899e getInputAndUpdateCursorWithSound
<details>
<summary>

>各種入力ウインドウにおいて、パッド入力を取得し対応する動作を行う(十字キーなら音ともに移動・ABなら音を鳴らして戻る)
</summary>

### args:
+ [in] u8 $1a : cursorId
+ [in] u8 $1b : rightend (with this value not included)
+ [in,out] u8 $22 : col
+ [in,out] u8 $23 : row
+ [out] u8 $50[$1a] : inputBits (only a,b,left,right;otherwise unchanged)

### notes:
[commandWindow_dispatchInput]

### (pseudo-)code:
```js
{
	$1e,1f = #8acf;
	$21 = 0;
	do {
$89aa:	
		presentCharacter();	//$34:8185();
		getPad1Input();//$3f:fbaa();
	} while ((a = $12) == 0);
$89b4:
	push (a)
	playSoundEffect18();	//set$ca_18_and_increment_$c9();	//$34:9b79();
	pop a;	//input bits
	for($21;;$21++) {
$89b9:		a >>= 1;
		if (carry) break;
	}
$89c0:	//$21 = 押されたボタンのビット番号 (A=0,B=1,)
	$1e,1f += ($21 << 1);	//$1e = #8acf
	$1e,1f = *($1e,1f)
	(*$1e)();	//funcptr
$89de:
}
```
</details>

____________________
# $34:89de getInputAndUpdateCursor_OnB
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$0050.(x = $1a) = #02;
	return;
}
```
</details>

____________________
# $34:89e6 getInputAndUpdateCursor_OnA
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$0050.(x = $1a) = #01;
	return;
}
```
</details>

____________________
# $34:89ee getInputAndUpdateCursor_OnUp
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	if ((a = $23) != 0) $8a0a
	if ((a = $1b) != 0) $8a32
	$23 = 3;
	$55,56 += 6;
	goto $8ac1;
$8a0a:
	$23--;
	if ((a = $23) != 2) $8a25;
	if ((a = $38) == 0) $8a25;
$8a17:
	$55,56 -= 2;
	$23--;
$8a25:
	$55,56 -= 2;
$8a32:
	goto $8ac1;
}
```
</details>

____________________
# $34:8a82 getInputAndUpdateCursor_OnLeft
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	if ((a = $22) != 0) { //beq $8a95
		$22--;
		$55,56 -= #0008;
	}
$8a95:
	$0050.(x = $1a) = #40;
	goto $8ac1;
}
```
</details>

____________________
# $34:8a9f getInputAndUpdateCursor_OnRight
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	if ($22 != $1b) { //beq $8ab4
		$22++;
		$55,56 += #0008;
	}
$8ab4:
	$0050.(x = $1a) = #80;
	goto $8ac1;
}
```
</details>

____________________
# $34:8abe getInputAndUpdateCursor_OnStartOrSelect
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	return $34:8990();	//jmp
}
```
</details>

____________________
# $34:8ac1 getInputAndUpdateCursor_end
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$1c = $55[y = 0];
	$1d = $55[++y];
	return tileSprites2x2(dest:$1a, top:$1c, right:$1d);	//$892e
}
```
</details>

____________________
# $34:8acf moveSelection_dispatchInput_inputHandlers[8]
<details>
<summary></summary>


____________________
# $34:8adf init4SpritesAt$0220
<details>
<summary></summary>

### (pseudo-)code:
```js
{
+ [in] u8 $18 : sprite index
+ [out] u8 $0220[0x10][$18<<4] : filled with #f0

	$4a,4b = #0220;
	a = $18;
	a <<= 4;	//$3f:fd3e();
	y = a;
	a = #f0;
	for (x = 0;x != 0x10;x++) {
		$4a[y++] = a;
	}
}
```
</details>

____________________
# $34:8b38 draw8LineWindow
<details>
<summary></summary>

### args:
+ [in] u8 $18 : left (border incl)
+ [in] u8 $19 : right (border incl)
+ [in] u8 $1a : behavior[xxxxxxba] (a:put left-border,b:put right-border)
+ [in] u16 $7ac0 : ptr to charTileArray ()

### (pseudo-)code:
```js
{
	push(a = $19);
	$1d = a & #7f;
	push(a = $18);
	$1c = a & #7f;
	$1e = pop a & #80;
	$1e ^= pop a & #80;	// (init$18 & #80 ^ init$19 & #80)
	if (a == 0) {	//bne $8b64;
$8b52:
		$78b8 = $1d - $1c - 1;//right - left - 1
		$78b9 = 0;
	} else {
$8b64:
		$78b8 = #1f - $1c;	//#1f - left
		$78b9 = $1d + #20 - $1c - 1 - $78b8;	//right+#20-left-1-width
	}
$8b7c:
	$2e,2f = $7ac0,7ac1;
	push (a = $18);
	a &= #80;
	if (0 == a) $2a,2b = pop a + #2260;
$8b9c:	else $2a,2b = #2660 + (pop a & #7f);
$8baa:
	a = $19 & #80;
	if (a == 0) $2c,2d = #2260;
$8bbb:	else $2c,2d = #2660;
$8bc3:
	$30 = 8;
	$1e = $1b = 1;
	putWindowTopBottomBorderTile();	//$34:8c84();
	for ($30;$30 != 0;$30--) {
$8bd0:
		presentCharacter();	//$34:8185();
		setVramAddr(high:a = $2b,low:x = $2a);	//$3f:f8e0
		putWindowSideBorderTile();	//$34:8c56();
$8bdd:
		y = 0; 
		for (x = $78b8;x != 0;x--) { //if (x == 0) $8bed;
$8be4:
			$2007 = $2e[y++];
		}
$8bed:
		x = $78b9;
		if (x == 0) { //$8bf8;	//bne
$8bf2:
			putWindowSideBorderTile();	//$34:8c56();
			//clc bcc 8c11
		} else {
$8bf8:
			$2006 = $2d;	//vram high
			$2006 = $2c;	//vram low
			setBackgroundProperty();	//$34:8d03();
			for (x; x != 0;x--) {
$8c05:
				$2007 = $2e[y++]
			}
			putWindowSideBorderTile();	//$34:8c56();
		}
$8c11:
		$2a,2b += #0020;
		$2c,2d += #0020;
		$2e,2f += $78b8;	//下位
		$2e,2f += $78b9;	//下位
		setBackgroundProperty();	//$34:8d03();
	}	//beq $8c53;
$8c53:
	return putWindowTopBottomBorderTile();	//$34:8c84();
}
```
</details>

____________________
# $34:8c56 putWindowSideBorderTile
<details>
<summary></summary>

### args:
+ [in,out] u8 $1b : side (1:left 0:right)  (toggled on each call)

### (pseudo-)code:
```js
{
	$1c = #fa;	//左枠線
	$1b = a = $1b ^ 1;
	$1c += a;	//#fa or #fb

	if (0 == (a = $1b)) { a = $1a >> 1; }
	else { a = $1a >> 2; }
	if (!carry) {
$8c77:
		$2007 = #ff;
	//bne $8c83
$8c7e:	} else {
		$2007 = $1c;
	}
$8c83:	return;	
	
}
```
</details>

____________________
# $34:8c84 putWindowTopBottomBorderTile
<details>
<summary></summary>

### args:
+ [in] u8 $1a : behavior [xxxxxxba] (a:put left-corner b:put right-corner)
+ [in,out] u8 $1e : vertical-side (1:top 0:bottom) ; toggled on each call
+ [in,out] u16 $2a : vramAddr
+ [in,out] u16 $2c : vramAddrForExtra
+ [in] u8 $78b8 : width (without border)
+ [in] u8 $78b9 : extraWidth

### (pseudo-)code:
```js
{
	$1d = #f7;	//border-topleft 
	$1e = a = $1e ^ 1;
	a <<= 2;	//$fd40
	$1d += ($1e + a);	//0 or 5
	presentCharacter();	//$34:8185();
	setVramAddr(high:a = $2b,low:x = $2a);	//$3f:f8e0
	setBackgroundProperty();	//$34:8d03();
	x = $1d;
	a = $1a >> 1;
	if (!carry) x++; //bcs$8cad
$8cad:	
	$2007 = x;	
	$1d++;
	for (x = $78b8;x != 0;x--) {	//if (x == 0) $8cbf;
$8cb9:		$2007 = $1d;
	}
$8cbf:
	x = $78b9;
	if (x != 0) {	//beq $8cd9
		$2006 = $2d; $2006 = $2c;
		setBackgroundProperty();	//$34:8d03();
		for (x;x != 0;x--) {
$8cd3:
			$2007 = $1d;
		}
	}
$8cd9:
	a = $1a >> 2;
	if (carry) $1d++; //bcc $8ce1
$8ce1:	
	$2007 = $1d;
	$2a,2b += #0020;
	$2c,2d += #0020;
	return setBackgroundProperty();	//jmp $34:8d03
$8d03:
}
```
</details>

____________________
# $34:8d03 setBackgroundProperty
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	bit $2002;
	$2000 = a = $06;	//PPU ctrl 1
	$2001 = a = $09;	//PPU ctrl 2
	$2005 = a = $0c;	//BG scroll (x)
	$2005 = a = $0d;	// (y)
}
```
</details>

____________________
# $34:8d1b draw1RowWindow
<details>
<summary>
vramの指定位置にcx文字がちょうど収まる大きさの1行ウインドウを描画する
</summary>

### args:
+ [in] u8 A : windowId
+ [in] u16 $7ac0 : stringPtr

### local variables:
+	Draw1LineWinowParam $8e33.x

### notes:
描画の際描画前の画像(タイル番号)を指定の場所に保存する
対象文字列の長さは特に考慮しない

### (pseudo-)code:
```js
{
	$18 = a;
	a <<= 3;	//$3f:fd3f();
	x = a + $18;	//a * 9
	$18 = $60 = $8e83.x; x++;
	$19 = $61 = $8e83.x; x++;
	$78b8 = a = $8e83.x;
	$78b9 = a + 2; x++;
	$1a = $8e83.x; x++;
	$1b = $8e83.x;
	y = 0;
	$1c = a = 4;
	for ($1c = 4;$1c != 0;$1c--) {
$8d52:		presentCharacter();	//$34:8185();
		a = $19; x = $18;
		setVramAddr();	//$3f:f8e0();
		a = $2007;

		for (x = $78b9;x != 0;x--) {
$8d62:			a = $2007;
			$1a[y] = a; y++;
		}
$8d6b:		
		$18,19 += #0020;
		setBackgroundProperty();	//$34:8d03();
	}
$8d81:
	//$1a = #f7; $1b = #f8; $1d = #f9;
	drawBorder(left=#f7,mid=#f8,right=#f9);	//$34:8de5();
	$18,19 = $7ac0,7ac1;	//ptr to string
	for ($1c = 2,y = 0;$1c != 0;$1c--) {
$8da0:		presentCharacter();	//$34:8185();
		a = $61; x = $60;
		setVramAddr();	//3f:f8e0
		$2007 = #fa;
		for (x = $78b8;x != 0;x--) {
$8db2:			$2007 = a = $18[y]; y++;
		}
$8dbb:
		$2007 = a = #fb;
		$60,61 += #0020;
		setBackgroundProperty();	//$34:8d03();
	}
$8dd6:
	//$1a = #fc; $1b = #fd; $1d = #fe;
	return drawBorder(left=#fc,mid=#fd,right=#fe);	//jmp $34:8de5();
$8de5:
}
```
</details>

____________________
# $34:8de5 drawBorder
<details>
<summary></summary>

### args:
+ [in] u8 $78b8 : midCharLength
+ [in] u8 $1a : leftMostChar
+ [in] u8 $1b : middleChar
+ [in] u8 $1d : rightMostChar
+ [in,out] u16 $60,61 : vramAddr (32bytes/row)

### (pseudo-)code:
```js
{
	presentCharacter();	//$34:8185();
	a = $61; x = $60;
	setVramAddr();	//3f:f8e0
	$2007 = $1a;
	for (x = $78b8,a = $1b;x != 0;x--) {
$8df9:		$2007 = a;
	}
$8dff:
	$2007 = $1d;
	$60,61 += #0020;
$8e11:	setBackgroundProperty();	//$34:8d03();
$8e14:
}
```
</details>

____________________
# $34:8eb0 eraseWindow
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$18 = #2380;
	$1a = #2780;
	y = #a;
	for (y = 10;y != 0;y--) {//下から1行ずつ消していく
$8ec2:
		presentCharacter();	//$34:8185();
		a = $19; x = $18;
		setVramAddr();	//$3f:f8e0();
		setBackgroundProperty();$34:8d03
		a = 0;
		for (x = 0x20;x != 0;x--) {
			$2007 = a;	//write to vram
		}
$8eed:
		$18,19 -= #0020;
		$1a,1b -= #0020;
	}
$8f0a:	return;
}
```
</details>

____________________
# $34:8f0b eraseFromLeftBottom0Bx0A	//[eraseItemWindowColumn]
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$18,19 = #2380;
	for (x = #0a;x != 0;x--) {
$8f15:		presentCharacter();	//$34:8185
		bit $2002;
		$2006 = $19; $2006 = $18;	//vramAddr.high,vramAddr.low
		setBackgroundProperty();	//$34:8d03();
		for (a = 0,y = #b;y != 0;y--) {
$8f2c:			$2007 = a;
		}
		$18,19 -= #0020;
	}
$8f42:	return;
$8f43:
}
```
</details>

____________________
# $34:8f57 getSortedIndex
<details>
<summary></summary>

### args:
+ [in] u8 $1a : base?
+ [in] ptr $1c : keys
+ [in] ptr $1e : result indices
+ [in] u8 $22 : len

### (pseudo-)code:
```js
{
	push (a = $22);
	x = a - $1a;	//len - base
	$18 = ++x;	//len - base + 1
	y = 1;
	for (x = 0;x != $18;x++) {
		a = x;
		$1e[y] = a;
		y++;
	}
	pop a;	//len?
	//fall through
```
</details>

**fall through**
____________________
# $34:8f6f sort
<details>
<summary></summary>

### args:
+ [in] u8 a : end
+ [in] u8 $1a : begin
+ [in] ptr $1c : keys
+ [in] ptr $1e : values
+	u8 $18 : begin
+	u8 $19 : end
+	u8 $1a : firstLesserKeyIndexInFront
+	u8 $1b : firstGreaterKeyIndexInBack
+	u8 $20 : pivot (key of begin)

### notes:
sorts descending (greater key first)

### (pseudo-)code:
```js
{
	$1b = a;	//len? or end?
	push (a = $18);
	push (a = $19);
	push (a = x);
	$18 = x = $1a;	//begin?
	$19 = y = $1b;	//end?
	$20 = $1c[y = $1a];	//key of begin (pivot)
$8f87:
	y = $1b;
	//end < leastIndex ?	
	if (y < $1a) $8fd3;	//bcc 8fd3
$8f8d:
	while ($1c[y] < $20) { y--;}
	//if ($1c[y] >= $20) $8f96;	//bcs
	//y--;
	//goto $8f8d;	//bcc
$8f96:
	$1b = y;	//後ろから探して最初に見つかった 先頭の値以上の値位置
	y = $1a;	//begin
$8f9a:
	while ($1c[y] > $20) { y++; }	//$8fa5;	//beq bcc
$8fa2:
$8fa5:
	$1a = y;	//先頭から探して最初に見つかった 先頭の値以下の値の位置
	//greaterIndexInBack < lesserIndexInFront?
	if ( (y = $1b) < $1a) $8fd3;	//bcc
$8fad:
	x = $1c[y];	//y:$1b = greaterInBack;
	$21 = $1e[y];	//key
	$1c[y = $1b] = $1c[y = $1a];	// greatertIndex = lesserValue
	$1e[y = $1b] = $1e[y = $1a];	// greaterKey = lesserKey
	$1e[y = $1a] = $21;		// lesserKey = greaterKey
	$1c[y] = x;	//y:$1a		// lesserValue = greaterValue
	//narrow ranges
	$1b--;	//back
	$1a++;	//front
	goto $8f87;	//bcs;always satisfied( last affecting op is: $8fa9 cpy $1a)
$8fd3:
	x = $1a;	//leastIndex
	//greatsetIndex <= begin?
	if (y <= $18) $8fe3;	//beq bcc
$8fdb:
	$1a = $18;	//nextBegin = begin
	a = y;		//nextEnd = greatestIndex
	$8f6f();	//recurse
$8fe3:
	//leastIndex >= end?
	if (x >= $19) $8fee;	//bcs
$8fe7:
	$1a = x;	//nextBegin = leastIndex
	a = $19;	//nextEnd = end
	$8f6f();	//recurse
$8fee:
	x = pop a;
	$19 = pop a;
	$18 = pop a;
	return;
$8ff7:
}
```
</details>

____________________
# $34:8ff7 presentBattle
<details>
<summary></summary>

### args:
+ [in] u8 $7ec2 : set by commandHandler; usually commandId
	- prizeMessage = 2
	- toadCastsToad = 18	
+ [in] u8 $78d5 : commandChianId
	- (0-5: 0=attack 1=action 2,4=prize)
+ [in] u8 $78da[] : message id queue?

### local variables:
+	u16 $34:950d[<0x20] : dispCommandListPtrTable
+	u16 $34:954d[?] : dispCommandHandlerTable
+	u8 $7ad7[0x14] : string
+	u16 $62 : dispCommandListPtr
+	u8 $64 : currentDispCommandIndex

### (pseudo-)code:
```js
{
	a = $7ec2;
	if (a != 0) {
		a = $78d5 << 1;
		$18,19 = #950d + a;
		$62,63 = *($18,19);
		$78ef,78ee,64 = x = 0;
		for (;;) {
$9020:			initTileArrayStorage();	//$34:9754();
			a = 0;
			for (x = 0x13;x >= 0;x--) {
$9027:				$7ad7.x = a;
			}
$902d:			y = $64;
			$4b = a = $62[y];
//$4b : dispCommand
//	04,02,01,00 : closeWindow?
//	03 : closeMessageWindow?
//	05 : showActorName?
//	06 : showHitCount?/actionName (ex.3かいヒット)
//	07 : showTargetName?	(ex.ぜんたい)
//	08 : showEffectMessage? (ex.めがみえる!)
//	09 : showMessage?	(ex.からだがじょじょにせきかする)
//	0a : waitForAButtonDown
//	0b : effectOnTarget?
//	0c : damage
//	0d : dyingEffect?
//	0e :
			if (#ff == $4b) break;
$9037:
			a <<= 1;
			$18,19 = #954d + a;
			$1a,1b = *($18,19);
			(*$1a)();	//funcptr
$9051:			$64++;
		}
	}
$9056:
	a = #25;
	return call_2e_9d53(a = #25);	//jmp $3f:fa0e();
$905b:
}
```
</details>

____________________
# $34:905b dispCommand_05_showActorName
<details>
<summary></summary>

### args:
+ [in] u16 $57 : playerPtr
+ [in] u8 $78d6 : charIndex
+ [in] u8 $7ecd[] : enemy group id?
+ [in] u8 $7d6b[4] : enemy ids

### (pseudo-)code:
```js
{
	if ((a = $78d6) < 0) {
		if (a == #ff) $909d;
		x = a & #7f;
		x = a = $7ecd.x;
		$1a = $7d6b.x;
		setTableBaseAddrTo$8a40();	//$34:95bd()
		loadString(index:a = $1a, dest:x = 0, base:$18);
	} else {
$907d:
		a <<= 6;	//$3f:fd3c();
		y = a + 6;
		for (x = 0;x != 6;x++) {
$9086:			
			$7ad7.x = $57[y++];
		}
	}
$9091:
	strToTileArray($18 = 8);	//966a
	draw1RowWindow(a = 0);		//8d1b
$909d:
	return;	//jmp $9051
$90a0:
}
```
</details>

____________________
# $34:90a0 dispCommand_06_showActionName
<details>
<summary></summary>

### args:
+ [in] u8 $72 : isEquipmentUsed
+ [in] u8 $78d7 : messageId (#ff : no display,#80> : specialAction)

### (pseudo-)code:
```js
{
	a = $72;
	if (a != 0) {
		//アイテム
		loadString(index:a = $78d7, dest:x = 0, base:$18 = #8800);
		for (x = 0;x != 9;x++) {
$90b6:			$7ad7.x = $7ad8.x;	//先頭の記号スペースを飛ばす
		}
		strToTileArray($18 = 8);//966a
		draw1RowWindow(a = 1);	//8d1b
		return;	//jmp $9051
	}
$90d0:
	a = $78d7;
	if (a < 0) goto $9150;
$90d8:	elif (a == 0) $9143;
	elif (a < #21) $9121;
	elif (a < #39) $910f;
	elif (a < #52) $90fd;
$90e6:	else {	//[#52-#7f]	//"そせい" "せきかかいふく" etc
		a -= #46; $1a = a;
		loadString(index:a = $1a, dest:x = 0, base:$18 = #8200);
		goto $34:9168;
	}
$90fd:	{	//[#39-#51]	//行動名
		a -= #39; $1a = a;
		setTableBaseAddrTo$8c40();	//95c6()
		loadString(index:a = $1a, dest:x = 0, base:$18);
		goto $34:9168;
	}
$910f:	{	//[#21-#38]  	//召還
		a += #c6; $1a = a;
		setTableBaseAddrTo$8a40();	//$34:95bd()
		loadString(index:a = $1a, dest:x = 0, base:$18);
		goto $34:9168;
	}
$9121:	{	//[#01-#20]	//"かいヒット"
		$18 = a; $19 = 0;
		itoa_16();	//$34:95e1();
		for (x = 0;x != 3;x++) {
			$7ad7.x = $1d.x;
		}
$9136:		setTableBaseAddrTo$8c40();	//95c6
		loadString(index:a = #13, dest:x = 2, base:$18);
		goto $9168;
	}
$9143:	{	//[#00]	//"ミス!"
		setTableBaseAddrTo$8c40();
		loadString(index:a = #09, dest:x = 0, base:$18);
		goto $9168;
	}
$9150:	{	//[#80-#ff]	//行動名(魔法・特殊)
		if (a == #ff) return;
		a -= #80; $1a = a;
		loadString(index:a = $1a, dest:x = 0, base:$18 = #8990);
	}
$9168:
	strToTileArray($18 = 8);	//966a
	draw1RowWindow(a = 1);		//8d1b
$9174:	return;	//jmp $9051
$9177:
}
```
</details>

____________________
# $34:9177 dispCommand_07_showTargetName
<details>
<summary></summary>

### args:
+ [in] u16 $57 : playerPtr
+ [in] u8 $78d8 : targetCharIndex
+ [in] u8 $7ecd[] : enemy group id?
+ [in] u8 $7d6b[4] : enemy ids?

### (pseudo-)code:
```js
{
	a = $78d8;
	if (a < 0) {
		if (a == #ff) $91cb;
		a &= #7f;
		if (a == 8) {
			$1a = #16;	//"ぜんたい"?
			setTableBaseAddrTo$8c40();	//95c6
		} else {
$9190:			x = a; a = $7ecd.x;
			x = a; a = $7d6b.x
			if (a == #ff) $91cb;
			$1a = a;
			setTableBaseAddrTo$8a40();	//$34:95bd()
		}
$91a1:		loadString(index:a = $1a, dest:x = 0; base:$18);
	} else {
$91ab:
		a <<= 6;	//$fd3c;
		y = a + 6;
		for (x = 0;x != 6;x++) {
$91b4:
			$7ad7.x = $57[y++];
		}
	}
$91bf:
	strToTileArray($18 = 8);	//966a
	draw1RowWindow(a = 2);		//8d1b
	return;		//jmp $9051
$91ce:
}
```
</details>

____________________
# $34:91ce setNoTargetMessage
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	return $78d8 = a = #ff;
$91d4:
}
```
</details>

____________________
# $34:91d4 dispCommand_08_show_effect_message
<details>
<summary></summary>

### args:
+ [in] u8 $78d9 : effect id? (#ff = display nothing)

### (pseudo-)code:
```js
{
	a = $78d9;
	if (a == #ff) return; //beq $91fb
	$1a = a + #0c;
	loadString(index:a = $1a, dest:x = 0, base:$18 = #8200);	//a609
	strToTileArray($18 = 8);	//966a
	draw1RowWindow(a = 3);
$91fb:	return;		//jmp $9051
$91fe:
}
```
</details>

____________________
# $34:91fe dispCommand_09_show_message
<details>
<summary></summary>

### args:
+ [in] u8 $78da.x : message queue?(item=message id;#ff = display nothing)
+ [in] u16 $78e4.x : message params
+ [in] u8 $78ee : queue index?
+ [in] u8 $78ef : message param index?

### (pseudo-)code:
```js
{
	$18 = 0; 
	x = $78ee; a = $78da.x;
	if (#ff == a) return;	//beq $91fb
	//a : message, valid range = 00-8f
	a >>= 1; ror $18;
	x = a;
	a = $9575.x;	//x : higher 7bits of $78da.$78ee
	$18 <<= 1;	//$18 : bit7 is lsb of $78da.$78ee
	if (!carry) { a >>= 4; //$3f:fd45(); }
$921a:	a &= #f;
//here a : 
//	lsb of $78da.$78ee == 1 then $9575.x & #f
//	otherwise $9575.x >> 4
 
	$18 = #956b + (a << 1);	
	$1a,1b = *($18,19);
	(*$1a)();	//jumptable
$9236:
	$78ee++;
	return;	//jmp $9051
$923c:
}
```
</details>

____________________
# $34:923c dispCommand09_sub00
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	loadStatusMessage();	//$34:9245();
	drawMessageWindow();	//$34:9253();
	return;	//jmp $9236
$9245:
}
```
</details>

____________________
# $34:9245 loadStatusMessage?
<details>
<summary>

>load string using table $18:8c40
</summary>

### (pseudo-)code:
```js
{
	setTableAddrTo$8c40();	//$34:95c6();
	x = $78ee;	
	loadString(index:a = $78da.x, dest:x = 0, base:$18);	// $35:a609();
$9253:
}
```
</details>

____________________
# $34:9253 drawMessageWindow
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	strToTileArray($18 = #11); //$34:966a();
	draw1RowWindow(a = #4); //$34:8d1b();
$925f:
}
```
</details>

____________________
# $34:925f dispCommand09_sub01
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	loadStatusMessage();	//$34:9245();
	drawMessageWindow();	//$34:9253();
	waitPad1Input();	//$34:926b();
	return;	//jmp $9236
$926b:
}
```
</details>
____________________
# $34:926b waitPad1ADown
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	do {
		getPad1Input();	//$3f:fbaa();
	} while (0 == (a = $12 & 1) );
$9275:
}
```
</details>
____________________
# $34:9275 dispCommand09_sub02
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	a = #c5;	//'?'
	for (x = 0xd;x >= 0;x--) {
		$7ad7.x =  a;
	}
	// 0123456789abcd
	//"HP_?????/?????"
	$7ad7 = #77; $7ad8 = #79; $7ad9 = #ff; $7adf = #c7;
	a = $6e[y = #30];
	if (a >= 0 || (0 >= (a = $7ed8) ) {
$929e:
		$24 = 3; $34:92b5();
		$24 = 9; $34:92b5();
	}
$92ac:	drawMessageWindow();	//$34:9253();
	waitPad1Input();	//$34:926b();
	return;	//jmp $9236
$92b5:
}
```
</details>

____________________
# $34:92b5 printHp
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	x = $78ef;
	$18 = $78e4.x
	x++;
	$19 = $78e4.x
	x++;
	$78ef = x;
	itoa_16();	//95e1
	for (x = $24,y = 0;y != 5;x++,y++) {
$92ce:
		$7ad7.x = $1a.y;
	}
	return;
$92db:
}
```
</details>

____________________
# $34:92db dispCommand09_sub03
<details>
<summary></summary>

can be thought as exactly like %u%s

### (pseudo-)code:
```js
{
	x = $78ef;
	$18 = a = $78e4.x; x++;
	$19 = a = $78e4.x; x++;
	$78ef = x;
	itoa_16();	//$34:95e1();
	x = y = 0;
	for (x = 0,y = 0;x != 5;x++) {
$92f4:		a = $1a.x;
		if (#ff != a) {
			$7da7.y = a; y++;
		}
$92fe:
	}
	$2a = y;
	setTableBaseAddrTo$8c40();	//$34:95c6();
	x = $78ee; 
	loadString(index:a = $78da.x, dest:x = $2a, base:$18); //a609
	strToTileArray($18 = #11); //$34:966a();
	draw1RowWindow(a = #4); //$34:8d1b();
	getPad1Input();	//$3f:fbaa();
	a = $12 & 1;
	return; //jmp $9236
$932b:
}
```
</details>

____________________
# $34:932b dispCommand09_sub04
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	loadStatusMessage();	//$34:9245();
	$2a = x;
	loadString(index:a = $78e4,dest:x = $2a,base:$18 = #8800); //$35:a609
	$7adc = #ff;	//6th char
	drawMessageWindow();	//$34:9253();
	waitPad1Input();	//$34:926b();
	return;	//jmp $9236
$934e:
}
```
</details>

____________________
# $34:934e dispCommand_0B
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	playEffect();	//$34:8411();
	return;	//jmp $9051
}
```
</details>

____________________
# $34:9354 dispCommand_0C
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$7ec2 = #17;
	playEffect();	//$34:8411();
	return;	//jmp $9051
}
```
</details>

____________________
# $34:935f dispCommand_0D	//dying effect?
<details>
<summary></summary>

### args:
+ [in] u8 $78d3 : ?

### (pseudo-)code:
```js
{
	a = $78d3 & 2;
	if (a != 0) return;	//bne $93c1;
$9369:	
	getActor2C();	//$35:a42e();
	if (a >= 0)  {	//bmi $9392;
$936e:
		a = $6e[y = #30];	//actor.30
		if (a >= 0) {	//bmi $9383;
$9374:
			setTableBaseAddrTo$00e0();	//$34:95cf
			$34:93cd();
			setTableBaseAddrTo$00f0();	//$34:95d8
			$34:93cd();
$9383:		} else {
			setTableBaseAddrTo$00f0();	//$34:95d8
			$34:93cd();
			setTableBaseAddrTo$00e0();	//$34:95cf
			$34:9408();
		}
	} else {
$9392:		
		a = $6e[y = #30];	//actor.30
		if (a >= 0) {	//bmi $93a7;
$9398:
			setTableBaseAddrTo$00e0();	//$34:95cf
			93cd;
			setTableBaseAddrTo$00f0();	//$34:95d8
			9408;
$93a7:		} else {
			setTableBaseAddrTo$00f0();	//$34:95d8
			9408;
			setTableBaseAddrTo$00e0();	//$34:95cf
			9408;
		}
	}
$93b3:
	$34:9474();
	$34:9d06();
$93b9:	$7ec2 = #16;
	playEffect();	//$34:8411();
$93c1:
	return;	//jmp $9051
}
```
</details>

____________________
# $34:93c4 dispCommand_0E
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	setTableBaseAddrTo$00e0();	//$34:95cf();
	updateEnemyStatus();	//$34:9408();
	jmp $93b9();
$93cd:
}
```
</details>

____________________
# $34:93cd updatePlayerStatus
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	for ($52 = 0;$52 != 4;$52++) {
$93d1:
		y = updatePlayerOffset();	//$a541
		$1a = ++y;
		push ( y = a = $52 << 1);
		a = $18[y]
		y = $1a
		$5b[y] |= a;
		if ((a & #80) != 0) { //$93f3
$93e9:
			$5b[y] &= #fe;
			pop a;
			goto $93ff;
		} else {
$93f3:
			y = pop a;
			a = $18[++y];
			y = $1a; y++;
			$5b[y] |= a;
		}
$93ff:
	}
$9407:
	return;
$9408:
}
```
</details>

____________________
# $34:9408 updateEnemyStatus
<details>
<summary></summary>

### args:
+ [in] u16 $18 : ptr to status to apply
+ [out] u8 $7ec4[8] : status

### local variables:
+	u16 $1e : enemyptr

### (pseudo-)code:
```js
{
	$1c = 0;
	$1e,1f = #7675;
	for ($1c = 0;$1c != 8;$1c++) {
$9414:
		$1a = $1c << 1;
		a = $18[y = $1a] | $1e[y = 1];
		$1e[y] = a;
		a &= #e8;
		if (0 != a) {
			x = $1c;
			$7ec4.x = $1e[y] = a | #80;
		}
$942f:	
		y = $1a; y++;
		a = $18[y];
		$1e[y = 2] |= a;
		$1e,1f += #40;
	}
$944f:
	return;
$9450:
}
```
</details>


____________________
# $34:9450 dispCommand_0A_waitForAButtonDownOrMessageTimeOut
<details>
<summary></summary>

### args:
+ [in] u8 $6010 : ?

### (pseudo-)code:
```js
{
	a = 8 - $6010;	//user option:message speed?
	a <<= 3;	//$fd3f()
	$24 = a;
	if (a == 0) return;	//beq $9471
	do {
$945f:
		presentCharacter();	//$34:8185();
		getPad1Input();		//$3f:fbaa();
		a = $12 & 1;
		if (a != 0) break;	//bne $9471;
	} while (--$24 != 0);
$9471:
	return;	//jmp $9051
$9474:
}
```
</details>

____________________
# $34:94d6 dispCommand_00010204_closeWindow
<details>
<summary>

>現在のコマンド番号に対応するウインドウを消す
</summary>

### args:
+ [in] u8 $78d6[] : dispCommandParams
+ [in] u8 $4b : currentDispCommand

### notes:
コマンド番号:
+ 00:行動者
+ 01:行動名
+ 02:効果対象
+ 03:追加効果 
+ 04:メッセージ

### (pseudo-)code:
```js
{
	x = $4b;
	a = $78d6.x;
	if (a == #ff) return;	//beq $94e4
	$34:8e14(a = $4b);	//
$94e4:
	return;	//jmp $9051
}
```
</details>

____________________
# $34:94e7 dispCommand_03_back4or5CommandIfMessageRemainsElseClose
<details>
<summary>
キューにまだ表示すべきメッセージがあるなら
メッセージ表示コマンド(=09)の位置まで現在位置($64)を戻す
なければメッセージ用ウインドウ(左下の奴)を消す
</summary>

### args:
+ [in] u8 $78d5 : commandChainId
+ [in] u8 $78da[] : dispCommandParams (for message window)
+ [in] u8 $78ee : current queue index

### notes:

### (pseudo-)code:
```js
{
	x = $78ee;
	a = $78da.x;
	if (a == #ff) jmp dispCommand_00010204();
$94f4:
	a = $78d5;
	if (a == 0) {
		$64 -= 4;
		return;
	}
$9503:
	$64 -= 5;
	return;	//jmp $9051
$950d:
}
```
</details>

____________________
# $34:954d functionTableFor$8ff7_presentBattle[0x0e]
<details>
<summary></summary>
</details>

____________________
# $34:95bd setTableBaseAddrTo$8a40
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$18,19 = #8a40;
}
```
</details>

____________________
# $34:95c6 setTableBaseAddrTo$8c40
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$18,19 = #8c40;
}
```
</details>

____________________
# $34:95cf setTableBaseAddrTo$00e0
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$18,19 = #00e0;
}
```
</details>

____________________
# $34:95d8 setTableBaseAddrTo$00f0
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$18,19 = #00f0;
}
```
</details>

____________________
# $34:95e1 itoa_16
<details>
<summary></summary>

### args:
+ [in]	u16 $18 : value
+ [out]	u8 $1a[5] : tileArray (higher digit first)

### (pseudo-)code:
```js
{
	for (a = #80,x = 3;x >= 0;x--) {
$95e5:		$1a.x = a;	//#80 = '0'
	}
	$1f = x;
	$20 = #2710; countAndDecrementUntil0(); //$34:9648();
	$20 = #03e8; countAndDecrementUntil0(); //$34:9648();
	$20 = #0064; countAndDecrementUntil0(); //$34:9648();
	$20 = #000a; countAndDecrementUntil0(); //$34:9648();
$9618:	
	$1e = $18 + #80;

	if (#80 != (a = $1a)) return;
$9625:	$1a = #ff;
	//以下$1b,1c,1dも同様の処理(0ならスペースに置換)
$9647:
}
```
</details>

____________________
# $34:9648 countAndDecrementUntil0
<details>
<summary></summary>

### args:
+ [in] u16 $20 : decrementBy

### (pseudo-)code:
```js
{
	x++;
	do {
$9649:		$18,19 -= $20,21;
		$1a.x++;
	} while ($18,19 >= 0);
	$18,19 += $20,21;
	$1a.x--;
$966a:
}
```
</details>

____________________
# $34:966a strToTileArray
<details>
<summary>

>文字列をキャラクタ番号の配列に変換する(濁点、半濁点、改行などを処理)
</summary>

### args:
+ [in] u8 $18 : cchLine
+ [in] u8 $4e : destCharPtr
+ [in] u8 $7ad7[] : string (zero terminated)

### (pseudo-)code:
```js
{
	offset$4e_16(a = $18);	//$35:a558();
	y = 0;x = 0;
	for (;;x++,y++) {
$9673:	
		$1c = a = $7ad7.x;
		if (a == 0) return;
$967b:
		elif (a == #ff) $96ef;	//(space)
		elif (a == #01) $9735;	//(\n)
		elif (a == #02) $9745;	//
		elif (a == #42) $96b2;	//ヴ
		elif (a >= #60) $96f1;	//(盾マーク;ポの次)
		elif (a >= #57) $96df;	//パ
		elif (a >= #52) $96cf;	//バ
		elif (a >= #43) $96ca;	//ガ
		elif (a >= #3d) $96c2;	//ぱ
		elif (a >= #38) $96ba;	//ば
		elif (a < #29) $96f1;	//が
$96ad:		putDakuten(); goto $96c5;	//always satisfied
$96b2:		putDakuten(); a += #8a; goto $96f1;
$96ba:		putDakuten(); a += #6b; goto $96f1;
$96c2:		putHandakuten();
$96c5:		a += #66; goto $96f1;
$96ca:		putDakuten(); bne $96e2;
$96cf:		putDakuten(); 
		if (a == #55) { a = #a6; goto $96f1; }	//'べ'
$96da:		a += #91; goto $96f1;
$96df:		putHandakuten();
$96e2:		if (a == #5a) { a = #a6; goto $96f1; } //'ぺ'
$96ea:		a += #8c; goto $96f1;
$96ef:		a = #ff;
$96f1:	
		$4e[y] = a;
	}
$96f8:
}
```
</details>

____________________
# $34:96f9 putDakuten	//Voiced consonant mark
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	push (a = y);
	getPrevLinePtr();	//$34:9715();
	$1e[y] = #c0;
	y = pop a;
	a = $1c;
$9707:
}
```
</details>

____________________
# $34:9707 putHandakuten
<details>
<summary></summary>

### notes:
P-sound mark = handakuten

### (pseudo-)code:
```js
{
	push (a = y);
	getPrevLinePtr();	//$34:9715();
	$1e[y] = #c1;
	y = pop a;
	a = $1c;
$9715:
}
```
</details>

____________________
# $34:9715 getPrevLinePtr
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$1d = a = y;
	$1e,1f = $4e,4f - $18;
	$1e,1f += $1d;
	y = 0;
$9735:
}
```
</details>

____________________
# $34:9735 strToTileArray_OnLinefeed
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	offsetTilePtr(len:a = $18);	//a558
	offsetTilePtr(len:a = $18);
	x++;
	y = 0;
	goto $9673;
}
```
</details>

____________________
# $34:9745 strToTileArray_OnChar02
<details>
<summary></summary>

### notes:
char 02 = tab(space run)

### (pseudo-)code:
```js
{
	x++;
	$1e = a = $7ad7.x;
	x++;
	y += $1e;
	goto $9673;
}
```
</details>

____________________
# $34:9754 initTileArrayStorage
<details>
<summary></summary>

### args:
+ [out] u16 $4e,$7ac0 : #7200

### (pseudo-)code:
```js
{
	$7ac0 = $18 = $4e = #$7200;
	memset($18,0xff,0x200);
$9777:
}
```
</details>

____________________
# $34:9777 calcActionOrder
<details>
<summary>

>行動順を決める
</summary>

### args:
+ [out] u8 $7acb[#c+1] : ordered indices (#ff:last)
+ 	u8 $7400[2][#c] : weight values

### notes:
まず乱数を12個生成しその大きい順にindexを並び替える
次にプレイヤーキャラのagiを乱数により1~3倍し大きい順にindexを並び替える
12個の乱数値のうちindex9-12のある場所をプレイヤーキャラの大きかった順に埋めていく

### (pseudo-)code:
```js
{
	for (y = 0;y != #c;y++) {
$9779:
		getSys1Random(a = #ff);	//a564();
		$7400.y = a;
		$740c.y = y;
	}
$978a:
	getSortedIndices(base:$1a = #1, keys:$1c = #73ff,
		result:$1e = $740b, len:$22 = #c);	//$8f57();
	for (y = 0;y != #c;y++) {
$97a7:
		$7acb.y = $740c.y | #80;
	}
$97b4:
	for ($52 = 0;$52 != 4;$52++) {
$97b8:
		y = updatePlayerOffset() + #18;	//a541();
		$3c = a = $57[y];	//agi
		a = getSys1Random(a <<= 1) + $3c;
		$7400.(x = $52) = a;	//agi + (0 ~ agi*2)
	}
$97db:
	getSortedIndices(base:$1a = #1, keys:$1c = #73ff,
		result:$1e = #7403, len:$22 = #4);	//$8f57
$97f6:
	for (y = 0;y != 4;y++) {
$97f8:
		x = #ff;
		do {
$97fa:
			x++;
			a = $7acb.x;
		} while (a < #88);	
$9802:
		//#88: last index value of enemy party = (89,8a,8b,8c rolls placeholder)
		$7acb.x = $7404.y;
	}
$980d:
	for (x = #b; x >= 0;x--) {
		$7400.x = $7acb.x;
	}
	$24 = $25 = ++x;
	for ($25;$25 != #c;$25++) {
$981d:
		x = $25;
		if ($7400.x >= 0) { //bmi$9833;
			$52 = a;
			y = updatePlayerOffset();	//a541
			a = $5b[++y] & #c0;
			if (a != 0) continue;	//$985c;
			//else $984f
		} else {
$9833:
			a &= #7f;	//a: $7400.x
			mul_8x8(a,x = #40);	//fcd6
			$1a,1b += #7675;
			a = $1a[y = #1] & #e8;
			if (a != 0) continue;	//$985c;
		}
$984f:
		y = $24;
		x = $25;
		$7acb.y = $7400.x;
		$24 = ++y;
$985c:
	}
$9864:
	$7acb.(y = $24) = #ff;
	return;
$986c:
}
```
</details>

____________________
# $34:986c getCommandInput
<details>
<summary>

>[processPlayerCommandInput]
</summary>

### notes:

### args:
+ [in]	u8 $52 : playerIndex
+ [in]	u8 $7ed8 : battleMode? (20:invincible)
+ u16 $5b : playerPtr

### (pseudo-)code:
```js
{
//コマンドハンドラが1を返したらここまで
	drawEnemyNamesWindow();	//$34:9d9e()
$986f:	//コマンドハンドラが0を返したらここまで戻ってくる
	x = $52;
	if (x != 4) {
		$7be1 &= ~(1 << x);	//$fd2c
		y = updatePlayerOffset();	//$35:a541();
		y += 2;
		a = $5b[y] & 1;
		if (a != 0) { //beq$9894
			setYtoOffset2F();	//$34:9b94();
			$7e0f.x = $5b[y];	//target
			if (a != 0) $989e
		}
$9894:	
		$78cf.x = #ff;
		$7e0f.x = 0;
	}
$989e:
	drawSelectedActionNames();	//$34:9ba2
	endInputCommandIfDone();	//$34:a433();
	updatePlayerOffset();	//$35:a541();
	x = $52;
	if (0 != (a = $7ce4.x)) { //beq $98bd
$98ae:
		setYtoOffsetOf(a = #23);	//$34:9b88;
		$5b[y] = $7ce4.x;
		$7ce4.x = 0;
	}
$98bd:		
	y = $5f; y++;
	a = $5b[y] & #c0; //dead|stone
	if (a != 0) { //beq $98ce
		$52++;
		$7ceb++;
		goto $986f;	
	}
$98ce:		
	y++;
	a = $5b[y] & #e0;	//paralyze|sleep|confuse
	if (a != 0) { //beq $98d8
		goto $a66c;
	}
$98d8:
	a = $5b[y] & 1;
	if (a != 0)	{ //beq $98e3
		$52++;
		goto $986f;
	}
$98e3:
	createCommandWindow();	//$34:9a69();	//$7400
	setYtoOffset2E();	//$34:9b9b();
$98e9:
	for (x = 2;x >= 0;x--) {
		$5b[y++] = 0;	//y = 2e,2f,30
	}
	setYtoOffsetOf(a = #2c);	//$34:9b88(#2c)
	$5b[y] &= #f7;
	y += 13h;	//y= +3F
	a = $5b[y];
	if (0 != a) {
		putCanceledItem(); //$34:9ae7();
	}
	if (0 == (a = $7cf3)) {
$990f:
		drawEnemyNamesWindow();	//$9d9e
		call_2e_9d53(a = 0);
		a = $7ed8 & #20;
		if (a == 0	//bne 992d
			&& $78ba >= 0) //bmi 992d
$9923:		{
			do {
				getPad1Input();	//fbaa
			} while ($12 == 0);
			createCommandWindow();	//$9a69();
		}
$992d:
		a = $7ed8 & #20;
		if (a != 0) { //beq $993a;
			fireCannon();	//$a50b();
			goto getCommandInput;	//$986c;
		}
$993a:
		if ($78ba < 0) return; //bpl 9940
	}
$9940:
	call_2e_9d53(a = 2);	//$3f:fa0e();指示するキャラが前にでる
	$53 = $52;
	$1a = $24 = $25 = $55 = 0;
	loadAndInitCursorPos(type:$55 = 0, dest:$1a = 0); //$34:8966();
$9958:	
	push (a = x);	//x = spriteOffset
	for (x = 3;x != 0;x--) {
		waitNmi();	//$3f:fb80();
	}
$9962:
	x = pop a; //= ($1a << 4)
	$1b = 0;
	$46 = 3;
	getInputAndUpdateCursorWithSound();	//$34:899e();
$996f:	//$23 = 選択コマンド位置
	if (1 != (a = $50)) {
		if (a == 0x40) {
			if (0 == (a = $24)) {
				$24++;
				$25 = 0;
				goto $9958;
			}
$9985:
			if (0 != (a = ($78ba & 0x8)) ) {
				a = 5;
			}
$9990:			else {
				a = 4;
			}
			$23 = a;
		} else {
$9996:
			if (a == 0x80) {
				if (0 == (a = $25)) {
					$25++;
					$24 = 0;
					goto $9958;
				}
$99a6:
				if (0 != (a = ($78ba & 0x8)) ) {
					a = 4;
				}
$99b1:				else {
					a = 5;
				}
				$23 = a;
			} else {
$99b7:
				if (a != 0x2) goto $9958;
				if (0 != $52) {
					$34:9a42();
				}
$99c2:
				a = 1;
				goto $99fd;
			}
		}
	}
$99c6:
	//$23: 選択コマンド(ウインドウ上からの番号,前進=4,後退=5)
	setSoundEffect05();	//set$ca_05_and_increment_$c9();	//$34:9b7d();
	init4SpritesAt$0220(index:$18 = 0); //$34:8adf();
	
	//a = $23; x = $52;
	//$7ac3.x = a;
	//x = $23;
	//a = $7400.x;
	//x = $52
	//$78cf.x = a;
	$7ac3[$52] = $23;
	a = $78cf[$52] = $7400[$23];	//listIndex => actionId

	$18 = #$9a16 + (a << 1);	//$34:9a16 : functionTable
	//y = 0;
	//a = $18[y];
	//push a; y++;
	//$19 = a = $18[y];
	$18 = *$18;
	(*$18)();	//jmp funcPtr
$99fd: //getCommandInput_next
	push a;
	push (a = $52);
	$52 = $53;
	call_2d9e53(a = #1);//$3f:fa0e(); 入力完了したキャラが下がる
	$52 = pop a;
	pop a;	//a: draw enemy window ?
	if (a != 0) goto $986f;
	else goto getCommandInput;	//$986c;
$9a16:	//jump table (for command)
}
```
</details>

____________________
# $34:9a42 rewindCharacterIndex
<details>
<summary></summary>

### notes:
	//backToPrevChar

### (pseudo-)code:
```js
{
}
```
</details>


____________________
# $34:9a68 commandWindow_OnCommand0001090a13
<details>
<summary>

>未使用command
</summary>

### (pseudo-)code:
```js
{
	return;
}
```
</details>

____________________
# $34:9a69 createCommandWindow
<details>
<summary></summary>

### args:
+ [in] u8 $5f : playerOffset
+ [in] u8 $78ba : begginingFlag (surpriseAttack/backAttack)
+ [out] u8 $7400[6] : commandIdList (index=cursor pos)

### (pseudo-)code:
```js
{
	a = $78ba;
	if (0 != (a & 0x8)) ) {
		x = 3;
		$7404 = x--;	//3
		$7405 = x;	//2
	}
$9a79:	//上の条件で分岐しても結局はこの値に上書きする
	$7404 = x = 2;
	$7405 = ++x;
	y = $5f;	//
	y = a = $57[y] << 2;	//$fd40()
	for (x = 0;x != 4;x++) {
		$7400.x = $9b21.y; //y = job*4
	}
$9a98:
	initTileArrayStorage();	//$34:9754();

	$38 = 0;
	for ($2d = 0;$2d != 4;$2d++) {
$9aa1:
		fillXbytesAt_7ad7_00ff(x = 5);	//$35:a549();
		a = $7400.(x = $2d);
		if (a == #ff) {
			$38++;
			a = 0;
		}
$9ab3:
		$1a = a;
		loadString(index:a = $1a,dest:x = 1,base:$18 = #8c40);	// $35:a609();
$9ac4:		strToTileArray($18 = 5);	//$34:966a();
$9acb:		offset$4e_16(a = 5);	//$35:a558();
$9acd:
	}
$9ad8:
	$18 = 4;	//left
	$19 = #a;	//right
	$1a = 3;	//border
	return draw8LineWindow();	//$34:8b38();
$9ae7:
}
```
</details>

____________________
# $34:9ae7 putCanceledItem
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$18 = a;
	$5b[y] = 0;
	a = $5b[--y];
	if (a == 0) { //bne 9b1c
		for (x = 0;x != #40; x+=2) {
$9af4:
			a = $60c0.x;
			if (a == $18) { //bne 9b02
				x++;
				$60c0.x++;
				goto $9b1c;
			}
$9b02:
		}
$9b08:
		for (x = 0;x != 0;x++) {
$9b0a:
			a = $60c0.x;
			if (a == 0) $9b13
		}
$9b13:
		$60c0.x = $18; x++;
		$60c0.x++;
	}
$9b1c:
	$5b[y] = 0;
	return;
}
```
</details>

____________________
# $34:9b79 playSoundEffect	//[set$ca_and_increment_$c9]
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	a = #18; goto $9b83;	//papa	(move sound)
$9b7d:	a = 5; goto $9b83;	//pi	(decide sound)
$9b81:	a = 6;			//bee-bee	(invalid sound)
$9b83:	$ca = a;
	$c9++;
	return;
$9b88:
}
```
</details>

____________________
# $34:9b88 setYtoOffsetOf
<details>
<summary></summary>

### code:
```js
{
	return y = a = ($5f + a);
}
```
</details>

____________________
# $34:9b8d setYtoOffset03
<details>
<summary></summary>

### notes:
offset 03 = EXP or lefthand or HP

### code:
```js
{
	return y = a = #03 + $5f;
}
```
</details>

____________________
# $34:9b94 setYtoOffset2F
<details>
<summary></summary>

### notes:
offset 2F: target indicator bits

### code:
```js
{
	return y = a = #2f + $5f;
}
```
</details>

____________________
# $34:9b9b setYtoOffset2E
<details>
<summary></summary>

### notes:
2E = action id

### code:
```js
{
	return y = a = #2e + $5f;
$9ba2:
}
```
</details>

____________________
# $34:9ba2 drawInfoWindow
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	if ((a = $7ceb) != 0) {
		$7ceb = 0;
		return;
	}
$9bad:	
	initTileArrayStorage();	//$9754;
	$720a = #7977;
	push (a = $52);
	for ($52 = 0;$52 != 4;$52++) {
$9bc1:
		initString(x = #12);	//$a549;
		$7ae3 = #c7;
		updatePlayerOffset();	//$a541;
		y = a + 6;
		for (x = 1;x != 7;x++,y++) {
			$7ad7.x = $57[y];
		}
$9bdf:
		setYtoOffset03();	//$9b8d;
		$18 = $5b[y++];
		$19 = $5b[y++];
		itoa_16();	//$95e1;
		$7adf = $1b;
		$7ae0 = $1c;
		$7ae1 = $1d;
		$7ae2 = $1e;
		$24 = 0;
		cachePlayerStatus();	//$9d1d();
		if ((a = $7ce8) == #ff) $9c7f;
$9c10:
		x = $52;
		if ((a = $78cf.x) != #ff) { //beq 9c4d
		//コマンド選択ずみ
			if (a >= #c8) { //bcc 9c39
				loadString(index:a = $1a = a - #c8,dest:x = #c,base:$18 = #8990);
				$7ae3 = #c7;
				goto $9cba;
			} else {
$9c39:
				loadString(index:a = $1a = a, dest:x = #0d, base:$18 = $8c40);
				goto $9cba;
			}
		} else {
$9c4d:	
			if (( $1a | $1b) != 0) { //beq 9c7f
				if ( ($1b & #20) != 0) { //beq 9c63
					a = ($1b &= #df);
					a |= $1a
					if (a == 0) $9c7f //beq
				}
$9c63:
				for(;;) {
					$1b <<= 1;
					rol $1a;
					if (carry) break; //bcs 9c6d
				
					$24++;
				}
$9c6d:
				loadString(index:a = $24, dest:x = #0d, base:$18 = #822c);
				goto $9cba
			} else {
$9c7f:
				if ($7ce8 != #ff) { //beq 9c95
					maskTargetBit(a = $7be1, target:x = $52);	//fd38
					if (!equal) { //beq 9c95
						if ($78cf.x != 0) goto $9c1d;
					}
				}
$9c95:
				setYtoOffsetOf(a = 5);	//$9b88
				$18 = $5b[y];
				$19 = $5b[++y];
				itoa_16();	//$95e1();
				$7ae4 = $1b;
				$7ae5 = $1c;
				$7ae6 = $1d;
				$7ae7 = $1e;
			}
		}
$9cba:
		strToTileArray(len:$18 = #12);	//966a
		offsetTilePtr(len:a = #12);	//a558
	}	//beq 9cd1 	//jmp $9bc1
$9cd1:
	$52 = pop a;
	return draw8LineWindow(left:$18 = #0b, right:$19 = #1e, border:$1a = #03);	//8b38
$9ce3
}
```
</details>

____________________
# $34:9ce3
<details>

### (pseudo-)code:
```js
{
}
```
</details>

____________________
# $34:9d1d cachePlayerStatus
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	y = $5f;
	push ($1c = $5b[++y] );
	$1a = $1c & #c0;	//daed|stone
	$1d = a = $5b[++y];
	$1a |= ($1d & #e0) >> 2; //paralyzed | sleeping | confused; fd47
	$1b = 0;
	pop a; //status0
	a &= #3f;
	$1b,a >>= 3;	//lsr ror * 3 (lowbyte:$1b)
	$1a |= a;	//status0>>3
$9d4b:
	x = $52 << 1;
	$78bb.x = $1a;
	$78bc.x = $1b;
	if (($1c & #c0) == 0) { //bne 9d89
		push (a = $1c);
		$1c &= 7;
		pop a;	//status0
		a &= #10;	//sealed (silence)
		a >>= 1;
		a |= $1c;
		$1c = a << 1;	//bit3(小人)とbit4(沈黙)を重ねる
		push (a = $1d);
		a &= #e0;
		$1c |= a;
		pop a;
		if ((a & 6) != 0) { //beq 9d83
$9d7d:
			$1c |= #01;
		}
$9d83:
		y = 0;
		if ($1c == 0) $9d89;	//bne 9d8d
	}
$9d89:
	y = #ff;
	goto $9d97;
$9d8d:
	for (y;y != 8;y++) {
		a <<= 1;
		if (carry) goto $9d97;	//bcs $9d97;
$9d90:
	}
$9d95:	goto $9d9d;
$9d97:
	a = y;
	x = $52;
	$78c4.x = a;
$9d9d:	
	return;
}
```
</details>

____________________
# $34:9d9e drawEnemyNamesWindow
<details>
<summary></summary>

### args:
+ [in] u8 $7dce[4] : group id
+ [in] u8 $7d6b[4] : enemy id

### (pseudo-)code:
```js
{
	initTileArrayStorage();	//$34:9754();
	for ($24 = 0;$24 != 4;$24++) {
		initString(x = 8);	//$a549 fillXbytesAt_7ad7_00ff();

		x = $24;
		a = $7dce.x;
		if (a != 0) {
			loadString(index:a = $7d6b.x, dest:x = 0, base:$18 = #8a40);
			strToTileArray(len:$18 = 8);	//$966a
			offsetTilePtr(len:a = 8);	//$a558
		}
$9dcd:
	}
$9dd5:
	return draw8LineWindow(left:$18 = #1, right:$19 = #0a,borderFlags:$1a = #3);	//$8b38
}
```
</details>

____________________
# $34:9de4 executeAction
<details>
<summary></summary>

### args:
+ [in] u8 $7ac2 : currentActorIndex(action order)
+ [in] u8 $7acb[0xc?] : ordinalToBattleCharIndexMap
+ [in] u8 $7ca7[4] : 選択魔法Lv (index=player)
+ [in] u8 $7ced : encounter id
+ [in] u8 $7cee : encounter flag (or high bits of encounter id?)

### local variables:
+ u8 $1a : actionId
+ u16 $6e : actorPtr
+ u16 $70 : firstTargetPtr
+ u8 $78d6 : targetIndex+flag
+ u8 $78d8 : targetName (single:=index multiple:#88)
+ u8 $7e98 : actor? $fd24[targetIndex] = bitMask for indicator bits
+ u8 $7e99,7e9b : targetIndicatorFlag
+ u8 $7e9a : sideFlag(actorEnemy:80 targetEnemy:40)
+ u8 $7ec2 : handlerId

### (pseudo-)code:
```js
{
	x = $7ac2; a = $7acb.x;
	push a;push a;
	if (a < 0) {
		a = (a & #7f) + 4;
	}
$9df3:
	$26 = $18 = a;	//00-03:player00-03,04-0b:enemy00-07
	$1a = #40;
	$20,21 = #7575;
	dispatchBattleFunction(7);	//$34:802e(); => calcDataAddress
	$6e,6f = $1c,$1d;	//result
	if (0x0C >= (a = $26)) {
		pop a; pop a;
		goto $9e5f;
	}
$9e19:
	if (a >= 4) {
		a = (a - 4) | 0x80;
	}
$9e22:
	$78d6 = a;	//index|flag
	x = a = (pop a) & #7f;	//index|mode
	a = 0;
	$7e98 = flagTargetBit();	//$3f:fd20
	pop a;
	if (0 <= a) { //bpl $9e5f
		$7e9a |= #80;	//
		a = $7ced;
		if( ((#55 == $7ced) && ($7cee == 0))
			|| ( ((#79 == $7ced) || (#90 == $7ced)) && ($7cee != 0) ) )
		{
			//$7ced
			//55:バハムート
			//79:くらやみのくも
			//90:くらやみのくも
$9e57:			$6e[4] = $6e[6];	//hp.high = maxhp.high
		}
	}
$9e5f:
	a = $6e[y = 1] & #c0;
	if (a != 0) {	//dead or stone
		$7e98,$7ec2 = x = 0;
		$78d6,78d8,7ceb = --x;
		a = 0;
		setActorCommandIdAndClearMode();	//$34:9f7b();
		//goto $9eec;
	} else {
$9e81:
		a = $6e[++y] & #c0; //paralyze or sleep
		if (a != 0) {
			a = 1;
			setActorCommandIdAndClearMode();	//$34:9f7b();
			setNoTargetMessage();	//$34:91ce();
			setActionTargetBitAndFlags();	//$34:9f87();
		}
$9e93:
		$7e9b = $7e99 = a = $6e[y = #2f];	//+2f:selected targets
		if (a == 0) setActionTargetToActor();	//$34:9f87();
$9ea2:
		x = 0;
		do {
$9ea4:			a <<= 1;
			if (carry) break;
			x++;
		} while (x != 0);
$9eaa:
		a = $6e[++y]; //+30: action flag
		if (a < 0) {
$9eaf:
			$7e9a |= #40;
			$78d8 = a = x | #80;
			x += 4;
		} else {
$9ec5:
			$78d8 = x;
		}
$9ec8:
		a = $6e[y] & #40;	//multiple target
		if (a != 0)  {
			a = #88;	//"ぜんたい"
			$78d8 = a;
		}
$9ed3:
		$18 = x;
		$1a = #40;
		$20 = #7575;
		dispatchBattleFunction(7);	//calcDataAddress() 802e()
		$70,71 = $1c,1d;
	}
$9eec:
	a = getActor2C() & #10;	//$35:a42e()
	if (0 != a) {
		//special attack
		$1a = $6e[y = #2e];
		goto $9f5a;
	}
$9efc:
	a = $6e[y] & 8;//y=#2c
	if (0 != a) {
		//item
		$1a = $6e[y = #2e];
		goto $9f19;
	}
$9f0b:
	$1a = a = $6e[y = #2e];
	if (a < 0x13) goto $9f5c;
	if (a >= 0x46) goto $9f1d;
$9f19:	a = #13; goto $9f5c;
$9f1d:	a = getActor2C();
	if (a >= 0) {
		x = $52 = a = a & 7;
		y = a = $7ca7.x + 7;
		$6e[y] -= 1;
$9f35:		a = $1a;	//actionId
		if (a == #ce,#d5,#dc,#e3,#ea,#f1,#f8,#ff) goto $9fd6;	//summon
	}
$9f5a:	a = #14;
$9f5c:	$7ec2 = a;	
//	where a : 
//		actor2C & 0x08 then 0x14
//		actor2C & 0x10 then 0x13
//		command < 0x13 then command
//		command < 0x46 then 0x13
//		otherwise 0x14
//
	$18 = #9fac + (a << 1);
	$18 = *$18;
$9f78:	(*$18)();	//func ptr
$9fac:	//function table
$9fd6:	//summon
}
```
</details>

____________________
# $34:9f7b setActorCommandIdAndClearMode 
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$6e[y = #2e] = a;
	a = getActor2C() & #e7;
	$6e[y] = a;
$9f87:
}
```
</details>

____________________
# $34:9f87 setActionTargetToSelf //setActionTargetBitAndFlags
<details>
<summary></summary>

### args:
+ [in,out] $6e[#2f] : target indicator bits
+ u8 $fd24.x : bitmask for target

### (pseudo-)code:
```js
{
	push (a = getActor2C() );	//$a42e
	x = a = a & 7;
	flagTargetBit();	//$3f:fd20
	$7e99 = $7e9b = $6e[y = #2f] = a;
	a = pop & #80; y++;
	$6e[y] = a;
	return a = $6e[y = #2f];
$9fa8:
}
```
</details>

____________________
# $34:9fa8 handleCommand00_0a_do_nothing
<details>
<summary></summary>

### (pseudo-)code:
```js
{	//未使用id
	$7ceb++;
	return;
$9fac:
}
```
</details>

____________________
# $34:9fac actionHandlers[0x15]
<details>
<summary></summary>
</details>

____________________
# $34:9fd6 executeAction_summon
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$7e93 = 0;
	for (x = #3f;x >= 0;x--) {
		 $7875.x = 0;
	}
	$30 = 2;
	$52 = getActor2C() & 7;	//$a42e();
	y = updatePlayerOffset();	//$a541
	if ( $57[y] != #13
		&& $57[y] != #14)
	{
$9ffc:
		a = getSys1Random(max:a = #63);	//$a564;
		if (a < 50) {
			$30--;
		}
		$30--;
	}
$a009:
	x = $52;
	a = $1a = $7ac7.x & 7;
	a <<= 4;	//$fd3e
	$7e94 = a | $30;
	$6e,6f = #7875;
	setYtoOffsetOf(a = #0f);	//$9b88
$a027:
	for (x = 2;x >= 0;x--) {
		$18.x = $5b[y] << 1; y++;	//熟練 知性 精神
	}
$a032:
	setYtoOffsetOf(a = #1);
	$6e[y = 1] = $5b[y] & #30;	//

	for (x = 2,y = #f; x >= 0;x--,y++) {
		$6e[y] = $18.x;
	}
$a04b:
	$6e[y = 0] = $1a;	//lv = 熟練 << 1
	$6e[y = 3] = 3;	//hp
	
	x = $7ac2
	$7acb.x = #88;

	$6e[y] = getActor2C() | #90;
$a065:
	x = $52;
	a = $18 = $7ac7.x & 7

	push (a = ((a << 1) + $18) + $30 );
	$26 = $18 = a + #$5b
	loadTo7400FromBank30(index:$18, size:$1a = 8, base:$20 = #98c0, dest:x = 0);	//$ba3a
$a08c:
	if ($7405 < 0) { //bpl a09b
		$27 = #f0;
		$28 = #40;
		//bne a0da
	} else {
$a09b:
		if (($7405 & #40) != 0) { //beq a0ac
			$28 = #c0;
			$27 = #ff;
			// bne a0da
		} else {
$a0ac:
			do {
				$27 = getSys1Random(max:a = #7);	//$a564
				x = $40;
				mul8x8(a,x);	//$fcd6
				$1a,1b += #7675;
			} while ( ( $1a[y = 1] & #e0 ) != 0);
$a0cd:
			$27 = flagTargetBit(a = 0,target:x = $27);	//$fd20
			$28 = #80;
		}
	}
$a0da:
	$6e[y = #2e] = $26;	//2e:actionId
	$6e[++y] = $27;		//2f:targetBit
	$6e[++y] = $28;		//30:targetFlag
$a0ea:
	$5d,5e = #7675;
	pop a; push a;
	//a = (a << 1) + $7ac7.(x = $52) & 7 + $30;
	$78da = a + #78;
	$78d9 = pop a + #21;
	return $9de4;
$a104:
}
```
</details>

____________________
# $35:a104 command_fight
<details>
<summary>

>04: たたかう
</summary>

### args:
+ [out] u8 $7edf : protectionTargetBit

### notes:
`$35:a29e`

### (pseudo-)code:
```js
{
	if (getActor2C() < 0) {	//$35:a42e()敵ならマイナス(bit7=1)
$a10c:
		x = $18 = $70[y] & 7;//y=#2c
		a = $7cec;	//nearly dead flag?
		if (maskTargetFlag(flag:a = $7cec, target:x) != 0) { //bne a11e // $a1a9;
$a11e:
			if ( ($70[y = #1] & #c0) == 0 //bne a12b
				&& ($70[++y] & #21) == 0) //a12b: bne a1a9
			{
$a12d:
				//not (dead|stone |confuse|jump)
				$22 = $52 = 0;
				for ($52;$52 != 4;$52++) {
$a133:
					x = $19 = a = $52 << 1;
					$24.x = a;
					y = updatePlayerOffset();	//$a541();
					if ( ($57[y] == #7)  //bne a165
$a145:						&& ($5b[++y] & #c1) == 0) //bne a165
$a14d:						&& ($5b[++y] & #e0) == 0) //bne a165
					{
$a153:	
						x = $19;
						setYtoOffset03();	//$9b8d();
						$1a.x = $5b[y];	//hp
						$1b.x = $5b[++y];
						$22++;
						//bne $a16d;
					} else {
$a165:
						x = $19;
						$1b.x = $1a.x = 0;
					}
$a16d:
				}
$a175:
				if ($22 != 0) { //健康なナイトがパーティにいる
$a179:
					x = getIndexOfGreatest();	//$a30f();
					$7edf = $7e99 = flagTargetBit(a = 0);	//$fd20
					$7ee0 = flagTargetBit(a = 0,x = $18);	//$fd20
					$70,71 = #7575 + $5f;
					/*
					1A:A19E:A0 33     LDY #$33
					1A:A1A0:B1 70     LDA ($70),Y @ $0001 = #$01
					1A:A1A2:8D EA 7C  STA $7CEA = #$1E
					1A:A1A5:29 FE     AND #$FE
					1A:A1A7:91 70     STA ($70),Y @ $0001 = #$01
					1A:A1A9:4C 12 A2  JMP $A212
					*/
					$7cea = a = $70[y = #33];
					$70[y] = a & #fe;	//後列フラグクリア
				}
			}
		} 
$a1a9:			
		//goto $a212;
	} else {
$a1ac:
		push a;
		a = $6e[y = #1] & #28;	//toad|minimum
		if (a != 0) { //beq a1c0
			pop a;
			$7e1f = $7e20 = 0;
		} else {
$a1c0:
		//武器チェック
		//盾か他方が素手の弓矢なら素手扱いとする
		//盾と弓か矢を同時に装備している場合弓矢の方は素手扱いされないが
		//通常弓矢と盾は同時に持てない(装備時に制限される)ので問題は起きない
			$52 = pop a & #7;
			y = updatePlayerOffset() + 3; //a541
			$7e1f = $59[y]; y+=2;
			$7e20 = $59[y];
			if ($7e1f != 0) { //beq a1e8
				if (a < #58) //bcc a1f6
$a1e1:
				//右手が盾
				$7e1f = 0;
				//beq a1f6
			} else {
$a1e8:
				if ($7e20 < #4a) a212 { //bcc a212
$a1ef:				//右手が素手で左手が弓か矢か盾
				$7e20 = 0;
				beq a212;
			}
$a1f6:
			//右手は素手以外
			if ($7e20 != 0) { //beq a206
$a1fd:
				if (a < #58) bcc a212
				//左手が盾
				$7e20 = 0;
				//beq a212
			} else {
$a206:
				if ($7e1f < #4a) bcc a212;
$a20d:
				//右手が弓か矢で左手が素手
				$7e1f = 0;
			}
		}
	}
$a212:
	dispatchBattleFunction_03();	//$34:801e();
	if ($7edf != 0) { //$a229
		$78da.(x = $78ee) = #52;	//"ナイトが みをていして かばった！"
		/*
		1A:A222:A0 33     LDY #$33
		1A:A224:AD EA 7C  LDA $7CEA = #$1E
		1A:A227:91 70     STA ($70),Y @ $0001 = #$01
		*/
		$70[y = #33] = $7cea;	//後列フラグ復元
	}
$a229:
	a = $7c + $7d;
	if (a > 32) a = 32;
	$78d7 = a;	//"nnかいヒット!" / "ミス!"
	if (a == 0) goto $a29e;	//miss!
$a23c:
	y = 2;
	if ( ($e0.(x = $64) & #80) != 0) $a29e;	//dead
$a246:
	if ( (a = ( $e0.(++x) & #18)) == 0) $a29e;	//status varied?
$a24d:
	a = (a - #8) & #18; 
	if (a == 0) { //bne $a295;
$a254:
		push (a = $e0.x)
		$70[y] = $e0.x = a & 7;	//x:+01,y:+02
		$18 = $6e[y = #2c] & #87;
		if (($18 == ($70[y] & #87) { // bne$a275; //istargetactor?
$a26d:
			$6e[y = 2] = $f0.x = $e0.x;
		}
$a275:
		pop a;
		x = 0;
$a278:		for (x;;x++) {
			a <<= 1;
			if (carry) break; //bcs a27e
		}
$a27e:		$78d9 = x + 2;	//status index + 2
		$70[y = #2c] &= #e7;	//clear mode
		$70[y = #2e] = 0;	//action id = no action
		beq a29e;
	} else {
$a295:		//statusCache02 == [#18 || #10]
		$70[y] = $e0.x = $e0.x - #8;
	}
$a29e:
	a = $e0.(x = $64) & #80; //target dead
	if (a != 0) { //beq a2b7
$a2a6:
		$78da.(x = $78ee) = #1a;	//1a:"しんでしまった!"
		if ($70[y = #2c] < 0) { //bpl a2b7
$a2b4:
			$78da.x++;	//1b:"てきをたおした!"
		}
	}
$a2b7:
	$24 = $78d5 = 0;
	if (getActor2C() >= 0) { //bmi $a30e	//$a42e();
$a2c3:
		$52 = a & 7;
		y = updatePlayerOffset + #31;	//a541
		if (($5b[y] & 4) != 0) { //beq a2dd
$a2d4:
			push (a = y);
			consumeEquippedItem(a = #4);	//$a353
			y = pop a;
		}
$a2dd:
		if (($5b[++y] & 4) != 0) { //beq a2e9
$a2e4:
			consumeEquippedItem(a = #6);
		}
$a2e9:
		setYtoOffset03();	//$9b8d();
		//#41:しゅりけん
		if ($59[y] == #41) { //bne a2f7
$a2f2:
			consumeEquippedItem(a = #4);
		}
$a2f7:
		setYtoOffsetOf(#5);	//$9b88();
		if ($59[y] != #41) $a307
$a302:
		consumeEquippedItem(a = #6);	//$a353();
$a307:
		if ($24 != 0) {
			//consumed item was last one.recalc required
			dispatchBattleFunction(5);	//$34:8026();
		}
	}
$a30e:
	return;
$a30f:
}
```
</details>

____________________
# $35:a30f getIndexOfGreatest
<details>
<summary></summary>

### args:
+ [in] u16 $1a[4] : values
+ [in] u8 $24[8] : associated indices
+ [out] u8 $52 : index
+ [out] u8 x : index
+ [out] u8 $5f : offset to player of result index 

### notes:

### (pseudo-)code:

#### logic:
	for (var i = 1;i < 4;i++) {
		var val = values[i];
		if ( val > values[0] ) {
			values[i] = values[0];
			values[0] = val;
			var index = indices[i];
			indices[i] = indices[0];
			indices[0] = index;
		}
	}
```js
{
	y = 0; x = 2;
	for (x = 2;x != 8; x+=2 ) {
		if ( ($1a.y,$1b.y - $1a.x,$1a.x) < 0) { //bcs a344
			xchg( $1a.x, $1a.y); //push ($1a.x); $1a.x = $1a.y; $1a.y = pop a;
			xchg( $1b.x, $1b.y); //push ($1b.x); $1b.x = $1b.y; $1b.y = pop a;
			xchg( $24.y, $24.x);
		}
$a344:
	}
	x = $52 = $24 >> 1;
	return updatePlayerOffset(player:$52 );	//$a541();
$a353:
}
```
</details>

____________________
# $35:a353 consumeEquippedItem
<details>
<summary></summary>

### args:
+ [in] u8 A : hand (right=4, left=6)
+ [in] ptr $59 : equips
+ [out] u8 $24 : recalcRequired (consumed item count reached 0)

### (pseudo-)code:
```js
{
	setYtoOffsetOf(a);	//$9b88();
	
	if (--$59[y] == 0) {
		$59[--y] = 0;
		$24++;
	}
	return;
$a367:
}
```
</details>

____________________
# $35:a367 handleCommand14_castMagic
<details>
<summary></summary>

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
</details>

____________________
# $35:a3bb handleCommand13_useItem
<details>
<summary></summary>

### (pseudo-)code:
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
</details>

____________________
# $35:a3d7
<details>

### (pseudo-)code:
```js
{
}
```
</details>

____________________
# $35:a42e getActor2C 
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	return a = $6e[y = #2c];
}
```
</details>

____________________
# $35:a433 endInputCommand
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	push (a = $52);
	for ($52;$52 != 4;) {
		$35:a44e();
		if (equal) {
$a446:
			$52 = pop a;
			return;
		}
	}
$a44a:
	pop a;
	pop a;pop a;	//pop ret addr
	return;	//return to battleLoop (not getCommandInput)
}
```
</details>

____________________
# $35:a44e
<details>

### (pseudo-)code:
```js
{
	x = $52 << 1;
	a = $78bb.x & #f8;
}
```
</details>
	
____________________
# $35:a458 canPlayerPartyContinueFighting
<details>
<summary></summary>

### args:
+ [out] u8 $78d3 : 80=all dead, 40=($7dd2 == 0)

### (pseudo-)code:
```js
{
	a = $78d3 & 2
	if (a == 0) { //beq a486
		$52 = 0;
		for ($52 = 0;$52 != 4;$52++) {
a463:
			updatePlayerOffset();	//$a541();
			y = a + 1;
			a = $5b[y] & #c0;	//dead | stone
			if (a == 0) goto $a47c;
		}
a478:	a = #80;
		bne $a483;
a47c:
		if ($7dd2 != 0) return;	//$a486
		a = #40;
a483:
		$78d3 = a;
	}	
a486:
	return;
}
```
</details>

____________________
# $35:a50b fireCannon
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	call_2d_9e53(a = #f);	//$fa0e
	$78da = #3d;	//"たいほうの えんごしゃげき!"
	$7ed8 &= #df;
	eraseFromLeftBottom0Bx0A();	//$8f0b();
	$78d5 = #3;	//
	presentBattle();	//$8ff7();
	canPlayerPartyContinueFighting();	//$a458();
	if ($78d3 == #40) { //bne a53c
		pop a; pop a;
		pop a; pop a;
		a = $78d3;
		return $811c();
	}
$a53c:
	return call_2d_9e53(a = #e);	//jmp fa0e
}
```
</details>

____________________
# $35:a541 updatePlayerOffset
<details>
<summary></summary>

### args:
+ [in] u8 $52 : playerIndexs
+ [out] u8 $5f : offset
+ [out] u8 A : offset

### (pseudo-)code:
```js
{
	//a = $52; 
	//$3f:fd3c();//a <<= 6
	//$5f = a;
	$5f = $52 << 6;
}
```
</details>

____________________
# $35:a549 initString
<details>
<summary></summary>

### args:
+ [in] u8 x : count

### (pseudo-)code:
```js
{
	while (x >= 0) {
		$7ad7.x-- = 0;
		$7ad7.x-- = #ff;
	}
$a558:
}
```
</details>

____________________
# $35:a558 offset$4E_16
<details>
<summary></summary>

### args:
+ [in] u8 A : offset

### (pseudo-)code:
```js
{
	$4e,4f += a;
$a564:
}
```
</details>

____________________
# $35:a564 getSys1Random(
<details>
<summary></summary>

	[in] u8 A : max )

### (pseudo-)code:
```js
{
	$21 = 1; x = 0
	$3f:fbef();
}
```
</details>

____________________
# $35:a56f modifyActionMessage?
<details>
<summary></summary>

### args:
+ [in] u8 $7e88 : (invokedActionId)
+ [in] u8 $7e9b : effect target bits
+ [in] u8 $54 : (fight/special = 0)
+ [in] u8 $35:a5fd : hasActionMessage (bit array,higher bit = lower id)

### (pseudo-)code:
```js
{
	$24 = a = $7e88;
	if (0 != a && (a < #5b) ) {
		if (#44 != (a = $78da)) {	//#44:"ようすをみている" 
			if (0 == (a = $7e9b)) {	//
$a588:
				if (3 == (a = $54)) goto $a5dc;
$a58e:				a = #3b; x = $78ee;	//#3b:"こうかがなかった"
$a593:				$78da.x = a;
				if ($78ee == 0) goto $a5dc;
			}
$a598:			a = $54;
			if (a == 5 || a == 4) {
				$24 = (a == 5) ? 0x34 : 0x01;
				$54 = 0;
			}
$a5ae:			a = $78da(x = $78ee);
			if (0 == a) a = #ff; goto $a593;
$a5ba:			push (a = $24);
			a &= #f8;
			a >>= 3;	//$3f:fd46();
			x = a;
			y = a = (pop a) & 7; y++;
			a = $a5fd.x;	//flagBitsForAction (higher bit lower index)
$a5cb:			do {
				a <<= 1;
				y--;
			} while (y != 0);
$a5cf:
			if (carry) {
$a5d1:
				x = $78ee;
				$78da.x = $24 + #20;
			}
		} else {
			return; //a: $78da
		}
	}
$a5dc:
	x = $78ee; a = $54;
	if (a != 0) {
		switch (a) {
$a5ef:		case 1: a = #45;	//"アンデットにダメージ!"
$a5f3:		case 2: a = 1;		//"まほうをきゅうしゅうした!"
$a5eb:		default: a = #4f;	//"しっぱい!"
		}
$a5f5		$78da.x = a;
	}
$a5f8:
	$54 = a = 0;
$a5fc: 
	return;
$a5fd:	//flag bits table for action
}
```
</details>

____________________
# $35:a609 loadString
<details>
<summary></summary>

### args:
+ [in] u16 $18 : tableBase
+ [in] u8 A : index
+ [in,out] u8 X : destOffset

### notes:
テーブルに入ってる値は$18:0000(file30000)からのリニアな16bitオフセット
対象のデータがあるbankを常に$8000-$bfffにマップするので注意

### (pseudo-)code:
```js
{
	$1a = a;
	a = x; push a;
	get2byteAtBank18($1a);	// $3f:fd60();
$a610:	push (a = $18);
	push (a = $19);
	$1a,1b = #4000;
	div16();	//$3f:fc92();
	y = $1c + #0c;
	$19 = pop a;
	$18 = pop a;
	switch (y) {	//possible y : c,d,e,f (per16k bank index)
	case 0xD:
$a639:		$18,19 += #4000; break;
	case 0xE:
$a666:		break;
	case 0xF:
$a659:		$18,19 -= #4000; break;
	default:
$a649:		$18,19 += #8000; break;
	}
$a666:
	pop a;x = a;	//initial X
	a = y;
	copyTo_$7ad7_x_Until0(bank = y,offset = x);	//jmp $3f:fd4a();
$a66c:
}
```
</details>

____________________
# $35:a66c

### (pseudo-)code:
```js
{
	y = $5f + 2;
	if (($5b[y] & #20) != 0) { //beq a67e
		dispatchBattleFunction_09();	//$8036();
		$52++;
		return getCommandInput_noRedraw();	//986f();
	}
$a67e:
	setYtoOffset2E();	//$9b9b();
	$5b[y] = 1;
	$52++;
	return getCommandInput_noRedraw();	//986f();
}
```
</details>

____________________
# $35:a71c commandWindow_OnForwardSelected
<details>
<summary>

>02: ぜんしん
</summary>

### (pseudo-)code:
```js
{
	setYtoOffsetOf(a = #f);	//9b88
	if (($59[y] & 1) == 0) { //bne a72d
$a727:
		//すでに前列だった
		playSoundEffect06;	//$9b81();
		return movePosition_end();	//$a7c8();
	}
$a72d:
	initMoveArrowSprite();	//$a7cd();
	push a;
	$0222 = #43;	// reverse x | palette3
	x = pop a;
	$0220 = $a823.x; x++;
	$0223 = $a823.x;
	$18 = #80;	//right key
	$19 = #02;	//move forward
	return showArrowAndDecideCommand();	//jmp
$a750:	
}
```
</details>

____________________
# $35:a750 commandWindow_OnBack
<details>
<summary>

>03: こうたい
</summary>

### (pseudo-)code:
```js
{
	setYtoOffsetOf(a = #0f);
	if (($59[y] & 1) != 0) {
		requestSoundEffect06();	//$9b81
		return movePosition_end();	//a7c8
	}
	initMoveArrowSprite();	//a7cd
	push a;
	$0222 = #03;
	x = pop a + 2;
	$0220 = $a823.x;
	x++;
	$0223 = $a823.x;
	$18 = #40;	//left
	$19 = #03;	//back
	//fall through
$a784:
}
```
</details>

____________________
# $35:a784 showArrowAndDecideCommand
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	if (($78ba & #08) != 0) { //beq a7a4
		$0223 = $a833.x;
		$0222 ^= #40;	//reverseX
		if ((a = $18) >= 0) { //bmi a7a1
$a79d:
			a <<= 1;
			//clc bcc a7a2
		} else {
$a7a1:
			a >>= 1;
		}
$a7a2:
		$18 = a;
	}
$a7a4:
	for (;;) {
		do {
			presenetCharacter();	//$8185();
			getPad1Input();	//fbaa
		} while ((a = $12) == 0);
		if (a == #01) $a7bc;	//beq
		if (a == #02) $a7c8;	//beq
		if (a == $18) $a7c8;	//beq
	}
$a7bc:	//A
	playSoundEffect05();	//$9b7d
	$52++;
	setYtoOffset2E();	//9b9b
	$5b[y] = $19;
$a7c8:	//fall through
}
```
</details>

____________________
# $35:a7c8 movePosition_end
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	return getCommandInput_next(preventRedraw:a = 1);	//jmp 99fd
}
```
</details>

____________________
# $35:a7cd initMoveArrowSprite
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	init4SpritesAt$0220(index:$18 = 0);	//8adf
	$0221 = #5d;
	a = $52 << 2;//fd40
	return;
$a7df:	
}
```
</details>

____________________
# $35:a7df command_forward
<details>
<summary>

>04: ぜんしん
</summary>

### (pseudo-)code:
```js
{
	$78d7 = #3b;
	setNoTargetMessage();
	return $a7f2;
}
```
</details>

____________________
# $35:a7ea command_back
<details>
<summary>

>03: こうたい
</summary>

### (pseudo-)code:
```js
{
	$78d7 = #3c;
	setNoTargetMessage();	//$91ce
$a7f2:
	$78d5 = 1;
	a = $6e[y = #33];
	getInvertedLineFlag();	//$a816
	$6e[y] = a;
	$52 = getActor2c() & 7;
	y = updatePlayerOffset() + #f;//$a541
	a = $59[y];
	getInvertedLineFlag();	//$a816
	$59[y] = a;
	return;
$a816:
}
```
</details>

____________________
# $35:a816 getInvertedLineFlag
<details>
<summary></summary>

### args:
+ [out] $18 : inverted line flag
+ [out] a : flag

### (pseudo-)code:
```js
{
	push a;
	$18 = a ^ 1 & 1;
	pop a;
	a &= #fe | $18
	return;
$a823:
}
```
</details>

____________________
# $35:a823 Point forwardArrowCoords[4];
<details>
<summary></summary>
</details>

____________________
# $35:a833 Point backArrowCoords[4];
<details>
<summary></summary>
</details>

____________________
# $35:a843 commandWindow_OnAttackSelected
<details>
<summary>

>04: たたかう
</summary>

### (pseudo-)code:
```js
{
	a = #04;
	return commandWindow_selectSingleTargetAndGoNext();	//jsr a848();
}
```
</details>

____________________
# $35:a848 commandWindow_selectSingleTargetAndGoNext
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$54 = a;
	$b3 = 0;	//単数選択
	call_2e_9d53(a = #10);	//$3f:fa0e(); 対象選択
	setYtoOffset2F();	//$9b94
	if (0 != (a = $b4) ) {
$a85d:	
		$5b[y] = a;	//2f:target bits
		$5b[++y] = $b5; y-=2;	//30:target flag
		$5b[y] = a = $54	//2e:actionid
		$52++;
	}
$a86c:
	pop a;
	pop a;
	$54 = 0;
	return getCommandInput_next(preventRedraw:a = 1);	//jmp 99fd
}
```
</details>

____________________
# $35:a877 commandWindow_OnGuard
<details>
<summary>

>05: ぼうぎょ
</summary>

### (pseudo-)code:
```js
{
	setYtoOffset2e();	//9b9b
	$5b[y] = 5;
	return getCommandInput_goNextCharacter();	//aa56
$a881:
}
```
</details>

____________________
# $35:a881 command_guard
<details>
<summary>

>05: ぼうぎょ
</summary>

### (pseudo-)code:
```js
{
	$78d7 = #3e;
	setNoTargetMessage();	//$91ce
	$78d5 = 1;
	push ( a = $6e[y = #23] );
	x = getActor2C() & 7;	//a42e
	$7ce4.x = pop a;
	if (a >= #80) {
		a = #ff;
	} else {
		a <<= 1;
	}
$a8a6:
	$6e[y = #23] = a;;
	return;
$a8ab:
}
```
</details>

____________________
# $35:a8ab commandWindow_OnEscapeSelected
<details>
<summary>

>06: にげる
</summary>

### (pseudo-)code:
```js
{
	setYtoOffset2E();	//$9b9b
	$5b[y] = 6;
	goto $a8bc;	//goto $aa56
}
```
</details>

____________________
# $35:a8b5 commandWindow_OnSneakAway
<details>
<summary>

>07: とんずら
</summary>

### (pseudo-)code:
```js
{
	setYtoOffset2E();	//9b9b
	$5b[y] = 7;
$a8bc:
	return getCommandInput_goNextCharacter();	//aa56
}
```
</details>

____________________
# $35:a8bf command_escape
<details>
<summary>

>06: にげる
</summary>

### (pseudo-)code:
```js
{
	$78d5 = 1;	//listid
	$78d7 = #3f;	//actionName
	setNoTargetMessage();	//$91ce();
	getActor2C();	//$a42e();
	if (a >= 0) $a8d4	//bpl
	else goto $a978
$a8d4:
	$18,19,1a,1b = 0;
	$24,25 = #7675;
	y = x = 0;
	for (x;x != 8;x++) {
$a8ea:	
		a = $7da7.x
		if (a != #ff) {	//beq $a900
$a8f1:		
			$18,19 += $24[y];	//y=0(lv)
			$1a++;
		}
$a900:
		$24,25 += #0040;
	}
$a912:
	div16();	//$fc92 ($1c = $18/$1a)
	a = $6e[y = #2a] + #19 - $1c;	//2a:jobparam+2?
	if (a < 0) a = 0;	//bcs$a923
$a923:
	$24 = a;	
	getSys1Random(#64);	//a564
	if (a < $24) $a948; //bcc
$a92e:
	if (($78ba & 1) != 0) $a948;	//bne
$a935:
	$78da = #1f;	//"にげられない！"
	return;
$a93b:
}
```
</details>


____________________
# $35:a93b command_sneakAway
<details>
<summary>

>07: とんずら
</summary>

### code:
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
</details>


____________________
# $35:a9ab commandWindow_OnJump
<details>
<summary>

>08: ジャンプ
</summary>

### (pseudo-)code:
```js
{
	$b3 = 0;	//single
	call_2e_9d53(a = #10);	//selectTarget
	setYtoOffset2F();	//9b94
	if ($b4 == 0) { //bne a9be
		clc bcc a9d3
	} else {
$a9be:
		if ($b5 >= 0) goto $a9ab; //bpl a9ab
$a9c2:
		$5b[y] = $b4;
		$5b[++y] = $b5;
		y -= 2;
		$5b[y] = #08;	//2e
		$52++;
	}
$a9d3:
	return getCommandInput_next(preventRedraw:a = 1);
$a9d8:
}
```
</details>

____________________
# $35:a9d8 command_jump
<details>
<summary>

>08: ジャンプ
</summary>

### (pseudo-)code:
```js
{
	$78d5 = 1;	//listId
	$78d7 = #41;	//actionName
	a = $6e[y = 1] & #28;
	if (a != 0) { //beq $a9f6
		$7ec2 = #18;	//effect
		$78da = #3b;	//message "こうかがなかった"
	} else {
$a9f6:
		$6e[y = #27] = 2;
		x = a = (getActor2C() & 7) << 1;	//$35:a42e();
		x++;
		$f0.x |= 1;
		y += 2;
		$6e[y] = 9;	//y:2e actionId
	}
$aa10:
	return;
}
```
</details>

____________________
# $35:aa11 command_09_landing
<details>
<summary>

>09: (着地)
</summary>

### (pseudo-)code:
```js
{
	$6e[y = #2] &= #fe;
	$6e[y = #27] = 2;
	return $801e();
$aa22:
}
```
</details>


____________________
# $35:aa22 commandWindow_0b_geomance
<details>
<summary>

>0b: ちけい
</summary>

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
</details>

____________________
# $35:aa56 getCommandInput_goNextCharacter
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$52++;
	a = 1;
	return;	//jmp $99fd
$aa5d:
}
```
</details>

____________________
# $35:aa5d command_0b
<details>
<summary>

>0b: ちけい
</summary>

### (pseudo-)code:
```js
{
	$6e[y] = getActor2c() | #10;	//a42e
	getCurrentTerrain();	//$aac3();
	y = #2e;
	$1a = $6e[y] = a;
	command_magic();	//$a367();
	$cc++;
	$7ec2 = #14;
	if ($7e9b == 0) { //bne aac2
$aa7c:
		x = (getActor2C() & 7) << 1;	//a42e
		$18,19 = $6e[y = 5,6];	//maxhp
		$18,19 >>= 2;	//(lsr ror) * 2

		var temp = $6e[y = 3,4] -= $18,19
		if (temp < 0) { //bcs aab3
$aaa8:
			$6e[y,--y] = 0;
			$f0.x = #80;
		}
$aab3:
		$7e5f.x = $18; x++;
		$7e5f.x = $19;
		$54 = 3;
	}
$aac2:
	return;
$aac3:
}
```
</details>

____________________
# $35:aac3 getCurrentTerrain
<details>
<summary></summary>

### args:
+ [in] u8 $74c8 : = field $48; warpId

### (pseudo-)code:
```js
{
	a = $7ce3;
	if (a >= 8) { //bcc ab02
		if (a == #12) { //bne aad2
			a = #55; //bne ab05	うずしお
		} else {
$aad2:
			$46,47 = $74c8 + #a24e;
			copyTo7400(base:$46, restore:$4a = #1a, size:$4b = 1, srcBank:a = 0);	//fddc
			if (($7ed8 & 8) == 0) { //bne aafc
$aaf4:
				a = $7400 & f;
				//jmp $ab02
			} else {
$aafc:
				a = $7400 >> 4;	//fd45()
			}
		}
	}
$ab02:
	a += #50;
$ab05:
	return;
$ab06:
}
```
</details>

____________________
# $35:ab06 geomanceTargetFlag = $7a
<details>
<summary></summary>
</details>


____________________
# $35:ab07 commandWindow_OnDetect
<details>
<summary>

>0d: みやぶる
</summary>

### (pseudo-)code:
```js
{
	a = #0d;
	commandWindow_selectSingleTargetAndGoNext();	//jsr a848
$ab0c:
}
```
</details>

____________________
# $35:ab0c command_detect
<details>
<summary>

>0d: みやぶる
</summary>

### (pseudo-)code:
```js
{
	setEffectHandlerTo18();	//ab66
	$78d5 = 1;
	$78d7 = #46;
	if ($70[y = 1] < 0) { //bpl ab27
		$78da = #3b;
		//jmp ab65
	} else {
$ab27:
		a = $70[y = #12];	//weakpoint
		for (y = 0, x = 0;y != 7;y++) {
			a <<= 1;
			if (carry) { //bcc ab37
				$7400.x = a = y;
				x++;
			}
$ab37:
			y++;
		}
		$7400.x = #ff;
		y = 0;
		x = $78ee;
		if ($7400 < 0) { //bpl ab51
			y--;
			a = #43;
			//jmp ab5b
		} else {
$ab51:
			
			if ((a = $7400.y) == #ff) ab65;	//beq
			a += #48;
		}
$ab5b:
		$78da.x = a;
		$78ee++;
		y++;
		goto ab51;
	}
$ab65:
	return;
}
```
</details>


____________________
# $35:ab66 setEffectHandlerTo18
<details>
<summary></summary>

### notes:
called by 3 routines

### (pseudo-)code:
```js
{
	$7ec2 = #18;
	$cc++;
	return;
$ab6e:
}
```
</details>

____________________
# $35:ab6e commandWindow_OnInspect 
<details>
<summary>

>0c: しらべる
</summary>

### (pseudo-)code:
```js
{
	a = #0c;
	commandWindow_selectSingleTargetAndGoNext();	//jsr a848
}
```
</details>

____________________
# $35:ab73 command_inspect
<details>
<summary>

>0c: しらべる
</summary>

### (pseudo-)code:
```js
{
	setEffectHandlerTo18();	//ab66
	for (x = 0,y = 3;x != 4;x++,y++) {
$ab7a:
		$78e4.x = $70[y];
	}
	if ($70[y = #1] < 0)  //bpl ab8f
		a = #3b;	//"こうかがなかった"
	} else {
$ab8f:
		a = #3f;
	}
	$78da = a;
	$78d5 = 1;
	$78d7 = #45;
	return;
$ab9f:
}
```
</details>

____________________
# $35:ab9f commandWindow_OnSteal	
<details>
<summary>

>0E: ぬすむ
</summary>

### (pseudo-)code:
```js
{
	a = #0e;
	commandWindow_selectSingleTargetAndGoNext();	//jsr $a848
}
```
</details>

____________________
# $35:aba4 command_steal
<details>
<summary>

>0E: ぬすむ
</summary>

### (pseudo-)code:
```js
{
	setEffectHandlerTo18();	//ab66
	$78d7 = #47;	//actionName
	$78d5 = 1;	//listId
	a = $70[y = #2c];
	if (a >= 0) {	//bmi $abbf
$abb7:		$78da = #35;	//"ぬすみそこなった"
		return; //jmp $ac64
	}
$abbf:
	a = $6e[y = 0];		//Lv
	a += $6e[y = #f];	//jobLv
	$24 = a;
	getSys1Random(a = #ff);	//$35:a564();
	if (a >= $24) { //bcc $abd6
$abd3:		goto $abb7;	
	}
$abd6:
	a = $70[y = 1] & #e8;
	if (a != 0) goto $abb7;	//bne $abd3
$abde:
	$18 = a = $70[y = #36] & #1f;	//droptable index
	loadTo7400Ex(bank:a = #08,destOffs:x = 0, currentBank:y = #1a,
		base:$20 = #9b80, index:$18, len:$1a = 8); //$3f:fda6
	a = getSys1Random(a = #ff);	//$35:a564();
$ac00:
	if (a < #30) x = 0;
	elif (a < #60) x = 1;
	elif (a < #90) x = 2;
	else x = 3;
$ac1a:
	a = $7400.x;
	if (a == 0) goto $abb7;	//fail to steal
	$25 = a;
	for (x = 0;x != #40; x += 2) {
$ac23:
		a = $60c0.x;
		if (a != $25) continue;	//$ac3b;
		x++;
		$60c0.x++;
		a = $60c0.x;
		if (a < #64) goto $ac5a; //bcc $ac5a
		
		$60c0.x--;
		goto $abb7;	//fail to steal(item full)
$ac3b:	
	}
$ac41:
	for (x = 0;x != #40; x += 2) {
		if (0 == (a = $60c0.x)) goto $ac51;
	}
$ac4e:	goto $abb7;	//fail to steal (no any space for item)
$ac51:
	$60c0.x = $25; x++;
	$60c0.x++;
$ac5a:
	$78e4 = $25;
	$78da = #29;	//"おたから:"
$ac64:	return;
}
```
</details>

____________________
# $35:ac65 commandWindow_OnChargeSelected
<details>
<summary>

>0F: ためる
</summary>

### (pseudo-)code:
```js
{
	setYtoOffset2E();	//$34:9b9b();
	$5b[y] = #f;
	return processCommandInput_goNextCharacter();	//jmp $aa56
$ac6f:
}
```
</details>

____________________
# $35:ac6f command_charge
<details>
<summary>

>0F: ためる
</summary>

### (pseudo-)code:
```js
{
	$78d7 = #48;	//actionName
	$78d5 = 1;	//commandListId
	y = 1;
	a = $6e[y] & #28;	//蛙or小人
	if (a == 0) {	//bne $acca
		y = #27;
		a = $6e[y] + 1;
		if (a >= 3) {	//bcc $acc2;
			//ためすぎ
			$6e[y] = 0;
			$6e[3,4] >>= 1;	//currentHp >>= 1
			if ($6e[3,4] == 0) { //bne $acb7;
$acaa:				//HP1だった(自爆で死亡)
				getActor2C();	//$35:a42e
				x = (a & 7) << 1;
				$f0.x |= #80;	//dead
			}
$acb7:			$7e93 = 1;
			$78da = #2f;	//message "ためすぎてじばくした!"
			return;
		}
$acc2:			
		$6e[y] = a;
		$7e93 = 0;
		return;
	}
$acca:	//蛙か小人
	$78da = #3b;	//message "こうかがなかった"
	return;
}
```
</details>

____________________
# $35:acd0 commandWindow_OnSing	
<details>
<summary>

>10: うたう
</summary>

### (pseudo-)code:
```js
{
	a = #10
	commandWindow_selectSingleTargetAndGoNext();	//jsr a848
}
```
</details>

____________________
# $35:acd5 command_sing
<details>
<summary>

>10: うたう
</summary>

### (pseudo-)code:
```js
{
	$52 = getActor2c() & 7;	//$a42e()
	y = updatePlayerOffset() + 3;	//a541
	//竪琴チェック
	a = $59[y];
	if ( !(#46 <= a && a < #4a) ) {
		y += 2; a = $59[y];
		if ( !(#46 <= a && a < #4a) ) {
$acfc:
			$78d5 = 1;
			$78da = #42;
			$7ec2 = #18;
			return;
$ad0c:
		}
	} else {
$acfc:
		return command_fight();	//jmp $a104
	}
	
}
```
</details>

____________________
# $35:ad0c commandWindow_OnIntimidate
<details>
<summary>

>11: おどかす
</summary>

### (pseudo-)code:
```js
{
	setYtoOffset2E();	//9b9b
	$5b[y] = #11;
	return processCommandInput_goNextCharacter();	//jmp $aa56
$ad16:
}
```
</details>

____________________
# $35:ad16 command_intimidate
<details>
<summary>

>11: おどかす
</summary>

### (pseudo-)code:
```js
{
	$78d5 = 1;
	$78d7 = #4a;
	if (($7ed8 & 1) != 0) { //beq ad2d
		$78da = #3b;
		return;
	}
$ad2d:
	$25 = 7;
	y = 0;
	$24 = a >> 1; //=3
	y = 0;
	a = $5d[y] - $24;
	if (a < 0) { //bcs ad41
		a = 0;
	}
$ad41:
	$24 = a;
	for ($25;$25 >= 0;$25--) {
$ad43:
		$5d[y] = $24;
		$5d += #0040;
	}	//bpl ad43
$ad5a:
	$5d,5e = #7675;
	$78da = #32;
	setNoTargetMessage();	//$91ce()
	return;
$ad6b:
}
```
</details>

____________________
# $35:ad6b commandWindow_OnCheer
<details>
<summary>

>12: おうえん
</summary>

### (pseudo-)code:
```js
{
	setYtoOffset2E();	//$9b9b
	$5b[y] = #12;
	return processCommandInput_goNextCharacter();	//jmp $aa56
}
```
</details>

____________________
# $35:ad75 command_cheer
<details>
<summary>

>12: おうえん
</summary>

### notes:
右手攻撃力+10

### (pseudo-)code:
```js
{
	$78d5 = 1;
	$78d7 = #4b;
	$78da = #31;
	$18,19 = #7575;

	for (x = 4;x != 0;x--) {
$ad8e:
		a = $18[y = #19] + #0a;
		if (carry) { //bcc ad9c
			$78d8 = a = #ff;
		}
$ad9c:
		$18[y] = a;
		$18,19 += #0040;
	}
	return;
$adaf:
}
```
</details>

____________________
# $35:adaf commandWindow_OnItemSelected()
<details>
<summary>

>14: アイテム
</summary>

### args:
+ [in,out] u8 $52 : playerIndex

### local variables:
+	u8 $62 : cursor row index (0-3), init : 0
+	u8 $63 : cursor col index (0-7), init : 1
+	u8 $65 : background no (used in scrolling function), init : 0
+	u8 $66 : current window left (col index,equipWindow = 0), init : 1
+	u8 $67 : indicates Nth selection  (0-1)
+	u8 $68 : row index of 1st selection 
+	u8 $69 : col index of 1st selection
+	u8 $7afd[0x40] : items {id,count}
+	u8 $7b3d[0x40] : equipflags (0 = cannot use/equip,mark 'x' next to name)

### (pseudo-)code:
```js
{
	updatePpuDmaScrollSyncNmi();	//$3f:f8c5();
	$3d = 0;
	eraseWindow();	//$34:8eb0();	//disp

	$10 = #78;
	updatePpuDmaScrollSyncNmi();	//$3f:f8c5();
	createEquipWindow(erase:$7573 = 0);	//$35:b419();

	for (x = 0;x != 0x40;x++) {
		$7afd.x = $60c0.x; //$60c0 = backpackItems[0x20]
	}
	for (x = 0x23;x >= 0;x--) {
		$7b3d.x = 1;
	}
	setYtoOffset03();//$34:9b8d();
	$7af5,7af7 = $59[y++];//righthand
	$7af6,7af8 = $59[y++];
	$7af9,7afb = $59[y++];//lefthand
	$7afa,7afc = $59[y++];
	$42,43 = 0;
	for ($43 = 0;$43 != 0x20;$43++,$42+=2) {
$ae0b:
		$20 = #$9400;
		x = $42;
		a = $60c0.x;
		if (a >= 0x62) { //62=皮の帽子
			if (a >= 0x98) {	//98=魔法の鍵
				if (a < 0xc8) {	//c8=フレア
					continue;//goto $ae34;消耗品
				} else {
					goto $ae2f;//魔法
				}
			} else {
				goto $ae2f;//防具
			}	
		} else {
$ae26:			//武器か盾
			$18 = a;
			$35:b8fd();//checkEquipableFlags?
			if (0 != (a = $1c)) {
				cotinue;//goto $ae34
			}
		}
$ae2f:
		x = $43;
		$7b41.x--;
$ae34:
	}
$ae40:
	$3d = 0;
	loadTileArrayForItemWindowColumn();//$35:b48b();
	draw8LineWindow(left:$18 = #10, right:$19 = #1e, behavior:$1a = #1); //$34:8b38();
	
	loadTileArrayForItemWindowColumn();
	draw8LineWindow(left:$18 = #1f, right:$19 = #8d, behavior:$1a = #0); //$34:8b38();
	
	loadTileArrayForItemWindowColumn();
	draw8LineWindow(left:$18 = #8e, right:$19 = #9c, behavior:$1a = #0); //$34:8b38();
	//
$ae7a:
	loadAndInitCursorPos(type:$55 = 2, dest:$1a = 1);	//$34:8966();
	tileSprites2x2(index:$1a = 1, top:$1c = #f0, right:$1d = #f0);	//$34:892e()
	loadAndInitCursorPos(type:$55 = 2, dest:$1a = 0);	//$34:8966();
	$62,65,67 = 0;	//$62:cursor.y
	$63,66 = 1;	//$63:cursor.x
$aeaa:	//itemWindowInputLoop
	while (true) {
		do {
			presentCharacter();	//$34:8185();
			getPad1Input();		//$35:fbaa();
		} while ($12 == 0);
$aeb4:
		push a; //=$12=inputflag
		setSoundEffect18();	//set$ca_and_increment_$c9(#18);	//$35:9b79()
		pop a;
$aeb9:		switch (a) {
		case 0x01: //A
			goto $af4c;
		case 0x02: //B
$aec4:			goto $b198;
		case 0x10: //up
$aee0:			//
			if (0 != (a = $63)) $aeec;
			if (1 == (a = $62)) break;	//$aef5;
			$62--;
$aeec:			if (0 == (a = $62)) break;	//$aef5;
$aef0:			$62--;
			itemWindow_moveCursor();	//$35:b4d4
$aef5:			break;	//jmp $aeaa
		case 0x20: //down
$aef8:			//goto $aef8;
			if (3 != (a = $62)) {
				if (0 == (a = $63)) $62++;
$af04:				$62++;
				itemWindow_moveCursor();	//$35:b4d4();
			}
$af09:			break;	//jmp $aeaa
		case 0x40: //left
$af0c:			if (0 != (a = $63)) {
				if ($63 == (a = $66)) itemWindow_scrollLeft();	//$35:b362();
$af19:				$63--;
				if ( (0 == (a = $63))
				 && (0 == (a = ($62 & 1))) ) {
					$62 |= 1;
				}
$af2b:				itemWindow_moveCursor();	//$35:b4d4();
			}
$af2e:			break;	//jmp $aeaa
		case 0x80: //right
$af31:			if (8 != (a = $63)) {
				if ( (7 != (a = $66))
					&& ($63 != a) ) {
					itemWindow_scrollRight();	//$35:b2a7();
				}
$af44:				$63++;
$af49:				itemWindow_moveCursor();	//$35:b4d4();
$af4c:
			}
$af49:			break;	//jmp $aeaa
$af4c:
		default:
$aede:			break;	//goto $aeaa;
		}
	}
}
```
</details>

____________________
# $35:af4c itemWindow_OnAButton
<details>
<summary></summary>

### args:
+ [in,out] u8 $1d : cursor.x
+ [in,out] u8 $52 : currentPlayerIndex
+ [in] u16 $59 : playerEquipsPtr
+ [in] u16 $5e : playerPtr
+ [in] u8 $62,63 : currentSelection {row,col}
+ [in,out] u8 $67 : mode
+ [in,out] u8 $68,69 : lastSelection {row,col}
+ [in] u8 $7af5[2][0x20+4] : items {id,count}
+ [in] u8 $7b3d[0x20+4] : isEquipmentForHand?

### (pseudo-)code:
```js
{
	if (0 == (a = $67)) {
		$67++;
		$68 = $62;
		$69 = $63;
		itemWindow_moveCursor();	//$35:b4d4();
		//選択位置にカーソルを設置する
		$1d += 4;
		tileSprites2x2(index:$1a = 1, top:$1c, right:$1d );	//$34:892e()
		setSoundEffect05();	//set$ca_and_increment_$c9(#5);	//$34:9b7d();
		for (x = 0x10;x != 0;x--) {
			presentCharacter();	//$34:8185();
		}
		backToItemWindowInputLoop();
	}
$af79:	//on 2nd item selected
	if ($63 == $69 && $62 == $68) {
		return itemWindow_OnUse;	//jmp $b4f7
	} else {
$af88:		//1個目と2個目の選択アイテムが違う(いれかえようとしている)
		if ( (0 == ($63 | $69)) {
			|| ( (0 != (a = $63)) && (0 != (a = $69)) )
		{
$af96:		//左右の装備を入れ替えたか選択のどちらも装備欄じゃない
			setSoundEffect06();	//set$ca_and_increment_$c9(#6);	//$34:9b81();
			return backToItemWindowInputLoop();
		} 
$af9c:		//装備を替えようとした
		$7408 = x = 0;
		$7409 = ++x;
		if (($63 = a) >= $69) {	//bcc $afc3;
			push (a); $63 = $69; $69 = pop a;	//swap($63,$69)
			push (a = $62); $62 = $68; $68 = pop a;	//swap($62,$68)
			$7408++; $7409--;
		}
$afc3:		a = $69 << 3;	//$3f:fd3f
		a += $68 + $68
		$43 = a;
		a = $69 << 2;	//$3f:fd40
		x = $45 = a + $68;
		a = $783d.x;
		if (a == 0) { //bne $affe;
$afdf:			$34:9b81();
			if (0 != (a = $7408)) { // beq $affb;
				push (a = $63); $63 = $69; $69 = pop a;
				push (a = $62); $62 = $68; $68 = pop a;
			}
$affb:			return backToItemWindowInputLoop(); //jmp $aeaa
		}
$affe:		//盾か剣だった(入れ替えられるかもしれない)
		x = $43;	//$43 : 2*(col*4+row)
		a = $7af5.x;
		if (a >= #62) $afdf;	//にもかかわらずIDが"皮の帽子"以上だった
		$40 = a; x++;		//id (着ける方)
		$41 = $7af5.x;		//count
		$42 = x = a = ($63 << 3) + $62 + $62;	//$3f:fd3f
		$3e = $7af5.x; x++;	//id (外す方:装備欄)
		$3f = $7af5.x;		//count
		$44 = ($63 << 2) + $62;	//(col * 4 + row)
$b031:		
		isHandFreeForItem(remove:$3e,equip:$40);	//$34:b242();
		if (carry) $afdf;
		if ((a = $3e) == $40) {	//bne $b066
			if ((a | $40) == 0) $afdf;
			a = 0;x = $42;
			$7af5.x = a; x++;
			$7af5.x = a;
			x = $44;
			$7b3d.x = 1;
			x = $43; x++;
			a = $41 + $3f;
			if (a >= #64) a = #63; //bcc $b060
			$7af5.x = a;
			//jmp $b131
		} else {
$b066:			if ((a = $41) == 1
				|| (a = $40) == 0) goto $b101;
$b076:
			for ($25 = x = 0;x != #40; x += 2) {
$b07a:				a = $7afd.x;
				$24 = x;
				if (a == 0) $b089;
			}
$b087:
			$25++;
$b089:			if ((a = $40) < #4f	//bcc $b0cd #4f = "きのや"
				|| a >= #57) 	//bcs $b0cd #56 = "メデューサの矢"
				goto $b0cd;
$b093:
			if ((a = $41) < #15) $b101;	//bcc
			if ((a = $3e) == 0) $b0b1;	//beq
			if ((a = $25) != 0) goto $afdf;	//beq $b0a4
$b0a4:		//21本以上持ってる矢を着けた
			x = $24;	//index of free space (from $7afd)
			$7afd.x = $3e; x++;	//id (外した方)
			$7afd.x = $3f;		//count
$b0b1:			x = $42;
			$7af5.x = $40; x++;	//id
			$7af5.x = #14;		//count
			x = $43; x++;
			$7af5.x -= #14;		//count (つけようとしたアイテムの元の数)
			goto $b131;
$b0cd:		//矢以外
			if ((a = $3e) == 0) $b0e5;	//beq
			if ((a = $25) == 0) $b0d8;	//beq $25:空欄がなければ1
			goto $afdf;
$b0d8:
			x = $24;	//空欄
			$7afd.x = $3e; x++;
			$7afd.x = $3f;
$b0e5:			x = $42;	//装備欄
			$7af5.x = $40; x++;
			$7af5.x = 1;
			x = $43; x++;	//着けようとしたアイテムの位置
			$7af5.x -= 1;
			goto $b131;
$b101:		//1個しかないアイテムか空欄か20本以下の矢を装備した	
			x = $43;
			$7af5.x = $3e; x++;
			$7af5.x = $3f;
			x = $42;
			$7af5.x = $40; x++;
			$7af5.x = $41;
			x = $44;
			push (a = $7b3d.x)
			x = $45; a = $7b3d.x;
			x = $44; $7b3d.x = a;
			pop a; x = $45;
			$7b3d.x = a;
		}
$b131:
		for (x = 0;x != #40;x++) {
$b133:			$60c0.x = $7afd.x;
		}
$b13e:		
		setYtoOffset03();	//$34:9b8d();
		$59[y++] = $7af7;
		$59[y++] = $7af8;
		$59[y++] = $7afb;
		$59[y++] = $7afc;
		setSoundEffect05();	//set$ca_and_increment_$c9(#5);	//$34:9b7d
		if ((a = $7408) != 0) { //beq $b16a
			push (a = $63); $63 = $69; $69 = pop a;
		}
$b16a:
		if ((x = $63) == 0) { //bne $b187
			createEquipWindowNoErase();	//$35:b5f9();
			if ((a = $69) < 3) {	//bcs $b193
				push (a = $63); $63 = x = $69;
				$35:b601();
				$63 = pop a;
			} //clc bcc $b193
		} else {
$b187:
			$35:b601();
			if ((a = $63) < 3) {	//bcs $b193
				createEquipWindowNoErase();	//$35:b5f9();
			}
		}
$b193:		
		$52--;
$b195:		endItemWindow(); //goto $b1b0;
	}
$b198:
}
```
</details>

____________________
# $35:b198 itemWindow_OnB
<details>
<summary></summary>

### args:
+ [in,out] u8 $67 : mode (0 = 1st,1=2nd selection)

### (pseudo-)code:
```js
{
	if (0 != (a = $67)) {
		$67--;
		tileSprites2x2(index:$1a = 1, top:$1c = #f0, right:$1d = #f0);	//$34:892e()
		backToItemWindowInputLoop();	//jmp $aeaa
	}
$b1ae:
	$52--;	//current char index?
	return endItemWindow();	//here $b1b0
$b1b0:
}
```
</details>

____________________
# $35:b1b0 endItemWindow
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	eraseWindow();	//$34:8eb0();
	$10 = 0;
	$08 &= #fe;
	updatePpuDmaScrollSyncNmi();	//$3f:f8c5();
	init4SpritesAt$0220(index:$18 = 0);	//$34:8adf();
	init4SpritesAt$0220(index:$18 = 1);	//$34:8adf();
$b1ce:	$52++;
	//無条件にこれを実行するのがウインドウイレースの原因
$b1d0:	dispatchBattleFunction(5); //$34:8026();	
	a = 0;
$b1d5:	returnToGetCommandInput();//jmp $34:99fd
$b1d8:
}
```
</details>

____________________
# $35:b1d8 loadTileArrayOfItemProps
<details>
<summary></summary>

### args:
+ [in] u8 $34[2][4] : items
+ [in] u16 $43 : ptrToDestTileArray

### (pseudo-)code:
```js
{
	initTileArrayStorage();	//$34:9754();
	for ($3c = 0;$3c != 8;$3c += 2) {
$b1df:
		fillXbytesAt_7ad7_00ff(x = #d);	//$35:a549
		x = $3c;
		$1a = a =$34.x;
		if (a == #ff) { //bne $b1f6
			offset$4E_16(a = #d);	//$35:a558
			//clc bcc $b232
		} else {
$b1f6:
			if ((a = $7400.x) == 0) {	//bne $b200
				$7ad7 = #73;
			}
$b200:
			loadString(index:a = $1a,dest:x,  base:$18 = #8800);	//$a609
			$7ae1 = #c8;
			$19 = 0;
			x = $3c;
			itoa_16(value:$18 = $35.x);	//$34:95e1();
			$7ae2,7ae3 = $1d,1e;	//下2桁
			strToTileArray($18 = #0d);	//$34:966a();
$b232:		}
		offset$4e_16(a = #0d);
	}
$b241:	return;
$b242:
}
```
</details>

____________________
# $35:b242 isHandFreeForItem
<details>
<summary></summary>

### args:
+ [in] itemid $3e : toRemove
+ [in] itemid $40 : toEquip
+ [in] itemid $7af5 : righthand
+ [in] itemid $7af9 : lefthand
+ [out] bool carry : 0:ok 1:bad combination

### notes:
外そうとしている手の逆に着けてるものと着けようとしている物の組み合わせを調べる
		素手	片手	竪琴	弓	矢	盾	防具その他
	(id)	00	01	46	4a	4f	58	(62-)
			00	45	49	4e	57	61
	00-00	o	o	o	o	o	o
	01-45	 	o	x	x	x	o
	46-49 			x	x	x	x
	4a-4e 				x	o	x
	4f-57 					x	x
	58-64						o

### (pseudo-)code:
```js
{
	$1d = $40;	//着けようとしてるもの
	if ((a = $7af5) == $3e) {	//bne $b250
		$1c = $7af9;	//右手と一致したので左手を見る
	}
	if ((a = $1d) >= $1c) { //bcc $b260
		push (a = $1c); $1d = a; $1c = pop a;
	}
	//here always $1c > $1d
$b260:
	if ((a = $1c) == 0)	$b2a5;		//ok:(empty)
	if (a >= #62) $b2a6;			//fail:かわのぼうし
	if (a >= #58) {				//かわのたて
		if ((a = $1d) == 0) $b2a5;	//
		if ((a >= #58)) $b2a5;		//
$b276:
		if (a >= #46) $b2a6;		//fail:マドラのたてごと
		else $b2a5;
	}
$b27c:
	if (a >= #4f) {				//きのや
		if ((a = $1d) == 0) $b2a5;
		if (a >= #4f) $b2a6;		//きのや
		if (a >= #4a) $b2a5;		//ゆみ
		else sec; $b2a6;
	}
$b28f:
	if (a >= #4a) {				//ゆみ
		if ((a = $1d) == 0) $b2a5;
		else sec; $b2a6;
	}
$b29a:
	if (a >= #46) {				//マドラのたてごと
		if ((a = $1d) == 0) $b2a5;
		else sec; $b2a6;
	}
$b2a5:	clc;
$b2a6:	return;	
}
```
</details>

____________________
# $35:b2a7 itemWindow_scrollRight
<details>
<summary></summary>

### args:
+ [in,out] u8 $65 : background no
+ [in,out] u8 $66 : left(colIndex,0-7)
+ [in] u8 $69 : col index of 1st selection (if avail)
+ [in] u8 $67 : mode

### (pseudo-)code:
```js
{
	if ((a = $66) < 6) { //bcs  $b2ea
		$3d = (a + 2) << 3;//fd3f
		loadTileArrayForItemWindowColumn(firstItem:$3d );	//$35:b48b
		x = a = ($66 + 2) << 1
		$18,19 = $b636.(x++),$b636.x
		if ((a = $66) < 5) { //bcs $b2d4
			a = 0 //bne $b2e5
		} else {
$b2d4:
			push (a = $18); push (a = $19);
			eraseFromLeftBottom0Bx0A();	//$34:8f0b
			$19 = pop a;$18 = pop a
			a = 2;	//draw right-border
		}
$b2e5:
		$1a = a;
		draw8LineWindow(left:$18, right:$19, behavior:$1a); //$34:8b38();
	}
$b2ea:	
	if ((a = $66) != 7) { //beq $b31b
		$66++;
		$64 = $10 + #78;
		$65 ^= 1;
		do {
$b301:
			updatePpuDmaScrollSyncNmi();	//$3f:f8c5
			$10 += #14
			if (carry) { //bcc $b315
$b30d:
				$08 = $65 | $08 & #fe;				
			}
$b315:		} while ($10 != $64);	//bne $b301
	}
$b31b:	if ((a = $67) != 0) { //beq $b350
		if ((a = $66) == $69) $b32c
		a += 1;
		if (a != $69) $b350
$b32c:
		a = #a8;
		//if ((x = $68) == 0) $b338
		for (x = $68;x != 0;x--) {
$b333:			a += #10;	//inloop,no clc
		}
$b338:
		$1c =a;
		x = #0c;
		if ((a = $69) != $66) x = #84;	//beq $b344
$b344:
		tileSprites2x2(index:$1a = 1, top:$1c, right:$1d = x);	//$34:892e()
		clc bcc $b361
	} else {	
$b350:		//[$67 == 0] hide(move off) 2nd cursor
		push (a = $1c);
		tileSprites2x2(index:$1a = 1, top:$1c = #f0, right:$1d);	//$34:892e()
		$1c = pop a
	}
$b361:
	return;
$b362:
}
```
</details>

____________________
# $35:b362 itemWindow_scrollLeft
<details>
<summary></summary>

### args:
+ [in,out] u8 $10 : windowX
+ [in,out] u8 $65 : background no
+ [in,out] u8 $66 : left(colIndex,0-7)
+ [in] u8 $69 : col index of 1st selection (if avail)
+ [in] u8 $67 : mode

### (pseudo-)code:
```js
{
	if ((a = $66) >= 2) { //bcc $b3a3
		if (a == 2) {	//bne b375
$b36a:
			createEquipWindow(erase:$7573 = 0);	//$34:b419
		} else {
$b375:	//draw 3-columns-left column
			$3d = (a - 3) << 3;	//fd3f
			loadTileArrayForItemWindowColumn(firstIndex:$3d);	//$34:b48b
			x = a = ($66 - 3) << 1;
			$18,19 = $b636.x

			a = ($66 == 3) ? 1 : 0
$b39e:			$1a = a;
			draw8LineWindow(left:$18, right:$19, behavior:$1a); //$34:8b38()
		}
	}
$b3a3:	//scroll left
	if ((a = $66) != 0) { //beq b3d2
		$66--;
		$64 = $10 - #78;	//$10 : scroll.x applied on irq
		if (!carry) { //bcs b3b8
			$65 ^= 1;
		}
$b3b8:		do {
			updatePpuDmaScrollSyncNmi();	//$3f:f8c5
			$10 -= #14;
			if (!carry) { //bcs b3cc
				$08 = $08 & #fe | $65	//$08 : ppu.ctrl1 applied on irq
			}
		} while ((a = $10) != $64); //bne b3b8
	}
$b3d2:
	//update cursor to reflect scroll
	if ((a = $67) != 0) { //beq $b407
		if ((a = $66) == $69) $b3e3
		a += 1;
		if ((a != $69) $b407
$b3e3:		a = #a8;
		for (x = $68;x != 0;x--) {
$b3ea:			a += #10;
		}
$b3ef:
		$1c = a;
		x = #0c;
		if ((a = $69) != $66) // beq $b3fb
			x = #84
$b3fb:		$1d = x;
		tileSprites2x2(index:$1a = 1, top:$1c, right:$1d = x);	//$34:892e()
		clc bcc $b418
$b407:	} else {
		push (a = $1c)
		tileSprites2x2(index:$1a = 1, top:$1c = #f0, right:$1d);	//$34:892e
		$1c = pop a
	}
$b418:
	return;
$b419:
}
```
</details>

____________________
# $35:b419 drawEquipWindow
<details>
<summary></summary>

### args:
+ [in] u16 $59 : ptrToEquips ($6200)
+ [in] bool $7573 : eraseFlag 

### (pseudo-)code:
```js
{
	for (x = 7;x >= 0;x--) {
		$7400.x = 1;
		$34.x = #ff;
	}
	y = a = getPlayerOffset() + 3;//$35:a541();
$b432:
	$36 = $59[y]; y+=2;	//equip.right.id,count
	$3a = $59[y]; y+=2;	//equip.left.id,count
	
	loadTileArrayOfItemProps();	//$35:b1d8();

	$7201 = $7235 = #c0;	//'"'
	$720f = $7244 = #9c;	//'て
	$720d = #a9;		//		
	$720e = #90;
	$7241 = #a4;
	$7242 = #99;
	$7243 = #b1
	if (#ff != (a = $7573) )  {
		eraseFromLeftBottom0Bx0A();	//$34:8f0b();
	}
	return draw8LineWindow(left:$18 = #01, right:$19 = #0f, behavior:$1a = #03); //jmp $34:8b38();
$b48b:
}
```
</details>

____________________
# $35:b48b loadTileArrayForItemWindowColumn()
<details>
<summary></summary>

### args:
+ [in,out] u8 $3d : firstItemOffset, incremented by 8 per call

### (pseudo-)code:
```js
{
	for (x = 7;x >= 0;x--) { $7400.x = 1; }
	y = $3d;
	for (x = 0;x != 8;x++) { $34.x = $60c0.y++; }
	for (x = 0;x != 8;x+=2) {
		if (0 == (a = $34.x) {
			$34.x = #57;
		}
	}
$b4b4:
	y = a = $3d >> 1;
	for (x = 0;x != 8;x+=2,y++) {
		if (0 == (a = $7b41.y)) {
			$7400.x--;
		}
	}
$b4c9:
	y = $3d = a = $3d + 8;
	return loadTileArrayOfItemProps();
	//jmp $35:b1d8
$b4d4:
}
```
</details>

____________________
# $35:b4d4 itemWindow_moveCursor
<details>
<summary></summary>

### args:
+	[in] u8 $62 : cursor row index (0-3)
+	[in] u8 $63 : cursor col index (0-7)

### (pseudo-)code:
```js
{
	a = #a8;
	for (x = $62; x != 0;x--) {
$b4db:		a += #10;
	}
$b4e0:
	$1c = a;
	if ($66 == (a = $63)) a = #8;
$b4ec:	else a = #80;
$b4ee:	$1d = a;
	return tileSprites2x2(index:$1a = 0, top:$1c, right:$1d );	//$34:892e()
$b4f7:
}
```
</details>

____________________
# $35:b4f7 itemWindow_OnUse
<details>
<summary></summary>

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
</details>

____________________
# $35:b5f9 drawEquipWindowNoErase
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$7573 = a = #ff;
	return drawEquipWindow();	//$35:b419();
$b601:
}
```
</details>

____________________
# $35:b601 redrawColumn
<details>
<summary></summary>

### args:
+ [in] u8 x : col

### local variables:
+	$35:b636: windowInitParams[8]

### (pseudo-)code:
```js
{
	$3d = a = (--x) << 3;//$fd3f
	loadTileArrayForItemWindowColumn(first:$3d);	//$b48b
	x = ($63 - 1) << 1;
	$18 = $b636.x; x++;
	$19 = $b636.x;
	if ((a = $63) == 1) a = 1; $b631;
$b627:	if (a == 8) a = 2; $b631;
$b62f:	a = 0;
$b631:	$1a = a;
	return draw8LineWindow(left:$18, right:$19, borderFlag:$1a);
$b636:
}
```
</details>

____________________
# $35:b646 commandWindow_OnMagic
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	a = $7ed8 & #40;
	if (a != 0) { //beq b655
		setSoundEffect06();	//set$ca_and_increment_$c9(#6);	//$34:9b81();
		a = 1;
		return getCommandInput_next();	//$34:99fd();
	}
$b655:
	a = #ff;
	for (x = #17;x >= 0;x--) { $7400.x = a; }
$b65f:
	setYtoOffsetOf(a = #3f);	//$34:9b88;
	x = 7;
$b666:	while ((a = $57[y]) == 0) {
		x--; y -= 2;
	}
$b670:
	$46 = $27 = a = x;
	push a;
	a = $18 = (7 - $27);
	a <<= 1;	//2
	$19 = a;	//2
	a <<= 1;	//4
	$18 = $19 + $18 + a	//2+1+4 = 7 (7*(7-$27))
	$24 = 0;
$b98c:
	while ($27 > 0) {
		$25 = 3;
		setYtoOffsetOf(a = #7);	//$34:9b88();
		y = a + $27;
		a = $59[y];
		$1c = x = 7;
$b69e:	
		do {	//bit7が立ってるとバグると思われる
			a >>= 1;
			if (carry) {	//bcc $b6b7;
				push a;
				x = $24;
				$7400.x = $18;
				$18++; $24++;
				pop a
				$25--;
				x = --$1c;
				//if (x != 0) continue;
			} else {
$b6b7:		
				$18++;
				x = --$1c;
			}
			//if (x == 0) break;
		} while (x != 0);
$b6bf:
		$24 += $25;
		a = --$27;
	}
$b6cc:
	initTileArrayStorage();	//$34:9754();
	x = pop a;
	$24 = ++x;
	$25 = y = a << 1;
	$26 = a = 0;
$b6dc:
	for ($24;$24 != 0;$24--) {
		initString(cch:x = #1c);	//$35:a549();
		$27 = 8;
		$7ad7 = $24 + #80;
		$7adb = #c7;
		setYtoOffsetOf(a = #6);	//9b88
		y = a + $24;
		$18 = $5b[y];
		$19 = 0;
		itoa_16(val:$18,19);	// $34:95e1();
		$7ad9,7ada= $1d,1e;
		setYtoOffsetOf(a = #31);//9b88
$b714:
		y = a + $25;
		$18 = $57[y];
		$19 = 0;
		itoa_16(val:$18,19);	//$34:95e1();
		$7adc,7add = $1d,1e;
		$25 -= 2;
		for ($28 = 3;$28 != 0;$28--) {
$b734:
			x = $26;
			$1a = a = $7400.x;
			if (a != #ff) {	//beq $b76f;
$b73f:
				$18 = a;
				push a;
				$20,21 = #98c0;
				$35:b8fd();
				if ((a = $1c) == 0) {	//bne $b75f;
$b751:
					x = $27;
					$7ad7.x = #73;
					x = $26;
					$7400.x = #ff;
$b75f:				}
				$27++;
				$18,19 = #8990;
				pop a;
				x = $27;
				loadString(dest:x, base:$18);	//a609
$b76f:			}
			$27 += 6;
			$26++;
		}	//bne b734
$b77e:
		strToTileArray(cchLine:$18 = #1c);	//$34:966a();
		offsetTilePtr(offset:a = #1c);	//$35:a558();
		//a = --$24;
		//if (a != 0) goto $b6dc; //beq b793
	}

$b793:
	eraseWindow();	//$34:8eb0();
	draw8LineWindow($18 = 1, $19 = #1e, $1a = #3); //$34:8b38
	loadAndInitCursorPos(type:$55 = 1, dest:$1a = 0)	//$34:8966();
	$24 = $25 = $26 = 0;
	x++;
$b7b8 magicWindow_inputLoop:
	$1a = $38 = x = 0;
	$1b = a = 2;
	getInputAndUpdateCursorWithSound();	////$34:899e();
	$29 = 0;
	$1e,1f = #ba2a;
$b7d2:
	a = $12
$b7d4:	do {
		a >>= 1;
		if (carry) break; //bcs b7db
		$29++;
	}
$b7db:
	$1e,1f += ($29<<1)
	$1e,1f = *($1e);
	(*$1e)();	//jumptable
$b7f9:
}
```
</details>

____________________
# $35:b7f9 magicWindow_OnUp
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	if ((a = $24) == 0) return;	//beq $b874
	$24--;
	if ((a = --$25) > 0) return;	//bpl $b874
	$25++;
	$7ac0,7ac1 -= #0038;
	draw8LineWindow(left:$18 = 1, right:$19 = #1e, borderFlags:$1a = 3);	//$8b38
	return;	//jmp $b874
}
```
</details>

____________________
# $35:b82a magicWindow_OnDown
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	if ((a = $24) == 7) return;	//beq $b874
	if (a == $46) return;	//beq $b874
	$24++;
	$25++;
	if ((a = $25) < 4) return; $b874
	$25--;
	$7ac0 += #0038;
	draw8LineWindow();
	return;	//jmp
}
```
</details>

____________________
# $35:b863 magicWindow_OnLeft
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	if ((a = $26) == 0) return;	//beq $b874
	$26--;
	return;	//jmp $b874
$b86c:
}
```
</details>

____________________
# $35:b86c magicWindow_OnRight
<details>
<summary></summary>

### code:
```
{
	if ((a = $26) == 2) return;	//beq $b874
	$26++;
$b874:
}
```
</details>

____________________
# $35:b874 magicWindow_OnSelectOrStart 
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	return;	//jmp $b7b8
}
```
</details>

____________________
# $35:b877 magicWindow_OnA 
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	$18 = a = $24;
	x = $26 + $18 + ($18 << 1); //row*3+col
	a = $7400.x;	//;magicid
	if (a == #ff) 
$b889:		goto $b8b5; //bne jmp
$b88c:
	push a;
	if ((0 == (a = $7ed8) & #10)) $b89a;
	pop a
	if (a == #2f) $b889;	//beq
	push a
$b89a:
	$47 = push ($46 - $24);
	x = $52;
	$7ac7.x = $47;
	pop a
	y = a + $5f + #7;
	a = $5b[y];
	if (a != 0) $b8bb;	//bne
$b8b4:
	pop a;
$b8b5:
	$9b81();
	return;	//jmp $b7b8
$b8bb:
	$9b7d();
	pop a;	//magic id
	push a;
	$b953();
	if (a == 0) $b8d1;	//beq
	if (a != 1) $b8cd;	//bne
	pop a;
	goto $b8b5;
$b8cd:
	pop a;
	return magicWindow_close();	//$b8ee;
$b8d1:
	$9b9b();
	x = $52;
	$5b[y] = $78cf.x = pop a + #c8;
	if (a != #ff) $b8ec;
$b8e3:
	a = $7be1;
	$fd20();
	$7be1 = a;
$b8ec:
	$52++;
}
```
</details>

____________________
# $35:b8ee magicWindow_OnB 
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	init4SpritesAt$0220(index:$18 = 0);	//$34:8adf();
	eraseWindow();	//$34:8eb0();
	return getCommandInput_next(noRedraw:a = 0);	//jmp $99fd
}
```
</details>

____________________
# $35:b8fd isPlayerAllowedToUseItem
<details>
<summary></summary>

### args:
+ [in] u8 $18 : itemid
+ [in] u16 $20 : ? itemDataBase = #$9400
+ [out] u8 $1c : allowed (1:ok 0:not)
+ [out] u8 $7478[8] : itemParams

### (pseudo-)code:
```js
{
	loadTo7400FromBank30(id:$18, size:$1a = #8, dest:x = #78);	//$ba3a();
	$38 = ($747f & #7f);
	x = $38 * 3;
	$3f:fd8b();
	$38,39,3a = $3b,3c,3d
	y = updatePlayerOffset();	//$a541();
	a = $57[y];	//job
	$b93e();
$b92a:
	$1c = x = 0;
	for (x = 0;x != 3;x++) {
$b92e:
		a = $38.x & $3b.x
		if (a != 0) goto $b93b;	//bne $b93b 
	}
$b93b:
	$1c++;
$b93d:	return;
}
```
</details>

____________________
# $35:b93e flagJob
<details>
<summary></summary>

### (pseudo-)code:
```js
{
+ [in] a=jobindex
	$3b,3c,3d = {0};
	sec
	for (x = jobindex;x>0;x--) {
		rol $3d
		rol $3c
		rol $3b
	}
	return;
$b953:
}
```
</details>

____________________
# $35:b953 setMagicTarget
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	//sec
	$18 = $7ce8 = a;
	$20,21 = #98c0
	isPlayerAllowedToUseItem();	//b8fd
	a = $747c;	//itemparam[4]
	if (a == 1) { //bne $b970
		$7ce8 = #ff;
	}
$b970:
	if ((a = $1c) != 0) $b979
$b974:
	a = 1;
	return;	//jmp $ba29
}
```
</details>

____________________
# $35:b979 setItemEffectTarget
<details>
<summary></summary>

### args:
+ [in] u8 $7478[8] : itemparam

### local variables:
+	u8 $b3 : selectTargetFlag (01:allowMulti 02:defaultPlayerSide)

### (pseudo-)code:
```js
{
	if (0 == (a = ($747d & #18)) ) { //bne b983
$b980:		goto $ba27;
	}
$b983:
	if ((a = ($747d & #40) != 0) $b9f0	//bne
$b98a:
	$b3 = 0;
	if ((a = ($747d & #20) != 0) $b999	//bne
$b995:
	$b3 = 1;
$b999:	if ((a = $747d) >= 0) $b9a4
$b99e:
	$b3 |= 2;
$b9a4:	if ((a = $7ce8) != #ff) $b9cf
$b9ab:	
	init4SpritesAt$0220(index:$18 = 0);	//$34:8adf();
	eraseWindow();	//$34:8eb0();
$b9b9:
	$10 = 0;
	$08 &= #fe;
	updatePpuDmaScrollSyncNmi();	//$3f:f8c5
	drawInfoWindow();	//$34:9ba2
	getPlayerOffset();	//35:a541
$b9cf:	$7ce8 = 0;
$b9d4:
	call_2e_9d53(a = #10);	//$3f:fa0e #10 : select target

	if ((a = $b4) == 0) {	//cancel (all target bits are off = nothing selected)
		a = 2;
		return;	//bne $ba29
$b9e1:	} else {
		$5b[y++] = $b4;	//target indicator bits
		$5b[y] = $b5;	//flag
		return (a = 0);	//jmp $ba27
	}
	//-------------------------------------------
$b9f0:	//#40 : 強制全体化?
	$18,19 = #7675;
$b9f8
	push (a = 0);
	for (x = 0;x != 8;x++) {
$b9fd:
		a = $18[y = 1] & #c0;	//dead|stone
		if (a == 0) { //bne $ba0a
			pop a
			flagTargetBit();	//$3f:fd20
			push a
		}
$ba0a:		$18,19 += #0040;
	}
$ba1c:
	setYtoOffset2F();	//$9b94
	$5b[y++] = pop a;	//all selected target bits are flagged(1)
	$5b[y++] = #c0;		//enemy|all
$ba27:
	a = 0;
$ba29:
	return;
}
```
</details>

____________________
# $35:ba2a commandWindow_OnMagic_inputHandlers[8] = 
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	77 B8 EE B8 74 B8 74 B8 F9 B7 2A B8 63 B8 6C B8
}
```
</details>

____________________
# $35:ba3a loadTo7400FromBank30
<details>
<summary></summary>

### args:
+ [in] $1a : itemDataSize
+ [in] $18 : itemid (if magic,itemid-#$30)
+ [in] x : destOffset

### (pseudo-)code:
```js
{
	return loadTo7400Ex(bank:a = #18,restore:y = #1a);
}
```
</details>

____________________
# $35:ba41 processPoison
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	a = #ff;
	for (x = #1f;x >= 0;x--) {
		$7400.x = a;
	}
	$64 = 0;
	$24 = 8;
	$28,29 = #7575;
	for ($24;$24 != #0c;$24++) {
		getPoisonDamage();	//$badc();
		$28,29 += #40;
	}
$ba73:
	$9d06();
	$24 = 0;
	$28,29 = #7675;
	for ($24;$24 != #08;$24++) {
$ba82:
		getPoisonDamage();	//$badc();
		x = $24;
		$7ec4.x = $28[y = #01];
		$28,29 += #40;
	}
$baa3:
	if ($64 != 0) { //beq $badb
		for (x = #1f;x >= 0;x--) {
			$7e4f.x = $7400.x;
		}
$bab2:
		$7e98 = $7e99 = #80;
		$7e9a = (a >> 1); //=#40
		$78d5 = #05;
		$78da = #41;
		$7ec2 = #17;
		presentBattle();	//8ff7
		$7ec2 = #16;
		$83f8();
		canPlayerPartyContinueFighting();	//$a458();
	}
$badb:
	return;
}
```
</details>

____________________
# $35:badc getPoisonDamage
<details>
<summary></summary>

### (pseudo-)code:
```js
{
	a = x = $28[y = #01];
	if ( ((a & #02) != 0) //beq bb3f
		&& ((x & #c0) == 0)) //bne bb3f
	{
		$64++;
		$62 = $24 << 1;
		$26 = $28[y = #05];
		$27 = $28[++y];
$bafc:
		$26,27 >>= 4;
		x = $62;	//index<<1
		$7400.x = $26; x++;
		$7400.x = $27;
	}
}
```
</details>


____________________
# $35:bb49 prize
<details>
<summary></summary>

### args:
+ [in] u16 $57 : playerParamBasePtr (=$6100)
+ [in] u16 $5b : playerBattleParamBasePtr (=$7575)
+ [in] u8 $78f0[4][4] : playerActionCounts
+ [in] u8 $7d6b[4] : mobids
+ [in] u8 $7dd3[4] : killCounts?
+ [out] u8 $7571 : droppedItemCount
+ [out] u8 $7434[30h] : droppedItems
+	u8 $52 : playerIndex
+	u8 $53 : alivePlayerCount
+	u16 $5f : playerOffset
+	u8 $7570 : enemyGroupNo

### local variables:
+	BattlePrizeInfo $7400 : enemyInfo

### dependencies:
+	$34:8ff7 : presentBattle
+	$34:9b88 : setYtoOffsetOf
+	$34:9b8d : setYtoOffset03 (03:exp)
+	$35:a541 : calcPlayerOffset
+	$35:a564 : getSys1Random
+	$35:ba3a : loadTo7400FromBank30
+	$35:bf7c : lvupParams
+	$35:bfb3 : ? some item related routine
+	$3f:fa0e : call_2e_9d53
+	$3f:fc92 : div16
+	$3f:fcd6 : mul8x8
+	$3f:fcf5 : mul16x16
+	$3f:fd3c~41 : shiftLeftN
+	$3f:fd43~48 : shiftRightN
+	$3f:fda6 : loadTo7400Ex

### notes:
	struct BattlePrizeInfo { //@ram7400
		u8  ? $10:9c80		//00
		u16 exp; 		//01 from $10:9d80
		MobBaseParam ;		//03
		u8 dropList[8];		//13 $10:9b80[ mobparam.0F &1F ]
		u16 gil;		//1b from $30:9c58
		u8 capacity; 		//1d from $39:b2ae
	}

### (pseudo-)code:
```js
{
	call_2e_9d53(a = #0f);	//$3f:fa0e();

	$7570,7571 = 0;
	for ($52 = 0;$52 < 4;$52++) {
		y = getPlayerOffset() + 1; //$35:a541()
		a = $5b[y] & #c0;
		if (a == 0) {
			x++;
		}
	}
	$53 = x;
	$52 = 0;
	for (x=0;x < 0x34;x++) {
		$7400.x = 0;
	}
	for (x;x < 0x80;x++) {	
		$7400.x = #ff;
	}
$bb87:
	for ($7570;$7570 < 4;$7570++) {
		x = $7570
		$2c = $7dd3,x
		$32 = mobid (= $7d6b,x)
		//$18 = mobid
		//$1a = 1
		//$20 = #$9c80
		//A = 8 X = 0 Y = 1A
		//loadParamEx()
		loadTo7400Ex({
			$18_index: mob_id,
			$1a_size_of_entry: 1,
			$20_base_address_of_table: #$9c80,
			A_bank_index_of_table: 8,
			X_dest_offset: 0,
			Y_current_bank: #$1a
		})
		$18 = $7400
		$1a = 2
		$20 = #$9d80
		x = 1
		loadParamEx()
		$18 = mobid
		$1a = #$10
		$20 = #$8000 ($30:8000)
		x = #3
		loadParam()
		$18 = $7412&1f
		$1a = 8
		$20 = #$9b80
		loarParamEx(x=#$13)
		$18 = mobid
		$1a = 2
		$20 = #$9c58
		loadParam(x=#$1b)
		$18 = mobid
		$1a = 1
		$20 = #$b2ae ($39:b2ae)
		loadParamEx(x=1d,y=1a,a=1c)
		//@$7400 {
			u8  exp_table_id 	//00 $10:9c80[mob_id]
			u16 exp				//01 $10:9d80[exp_table_id]
			MobBaseParam ;		//03
			u8 dropList?[8]		//13 $10:9b80[ mobparam.0F &1F ]
			u16 gil? $30:9c58	//1b
			u8 capacity? $39:b2ae	//1d
		}
		//$18,19 = $7401,7402
		//$1a,1b = $53,#00
		$7401,7402 /= $53	//$53=生存者数
		for ($2c;$2c > 0;$2c--) {	//$2c = 敵グループ内撃破数
			$7424,7425,7426 += $7401,7402,#00
			$7427,7428,7429 += $741b,741c,#00

$bc7e:
			$2e = $7412 >> 5;	//jsr fd44
			a = getSys1Random(6);	//jsr $35:a564(a=#6)
			if (a < $2e) {	//bcs bce6
				getSys1Random(max:a = #ff);
				if (a < 30h) a = 0;	//12/64
				else if (a < 60h) a = 1;//12/64
				else if (a < 90h) a = 2;//12/64
				else if (a < c0h) a = 3;//12/64
				else if (a < d8h) a = 4;// 6/64
				else if (a < f0h) a = 5;// 6/64
				else if (a < fch) a = 6;// 3/64
				else a = 7;		// 1/64
				
				a = $7413[a] 
				if (a != nullItem) {	//beq bce6
					incrementItem();	//$bfb3();
					if ( (carry)  //bcc bce6 
						&& ((x = $7571) < 30h) ) //bcs bce6
					{
							$7434,x = a; $7571++;
					}
				}
$bce6:
			}
			$742a += $741d
		}
	}
	$601c,601d,601e += $7427,7428,7429
	if ($742a != 0) {
		$742a = 1 + $742a>>2; //jsr $fd47 A>>=2
		if ($601b + $742a > 0xff) {
			$601b = 0xff;
		} else {
			$601b += $742a;
		}
	}
	$78d5,$7ec2 = 2;
	$78da = #2d;
	$78e4,78e5 = $7427,$7428	//gil
	//jsr $34:8ff7			//display routine
	$78da = #2e;
	$78e4,78e5 = $742a,#00		//capacity
	//jsr $34:8ff7
	$78da = #40;
	$78e4,78e5 = $7424,$7425	//exp
	
	//jsr $34:8ff7
	for ($3c = 0;;$3c++) {
		var item = $7434[$3c];
		if (item == 0xFF) break;
		$78e4 = item
		$78da = #29
		//おたから : xxxxxxxx
		//jsr $34:8ff7
	}
$bd9b:
	for ($52;$52 < 4;$52++) {	//$52は $35:bb71 で 0に初期化
		getPlayerOffset();	//$5f = $52 << 6;	//$35:a541()
		y = $5f + 1;
		a = ($5b),y & #c0;	//石化か死亡なら飛ばす?
		if (a != 0) cotinue; //jmp $35:bf70
		
		//熟練度上昇処理
		$1e,1f,20 = #0
		$1c = $52 << 2;	//jsr $fd40 a<<=2
		setYtoOffsetOf(a = #35);	//9b88
		$22 = ($5b),y	//2bit値の係数?
		for ($20;$20 != 4; $20++) {
			$23 = #0;
			$22,23 <<= 2;
			a = $78f0.$1c;	//$1c = playerNo * 4
			x = $23;
			$1a,1b = mul8(a,x); //$3f:fcd6()
			$1e,1f += $1a,1b
			$1c++;
		}
$bdf0:
		$1e,1f <<= 2;	// asl,rol
		setYtoOffsetOf(a = #11);	//$9b88
		$1e,1f += ($57),y , #00

		$1e,1f -= 100;
		if ( $1e,1f >= 0 ) {
			($57,y) = 0;
			y--;
			a = ($57,y) + 1;
			if (a < 99) {
				($57,y) = a;
				$78d5,$78d6 = #04,$52;
				$78da = #22;
				//じゅくれんどアップ!
				//jsr $34:8ff7
			}
		}
$be39:
		setYtoOffset03();
		//add exp
		$57[y] = $2f = $7424 + $57[y++];	
		$57[y] = $30 = $7425 + $57[y++];
		$57[y] = $31 = $7426 + $57[y];
		y -= 2;		
		if ($57[y] - #98967f >= 0) {	//#98967f =  999999999
			$57 = $2f = #98997f	//#98997f = 1000000767
		}

		y = $5f + 1;
		$18 = x = a = $57[y];	//LV
		$1a = #3;
		$20 = #$a0b0;
		//loadParamEx(a=#1c,x=#1e,y=#1a);
		$741e,741f,7420 = $39:a0b0.(lv*3);
$beaa:
		if ($2f,30,31 - $741e,741f,7420 < 0) {
$beb2:
			//獲得exp加算済みExpが必要Expを超えている
			y = $5f + 1;//offset to lv
			x = $32 = a = $57[y];
			a = x = a + 1;
			if (a < 99) {
$bec3:
				$57[y] = a;
				setYtoOffsetOf(a = #14);	//$9b88
				$24 = a = $57[y];	//VIT
				a >>= 1;
				$24 += getSys1Random(vit/2); //$35:a564();
				y = $5f + 1;
				a = $57[y] << 1;	//lv
				$24 += a;
				setYtoOffsetOf(a = #0e);	//$9b88
				$57[y] += $24,#00;	//maxHP
$bef6:				
				if ($57[y] - #270f >= 0) {
					$57[y] = #270f;	//#270f = 9999
				}
				y = $5f;
				//$18 = a = $57[y];	//job
				//$1a = #c4;
				$1c = mul16(job,#c4);
				$20,21 = $1c,1d + #a1d6;
				$18 = $32;	//LV
				$1a = #2
				//loadParamEx(a=#1c,x=#21,y=#1a);
				$7421,7422 = ($39:a1d6 + job*#c4).(lv*2)
				
				a = $7421;
				lvupParams();	//$35:bf7c();

				setYtoOffsetOf(a = #31); //$9b88
				for (x = 8;x > 0;x--) {
$bf49:
					$7422 >>= 1;
					if (carry) {
						a = $57[y] + 1;	//maxMp
						if (a < 100) {
							$57[y] = a;
						}
					}
					y += 2;
				}
$bf5e:
				$78d5,78d6 = #4,$52; //playerNo
				$78da = #20
				//レベルアップ!
				//jsr $8ff7
			}	//lv < 99?
		}	//LVup?
$bf70:
	}
$bf7b:
	return;
}
```
</details>

____________________
# $35:bf7c battle.grow_player
<details>

### args:
+ [in] u8 A: lvupInfo
+ [in] u16 $57 : playerParamBasePtr
+ [in] u8 $5f : playerOffsetBase

### (pseudo-)code:
```js
{
	$19 = a;
	$18 = a & 7;
	setYtoOffsetOf(a = #12);	//$9b88
	for (x = 5;x >0;x--) {
$bf89:
		$19 <<= 1;
		if (carry) {
			clc;
			a = $57[y] + $18;
			if (a >= 100) a = 99;
			$57[y] = a;
			a = y;
			var temp = a;//pha
			y = a + 5
			a = $57[y] + $18;
			if (a >= 100) a = 99;
			$57[y] = a;
			y = temp; //pla
		}
		y++;
	}
$bfb3:
}
```
</details>

____________________
# $35:bfb3 incrementItem
<details>
<summary></summary>

### args:
+ [in] u8 a : itemid
+ [out] bool carry : succeeded (1)

### notes:
	指定されたidをもつitemの数を1個増やす
	同じidのitemがなければ空欄を見つけてそこに置く
	もしみつからなければcarryをクリアして戻る
	同じidがありかつ99個以上の場合indexを1つ後ろにずらしたまま
	空欄(0)を探すので本来item32個分で終わるはずの検索も
	(60c0-61bfの奇数アドレスのどれかが0になるまで)終わらず
	0だったアドレスの次の値が1増える
	(item欄ならitemid,最後のitemなら先頭のキャラのjob)
	

### (pseudo-)code:
```js
{
	$18 = a;
	for (x = 0;x != #40; x += 2 ) {
		if ($60c0.x == $18) { //bne bfcf
$bfbe:
			x++;
			a = $60c0.x + 1;
//$bfc7: B0 0E bcs $bfd7 => B0 25 bcs $bfee (fail) or B0 0C (try to find freespace)
			if (a < 100) { //bcs bfd7
$bfc9:
				$60c0.x = a;
				sec bcs $bfef
			}
		}
$bfcf:
	}
$bfd5:	//same id not found
	for (x = 0;x != #40; x+=2 ) {
$bfd7:	
	//if same item found but its incremented amount >= 100,improperly jumps to here
		if ($60c0.x == 0) { //bne bfe8
$bfdc:
			$60c0.x = $18; x++;
			$60c0.x++;
			sec bcs $bfef
		} 
	}
$bfee:
	clc;
$bfef:
	return a = $18;
$bff1:
}
```
</details>

____________________
# $34:8074 battleLoop 
<details>

### (pseudo-)code:
```js
{
//	least value of S = $18 = $20 - 8(call_doBattle,beginBattle,dungeon_mainLoop,dungeon_mainLoop)
//	u8 $7ac2 : currentActorIndex
//------------------------------------------------------
	$34:81c3();
	a = $7ed8 & #20;
	if (0 != a) $35:a487();
$8081:
	a = $78ba & 1;
	if (0 == a) {
		dispatchBattleFunction(2);	//decideEnemyAction(); //$34:801a();
	}
$808b:
	call_2e_9d53(a = #0e);	//$3f:fa0e();

	$34:81a0();
	getCommandInput();	//$34:986c();
	$7be1 = a = 0;
	beginBattlePhase();	//$34:8374(); [out]$74 = escape count

	call_2e_9d53(a = #0f);	//$3f:fa0e();

	a = $78ba;
	if (a >= 0) $34:8271();
$80ab:
	calcActionOrder();	//$34:9777();
	clearSprites2x2(index:$18 = 0);	//$8adf
	eraseFromLeftBottom0Bx0A();	//$34:8f0b();
	$34:82ce();
$80bb:
	$78cf,78d0,78d1,78d2 = #ff;
$80c9:	do {
		initBattleVars();	//$34:8213();
		drawInfoWindow();	//$34:9ba2();
		canPlayerPartyContinueFighting();	//$35:a458();
		if (0 != (a = $78d3)) goto $811c;
$80d7:
		$34:8295();
		executeAction();	//$34:9de4();
$80dd:		modifyActionMessage();	//$35:a56f();
		$7ed8 &= #df;
		presentBattle();	//$34:8ff7();

		x = ++$7ac2;
		a = $7acb.x;
		if (#ff == a) break;
	} while ($7ac2 != 0x0C);
$80ff:
	a = $78d3 & 2;
	if (0 == a) { 
		processPoison();	//$ba41();
	}
$8109:
	canPlayerPartyContinueFighting();	//$35:a458()
	if (0 == $78d3) {
$8111:
		$78ba &= 8;
		goto $8074;
	}
$811c:
	//...
$8184:
	return;
}
```
</details>
