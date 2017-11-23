
# $3f:eec0 field.draw_string_in_window


### args:
+	[in] ptr $3e : string offset
+	[in] u8 $93 : string bank
+	[out] bool carry: more_to_draw

### code:
```js
{
	call_switchFirst2Banks(per8k:a = $93);
	$1e = 0;
	$1c,1d = $3e,3f;
$eed1:
	$1d = a;
	$3a = $38;
	$3b = $39;
	$f670();	//field_calc_draw_width_and_init_window_tile_buffer
	$1f = $90 = #0;
	field.eval_and_draw_string();	//$eefa();
	if (!carry) { //eef3
		field.draw_window_content();	//$f692();
		call_switchFirst2Banks(per8k:a = $57);
$eef1:
		clc;
		return;
	}
$eef3:
	call_switchFirst2Banks(per8k:a = $57);
	sec;
	return;
}
```




