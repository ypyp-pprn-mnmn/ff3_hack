
# $3f:fb89 switch_16k_synchronized_nocache
> PRG ROM bankを16k bytes単位で切り替える。

### args:
+	in u8 A : bankNo (per _16k_ unit)
+	in,out u8 $a9 : page_lock (コマンド発行中のみincr)

### local variables:

### notes:
$a9 is checked by `$3f:fb30 battle.irq_handler`.

### code:
```js
{
$fb89:
	push(a << 1);
	a = 0x06;
	$a9++;
	$8000 = a;	//commandId	pop(a);
	$8001 = pop();	//per8k bankNo
	$a9--;
	a++;
$fb9b:
	push(a);
	a = 0x07;
	$a9++;
	$8000 = a;
	$8001 = pop();
	$a9--;
}
```	




