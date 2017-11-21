
# $3f:ECAB field::await_and_get_new_input:


## callers:
+	 `1F:EC93:20 AB EC  JSR field::await_and_get_new_input` ($3f:ec8b field::show_message_window)
+	 `1F:ECBA:4C AB EC  JMP field::await_and_get_new_input` (tail recursion)
+	 `1F:EE6A:20 AB EC  JSR field::await_and_get_new_input` ($3f:ee65 field::stream_string_in_window)
## code:
```js
{
/*
	1F:ECAB:20 81 D2  JSR field::get_pad_input
	1F:ECAE:A5 20     LDA field::pad1_bits = #$00
	1F:ECB0:F0 0B     BEQ $ECBD
	1F:ECB2:20 00 FF  JSR thunk_waitNmiBySetHandler
	1F:ECB5:E6 F0     INC field_frame_counter = #$EF
	1F:ECB7:20 50 C7  JSR field::call_sound_driver
	1F:ECBA:4C AB EC  JMP field::await_and_get_new_input
*/
}
```



