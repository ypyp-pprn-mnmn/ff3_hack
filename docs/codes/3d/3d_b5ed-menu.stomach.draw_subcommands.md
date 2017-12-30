
# $3d:b5ed menu.stomach.draw_subcommands
> (デブチョコボの)メニュー画面のコマンドウインドウを描画する。

### args:
+	in u8 A: text_id

### callers:
+	`1E:B3A0:20 ED B5  JSR $B5ED` @ $3d:b383 menu.stomach.main

### local variables:
none.

### notes:
write notes here

### (pseudo)code:
```js
{
/*
    pha             ; B5ED 48
    ldx #$1B    ; B5EE A2 1B
    jsr menu.draw_window_box        ; B5F0 20 F1 AA
    pla             ; B5F3 68
	jmp menu.draw_window_content    ; B5F4 4C 78 A6
*/
}
```

