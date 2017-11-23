
# $35:a881 command_guard

<summary>05: ぼうぎょ</summary>

## (pseudo-)code:
```js
{
	$78d7 = #3e;
	setNoTargetMessage();	//$91ce
	$78d5 = 1;
	push ( a = $6e[y = #23] );
	x = getActor2C() & 7;	//a42e
	$7ce4.x = pop a;
	if (a >= #80) {
		a = #ff;
	} else {
		a <<= 1;
	}
$a8a6:
	$6e[y = #23] = a;;
	return;
$a8ab:
}
```



