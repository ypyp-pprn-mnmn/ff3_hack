
# $3d:a33c menu.items.consume_item
> 「アイテム」メニューから利用したアイテムを消費する。

### args:
+	in u8 X: index (in backpack) of item that has just used
+	out u8 $60c0[X]: item id, cleared to 0 if amount reached to 0
+	out u8 $60e0[X]: amount of item, that has just used.

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
    ldx <$63     ; A33C A6 63
    dec $60E0,x ; A33E DE E0 60
    bne .L_A348   ; A341 D0 05
    lda #$00    ; A343 A9 00
    sta $60C0,x ; A345 9D C0 60
.L_A348:
  	rts             ; A348 60
*/
}
```

