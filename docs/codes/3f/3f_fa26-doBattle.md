
# $3f:fa26 doBattle


### args:
+	[in] a : encounter id
+	[in] x : backgroound sight graphics
+	[in] y : battleMode?

### notes:
	least value of S = $1a = $20 - 6

### code:
```js
{
	$7ced = a;
	$7cef = x;
	$7ed8 = y;
	blackOutScreen(); //[out] a = 0
	$a9 = a; //=0
	saveFieldVars(); //$fb17();
	saveNmiIrqHandlerAndSetHandlerForBattle();	//$fab5();
	switch_16k_synchronized({bank:a = 0x17});	//$fb87()
	initBattle();	//$2e:9d56();	//load encounter data?
	switch_16k_synchronized({bank:a = 0x1a});	//$fb87()
$fa47:
	$34$8003();
	switch_16k_synchronized({bank:a = 0x17});	//$fb87()
$fa4f:
	$2e$9d50();	//set music & load patterns
	cli;
	switch_16k_synchronized({bank:a = 0x1a});	//$fb87()
$fa58:
	call_battleLoop();	//$34:8000
	for ($b6 = 0;$b6 != 20;$b6++) {
$fa5f:
		updatePpuDmaScrollSyncNmiEx();	//$f8b0();
		if (( $b6 & #03) == 0) { //bne fa6b
$fa68:
			$fa87();
		}
$fa6b:
	} //bne fa5f
$fa73:
	blackOutScreen();	//$fa1d();
	restoreNmiIrqHandler();	//$fadd
	restoreFieldVariables();//$f83b();
	sei;
	$78d3 <<= 1;
	return;
$fa81:
}
```



