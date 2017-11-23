
# $3d:b6da


## (pseudo)code:
```js
{
	$e4 = $e3;
	$e3 = $e2;
	$e2 = $e1;
	$e1 = $33 & #0f;
	a = $2d >> 1;
	if (!carry) { //bcs b6fa
		a = $44 & #30;
$b6f5:
		$e1 |= a;
		return;
	}
$b6fa:
	if ( ($44 & #04) != 0)  //beq b706
		&& ( ($a5 & 1) == 1) ) //bcc b706
	{
		return;
	}
$b706:
	push (a = ($44 & #34) );
	temp = a & #04;
	pop a;
	if (temp < 4) return $b6f5; //bcc
$b712:
	a = #70; return $b6f5;
}
```



