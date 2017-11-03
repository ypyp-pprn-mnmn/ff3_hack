; ff3_string.asm
;
; string related codes in bank $34-35
;
;version:
;	0.05 (2006-11-12)
;======================================================================================================
ff3_string_begin:

TILE_ARRAY_BASE = $7200+$20;(1 << UNROLL_SHIFT)
;======================================================================================================
;strToTileArray
; 意外にもフィールドのルーチンからも呼ばれる模様
	.ifdef ENABLE_strToTileArray
	;.bank	$34
	;.org	$966a
	INIT_PATCH $34,$966a,$9754
	
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
	ldx #0
.decode_loop:
	txa
	pha
	lda .pString,x
	beq .return
	cmp #1
	beq .force_linefeed
	cmp #2
	beq .space_run
	cpy <.cchLine
	bcc .decode
		;.linefeed
		pha
		lda <.cchLine
		jsr .do_feed
		pla
.decode:
	sec
	sbc #$29
	cmp #$5c-$29
	bcs .put_tile
		;original code 29-5f reaches here
		sta <.char
		;tax
		;lda .offsetAndFlags,x
		ldx #0
	.find_char_type:
			cmp .codeBounds,x
			inx
			bcs .find_char_type
		;x = type + 1
		lda .offsetFlags-1,x
		lsr a
		pha
		lda #$c0
		adc #0	;take lsb as carry
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
.next:
	pla
	tax
.next_nopop:	
	inx
	bne .decode_loop
.do_feed:
	ldy #0
	pha
	jsr offsetTilePtr
	clc
	pla
	adc <.pUpperLine
	sta <.pUpperLine
	lda #0
	adc <.pUpperLine+1
	sta <.pUpperLine+1
	rts
.return:
	pla	;dummy
	rts	
.put_he:
	lda #$a6
	bne .put_only
.force_linefeed:
	lda <.cchLine
	asl a
	jsr .do_feed	
	bne .next	;always satisfied
.space_run:
	pla
	inx
	tya
	clc
	adc .pString,x
	tay
	jmp .next_nopop
.codeBounds:
					;code (after subtracted by #$29 )
	.db $0f			;00-0e	+66 06 がぎぐげござじずぜぞだぢづでど (29 => 8f)
	.db $14			;0f-13	+6b 0b ばびぶべぼ 12+89 (38 => a3)
	.db $19			;14-18	+66 06 ぱぴぷぺぽ 17+89 (3d => a3)
	.db $1a			;19-19	+8a 2a ヴ (42 => cc)
	.db $29			;1a-28	+8c 2c ガギグゲゴザジズゼゾダヂヅデト (43 => cf)
	.db $2c,$2d,$2e	;29-2d	+91 31 バビブベボ 2c+89 (ヘ: => a6)
	.db $31,$32,$33	;2e-32	+8c 2c パピプペポ 31+89
.offsetFlags:
	;bit0 indicates 1='Handakuten'
	;offset 0 is special;means 'he'
	;higher bits are offset,subtracted by $60
	.db $0c
	.db $16
	.db $0d
	.db $54
	.db $58
	.db $62,$00,$62
	.db $59,$01,$59
	;9719
	.endif	;ENABLE_strToTileArray
;9754
;======================================================================================================
;$96f8:
;
;$34:9754 initTileArrayStorage
	INIT_PATCH $34,$9754,$9777
initTileArrayStorage:
	ldx #HIGH(TILE_ARRAY_BASE)	;#$72
	stx $4f
	stx $7ac1
	ldx #LOW(TILE_ARRAY_BASE)	;#$20	;original: 00
	stx $4e
	stx $7ac0
	lda #$ff
	ldx #0
.loop:
	sta $7200,x	;TILE_ARRAY_BASEによらず常に7200-73FFを初期化
	sta $7300,x
	inx
	bne .loop
	rts
;======================================================================================================
	INIT_PATCH $35,$a609,$a66c
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
	RESTORE_PC	ff3_string_begin