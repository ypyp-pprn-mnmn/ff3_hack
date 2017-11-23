
# $34:9648 countAndDecrementUntil0



### args:
+ [in] u16 $20 : decrementBy

### (pseudo-)code:
```js
{
	x++;
	do {
$9649:		$18,19 -= $20,21;
		$1a.x++;
	} while ($18,19 >= 0);
	$18,19 += $20,21;
	$1a.x--;
$966a:
}
```



