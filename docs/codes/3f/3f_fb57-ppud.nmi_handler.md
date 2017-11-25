


# $3f:fb57 ppud.nmi_handler
>戦闘モード時のnmiハンドラ

### args:
-	[in,out] u8 $05: nmi_pending (@see `$3f:fb80 ppud.await_nmi_completion`)

### notes:


### code:
```js
{
	push(a);
	push(a = x);
	a = $7cf3;	//sprite0 hitflag?
	if (a != 0) {
		ppud.sync_registeres_with_cache() //$3f:f8cb();
		$02 = a = $03;
		$c000 = $c001 = a;	//irq latch regs (mapper function)
		x = $01;		//$01 : 0:disable / 1:enable irq (mapper function;MMC3)
		$e000.x = a;	//irq disable/enable
	}
$fb71:
	$05 = 0;
	x = a = pop();
	a = pop();
	return;	//RTI.
}
```





