
# $35:b7f9 magicWindow_OnUp

<summary></summary>

## (pseudo-)code:
```js
{
	if ((a = $24) == 0) return;	//beq $b874
	$24--;
	if ((a = --$25) > 0) return;	//bpl $b874
	$25++;
	$7ac0,7ac1 -= #0038;
	draw8LineWindow(left:$18 = 1, right:$19 = #1e, borderFlags:$1a = 3);	//$8b38
	return;	//jmp $b874
}
```



