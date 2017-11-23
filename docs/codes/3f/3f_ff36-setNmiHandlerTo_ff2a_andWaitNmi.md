
# $3f:ff36 setNmiHandlerTo_ff2a_andWaitNmi


## code:
```js
{
	$0100,0101,0102 = #4c,#2a,#ff; //jmp $ff2a
$ff45:
	for (;;) {} //jmp $ff45
}
```



