
# $33:b7b5 swap60hBytesAt$0200and$02a0

### code:
```js
{
	for (x = 0;x != 0x60;x++) {
$b7b7:
		push (a = $02a0.x);
		$02a0.x = $0200.x;
		$0200.x = pop a;
	}
}
```


