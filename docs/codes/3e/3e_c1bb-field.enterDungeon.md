
# $3e:c1bb field::enterDungeon


### args:
+	[in] u8 $78 : world (00:floating land)

### code:
```js
{
	$7f49 = #93;	//SE
	$cf79();
	call_switch1stBank(per8k:a = #00);	//$ff06;
$c1c8:
	x = $45;
	if ($78 == 0) { //bne c1d4
$c1ce:
		a = $8800.x;
		//jmp c1d7
	} else {
$c1d4:
		a = $8840.x;
	}
	$48 = a;
	dungeon::mainLoop();	//e1dc
	return $c0ed();
}
```




