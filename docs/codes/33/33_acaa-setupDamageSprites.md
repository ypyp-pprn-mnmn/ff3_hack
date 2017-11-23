
# $33$acaa setupDamageSprites

### code:
```js
{
	x = $c8;
	a = $8e;	//y
	$acfd();
	x++;
	$0200.x = $7e;
	$0204.x = $7f;
	$0208.x = $80;
	$020c.x = $81;
	x++;
	a = $82;	//attr
	$acfd();
	x++;
	a = $8c;
	$0200.x = a; a += 8;
	$0204.x = a; a += 8;
	$0208.x = a; a += 8;
	$020c.x = a;
	if ( ($7e | $7f | $80 | $81) == 0) {
$acee:
		a = #f0; x = $c8;
		$acfd();
	}
$acf5:
	$c8 += #10;
	return;
$acfd:
}
```


