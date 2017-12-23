
# $3d:a87a menu.draw_view_of_buffered_string
> 指定のテキストをバッファ($7b00)にロードした上で、(枠と背景は描画済みの)ウインドウ内にスクロールを考慮の上で描画する。

### args:
+	in u8 A: text_id (pointer table at $8200)

### (pseudo)code:
```js
{
	field.load_label_text_into_buffer();	//$d1b1();
	$93 = 0x18;
	[$3f,$3e] = [0x7b, 0x01];
	return field.reflect_window_scroll();	//$eb61();
/*
field.loadAndDrawString:
    jsr field.load_label_text_into_buffer; A87A 20 B1 D1
    lda #$18    ; A87D A9 18
    sta <$93     ; A87F 85 93
    lda #$01    ; A881 A9 01
    sta <$3E     ; A883 85 3E
    lda #$7B    ; A885 A9 7B
    sta <$3F     ; A887 85 3F
    jmp field.reflect_window_scroll ; A889 4C 61 EB
*/
$a88c:
}
```


