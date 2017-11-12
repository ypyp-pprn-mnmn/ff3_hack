; ff3_string.asm
;
; string related codes in bank $34-35
;
;version:
;	0.02 (2006-10-07)
;======================================================================================================
ff3_string_begin:
;$34:95e1 itoa_16
;//	[in]	u16 $18 : value
;//	[out]	u8 $1a[5] : tileArray (higher digit first)
;{
;	for (a = #80,x = 3;x >= 0;x--) {
;$95e5:		$1a.x = a;	//#80 = '0'
;	}
;	$1f = x;
;	$20 = #2710; countAndDecrementUntil0(); //$34:9648();
;	$20 = #03e8; countAndDecrementUntil0(); //$34:9648();
;	$20 = #0064; countAndDecrementUntil0(); //$34:9648();
;	$20 = #000a; countAndDecrementUntil0(); //$34:9648();
;$9618:	
;	$1e = $18 + #80;
;
;	if (#80 != (a = $1a)) return;
;$9625:	$1a = #ff;
;	//以下$1b,1c,1dも同様の処理(0ならスペースに置換)
;$9647:
;}

;$34:9648 countAndDecrementUntil0
;//	[in] u16 $20 : decrementBy
;{
;	x++;
;	do {
;$9649:		$18,19 -= $20,21;
;		$1a.x++;
;	} while ($18,19 >= 0);
;	$18,19 += $20,21;
;	$1a.x--;
;$966a:
;}

;======================================================================================================
;strToTileArray
;
; todo: implement code 01(\n) and 02(??)
	.IF	1
	.bank	$34
	.org	$966a
	
strToTileArray:
.cchLine	= $18
.char		= $1c
.pUpperLine	= $1e
.pTileArray	= $4e
.pString	= $7ad7
	lda <.pTileArray
	sta <.pUpperLine
	lda <.pTileArray+1
	sta <.pUpperLine+1
	lda <.cchLine
	jsr offsetTilePtr
	
	ldy #0
.decode_loop:
	lda .pString,y
	beq .return
	sec
	sbc #$29
	cmp #$5c-$29
	bcs .put_tile
		;original code 29-5f reaches here
		sta <.char
		tax
		lda .offsetAndFlags,x
		lsr a
		pha
		lda #$c0
		adc #0
		sta [.pUpperLine],y
		pla
		beq .put_he
		adc #$60
		adc <.char
		sec
.put_tile:
	adc #$28	;carry
.put_only:	
	sta [.pTileArray],y
	iny
	bne .decode_loop
.return:
	rts	
.put_he:
	lda #$a6
	bne .put_only	
.offsetAndFlags:
		;code (after #$29 subtracted)
		;		
		;00-0E	+66 0b がぎぐげござじずぜぞだぢづでど (29 => 8f)
		;0F-13	+6b 0b ばびぶべぼ 12+89 (38 => a3)
		;14-18	+66 06 ぱぴぷぺぽ 17+89 (3d => a3)
		;19		+8a 2a ヴ (42 => cc)
		;1a-28	+8c 2c ガギグゲゴザジズゼゾダヂヅデト (43 => cf)
		;29-2d	+91 31 バビブベボ 2c+89 (ヘ: => a6)
		;2e-32	+8c 2c パピプペポ 31+89
		;bit0 indicates 1='Handakuten'
		;offset 0 is special;means 'he'
		;higher bits are offset,subtracted by $60
		.db $0c,$0c,$0c,$0c,$0c, $0c,$0c,$0c,$0c,$0c, $0c,$0c,$0c,$0c,$0c ;$06*2
		.db $16,$16,$16,$16,$16 ;$0b*2
		.db $0d,$0d,$0d,$0d,$0d	;$06*2 | 1
		.db $54	;$2a*2
		.db $58,$58,$58,$58,$58, $58,$58,$58,$58,$58, $58,$58,$58,$58,$58 ;$2c*2
		.db $62,$62,$62,$00,$62 ;$31*2
		.db $59,$59,$59,$01,$59 ;$2c*2 | 1
	.ENDIF	;strToTileArray
;======================================================================================================
itoa_8:
;	[in] u8 a : value
;	[out] u8 $1a[3] : tileArray (higher first)
.result = $1a
	ldx #0
.digit_loop:	
		ldy #$ff
	.subtraction_loop:	
			iny
			sec
			sbc .digits,x
			bcs .subtraction_loop
		adc .digits,x
		pha
		tya
		bne .has_digit
			lda #$ff
			bne .store
	.has_digit:
			ora #$80
	.store:
		sta <.result,x
		pla
		inx
		cpx #3
	bne .digit_loop
	lda <.result+2
	cmp #$ff
	bne .return
	lda #$80
	sta <.result+2
.return:	
	rts
.digits	.db	100,10,1	
;======================================================================================================
;$96f8:
;
;$34:9754 initTileArrayStorage
;//fill_7200to73ff_ff
;//	[out] u16 $4e,$7ac0 : #7200
;{
;	$7ac0 = $18 = $4e = #$7200;
;	memset($18,0xff,0x200);
;$9777:
;}
	.org $9754
initTileArrayStorage:
	ldx #$72
	stx $4f
	stx $7ac1
	ldx #$00
	stx $4e
	stx $7ac0
	lda #$ff
.loop:
	sta $7200,x
	sta $7300,x
	inx
	bne .loop
	rts
;======================================================================================================
	.bank	$35
	.org	$a609
	.ds		$a66c - $a609
	.org	$a609
loadString:
;$35:a609 loadString
;	[in] u16 $18 : tableBase
;	[in] u8 A : index
;	[in,out] u8 X : destOffset
.pTableBase = $18
.offset = $18
.index = $1a
;----------------------------
	sta <.index
	txa
	pha
	jsr get2byteAtBank18	;get2byteAtBank18($1a) $fd60
	pla
	tax
	lda <.offset+1
	pha
	and #$3f
	ora #$80
	sta <.offset+1
	pla
	jsr shiftRight6	;$fd43
	clc
	adc #$0c
	jmp loadStringWorker	;$3f:fd4a
;$a66c:
;======================================================================================================
	RESTORE_PC	ff3_string_begin