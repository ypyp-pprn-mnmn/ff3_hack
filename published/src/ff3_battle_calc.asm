; ff3_battle_calc.asm
;
;description:
;	replaces calculation for command 'fight'
;
;version:
;	0.01 (2006-10-10)
;======================================================================================================
ff3_battle_calc_begin:
	;.include "ff3_30-31.h"
;	INIT_PATCH $30,$9e8a,$a2b5
	.bank	$30
	.org	$9e8a
processFight:
;arguments:
;	[in]
.pActor = $6e
.pTarget = $70
.escapeCount = $74
.defendFlags = $7ce4
;	[in,out]
.messageCount = $78ee
.message = $78da
;	[out]
.hitCount_1st = $7c
.hitCount_2nd = $7d
.protectFlag = $7edf
;locals:
.isTargetAtBackline = $7ce9
.targetHp = $3c
.actorHp = $40
.actor2c = $45	;extra
.target2c = $46	;extra
.handCount = $741f
;	shared with cacheStatus()
.actorIndexForCache = $62
.targetIndexForCache = $64
.actorIndex = $66
.targetIndex = $68
.actorStatusCache = $f0
.targetStatusCache = $e0
;	shared with sumDamage()
.damageForDisplay = $6a
.damage = $78
;	shared with checkSegmentation()
.hitCount_1st_2 = $bb
.hitCount_2nd_2 = $bc
;------------------------------------------------------------------------------------------------------
	lda <.actor2c
	pha
	lda <.target2c
	pha
	ldy #$2c
	lda [.pActor],y
	and #$87
	sta <.actor2c
	lda [.pTarget],y
	and #$87
	sta <.target2c
	
	jsr $a2ba
	ldx .targetIndexForCache
	bit .targetStatusCache,x
	bvs .dead_stone_jump
	bmi .dead_stone_jump
		inx
		lda #1
		bit .targetStatusCache,x
		bne .init
.dead_stone_jump:
	ldy #$30
	lda [.pActor],y
	bmi .target_is_enemy
		INIT16 <$22,$7575
		lda #3
		jsr $a300
		lda <$69
		beq .cache_and_init
			ldx #0
			stx $7ec2
			dex
			stx $7ed8
			jmp .set_messages
.target_is_enemy:
		INIT16 <$22,$7675
		lda #7
		jsr $a300
.cache_and_init:
	jsr $a2ba	;cacheStatus
.init:
	ldx #$ff
	stx $7ee1
	inx
	stx $741e
	stx $7ce9
	stx <.hitCount_1st
	stx <.hitCount_2nd
	stx <.damageForDisplay
	stx <.damageForDisplay+1
	stx <$42
	inx
	stx .handCount
	
	ldy #3
	lda [.pActor],y
	sta <.actorHp
	lda [.pTarget],y
	sta <.targetHp
	iny
	lda [.pActor],y
	sta <.actorHp+1
	lda [.pTarget],y
	sta <.targetHp+1

	bit <.actor2c
	bpl .actor_is_player_char
		;enemy
		lda <.escapeCount
		beq .cache_params
			bit <.target2c
			bmi .cache_params
			
