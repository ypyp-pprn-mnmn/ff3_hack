
# $3f:f47a menu.erase_box_from_bottom
> short description of the function

### args:
+	u8 $38: box left
+	u8 $39: box top
+	u8 $3a: current x
+	u8 $3b: current y
+	u8 $3c: box width
+	u8 $3d: box height

### callers:
+	yet to be investigated

### local variables:
+	u8 $90: output buffer index
+	u8 $91: ?
+	u8 $0780[32]: tile buffer (upper line)
+	u8 $07a0[32]: tile buffer (lower line)

### notes:
write notes here

### (pseudo)code:
```js
{
/*
	pha				; F47A 48
	lda $3C         ; F47B A5 3C
	sta $90         ; F47D 85 90
	sta $91         ; F47F 85 91
	ldy #$1D        ; F481 A0 1D
	lda #$00        ; F483 A9 00
.l_F485:
	sta $0780,y     ; F485 99 80 07
	sta $07A0,y     ; F488 99 A0 07
	dey 			; F48B 88
	bpl .l_F485     ; F48C 10 F7
	jsr field.draw_window_content       ; F48E 20 92 F6
	lda $3B         ; F491 A5 3B
	sec 			; F493 38
	sbc #$04        ; F494 E9 04
	sta $3B         ; F496 85 3B
	pla 			; F498 68
	sec 			; F499 38
	sbc #$01        ; F49A E9 01
	bne .l_F47A     ; F49C D0 DC
	jmp restore_banks_by_$57            ; F49E 4C F5 EC
*/
}
```

