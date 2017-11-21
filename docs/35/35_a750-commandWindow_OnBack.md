
# $35:a750 commandWindow_OnBack

<summary>03: こうたい</summary>

## (pseudo-)code:
```js
{
	setYtoOffsetOf(a = #0f);
	if (($59[y] & 1) != 0) {
		requestSoundEffect06();	//$9b81
		return movePosition_end();	//a7c8
	}
	initMoveArrowSprite();	//a7cd
	push a;
	$0222 = #03;
	x = pop a + 2;
	$0220 = $a823.x;
	x++;
	$0223 = $a823.x;
	$18 = #40;	//left
	$19 = #03;	//back
	//fall through
$a784:
}
```



