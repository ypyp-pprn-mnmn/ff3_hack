
# $3f$eb61 field.reflect_window_scroll


## args:
+	[in] u8 $57: bank number to restore
+	[out] bool carry: always 0. (= scroll successful)
## callers:
+	`1E:9F92:20 61 EB  JSR field.reflect_item_window_scro`
+	`1E:A889:4C 61 EB  JMP field.reflect_item_window_scro`
+	`1E:B436:20 61 EB  JSR field.reflect_item_window_scro`
+	`1E:B616:4C 61 EB  JMP field.reflect_item_window_scro`
+	`1E:B624:4C 61 EB  JMP field.reflect_item_window_scro`
+	`1E:BC0F:4C 61 EB  JMP field.reflect_item_window_scro`
+	`1F:EB9F:4C 61 EB  JMP field.reflect_item_window_scroll` @ $3f$eb69 field.scrollup_item_window
## code:
```js
{
	field.draw_string_in_window();	//$eec0
	resotreBanksBy$57();	//$ecf5();
	clc;	//successfully scrolled the item window
	return;
$eb69:
}
```



