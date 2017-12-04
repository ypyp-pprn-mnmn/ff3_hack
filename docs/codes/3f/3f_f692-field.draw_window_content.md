

# $3f:f692 field.draw_window_content
> render window content using tile (i.e., name table index) buffer at $0780-$07bf(inclusive).

### args:
+	in u8 A: text drawing disposition code.
	- 0x09: draw only lower line (skip upper line)
+	in,out u8 $f0: window scroll frame counter.

### notes:
the disposition code 0x09 will be returned from `textd.draw_in_box` when char code 0x0a has encountered during processing.

### code:
```js
{
	push(a);
	waitNmiBySetHandler();	//$ff00
	$f0++;
	a = pop();
	field.upload_window_content();	//putWindowTiles();	//$f6aa
	field.sync_ppu_scroll();	//$ede1();
	field.callSoundDriver();
	call_switchFirst2Banks(per8kbank:a = $93);	//$ff03
	return field.init_window_tile_buffer();	//$f683()
$f6aa:
}
```





