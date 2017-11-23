
# $35:b362 itemWindow_scrollLeft



### args:
+ [in,out] u8 $10 : windowX
+ [in,out] u8 $65 : background no
+ [in,out] u8 $66 : left(colIndex,0-7)
+ [in] u8 $69 : col index of 1st selection (if avail)
+ [in] u8 $67 : mode

### (pseudo-)code:
```js
{
	if ((a = $66) >= 2) { //bcc $b3a3
		if (a == 2) {	//bne b375
$b36a:
			createEquipWindow(erase:$7573 = 0);	//$34:b419
		} else {
$b375:	//draw 3-columns-left column
			$3d = (a - 3) << 3;	//fd3f
			loadTileArrayForItemWindowColumn(firstIndex:$3d);	//$34:b48b
			x = a = ($66 - 3) << 1;
			$18,19 = $b636.x

			a = ($66 == 3) ? 1 : 0
$b39e:			$1a = a;
			draw8LineWindow(left:$18, right:$19, behavior:$1a); //$34:8b38()
		}
	}
$b3a3:	//scroll left
	if ((a = $66) != 0) { //beq b3d2
		$66--;
		$64 = $10 - #78;	//$10 : scroll.x applied on irq
		if (!carry) { //bcs b3b8
			$65 ^= 1;
		}
$b3b8:		do {
			updatePpuDmaScrollSyncNmi();	//$3f:f8c5
			$10 -= #14;
			if (!carry) { //bcs b3cc
				$08 = $08 & #fe | $65	//$08 : ppu.ctrl1 applied on irq
			}
		} while ((a = $10) != $64); //bne b3b8
	}
$b3d2:
	//update cursor to reflect scroll
	if ((a = $67) != 0) { //beq $b407
		if ((a = $66) == $69) $b3e3
		a += 1;
		if ((a != $69) $b407
$b3e3:		a = #a8;
		for (x = $68;x != 0;x--) {
$b3ea:			a += #10;
		}
$b3ef:
		$1c = a;
		x = #0c;
		if ((a = $69) != $66) // beq $b3fb
			x = #84
$b3fb:		$1d = x;
		tileSprites2x2(index:$1a = 1, top:$1c, right:$1d = x);	//$34:892e()
		clc bcc $b418
$b407:	} else {
		push (a = $1c)
		tileSprites2x2(index:$1a = 1, top:$1c = #f0, right:$1d);	//$34:892e
		$1c = pop a
	}
$b418:
	return;
$b419:
}
```



