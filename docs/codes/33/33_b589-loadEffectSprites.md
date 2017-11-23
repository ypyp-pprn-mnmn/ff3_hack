
# $33:b589 loadEffectSprites

### args:
+	[in] u8 $7e8b[3] : actionEffectLoadParam

### code:
```js
{
	a = $7e8b & #40;
	if (a == 0) a = 0; x = #96;
$b597:	else 	a = 0; x = #a6;
$b59b:
	$7e,7f = a,x;	//#9600 or #a600
	mul8x8_reg(a = $7e8c,x = #10);	//f8ea
	$7e,7f += a,x;
	loadEffectSpritesWorker(a = 7);	//bf24
	return loadEffectSpritesWorker_base0(a = 8); //bf1e
}
```


