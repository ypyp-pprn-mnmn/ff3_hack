
# $3e:d213 field.queue_SE_of_move_of_cursor
> カーソル移動を示す効果音をキューに入れる。

### args:
+	out u8 $7f49: sound effect id (= 0x98)

### callers:
+	yet to be investigated

### local variables:
none.

### notes:
coceptually, this logic does 'feedback_move_of_cursor'.

### (pseudo)code:
```js
{
/*
	;; beep.
    lda #$98    ; D213 A9 98
    sta $7F49   ; D215 8D 49 7F
    rts         ; D218 60
*/
}
```

