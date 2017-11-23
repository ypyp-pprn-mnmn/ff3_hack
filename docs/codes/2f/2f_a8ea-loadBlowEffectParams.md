
# $2f:a8ea loadBlowEffectParams

### code:
```js
{
	mul_8x8reg(a = $7e1f, x = 3);	//$f8ea
	$7e,7f = #9098 + (a,x)
	$7e1f = $7e[y = 0];
	$7e13 = $7e[++y];
	$7e14 = $7e[++y];
	//
	mul_8x8reg(a = $7e20, x = 3);	//$f8ea
	$7e,7f = #9098 + (a,x)
	$7e20 = $7e[y = 0];
	$7e15 = $7e[++y];
	$7e16 = $7e[++y];

	mul_8x8reg(a = $7e13, x = #10);
	$7e,7f = (a,x);
	a = 2;
	loadSprites();	//$a1b9();

	mul_8x8reg(a = $7e15, x = #10);
	$7e,7f = (a,x);
	a = 3;
	loadSprites();	//$a1b9();

	$7e17 = $7e14;
	$7e18 = $7e16;
	return;
}
```


