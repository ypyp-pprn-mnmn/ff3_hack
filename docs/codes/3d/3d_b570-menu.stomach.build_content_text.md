
# $3d:b570 menu.stomach.build_content_text
> パーティがデブチョコボに預けているアイテム($6300)を元に、アイテム描画用のテキストをバッファ($7300-$77ff)に生成する

### args:

#### in:
+	u8 $6300[256]: item amount in stomach

#### out:
+	u8 $7300[0x500]: text buffer, ready to be supplied into rendering logics

### callers:
+	`jsr menu.stomach.build_content_text	; B427 20 70 B5` @ $3d:b383

### local variables:
+	ptr $80: text buffer
+	u8 $82: item_id

### notes:
The param for amount of item in stomach (code 0x1d) of which would be in right column is being set to 0xff.
This looks like a bug.
However, handler in `$3f:eefa textd.draw_in_box` works around the situation.
The handler is checking if the charcode is `CHAR.ITEM_AMOUNT_IN_STOMACH`(0x1d),
and if so it uses last seen parameter byte (which will be the parameter of the code 0x1b) as the one for code 0x1d.

### (pseudo)code:
```js
{
/*
	ldx #$01        ; B570 A2 01
	ldy #$00        ; B572 A0 00
LB574:
	lda $6300,x     ; B574 BD 00 63
	beq LB57E       ; B577 F0 05
	txa             ; B579 8A
	sta $7C00,y     ; B57A 99 00 7C
	iny             ; B57D C8
LB57E:
	inx             ; B57E E8
	bne LB574       ; B57F D0 F3
	lda #$00        ; B581 A9 00
	sta $7C00,y     ; B583 99 00 7C
	cpy #$FF        ; B586 C0 FF
	beq	Lb590
Lb5ba:
	sta $7c00,y
	iny
	bne Lb5ba
*/
	//デブチョコボに預けているアイテム($6300)が1個以上であれば、
	//バッファ($7c00)にそのアイテムIDを追加する
	x = 1, y = 0;
	do {
		if (!(a = $6300[x])) {
			$7c00[y++] = (a = x);
		}
	} while (++x != 0);
	do {
		$7c00[y++] = 0;
	} while (++y != 0);
/*
lb590:
	lda #$00        ; B590 A9 00
	sta $82         ; B592 85 82
	sta $72FF       ; B594 8D FF 72
	sta $7300       ; B597 8D 00 73
	lda #$01        ; B59A A9 01
	sta $80         ; B59C 85 80
	lda #$73        ; B59E A9 73
	sta $81         ; B5A0 85 81
LB5A2:
	ldy #$00        ; B5A2 A0 00
	lda #$1B        ; B5A4 A9 1B
	sta ($80),y     ; B5A6 91 80
	iny             ; B5A8 C8
	lda $82         ; B5A9 A5 82
	sta ($80),y     ; B5AB 91 80
	iny             ; B5AD C8
	lda #$1D        ; B5AE A9 1D
	sta ($80),y     ; B5B0 91 80
	iny             ; B5B2 C8
	lda $82         ; B5B3 A5 82
	sta ($80),y     ; B5B5 91 80
	iny             ; B5B7 C8
	inc $82         ; B5B8 E6 82
	lda #$1B        ; B5BA A9 1B
	sta ($80),y     ; B5BC 91 80
	iny             ; B5BE C8
	lda $82         ; B5BF A5 82
	sta ($80),y     ; B5C1 91 80
	iny             ; B5C3 C8
	lda #$1D        ; B5C4 A9 1D
	sta ($80),y     ; B5C6 91 80
	iny             ; B5C8 C8
	lda #$FF        ; B5C9 A9 FF
	sta ($80),y     ; B5CB 91 80
	iny             ; B5CD C8
	lda #$01        ; B5CE A9 01
	sta ($80),y     ; B5D0 91 80
	iny             ; B5D2 C8
	inc $82         ; B5D3 E6 82
	beq LB5E7       ; B5D5 F0 10
	lda $80         ; B5D7 A5 80
	clc             ; B5D9 18
	adc #$09        ; B5DA 69 09
	sta $80         ; B5DC 85 80
	lda $81         ; B5DE A5 81
	adc #$00        ; B5E0 69 00
	sta $81         ; B5E2 85 81
	jmp LB5A2       ; B5E4 4C A2 B5
	; ----------------------------------------------------------------------------
*/
	$7300 = $72ff = $82 = 0;
	[$81, $80] = [0x73, 0x01];
	for (;;[$81, $80] += [0x00, 0x09]) {
		y = 0;
		($80)[y++] = 0x1b;	//CHAR.ITEM_NAME_IN_STOMACH
		($80)[y++] = $82;
		($80)[y++] = 0x1d;	//CHAR.ITEM_AMOUNT_IN_STOMACH
		($80)[y++] = $82;	// this will be ignored. appropriate value is $82, though.
		$82++;
		($80)[y++] = 0x1b;
		($80)[y++] = $82;
		($80)[y++] = 0x1d;	
		($80)[y++] = 0xff;	// this will be ignored.

		($80)[y++] = 0x01;	//CHAR.EOL
		if (++$82 == 0) {
			break;
		}
	}
/*
LB5E7:
	dey             ; B5E7 88
	lda #$00        ; B5E8 A9 00
	sta ($80),y     ; B5EA 91 80
	rts             ; B5EC 60
*/
	($80)[--y] = 0;	//CHAR.EOS
	return;
}
```


