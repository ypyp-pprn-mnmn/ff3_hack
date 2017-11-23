
# $34:9ba2 drawInfoWindow



### (pseudo-)code:
```js
{
	if ((a = $7ceb) != 0) {
		$7ceb = 0;
		return;
	}
$9bad:	
	initTileArrayStorage();	//$9754;
	$720a = #7977;
	push (a = $52);
	for ($52 = 0;$52 != 4;$52++) {
$9bc1:
		initString(x = #12);	//$a549;
		$7ae3 = #c7;
		updatePlayerOffset();	//$a541;
		y = a + 6;
		for (x = 1;x != 7;x++,y++) {
			$7ad7.x = $57[y];
		}
$9bdf:
		setYtoOffset03();	//$9b8d;
		$18 = $5b[y++];
		$19 = $5b[y++];
		itoa_16();	//$95e1;
		$7adf = $1b;
		$7ae0 = $1c;
		$7ae1 = $1d;
		$7ae2 = $1e;
		$24 = 0;
		cachePlayerStatus();	//$9d1d();
		if ((a = $7ce8) == #ff) $9c7f;
$9c10:
		x = $52;
		if ((a = $78cf.x) != #ff) { //beq 9c4d
		//コマンド選択ずみ
			if (a >= #c8) { //bcc 9c39
				loadString(index:a = $1a = a - #c8,dest:x = #c,base:$18 = #8990);
				$7ae3 = #c7;
				goto $9cba;
			} else {
$9c39:
				loadString(index:a = $1a = a, dest:x = #0d, base:$18 = $8c40);
				goto $9cba;
			}
		} else {
$9c4d:	
			if (( $1a | $1b) != 0) { //beq 9c7f
				if ( ($1b & #20) != 0) { //beq 9c63
					a = ($1b &= #df);
					a |= $1a
					if (a == 0) $9c7f //beq
				}
$9c63:
				for(;;) {
					$1b <<= 1;
					rol $1a;
					if (carry) break; //bcs 9c6d
				
					$24++;
				}
$9c6d:
				loadString(index:a = $24, dest:x = #0d, base:$18 = #822c);
				goto $9cba
			} else {
$9c7f:
				if ($7ce8 != #ff) { //beq 9c95
					maskTargetBit(a = $7be1, target:x = $52);	//fd38
					if (!equal) { //beq 9c95
						if ($78cf.x != 0) goto $9c1d;
					}
				}
$9c95:
				setYtoOffsetOf(a = 5);	//$9b88
				$18 = $5b[y];
				$19 = $5b[++y];
				itoa_16();	//$95e1();
				$7ae4 = $1b;
				$7ae5 = $1c;
				$7ae6 = $1d;
				$7ae7 = $1e;
			}
		}
$9cba:
		strToTileArray(len:$18 = #12);	//966a
		offsetTilePtr(len:a = #12);	//a558
	}	//beq 9cd1 	//jmp $9bc1
$9cd1:
	$52 = pop a;
	return draw8LineWindow(left:$18 = #0b, right:$19 = #1e, border:$1a = #03);	//8b38
$9ce3
}
```



