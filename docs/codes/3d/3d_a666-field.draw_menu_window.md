

# $3d:a666 field.draw_menu_window
> 指定のタイプのウインドウを描画する。枠と中身の両方。

### args:
#### in:
+	u8 x : window_type
+   u8 a : text_id, specifies the text to be rendered in the window

#### local variables:
+   u8 $92: text_id will be given into `field.stream_String_in_window`
+   ptr $94: text_ptr_table = #$8200, will be given `field.stream_String_in_window`

### (pseudo)code:
```js
{
    push(A);
	field.draw_menu_window_box();
    $92 = A = pop();
    [$94,$95] = [0x00, 0x82];
    return field.stream_string_in_window();
/*
1E:A666:48        PHA
1E:A667:20 F1 AA  JSR field.draw_menu_window
1E:A66A:68        PLA
1E:A66B:85 92     STA $0092 = #$34
1E:A66D:A9 82     LDA #$82
1E:A66F:85 95     STA $0095 = #$82
1E:A671:A9 00     LDA #$00
1E:A673:85 94     STA $0094 = #$00
1E:A675:4C 65 EE  JMP field::stream_string_in_window
*/
}
```


**fall through**


