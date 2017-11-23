
# $31:bdc5 checkForEffectTargetDeath

<summary></summary>

## args:
+ [in] u8 A : sideToCheck (0=player 1=mob)?
## (pseudo-)code:
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



