

# $3e:d20d field.queue_SE_of_valid_action
> バッドから入力されたアクションが有効であることを示す効果音をキューに入れる。

### args:
+	out u8 $7f49: sound effect id (= 0x05) and play flags (= 0x80: play new)

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
    lda #$85    ; D20D A9 85
    sta $7F49   ; D20F 8D 49 7F
    rts             ; D212 60
*/
}
```


