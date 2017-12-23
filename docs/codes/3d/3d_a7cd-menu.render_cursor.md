
# $3d:a7cd menu.render_cursor
> 次のNMIにあわせて、カーソルを描画する。

### args:
+	u8 $26: sprite index
+	u8 $37: in_menu_mode

+	u8 $b4: ?
+	u8 $b5: ? left part of cursor, y (-> $0200 + x)
+	u8 $b6: ? left part of cursor, x (-> $0203 + x)
+	u8 $b7: ? right part of cursor, y (-> $0204 + x)
+	u8 $b8: ? right part of cursor, x (-> $0207 + x)

+	u8 $f0: frame counter

### callers:
+	yet to be investigated

### local variables:
+	yet to be investigated

### notes:
write notes here

### (pseudo)code:
```js
{
/*
.L_A7CD:
  	jsr thunk_await_nmi_by_set_handler  ; A7CD 20 00 FF
    lda #$02    ; A7D0 A9 02
    sta $4014   ; A7D2 8D 14 40
    inc <$F0     ; A7D5 E6 F0
    jsr .L_C758   ; A7D7 20 58 C7
    jsr field.init_sprites_cache    ; A7DA 20 86 C4
    jsr .L_9119   ; A7DD 20 19 91
    jsr .L_912A   ; A7E0 20 2A 91
    jsr .L_914C   ; A7E3 20 4C 91
    ldx <$26     ; A7E6 A6 26
    bit <$B4     ; A7E8 24 B4
    bvc .L_A810   ; A7EA 50 24
    lda <$B5     ; A7EC A5 B5
    asl a       ; A7EE 0A
    asl a       ; A7EF 0A
    asl a       ; A7F0 0A
    sta $0200,x ; A7F1 9D 00 02
    lda #$E8    ; A7F4 A9 E8
    sta $0201,x ; A7F6 9D 01 02
    lda #$83    ; A7F9 A9 83
    ldy <$37     ; A7FB A4 37
    bne .L_A801   ; A7FD D0 02
    lda #$80    ; A7FF A9 80
.L_A801:
  	sta $0202,x ; A801 9D 02 02
    lda <$B6     ; A804 A5 B6
    asl a       ; A806 0A
    asl a       ; A807 0A
    asl a       ; A808 0A
    sta $0203,x ; A809 9D 03 02
    inx             ; A80C E8
    inx             ; A80D E8
    inx             ; A80E E8
    inx             ; A80F E8
.L_A810:
  	bit <$B4     ; A810 24 B4
    bpl .L_A838   ; A812 10 24
    lda <$B7     ; A814 A5 B7
    asl a       ; A816 0A
    asl a       ; A817 0A
    asl a       ; A818 0A
    sta $0200,x ; A819 9D 00 02
    lda #$E8    ; A81C A9 E8
    sta $0201,x ; A81E 9D 01 02
    lda #$03    ; A821 A9 03
    ldy <$37     ; A823 A4 37
    bne .L_A829   ; A825 D0 02
    lda #$00    ; A827 A9 00
.L_A829:
  	sta $0202,x ; A829 9D 02 02
    lda <$B8     ; A82C A5 B8
    asl a       ; A82E 0A
    asl a       ; A82F 0A
    asl a       ; A830 0A
    sta $0203,x ; A831 9D 03 02
    inx             ; A834 E8
    inx             ; A835 E8
    inx             ; A836 E8
    inx             ; A837 E8
.L_A838:
  stx <$26     ; A838 86 26
    rts             ; A83A 60
*/
$a83b:
}
```

