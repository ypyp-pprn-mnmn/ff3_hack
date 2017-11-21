
# $3f:fb57 nmi_handler


## args:
-	[in,out] u8 $05: nmi_lock (@see `$3f:fb80 waitNmi`)
## notes:
戦闘中のハンドラ
## code:
```js
{
	push(a);
	push(a = x);
	a = $7cf3;	//sprite0 hitflag?
	if (a != 0) {
		updatePpuScrollNoWait(); //$3f:f8cb();
		$02 = a = $03;
		$c000 = $c001 = a;	//irq latch regs (mapper function)
		x = $01;	//$01 : 0:disable / 1:enable irq (mapper function;MMC3)
		$e000.x = a;
	}
$fb71:
	$05 = 0;
	x = a = pop();
	a = pop();
}
```



