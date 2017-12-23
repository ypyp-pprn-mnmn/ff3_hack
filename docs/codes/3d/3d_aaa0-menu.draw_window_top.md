
# $3d:aaa0 menu.draw_window_top
> 指定のメニューウインドウの上の枠だけ描画する。

### args:
+	in u8 X: window_id

### callers:
+	$3d:aa8e menu.items.erase_message
+	yet to be investigated

### local variables:
none.

### notes:
write notes here

### (pseudo)code:
```js
{
/*
    jsr menu.get_window_metrics     ; AAA0 20 BC AA
    jmp field.draw_window_top       ; AAA3 4C E5 EC
*/
}
```

