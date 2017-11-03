; ff3_info_window
;
;description:
;	replaces code for information window (larger window on the bottom right)
;
;version:
;	0.01 (2006-10-24)
;
;======================================================================================================
ff3_info_window_begin:

	INIT_PATCH	$34,$9ba2,$9ce3
drawInfoWindow:
.iPlayer = $52
.pBaseParam = $57
.pBattleParam = $5b
.commandIds = $78cf

	lda $7ceb
	beq .continue_process
		lda #0
		sta $7ceb
		rts
.continue_process:
	jsr initTileArrayStorage
	;INIT16 $720a,$7977
	INIT16 TILE_ARRAY_BASE+$0a,$7977	;'H' 'P'
	lda <.iPlayer
	pha
	ldx #0
.for_each_player:
		stx <.iPlayer
		ldx #$12
		jsr initString
		;$7ae3 = #c7;
		jsr getPlayerOffset	;a541
		clc
		adc #$0b
		tay
		ldx #6
	.copy_name:
			lda [.pBaseParam],y
			sta stringCache,x
			dey
			dex
			bne .copy_name
			
		ldx #7+4
		lda #3
		jsr getStringFromValueAt	;ex

		;lda #0
		;sta <$24
		jsr cachePlayerStatus	;9d1d
		lda $7ce8
		cmp #$ff
		beq .show_maxhp

			ldx <.iPlayer
			lda .commandIds,x
			cmp #$ff
			beq .check_status

				cmp #$c8
				bcc .not_magic
			.action_is_magic:
					INIT16_x <$18, ($8990 - $c8 * 2)
					ldx #$0c
					bne .load_string
			.not_magic:
	.ifdef ENABLE_EXTRA_ABILITY
					jsr getExtraAbilityNameId
	.endif ;ENABLE_EXTRA_ABILITY
					INIT16_x <$18, $8c40
					ldx #$0d
					bne .load_string
		.check_status:
			lda <$1b
			ora <$1a
			beq .show_maxhp
				lda <$1b
				and #$20
				beq .status_bit_to_index
					lda <$1b
					and #$df
					sta <$1b
					ora <$1a
					beq .show_maxhp
			.status_bit_to_index:
				ldy #0
			.find_index:
					asl <$1b
					rol <$1a
					bcs .got_index
					iny
					bcc .find_index
			.got_index:
				INIT16_x <$18,$822c
				tya
				ldx #$0d
				;bne .load_string
		.load_string:
			jsr loadString
			jmp .to_tiles
;$9c7f:
		.show_maxhp:
			lda $7ce8
			cmp #$ff
			beq .get_maxhp
				lda $7be1
				ldx <.iPlayer
				jsr maskTargetBit
				beq .get_maxhp
					lda .commandIds,x
					bne .action_is_magic
		.get_maxhp:
			ldx #$10
			lda #5
			jsr getStringFromValueAt
;$9cba:
		;$7ae3 = #c7;
	.to_tiles:
		lda #$c7
		sta stringCache+$0c
		lda #$12
		sta <$18
		jsr strToTileArray
		lda #$12
		jsr offsetTilePtr
		ldx <.iPlayer
		inx
		cpx #4
		beq .finish
		jmp .for_each_player
;$9cd1:
.finish:
	pla
	sta <.iPlayer
	lda #$0b
	sta <$18
	lda #$1e
	sta <$19
	lda #$03
	sta <$1a
	jmp draw8LineWindow
;------------------------------------------------------------------------------------------------------
getStringFromValueAt:
;[in] x = dest end offset
;[in] a = offset to value
.pBattleParam = $5b
	jsr setYtoOffsetOf
	lda [.pBattleParam],y
	sta <$18
	iny
	lda [.pBattleParam],y
	sta <$19
	txa
	pha
	jsr itoa_16	;95e1
	pla
	tay
	ldx #3
.copy:
		lda <$1b,x
		sta stringCache,y
		dey
		dex
		bpl .copy
	rts

infoWindow_free_begin:
infoWindow_free_end = $9ce3
;------------------------------------------------------------------------------------------------------
;$9ce3
;======================================================================================================
	RESTORE_PC ff3_info_window_begin