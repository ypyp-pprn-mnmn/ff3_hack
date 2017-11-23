
# $3e:c6d5 field::OnCharacterMoved


### code:
```js
{
	if ((a = $44) >= 0) { //bmi c6df
		a &= #40;
		if (a == 0) $c6cb;
		else $c6f7;
	}
$c6df:
	if ($45 >= 0) $c6b9; //bpl
//($45 & 80) != 0
	push (a = x);
	push ($82);
	push ($83);
	$c911();
	$83 = pop a;
	$82 = pop a;
	x = pop a;
	return;
$c6f7:
}
```




