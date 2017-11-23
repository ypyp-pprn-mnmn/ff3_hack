
# $33:bf24 loadEffectSpritesWorker

### code:
```js
{
	mul8x8_reg(a,x = 6);	//f8ea
	$18,19 = #beb2 + a,x;
	push (a = y);
	
	y = 0;
	$7e,7f += $18[y++],$18[y++];
	$80,81 = $18[y++],$18[y++];
	$82 = $18[y++];
	$84 = $18[y++];
	copyToVramDirect(src:$7e, vramAddr:$80, len:$82, bank:$84)	//$3f:f969();
	y = pop a;
}
```
