
# $35:a816 getInvertedLineFlag

<summary></summary>

## args:
+ [out] $18 : inverted line flag
+ [out] a : flag
## (pseudo-)code:
```js
{
	push a;
	$18 = a ^ 1 & 1;
	pop a;
	a &= #fe | $18
	return;
$a823:
}
```



