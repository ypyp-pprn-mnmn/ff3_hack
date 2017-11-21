
# $3f:e1dc dungeon::mainLoop


## args:
	least value of S = $1e = $20 - 2
+	[in] u8 $48 : warpId
## code:
```js
{
	a = #0;
	dungeon::loadFloor();	//$e7ec();
$e1e1:

	call_switch1stBank(a = #3a); //ff06
	waitNmiBySetHandler();	//ff00
	$4014 = #02;

	$3a:8515();
	$e54c();
	$f0,f1 += #0001;
	field::callSoundDriver();

	if ($36|$35 == #08) {
		$e900();	//checks event ?
	}
	if ( ($34 == 0) //bne e229
		&& ($76 == 0) //bne e229
	{
$e217:
		if (($ab & #e0) != 0) goto $e26a; //beq e220
$e220:
		if ( ($76 | $a9) == 0) { //bne e229
$e226:
			floor::getInputAndHandleEvent();	//$e2f8();	//getinput
		}
	}
$e229:
	if ( ($a9 == 0)	//bne e23a
		&& ($76 != 0) //beq e23a
	{
$e231:
		$92 = a;
		$76 = 0;
		$ec8b();
	}
$e23a:
	switch1stBankTo3C();	//$eb28();
	$3c:b78a();
	$3c:c486();
	$d844();
	switch1stBankTo3C();	//$eb28();
	$3c:b7f9();
	if ($4b == #ff) goto $e1e1; //beq
$e252:
	//4b = areaNameId/ stringIndex based from $30200
	$94 = 0;
	$92 = $4b;
	$95 = #82;	//94: #8200
	$4b = #ff;
	a = #4;
	$ec8d();
	goto $e1e1();

$e26a:	// (a = ($ab & #e0)) != 0

	if (a < #40) { //bcs e28b
		//encounter!
$e26e:
		$d34d();	//flash screen
		$e283();
		beginBattle();	//$c049();	//process battle(call battleLoop)
		a = 1;
		$e7f8(); //this clears encount flag
		$4b = #ff
		goto $e1e1;
	}
$e283:
	a = #3a;
	call_switch1stBank(); //ff06
	return $3a:8533();
$e28b:	// ($ab & #e0) >= #40
	if (a == #40) { //bne e295
	//warp back?
		a = #94;
$e28f:
		$7f49 = a;	//soundDriver_effectId
		return $d08c();
	}
$e295:
	if (a == #80) { //bne e2ce
$e299:	//warp forward?
		x = S;	//stack pointer
		if (x < #20) goto $e220(); //bcs e2a1
$e2a1:
		push ($29);
		push ($2a);
		push ($48);
		$e28f(a = #93);	//set SE

		x = $45 & #0f;	//warpIndex
		$48 = $0700.x;	// warpId
		dungeon::mainLoop();	//$e1dc(); recursive call
$e2bc:
		$48 = pop a;
		$2a = pop a;
		$29 = pop a;
	}
}
```




