

# $3e:d529 menu.queue_SE_of_invalid_action
> アクションが無効であることを示す効果音をキューに入れる。

### args:
+	out u8 $7f49: sound effect id (= 0x06) and play flags (= 0x80: play new)

### callers:
+	yet to be investigated

### local variables:
none.

### notes:


### (pseudo)code:
```js
{
/*
    lda #$86    ; D529 A9 86
    sta $7F49   ; D52B 8D 49 7F
    rts             ; D52E 60
*/
}
```


