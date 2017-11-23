
# $33:b8af initAndTileEffectSprites 

>tile6x6

### args:
+	[in] u8 A : coordinates mode (00:left top,01:right top,02:left bottom,03:right bottom)
+	[in] u8 $b89b.(a*4) : { beginX,diffX, beginY,dY }
+	[in] u8 $b8ab.(a) : defaultAttr

### code:
```js
{
	push (a);
	a <<= 2;
	for (x = 0,y = a;x != 4;x++,y++) {
$b8b5:		$7e.x = $b89b.y;
	}
	for (x = 0,y = 6;x != #90; x += 4) {
$b8c4:
		$7924.x = a = $80;	//sprite.y;
		if (--y == 0) {
			y = 6;
			$80 = a + $81;
		}
$b8d3:
	}
	$82 = a = $7e;
	for (x = 0;y = 6;x != #90; x += 4) {
$b8e3:
		$7927.x = a = $82;	//sprite.x;
		$82 = a + $7f;
		if (--y == 0) {
			y = 6;
			$82 = $7e;
		}
	}
$b8fe:
	y = pop a;
	a = $b8ab.y;
	for (x = 0;x != #90;x += 4) {
$b905:		$7926.x = a;		//sprite.attr
	}
}
```


