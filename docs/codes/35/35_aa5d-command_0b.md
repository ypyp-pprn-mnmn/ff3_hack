
# $35:aa5d command_0b



>0b: ちけい


### (pseudo-)code:
```js
{
	$6e[y] = getActor2c() | #10;	//a42e
	getCurrentTerrain();	//$aac3();
	y = #2e;
	$1a = $6e[y] = a;
	command_magic();	//$a367();
	$cc++;
	$7ec2 = #14;
	if ($7e9b == 0) { //bne aac2
$aa7c:
		x = (getActor2C() & 7) << 1;	//a42e
		$18,19 = $6e[y = 5,6];	//maxhp
		$18,19 >>= 2;	//(lsr ror) * 2

		var temp = $6e[y = 3,4] -= $18,19
		if (temp < 0) { //bcs aab3
$aaa8:
			$6e[y,--y] = 0;
			$f0.x = #80;
		}
$aab3:
		$7e5f.x = $18; x++;
		$7e5f.x = $19;
		$54 = 3;
	}
$aac2:
	return;
$aac3:
}
```



