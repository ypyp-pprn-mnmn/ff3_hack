
# $34:8577 playEffect_01 



### args:
+ [in] u8 $7e88 : actionId
+ [in] u8 $7e98 : actors char bit?
+ [in] u8 $7e99 : selected targets ($6e[#2f])
+ [in] u8 $7e9a :	effect side
+ [in] u8 $7e9d : actionParam[6]; see $31:af77

### local variables:
+	$00c9 : playSoundFlag
+	$00ca : soundEffectId

### (pseudo-)code:
```js
{
	y = $7e88;
	$00ca = a = $83a0.y;
	$00c9 = 0;
	a = $7e9a;	//effect side
	if (a < 0) dispatchPresentScene_1f();	//$34:8545(); 
$858d:
	set52toActorIndexFromEffectBit();	//$34:8532();
	$7e89 = $7e99;	
	call_2e_9d53(a = #1d);
	doNothing_8689();	//$34:8689()
	a = $7e9a & #40;
	if (a == 0) return;  //beq $85ec

	a = $7e9d;	
	switch (a) {
	case 6:	//分裂系?
		a = $7e99;
		if (#ff == a) break;	//beq $85ec;
		$7e = a;
		return call_2e_9d53(a = #0c);
	case 7:
		$7e8f = $7e9b;
		$7e90 = 3;
		return call_2e_9d53(a = #22);
	case 8:
	case 0xd:
$85d2:		a = $7e9b;
		if (0 == a) break;	//beq $85ec;
		tagetBitToCharIndex(x = 3);	//$34:86ab();
		$b8 = y;
		$7e = $7e9b;
		return call_2e_9d53(a = #23);
	}
$85ec:	
	return;
}
```



