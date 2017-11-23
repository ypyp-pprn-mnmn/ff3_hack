
# $35:ab0c command_detect

<summary>0d: みやぶる</summary>

## (pseudo-)code:
```js
{
	setEffectHandlerTo18();	//ab66
	$78d5 = 1;
	$78d7 = #46;
	if ($70[y = 1] < 0) { //bpl ab27
		$78da = #3b;
		//jmp ab65
	} else {
$ab27:
		a = $70[y = #12];	//weakpoint
		for (y = 0, x = 0;y != 7;y++) {
			a <<= 1;
			if (carry) { //bcc ab37
				$7400.x = a = y;
				x++;
			}
$ab37:
			y++;
		}
		$7400.x = #ff;
		y = 0;
		x = $78ee;
		if ($7400 < 0) { //bpl ab51
			y--;
			a = #43;
			//jmp ab5b
		} else {
$ab51:
			
			if ((a = $7400.y) == #ff) ab65;	//beq
			a += #48;
		}
$ab5b:
		$78da.x = a;
		$78ee++;
		y++;
		goto ab51;
	}
$ab65:
	return;
}
```




