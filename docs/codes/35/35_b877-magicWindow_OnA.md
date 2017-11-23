
# $35:b877 magicWindow_OnA 



### (pseudo-)code:
```js
{
	$18 = a = $24;
	x = $26 + $18 + ($18 << 1); //row*3+col
	a = $7400.x;	//;magicid
	if (a == #ff) 
$b889:		goto $b8b5; //bne jmp
$b88c:
	push a;
	if ((0 == (a = $7ed8) & #10)) $b89a;
	pop a
	if (a == #2f) $b889;	//beq
	push a
$b89a:
	$47 = push ($46 - $24);
	x = $52;
	$7ac7.x = $47;
	pop a
	y = a + $5f + #7;
	a = $5b[y];
	if (a != 0) $b8bb;	//bne
$b8b4:
	pop a;
$b8b5:
	$9b81();
	return;	//jmp $b7b8
$b8bb:
	$9b7d();
	pop a;	//magic id
	push a;
	$b953();
	if (a == 0) $b8d1;	//beq
	if (a != 1) $b8cd;	//bne
	pop a;
	goto $b8b5;
$b8cd:
	pop a;
	return magicWindow_close();	//$b8ee;
$b8d1:
	$9b9b();
	x = $52;
	$5b[y] = $78cf.x = pop a + #c8;
	if (a != #ff) $b8ec;
$b8e3:
	a = $7be1;
	$fd20();
	$7be1 = a;
$b8ec:
	$52++;
}
```



