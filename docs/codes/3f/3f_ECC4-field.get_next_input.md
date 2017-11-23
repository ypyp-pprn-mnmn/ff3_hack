
# $3f:ECC4 field::get_next_input:


### callers:
+	`1F:EC9E:20 C4 EC  JSR field::get_next_input`

### code:
```js
{
/*
	1F:ECC4:20 00 FF  JSR thunk_waitNmiBySetHandler
	1F:ECC7:E6 F0     INC field_frame_counter = #$EF
	1F:ECC9:20 50 C7  JSR field::call_sound_driver
	1F:ECCC:4C BD EC  JMP $ECBD
	1F:ECCF:A5 20     LDA field::pad1_bits = #$00
	1F:ECD1:85 21     STA $0021 = #$06
	1F:ECD3:A5 93     LDA field::bank_of_loaded_string = #$1B
	1F:ECD5:4C 03 FF  JMP call_switch_2banks
*/
}
``` 



