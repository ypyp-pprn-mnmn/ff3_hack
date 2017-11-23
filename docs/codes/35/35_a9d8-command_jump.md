
# $35:a9d8 command_jump

<summary>08: ジャンプ</summary>

## (pseudo-)code:
```js
{
	$78d5 = 1;	//listId
	$78d7 = #41;	//actionName
	a = $6e[y = 1] & #28;
	if (a != 0) { //beq $a9f6
		$7ec2 = #18;	//effect
		$78da = #3b;	//message "こうかがなかった"
	} else {
$a9f6:
		$6e[y = #27] = 2;
		x = a = (getActor2C() & 7) << 1;	//$35:a42e();
		x++;
		$f0.x |= 1;
		y += 2;
		$6e[y] = 9;	//y:2e actionId
	}
$aa10:
	return;
}
```



