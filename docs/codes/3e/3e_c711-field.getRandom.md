
# $3e:c711 field::getRandom


## code:
```js
{
	if ($f6 >= 0) { //bmi c71b
		$f5++;
	} else {
		$f5--;
	}
	if ($f5 == 0) { //bne c726
$c71f:
		$f6 += #a0;
	}
$c726:
	x = $f5;
	a = $fe00.x;
	return;
$c72c:
}
```




