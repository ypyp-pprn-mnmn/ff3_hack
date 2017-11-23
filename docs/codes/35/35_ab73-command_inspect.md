
# $35:ab73 command_inspect



>0c: しらべる


### (pseudo-)code:
```js
{
	setEffectHandlerTo18();	//ab66
	for (x = 0,y = 3;x != 4;x++,y++) {
$ab7a:
		$78e4.x = $70[y];
	}
	if ($70[y = #1] < 0)  //bpl ab8f
		a = #3b;	//"こうかがなかった"
	} else {
$ab8f:
		a = #3f;
	}
	$78da = a;
	$78d5 = 1;
	$78d7 = #45;
	return;
$ab9f:
}
```



