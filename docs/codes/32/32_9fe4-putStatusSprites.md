
# $32:9fe4 putStatusSprites

### args:
+	[in] u8 $9e : offsetY?
+	[in] u8 $9f : tileIndex? (#ff == nothing)
+	[in] u8 $a0 : destOffset
+	[in] u16 $a1 : ptr to spriteProps {y,?,attr,x}
+	[in] u8 $a3 : index of $7db7

### code:
```js
{

	for (x = $a0,y = 0;y != 8;) {
$9fe8:
		$0200.x = a = $a1[y] + $9e;	//sprite.y
		y++;
		if (#ff == (a = $9f)) {
			$0201.x = a = 0;
		} else {
			$0201.x = a;	//sprite.tileIndex
		}
$a004:
		push (a = x);
		y++;
		$a7 = $a1[y];	//y:2
		x = $a3;
		if (#ff != (a = $7db7.x)) { //beq a02f
			x = a;
			$a7 = $a7 & #fc | $a051.x;
			$a8 = $a049.x;
			x = pop a;
			push a;
			$0200.x += $a8;	//sprite.y
		}
$a02f:
		x = pop a;
		$0202.x = $a7; y++;	//sprite.attr
		$0203.x = $a1[y] + $9d;	//sprite.x	y:3
		x += 4;
		y++;
	}
$a048:	return;
}
```


