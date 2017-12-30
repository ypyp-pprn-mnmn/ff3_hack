
# $3f:ff0c switch_1st_bank
>切り替え可能ななPRG ROM bankの一つ目($8000-9FFF)を指定のbankへ切り替える。

### args:
+	in u8 A: index of PRG ROM bank (per 8k bytes) to switch.

### callers:
+	$3f:ff06 thunk.switch_2nd_bank
+	$3f:ff17 switch_2banks

### code:
```js
{
	push(a);
	$8000 = 6;
	$8001 = pop();
	return;
}
```

