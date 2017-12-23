
# $3d:a996 menu.savefile.draw_message
> セーブメニューのメッセージ(右上のウインドウ)をウインドウごと描画する。

### args:
+	in u8 A: text_id of message to draw

### callers:
+	$3d:a984 menu.savefile.build_menu

### local variables:
none.

### notes:
write notes here

### (pseudo)code:
```js
{
/*
    pha             ; A996 48
    ldx #$10    ; A997 A2 10
    jsr menu.draw_window_box        ; A999 20 F1 AA
    pla             ; A99C 68
    jmp menu.draw_window_content    ; A99D 4C 78 A6
*/
}
```

