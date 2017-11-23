
# $31:af77 doSpecialAction



>battleFunction00


### notes:
//dispId : 0

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



