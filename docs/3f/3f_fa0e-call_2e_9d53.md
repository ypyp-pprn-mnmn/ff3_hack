
# $3f:fa0e call_2e_9d53


## args:
+	[in] u8 A : 9d53_param
## notes:
各種ゲームシーン表示系のルーチンから呼ばれる
## code:
```js
{
	push(a);
	switch_16k_synchronized({bank: a = 0x17});
	a = pop();
	$2e$9d53();
	switch_16k_synchronized({bank: a = 0x1a}); //jmp 3f:fb87
}
```



