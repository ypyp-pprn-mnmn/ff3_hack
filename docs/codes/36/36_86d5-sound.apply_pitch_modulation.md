

# $36:86d5 sound.apply_pitch_modulation
> short description of the function

### args:
+	in u8 $d0: track #
+	in u8 $d2: ?, some ctrl flags
+	in PitchModulation* $d8: pointer value dereferenced by $9aeb[indexed by $7feb], pointing to stream of 2-byte entires

```cpp
struct PitchModulation {
	s8 timer_counter;	//00: nop, positive: counter, negative: back
	s8 adjustment;	//will be fed into lower byte of the pitch timer
};
```

+	in,out u8 $7f6d[7]: note pitch timers, low.
+	in u8 $7feb[7]: pitch modulation type, used to index $9aeb
+	in,out u8 $7ff2[7]: next index of pitch modulation curve, the stream pointed to by $d8.
	- negative byte directs this counter to 'back' position.
	- on exit, points to next byte of the stream.
+	in,out u8 $7ff9[7]: timer counter, command byte fetched from the stream pointed to by $d8.

### callers:
+	$36:857d sound.apply_effecters

### local variables:
none.

### static references:
+	PitchModulation** $9eab[0x10?]
	
		9ECB 9ED0 9ED7 9EDE 9EE3 9EE6 9EED 9EF4 
		9EFB 9EFE 9F05 9F24 9F2F 9F7A 9F8D 9FA2 

		9ECB: 04FF 0401 FC
		9ED0: 3200 06FF 0601 FC
		9ED7: 32FF 0601 06FF FC
		9EDE: 06FF 0601 FC
		9EE3: 01FF 00
		9EE6: 1000 06FF 0601 FC
		9EED: 0600 06FF 0601 FC
		9EF4: 1800 06FF 0601 FC
		9EFB: 04FF FE
		9EFE: 18FF 06FF 0601 FC
		9F05: 01FF 01FE 01FE 01FE 0102 0102 0102 0102
		      0102 0102 0102 01FE 01FE 01FE 01FE E4
		9F24: 0100 01FF 0101 0101 01FF F8
		9F2F: 0107 01FE 01FE 01FE 01FE 01FE	01FE 01FE
			  01FE 0101 0101 0101 01FF 01FF	01FF 0101
			  0101 0101 01FF 01FF 01FF 0101	0101 0101
			  01FF 01FF 01FF 0102 0102 0102	0102 0102
			  0102 0102 01FE 01FE 01FE 00
		9F7A: 0101 0102 0102 0102 0202 01FE 01FE 01FE
		      01FF EE
		9F8D: 0107 01FD 01FD 01FD 01FD 02FE 0201 0201
		      02FF 02FF F8
		9FA2: 01F9 0107 0207 01FE 01FD 01FD 01FD 01FD
		      0102 0102 0102 01FE 01FE 01FE 0102 0102
			  0102 01FE 01FE 01FE 0102 0102 0102 01FE
			  01FE 01FE 0102 0102 0102 0102 0102 0102
			  0102 00

### notes:
write notes here

### (pseudo)code:
```js
{
	x = $d0;
	a = $7feb.x << 1;
	if (!carry) {
		y = a;
		u16($d8) = u16($9eab.y);
		a = $7ff9.x;
		if (a == 0) {	//bne 8729
			y = $7ff2.x;
			a = $d8[y];
			if (a != 0) {	//beq 872c
				if (a < 0) {	//bpl 86fd
					y = $7ff2.x + a;
					a = $d8[y];
				}
$86fd:
				$7ff9.x = a;
				$7ff2.x = a = (y += 2);
				a = $d8[--y];
				if (a >= 0) {	//bmi 871b
$870b:
					$7f6d.x += a;
					if (carry) {	//bcc 8729
$8714:
						$7f6d.x = 0xff;	//satulation?
						//bne 8729
					}
				} else {
$871b:
					$7f6d.x += a;
					if (!carry) {	//bcs 8729
						$7f6d.x = 0x00;	//satlation?
					}
				}
			} else {
$872c:
				return;
			}
		}
$8729:
		$7ff9.x--;
$872c:
	}
	return;
$872d:
/*
    ldx <$D0     ; 86D5 A6 D0
    lda $7FEB,x ; 86D7 BD EB 7F
    asl a       ; 86DA 0A
    bcs .L_872C   ; 86DB B0 4F
*/
/*
        tay             ; 86DD A8
        lda $9EAB,y ; 86DE B9 AB 9E
        sta <$D8     ; 86E1 85 D8
        lda $9EAC,y ; 86E3 B9 AC 9E
        sta <$D9     ; 86E6 85 D9
        lda $7FF9,x ; 86E8 BD F9 7F
*/
/*
        bne .L_8729   ; 86EB D0 3C
            ldy $7FF2,x ; 86ED BC F2 7F
            lda [$D8],y ; 86F0 B1 D8
            beq .L_872C   ; 86F2 F0 38
            bpl .L_86FD   ; 86F4 10 07
                clc             ; 86F6 18
                adc $7FF2,x ; 86F7 7D F2 7F
                tay             ; 86FA A8
                lda [$D8],y ; 86FB B1 D8
*/
/*
        .L_86FD:
            sta $7FF9,x ; 86FD 9D F9 7F
            iny             ; 8700 C8
            iny             ; 8701 C8
            tya             ; 8702 98
            sta $7FF2,x ; 8703 9D F2 7F
            dey             ; 8706 88
            lda [$D8],y ; 8707 B1 D8
            bmi .L_871B   ; 8709 30 10
				clc             ; 870B 18
				adc $7F6D,x ; 870C 7D 6D 7F
				sta $7F6D,x ; 870F 9D 6D 7F
				bcc .L_8729   ; 8712 90 15
					lda #$FF    ; 8714 A9 FF
					sta $7f6d,x ; 8716 9D 6D 7F
					bne .L_8729 ; 8719 D0 0E
          .L_871B:
				clc             ; 871B 18
				adc $7F6D,x ; 871C 7D 6D 7F
				sta $7F6D,x ; 871F 9D 6D 7F
				bcs .L_8729   ; 8722 B0 05
					lda #$00    ; 8724 A9 00
					sta $7F6D,x ; 8726 9D 6D 7F
        .L_8729:
            dec $7FF9,x ; 8729 DE F9 7F
.L_872C:
    rts             ; 872C 60
*/
}
```


