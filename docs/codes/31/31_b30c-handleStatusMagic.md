
# $31:b30c handleStatusMagic



>specialHandler04: バステ魔法


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



