


# $3f:f8cb ppud.sync_registers_with_cache

### args:
-	in u8 $06: ppu ctrl cache
-	in u8 $09: ppu mask cache
-	in u8 $0c: bg scroll X
-	in u8 $0d: bg scroll Y

### code:
```js
{
	$2000 = $06;	//PPU ctrl1
	$2001 = $09;	//PPU ctrl2
	$2005 = $0c;	//VRAM addr1 (bg scroll.x)
	$2005 = $0d;	//VRAM addr1 (bg scroll.y)
	return;
}
```





