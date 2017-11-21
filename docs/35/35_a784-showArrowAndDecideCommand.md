
# $35:a784 showArrowAndDecideCommand

<summary></summary>

## (pseudo-)code:
```js
{
	if (($78ba & #08) != 0) { //beq a7a4
		$0223 = $a833.x;
		$0222 ^= #40;	//reverseX
		if ((a = $18) >= 0) { //bmi a7a1
$a79d:
			a <<= 1;
			//clc bcc a7a2
		} else {
$a7a1:
			a >>= 1;
		}
$a7a2:
		$18 = a;
	}
$a7a4:
	for (;;) {
		do {
			presenetCharacter();	//$8185();
			getPad1Input();	//fbaa
		} while ((a = $12) == 0);
		if (a == #01) $a7bc;	//beq
		if (a == #02) $a7c8;	//beq
		if (a == $18) $a7c8;	//beq
	}
$a7bc:	//A
	playSoundEffect05();	//$9b7d
	$52++;
	setYtoOffset2E();	//9b9b
	$5b[y] = $19;
$a7c8:	//fall through
}
```



