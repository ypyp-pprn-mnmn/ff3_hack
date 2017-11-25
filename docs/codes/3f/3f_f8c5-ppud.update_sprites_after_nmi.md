


# $3f:f8c5 ppud.update_sprites_after_nmi

### args:
-	in u8 $06: ppu ctrl cache
-	in u8 $09: ppu mask cache
-	in u8 $0c: bg scroll X
-	in u8 $0d: bg scroll Y

### code:
```js
{
	ppud.await_nmi_completion();	//$fb80
	ppud.do_sprite_dma();	//$f8aa
$f8cb:
	return ppud.sync_registers_with_cache();	//fall thorough.
}
```

**fall through**




