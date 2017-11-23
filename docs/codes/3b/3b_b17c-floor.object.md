
# $3b:b17c floor::object:


### (pseudo)code:
```js
{
	if ($700d.x != 0) //bne b188
	 	||  (($7102.x & $f0) == 0) //bne b1cd
	{
$b188:
		if ((a = $7008.x) != 0) { //beq b1ac
$b18d:
			a = $7006.x = (a + $7006.x) & #0f;
			if (a == 0) { //bne b1cd
$b198:
				$7008.x = $700c.x = $700d.x = 0;
				$7004.x = $7002.x;
			}
		} 
$b1ac:		else if ((a = $7009.x) != 0) { //beq b1cd
			$7007.x = (a + $7007.x) & #0f;
			if (a == 0) { //bne b1cd
				$7009.x = $700c.x = $700d.x = 0;
				$7005.x = $7003.x;
			}
		}
	}
$b1cd:
	a = $7006.x | $7007.x;
	if (a == #08) { //bne b1ee
$b1d7:
		if (($7100.x & #04) != 0)  //beq b1e8
			&& ($7106 & #01) != 0)) //lsr bcc b1e8
		{
$b1e4:
			a = 0;
			//beq b1eb
		} else {
$b1e8:
			a = $7100.x;
		}
		$7101.x = a;
	}
$b1ee:
	$80 = ($7007.x - $36) & #0f;
	a = ($7005.x - $2a) & #3f;
	if (a < #10) { //bcs b230
$b203:
		a = (a << 4) | $80;
		if (a < #e8) { //bcs b230
			$41 = a - 2;
			$80 = ($7006.x - $35) & #0f;
			a = ($7004.x - $29) & #3f;
			if (a < #10) { //bcs b230
$b224:
				a = (a << 4) | $80;
				if (a < #f8) $b232(); //bcc b232
			}
		}
	}
$b230:
	sec; return;
$b232:
	$40 = a;
	$8f = x;
	if ($700d.x >= 0) { //bpl b23e jmp b2c6
$b23e:
		a = $7001.x & #f0;
		if (a == 0) { //beq b275
			a = (($7006.x | $7007.x) << 1) & #08;
		} else if (a < #80 && a >= #40) { //asl bcc b251 asl bcs b262
$b262:
			$00 = a = $f0;
			a &= #08; //jmp b27e
		} else if (a < #c0) { //asl bcc b254
			a = 0;	//beq b27e
		} else if (a < #f0) { //asl asl bcc b258
			$00 = a = ($f0 >> 1);
			a &= #08; //beq b27e
		} else { //bcs b26b
			$00 = a = ($f0 << 1);
			a &= #08; //jmp b27e
		}
$b27e:
		push a;
		$80,81 = a + ($700e.x,$700f.x);
		$82 = x + #20;
		if (($7001.x & #40) != 0 //beq b2ad
			&& ($7001.x & #10) != 0 //beq b2ad
			&& ($00 & #10) != 0) //beq b2ad
		{
$b2a6:
			$82 -= #08;
		}
$b2ad:
		pop a;
		if ( (a != 0)  //beq b2c3
			&& ($7001.x & #f0) == 0) //bne b2c3
		{
			if ($7007.x != 0) { //beq b2c1
				$40--;
			} else {
$b2c1:
				$41--;
			}
		}
$b2c3:
		return $aead();
	}
$b2c6:
	//....
}
```



