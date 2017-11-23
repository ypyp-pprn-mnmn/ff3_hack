
# $33:ac4b buildDamageSprite

### code:
```js
{
	push (a = x);
	if ($7e6f == 0) { //bne ac6c
		x = $7e72 & 3;
		$8c = $c0.x - #10;
		$8e = $c4.x - $8a + #10;
		//jmp $ac93
	} else {
$ac6c:
		if ( $7da7.x == #ff) goto $aca7; //beq
		y = a = $7e72 & 7;
		x = a << 1;
		$8c = $7dd7.x - #10;
		$7e = $ac43.y + $8a;
		$8e = $7e07.y - $7e;
	}
$ac93:
	if ( is_backattacked_32() ) { //bne aca1	//$90d2
		$8c = ($8c ^ #ff) + #df;
	}
$aca1:
	getDamageDigitTilesAndColor();	//$add1();
	setupDamageSprites();	//$acaa();
	x = pop a;
	return;
}
```


