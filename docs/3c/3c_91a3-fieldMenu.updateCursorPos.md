
# $3c:91a3 fieldMenu::updateCursorPos


## args:
+	[in] u8 a : cursorIncrement
+	[in,out] u8 $78f0 : cursor
+	[in] u8 $78f1 : rowSize
## (pseudo)code:
```js
{
	$06 = a;
	$9175();
	$80 = a & #f;
	if (a == 0) return;	//beq 91c8
	if (a < 4) { //bcs 91b6
$91b2:
		$06 = x = 4;
	}
$91b6:
	if ((a & 5) == 0) { //bne 91c9
$91ba:
		a = $78f0 - $06;
		if (a < 0) { //bcs 91c5
			a += $78f1;
		}
$91c5:
		$78f0 = a;
		return;
	}
$91c9:
	a = $78f0 + $06;
	if (a < $78f1) $91c5;
	a -= $78f1;
	if (a >= 0) $91c5;
$91d9:
}
```



