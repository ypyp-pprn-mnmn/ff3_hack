
# $35:a71c commandWindow_OnForwardSelected



>02: ぜんしん


### (pseudo-)code:
```js
{
	setYtoOffsetOf(a = #f);	//9b88
	if (($59[y] & 1) == 0) { //bne a72d
$a727:
		//すでに前列だった
		playSoundEffect06;	//$9b81();
		return movePosition_end();	//$a7c8();
	}
$a72d:
	initMoveArrowSprite();	//$a7cd();
	push a;
	$0222 = #43;	// reverse x | palette3
	x = pop a;
	$0220 = $a823.x; x++;
	$0223 = $a823.x;
	$18 = #80;	//right key
	$19 = #02;	//move forward
	return showArrowAndDecideCommand();	//jmp
$a750:	
}
```



