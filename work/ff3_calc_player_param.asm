; ff3_calc_player_param.asm
;
;description:
;	replaces code for player parameter calculation
;	adds 'extra job ability' feature
;
;version:
;	0.05 (2006-11-10)
;
;======================================================================================================
ff3_calc_player_param_begin:
	INIT_PATCH $31,$aa16,$ab0a
battleFunction05:
calcPlayerParam:
;[in]
.iPlayer = $52
.pBaseParam = $57
.pEquips = $59
.pBattleParam = $5b
;locals
.equipId_right = $27
.equipId_left = $28
.baseParams = $2c		;str,agi,vit,int,men
.equipParams = $7400	;[8][5]
.equipIds = $742f	;{head,body,wrest,righthand,count,lefthand}
.equipTraitFlag = $32
.equipFlag_right = $48	;=> pBattleParam[31]
.equipFlag_left = $49	;=> +32
;------------------------------------------------------------------------
	jsr b31_updatePlayerOffset	;be90
	tay
	ldx #0
.load_equips:
		lda [.pEquips],y
		sta .equipIds,x
		sta <$24,x
		iny
		inx
		cpx #6
		bne .load_equips
	ldx #2
.replace_empty_armor:
		lda <$24,x
		bne .replace_next
			lda #$57
			sta <$24,x
	.replace_next:
		dex
		bpl .replace_empty_armor
	lda <$24+5
	sta <$24+4
	sta .equipIds+4
	
	lda <.equipId_right
	jsr idToKindFlag	;extra
	sta <.equipFlag_right
	
	lda <.equipId_left
	jsr idToKindFlag	;extra
	sta <.equipFlag_left
	beq .empty_either
		lda <.equipFlag_right
		bne .set_traits
.empty_either:
		;at least lefthand or righthand is empty (or invalid item)
		lda <.equipFlag_right
		and #6
		beq .check_left
			;bow or arrow
			lda #0
			sta <$24+3
			beq .clear_flags
	.check_left:
		lda <.equipFlag_left
		and #6
		beq .set_traits
			;bow or arrow
			lda #0
			sta <$24+4
		.clear_flags:
			sta <.equipFlag_right
			sta <.equipFlag_left
.set_traits:
	lda <.equipFlag_right
	ora <.equipFlag_left
	;00:both bare fist or bow/arrow with other empty
	;01:onehanded weapon
	;06:bow(2) & arrow(4) set
	;08:harp
	;80:shield
	beq .finish	;$ab0a	;both barefist
	cmp #6
	beq .finish	;$ab0a	;bow_arrow_set
	cmp #8
	bne .others
;harp	
	lsr a
	bne .finish
.others:
	lda #2
.finish:
	.ifdef ENABLE_EXTRA_ABILITY_TAG
		pha
		
		jsr b31_updatePlayerOffset
		tay
		lda [.pBaseParam],y
		tax	;job
		lda #EXTRA_ABILITY_OFFSET
		jsr b31_setYtoOffsetOf
		lda extraAbilityFlags,x
		sta [.pBattleParam],y
		
		pla
		jmp $ab0a
	.else
		jmp $ab0a
	.endif	;ENABLE_EXTRA_ABILITY_TAG
;-------------------------------------------------------------------------------------------------------
idToKindFlag:	;[in] a = id [out] x = resultKind,a = flagValue
	ldx #5
.loop:
		cmp .bounds,x
		bcs .return
		dex
	bpl .loop
.return:
	inx
	lda .kindToFlag,x
	rts
.bounds:
	.db	$01,$46,$4a,$4f,$58,$65
.kindToFlag
	.db	$00,$01,$08,$02,$04,$80,$00
;-------------------------------------------------------------------------------------------------------
calc_player_param_free_begin:
calc_player_param_free_end = $ab0a
;-------------------------------------------------------------------------------------------------------
	INIT_PATCH $31,$ac69,$aca2
calcPlayerParam_testWrestlingAbility:
.pBattleParam = $5b
.equipTraitFlag = $32

	lda #EXTRA_ABILITY_OFFSET
	jsr b31_setYtoOffsetOf
	lda [.pBattleParam],y
	and #PASSIVE_WRESTLING
	beq $aca2
	
	lda <.equipTraitFlag
	and #$06
	bne $aca2
		lda $7428
		lsr a
		lsr a
		sta <$24

		lda $742e
		lsr a
		clc
		adc $742e
		sta <$25

		lda $742d
		lsr a
		lsr a
		clc
		adc <$24
		adc <$25
		adc #$02
		sta <$3b
		sta <$40
		jmp $ad3d
;$ac69:
;	if ( ($57[y = $5f] == #02 //beq ac76
;		|| $57[y] == #0d ) //bne aca2
;$ac76:		&&  (($32 & #06) == 0) ) //bne aca2
;	{  	//ƒ‚ƒ“ƒNor‹óŽè‰Æ and ‘fŽè
;$ac7c:
;		$24 = $7428 >> 2;	//fd47
;		$25 = $742e >> 1 + $742e;
;		$40 = $3b = $24 + $25 + $742d >> 2;	//fd47
;		//jmp $ad3d
;	} else {
;$aca2:
;=======================================================================================================
ff3_calc_player_param_end:	
	RESTORE_PC ff3_calc_player_param_begin