
# $33:ad0a getDamageValueAndFlag

### code:
```js
{
	$7e = a = x;
	y = a << 1;
	$7e70 = $7e4f.y;
	$7f = $7e50.y;
	$7e71 = $7f & #3f;
	$7e72 = ($7f & #c0) | $7e;	//higher 2bits of damage | index
	x = $7e;	//restore x
	return;
}
```


