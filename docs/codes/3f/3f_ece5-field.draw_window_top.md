
# $3f:ece5 field::draw_window_top


### callers:
+	`1E:AAA3:4C E5 EC  JMP field::draw_window_top` @ ?

### notes:
called when executed an exchange of position in item window from menu

### code:
```js
{
//1F:ECE5:A5 39     LDA window_top = #$02
//1F:ECE7:85 3B     STA window_row_in_draw = #$04
//1F:ECE9:20 70 F6  JSR field::calc_size_and_init_buff
//1F:ECEC:20 56 ED  JSR field::init_window_attr_buffer
//1F:ECEF:20 F6 ED  JSR field::get_window_top_tiles
//1F:ECF2:20 C6 ED  JSR field::draw_window_row
}
```


**fall through**

