
# $3f:e9bb floor::getObjectEvent


### args:
+	[in] u8 x : object offset

### code:
```js
{
	$44 = $43;
	$a0 = $7000.x;
	x = #82;
	if ($78 != 0) {
		x = #84;
	}
	a = $a0;
	floor::loadEventScriptStream();	//$ea04()
	if ($a0 < #e0) { //bcs e9e8
		switch1stBankTo3C(); //$eb28();
		floor::copyEventScriptStream(); //$3c:92f3();
		if ($6c != 0) { //beq e9e4
			return floor::getObjectEventPtr(); //?c72c
		}
$e9e4:
		return;
	}
$e9e5:
	$50++;
	return;
$e9e8:
	if (a >= #e3) return $e9e5();
$e9ec:
	x = 8;
	call_switch2ndBank(per8k:a = #3b); //ff09
	$3b:a003();
	switch1stBankTo3C(); //eb28
	$8fdd();
	if ($6c != 0) { //beq ea03
		return floor::getObjectEventPtr(); //c72c
	}
$ea03:
	return;
}
```




