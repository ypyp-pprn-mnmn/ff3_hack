
# $3d:a678 menu.draw_window_content
> (枠と背景は描画済みの)メニューのウインドウ内に指定のテキストをウインドウに収まる限りで描画する。

### args:
+	in u8 A: menu_text_id, specifies the text to be rendered in the window.
	pointer table for the text is based on $8200.

### callers: (25 calls found so far)
+   `1E:A32F:4C 78 A6  JMP menu.draw_window_content`
+   `1E:A339:4C 78 A6  JMP menu.draw_window_content`
+   `1E:A99D:4C 78 A6  JMP menu.draw_window_content`
+   `1E:AA9D:4C 78 A6  JMP menu.draw_window_content`
+   `1E:B1F9:4C 78 A6  JMP menu.draw_window_content`
+   `1E:B213:4C 78 A6  JMP menu.draw_window_content`
+   `1E:B21D:4C 78 A6  JMP menu.draw_window_content`
+   `1E:B5F4:4C 78 A6  JMP menu.draw_window_content`
+   `1E:BC00:4C 78 A6  JMP menu.draw_window_content`
+   `1E:9656:20 78 A6  JSR menu.draw_window_content`
+   `1E:9C11:20 78 A6  JSR menu.draw_window_content`
+   `1E:9E38:20 78 A6  JSR menu.draw_window_content`
+   `1E:9EE8:20 78 A6  JSR menu.draw_window_content`
+   `1E:A082:20 78 A6  JSR menu.draw_window_content`
+   `1E:A168:20 78 A6  JSR menu.draw_window_content`
+   `1E:A2FD:20 78 A6  JSR menu.draw_window_content`
+   `1E:AF73:20 78 A6  JSR menu.draw_window_content`
+   `1E:AFCC:20 78 A6  JSR menu.draw_window_content`
+   `1E:B014:20 78 A6  JSR menu.draw_window_content`
+   `1E:B0F2:20 78 A6  JSR menu.draw_window_content`
+   `1E:B206:20 78 A6  JSR menu.draw_window_content`
+   `1E:B3E3:20 78 A6  JSR menu.draw_window_content`
+   `1E:B601:20 78 A6  JSR menu.draw_window_content`
+   `1E:B8A7:20 78 A6  JSR menu.draw_window_content`
+   `1E:BBF6:20 78 A6  JSR menu.draw_window_content`

### local variables:
+   u8 $92: text_id will be given into `field.stream_String_in_window`
+   ptr $94: text_ptr_table = #$8200, will be given into `field.stream_String_in_window`

### notes:
this logic is very similar to `$3d:a66b menu.stream_window_content`.
The only difference is that unlike the other one, this logic _DON'T_ handle paging.

### (pseudo)code:
```js
{
/*
    sta <$92    	; A678 85 92
    lda #$82    	; A67A A9 82
    sta <$95     	; A67C 85 95
    lda #$00    	; A67E A9 00
    sta <$94     	; A680 85 94
    jmp field.load_and_draw_string  ; A682 4C 9A EE
*/
}
```

