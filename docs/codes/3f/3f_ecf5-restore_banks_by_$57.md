
# $3f:ecf5 restore_banks_by_$57


## callers:
+	`1F:EB64:20 F5 EC  JSR field::restore_bank` @ $3f$eb61 field.update_item_window
+	field::draw_window_top (by falling thourgh)
+	`1F:ED53:4C F5 EC  JMP field::restore_bank_by_$57` @ field::draw_window_box
+	`1F:F49E:4C F5 EC  JMP field::restore_bank` @ ?
## code:
```js
{
	return call_switchFirst2Banks(per8k:a = $57);
}
```



