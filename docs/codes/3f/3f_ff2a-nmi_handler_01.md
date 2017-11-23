
# $3f:ff2a nmi_handler_01


## code:
```js
{
	$2002;
	$0100 = #40;
	pop a; pop a; pop a; //flag,addr,addr
	return;
}
```



