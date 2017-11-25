



# $3f:f8b0 ppud.update_sprites_and_palette_after_nmi
> awaits nmi, then updates sprites and palette.

### args:
+	@see [$3f:f897 ppud.up*load*_palette]

### code:
```js
{
	ppud.await_nmi_completion();	//$3f:fb80();
	ppud.do_sprite_dma();	//f8aa;
	ppud.upload_palette();	//$f897();
	return ppud.sync_registers_with_cache();	//f8cb
}
```






