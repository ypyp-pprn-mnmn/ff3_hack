; ff3_field_window.asm
;
; description:
;	replaces field::drawWindow($3f:ed02) related codes
;
; version:
;	0.01 (2006-11-09)
;======================================================================================================
ff3_field_window_begin:

	.ifdef FAST_FIELD_WINDOW
	INIT_PATCH $3f,$ed02,$ed56
field_drawWindowBox:
;$3f:ed02 field::drawWindow
;//	[in] u8 $3c : width (border incl)
;//	[in] u8 $3d : height
;//caller:
;//	$3c:8efd
;//	$3c:8f0e
;//	$3c:8fd5
;//	$3c:90b1
;//	$3d:aaf4 (jmp)
;{
;	push ( $3d - 2 );
;	field::getWindowTilesForTop();	//$edf6();
;	field::drawWindowLine();	//$edc6();
;	a = pop - 2;
;	if (a != 0) { //beq ed3b
;$ed23:
;		if (a < 0) { //bcs ed2a
;$ed25:
;			$3b--;
;			//jmp $ed3b
;		} else {
;$ed2a:
;			do {
;				push a;
;				field::getWindowTilesForMiddle();	//$ee1d();
;				field::drawWindowLine();	//$edc6();
;				a = pop a - 2;
;				if (a == 0) goto $ed3b
;			} while (a >= 0); //bcs ed2a
;$ed39:
;			$3b--;
;		}
;	}
;$ed3b:
;	field::getWindowTilesForBottom()//$ee3e();
;	field::drawWindowLine();	//$edc6();
;$ed41:
;	$38++; $39++;
;	$3c -= 2;
;	$3d -= 2;
;	return restoreBanksBy$57();	//jmp $ecf5();
;$ed56:
;}
.skipAttrUpdate = $37
.window_id = $96
.currentY = $3b
.beginX = $38	;loaded by field_getWindowMetrics
.beginY = $39	;loaded by field_getWindowMetrics
.width = $3c	;loaded by field_getWindowMetrics
.height = $3d	;loaded by field_getWindowMetrics
.attrCache = $0300	;128bytes. 1st 64bytes for 1st BG, 2nd for 2nd.
.newAttr = $07c0	;16bytes. only for 1 line (2 consecutive window row)

	ldx <.window_id
	jsr field_getWindowMetrics	;$ed61
;---
	;jsr $f670
	jsr field_loadWindowTileAttr	;ed56
;---
	lda <.beginY
	clc
	adc <.height
	sec
.setupAttributes:
		sbc #2	;carry is always set here.3
		sta <.currentY
		;[in] $37: require_attr_update, $38: startX?, $3b: offsetY?, $3c: width?
		;	$07c0: new_attr_values[16]
		jsr field_updateTileAttrCache
		lda <.currentY
		cmp <.beginY
		beq .adjust_window_metrics	;currentY == beginY
		bcs .setupAttributes		;currentY >= beginY
.adjust_window_metrics:
;	$38++; $39++;
;	$3c -= 2;
;	$3d -= 2;
;	return restoreBanksBy$57();	//jmp $ecf5();
; adjust metrics as borders don't need further drawing...
	inc <.beginX
	inc <.beginY
	dec <.width
	dec <.width
	dec <.height
	dec <.height

	lda <.skipAttrUpdate
	bne .finish

.updateAttributes:
	jsr waitNmiBySetHandler
	ldx #0
	lda #$23
	jsr .copyAttributes
	ldx #$40
	lda #$27
	jsr .copyAttributes
.finish:
	;lda #2
	;sta $4014	;DMA
	jsr field_setBgScrollTo0	;if omitted, noticable glithces arose in town conversations
	jmp field_restore_bank	;$ecf5
.copyAttributes:
	bit $2002
	sta $2006
	lda #$c0
	sta $2006
	jmp field_X_updateTileAttrEntirely

;	ldy #$40	;update entire attr table in target BG (64 bytes)
;.copy:
;	lda .attrCache,x
;	sta $2007
;	inx
;	dey
;	bne .copy
	;jsr field_setBgScrollTo0

	VERIFY_PC $ed56

