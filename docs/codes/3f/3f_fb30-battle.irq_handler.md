
# $3f:fb30 battle.irq_handler
> 戦闘モード時のIRQハンドラ。画面の分割処理(背景とウインドウ領域)を行い、バンク変更中でなければ$3f:faf2を通じて効果音の再生も行う。

### args:
-	out u8 $00: 0
-	in u8 $08: ppu ctrl cache, will set to $2000
-	in u8 $10: ppu bg scroll x, will set to $2005
-	in u8 $11: ppu bg scroll y, will set to $2005
-	in u8 $aa: ?
-	in u8 $a9: in bank switching. 1: switching, 0: otherwise.

### notes:
$a9, set by `$3f:fb89 switch_16k_synchronized_nocache`,
is being not 0 if and only if there is switching of bank in progress. 

### code:
```js
{
	push(a);
	if ((a = $00aa) == 0) { //bne $fb45
		$2000 = $08;	//ppu ctrl
		$2005 = $10;	//bg.scroll.x
		$2005 = a = $11;//bg.scroll.y
	}
$fb45:
	$e000 = a;	//disable irq (mapper function;MMC3)
	$00 = 0;
	if (($aa | $a9) == 0) {	//$a9はbank変更中1
		battle.play_SE();	//$3f$faf2();
	}
$fb55:
	a = pop();
	return;	//RTI
}
```


