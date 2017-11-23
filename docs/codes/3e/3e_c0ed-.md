
# $3e:c0ed


### code:
```js
{
	$c859();
	$cf9f();
	if ($6011 < 0) { //bpl $c108
		switchToBank3C();	//$c98a();
		$7f42 = #04;
		$7f49 = #88;
		$939b();
	}
	S = #ff;
	$c765();
	$43 = a & #20;
$c112:
	call_switch1stBank(per8k:a = #3a); //ff06

	waitNmiBySetHandler(); //ff00
//$34=scrollincrement,$4e=?

	$4014 = #02;	//dmaAddr.high (low=00)
	$8515();
	field_doScroll();	//$c389();	
	//...
$c150:
	$c1e4();	//=>c243,cd7e(getVehicleSpeed)
	switchToBank3C();	//$c98a();
	$3c:b78a();
	$3c:b7f9();
	$c486();
	$d83c();
	goto $c112();	//jmp
}
```




