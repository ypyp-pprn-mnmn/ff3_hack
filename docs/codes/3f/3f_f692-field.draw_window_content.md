
# $3f:f692 field.draw_window_content
> render window content using tile (i.e., name table index) buffer at $0780-$07bf(inclusive).

### args:
+	in u8 A: text drawing disposition code.
	- 0x09: draw only lower line (skip upper line)
+	in,out u8 $f0: window scroll frame counter.

### callers:
+	`1F:EEE9:20 92 F6  JSR field::draw_window_content` @ $3f:eec0 field.draw_string_in_window
+	`1F:EF49:20 92 F6  JSR field::draw_window_content` @ $3f:eefa textd.draw_in_box
+	`1F:EFDE:20 92 F6  JSR field::draw_window_content` @ ? (sub routine of $eefa)
+	`1F:F48E:20 92 F6  JSR field::draw_window_content` @ $3f:f47a menu.erase_box_from_bottom

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


