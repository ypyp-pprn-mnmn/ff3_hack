
# $3d:a363 menu.items.clone_for_2nd_selection
> 「アイテム」メニュー($7a00で管理)の2回目の選択処理のために、X方向にシフトしたクローンを$7900に生成する。

### args:
+	in MenuItem $7a00[0x21]: 'item' menu-items
+	in u8 $7af1: byte offset of the end of menu-item in the view (of $7a00)
+	out MenuItem $7900[0x21]: cloned menu-items, with right-shifted X by 1
+	out u8 $79f1: byte offset of the end of menu-item in the view (of $7900, set to $7af1 on ext)

### callers:
+	$3c:9ec2 menu.items.main_loop
+	yet to be investigated

### local variables:
none.

### notes:
write notes here

### (pseudo)code:
```js
{
/*
    ldx #$80    ; A363 A2 80
.L_A365:
		lda $7A00,x ; A365 BD 00 7A
		clc             ; A368 18
		adc #$01    ; A369 69 01
		sta $7900,x ; A36B 9D 00 79
		lda $7A01,x ; A36E BD 01 7A
		sta $7901,x ; A371 9D 01 79
		lda $7A02,x ; A374 BD 02 7A
		sta $7902,x ; A377 9D 02 79
		lda $7A03,x ; A37A BD 03 7A
		sta $7903,x ; A37D 9D 03 79
		txa             ; A380 8A
		sec             ; A381 38
		sbc #$04    ; A382 E9 04
		tax             ; A384 AA
		bcs .L_A365   ; A385 B0 DE
    lda $7AF1   ; A387 AD F1 7A
    sta $79F1   ; A38A 8D F1 79
    rts             ; A38D 60
*/
}
```

