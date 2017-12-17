
# $31:b17c battle.specials.handle_00
> specialHandler00: HPダメージ魔法

### args:
+	u8 $30: hit count
+	u8 $38: attack count
+	BattleCharacter* $6e: ptr to actor
+	BattleCharacter* $70: ptr to target
+	u8 $7c: hit count (with attr boost bonus)

### callers:
+	$31:b15f battle.specials.invoke_handler

### notes:
former name : "handleDamageMagic"

### (pseudo-)code:
```js
{
	//0x26: リフレクフラグ
	if ($70[y = 0x26] != 0) { //beq b185
		battle.specials.pickup_victim_of_reflection();	//$b9fa
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
			if ($70[y = 1] < $7403) $b1b4; //bcc
		}
$b1ae:
		clearEffectTarget();	//$b926();
	}
$b1b1:
	return $b21c();
$b1b4:
	$26 = $70[y = 0x15];
	y = 0x10;
	if (($7405 & 0x10) != 0) y++; //beq b1c4
$b1c4:
	//(int or men)/2 + param[2]
	$25,2b = ($6e[y] >> 1) + $7402
	if ( (( $e0.(x = $64) & 0x28) != 0)  // bne b1e1 toad|minimum
		|| ($70[y = 0x27] != 0) //beq b1e9
	}
$b1db:
		$25,2b <<= 1;
		$26 = 0;
	}
$b1e9:
	if (($7405 & 0x40) == 0) { //beq b1f4
		$2a = 1；
	}
$b1f4:
	$28,29 = 0;
	$24 = $7c;
	calcDamage({
		hitcount: $7c,
		atk: $25,2b,
		def: $26,
		attr: $27,
		bonus: $28,
		bonusMul: $29,
		divide: $2a
	}); // $bb44();
$b201:
	if ( ($1c | $1d) == 0) {
		$1c++; //bne b209
	}
$b209:
	$78,79 = $1c,1d
	battle.get_target_ptr(); //$bdbc(); effectively [$24,$25] = [$70,$71]
	damageHp();	//$bcd2()
	if (carry) { //bcc b21c
		battle.specials.try_to_apply_enchanted_status();	//$be43
	}
$b21c:
	if ( ($7574 != 0)  //beq b232
		&& ( ($70[y = 3] | $70[++y]) == 0) ) //bne b232
	{ 
$b22a:
		$70[y = 1] |= 0x80;	//dead
	}
$b232:
	return;
}
```





