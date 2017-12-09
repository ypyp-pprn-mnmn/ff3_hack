


# $3d:a666 field.draw_menu_window
> 指定のタイプのウインドウを描画する。枠と中身の両方。

### args:
#### in:
+	u8 x : window_type
+   u8 a : text_id, specifies the text to be rendered in the window

### (pseudo)code:
```js
{
    push(A);
	field.draw_menu_window_box();   //$ed02
    return field.draw_menu_window_contents({text_id: A = pop()});  //fall through into $a66b.
/*
1E:A666:48        PHA
1E:A667:20 F1 AA  JSR field.draw_menu_window
1E:A66A:68        PLA
*/
}
```


**fall through**

