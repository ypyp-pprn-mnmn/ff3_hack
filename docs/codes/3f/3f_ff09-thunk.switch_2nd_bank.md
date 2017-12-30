

# $3f:ff09 thunk.switch_2nd_bank
> $3f:ff1f switch_2nd_bank へのthunk. (切り替え可能なPRG ROM bankの二つ目(A000-BFFF)を指定のbankへ切り替える。)

### args:
+	in u8 A: index of PRG ROM bank (per 8k bytes) to switch.

### code:
```js
{
	return switch_2nd_bank();	//jmp $ff1f
}
```


