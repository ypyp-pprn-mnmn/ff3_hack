
# $32:9f71 putCharacterSprites

### args:
+	[in] u8 $b7 : ?
+	[in] u8 $7df7[2][8] : spritePos {x,y}

### code:
```js
{
	a = #f0;
	for (x = 0;x != #20;x++) {
$9f75:		$0260.x = a;
	}
$9f7d:
	x = $a3 = a = ($b7 & #18) >> 3;
	$a4 = a = $7e0f.x
	for (y = 0;y != 8;y++) {
$9f8e:
		$a4 <<= 1;
		if (!carry) continue;	//bcc $9fde
		x = a = y << 1;
		$9d = $7df7.x;
		$9d += ($a3 << 3);
		flag = is_backattacked_32();	//$32:90d2();
		if (flag) { //bne $9fb5
$9fa9:			$9d = (~$9d + #f1);
		} else {
$9fb5:			$9d += 8;
		}
$9fbc:
		$9e = $7df8.x;	//x = index<<1
		a = (x << 1) + #60;
		x = a;	//x = index*4 + #60
		$0200.x = $9e;		//sprite.y
		$0201.x = $a3 + #3a;	//sprite.tileIndex
		$0202.x = #3;		//sprite.attr
		$0203.x = $9d;		//sprite.x
$9fde:
	}
$9fe3:
	return;
}
```


