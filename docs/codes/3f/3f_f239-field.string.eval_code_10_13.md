
# $3f:f239 field.string.eval_code_10_13


### code:
```js
{
	$67 = ((a & 3) << 6) & 0xc0; //lsr ror ror
	if (($84 = a) > 0x30) { //bcc f299
		if ($84 == 0xff) { //bne f289
$f24a:
			x = $67;
			if ((a = $6101.x) < 0x62) { //bcs f291
$f253:
				$80 = a; //lv
				$84,85 = #8000 + (a << 1 + $80); //lv*3
				call_switch1stbank(per8:a = 0x39); //ff06
$f268:
				$80,81,82 = $84[y = 0xb0,0xb1,0xb2] - $6103,6104,6105;	//EXP?
				switch_to_character_logics_bank();	$f727
				$3c$8b78();
				//jmp f291
			}
		} else {
$f289:
			push(a); //a = lv
			switch_to_character_logics_bank();	//switchBanksTo3c3d(); //f727
			A = pop();
			$3c$8998();
		}
$f291:	//switch_to_string_bank
		call_switchFirst2banks(per8base:a = $93);
		//tail recursion. identical to just go back to beginning of the loop.
		return field.eval_and_draw_string();	//$eefa();
	}
$f299:
	switch (a) {
	case 0x00:	//bne f301
		//...
$f2d8:	//some other cases are calling this address
		//...
		return $f0c5();	//in the middle of the handler for charcode == 0x18
$f301:
	case 0x01:	//bne f310
		//...
		//1F:F30D:4C D8 F2  JMP $F2D8
		return $f2d8();
$f310:
	case 0x02:	//bne f348
		//...
$f316:	//case 0x0c calls this address
		//...
		return field.eval_and_draw_string();	//$eefa();
$f348:
	default:
		if (a < 0x08) {	//bcs f373
			//...
$f36a:
			//...
			return $f0a1();	//in the middle of the handler for charcode == 0x18
		} else {
$f373:
			//...
$f387:
			return field.eval_and_draw_string();	//$eefa();
		}
	}
}
```



