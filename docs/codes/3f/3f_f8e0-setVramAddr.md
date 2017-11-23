
# $3f:f8e0 setVramAddr {


### args:
+	[in] u8 a : addr(high byte)
+	[in] u8 x : addr(low byte)

### code:
```js
{
	bit $2002;	//PPU status
	$2006 = a;	//VRAM addr2
	$2006 = x;
}
```



