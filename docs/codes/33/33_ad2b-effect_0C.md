
# $33:ad2b effect_0C	

>damageEffect

### args:
+	[in] u8 $7e6f : side (0 = player)
+	[in] damage $7e4f[8] : damages

		struct damage {
			u16 damage : 14;	//表示する値 3FFFで 表示無し
			u16 miss : 1;		//1なら damage == 3fffでない限りミス!と表示
			u16 heal : 1;		//1なら数字の色が緑($56-の代わりに$66-のタイルを使用,パレットは同じ)
		};

### code:
```js
{
	$cb = 0;
	a = #be;
	$a440();
	for (x = 0;x != #10;x++) {
		if ($7e4f.x != #ff) goto $ad43;
	}
	return;
$ad43:

	loadEffectSpritesWorker_base0(	a = #d );	//$bf1e();
	damagesToTiles();	//$ada6();
	beginSwingFrame();	//$a059();
	$7e73 = a;
	$90 = #8;
	$91 = #40;
	fill_A0hBytes_f0_at$0200();	//$a42b();
$ad5c:
	$c8 = 0;
	$7e73 += $90;
	x = $7e73 & #7f;
	$7ee3();	//ram
	mul8x8_reg(a, x = $91); //f8ea
	$8a = x;
	x = 0;
	do {
$ad7b:
	
		getDamageValueAndFlag();	//$ad0a();
		buildDamageSprite();	//$ac4b();
$ad81:
		if ($7e6f == 0) {
			x++;
			(x == 4);
		} else {
			x++;
			(x == 8);
		}
	} while (!equal); //bne ad7b
$ad91:
	updatePpuDmaScrollSyncNmi();	//$f8c5();
	incrementEffectFrame();	//$8ae6();
	if ((a & #10) != 0) { //beq ad9f
		$91 = #10;
	}
$ad9f:
	if (($b6 & #20) == 0) goto $ad5c;
	return;
}
```


