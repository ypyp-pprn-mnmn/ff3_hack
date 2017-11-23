
# $33:a3f9 clearWeaponSprite? 

>fill 18hbytes at y

### code:
```js
{
	push (a = x);
	y = $a3f5.x;
	a = #f0;
	for (x = 0;x != #18;x++) {
		$0200.y = a;
	}
	x = pop a;
	return;
$a40f:
}
```

