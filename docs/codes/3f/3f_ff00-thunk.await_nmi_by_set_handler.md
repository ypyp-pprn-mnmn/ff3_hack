
# $3f:ff00 thunk.await_nmi_by_set_handler
> $3f:ff36へのthunk. (次のNMIを待つ)

### args:
none.

### notes:
processor registers carry, overflow, X and Y are preserved acorss the call.

### code:
```js
{
	return await_nmi_by_set_handler();	//jmp $ff36();
}
```

