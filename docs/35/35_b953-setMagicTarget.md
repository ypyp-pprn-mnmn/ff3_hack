
# $35:b953 setMagicTarget

<summary></summary>

## (pseudo-)code:
```js
{
	//sec
	$18 = $7ce8 = a;
	$20,21 = #98c0
	isPlayerAllowedToUseItem();	//b8fd
	a = $747c;	//itemparam[4]
	if (a == 1) { //bne $b970
		$7ce8 = #ff;
	}
$b970:
	if ((a = $1c) != 0) $b979
$b974:
	a = 1;
	return;	//jmp $ba29
}
```



