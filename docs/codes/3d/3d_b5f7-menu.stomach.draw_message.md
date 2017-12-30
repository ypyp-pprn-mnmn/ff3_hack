
# $3d:b5f7 menu.stomach.draw_message
> (デブチョコボの)メニュー画面にメッセージを描画する。

### args:
+	in u8 A: text_id

### callers:
+	`1E:B39B:20 F7 B5  JSR $B5F7` @ $3d:b383 menu.stomach.main
+	`1E:B3D5:20 F7 B5  JSR $B5F7`
+	`1E:B41B:20 F7 B5  JSR $B5F7`
+	`1E:B4DE:20 F7 B5  JSR $B5F7`
+	`1E:B4FF:20 F7 B5  JSR $B5F7`
+	`1E:B528:20 F7 B5  JSR $B5F7`
+	`1E:B549:20 F7 B5  JSR $B5F7`
+	`1E:B56B:20 F7 B5  JSR $B5F7`

### local variables:
none.

### notes:
write notes here

### (pseudo)code:
```js
{
/*
    pha             ; B5F7 48
    jsr menu.party_summary.save_render_params; B5F8 20 A8 A3
    ldx #$1A    ; B5FB A2 1A
    jsr menu.draw_window_box        ; B5FD 20 F1 AA
    pla             ; B600 68
    jsr menu.draw_window_content    ; B601 20 78 A6
	jmp menu.party_summary.load_render_params; B604 4C 8E A3
*/
}
```

