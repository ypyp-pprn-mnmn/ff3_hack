
# $35:b419 drawEquipWindow



### args:
+ [in] u16 $59 : ptrToEquips ($6200)
+ [in] bool $7573 : eraseFlag 

### (pseudo-)code:
```js
{
	for (x = 7;x >= 0;x--) {
		$7400.x = 1;
		$34.x = #ff;
	}
	y = a = getPlayerOffset() + 3;//$35:a541();
$b432:
	$36 = $59[y]; y+=2;	//equip.right.id,count
	$3a = $59[y]; y+=2;	//equip.left.id,count
	
	loadTileArrayOfItemProps();	//$35:b1d8();

	$7201 = $7235 = #c0;	//'"'
	$720f = $7244 = #9c;	//'て
	$720d = #a9;		//		
	$720e = #90;
	$7241 = #a4;
	$7242 = #99;
	$7243 = #b1
	if (#ff != (a = $7573) )  {
		eraseFromLeftBottom0Bx0A();	//$34:8f0b();
	}
	return draw8LineWindow(left:$18 = #01, right:$19 = #0f, behavior:$1a = #03); //jmp $34:8b38();
$b48b:
}
```



