
# $35:b82a magicWindow_OnDown

<summary></summary>

## (pseudo-)code:
```js
{
	if ((a = $24) == 7) return;	//beq $b874
	if (a == $46) return;	//beq $b874
	$24++;
	$25++;
	if ((a = $25) < 4) return; $b874
	$25--;
	$7ac0 += #0038;
	draw8LineWindow();
	return;	//jmp
}
```



