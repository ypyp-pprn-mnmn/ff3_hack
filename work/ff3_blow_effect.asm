;; encoding: **shift-jis**
; ff3_blow_effect.asm
;
; description:
;	replaces codes around blow-effect playing
;	
; version:
;	0.04 (2017-11-25)
;======================================================================================================
ff3_blow_effect_begin:
;======================================================================================================
	INIT_PATCH	$32,$98d1,$991f
showBlowSprite_02:	;
	lda #$12
	bne randomizePosAndShow
	
showBlowSprite_01:	;type 0(fist) ,2(bell,book,rod,cane) ,4(harp),9(claw)
	lda #$10
	;fall through
randomizePosAndShow:
.frameCount = $b6
.spriteX = $8c
.spriteY = $8d
.randX = $be
.randY = $bf
.target = $b8
.hand = $cd
	pha
;$98e8:
	ldx <.randY
	lda <.frameCount
	.ifdef VARIABLE_SWING_FRAMES
		jsr blowEffect_isFrameCountSatisfied	;a unchanged
		;x = range index
		;a = frame count
		asl a
		sec
		sbc blowEffect_frameBounds,x
		lsr a
		lsr a
		bcs .no_update
	.else
		lsr a
		bcs .no_update
	.endif	;VARIABLE_SWING_FRAMES

		lda <.target
		asl a
		tay
		lda enemyPos,y
		sta <.randX
		lda enemyPos+1,y
		sta <.randY

		jsr getSys0Random_00_ff
		and #$1f
		clc
		adc <.randX
		sta <.randX
		
		jsr getSys0Random_00_ff
		and #$1f
		clc
		adc <.randY
		tax
.no_update:
;$9912:
	;lda <.randY
	stx <.spriteY
	lda <.randX
	sta <.spriteX
	lda #0
	sta <$8f
	;fall through
;$991f
;$32:98d6
	pla
	tay
	lda <.hand
	beq .show
		iny
.show:
	sty <$8e
	jmp $9357
;$991f
	.org	$97df
blowSpriteHandlers:
;1F 99 E0 98 D1 98 1C 98 15 98 EB 97
	.dw	$991f	;type 1
	.dw	showBlowSprite_01	;$98e0	;type 0,2,4,9
	.dw showBlowSprite_02	;$98d1
	.dw $981c
	.dw $9815
	.dw $97eb
;======================================================================================================
	INIT_PATCH	$33,$a1ef,$a245
	
blowEffect_init:
	jsr $a11c
	ldx <$95
	jmp $a3f9
blowEffect_type07	;shuriken	
.hand = $cd
.frameCount = $b6
	jsr blowEffect_init
	
	jsr beginSwingFrame	;a059
	lda #$af
	sta sound.effect_id
;$a1ff:
.frame_loop:
		jsr $a05e	;;fill_A0hBytes_f0_at$0200andSet$c8_0
		lda <.frameCount
		jsr blowEffect_isFrameCountSatisfied
		lda <.hand
		bcs .frame_2nd_half
			beq .frame_1st_right
				ldx #$07
				lda #$1e
				bne .show_hand
		.frame_1st_right:
				ldx #$05
				lda #$18
				bne .show_hand
	.frame_2nd_half:
			beq .frame_2nd_right
				ldx #$06
				lda #$1f
				bne .show_hand
		.frame_2nd_right:
				ldx #$01
				lda #$19
		.show_hand:
			jsr $a06e
	.next_frame:
		jsr ppud.update_sprites_and_palette_after_nmi	;f8b0
		jsr incrementSwingFrame	;8ae6
		lsr a
		jsr blowEffect_isFrameCountSatisfied
		bcc .frame_loop
	jsr $a5fe
	jmp $ac35
;$a245
;------------------------------------------------------------------------------------------------------
	;INIT_PATCH	$33,$a2fb,$a365
	;INIT_PATCH	$33,$a379,$a3dd
	INIT_PATCH $33,$a2fb,$a3dd
	
blowEffect_doSwing_type09:	;09=claw also 00(fist),08(arrow)
.hand = $cd
.swingCount = $bd
.frameCount = $b6

	;jsr $a11c
	;ldx <$95
	;jsr $a3f9
	jsr blowEffect_init
.swing_loop:
		jsr beginSwingFrame	;a059
		lda #$8a
		sta sound.effect_id	;$7f49
	.frame_loop:
			jsr	$a05e	;fill_A0hBytes_f0_at$0200andSet$c8_0
			lda <.hand
			beq	.righthand
;$a312
				lda #$06
				jsr .showFist
				lda #$0d
				bne .show_blow
			.righthand:
				lda #$05
				jsr .showFist
				lda #$04
		.show_blow:
			pha
			jsr $a2cf
			bne .play_blow
				pla
				pha
				jsr $92a1
		.play_blow:
			pla
			lda #2
			jsr $97b2
		.next_frame:
			jsr blowEffect_advanceFrameOrFinish
			bcc .frame_loop
			bcs .swing_loop
.showFist:
	jsr $a2d9
	jsr	$a44f
	and #1
	sta <$7e
	jsr $a44f
	and #1
	sta <$7f
