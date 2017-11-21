
# $3f:fb30 irq_handler


## args:
-	[in,out] u8
## notes:
戦闘中のハンドラ。
バンク変更中を考慮している。
## code:
```js
{
	push a;
	if ((a = $00aa) == 0) { //bne $fb45
		$2000 = $08;	//ppu ctrl
		$2005 = $10;	//bg.scroll.x
		$2005 = a = $11;//bg.scroll.y
	}
$fb45:
	$e000 = a;	//disable irq (mapper function;MMC3)
	$00 = 0;
	if (($aa | $a9) == 0) {	//$a9はbank変更中1
		$3f:faf2
	}
$fb55:
	pop a;
	return;
}
```



