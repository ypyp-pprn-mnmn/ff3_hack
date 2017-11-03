; ff3_window.asm
;
;	replaces window drawing functions
;	performs faster than original
;
;version:
;	0.09 (2006-10-05)
;
;	$1b,22,23,24,25,26 used in caller (so should be avoided)
;
;======================================================================================================

ff3_window_begin:
;------------------------------------------------------------------------------------------------------
;shared variables:
pLeftParts = $18
pRightParts = $1a
borderDrawFlags = $1a	; [in] bit0:draw left, bit1:draw right
updateCounter = $1c		;incremented by updateCount,when it overflows then stops drawing and wait for nmi
clockCount = $1d		;indicates required cpu cycle count / 8 (approx) for drawing line
borderPutFlags = $1e	; [lrLRxxxx] R:put right border in 2ndBG,l: put left border in 1st BG
lineLen = $1f			;total line width without border
drawLen = $20			;line length for bg currently drawing
vram = $2e
pTileArray = $7ac0	;see also initTileArrayStorage
;------------------------------------------------------------------------------------------------------
	.bank	$34
	.org	$8b38	;-$8d03)
	.ds		$8d03 - $8b38
	.org	$8b38
draw8LineWindow:
;args
.left = $18			; [in] unit = tiles, bit7 = bg select, border incl
.right = $19		; [in] unit = tiles, bit7 = bg select, border excl
;locals
.maskedLeft = $1c		;temp
.maskedRight = $1d		;temp
.crossFlag = $1e		;temp
.len_1st = $78b8	;width without border
.len_2nd = $78b9	;width without border
.vram_1st = $2a
.vram_2nd = $2c
.line = $30
;---------------------------------------
	lda <.left
	;pha
	and #$1f
	sta <.maskedLeft
	
	lda <.right
	;pha
	and #$1f
	sta <.maskedRight
	
	lda <.left
	eor <.right
	bmi .crosses_boundary
	;both are in same bg
		lda #$c0	;left1st | right1st
		sta <borderPutFlags
		lda <.right
		clc	;to exclude border	
		sbc <.left
		sta .len_1st
		
		lda #0
		beq .store_width
.crosses_boundary:
		lda #$90	;left1st | right2nd
		sta <borderPutFlags
		lda #$1f
		sec
		sbc <.maskedLeft
		sta .len_1st
		lda <.maskedRight
.store_width:		
	sta .len_2nd
; --- init 1st bg addr
	clc
	lda #$60
	sta <.vram_2nd		;2nd bg also have $60 at low byte
	adc <.maskedLeft
	sta <.vram_1st
	lda <.left
	bmi .left_starts_bg1
		lda #$22
		bne .store_left_high
.left_starts_bg1:
		lda #$26		
.store_left_high:
	adc #0	;carry still remains
	sta <.vram_1st+1		
; --- init 2nd bg addr
	lda <.right
	bmi .right_ends_bg1
		lda #$22
		bne .store_right_high
.right_ends_bg1:
		lda #$26	
.store_right_high:	
	sta <.vram_2nd+1

	jsr getBorderParts
;here still required vars:
;	.vram_1st, .vram_2nd, .len_1st, .len_2nd
;	lineLen
	lda .len_1st

	sta <drawLen
	clc
	adc .len_2nd
	sta <lineLen

	jsr generateCopyLoopCode
	jsr waitNmi
; --- begin drawing	
	ldx <.vram_1st		;3
	lda <.vram_1st+1	;3
	jsr setVram		;6+52
	
	lda .len_1st		;3
	sec					;2
	sbc <lineLen		;3
	jsr .drawOnCurrent	;6 80
	
	lda .len_2nd
	bne .draw_2nd
		rts
