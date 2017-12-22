
# $3e:d336 field.clear_all_sprites
> スプライト属性のキャッシュを初期化し、すべてのスプライトを画面からクリアする。

### args:
none.

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
    jsr field.init_sprites_cache   		; D336 20 86 C4
    jsr thunk_await_nmi_by_set_handler  ; D339 20 00 FF
    lda #$02    						; D33C A9 02
    sta $4014   						; D33E 8D 14 40
    rts             					; D341 60
*/
$d342:
}
```

