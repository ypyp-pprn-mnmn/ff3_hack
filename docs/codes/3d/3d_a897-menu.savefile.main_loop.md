
# $3d:a897 menu.savefile.main_loop
> 「セーブ」メニューを処理するメインのループ。メインメニューから「セーブ」を選択したときに実行される。

### args:

### local vairables:
+	u8 $79f0: last valid cursor-stop position.
+	u8 $24: is 'A' button down
+	u8 $25: is 'B' button down
+	u8 $a2: is cursor available to window-1 (1)
+	ptr $80: source game data
+	ptr $82: dest game data

### notes:

### (pseudo)code:
```js
{
	//...
$a8e3:
	$79f0 = 0;
	menu.savefile.build_menu();	//$a984();
$a8eb:
	do {
		menu.render_cursor();	//$a7cd();	//cursor?
		a = ($79f0 >> 2) & 3;
		$8241();
		a = 4;
		$91d9();
		if ($25 != 0) $a88c;	//b
	} while ($24 == 0); //beq a8eb:
$a905:
	menu.accept_input_action();	// $8f74();
	a = #4c;
	$a996();
	$a2 = 1;
	$78f0 = 0;
$a916:
	do {
		menu.render_cursor();	//$a7cd();
		a = ($79f0 >> 2) & 3;
		$8241();

		menu.get_input_for_window1_and_update_cursor({position_delta:a = 4});	//$91a3();
		if ($25 != 0) $a935; //b
	} while ($24 == 0); //beq $a916
$a930:
	if ($78f0 != 0) goto $a88c; //beq a938 まえのデーターをけします  rｧいいえ
$a938:
	//rｧはい
	a = 0x4d;
	$a996();
	
	a = $7f3a + 1;
	if (a >= 100) { //bcc a949
		a = 1;
	}
$a949:
	$7f3a = a;
	//$83 = ($79f0 & #0c) + #64;
	//$80 = $82 = 0;
	//$81 = #60;
	$80,81 = #6000;
	$82,83 = #6400 + (($79f0 & #c) << 8);
$a962:
	do {
		y = 0;
		do {
			$82[y] = $80[y];
		} while (++y != 0);
$a969:
		$81++; $83++;
	} while (($81 & 3) != 0); //bne a962 $80,81 == $6400 になるまで
$a973:
	$aa67();
	$aa4b();
	return saveMenu::close();	//$a88c();
$a984:
/*
    lda $7F38   ; A897 AD 38 7F
    cmp #$55    ; A89A C9 55
    bne .L_A8A5   ; A89C D0 07
    lda $7F39   ; A89E AD 39 7F
    cmp #$AA    ; A8A1 C9 AA
    beq .L_A8B4   ; A8A3 F0 0F
.L_A8A5:
    lda #$55    ; A8A5 A9 55
    sta $7F38   ; A8A7 8D 38 7F
    lda #$AA    ; A8AA A9 AA
    sta $7F39   ; A8AC 8D 39 7F
    lda #$01    ; A8AF A9 01
    sta $7F3A   ; A8B1 8D 3A 7F
.L_A8B4:
    lda $7F3A   ; A8B4 AD 3A 7F
    sta $6014   ; A8B7 8D 14 60
    jsr .L_AE5C   ; A8BA 20 5C AE
    jsr menu.init_input_states      ; A8BD 20 92 95
    jsr menu.main.erase             ; A8C0 20 85 A6
    jsr menu.upload_default_bg_attrs    ; A8C3 20 6F 95
    lda #$00    ; A8C6 A9 00
    sta $2001   ; A8C8 8D 01 20
    jsr .L_DD06   ; A8CB 20 06 DD
    jsr thunk_await_nmi_by_set_handler  ; A8CE 20 00 FF
    lda #$02    ; A8D1 A9 02
    sta $4014   ; A8D3 8D 14 40
    jsr menu.init_ppu               ; A8D6 20 9F 95
    lda #$00    ; A8D9 A9 00
    sta <$A2     ; A8DB 85 A2
    sta <$A4     ; A8DD 85 A4
    lda #$01    ; A8DF A9 01
    sta <$A3     ; A8E1 85 A3
    lda #$00    ; A8E3 A9 00
    sta $79F0   ; A8E5 8D F0 79
    jsr .L_A984   ; A8E8 20 84 A9
.L_A8EB:
		jsr menu.render_cursor          ; A8EB 20 CD A7
		lda $79F0   ; A8EE AD F0 79
		lsr a       ; A8F1 4A
		lsr a       ; A8F2 4A
		and #$03    ; A8F3 29 03
		jsr .L_8241   ; A8F5 20 41 82
		lda #$04    ; A8F8 A9 04
		jsr .L_91D9   ; A8FA 20 D9 91
		lda <$25     ; A8FD A5 25
		bne saveMenu.close              ; A8FF D0 8B
		lda <$24     ; A901 A5 24
		beq .L_A8EB   ; A903 F0 E6
    jsr menu.accept_input_action    ; A905 20 74 8F
    lda #$4C    ; A908 A9 4C
    jsr .L_A996   ; A90A 20 96 A9
    lda #$01    ; A90D A9 01
    sta <$A2     ; A90F 85 A2
    lda #$00    ; A911 A9 00
    sta $78F0   ; A913 8D F0 78
.L_A916:
		jsr menu.render_cursor          ; A916 20 CD A7
		lda $79F0   ; A919 AD F0 79
		lsr a       ; A91C 4A
		lsr a       ; A91D 4A
		and #$03    ; A91E 29 03
		jsr .L_8241   ; A920 20 41 82
		lda #$04    ; A923 A9 04
		jsr fieldMenu.updateCursorPos   ; A925 20 A3 91
		lda <$25     ; A928 A5 25
		bne .L_A935   ; A92A D0 09
		lda <$24     ; A92C A5 24
		beq .L_A916   ; A92E F0 E6
    lda $78F0   ; A930 AD F0 78
    beq .L_A938   ; A933 F0 03
.L_A935:
    jmp saveMenu.close              ; A935 4C 8C A8
; ----------------------------------------------------------------------------
.L_A938:
    lda #$4D    ; A938 A9 4D
    jsr .L_A996   ; A93A 20 96 A9
    lda $7F3A   ; A93D AD 3A 7F
    clc             ; A940 18
    adc #$01    ; A941 69 01
    cmp #$64    ; A943 C9 64
    bcc .L_A949   ; A945 90 02
    lda #$01    ; A947 A9 01
.L_A949:
    sta $7F3A   ; A949 8D 3A 7F
    lda $79F0   ; A94C AD F0 79
    and #$0C    ; A94F 29 0C
    clc             ; A951 18
    adc #$64    ; A952 69 64
    sta <$83     ; A954 85 83
    lda #$00    ; A956 A9 00
    sta <$80     ; A958 85 80
    sta <$82     ; A95A 85 82
    lda #$60    ; A95C A9 60
    sta <$81     ; A95E 85 81
    ldy #$00    ; A960 A0 00
.L_A962:
    lda [$80],y ; A962 B1 80
    sta [$82],y ; A964 91 82
    iny             ; A966 C8
    bne .L_A962   ; A967 D0 F9
    inc <$81     ; A969 E6 81
    inc <$83     ; A96B E6 83
    lda <$81     ; A96D A5 81
    and #$03    ; A96F 29 03
    bne .L_A962   ; A971 D0 EF
    jsr .L_AA67   ; A973 20 67 AA
    jsr .L_AA4B   ; A976 20 4B AA
    lda #$4E    ; A979 A9 4E
    jsr .L_A996   ; A97B 20 96 A9
    jsr .L_AA4B   ; A97E 20 4B AA
    jmp saveMenu.close              ; A981 4C 8C A8
*/
$a984:
}
```




