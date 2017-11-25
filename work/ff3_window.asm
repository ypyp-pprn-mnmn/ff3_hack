;; encondig: **shift-jis**
; ff3_window.asm
;
;	replaces window drawing functions
;	performs much faster than original
;	"だるまさんがころんだ"
;		6820 PPU cycles = 341 pixels per scanline * 20 scanlines within V-blank
;		=> approx. 2273 CPU cycles enough.
;		まずウインドウ1行分(tile: 8x8 pixel)転送用のコードを
;		WRAM($6000-7fff; access timing はRAMと同等 = 100% CPU cycle)に生成し
;		V-blankが開始したらループを開始し、転送用のコードが猶予のある限りVRAMへ転送を行う
;		転送用のコードは1ループに要するCPUサイクル数(処理を容易にするため8サイクル数単位)をカウントアップしており
;		256(=2048 CPU cycles; 理論的な上限は279=2272cycles)を超えたら転送を止めて次のNMIを待つ
;		なお、転送用のコードが要するCPUサイクル数は概算で69+9*1行の幅(8x8のタイル単位)
;version:
;	0.14 (2017-11-25)
;
;	$1b,22,23,24,25,26 used in caller (so should be avoided)
;
;======================================================================================================

ff3_window_begin:

;GENCODE_ENABLE_LOOP
UNROLL_SHIFT = 5	;valid range: 1-5
UNROLL_COUNT = (1 << UNROLL_SHIFT)
SIZEOF_PUT_CODE = 6	;lda $xxxx, sta $2007
LOOP_OVERHEAD = ((69+14) >> 3) + 1
;------------------------------------------------------------------------------------------------------
;shared variables:
pLeftParts = $18
pRightParts = $1a
borderDrawFlags = $1a	; [in] bit0:draw left, bit1:draw right
updateCounter = $1c		;incremented by updateCount;if it overflows then stops drawing and waits for nmi
clockCount = $1d		;indicates required cpu cycle count / 8 (approx.) for drawing line
borderPutFlags = $1e	; [lrLRxxxx] R:put right border in 2ndBG,l: put left border in 1st BG
lineLen = $1f			;total line width without border
drawLen = $20			;line length for bg currently drawing
vram = $2e
pTileArray = $7ac0	;see also initTileArrayStorage
;------------------------------------------------------------------------------------------------------
	INIT_PATCH $34,$8b38,$8d03

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
	jsr ppud.await_nmi_completion
; --- begin drawing	
	ldx <.vram_1st		;3
	lda <.vram_1st+1	;3
	jsr drawWindow_setVram		;6+24
	
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

		jsr ppud.await_nmi_completion
		ldx <.vram_2nd		;3
		lda <.vram_2nd+1	;3
		jsr drawWindow_setVram		;6+52
		
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
	lda #0				;2	(25>>3)
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
		;1loop:69 + genCode
		jsr genCodeBase	;6

		jsr checkUpdateAndOffsetVram;56 = 6+50
		
		dec <.line		;4
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
	tya	;0(top) or 6(bottom)
	beq checkUpdateAndOffsetVram
		;we finished drawing. setup scroll values
		jmp ppud.sync_registers_with_cache
	;jmp checkUpdateAndOffsetVram
;-----------------------------------------------------------------------------------------------------
checkUpdateAndOffsetVram:	;50clk = 24 + 26clk(if update skipped)
	lda <updateCounter	;3
	clc					;2
	adc <clockCount		;3
	bcc .store_counter	;2+1
		jsr ppud.sync_registers_with_cache	;$f8cb 6+34
		jsr ppud.await_nmi_completion		;
		clc				;2
		lda #(40>>3)	;2
.store_counter:
	sta <updateCounter	;3

	lda <vram		;3
	;clc			;always cleared
	adc #$20		;2
	tax				;2
	lda <vram+1		;3
	adc #0			;2
	;fall through
drawWindow_setVram:		;24clk = 6+18
	sta <vram+1
	stx <vram
	;fall through
drawWindow_setVramAddr:	;18clk
	bit $2002	;reset flip-flop	;4
	sta $2006	;vram addr high		;4
	stx $2006	;vram addr low		;4
drawWindow_doReturn:
	rts	;6

drawWindow_setVramAndInitPpu:
	jsr drawWindow_setVramAddr	;6+18
	jmp ppud.sync_registers_with_cache	;3+28
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
	tay			;2
genCode_go_next:
genCode_loop_begin:	;(4+4)*8
	lda $7200,y
	sta $2007
;	unrolled as many as required to fill a window line

genCode_dex:
genCode_put_right:
	lda #00		;2
	sta $2007	;4
genCode_finish_line:
	rts			;6
genCode_end:	;21(prolog/epilog)+6(left)+6(right)+ 64~72(loop)+5+7(loop overhead)
genCode_free_end = $8d03
;------------------------------------------------------------------------------------------------------
;here original:$8d03	
;------------------------------------------------------------------------------------------------------
	.bank BANK(ff3_window_begin)
	.org ff3_window_begin ;$8000 + (ff3_window_begin & $7fff)
