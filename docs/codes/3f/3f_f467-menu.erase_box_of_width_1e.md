

# $3f:f467 menu.erase_box_of_width_1e
> short description of the function

### args:
+	in u8 A: box height.

### callers:
+	`1E:9BD2:20 67 F4  JSR $F467` @ ?

### local variables:
+	u8 $38: box left
+	u8 $39: box top
+	u8 $3a: current x
+	u8 $3b: current y
+	u8 $3c: box width
+	u8 $3d: box height

### notes:
write notes here

### (pseudo)code:
```js
{
/*
.l_F467:
	sta $3D         ; F467 85 3D
	lda #$1B        ; F469 A9 1B
	sta $39         ; F46B 85 39
	sta $3B         ; F46D 85 3B
	lda #$01        ; F46F A9 01
	sta $38         ; F471 85 38
	lda #$1E        ; F473 A9 1E
	sta $3c         ; F475 85 3C
	lda $3d			; F477 A5 3D
	lsr a           ; F479 4A
.l_F47A:
*/
}
```

**fall through**


