
# $3d:b619 menu.draw_item_select_window
> (各種メニュー内に)アイテム選択ウインドウを描画する。このウインドウは選択のみをサポートする。

### args:
+	in ptr $1c: pointer to text, buffer for scroll.
+	out ptr $3e: pointer to source text

### callers:
+	`1E:B13A:20 19 B6  JSR menu.draw_item_window`
+	`1E:B413:20 19 B6  JSR menu.draw_item_window` @ $3d:b383 menu.stomach.main
+	`1E:B48C:20 19 B6  JSR menu.draw_item_window` @ $3d:b383 menu.stomach.main

### local variables:
none.

### notes:
write notes here

### (pseudo)code:
```js
{
/*
    jsr menu.items.load_render_params   ; B619 20 75 90
    lda <$1C     ; B61C A5 1C
    sta <$3E     ; B61E 85 3E
    lda <$1D     ; B620 A5 1D
    sta <$3F     ; B622 85 3F
	jmp field.reflect_window_scroll ; B624 4C 61 EB
*/
}
```

