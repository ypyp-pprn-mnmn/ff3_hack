
# $34:8f57 getSortedIndex

<summary></summary>

## args:
+ [in] u8 $1a : base?
+ [in] ptr $1c : keys
+ [in] ptr $1e : result indices
+ [in] u8 $22 : len
## (pseudo-)code:
```js
{
	push (a = $22);
	x = a - $1a;	//len - base
	$18 = ++x;	//len - base + 1
	y = 1;
	for (x = 0;x != $18;x++) {
		a = x;
		$1e[y] = a;
		y++;
	}
	pop a;	//len?
	//fall through
```


**fall through**

