
# $3f:ff1f switch_2nd_bank
>切り替え可能ななPRG ROM bankの二つ目($A000-BFFF)を指定のbankへ切り替える。

### args:
+	in u8 A: index of PRG ROM bank (per 8k bytes) to switch.

### callers:
+	$3f:ff09 thunk.switch_2nd_bank: it is an only caller of this function.

### notes:
processor registers X and Y are unaffected and preserved across calls.

### code:
```js
{
	push(a);
	$8000 = 7;
	$8001 = pop();
	return;
$ff2a:
}
```

