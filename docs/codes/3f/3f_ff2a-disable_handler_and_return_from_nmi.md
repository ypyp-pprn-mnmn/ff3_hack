
# $3f:ff2a disable_handler_and_return_from_nmi
> nmiハンドラから自身を取り除き、$3f:ff36の呼び出し元へ直接戻る。

### args:
none. as this is an NMI handler.

### notes:
technically the continuation of this function is NOT an instruction
executed right before the NMI inturrupt happened as usual.
rather, it is a return address of `$3f:ff36 await_nmi_by_set_handler`
which had set this function as NMI handler.
this is done by manipulating stacks. 

### code:
```js
{
	$2002;
	$0100 = 0x40;	//rti.
	pop(); pop(); pop(); //flag,addr,addr
	return;
}
```

