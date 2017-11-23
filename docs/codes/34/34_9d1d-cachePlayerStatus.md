
# $34:9d1d cachePlayerStatus



### (pseudo-)code:
```js
{
	y = $5f;
	push ($1c = $5b[++y] );
	$1a = $1c & #c0;	//daed|stone
	$1d = a = $5b[++y];
	$1a |= ($1d & #e0) >> 2; //paralyzed | sleeping | confused; fd47
	$1b = 0;
	pop a; //status0
	a &= #3f;
	$1b,a >>= 3;	//lsr ror * 3 (lowbyte:$1b)
	$1a |= a;	//status0>>3
$9d4b:
	x = $52 << 1;
	$78bb.x = $1a;
	$78bc.x = $1b;
	if (($1c & #c0) == 0) { //bne 9d89
		push (a = $1c);
		$1c &= 7;
		pop a;	//status0
		a &= #10;	//sealed (silence)
		a >>= 1;
		a |= $1c;
		$1c = a << 1;	//bit3(小人)とbit4(沈黙)を重ねる
		push (a = $1d);
		a &= #e0;
		$1c |= a;
		pop a;
		if ((a & 6) != 0) { //beq 9d83
$9d7d:
			$1c |= #01;
		}
$9d83:
		y = 0;
		if ($1c == 0) $9d89;	//bne 9d8d
	}
$9d89:
	y = #ff;
	goto $9d97;
$9d8d:
	for (y;y != 8;y++) {
		a <<= 1;
		if (carry) goto $9d97;	//bcs $9d97;
$9d90:
	}
$9d95:	goto $9d9d;
$9d97:
	a = y;
	x = $52;
	$78c4.x = a;
$9d9d:	
	return;
}
```



