
# $36:8ac0 sound.music.mute_channels
> BGMに使用するチャネル(全チャネル、ただし矩形#2とノイズは効果音優先)をミュートし、再生状態もそのように更新する。

### args:
+	in u8 $7f4a[7]: track controls

### callers:
+	$36:89c3 sound.music.load_stream

### code
```js
{
	for (x = 3;x >= 0;x--) {
		if ($7f4a.x >= 0) continue;	//bpl 8aec
		if (x == 1) {	//bne 8ad2
			//square-wave 1
			if ($7f4f < 0) continue;	//bmi 8aec
			//bpl 8adb
		} else {
$8ad2:
			if (x == 3) { //bne 8adb
$8ad6:
				//noise
				if ($7f50 < 0) continue; //bmi 8aec
			}
		}
$8adb:
		a = x;
		y = a << 2;
		if (x == 2) { // bne 8ae7
$8ae3:			//tri-wave channel
			a = #80;	//linear counter start
			//bne 8ae9
		} else {
$8ae7:			a = #30;	//envelope decay loop | envelope decay disabled
		}
$8ae9:
		$4000.y = a;	//each channel's ctrl0
$8aec:
	}
$8aef:
	return;
/*
    ldx #$03    ; 8AC0 A2 03
.L_8AC2:
        lda $7F4A,x ; 8AC2 BD 4A 7F
        bpl .L_8AEC   ; 8AC5 10 25
            cpx #$01    ; 8AC7 E0 01
            bne .L_8AD2   ; 8AC9 D0 07
                lda $7F4F   ; 8ACB AD 4F 7F
                bmi .L_8AEC   ; 8ACE 30 1C
                bpl .L_8ADB   ; 8AD0 10 09
    .L_8AD2:
            cpx #$03    ; 8AD2 E0 03
            bne .L_8ADB   ; 8AD4 D0 05
                lda $7F50   ; 8AD6 AD 50 7F
                bmi .L_8AEC   ; 8AD9 30 11
    .L_8ADB:
            txa             ; 8ADB 8A
            asl a       ; 8ADC 0A
            asl a       ; 8ADD 0A
            tay             ; 8ADE A8
            cpx #$02    ; 8ADF E0 02
            bne .L_8AE7   ; 8AE1 D0 04
                lda #$80    ; 8AE3 A9 80
                bne .L_8AE9   ; 8AE5 D0 02
    .L_8AE7:
                lda #$30    ; 8AE7 A9 30
    .L_8AE9:
            sta $4000,y ; 8AE9 99 00 40
    .L_8AEC:
        dex             ; 8AEC CA
        bpl .L_8AC2   ; 8AED 10 D3
    rts             ; 8AEF 60
*/
}
```




