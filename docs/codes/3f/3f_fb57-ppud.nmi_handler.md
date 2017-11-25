



# $3f:fb57 ppud.nmi_handler
>戦闘モード時のnmiハンドラ

### args:
-	[in,out] u8 $05: nmi_pending (@see `$3f:fb80 ppud.await_nmi_completion`)
-	[in] u8 $7cf3: ?
-	[in] u8 $01: irq disable/enable.
	- 1: enabled (touch odd address on $e000-$ffff)
	- 0: disabled (touch even address on $e000-$ffff)
-	[out] u8 $02: irq countdown?
-	[in] u8 $03: irq countdown?

### notes:
-	the ppu set VBlank flag at 2nd tick of scanline 241, where the VBlank NMI also occurs.
-	cpu cycles this handler takes to execute is depending on the value at $7cf3:
	- $7cf3 != 0: 97 cycles (including RTI)
	- $7cf3 == 0: 32 cycles (including RTI)

### code:
```js
{
	push(a);
	push(a = x);
	a = $7cf3;	//sprite0 hitflag?
	if (a != 0) {
		ppud.sync_registeres_with_cache() //$3f:f8cb();	40 cycles
		$02 = a = $03;
		$c000 = $c001 = a;	//irq latch regs (mapper MMC3 function)
		x = $01;		//$01 : 0:disable / 1:enable irq (mapper MMC3 function)
		$e000.x = a;	//irq disable/enable
	}
$fb71:
	$05 = 0;
	x = a = pop();
	a = pop();
	return;	//RTI.
}
```






