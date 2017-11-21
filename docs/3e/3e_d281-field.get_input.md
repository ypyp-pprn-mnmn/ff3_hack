
# $3e:d281 field::get_input


## args:
+	[out] u8 $20 : inputBits (bit7< A B select start up down left right >bit0)
## notes:
bitの配置が戦闘中のルーチンと逆
## code:
```js
{
	$4016 = 1; $4016 = 0;
	for (x = 8;x != 0;x--) {
		a = $4016 & 3;
		carry = (a < 1) ? 0 : 1
		rol $20;
	}
	return;
$d29a:
}
```




