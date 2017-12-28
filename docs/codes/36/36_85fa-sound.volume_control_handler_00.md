
# $36:85fa sound.volume_control_handler_00
> short description of the function

### args:
+	in u8 $d0: track #
+	in u8 $d2: ?, some ctrl flags
+	in ptr $d8: some pointer value dereferenced by $9a7c[indexed by $7fc1]
+	out u8 $7f7b[7]: volume controls for each track
+	in u8 $7f90[7]: ?, index of volume control pattern?
+	in,out u8 $7fba[7]: ?
+	in,out u8 $7fc8[7]: ?, some index, incremented by 1 after read of a value pointed to by $d8.
+	in,out u8 $7fe4[7]: ?, phase of volumne control pattern?

### callers:
+	$36:8595 sound.apply_volume_effects

### local variables:
+	none.

### static references:
+	$8825[0xff?]:

		8825	00000000000000000000000000000000
		8835	00000000000000000000000000000001
		8845	00000000000000000101010101010102
		8855	00000000000101010101020202020203
		8865	00000000010101010202020203030304
		8875	00000001010102020203030304040405
		8885	00000001010202020303040404050506
		8895	00000001010202030304040505060607
		88a5	00000101020203030404050506060708
		88b5	00000101020303040405060607070809
		88c5	0000010202030404050606070808090A
		88d5	00000102020304050506070808090A0B
		88e5	000001020304040506070808090A0B0C
		88f5	0000010203040506060708090A0B0C0D
		8905	00000102030405060708090A0B0C0D0E
		8915	000102030405060708090A0B0C0D0E0F


### notes:
write notes here

### (pseudo)code:
```js
{
	x = $d0;
	y = $7fc8.x
	$7fe4.x = $d8[y]
	$7fc8.x++;
	if ($d8[++y] < 0) {
		$7fba.x++;
		$7fc8.x = 0;
	}
$8614:
	y = ($7f90.x << 4) | $7fe4.x;
	if ($d2 == 0) {
		y = ($7f44 << 4) | $8825.y;
	}
$862e:
	$7f7b.x = $8825.y;
	return;
$8635:
/*
    ldx <$D0     ; 85FA A6 D0
    ldy $7FC8,x ; 85FC BC C8 7F
    lda [$d8],y ; 85FF B1 D8
    sta $7FE4,x ; 8601 9D E4 7F
    inc $7FC8,x ; 8604 FE C8 7F
    iny             ; 8607 C8
    lda [$D8],y ; 8608 B1 D8
    bpl .L_8614   ; 860A 10 08
        inc $7FBA,x ; 860C FE BA 7F
        lda #$00    ; 860F A9 00
        sta $7FC8,x ; 8611 9D C8 7F
.L_8614:
    lda $7F90,x ; 8614 BD 90 7F
    asl a       ; 8617 0A
    asl a       ; 8618 0A
    asl a       ; 8619 0A
    asl a       ; 861A 0A
    ora $7FE4,x ; 861B 1D E4 7F
    tay             ; 861E A8
    lda <$D2     ; 861F A5 D2
    bne .L_862E   ; 8621 D0 0B
		;; music
        lda $7F44   ; 8623 AD 44 7F
        asl a       ; 8626 0A
        asl a       ; 8627 0A
        asl a       ; 8628 0A
        asl a       ; 8629 0A
        ora .L_8825,y ; 862A 19 25 88
        tay             ; 862D A8
.L_862E:
	;; effect
    lda .L_8825,y ; 862E B9 25 88
    sta $7F7B,x ; 8631 9D 7B 7F
    rts             ; 8634 60
*/
}
```

