
# $3f:ee65 field::stream_string_in_window:


### callers:
+	$3c:90ff	? 1E:9109:4C 65 EE  JMP $EE65
+	$3d:a666	? 1E:A675:4C 65 EE  JMP $EE65
+	$3f:ec83	? 1F:EC88:4C 65 EE  JMP $EE65
+	$3f:ec8b	? 1F:EC90:20 65 EE  JSR $EE65

### code:
```js
{
/*
 1F:EE65:20 9A EE  JSR field::load_and_draw_string
 1F:EE68:90 2F     BCC $EE99
	$ee6a:
	 1F:EE6A:20 AB EC  JSR field::await_and_get_new_input
	 1F:EE6D:A5 3D     LDA window_height = #$08
	$ee6f:
	 1F:EE6F:48        PHA
	 1F:EE70:A9 00     LDA #$00
	 1F:EE72:85 F0     STA field_frame_counter = #$13
	$ee74:
		 1F:EE74:20 D8 EC  JSR field::advance_frame
		 1F:EE77:A5 F0     LDA field_frame_counter = #$13
		 1F:EE79:29 01     AND #$01
		 1F:EE7B:D0 F7     BNE $EE74

	 1F:EE7D:20 A9 EB  JSR field::seek_to_next_line
	 1F:EE80:20 C0 EE  JSR floor::draw_encoded_string
	 1F:EE83:B0 0A     BCS $EE8F
		 1F:EE85:68        PLA
		 1F:EE86:38        SEC
		 1F:EE87:E9 02     SBC #$02
		 1F:EE89:F0 0E     BEQ $EE99
		 1F:EE8B:B0 E2     BCS $EE6F
		 1F:EE8D:90 0A     BCC $EE99
$ee8f:
	 1F:EE8F:68        PLA
	 1F:EE90:38        SEC
	 1F:EE91:E9 02     SBC #$02
	 1F:EE93:F0 D5     BEQ $EE6A
	 1F:EE95:B0 D8     BCS $EE6F
	 1F:EE97:90 D1     BCC $EE6A
$ee99:
 1F:EE99:60        RTS
*/
}
```