.draw_2nd:	
		pha	; len_2nd
		sta <drawLen
		asl <borderPutFlags
		asl <borderPutFlags
		jsr generateCopyLoopCode

		jsr waitNmi
		ldx <.vram_2nd		;3
		lda <.vram_2nd+1	;3
		jsr setVram		;6+52
		
		pla	; len_2nd		;4
		sec					;2
		sbc <lineLen		;3
		clc					;2
		adc .len_1st		;4 79
		;jmp .drawOnCurrent
.drawOnCurrent:
;[in]	a : initialOffset
;.len = $18
	pha					;2
	lda #4				;2	(25>>3)
	sta <updateCounter	;3
	
	lda #$f8	;topline;2
	ldx <drawLen			;3
	ldy #0				;2
	jsr putTopBottom	;6+x
	ldx #8				;2
	stx <.line			;3
	;
	pla	;initialOffset	;4
	tay					;2
.putLines:
		;	1loop:102 + genCode
		;genCode:
		;	26+76-84/8pixel 16+10  vblank is about 2266clk worth
		; 128+9*(cx&7)+11*(cx>>3)
		jsr genCodeBase	;6+ 78-86/8pixel + ?

		jsr checkUpdateAndOffsetVram;86 = 6+(28+6+12+34)
		
		dec <.line		;4
		lda <.line		;3
		bne .putLines	;3
;------
	lda #$fd	;bottomline
	ldx <drawLen
	ldy #6
	;jmp putTopBottom
;------------------------------------------------------------------------------------------------------
;helpers
putTopBottom:
;[in] a : centerPartTile
;[in] x : len_current
;[in] y : top(0) or bottom(6)
	pha
	bit <borderPutFlags
	bpl .putCenter	;bpl: bit7 is clear
		lda [pLeftParts],y
		sta $2007
.putCenter:
	pla
	dex
	bmi .put_right
.putCenter_loop:
		sta $2007
		dex
		bpl .putCenter_loop
.put_right:		
	bit <borderPutFlags
	bvc .finish			;bvc: bit6 is clear
		lda [pRightParts],y
		sta $2007
.finish:
	;jmp checkUpdateAndOffsetVram
;-----------------------------------------------------------------------------------------------------
checkUpdateAndOffsetVram:	;52+28clk(if update skipped)
	lda <updateCounter	;3
	clc					;2
	adc <clockCount	;3
	bcc .store_counter	;2+1
		jsr updatePpu	;6+46
		jsr waitNmi		;
		lda #0			;	(62>>3+1)
.store_counter:
	sta <updateCounter	;3
	
	lda <vram		;3
	clc				;3
	adc #$20		;2
	tax				;2
	lda <vram+1	;3
	adc #0			;2
	;fall through
setVram:		;52clk = 6+12+34
	sta <vram+1
	stx <vram
setVramAndInitPpu:	;+12
	bit $2002	;reset flip-flop	;4
	sta $2006	;vram addr high		;4
	stx $2006	;vram addr low		;4
updatePpu:	;7*4+6  34
	lda <ppuCtrl1SetOnNmi			;3
	sta $2000	;ppu ctrl			;4
	lda <ppuCtrl2SetOnNmi
	sta $2001
	lda <scrollXSetOnNmi
	sta $2005
	lda <scrollYSetOnNmi
	sta $2005
doReturn:	
	rts
;------------------------------------------------------------------------------------------------------
getBorderParts:
	lda <borderDrawFlags
	pha
	lda #LOW(.borderParts)
	sta <pLeftParts
	clc
	adc #2
	sta <pRightParts
	lda #HIGH(.borderParts)
	sta <pLeftParts+1
	sta <pRightParts+1
	
	pla
	lsr a
	bcs .check_right
		inc <pLeftParts	;no border
.check_right:
	lsr a
	bcs .finish
		dec <pRightParts
.finish:		
	rts
.borderParts:
	.db $f7,$f8,$f9
	.db $fa,$ff,$fb
	.db $fc,$fd,$fe	
;------------------------------------------------------------------------------------------------------
genCode_begin:
genCode_put_left:
	lda #00		;2
	sta $2007	;4
genCode_copyLoop:	
	tya			;2
	clc			;2
