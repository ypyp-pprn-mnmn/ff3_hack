
# $3e:d308 field.upload_all_palette_entries
> キャッシュ用のバッファからBG用とスプライト用の両方のパレットの色データをVRAMへアップロードする。

### args:
+   in NesColors $03c0[8]: palette entries, which each has 4 color indexes.

### callers:
(15 callers found so far, including the below)

+   `1E:B390:20 08 D3  JSR field.upload_all_palette_entri` @ $3d:b383 menu.stomach.main

### notes:
this function is very similar to `$3e:d381 field.upload_bg_palette`.
the difference is that this function:
a) uploads for both BG and sprites,
b) uploads data from $03c0 (the other does it from $03f0)

### code:
```js
{
/*
    lda $2002   ; D308 AD 02 20
    lda #$3F    ; D30B A9 3F
    sta $2006   ; D30D 8D 06 20
    lda #$00    ; D310 A9 00
    sta $2006   ; D312 8D 06 20
    ldx #$00    ; D315 A2 00
.L_D317:
        lda $03C0,x ; D317 BD C0 03
        sta $2007   ; D31A 8D 07 20
        inx             ; D31D E8
        cpx #$20    ; D31E E0 20
        bcc .L_D317   ; D320 90 F5
    lda $2002   ; D322 AD 02 20
    lda #$3F    ; D325 A9 3F
    sta $2006   ; D327 8D 06 20
    lda #$00    ; D32A A9 00
    sta $2006   ; D32C 8D 06 20
    sta $2006   ; D32F 8D 06 20
    sta $2006   ; D332 8D 06 20
    rts             ; D335 60
*/
$d336:
}
```

