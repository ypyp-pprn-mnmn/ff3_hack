
# $2f:a0e7 load_enemy_graphics_params

### args:
+	[in]  a : enemyId
+	[in] u8 $2e:8b00(5cb00) : enemy_to_graphics_id ([aaabbbbb])
+	[in] u8 $2e:8f00(5cf00) : some flag for enemy (1-bit per record, lower id stored in higher bit)
+	[out] u8 $7e : graphics_id (= $2e:8b00[ enemy_id ])
+	[out] u8 $7f : ($2e:8b00[ enemy_id ] & 0x1f) + offset
	-	where offset:
		-	$7e&#e0 == #20 then #10
		-	$7e&#e0 == #60 then #18
		-	otherwise #00
+	[out] u8 $80 : msb contains bit of $2e:8f00[ enemy_id >> 3 ] >> (enemy_id & 7)

### code:
```js
{
	$7e = a;
	push (a = x);
	push (a = y);
	if ((a = $7e) == #ff) { //bne a0fc
		//empty
		$7f = $7e = #ff;
		//jmp a145
	} else {
$a0fc:
		x = $81 = a;
		$7e = $8b00.x;
		$80 = a & #1f;
		if (($7e & #e0) == #20) { //bne a115
$a110:
            // 4x6 size
			a = #10;
			//jmp a120
$a115:		} else if (a == #60) { //bne a11e
$a119:
            // 6x6 size
			a = #18;
			//jmp a120
		} else {
$a11e:
			a = 0;
		}
$a120:
		$7f = a + $80;	//enemyId & 1f + a
		$80 = $81 & 7;	//enemyId & 7
		y = $81 >> 3;	//enemyId >> 3
		x = $80;	//enemyId & 7
		$80 = 0;
		x++;
		a = $8f00.y;
		for (x;x != 0;x--) {
$a13b:
			a <<= 1;
			ror $80;
		}
$a141:
		a &= #80; a |= $7f; //? 意味が無い
	}
$a145:
	y = pop a;
	x = pop a;
	return;
}
```


