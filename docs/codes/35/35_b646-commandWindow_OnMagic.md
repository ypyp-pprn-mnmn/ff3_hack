
# $35:b646 commandWindow_OnMagic



### (pseudo-)code:
```js
{
	a = $7ed8 & #40;
	if (a != 0) { //beq b655
		setSoundEffect06();	//set$ca_and_increment_$c9(#6);	//$34:9b81();
		a = 1;
		return getCommandInput_next();	//$34:99fd();
	}
$b655:
	a = #ff;
	for (x = #17;x >= 0;x--) { $7400.x = a; }
$b65f:
	setYtoOffsetOf(a = #3f);	//$34:9b88;
	x = 7;
$b666:	while ((a = $57[y]) == 0) {
		x--; y -= 2;
	}
$b670:
	$46 = $27 = a = x;
	push a;
	a = $18 = (7 - $27);
	a <<= 1;	//2
	$19 = a;	//2
	a <<= 1;	//4
	$18 = $19 + $18 + a	//2+1+4 = 7 (7*(7-$27))
	$24 = 0;
$b98c:
	while ($27 > 0) {
		$25 = 3;
		setYtoOffsetOf(a = #7);	//$34:9b88();
		y = a + $27;
		a = $59[y];
		$1c = x = 7;
$b69e:	
		do {	//bit7が立ってるとバグると思われる
			a >>= 1;
			if (carry) {	//bcc $b6b7;
				push a;
				x = $24;
				$7400.x = $18;
				$18++; $24++;
				pop a
				$25--;
				x = --$1c;
				//if (x != 0) continue;
			} else {
$b6b7:		
				$18++;
				x = --$1c;
			}
			//if (x == 0) break;
		} while (x != 0);
$b6bf:
		$24 += $25;
		a = --$27;
	}
$b6cc:
	initTileArrayStorage();	//$34:9754();
	x = pop a;
	$24 = ++x;
	$25 = y = a << 1;
	$26 = a = 0;
$b6dc:
	for ($24;$24 != 0;$24--) {
		initString(cch:x = #1c);	//$35:a549();
		$27 = 8;
		$7ad7 = $24 + #80;
		$7adb = #c7;
		setYtoOffsetOf(a = #6);	//9b88
		y = a + $24;
		$18 = $5b[y];
		$19 = 0;
		itoa_16(val:$18,19);	// $34:95e1();
		$7ad9,7ada= $1d,1e;
		setYtoOffsetOf(a = #31);//9b88
$b714:
		y = a + $25;
		$18 = $57[y];
		$19 = 0;
		itoa_16(val:$18,19);	//$34:95e1();
		$7adc,7add = $1d,1e;
		$25 -= 2;
		for ($28 = 3;$28 != 0;$28--) {
$b734:
			x = $26;
			$1a = a = $7400.x;
			if (a != #ff) {	//beq $b76f;
$b73f:
				$18 = a;
				push a;
				$20,21 = #98c0;
				$35:b8fd();
				if ((a = $1c) == 0) {	//bne $b75f;
$b751:
					x = $27;
					$7ad7.x = #73;
					x = $26;
					$7400.x = #ff;
$b75f:				}
				$27++;
				$18,19 = #8990;
				pop a;
				x = $27;
				loadString(dest:x, base:$18);	//a609
$b76f:			}
			$27 += 6;
			$26++;
		}	//bne b734
$b77e:
		strToTileArray(cchLine:$18 = #1c);	//$34:966a();
		offsetTilePtr(offset:a = #1c);	//$35:a558();
		//a = --$24;
		//if (a != 0) goto $b6dc; //beq b793
	}

$b793:
	eraseWindow();	//$34:8eb0();
	draw8LineWindow($18 = 1, $19 = #1e, $1a = #3); //$34:8b38
	loadAndInitCursorPos(type:$55 = 1, dest:$1a = 0)	//$34:8966();
	$24 = $25 = $26 = 0;
	x++;
$b7b8 magicWindow_inputLoop:
	$1a = $38 = x = 0;
	$1b = a = 2;
	getInputAndUpdateCursorWithSound();	////$34:899e();
	$29 = 0;
	$1e,1f = #ba2a;
$b7d2:
	a = $12
$b7d4:	do {
		a >>= 1;
		if (carry) break; //bcs b7db
		$29++;
	}
$b7db:
	$1e,1f += ($29<<1)
	$1e,1f = *($1e);
	(*$1e)();	//jumptable
$b7f9:
}
```



