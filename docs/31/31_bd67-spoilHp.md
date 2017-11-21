
# $31:bd67 spoilHp

<summary></summary>

## args:
### in:
+	u16 $78,79 : damage
### out:
+	u8 $26 : dead flag (00:both alive 01:target dead 81:actor dead)
+	u8 $42 : undead flag
## (pseudo-)code:
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



