

# $3d:b369 menu.init_ppu
> PPUの各レジスタを初期化し、制御フラグのキャッシュ(at $fd, $ff)にも設定する。

### args:
+	out u8 $fd: ppu ctrl cache?
+	out u8 $ff: ppu ctrl cache.

### callers:
+	`1E:AF44:20 69 B3  JSR $B369`
+	`1E:B393:20 69 B3  JSR $B369` @ $3d:b383 menu.stomach.main

### local variables:
none.

### notes:
this function is very similar to `$3c:959f menu.reset_ppu`.
the other one doesn't set internal cache values ($fd, $ff)

### (pseudo)code:
```js
{
/*.L_B369:
    lda #$88    ; B369 A9 88
    sta <$FD    ; B36B 85 FD
    sta <$FF    ; B36D 85 FF
    sta $2000   ; B36F 8D 00 20
    lda #$00    ; B372 A9 00
    sta $2005   ; B374 8D 05 20
    sta $2005   ; B377 8D 05 20
    lda #$1E    ; B37A A9 1E
    sta $2001   ; B37C 8D 01 20
	rts         ; B37F 60
*/
}
```


