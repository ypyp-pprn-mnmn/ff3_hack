
# $3e:c3be


### code:
```js
{
	if ($32 != 0) {
$c3c2:
		$ca79();
	}
$c3c5:
	field_setScroll();	//$c398();
	a = ($35 + $34) & #0f;
	if (a != 0) { //beq c3d4
		$35 = a;
		return;
	}
$c3d4:
	$34 = $35 = a;	//a:0
	a = ($27 += 1);
	a = a & #10;
	$fd >>= 1;
	(a == #10);
	rol $fd;
	return;
}
```




