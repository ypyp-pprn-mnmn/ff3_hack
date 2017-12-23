
# $3c:8f74 menu.accept_input_action
> (AボタンまたはBボタンによって)プレイヤーが指示したアクションを受理し、効果音をキューに入れる。

### args:
+	out u8 $24: is 'A' button down (= 0)
+	out u8 $25: is 'B' button down (= 0)

### callers:
+	yet to be investigated

### local variables:
none.

### notes:
write notes here

### (pseudo)code:
```js
{
/*
    lda #$00    ; 8F74 A9 00
    sta <$24     ; 8F76 85 24
    sta <$25     ; 8F78 85 25
    jmp field.queue_SE_of_valid_action  ; 8F7A 4C 0D D2
*/
}
```

