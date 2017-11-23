
# $33:b866 setEffectSpriteTile

### args:
+	[in] u8 $7e : [xVHnnnnn]
+	[out] u8 $7925.y : sprite.tileIndex where
	-	$7e & #7f == 0 : 0
	-	otherwise : ($7e & #1f) + #49
+	[in,out] u8 $7926.y : sprite.attr
+	[in,out] u8 Y : spriteIndex

### local variables:
+	u8 $7f : [VH000011]

### code:
```js
{
	$7f = (($7e << 1) & #c0) | #03;
	a = $7e & #7f;
	if (a == 0) {	//bne b87c
		a = 0;
	} else {
$b87c:		a &= #1f; a += #49;
	}
$b881:
	$7925.y = a;	//tileIndex
	$18 = ($7f & 3) | $7926.y;
	$7926.y = ($7f & #c0) ^ $18;	//attr:パレット番号は必ず3?
	y += 4;
}
```