;------------------------------------------------------------------------------------------------------
;$3f:ed56 field::fill_07c0_ff
;{
;	for (x = #f;x >= 0;x--) {
;		$07c0.x = #ff;
;	}
;	return;
;$ed61:
;}
;------------------------------------------------------------------------------------------------------
;$3f:ed61 field::get_window_metrics
;//[in]
;// u8 $37: skipAttrUpdate
;// u8 X: window_id (0...4)
;//[out]
;//	u8 $38: start_x
;//	u8 $39: start_y
;//	u8 $3c: width
;//	u8 $3d: height
;{
;	if ($37 == 0) { //bne edb1
;		a = $b6 = $edb2.x
;		$97 = a - 1;
;		$98 = $b5 = a = $edb7.x + 2;
;		$b5--;
;		$38 = (($29 << 1) + $edb2.x) & #3f;
;		$39 = (($2f << 1) + $edb7.x) % #1e;
;		a = $3c = $edbc.x;
;		a = $b8 = $b6 + a; $b8--;
;		a = $3d = $edc1.x;
;		$b7 = a + $b5 - 3;
;		$ec18();
;	}
;$edb1:
;	return;
;}
	INIT_PATCH $3f,$ed61,$edb2
field_getWindowMetrics:
;[in]
.scroll_x = $29	;in 16x16 unit
.scroll_y = $2f	;in 16x16 unit
.skip_attr_update = $37
.window_attr_table_x = $edb2
.window_attr_table_y = $edb7
.window_attr_table_width = $edbc
.window_attr_table_height = $edc1
;[out]
.left = $38	;in 8x8 unit
.top = $39	;in 8x8 unit
.width = $3c
.height = $3d
.offset_x = $97
.offset_y = $98
.internal_top = $b5
.internal_left = $b6
.internal_bottom = $b7
.internal_right = $b8

	lda <.skip_attr_update
	bne $ed60	;rts
	;; calculate left coordinates
	lda .window_attr_table_x,x
	sta <.internal_left
	sta <.offset_x
	dec <.offset_x
	lda <.scroll_x	;assert(.object_x < 0x80)
	asl a
	adc <.internal_left
	and #$3f
	sta <.left
	;; calculate top coordinates
	lda .window_attr_table_y,x
	;clc ;here always clear
	adc #2
	sta <.offset_y
	sta <.internal_top
	dec <.internal_top
	lda <.scroll_y
	asl a
	adc .window_attr_table_y,x
	cmp #$1e
	bcc .no_wrap
	;sec ;here always set
	sbc #$1e
.no_wrap:
	sta <.top
	
	;; calculate right coordinates
	lda .window_attr_table_width,x
	sta <.width
	clc
	adc <.internal_left
	sta <.internal_right
	dec <.internal_right
	;; calculate bottom coordinates
	lda .window_attr_table_height,x
	sta <.height
	clc
	adc <.internal_top
	;sec	;here always clear
	sbc #2
	sta <.internal_bottom
	;; done calcs
	jsr field_hide_sprites_around_window	;$ec18
	lda #2
	sta $4014	;DMA
	rts
	VERIFY_PC $edb2

	.endif	;//FAST_FIELD_WINDOW
;------------------------------------------------------------------------------------------------------
;$3f:edc6 field::drawWindowLine
;{
;	$90 = $3c;
;	$c98f();	//field::loadWindowPalette?
;	waitNmiBySetHandler();	//$ff00();
;	$4014 = 2;
;	putWindowTiles();	//$f6aa();
;	field::setWindowPalette();	//$c9a9();
;	field::setBgScrollTo0();	//$ede1();
;	return field::callSoundDriver();
;$ede1:
;}
	INIT_PATCH $3f,$edc6,$ede1
field_drawWindowLine:
.width = $3c
;.iChar = $90
	lda <.width
	sta <$90
	jsr field_updateTileAttrCache	;$c98f
	jsr waitNmiBySetHandler	;$ff00
	lda #02
	sta $4014
	jsr field_drawWindowContent	;$f6aa
	jsr field_setTileAttrForWindow	;$c9a9
	jsr field_setBgScrollTo0	;$ede1
	jmp field_callSoundDriver	;$c750
	VERIFY_PC $ede1

;------------------------------------------------------------------------------------------------------
;$3f:f40a setVramAddrForWindow
;//	[in] u8 $3a : x offset
;//	[in] u8 $3b : y
	INIT_PATCH $3f,$f40a,$f435
