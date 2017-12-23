
# $3d:a332 menu.party_summary.draw_content
> プレイヤーパーティのウインドウの内容を描画する。枠は描画しない。

### args:
+	yet to be investigated

### callers:
+	yet to be investigated

### local variables:
+	yet to be investigated

### notes:
write notes here

### (pseudo)code:
```js
{
/*
    ldx #$07    ; A332 A2 07
    jsr menu.get_window_content_metrics ; A334 20 A6 AA
    lda #$3B    ; A337 A9 3B
    jmp menu.draw_window_content    ; A339 4C 78 A6

*/
}
```

