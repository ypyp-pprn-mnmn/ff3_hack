
# $34:8a82 getInputAndUpdateCursor_OnLeft

<summary></summary>

## (pseudo-)code:
```js
{
	if ((a = $22) != 0) { //beq $8a95
		$22--;
		$55,56 -= #0008;
	}
$8a95:
	$0050.(x = $1a) = #40;
	goto $8ac1;
}
```



