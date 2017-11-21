
# $34:9de4 executeAction

<summary></summary>

## args:
+ [in] u8 $7ac2 : currentActorIndex(action order)
+ [in] u8 $7acb[0xc?] : ordinalToBattleCharIndexMap
+ [in] u8 $7ca7[4] : 選択魔法Lv (index=player)
+ [in] u8 $7ced : encounter id
+ [in] u8 $7cee : encounter flag (or high bits of encounter id?)
## local variables:
+ u8 $1a : actionId
+ u16 $6e : actorPtr
+ u16 $70 : firstTargetPtr
+ u8 $78d6 : targetIndex+flag
+ u8 $78d8 : targetName (single:=index multiple:#88)
+ u8 $7e98 : actor? $fd24[targetIndex] = bitMask for indicator bits
+ u8 $7e99,7e9b : targetIndicatorFlag
+ u8 $7e9a : sideFlag(actorEnemy:80 targetEnemy:40)
+ u8 $7ec2 : handlerId
## (pseudo-)code:
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



