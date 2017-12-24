

# $3d:a328 menu.party_summary.draw_window
> プレイヤーキャラ選択ウインドウ(type: 0x07)を描画する。

### args:
none.

### callers:
+	`1E:9778:20 28 A3  JSR menu.draw_pc_window`
+	`1E:9ECF:20 28 A3  JSR menu.draw_pc_window` @ $3c:9ec2 menu.items.main_loop

### local variables:
none.

### notes:
write notes here

### (pseudo)code:
```js
{
/*
    ldx #$07    ; A328 A2 07
    jsr menu.draw_window_box  ; A32A 20 F1 AA
    lda #$3B    ; A32D A9 3B
    jmp menu.draw_window_content   ; A32F 4C 78 A6
*/
}
```


