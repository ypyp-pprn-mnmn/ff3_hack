
# $3d:b4ae menu.stomach.store_item
> デブチョコボにアイテムを預ける。

### args:
+	in u8 $7af0: byte offset into selected item in the menu.
+	in MenuItem $7a00[]
+	in,out u8 $60c0[0x20]: IDs of items in backpack
+	in,out u8 $60e0[0x20]: amounts of items in backpack

### callers:
+	`1E:B40E:20 AE B4  JSR menu.stomach.store_item` @ $3d:b383 menu.stomach.main

### local variables:
+	u8 $80: amount of item to be stored
+	u8 $8e: index (in backpatk) of item to be stored

### notes:
write notes here

### (pseudo)code:
```js
{
/*
    ldx $7AF0   ; B4AE AE F0 7A
	lda $7A02,x ; B4B1 BD 02 7A
	;;0x0F == CHAR.DUSTBOX
    cmp #$0F    ; B4B4 C9 0F
    beq .L_B4C3   ; B4B6 F0 0B
    lda $7A03,x ; B4B8 BD 03 7A
    sta <$8E     ; B4BB 85 8E
    tax             ; B4BD AA
    lda $60C0,x ; B4BE BD C0 60
    bne .L_B4C8   ; B4C1 D0 05
.L_B4C3:
    jsr menu.queue_SE_of_invalid_action ; B4C3 20 29 D5
    sec             ; B4C6 38
    rts             ; B4C7 60
; ----------------------------------------------------------------------------
.L_B4C8:
    cmp #$9A    ; B4C8 C9 9A
    bcc .L_B4D0   ; B4CA 90 04
    cmp #$A4    ; B4CC C9 A4
    bcc .L_B4C3   ; B4CE 90 F3
.L_B4D0:
    tay             ; B4D0 A8
    lda #$00    ; B4D1 A9 00
    sta <$80     ; B4D3 85 80
    lda $6300,y ; B4D5 B9 00 63
    cmp #$63    ; B4D8 C9 63
    bcc .L_B4E3   ; B4DA 90 07
        lda #$55    ; B4DC A9 55
        jsr menu.stomach.draw_message   ; B4DE 20 F7 B5
        clc             ; B4E1 18
        rts             ; B4E2 60
; ----------------------------------------------------------------------------
.L_B4E3:
    adc $60E0,x ; B4E3 7D E0 60
    cmp #$64    ; B4E6 C9 64
    bcc .L_B4F0   ; B4E8 90 06
    sbc #$63    ; B4EA E9 63
    sta <$80     ; B4EC 85 80
    lda #$63    ; B4EE A9 63
.L_B4F0:
    sta $6300,y ; B4F0 99 00 63
    lda <$80     ; B4F3 A5 80
    sta $60E0,x ; B4F5 9D E0 60
    bne .L_B4FD   ; B4F8 D0 03
    sta $60C0,x ; B4FA 9D C0 60
.L_B4FD:
    lda #$54    ; B4FD A9 54
    jsr menu.stomach.draw_message   ; B4FF 20 F7 B5
    clc             ; B502 18
    rts             ; B503 60
*/
}
```

