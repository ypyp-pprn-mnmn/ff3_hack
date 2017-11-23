
# $3f:f692 field.draw_window_content


## code:
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