field_setVramAddrForWindow:
.offsetX = $3a
	ldy <.offsetX
field_setVramAddrForWindowEx:
;[in] a : widthInCurrentBg
;[in] y : offsetX
;[out] y : offsetX & #20 ^ #20
;[in]
.offsetX = $3a
.offsetY = $3b
;[ref]
.vramAddrLow = $f4a1
.vramAddrHigh = $f4c1
;--------------------------------------
	tya
	pha
	ldy <.offsetY
	and #$20
	tax
	beq .left_on_1st_bg
		lda #$04
.left_on_1st_bg:
	ora .vramAddrHigh,y
	sta $2006

	pla
	and #$1f
	ora .vramAddrLow,y
	sta $2006

;x = left & #20
	txa
	eor #$20
	tay

	rts

	VERIFY_PC $f435

;------------------------------------------------------------------------------------------------------
;	INIT_PATCH $3f,$f692,$f69c
;field_drawStringInWindow:
;	jmp field_drawStringInWindowEx
;
;$3f:f692 field::drawStringInWindow
;{
;	push a;
;	waitNmiBySetHandler();	//$ff00
;	$f0++;
;	pop a;
;	putWindowTiles();	//$f6aa
;$f69c
;	field::setBgScrollTo0();	//$ede1();
;	field::callSoundDriver();
;	call_switchFirst2Banks(per8kbank:a = $93);	//$ff03
;	return $f683();	//??? a= ($93+1)
;$f6aa:
;}

;------------------------------------------------------------------------------------------------------
;$3f:f6aa putWindowTiles
;//	[in] u8 $38 : offset x
;//	[in] u8 $39 : offset per 2 line
;//	[in,out] u8 $3b : offset y (wrap-around)
	INIT_PATCH	$3f,$f6aa,$f727

field_drawWindowContent:
;[in]
.left = $38
.width = $3c
.offsetX = $3a
.offsetString = $3a
.offsetY = $3b
.iChar = $90
.widthIn1stBg = $91
.tileArray = $0780
.upperLineString = $0780
.lowerLineString = $07a0

;-----------------------------------------
	cmp #9
	beq .draw_lower_line
		lda #0
		jsr .draw_line
.draw_lower_line:
	lda #$20
.draw_line:
;[in] a  = index offset
	pha
	sta <.offsetString

	bit $2002
	lda <.widthIn1stBg
	ldy <.left
	jsr .putTiles	;[out] y = offsetX & #20 ^ #20, $3a = offsetString

	clc
	pla
	adc <.width
	sec
	sbc <.offsetString
	bcc .next_line
	beq .next_line
		jsr .putTiles

.next_line:
	ldy <.offsetY
	iny
	cpy #30
	bne .no_wrap
		ldy #0
.no_wrap:
	sty <.offsetY
	lda #0
	sta <.iChar	;$90
	rts

.putTiles:
	pha

	jsr field_setVramAddrForWindowEx
.beginOffset = .offsetString
.endOffset = .beginOffset
	pla	;widthInCurrentBg
	ldx <.offsetString
	pha
	clc
	adc <.offsetString
	sta <.endOffset
	pla
	lsr a
	ror a
	bpl .length_even
;odd
.length_odd:
	bcc .copy_loop_1
	bcs .copy_loop_3
;even
.length_even:
	bcs .copy_loop_2
.copy_loop_0:
	lda .tileArray,x
	sta $2007
	inx
.copy_loop_3:
	lda .tileArray,x
	sta $2007
	inx
.copy_loop_2:
	lda .tileArray,x
	sta $2007
	inx
.copy_loop_1:
	lda .tileArray,x
	sta $2007
	inx
	
	cpx <.offsetString
	bne .copy_loop_0

	rts
	;VERIFY_PC $f727
;-----------
;[in]
;	u8 x: offset into attr table cache
;	attr_value[128] $0300: attr table cache
field_X_updateTileAttrEntirely:
.attr_cache = $0300
	ldy #$40	;update entire attr table in target BG (64 bytes)
.copy:
	lda .attr_cache,x
	sta $2007
	inx
	dey
	bne .copy
	rts

	VERIFY_PC $f727
;======================================================================================================
	RESTORE_PC ff3_field_window_begin