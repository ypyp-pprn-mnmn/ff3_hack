
# $35:a50b fireCannon



### (pseudo-)code:
```js
{
	call_2d_9e53(a = #f);	//$fa0e
	$78da = #3d;	//"たいほうの えんごしゃげき!"
	$7ed8 &= #df;
	eraseFromLeftBottom0Bx0A();	//$8f0b();
	$78d5 = #3;	//
	presentBattle();	//$8ff7();
	canPlayerPartyContinueFighting();	//$a458();
	if ($78d3 == #40) { //bne a53c
		pop a; pop a;
		pop a; pop a;
		a = $78d3;
		return $811c();
	}
$a53c:
	return call_2d_9e53(a = #e);	//jmp fa0e
}
```