;------------------------------------------------------------------------------------------------------
genCodeBase = TEMP_RAM+1
generateCopyLoopCode:
;	[out] clockCount
.alignOffset = $21
;genCode_loopOffset = genCodeBase - 1
;-----------------------------------
	lda <drawLen
	; alignOffset = (7 - width)+1 & 7
	eor #$ff
	clc
	adc #1
	and #(UNROLL_COUNT - 1)	;
	sta <.alignOffset
	;calc required cpu cycle count
	; 
	;clock required: 69 + 26 + (9 * drawLen)
	; overhead + put cost + loop cost
	;countdown value : req.clk / (2266/256) (113.3clock*20scanline)
	lda <drawLen
	lsr a
	lsr a
	lsr a
	clc
	adc <drawLen

	;sta <clockCount	;(9 * drawLen) / denom (=8)
	;lda <drawLen
	;jsr $fd49 - (UNROLL_SHIFT - 4 + 3)
	;clc
	;adc <clockCount
	adc #LOOP_OVERHEAD
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
;	tya
;	sta genCode_loopOffset

	lda <drawLen
	beq .no_center_tiles
		lda #(genCode_loop_begin - genCode_copyLoop)
		ldx #(genCode_copyLoop - genCode_begin)
		jsr copyCodeBytes

		;--------------------------------------------------------------
		; offsetIndex =
		; 8+(len-lenCurrent)-align
		lda #UNROLL_COUNT+1
		clc
		adc <lineLen
		sbc <drawLen
		;sec	;always set (above sbc)
		sbc <.alignOffset
		sta genCodeBase - (genCode_loop_begin - genCode_adc_offset) + 1,y
		;----------------------------------------------------------------
		lda pTileArray
		clc
		adc <.alignOffset
		bcc .sub_offset
			inc pTileArray+1
	.sub_offset:
		sec
		sbc #UNROLL_COUNT
		sta pTileArray
		bcs .done_offset
			dec pTileArray+1
	.done_offset:
		ldx <drawLen
		.unroll_loopBytes:
			txa
			pha
			lda #SIZEOF_PUT_CODE
			ldx #(genCode_loop_begin - genCode_begin)
			jsr copyCodeBytes
			; --- init address
			lda pTileArray
			clc
			sta genCodeBase + (1 - SIZEOF_PUT_CODE),y
			adc #1	;post increment
			sta pTileArray
			
			lda pTileArray+1
			sta genCodeBase + (2 - SIZEOF_PUT_CODE),y
			adc #0
			sta pTileArray+1
			;-----------------
			pla
			tax
			dex
		bne .unroll_loopBytes

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
	INIT_PATCH $34,$8eb0,$8f0b


eraseWindow:
.vram1stBegin = $2240
.vram1stEnd = $23a0	;last line begins $2380
.vram2ndBegin = $2640
	;jsr ppud.await_nmi_completion	;presentCharacterのかわりに使うと画面消去中キャラが動かないが多少(5scanline分) 描画に使える時間が増える
	jsr presentCharacter	;;ステータスエフェクトを動かすために必要。@see $32:9f11 effectCommand_03
	;; scanline 247, pixel 48 (fceux+old PPU) remaining 1591.7 + 97.7 cpu cycles. (14 x 113.7 + ((341 - 48) / 3)) 
	;; scanline 247, pxiel 97 (fceux+new PPU) remaining 1591.7 + 81.3 cpu cycles. (14 x 113.7 + ((341 - 97) / 3)) 
	ldx #LOW(.vram1stBegin)		;3
	lda #HIGH(.vram1stBegin)	;3
	jsr .erase	;6 + 24 + loop-body
	;jsr ppud.await_nmi_completion
	jsr presentCharacter
	ldx #LOW(.vram2ndBegin)
	lda #HIGH(.vram2ndBegin)
	;fall through
.erase:
	;jsr drawWindow_setVramAndInitPpu	;6+49
	jsr drawWindow_setVramAddr	;6+18
	lda #0		;3
	;ldx #$20
	ldx #$16	;3
.erase_loop:
	;fill 32*11 bytes. 1loop = 49cycles = (4*11)+5. 32x49=1568 cycles.
	;fill 22*16 bytes. 1loop = 69cycles. 22x69 = 1518 cycles.
	;; if an emulator running the game is accurately emulating ppu behaviors,
	;; code here can't complete rendering within v-blank period, and would be causing glithces.
	;; 'accurate' one seems to take more cycles than not.
	;; the 50-cycles gain achieved by unrolling mitigates this.
		sta $2007
		sta $2007
		sta $2007
		sta $2007
		sta $2007
		sta $2007
		sta $2007
		sta $2007
		sta $2007
		sta $2007
		sta $2007	;11 STA's so far

		sta $2007
		sta $2007
		sta $2007
		sta $2007
		sta $2007	;16 STA's so far
		dex
		bne .erase_loop
	;;here, the v-blank period is reaching almost the end.
	;;ppu is operating at scanline 260, cycle around 319
	jmp ppud.sync_registers_with_cache
;$8f0b
;------------------------------------------------------------------------------------------------------
	;.bank	$34
	;.org	$8f0b
	INIT_PATCH $34,$8f0b,$8f43
eraseFromLeftBottom0Bx0A:
.vram = $18
	INIT16 <.vram,$2380
	jsr ppud.await_nmi_completion
	ldy #$0a
.erase_loop:
		ldx <.vram
		lda <.vram+1
		jsr drawWindow_setVramAndInitPpu	;6+49
		;jsr drawWindow_setVramAddr
		ldx #5
		lda #0
	.erase_line:	
			sta $2007
			sta $2007
			dex 
			bne .erase_line
		sta $2007
		;SUB16 <.vram,$0020
		SUB16by8 <.vram,#$20
		dey	
		bne .erase_loop
	rts
	;jmp ppud.sync_registers_with_cache
;=======================================================================================================	
	RESTORE_PC	ff3_window_last