
# $35:b2a7 itemWindow_scrollRight

<summary></summary>

## args:
+ [in,out] u8 $65 : background no
+ [in,out] u8 $66 : left(colIndex,0-7)
+ [in] u8 $69 : col index of 1st selection (if avail)
+ [in] u8 $67 : mode
## (pseudo-)code:
```js
{
	if ((a = $66) < 6) { //bcs  $b2ea
		$3d = (a + 2) << 3;//fd3f
		loadTileArrayForItemWindowColumn(firstItem:$3d );	//$35:b48b
		x = a = ($66 + 2) << 1
		$18,19 = $b636.(x++),$b636.x
		if ((a = $66) < 5) { //bcs $b2d4
			a = 0 //bne $b2e5
		} else {
$b2d4:
			push (a = $18); push (a = $19);
			eraseFromLeftBottom0Bx0A();	//$34:8f0b
			$19 = pop a;$18 = pop a
			a = 2;	//draw right-border
		}
$b2e5:
		$1a = a;
		draw8LineWindow(left:$18, right:$19, behavior:$1a); //$34:8b38();
	}
$b2ea:	
	if ((a = $66) != 7) { //beq $b31b
		$66++;
		$64 = $10 + #78;
		$65 ^= 1;
		do {
$b301:
			updatePpuDmaScrollSyncNmi();	//$3f:f8c5
			$10 += #14
			if (carry) { //bcc $b315
$b30d:
				$08 = $65 | $08 & #fe;				
			}
$b315:		} while ($10 != $64);	//bne $b301
	}
$b31b:	if ((a = $67) != 0) { //beq $b350
		if ((a = $66) == $69) $b32c
		a += 1;
		if (a != $69) $b350
$b32c:
		a = #a8;
		//if ((x = $68) == 0) $b338
		for (x = $68;x != 0;x--) {
$b333:			a += #10;	//inloop,no clc
		}
$b338:
		$1c =a;
		x = #0c;
		if ((a = $69) != $66) x = #84;	//beq $b344
$b344:
		tileSprites2x2(index:$1a = 1, top:$1c, right:$1d = x);	//$34:892e()
		clc bcc $b361
	} else {	
$b350:		//[$67 == 0] hide(move off) 2nd cursor
		push (a = $1c);
		tileSprites2x2(index:$1a = 1, top:$1c = #f0, right:$1d);	//$34:892e()
		$1c = pop a
	}
$b361:
	return;
$b362:
}
```



