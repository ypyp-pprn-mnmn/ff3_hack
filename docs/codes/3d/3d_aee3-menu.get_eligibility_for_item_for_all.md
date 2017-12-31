

# $3d:aee3 menu.get_eligibility_for_item_for_all
> 指定したアイテムの装備可能フラグを取得し、各プレイヤーキャラクターのステータスに反映する。

### args:
+	in u8 A: item_id
+	out u8 $6102, $6142, $6182, $61c2: status of player characters. bit0 = eligibilty, in context of menu-mode.

### callers:
+	`jsr .L_AEE3   ; B49F 20 E3 AE` @ $3d:b492 menu.stomach.get_eligibility_for_all_characters
+   `lda $7B80,x ; AEE0 BD 80 7B` (fall through) @ $3d:aed5 menu.shop.update_eligibility_for_item

### local variables:
+	yet to be investigated

### notes:
write notes here

### (pseudo)code:
```js
{
/*
    jsr .L_D113   ; AEE3 20 13 D1
    lda <$80     ; AEE6 A5 80
    and #$08    ; AEE8 29 08
    bne .L_AEF4   ; AEEA D0 08
    lda $6102   ; AEEC AD 02 61
    ora #$01    ; AEEF 09 01
    sta $6102   ; AEF1 8D 02 61
.L_AEF4:
    lda <$80     ; AEF4 A5 80
    and #$04    ; AEF6 29 04
    bne .L_AF02   ; AEF8 D0 08
    lda $6142   ; AEFA AD 42 61
    ora #$01    ; AEFD 09 01
    sta $6142   ; AEFF 8D 42 61
.L_AF02:
    lda <$80     ; AF02 A5 80
    and #$02    ; AF04 29 02
    bne .L_AF10   ; AF06 D0 08
    lda $6182   ; AF08 AD 82 61
    ora #$01    ; AF0B 09 01
    sta $6182   ; AF0D 8D 82 61
.L_AF10:
    lda <$80     ; AF10 A5 80
    and #$01    ; AF12 29 01
    bne .L_AF1E   ; AF14 D0 08
    lda $61C2   ; AF16 AD C2 61
    ora #$01    ; AF19 09 01
    sta $61C2   ; AF1B 8D C2 61
.L_AF1E:
    rts             ; AF1E 60
*/
}
```



