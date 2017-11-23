
# $3e:c243 field::dispatchInput


### code:
```js
{
	if ($a9 == 0) { //bne c252
		floor::getInputOrFireObjectEvent(); //d219
		if (($20 & #0f) != 0) goto c253; //bne c253
		
		$4e = a;	//0
	}
$c252:
	return;
$c253:	//[上下左右]
	$33 = a;
$c255:
	return field_OnMove();	//$c4fc();	//jmp
}
```




