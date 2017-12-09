

# $3d:a66b field.draw_menu_window_content
>(枠と背景は描画済みの)メニューのウインドウ内に指定のテキストを描画する。

### args:

#### in:
+   u8 a : text_id, specifies the text to be rendered in the window

### local variables:
+   u8 $92: text_id will be given into `field.stream_String_in_window`
+   ptr $94: text_ptr_table = #$8200, will be given into `field.stream_String_in_window`

### (pseudo)code:
```js
{
    $92 = A;
    [$94,$95] = [0x00, 0x82];
    return field.stream_string_in_window();	//$ee65
}
```


