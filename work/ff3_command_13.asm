; ff3_command_13.asm
;
; description:
;	replaces command 13 (useItem)
;
; version:
;	0.06 (2017-11-13)
;		special thanks to owner of FF3c aka '966' for reporting bug
;======================================================================================================
ff3_command_13_begin:
	INIT_PATCH $31,$a65e,$a732
setupItemCalculation:	;$31:a65e useItem //dispid:04 [battleFunction04]
;[in]
.actionId = $1a
.pActor = $6e
.pTarget = $70
;---------------------------------------
	ldy #1
	sty battleProcessType
	sta <$72
	sta <$4b
	lda #$14
	sta $7ec2
	lda <.actionId
	sta actionName
	cmp #$98	;magical key
	bcs .not_equip
.pItemParam = $1a
		ldx #8
		jsr mul_8x8	;y is unchanged
		clc
		lda <.pItemParam+1
		adc #$94
		sta <.pItemParam+1
		ldy #4
		lda [.pItemParam],y
		and #$7f
		cmp #$7f
		beq .no_effect	;a722
		sta <.actionId
		lda #1
		bne .take_effect	;a71b
.no_effect:	;a722
	lda #$18
	sta $7ec2
	lda #$51	;"‚È‚É‚à ‚¨‚±‚ç‚È‚©‚Á‚½"
	sta battleMessages
	rts
.not_equip:
	cmp #$c8
	bcs .no_effect	;a722
.pItemEffect = $46
.effectId = $1b
		;consumeable item
		;$46,47 = (a - #98) + #91a0;
		clc
		adc #08
		sta <.pItemEffect
		lda #0
		adc #$91
		sta <.pItemEffect+1
		lda #$18
		sta <$4a
		;fix! v0.6.1
		lda #1
		sta <$4b
		;
		lda #$17
		jsr copyTo7400	;fddc
		lda $7400
		sta <.effectId
		cmp #$7f
		beq .no_effect	;a722
		
		lda $7ed8
		and #$10
		beq .consume_item
		
		lda <.actionId	;also itemid
		cmp #$ad	;‚¤‚¿‚Å‚Ì‚±‚Ã‚¿
		beq .no_effect	;a722
.consume_item:
			ldx #0
		.find_item:
				lda backpackItems,x
				cmp <.actionId
				beq .found
				inx
				inx
				bne .find_item
		.found:	
			;ASSERT(x < 0x40)
			inx
			dec backpackItems,x
			bne .get_cast_count
				dex
				lda #0
				sta backpackItems,x
		.get_cast_count:
			lda <.actionId
			ldx <.effectId
			stx <.actionId
			cmp #$a6	;potion
			bcs .load_cast_count
				lda #0
				beq .take_effect
		.load_cast_count:
.pItemHitCount = $46
			;$46,47 = #a35e + (a - #a6);
			clc
			adc #$b8
			sta <.pItemHitCount
			lda #0
			tax
			adc #$a2
			sta <.pItemHitCount+1
			lda #$18
			sta <$4a
			txa
			inx
			stx <$4b	;1
			jsr copyTo7400
			
			lda $7400
.take_effect: ;a71b
.castCountFinal = $7c
.castCount = $30
	.ifdef ENABLE_EXTRA_ABILITY_TAG
		tax
		;lda #EXTRA_ABILITY_OFFSET
		;jsr b31_setYtoOffsetOf
		;; FIXED:
		;;	checks for possesion of the ability should always be made against executor itself
		;;	and here pActor points to that exexcutor.
		;;	so it is fine to use the offset directly
		;;	see: http://966-yyff.cocolog-nifty.com/blog/2012/10/post-9708.html
		ldy #EXTRA_ABILITY_OFFSET	
		lda [.pActor],y
		and #PASSIVE_DOUBLE_ITEM_EFFECT
		beq .effect_normal
			txa
			asl a
			tax
	.effect_normal:
		stx <.castCount
		stx <.castCountFinal
	.endif ;ENABLE_EXTRA_ABILITY_TAG

	jmp $af77	;doSpecialAction
;------------------------------------------------------------------------------------------------------
;$a732
;======================================================================================================
	RESTORE_PC ff3_command_13_begin