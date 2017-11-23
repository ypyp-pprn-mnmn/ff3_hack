
# $3e:c98f field::update_window_attr_buff


## args:
###
+	in u8 $37: skip_window_attr_update
+	in u8 $38: window_left (in 8x8)
+	in u8 $3b: window_row_in_draw (in 8x8)
+	in u8 $3c: window_width (in 8x8)
## code:
```js
{
	if ($37 == 0) { //bne c9b5
		$31 = $38 >> 1;
		$30 = $3b >> 1;
		$86 = $3c >> 1;
		$2d = 1;
		return field.merge_bg_attr_with_buff();	//$cab1();
	}
$c9a9:
}
```




