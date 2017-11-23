
# $3f:ecd8 field::advance_frame_with_sound


## callers:
+	 `1F:EE74:20 D8 EC  JSR field::advance_frame_w_sound` ($3f:ee65 field::stream_string_in_window)
## code:
```js
{
//field::advance_frame_w_sound:
// 1F:ECD8:20 00 FF  JSR thunk_waitNmiBySetHandler
// 1F:ECDB:E6 F0     INC field_frame_counter = #$E8
// 1F:ECDD:20 50 C7  JSR field::call_sound_driver
// 1F:ECE0:A5 93     LDA $0093 = #$1B
// 1F:ECE2:4C 03 FF  JMP call_switch_2banks
$ece5:
}
```




