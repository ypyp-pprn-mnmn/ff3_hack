
# $3f:f640 invert_treasure_loot_flag


## code:
```js
{
	x = $45 & #0f;
	push (a = $0710.x);
	x = a & 7;
	$80 = $f668.x;
	x = pop a >> 3;
	if ($78 != 0) {
		x += #20;
	}
	$6040 ^= $80;
	return;
$f668:
	01 02 04 08 10 20 40 80
}
```




