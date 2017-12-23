
# $3d:aa8e menu.items.erase_message
> 「アイテム」メニューのメッセージをウインドウごと消去する。

### args:
+	yet to be investigated

### callers:
+	$3c:9ec2 menu.items.main_loop

### local variables:
+	yet to be investigated

### notes:
write notes here

### (pseudo)code:
```js
{
/*
    jsr menu.erase_message_area ; AA8E 20 4B F4
    ldx #$06    ; AA91 A2 06
    jsr menu.draw_window_top   ; AA93 20 A0 AA
    ldx #$05    ; AA96 A2 05
    jsr menu.draw_window_box        ; AA98 20 F1 AA
    lda #$35    ; AA9B A9 35
    jmp menu.draw_window_content    ; AA9D 4C 78 A6
*/
}
```

