
# $35:a458 canPlayerPartyContinueFighting



### args:
+ [out] u8 $78d3 : 80=all dead, 40=($7dd2 == 0)

### (pseudo-)code:
```js
{
	a = $78d3 & 2
	if (a == 0) { //beq a486
		$52 = 0;
		for ($52 = 0;$52 != 4;$52++) {
a463:
			updatePlayerOffset();	//$a541();
			y = a + 1;
			a = $5b[y] & #c0;	//dead | stone
			if (a == 0) goto $a47c;
		}
a478:	a = #80;
		bne $a483;
a47c:
		if ($7dd2 != 0) return;	//$a486
		a = #40;
a483:
		$78d3 = a;
	}	
a486:
	return;
}
```



