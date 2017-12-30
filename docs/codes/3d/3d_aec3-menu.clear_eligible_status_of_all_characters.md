
# $3d:aec3 menu.clear_eligible_status_of_all_characters
> (メニュー内において)「装備可能」を示すステータス(bit0)をすべてのプレイヤーキャラについてクリアする。

### args:
+	in,out u8 $6102,$6142,$6182,$61c2: characters' status

### callers:
+	`1E:AED5:20 C3 AE  JSR menu.clear_eligible_status_of_`
+	`1E:AFCF:20 C3 AE  JSR menu.clear_eligible_status_of_`
+	`1E:AFEF:20 C3 AE  JSR menu.clear_eligible_status_of_`
+	`1E:B396:20 C3 AE  JSR menu.clear_eligible_status_of_` @$3d:b383 menu.stomach.main
+	`1E:B46E:20 C3 AE  JSR menu.clear_eligible_status_of_`

### local variables:
none.

### notes:
write notes here

### (pseudo)code:
```js
{
/*
.L_AEC3:
    ldx #$00    ; AEC3 A2 00
.L_AEC5:
		lda $6102,x ; AEC5 BD 02 61
		and #$FE    ; AEC8 29 FE
		sta $6102,x ; AECA 9D 02 61
		txa             ; AECD 8A
		clc             ; AECE 18
		adc #$40    ; AECF 69 40
		tax             ; AED1 AA
		bne .L_AEC5   ; AED2 D0 F1
	rts             ; AED4 60
*/
}
```

