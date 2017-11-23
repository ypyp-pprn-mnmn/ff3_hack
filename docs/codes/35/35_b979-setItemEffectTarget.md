
# $35:b979 setItemEffectTarget



### args:
+ [in] u8 $7478[8] : itemparam

### local variables:
+	u8 $b3 : selectTargetFlag (01:allowMulti 02:defaultPlayerSide)

### (pseudo-)code:
```js
{
	if (0 == (a = ($747d & #18)) ) { //bne b983
$b980:		goto $ba27;
	}
$b983:
	if ((a = ($747d & #40) != 0) $b9f0	//bne
$b98a:
	$b3 = 0;
	if ((a = ($747d & #20) != 0) $b999	//bne
$b995:
	$b3 = 1;
$b999:	if ((a = $747d) >= 0) $b9a4
$b99e:
	$b3 |= 2;
$b9a4:	if ((a = $7ce8) != #ff) $b9cf
$b9ab:	
	init4SpritesAt$0220(index:$18 = 0);	//$34:8adf();
	eraseWindow();	//$34:8eb0();
$b9b9:
	$10 = 0;
	$08 &= #fe;
	updatePpuDmaScrollSyncNmi();	//$3f:f8c5
	drawInfoWindow();	//$34:9ba2
	getPlayerOffset();	//35:a541
$b9cf:	$7ce8 = 0;
$b9d4:
	call_2e_9d53(a = #10);	//$3f:fa0e #10 : select target

	if ((a = $b4) == 0) {	//cancel (all target bits are off = nothing selected)
		a = 2;
		return;	//bne $ba29
$b9e1:	} else {
		$5b[y++] = $b4;	//target indicator bits
		$5b[y] = $b5;	//flag
		return (a = 0);	//jmp $ba27
	}
	//-------------------------------------------
$b9f0:	//#40 : 強制全体化?
	$18,19 = #7675;
$b9f8
	push (a = 0);
	for (x = 0;x != 8;x++) {
$b9fd:
		a = $18[y = 1] & #c0;	//dead|stone
		if (a == 0) { //bne $ba0a
			pop a
			flagTargetBit();	//$3f:fd20
			push a
		}
$ba0a:		$18,19 += #0040;
	}
$ba1c:
	setYtoOffset2F();	//$9b94
	$5b[y++] = pop a;	//all selected target bits are flagged(1)
	$5b[y++] = #c0;		//enemy|all
$ba27:
	a = 0;
$ba29:
	return;
}
```



