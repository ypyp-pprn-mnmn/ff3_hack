
# $34:89ee getInputAndUpdateCursor_OnUp



### (pseudo-)code:
```js
{
	if ((a = $23) != 0) $8a0a
	if ((a = $1b) != 0) $8a32
	$23 = 3;
	$55,56 += 6;
	goto $8ac1;
$8a0a:
	$23--;
	if ((a = $23) != 2) $8a25;
	if ((a = $38) == 0) $8a25;
$8a17:
	$55,56 -= 2;
	$23--;
$8a25:
	$55,56 -= 2;
$8a32:
	goto $8ac1;
}
```



