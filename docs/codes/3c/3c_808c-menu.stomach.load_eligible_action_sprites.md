
# $3c:808c menu.stomach.load_eligible_action_sprites
> アイテムが利用可能(装備可能)なプレイヤーキャラを示すアクションのためのスプライトを全員分ロードする。

### args:
+	yet to be investigated

### callers:
+	`1E:B3BA:20 8C 80  JSR $808C`
+	`1E:B3F5:20 8C 80  JSR $808C`
+	`1E:B450:20 8C 80  JSR $808C`

### local variables:
+	yet to be investigated

### notes:
write notes here

### (pseudo)code:
```js
{
/*
    lda #$10    ; 808C A9 10
    sta <$40     ; 808E 85 40
    lda #$08    ; 8090 A9 08
    sta <$41     ; 8092 85 41
    jsr .L_80D9   ; 8094 20 D9 80
    lda #$A0    ; 8097 A9 A0
    sta <$40     ; 8099 85 40
    lda #$28    ; 809B A9 28
    sta <$41     ; 809D 85 41
    ldx #$00    ; 809F A2 00
    jsr .L_8136   ; 80A1 20 36 81
    lda #$B8    ; 80A4 A9 B8
    sta <$40     ; 80A6 85 40
    lda #$28    ; 80A8 A9 28
    sta <$41     ; 80AA 85 41
    ldx #$40    ; 80AC A2 40
    jsr .L_8136   ; 80AE 20 36 81
    lda #$D0    ; 80B1 A9 D0
    sta <$40     ; 80B3 85 40
    lda #$28    ; 80B5 A9 28
    sta <$41     ; 80B7 85 41
    ldx #$80    ; 80B9 A2 80
    jsr .L_8136   ; 80BB 20 36 81
    lda #$E8    ; 80BE A9 E8
    sta <$40     ; 80C0 85 40
    lda #$28    ; 80C2 A9 28
    sta <$41     ; 80C4 85 41
    ldx #$C0    ; 80C6 A2 C0
	jmp .L_8136   ; 80C8 4C 36 81
*/
}
```

