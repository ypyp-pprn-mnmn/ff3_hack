
# $35:acd5 command_sing

<summary>10: うたう</summary>

## (pseudo-)code:
```js
{
	$52 = getActor2c() & 7;	//$a42e()
	y = updatePlayerOffset() + 3;	//a541
	//竪琴チェック
	a = $59[y];
	if ( !(#46 <= a && a < #4a) ) {
		y += 2; a = $59[y];
		if ( !(#46 <= a && a < #4a) ) {
$acfc:
			$78d5 = 1;
			$78da = #42;
			$7ec2 = #18;
			return;
$ad0c:
		}
	} else {
$acfc:
		return command_fight();	//jmp $a104
	}
	
}
```



