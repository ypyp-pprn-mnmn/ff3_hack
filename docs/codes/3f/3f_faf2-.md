
# $3f:faf2


### code:
```js
{
	push(a = x);
	push(a = y);
	if ((a = $c9) != 0) { //beq $fb05
		$7f49 = $ca | #80;
		$c9 = 0;
	}
	switch_16k_synchronized_nocache({bank:a = 0x1b});	//$3f:fb89;
	$36$8003;	//sound?
	switch_16k_synchronized_nocache({bank:a = $ab});		//$ab : last $fb87 param (=last bank no)
	y = pop a;
	x = pop a;
	return;
}
```



