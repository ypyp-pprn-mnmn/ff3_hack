

# $3f:ec8d field::show_window:


### callers:
+	`1F:E264:20 8D EC  JSR $EC8D`

### args:
+	u8 A : window_type

### code:
```js
{
/*
1F:EC8D:20 FA EC  JSR field::draw_inplace_window
1F:EC90:20 65 EE  JSR field::stream_string_in_window
1F:EC93:20 AB EC  JSR field::await_and_get_new_input
1F:EC96:A5 7D     LDA $007D = #$00
1F:EC98:F0 0E     BEQ $ECA8
	1F:EC9A:A5 20     LDA field::pad1_bits = #$00
	1F:EC9C:30 06     BMI $ECA4
		1F:EC9E:20 C4 EC  JSR field::get_next_input
		1F:ECA1:4C 9A EC  JMP $EC9A
		
		1F:ECA4:A9 00     LDA #$00
		1F:ECA6:85 7D     STA $007D = #$00
1F:ECA8:4C B6 C9  JMP $C9B6
*/
}
```