;	//if ( getActor2C() < 0
;	//	|| (($74 != 0) && (getTarget2C() >= 0) && 
;	if (getActor2C() < 0) {	//msb==1
;		//“G
;		if (0 != (a = $74) ) {	//$74 = escape count
;			if (getTarget2C() >= 0) {//$31:bc25()
;$9f10:
;				$70[y = #27] += 1;
;				if (a != 0) $9f40; // //bne $9f40
;			}
;		}
;	} else {
;$9f1b:
;		a = $6e[y = #31];
;		if (a < 0) $9f37;	//bmi
;$9f21:		if ((a & 1) == 0) $9f37; //beq
;$9f25:
;		a = $6e[++y];
;		if (a < 0) $9f37;
;		if ((a & 1) != 0) {	//beq $9f37;
;$9f2e:
;			$741f++;
;			$741e++;
;			goto $9f40:
;		}
;$9f37:
;		a = $6e[y = #31] | $6e[++y];
;		if (a == 0) $9f2e;
;	}
;$9f40:
;	y = #16;
;	for (x = 0;x != 0xa;x++) {
;		$7440.x = $7420.x = $6e[y++]; //atk (left/right)
;	}
;	for (x;x != 0xf;x++) {	//x:a-f
;		$7420.x = $6e[y++];	//def
;	}
;	y = #27;
;	for (x;x != 0x12;x++) {	//x:f-12
;		$7420.x = $6e[y++];	//$742f~7431 = 27,28,29
;	}
;$9f6a:	//for($741f-;$741f!=0;$741f--){ //$a15a
;	$24,25 = $7441,7442;
;	x = $62;	//attackerIndex*2
;	a = $f0.x & 4;	//4=status.blind
;	if (a != 0) {
;		$25 >>= 1;
;	}
;$9f7e:
;	if (0 == (a = $6e[y = #33]) & 4) {
;		a = $6e[y = #2c];
;		if (a >= 0) {
;			//–¡•û
;			$31:a397();
;			if (carry) goto $9fa6;
;		}
;$9f91:
;		a = $6e[y = #33] & 1;	//Œã—ñ”»’è?
;		if (0 != a) {
;			$25 >>= 1;
;		}
;$9f9b:
;		a = $70[y] & 1;		//Œã—ñ”»’è?
;		if (0 != a) {
;			$7ce9++;
;			$25 >>= 1;
;		}
;	}
;$9fa6:
;	$7c = getRandomSucceededCount(try:$24, rate:$25);	//$31:bb28(); $24=‰ñ”,$25¬Œ÷—¦
;//
;	$24,25 = $742b,742c;	//def,evade
;	x = $64;		//attackerIndex*2
;	a = $e0.x & 4;		//target.status0.blind
;	if (a != 0) { //beq 9fbf
;		$25 >>= 1;
;	}
;$9fbf:
;	//if (($e0.x & #28) == 0) {//bne 9fcb
;	//	if ($70[y = #27] == 0) beq 9fcf
;	//}
;	if (($e0.x & #28) != 0 || $70[y = #27] != 0) {
;$9fcb:
;		$24 = 0;	//Š^‚©¬l‚©‘ÎÛ‚ª—­‚ß‚Ä‚¢‚é
;	}
;$9fcf:
;	getRandomSucceededCount(try:$24, rate:$25 );	//$bb28();
;	if ((a = $7ce9) != 0) { //beq $9fd9;
;		$30++;	//–hŒä‘¤‚ªŒã—ñ‚È‚ç–hŒä¬Œ÷‰ñ”1‰ñ•ÛØ
;	}
;$9fd9:
;	$7c = $24 = a = atkCount - defCount > 0 ? atkCount - defCount : 0;//$7c=atkcount $30=defcount
;	if (a == 0) {	//miss!
;		$6e[y = #27] = 0;
;		goto $31:a139;
;	}
;$9ff1:	//hit!
;	a = $70[y = #12] & $7440;	//$70[12]:–hŒä‘¤Žã“_‘®« $7440:UŒ‚‘®«
;	if (0 != a) {
;		a = 4;
;	} else {
;$9ffe:
;		a = $742a;	//$742a:‘Ï«‘®«
;		if (a != 2) {
;			a &= $7440;
;			if (a == 0) {
;$a00e:
;				a = 2;
;				goto $a010;
;			}
;		}
;$a00a:
;		a = 1;
;	}
;$a010:
;	$27 = a;	//‘Ï:1 •:2 Žã:4
;	$2b = x = 0;
;	$2a = ++x;	//=1
;	$28 = $7431;	//=$6e[#29]
;	$29 = a = 0;
;	$25 = $7443;	//atk
;$a027:
;	if (getActor2C() >= 0) { //$a2b5
;		addToAttackOffsetOf(y = #38);	//y = #38; $a389();
;		addToAttackOffsetOf(++y);	//y++; $a389();
;	}
;$a035:
;	$26 = $742d;	//def
;	if (getTarget2C() >= 0) {	//$bc25
;$a03f:
;		x = a & 7;
;		//–hŒä’†‚È‚ç$26(–hŒä)2”{(128ˆÈã‚È‚ç255)
;		if ($7ce4.x != 0) { //beq a055
;$a047:
;			if ($26 >= #80) { //bcc $a053
;$a04d:
;				$26 = #ff;
;			} else {
;$a053:
;				$26 <<= 1;
;			}
;		}
;	}
;$a055:
;	a = $f0.(x = $62) & #28; //actor.status0 & toad|minimum
;	if (a != 0) { //beq a061
;		$25 = 1;
;	}
;$a061:
;	a = $e0.(x = $64) & #28; //target.status0 & toad|minimum
;	if (a != 0 || $70[y = #27] != 0) {
;$a06f:
;		$25,2b <<= 1;
;		$26 = 0;
;	}
;$a077:
;	getRandom(#63);//$beb4()
;	if (a < $7430) { //$7430 = $6e[#28]
;		$29++; $cb++;
;	}
;$a085:
;	x = $62;
;	a = $f0.x & 0x28;
;	if (0 != a) {
;		$cb = $29 = 0;
;	}
;$a093:
;	calcDamage();	//$31:bb44(); result:$1c,1d
;	if ($29 != 0) {
;		x = $78ee;
;		$78da.x = #34;	//critical hit!
;		$78ee++;
;	}
;$a0a5:
;	a = $6e[y = #27];
;	if (0 != a) {
;		x = a;x++;
;		$18 = x;
;		$19 = $6e[y] = a = 0;
;		$1a,1b = $1c,1d;
;		mul16x16();	//$3f:fcf5
;	}
;$a0c0:
;	if ($1c,1d == 0) { $1c++; }
;$a0c8:
;	$78,79 = $1c,1d;
;	$24,25 = $70,71;
;	y = #12; a = $7440 & 1;
;	if (a != 0) { //‹zŽû‘®«‚ ‚è
;		isTargetWeakAtHoly();	//$bbe2();
;		if (!carry) { 
;			sumDamageForDisplay(damage:$78);	//$a368();
;		}
;		getTarget2C();	//$bc25();
;		$18 = a & 0x87;
;		getActor2C();	//$a2b5();
;		a &= 0x87;
;$a0f7:
;		if (a != $18) {	//target!=actor
;$a0f9:
;			$bd67();
;			goto $a10d;
;$a10d:
;			a = $26;
;			if (a == 0) goto $a129;
;			else if (a < 0) goto $a11e;
;			goto $a113;
;		}
;	} else {
;$a0ff:
;		$26 = 0;
;		sumDamageForDisplay();//$a368();
;	}
;$a106:
;	applyDamage();	//$bcd2();
;	if (!carry) {
;$a113:		//dead
;		$e0.(x = $64) |= #80;
;		goto $a139;
;$a11e:
;		$f0.(x = $62) |= #80;
;		goto $a139;
;	} else {
;$a129:		//alive
;		a = $7ed8;
;		if (a >= 0) {
;			a = $6e[y = 1] & 0x28;
;			if (0 == a) {
;				checkStatusEffect();//$31:be14();
;			}
;		}
;	}
;$a139:	//hit”0(=ƒ~ƒX)‚È‚ç‚±‚±‚Ü‚Å”ò‚ñ‚Å‚­‚é
;	a = --$741f;
;	if (0 != a) {
;		for (x = 0;x != 5;x++) {
;			$7440.x = $7425.x;
;		}
;		$7d = $7c; 
;		$79 = $78 = $7c = 0;
;		goto $9f6a;
;	}
;$a15d:
;	a = $741e;
;	if (0 != a) {
;		push (a = $7c);
;		$7c = a = $7d;
;		$7d = pop a;
;	}
;$a16c:
;	y = $64;
;	$bb = a = $7c;	//hit count (1st hand)
;	a |= $7d;
;	if (a == 0) { //bne a184
;		$7e4f.y = $bc = a;
;		y++;
;		$7e4f.y = #40;
;		//goto $a264;
;	} else {
;$a184:
;		$bc = $7d;	//hit count (2nd)
;		$78,79 = $6e[y = #3],$6e[++y];	//actor.hp
;		x = $62;
;		getActor2C();	//$a2b5();
;		$18 = a & #87;
;		if (($70[y] & #87) == $18) beq $a203;
;$a1a4:
;		if ($40,41 >= $78,79) { //bcc $a1da;	//actorHpBeforeAttack >= actor.hp
;$a1af:
;			$7e5f.x = ($40,41 - $78,79);
;			a = ($6e[y = #16] | $6e[y = #1b]) & 1;	//¶Žè‚Æ‰EŽè‚ÌUŒ‚‘®«
;			if (a == 0) beq $a1d7;
;$a1cf:
;			$78da.(x = $78ee) = #27;	//"HP‚ð‚¬‚á‚­‚É‚·‚¢‚Æ‚ç‚ê‚½!"
;$a1d7:
;			//goto $a203;
;		} else {
;$a1da:			//UŒ‚ŽÒ‚ÌHP‚ªUŒ‚‘O‚æ‚è‘‚¦‚Ä‚¢‚é
;			$7e5f.x = ($78,79 - $40,41) | #8000;
;$a1ec:
;			getActor2C();	//$a2b5();
;			if (a >= 0) { //bmi $a1fb
;				$78da.(x = $78ee) = #25; //"HP‚ð‚«‚ã‚¤‚µ‚ã‚¤‚µ‚½!"
;			} else {
;$a1fb:
;				$78da.(x = $78ee) = #26; //"HP‚ð‚·‚¢‚Æ‚ç‚ê‚½!"
;			}
;$a203:		}
;		$43 = 0;
;		a = $78da.(x = $78ee);
;		if (a != #ff) {
;			$43++; $78ee++;
;		}
;$a216:
;		x = $62;
;		a = ($7e5f.(++x) & #7f) | $7e5f.(--x);
;		if (a == 0) { //bne $a23c
;$a224:
;			$7e5f.x = #ffff;
;			if ($43 != 0) {
;				x = --$78ee;
;				$78da.x = #ff;
;			}
;		}
;$a23c:
;		x = $64;
;		if ($42 != 0) { //beq $a259
;			$7e4f.x = ($70[y = 3,4] - $3c,3d) | #8000;	//$3c: targetHpBeforeAttack
;			//bne a264 (always satisfied)
;		} else {
;$a259:
;			$7e4f.x = $6a,6b
;		}
;	} //$7c | $7d == 0 (whether miss or not)
;$a264:
;	//$74:count of char who try to escape
;	if ($74 != 0) { //beq a288
;		if (getActor2C() < 0) {	//bpl a288
;			$70[y = #27] -= 1;
;			if ($7c != 0) { //beq a288
;				$78da.(x = $78ee) = #55; //"‚É‚°‚²‚µ‚Å ‚Ú‚¤‚¬‚å‚Å‚«‚È‚©‚Á‚½!"
;				$78ee++;
;			}
;		}
;	}
;$a288:	
;	if (getActor2C() < 0) return getActor2C();//bmi a2b5
;$a28d:
;	checkSegmentation();	//$bf53();
;	//if ((a = $6e[y = #31]) >= 0) {	//bmi a29a
;	//	if ((a & 1) == 0) { //bne a2a6
;	if ((a = $6e[y = #31] < 0)
;		|| (a & 1) != 0)
;	{
;$a29a:
;		if ($7d == 0) {
;$a29e:
;			$bc = $7c;
;			$bb = 0;
;		}
;	}
;$a2a6:
;	a = $6e[y = #33] & 4;
;	if (a != 0) {
;		$bb = $7c + $7d;
;	}
;$a2b5:
;	return getActor2C(); //fall through
;}
