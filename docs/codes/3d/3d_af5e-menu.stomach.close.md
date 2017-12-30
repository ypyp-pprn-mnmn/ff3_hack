
# $3d:af5e menu.stomach.close
> デブチョコボのメニュー画面を閉じる。

### args:
none.

### callers:
+	`1E:B380:4C 5E AF  JMP $AF5E` @ $3d:b383 menu.stomach.main

### local variables:
+	u8 $50: ?, 0 on exit.

### notes:
write notes here

### (pseudo)code:
```js
{
/*
    jsr menu.accept_input_action    ; AF5E 20 74 8F
    lda #$00    ; AF61 A9 00
    sta <$50     ; AF63 85 50
	jmp menu.erase_entirely         ; AF65 4C 85 A6
*/
}
```

