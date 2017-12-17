

# $31:b233 battle.specials.handle_01
> HP回復魔法 (specialHandler01: "handleHealingMagic")

### args:
+	u8 $30: hit count
+	u8 $38: attack count
+	BattleCharacter* $6e: ptr to actor
+	BattleCharacter* $70: ptr to target
+	u8 $7c: hit count (with attr boost bonus)

### callers:
+	$31:b15f battle.specials.invoke_handler

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

