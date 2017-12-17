

# $35:badc battle.apply_poison_damage
> 毒のダメージを計算し、結果を対象者に適用(ダメージ分をHPから減算し、必要に応じて死亡フラグをセット)する。

### args:

-	in u8 $24: character index
-	in BattleCharacter* $28: target
-	in,out u8 $64: ? some index
-	out u16 $7400[12]: damage values

### local variables:

-	u16 $26: damage value
-	u8 $62: damage index

### (pseudo-)code:
```js
{
/*
battle.apply_poison_damage:
    ldy #$01        ; BADC A0 01
    lda ($28),y     ; BADE B1 28
    tax             ; BAE0 AA
    and #$02        ; BAE1 29 02
    beq LBB3F       ; BAE3 F0 5A
    txa             ; BAE5 8A
    and #$C0        ; BAE6 29 C0
    bne LBB3F       ; BAE8 D0 55
    inc $64         ; BAEA E6 64
    lda $24         ; BAEC A5 24
    asl a           ; BAEE 0A
    sta $62         ; BAEF 85 62
    ldy #$05        ; BAF1 A0 05
    lda ($28),y     ; BAF3 B1 28
    sta $26         ; BAF5 85 26
    iny             ; BAF7 C8
    lda ($28),y     ; BAF8 B1 28
    sta $27         ; BAFA 85 27
	lsr $27         ; BAFC 46 27
    ror $26         ; BAFE 66 26
    lsr $27         ; BB00 46 27
    ror $26         ; BB02 66 26
    lsr $27         ; BB04 46 27
    ror $26         ; BB06 66 26
    lsr $27         ; BB08 46 27
    ror $26         ; BB0A 66 26
    ldx $62         ; BB0C A6 62
    lda $26         ; BB0E A5 26
    sta $7400,x     ; BB10 9D 00 74
    inx             ; BB13 E8
	lda $27			; BB14 A5 27
    sta $7400,x     ; BB16 9D 00 74
*/
	a = x = $28[y = #01];
	if ( ((a & #02) != 0) //beq bb3f
		&& ((x & #c0) == 0)) //bne bb3f
	{
		$64++;
		$62 = $24 << 1;
		$26 = $28[y = 0x05];	//+05,06 : max hp
		$27 = $28[++y];
$bafc:
		$26,27 >>= 4;
		x = $62;	//index<<1
		$7400.x = $26; x++;
		$7400.x = $27;
	}
$bb19:
/*
    ldy #$03        ; BB19 A0 03
    sec             ; BB1B 38
    lda ($28),y     ; BB1C B1 28
    sbc $26         ; BB1E E5 26
    sta ($28),y     ; BB20 91 28
    iny             ; BB22 C8
    lda ($28),y     ; BB23 B1 28
    sbc $27         ; BB25 E5 27
	sta ($28)		; BB27 91 28
    bcs LBB3F       ; BB29 B0 14
LBB3F:  
	ldy #$03        ; BB3F A0 03
    lda ($28),y     ; BB41 B1 28
    iny             ; BB43 C8
    ora ($28),y     ; BB44 11 28
    beq LBB2B       ; BB46 F0 E3
	rts				; BB47 60
*/
	$28[y] -= $26;
	$28[++y] -= $27;
	if (!carry || ($28[y = 3] | $28[y+1]) == 0) {
$bb2b:
		//毒ダメージを引いたらHPが0以下になった
/*
LBB2B:
	ldy #$03        ; BB2B A0 03
    lda #$00        ; BB2D A9 00
    sta ($28),y     ; BB2F 91 28
    iny             ; BB31 C8
    sta ($28),y     ; BB32 91 28
    ldy #$01        ; BB34 A0 01
    lda ($28),y     ; BB36 B1 28
    ora #$80        ; BB38 09 80
    and #$FE        ; BB3A 29 FE
    sta ($28),y     ; BB3C 91 28
    rts             ; BB3E 60
*/
		$28[++y] = $28[y = 3] = 0;
		$28[y] = ($28[y = 1] | 0x80) & 0xFE;	//set dead / clear poison
		return;
	}
$bb47:
	//生存
	return;
}
```






