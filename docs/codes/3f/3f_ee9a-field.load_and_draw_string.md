


# $3f:ee9a field::load_and_draw_string


### args:

#### in:
+	u8 $92: string_id
+	ptr $94: offset to string ptr table

#### out:
+	bool carry: more_to_draw	//flagged cases could be tested at サロニアの図書館(オーエンのほん1)
+	ptr $3e: offset to the string, assuming the bank it to be loaded is at 1st page (starting at $8000)
+	u8 $93: bank number which the string would be loaded from

### callers:
+	`1F:C036:20 9A EE  JSR field::load_and_draw_string`
+	`1F:EE65:20 9A EE  JSR field::load_and_draw_string` @ $3f:ee65 field::stream_string_in_window
+	`3c:9116  jmp $EE9A `   
+	`3d:a682  jmp $EE9A `

### code:
```js
{
	call_switch1stBank(per8k:a = #18); //ff06
	y = $92 << 1;
	if (carry) { //bcc eea7
		$95++;
	}
	$3e = $94[y];
	push (a = $94[++y] );
	$3f = a & #1f | #80;
	$93 = #18 + (pop a) >> 5;
$eec0:
}
```


**fall through**



