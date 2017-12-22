
# $3d:a66b menu.stream_window_content
>(枠と背景は描画済みの)メニューのウインドウ内に指定のテキストをテキストの終了まで描画する。

### args:

#### in:
+   u8 a : text_id, specifies the text to be rendered in the window

### callers:
+   `1E:96EE:20 6B A6  JSR menu.stream_window_content`
+   `1E:98C2:20 6B A6  JSR menu.stream_window_content`
+   `1E:98DC:20 6B A6  JSR menu.stream_window_content`
+   `1E:9EF8:20 6B A6  JSR menu.stream_window_content`
+   `1E:A98B:20 6B A6  JSR menu.stream_window_content`
+   `1E:A9F4:20 6B A6  JSR menu.stream_window_content`
+   `1E:AA81:20 6B A6  JSR menu.stream_window_content`
+   `1E:A872:4C 6B A6  JMP menu.stream_window_content`

### local variables:
+   u8 $92: text_id will be given into `field.stream_String_in_window`
+   ptr $94: text_ptr_table = #$8200, will be given into `field.stream_String_in_window`

### notes:
this logic is very similar to `$3d:a678 menu.draw_window_content`.
The only difference is that unlike the other one, this logic _DOES_ handle paging.

### (pseudo)code:
```js
{
    $92 = A;
    [$94,$95] = [0x00, 0x82];
    return field.stream_string_in_window();	//$ee65
}
```