genCode_adc_offset:	
	adc #0		;2 alignOffset + (totalWidth - width)
	clc			;2
	tay			;2
	genCode_ldx_counter:	
		ldx #0	;2 #(.width_for_bg>>3+1)
	genCode_bne_next:	
		bne genCode_loop_begin	;3 +alignOffset
	;here total 15+6(left-border)
genCode_next:
	tya		;2
	;clc
	adc #$8	;2
	tay		;2
	bcc genCode_go_next	;3
		;jsr genCode_updateCode
	genCode_updateCode:
		txa
		pha	
		lda genCode_loopOffset
		;clc	always set (as Y was overflowed)
		adc #(8*6)-1
		tax
	.update_loop:	
			inc genCodeBase + (genCode_loop_begin - genCode_copyLoop) + (1 - 6),x
			txa
			sec
			sbc #6
			tax
			cpx genCode_loopOffset
			bne .update_loop
		pla
		tax
		clc	;to keep carry cleared while loop runs
genCode_go_next:
genCode_loop_begin:	;(4+4)*8
	lda $7200,y
	sta $2007
;	lda $7201,y
;	sta $2007
;	lda $7202,y
;	sta $2007
;	lda $7203,y
;	sta $2007
;	lda $7204,y
;	sta $2007
;	lda $7205,y
;	sta $2007
;	lda $7206,y
;	sta $2007
;	lda $7207,y
;	sta $2007
genCode_dex:
	dex			;2
	bne genCode_next-42	;3
genCode_put_right:
	lda #00		;2
	sta $2007	;4
genCode_finish_line:	
	rts			;6
genCode_end:	;21(prolog/epilog)+6(left)+6(right)+ 64~72(loop)+5+7(loop overhead)
;------------------------------------------------------------------------------------------------------
;here original:$8d03	
;------------------------------------------------------------------------------------------------------
	.bank BANK(ff3_window_begin)
	.org ff3_window_begin ;$8000 + (ff3_window_begin & $7fff)
;------------------------------------------------------------------------------------------------------
genCodeBase = $0121
generateCopyLoopCode:
;	[out] clockCount
.alignOffset = $21
genCode_loopOffset = genCodeBase - 1
;-----------------------------------
	lda <drawLen
	; alignOffset = (7 - width)+1 & 7
	eor #$ff
	clc
	adc #1
	and #7
	sta <.alignOffset
	;calc required cpu cycle count
	; 
	;128+9*(drawLen & 7)+11*(drawLen>>3)
	lda <drawLen
	sta <clockCount
	asl a
	;clc	always clear ( drawlen < 3e )
	adc <clockCount
	lsr a
	lsr a
	lsr a
	clc
	adc <clockCount
	adc #18	;(128)/8+3
	sta <clockCount
	;-----------------------------
	ldy #3
	lda [pRightParts],y
	pha
	lda [pLeftParts],y
	pha
	;-----------------------------
	;from here,Y is reserved to 'dest index'
	ldy #0
	bit <borderPutFlags
	bpl .copy_loop_code	;bpl: bit7 is clear
		inc <clockCount
		lda #(genCode_copyLoop - genCode_put_left)
		ldx #0
		jsr copyCodeBytes
		pla
		pha
		sta genCodeBase + 1	;lda #xx