blowEffect_doReturn_00:
	rts
;------------------------------------------------------------------------------------------------------	
blowEffect_advanceFrameOrFinish:
.swingCount = $bd
;[out] bool carry: do next frame(0),do next swing(1)
	jsr ppud.update_sprites_and_palette_after_nmi	;$f8b0
	jsr incrementSwingFrame			;$8ae6
	jsr blowEffect_isFrameCountSatisfied
	bcc blowEffect_doReturn_00 ;.return
	dec <.swingCount
	bmi .finish
	bne blowEffect_doReturn_00	;beq .finish
;.return:
;		rts
.finish:
	pla	;retaddr
	pla	;retaddr
	jmp $ac35
;------------------------------------------------------------------------------------------------------	
	;.org	$a365
blowEffect_type01:
	jsr getSwingCountOfCurrentHand	;a245
	lda #$00
	beq blowEffect_storeBlow
;------------------------------------------------------------------------------------------------------		
	;.org	$a36f
blowEffect_type02:
	jsr getSwingCountOfCurrentHand	;a245
	lda #$01
blowEffect_storeBlow
	sta <$ba
	;jmp blowEffect_doSwing_type0102
	;bne blowEffect_doSwing_type0102
;------------------------------------------------------------------------------------------------------	

blowEffect_doSwing_type0102:
;[in]
.blowSprite = $ba
.swingCount = $bd
.hand = $cd	;right=0 left=1
;locals
.frameCount = $b6	;shared
;locals (extra)
;---------------------------------------
	jsr $a438	;getWeaponSprite
	jsr $a40f	;copySpriteProps
	ldx <$95
	jsr $a3f9	;clearWeaponSprite

.swing_loop:	;$a384:
		jsr beginSwingFrame	;$a059
		sta <$b9
		lda #$b6
		sta sound.effect_id	;$7f49
	.frame_loop:	;$a38e:
			jsr $a05e	;fill_A0hBytes_f0_at$0200andSet$c8_0();
			lda <.frameCount
			asl a
			jsr blowEffect_isFrameCountSatisfied
			lda <.hand
			bcs .frame_2nd_half
				;‘O”¼(4ƒtƒŒ[ƒ€)
				beq .righthand_1st
					lda #7
					ldx #2
					jsr $a065
					jmp .next_frame
					;
			.righthand_1st:
					ldx #5
					lda #0
					jsr $a06e
					jmp .next_frame
		.frame_2nd_half:
				;Œã”¼
				beq .righthand_2nd
					lda #6
					ldx #3
					jsr $a065
					jmp .show_blow
			.righthand_2nd:
					lda #1
					tax
					jsr $a06e
		.show_blow:
			lda <.blowSprite
			jsr $97b2
	.next_frame:
		jsr blowEffect_advanceFrameOrFinish
		bcc .frame_loop
		bcs .swing_loop
;		a,x
;r/1st	0,5
;l/1st	7,2
;r/2nd	1,1
;l/2nd	6,3	
blowEffect_isFrameCountSatisfied:
;[in] a : frameCount
;[out] bool carry : 1:satisfied ( frame >= limit)
.hand = $cd
.swingCounts = $bb
	.ifdef VARIABLE_SWING_FRAMES
		pha
		ldx <.hand
		lda <.swingCounts,x
		ldx #3
	.find_range:
			cmp .bounds,x
			bcs .found
			dex
			bpl .find_range
	.found:
		;x=index
		pla
		cmp blowEffect_frameBounds,x
		rts
	.bounds:
		.db $00,$05,$0b,$10
blowEffect_frameBounds:
		.db $08,$06,$04,$02
	.else
		cmp #SWING_FRAME_COUNT
		rts
	.endif	;VARIABLE_SWING_FRAMES
;original: $a3dd	
;------------------------------------------------------------------------------------------------------
	.bank	$33
	.org	$a077
swingCountBounds:
				;original
	.db	$11		;07 fist = 0
	.db	$11		;05 axe = 1, spear = 1, sword = 1,
	.db	$11		;05 rod = 2, book = 2, bell = 2,
	.db	$11		;07 bow = 3,
	.db	$05		;05 harp = 4,
	.db	$07		;07 boomerang = 5,
	.db	$07		;07 ring = 6,
	.db	$07		;07 shuriken = 7,
	.db	$11		;07 arrow = 8,
	;	claw = 9 (oops)
;------------------------------------------------------------------------------------------------------
	.bank	$33
	.org	$a080
blowEffectHandlers:
	.dw	$a2f2	;fist
	.dw	blowEffect_type01	;$a365	;axe
	.dw	blowEffect_type02	;$a36f	;rod,book,bell
	.dw	$a251	;bow
	.dw	$a1a5	;harp
	.dw	$a12c	;boomerang
	.dw	$a125	;engeturin
	.dw	blowEffect_type07	;$a1ef	;shuriken
	.dw	$a2f2	;arrow
	.dw	$a2fb	;claw
;======================================================================================================
	RESTORE_PC	ff3_blow_effect_begin