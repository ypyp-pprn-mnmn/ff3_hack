

# $36:80ab sound.play_music
> BGMを再生する。

### args:
+	in u8 $7f42: music_id

### callers:
+	$36:8003 sound.update_playback

### notes:
music playback utilizes all the channels available in the console.

### code:
```js
{
	if ($7f42 >= 0) {	//bmi 80b1
		return;
	}
$80b1:
// play_pulse1(square)_channel:
/*
  	lda $7F4A   ; 80B1 AD 4A 7F
    bpl .L_80F5   ; 80B4 10 3F
    and #$01    ; 80B6 29 01
    beq .L_80E0   ; 80B8 F0 26
*/
	if ($7f4a < 0) {	//bpl $80f5;
		if (($7f4a & 1) != 0) { //beq 80e0
			$7f4a &= 0xfe;
			//DDLC VVVV: where:
			//	D: Duty,
			//	L: envelope loop / length counter halt,
			//	C: constant volume (C)
			//	V: volume/envelope
			$4000 = $7f89 | $7f7b;	
			$4001 = $7f82;			//sweep
			$4002 = $7f6d;			//timer.low
			$4003 = $7f74;			//length counter|timer.high
			//goto $80f5;
		} else {
$80e0:
			$4000 = $7f89 | $7f7b;
			a = $7f82 << 1;
			if (!carry) {	//bcs $80f5
				$4002 = $7f6d;
			}
		}
	}
$80f5:
// play_pulse2(square)_channel:
/*
  	lda $7F4F   ; 80F5 AD 4F 7F
    bmi .L_813E   ; 80F8 30 44
    lda $7F4B   ; 80FA AD 4B 7F
    bpl .L_813E   ; 80FD 10 3F
    and #$01    ; 80FF 29 01
    beq .L_8129   ; 8101 F0 26
*/
	if (($7f4f >= 0) &&	//bmi $813e
		($7f4b < 0)) {	//bpl $813e
$80ff:
		if (($74fb & 1) != 0)) {	//beq $8121
		} else {
$8121:
		}
	}
$813e:
// play_triangle_channel:
/*
  	lda $7F4C   ; 813E AD 4C 7F
    bpl .L_8174   ; 8141 10 31
    and #$01    ; 8143 29 01
    beq .L_8166   ; 8145 F0 1F
*/
	if ($7f4c < 0) {	//bpl 8174
		if (($7f4c & 1) != 0) { //beq 8166
		} else {
$8166:
		}
	}
$8174:
// play_noise_channel:
/*
  	lda $7F50   ; 8174 AD 50 7F
    bmi .L_81AC   ; 8177 30 33
    lda $7F4D   ; 8179 AD 4D 7F
    bpl .L_81AC   ; 817C 10 2E
    and #$01    ; 817E 29 01
    beq .L_819E   ; 8180 F0 1C
*/
	if (($7f50 >= 0) &&	//bmi $81ac
		($7f4d < 0)) {	//bpl $81ac
$817e:
		if (($74fd & 1) != 0)) {	//beq $819e
$8182:
		} else {
$819e:
		}
	}
$81ac:
// play_DM_channel 'delta modulation'
/*
  	lda $7F4E   ; 81AC AD 4E 7F
    bpl .L_81C2   ; 81AF 10 11
    and #$01    ; 81B1 29 01
    beq .L_81C2   ; 81B3 F0 0D
*/
	if ($7f4e >= 0)) {	//bpl 81c2
		if (($7f4e & 1) != 0) {	//beq 81c2

		}
	}
$81c2:
	return;
$81c3:
/*
; ----------------------------------------------------------------------------
    lda $7F42   ; 80AB AD 42 7F
    bmi .L_80B1   ; 80AE 30 01
    rts             ; 80B0 60
; ----------------------------------------------------------------------------
.L_80B1:
  	lda $7F4A   ; 80B1 AD 4A 7F
    bpl .L_80F5   ; 80B4 10 3F
    and #$01    ; 80B6 29 01
    beq .L_80E0   ; 80B8 F0 26
    lda $7F4A   ; 80BA AD 4A 7F
    and #$FE    ; 80BD 29 FE
    sta $7F4A   ; 80BF 8D 4A 7F
    lda $7F89   ; 80C2 AD 89 7F
    ora $7F7B   ; 80C5 0D 7B 7F
    sta $4000   ; 80C8 8D 00 40
    lda $7F82   ; 80CB AD 82 7F
    sta $4001   ; 80CE 8D 01 40
    lda $7F6D   ; 80D1 AD 6D 7F
    sta $4002   ; 80D4 8D 02 40
    lda $7F74   ; 80D7 AD 74 7F
    sta $4003   ; 80DA 8D 03 40
    jmp .L_80F5   ; 80DD 4C F5 80
; ----------------------------------------------------------------------------
.L_80E0:
  	lda $7F89   ; 80E0 AD 89 7F
    ora $7F7B   ; 80E3 0D 7B 7F
    sta $4000   ; 80E6 8D 00 40
    lda $7F82   ; 80E9 AD 82 7F
    asl a       ; 80EC 0A
    bcs .L_80F5   ; 80ED B0 06
    lda $7F6D   ; 80EF AD 6D 7F
    sta $4002   ; 80F2 8D 02 40
.L_80F5:
  	lda $7F4F   ; 80F5 AD 4F 7F
    bmi .L_813E   ; 80F8 30 44
    lda $7F4B   ; 80FA AD 4B 7F
    bpl .L_813E   ; 80FD 10 3F
    and #$01    ; 80FF 29 01
    beq .L_8129   ; 8101 F0 26
    lda $7F4B   ; 8103 AD 4B 7F
    and #$FE    ; 8106 29 FE
    sta $7F4B   ; 8108 8D 4B 7F
    lda $7F8A   ; 810B AD 8A 7F
    ora $7F7C   ; 810E 0D 7C 7F
    sta $4004   ; 8111 8D 04 40
    lda $7F83   ; 8114 AD 83 7F
    sta $4005   ; 8117 8D 05 40
    lda $7F6E   ; 811A AD 6E 7F
    sta $4006   ; 811D 8D 06 40
    lda $7F75   ; 8120 AD 75 7F
    sta $4007   ; 8123 8D 07 40
    jmp .L_813E   ; 8126 4C 3E 81
; ----------------------------------------------------------------------------
.L_8129:
  	lda $7F8A   ; 8129 AD 8A 7F
    ora $7F7C   ; 812C 0D 7C 7F
    sta $4004   ; 812F 8D 04 40
    lda $7F83   ; 8132 AD 83 7F
    asl a       ; 8135 0A
    bcs .L_813E   ; 8136 B0 06
    lda $7F6E   ; 8138 AD 6E 7F
    sta $4006   ; 813B 8D 06 40
.L_813E:
  	lda $7F4C   ; 813E AD 4C 7F
    bpl .L_8174   ; 8141 10 31
    and #$01    ; 8143 29 01
    beq .L_8166   ; 8145 F0 1F
    lda $7F4C   ; 8147 AD 4C 7F
    and #$FE    ; 814A 29 FE
    sta $7F4C   ; 814C 8D 4C 7F
    lda $7F7D   ; 814F AD 7D 7F
    ora #$80    ; 8152 09 80
    sta $4008   ; 8154 8D 08 40
    lda $7F6F   ; 8157 AD 6F 7F
    sta $400A   ; 815A 8D 0A 40
    lda $7F76   ; 815D AD 76 7F
    sta $400B   ; 8160 8D 0B 40
    jmp .L_8174   ; 8163 4C 74 81
; ----------------------------------------------------------------------------
.L_8166:
  	lda $7F7D   ; 8166 AD 7D 7F
    ora #$80    ; 8169 09 80
    sta $4008   ; 816B 8D 08 40
    lda $7F6F   ; 816E AD 6F 7F
    sta $400A   ; 8171 8D 0A 40
.L_8174:
  	lda $7F50   ; 8174 AD 50 7F
    bmi .L_81AC   ; 8177 30 33
    lda $7F4D   ; 8179 AD 4D 7F
    bpl .L_81AC   ; 817C 10 2E
    and #$01    ; 817E 29 01
    beq .L_819E   ; 8180 F0 1C
    lda $7F4D   ; 8182 AD 4D 7F
    and #$FE    ; 8185 29 FE
    sta $7F4D   ; 8187 8D 4D 7F
    lda $7F7E   ; 818A AD 7E 7F
    ora #$30    ; 818D 09 30
    sta $400C   ; 818F 8D 0C 40
    lda $7F70   ; 8192 AD 70 7F
    sta $400E   ; 8195 8D 0E 40
    sta $400F   ; 8198 8D 0F 40
    jmp .L_81AC   ; 819B 4C AC 81
; ----------------------------------------------------------------------------
.L_819E:
  	lda $7F7E   ; 819E AD 7E 7F
    ora #$30    ; 81A1 09 30
    sta $400C   ; 81A3 8D 0C 40
    lda $7F70   ; 81A6 AD 70 7F
    sta $400E   ; 81A9 8D 0E 40
.L_81AC:
  	lda $7F4E   ; 81AC AD 4E 7F
    bpl .L_81C2   ; 81AF 10 11
    and #$01    ; 81B1 29 01
    beq .L_81C2   ; 81B3 F0 0D
    lda $7F4E   ; 81B5 AD 4E 7F
    and #$FE    ; 81B8 29 FE
    sta $7F4E   ; 81BA 8D 4E 7F
    lda #$00    ; 81BD A9 00
    sta $4011   ; 81BF 8D 11 40
.L_81C2:
  	rts             ; 81C2 60
*/
}
```





