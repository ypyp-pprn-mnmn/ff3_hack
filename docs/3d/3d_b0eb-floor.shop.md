
# $3d:b0eb floor::shop:


## (pseudo)code:
```js
{
	//...
$b19a:
	$8f74();
	x = $8e;
	if ( $64 == 0) { //bne b1ae
		$60e0.x -= 1;
	}
$b1ae:
	if ( $64 != 0 || $60e0.x == 0) { //bne b1b6
$b1b0:
		$60c0.x = $60e0.x = 0;
	}
$b1b6:
	$80,81,82 = $61,62,63;
$b1c2:
	incrementPartyGil( increment:$80 );
	$b1f2();
	return $b137();
}
```



