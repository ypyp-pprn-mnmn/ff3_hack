; ff3_field_window.asm
;
; description:
;	replaces field::drawWindow($3f:ed02) related codes
;
; version:
;	0.01 (2006-11-09)
;======================================================================================================
ff3_field_window_begin:

	INIT_PATCH $3f,$ed02,$ed56
field_drawWindow:
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
.paletteUpdateRequired = $37
.beginY = $39
.line = $3b
.width = $3c
.height = $3d
.paletteCache = $0300

	ldx <$96
	jsr $ed61	;getWindowSize
	;jsr $f670
	;jsr field_fill_07c0_ff	;ed56
	lda <.beginY
	sta <.line
	lda <.height
	lsr a
	tax
.setupPalette:
		txa
		pha
		jsr field_cacheWindowPalette
		inc <.line
		inc <.line
		pla
		tax
		dex
		bne .setupPalette

;	lda <.beginY
;	sta <.line

;	$38++; $39++;
;	$3c -= 2;
;	$3d -= 2;
;	return restoreBanksBy$57();	//jmp $ecf5();
	inc <$38
	inc <$39
	dec <$3c
	dec <$3c
	dec <$3d
	dec <$3d
	lda <.paletteUpdateRequired
	bne .finish
.updatePalette:
	jsr waitNmiBySetHandler
	ldx #0
	lda #$23
	jsr .copyPalette
	lda #$27
.copyPalette:
	bit $2002
	sta $2006
	lda #$c0
	sta $2006
	ldy #$40
.copy:
	lda .paletteCache,x
	sta $2007
	inx
	dey
	bne .copy
	jsr field_setBgScrollTo0
.finish:
	jmp $ecf5
	VERIFY_PC $ed56
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
;	$3f:f692 field::drawStringInWindow
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

;	INIT_PATCH $3f,$f692,$f69c
;field_drawStringInWindow:
;	jmp field_drawStringInWindowEx

;======================================================================================================
	RESTORE_PC ff3_field_window_begin