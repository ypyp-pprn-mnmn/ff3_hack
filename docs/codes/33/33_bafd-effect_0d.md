
# $33:bafd effect_0d

### args:
+	[in] u8 $7e9d : from actionParam[6]

### code:
```js
{
	y = $7e9d << 1;
	$7e,7f = $bc2b.y, $bc2c.y;
	callPtrOn$007e();	//$32:bb15();
	fill_A0hBytes_f0_at$0200();	//$32:a42b();
	setSpriteAndScroll();	//jmp $3f:f8c5
}
```


