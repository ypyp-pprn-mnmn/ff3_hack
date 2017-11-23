
# $31:b233 handleHealingMagic	



>specialHandler01: 回復魔法


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



