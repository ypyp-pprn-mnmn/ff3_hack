
# $3f:edc6 field::draw_window_row


### code:
```js
{
	$90 = $3c;
	field.update_window_attr_buff();	//$c98f();
	waitNmiBySetHandler();	//$ff00();
	$4014 = 2;
	field.upload_window_content();	//$f6aa();
	field.set_bg_attr_for_window();	//$c9a9();
	field.sync_ppu_scroll();	//$ede1();
	return field.callSoundDriver();
$ede1:
}
```



