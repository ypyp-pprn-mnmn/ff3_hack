
# $3f:ff06 thunk.switch_1st_bank
> $3f:ff0c switch_1st_bank へのthunk. (切り替え可能ななPRG ROM bankの一つ目($8000-9FFF)を指定のbankへ切り替える。)

### args:
+	in u8 A: index of PRG ROM bank (per 8k bytes) to switch.

### code:
```js
{
	return switch_1st_bank();	//jmp $ff0c
}
```

