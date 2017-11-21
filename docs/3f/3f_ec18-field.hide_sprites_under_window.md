
# $3f:ec18 field::hide_sprites_under_window


## args:
+	[in]	u8 X: window_type (0...4)
## callers:
+	$3f$ed61 field::get_window_region
## code:
```js
{
// 1F:EC18:A9 00     LDA #$00
	return field.showhide_sprites_by_region(A = 0);	//fall through
}
```


**fall through**

