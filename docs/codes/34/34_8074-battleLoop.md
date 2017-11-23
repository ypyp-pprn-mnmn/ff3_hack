
# $34:8074 battleLoop 


## (pseudo-)code:
```js
{
//	least value of S = $18 = $20 - 8(call_doBattle,beginBattle,dungeon_mainLoop,dungeon_mainLoop)
//	u8 $7ac2 : currentActorIndex
//------------------------------------------------------
	$34:81c3();
	a = $7ed8 & #20;
	if (0 != a) $35:a487();
$8081:
	a = $78ba & 1;
	if (0 == a) {
		dispatchBattleFunction(2);	//decideEnemyAction(); //$34:801a();
	}
$808b:
	call_2e_9d53(a = #0e);	//$3f:fa0e();

	$34:81a0();
	getCommandInput();	//$34:986c();
	$7be1 = a = 0;
	beginBattlePhase();	//$34:8374(); [out]$74 = escape count

	call_2e_9d53(a = #0f);	//$3f:fa0e();

	a = $78ba;
	if (a >= 0) $34:8271();
$80ab:
	calcActionOrder();	//$34:9777();
	clearSprites2x2(index:$18 = 0);	//$8adf
	eraseFromLeftBottom0Bx0A();	//$34:8f0b();
	$34:82ce();
$80bb:
	$78cf,78d0,78d1,78d2 = #ff;
$80c9:	do {
		initBattleVars();	//$34:8213();
		drawInfoWindow();	//$34:9ba2();
		canPlayerPartyContinueFighting();	//$35:a458();
		if (0 != (a = $78d3)) goto $811c;
$80d7:
		$34:8295();
		executeAction();	//$34:9de4();
$80dd:		modifyActionMessage();	//$35:a56f();
		$7ed8 &= #df;
		presentBattle();	//$34:8ff7();

		x = ++$7ac2;
		a = $7acb.x;
		if (#ff == a) break;
	} while ($7ac2 != 0x0C);
$80ff:
	a = $78d3 & 2;
	if (0 == a) { 
		processPoison();	//$ba41();
	}
$8109:
	canPlayerPartyContinueFighting();	//$35:a458()
	if (0 == $78d3) {
$8111:
		$78ba &= 8;
		goto $8074;
	}
$811c:
	//...
$8184:
	return;
}
```