.copy_loop_code:
	pla	;dummy
	tya
	sta genCode_loopOffset
	lda <drawLen
	beq .no_center_tiles
		lda #(genCode_loop_begin - genCode_copyLoop)
		ldx #(genCode_copyLoop - genCode_begin)
		jsr copyCodeBytes
		;--------------------------------------------------------------
		;branch target =
		; alignOffset*6 from .loop_begin
		lda <.alignOffset
		asl a
		;clc	always clear
		adc <.alignOffset
		asl a
		;sec	always clear
		sbc #((genCode_bne_next+2)-genCode_loop_begin)-1
		sta genCodeBase - (genCode_loop_begin - genCode_bne_next) + 1,y
		;--------------------------------------------------------------
		; loop count =
		; (len-1)>>3+1
		lda <drawLen
		;sec	always clear (by prev sbc)
		sbc #0
		lsr a
		lsr a
		lsr a
		clc
		adc #1
		sta genCodeBase - (genCode_loop_begin - genCode_ldx_counter) + 1,y
		;--------------------------------------------------------------
		; offsetIndex =
		; 8+(len-lenCurrent)-align
		lda #8+1
		;clc ;always clear (prev adc)
		adc <lineLen
		sbc <drawLen
		;sec	;always set (above sbc)
		sbc <.alignOffset
		sta genCodeBase - (genCode_loop_begin - genCode_adc_offset) + 1,y
		;----------------------------------------------------------------
		lda pTileArray
		;sec	;always set (above sbc)
		sbc #8
		sta pTileArray
		lda pTileArray+1
		sbc #0
		sta pTileArray+1
		;		
		lda #8
		.unroll_loopBytes:
			pha
			lda #6
			ldx #(genCode_loop_begin - genCode_begin)
			jsr copyCodeBytes
			; --- init address
			lda pTileArray
			clc
			sta genCodeBase + (1 - 6),y
			adc #1	;post increment
			sta pTileArray
			
			lda pTileArray+1
			sta genCodeBase + (2 - 6),y
			adc #0
			sta pTileArray+1
			;-----------------
			pla
			sec
			sbc #1
		bne .unroll_loopBytes
		
		lda #(genCode_put_right - genCode_dex)
		ldx #(genCode_dex - genCode_begin)
		jsr copyCodeBytes
		;jmp .copy_put_right_code
.no_center_tiles:
.copy_put_right_code:
	bit <borderPutFlags
	bvc .copy_last	;bvc: bit6 is clear
		inc <clockCount
		lda #(genCode_finish_line - genCode_put_right)
		ldx #(genCode_put_right - genCode_begin)
		jsr copyCodeBytes
		pla
		pha
		sta genCodeBase - 4,y	;lda #xx
.copy_last:
	pla	;dummy
	lda #(genCode_end - genCode_finish_line)
	ldx #(genCode_finish_line - genCode_begin)
	;jmp .copyCodeBytes
copyCodeBytes:
;	[in] a : len
;	[in] x : sourceOffset
;	[in] y : destOffset	
.copyLast = $30
	sty <.copyLast
	clc
	adc <.copyLast
	sta <.copyLast
.copy:
	lda genCode_begin,x
	sta genCodeBase,y
	inx
	iny
	cpy <.copyLast
	bne .copy
	rts
ff3_window_last:	
;------------------------------------------------------------------------------------------------------
;$34:8f0b eraseFromLeftBottom0Bx0A	//[eraseItemWindowColumn]
;{
;	$18,19 = #2380;
;	for (x = #0a;x != 0;x--) {
;$8f15:		presentCharacter();	//$34:8185
;		bit $2002;
;		$2006 = $19; $2006 = $18;	//vramAddr.high,vramAddr.low
;		setBackgroundProperty();	//$34:8d03();
;		for (a = 0,y = #b;y != 0;y--) {
;$8f2c:			$2007 = a;
;		}
;		$18,19 -= #0020;
;	}
;$8f42:	return;
;$8f43:
;}
	.bank	$34
	.org	$8f0b
eraseFromLeftBottom0Bx0A:
.vram = $18
	INIT16 <.vram,$2380
	jsr waitNmi
	ldy #$0a
.erase_loop:
		ldx <.vram
		lda <.vram+1
		jsr setVramAndInitPpu	;6+52
		ldx #5
		lda #0
	.erase_line:	
			sta $2007
			sta $2007
			dex 
			bne .erase_line
		sta $2007
		SUB16 <.vram,$0020
		dey	
		bne .erase_loop
	rts	
;=======================================================================================================	
	RESTORE_PC	ff3_window_last