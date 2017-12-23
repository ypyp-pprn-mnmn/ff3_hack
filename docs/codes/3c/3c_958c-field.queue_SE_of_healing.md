
# $3c:958c field.queue_SE_of_healing
> 回復したことを示す効果音をキューにいれる。

### args:
+	out u8 $7f49: sound effect id (= 0x3d) and play flags (= 0x80: play)

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
    lda #$DD    ; 958C A9 DD
    sta $7F49   ; 958E 8D 49 7F
    rts         ; 9591 60
*/
}
```

