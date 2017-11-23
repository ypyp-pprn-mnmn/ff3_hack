
# $2f:a738 flashEnemy

### code:
```js
{
	$a697();
	$a6b1();	//?
	y = 0;
	a = $7e8f;
	for (y;y != 8;y++) {
$a743:
		a <<= 1;
		if (carry) { //bcc a74f
			push a;
			push (a = y);
			$a75a();
			y = pop a;
			pop a;
		}
	}
	$7e8e = 0;
	return;
$a75a:
}
```


