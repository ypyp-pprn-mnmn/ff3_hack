
# $3f:fab5 saveNmiIrqHandlerAndSetHandlerForBattle


## code:
```js
{
	for (x = 6;x != 0;x--) {
		$7ed8.x = $00ff.x;
	}
	$0100,0101,0102 = jmp $fb57;
	$0103,0104,0105 = jmp $fb30;
$fadd:
}
```



