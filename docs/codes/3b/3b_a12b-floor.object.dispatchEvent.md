
# $3b:a12b floor::object::dispatchEvent


### args:
+	[in] u8 $70 : eventId

### (pseudo)code:
```js
{
	a = $70;
	if (a < #c0) return floor::object::processEventUnderC0(); //$acd1();
$a134:	if (a >= #d0) return floor::object::invokeEventAboveD0(); //$b53f();
$a13b:	a = $70 & #0f;
	if (a < 4) {
		$20 = $a1ca.(x = a);
		return;
	}
$a14a:
	if (a < 8) {
		$33 = $a1ca.(x = a & 3);
		return;
	}
$a157:
	switch (a) {
	case 8: $7e &= #7f; return;
$a162:	case 9: $7e |= #80; return;
$a16d:	case #0a: $42 = $46 = 6; return; //ノーチラス
$a178:	case #0b: $42 = $46 = 7; return; //invincible
$a183:	case #0c: $7e &= #bf; return;
$a18e:	case #0d: $7e |= #40; return;
$a199:	case #0e:
		$42 = $46 = 0; //get off (walk) ?
		$6007 = $78; //world
		$6005 = $27 + #07;
		$6006 = $28 + #07;
		$6004 = 1;
		return;
$a1be:	case #0f: $42 = $46 = 1; return;	//ride on chocobo?
	}
$a1c9:
	return;
}
```



