
# $33:b09b beginActionEffect

### args:
+	[in] u8 $7e88 : actionId

### code:
```js
{
	getActionEffectLoadParam();	//$33:af6f();
	push (a = $7e8b & #80);
	if (a == 0) a = #5;
	else a = #6;
$b0ac:
	loadEffectSpritesWorker_base0();	//$33:bf1e();
	a = $7e8d;
	$33:af94();
	a = $7e9a;
	if (a < 0) {
		pop a;
		return;
	}
$b0bc:
	a = $cc;
	if (0 != a) {
		pop a;
		beginSwingFrame();	//$33:a059();
		do {
$b0c4:			$33:af9f();
			setSpriteAndScroll();	//$3f:f8c5();
			incrementEffectFrame();	//$32:8ae6();
		} while (a != #20);
		return;
	}
$b0d2:
	pop a;
	if (a == 0) {	//bne $b0f1
		beginSwingFrame();	//$33:a059();
		$7f49 = #a1;
		do {
$b0dd:			$33:af9f();
			$33:b1cd();
			$33:b1f8();
			setSpriteAndScroll();	//$3f:f8c5
			incrementEffectFrame();	//$32:8ae6();
		} while (a != #2c);
	}
$b0f1:
	$33:bf5f();
	a = #10;
	$33:b35c();
	$33:b362();
	beginSwingFrame();	//$33:a059();
	$7f49 = #a1;
	do {
$b104:		$33:af9f();
		$33:b1c3();
		$33:b134();
		setSpriteAndScroll();	//$3f:f8c5
		incrementEffectFrame();	//$32:8ae6();
	} while (a != #30);
	do {
$b117:	
		$33:af9f();
		$33:b134();
		for (y = 0;y != 8;y++) {
$b11f:
			a = 1;
			$33:bf9c();
		}
$b129:
		setSpriteAndScroll();	//$3f:f8c5
		$b6++;
	} while (0 != (a = $7e26));
}
```


