
# $3f:ff03 thunk.switch_2banks
> $3f:ff17 switch_2banks へのthunk. (切り替え可能ななPRG ROM bankのページ二つ($8000-BFFF)を指定のbankへ切り替える。)

### args:
+	in u8 A: index of first PRG ROM bank (per 8k bytes) to switch.

### notes:
this function always maps 2 consecutive 8k banks into $8000-$bfff.

### code:
```js
{
	return switch_2banks();	//jmp $ff17
}
```

