
# $3f:ff36 await_nmi_by_set_handler
> この関数の呼び出し元へ直接戻る特殊なNMIハンドラを設定することによって、次のNMIを待つ。

### notes:
this function internally utilizes nmi handler to await next NMI,
but returns to caller as usual function.
this is done by the NMI handler by manipulating stacks.
processor registers carry, overflow, X and Y are preserved acorss the call.

### code:
```js
{
	[$0100,$0101,$0102] = [0x4c, 0x2a, 0xff]; //jmp $ff2a
$ff45:
	for (;;) {} //jmp $ff45
}
```

