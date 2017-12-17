;; encoding: utf-8
; ff3_floor_treasure.asm
;
;description:
;	implements treasure related functions
;
;version:
;	0.3
;======================================================================================================
	;.ifndef ff3_floor_treasure_begin
	.include "ff3_floor.h.asm"
ff3_floor_treasure_begin:

	;INIT_PATCH_EX treasure,$3f,$e917,$e9bb,$e917
	INIT_PATCH $3f,$e917,$e9bb

;e917
floor_processChipEvent:
;[in]
.isTreasureGil = $49
.worldId = $78
.pFloorChips = $80
.treasureIdList = $0710
.leaderOffset = $600e
.treasureFlags = $6040
;[local/params for functions]
.chipAttributes = $44
.eventParams = $45
.isTreasureNaked = $ba
;--------------------------------------------

	jsr floor_getChipEvent	;$e51c() [out] y = chipid
	lda <.chipAttributes
	bpl .no_event
.has_event:
	cpy #$90
	bcc .no_event
	cpy #$a0
	bcc .door_event
	cpy #$d0
	bcc .no_event
	cpy #$f0
	bcc .treasure_event
.no_event:
	clc
	rts

.door_event:	;[90 <= chipid < a0]
;$e968:
	ldx .leaderOffset	;600e
	lda playerBaseParams,x	;6100
	cmp #JOB_THIEF	;08
	beq .door_is_unlocked
		lda #$03
		sec
		rts
.door_is_unlocked:
	lda $6021
	ora #$40
	sta $6021
	lda #$7a
	sec
	rts

.treasure_event:	;[d0 <= chipid < f0]
	ldx #0
	cpy #$e0
	bcc .store_naked
		dex
.store_naked:
	stx <.isTreasureNaked
	
	jsr floor_getTreasureFlagMaskAndIndex
	and .treasureFlags,y
	beq .no_event
;has treasure
	lda #$3f | $80
	sta sound.effect_id

	lda <.isTreasureNaked
	bmi .fetch_treasure
		jsr $e6f0	;unk
.fetch_treasure:
	lda <$80
	pha
	lda <$81
	pha
	
	jsr floor_getTreasure	;f549 [out] a = message id
	
	tax
	pla
	sta <$81
	pla
	sta <$80

	ldy #0
	cpx #$50	;message ("もちものがいっぱいです")
	bne .got_treasure
		sty <.chipAttributes
		sty <$0d
		beq .finish	;
.got_treasure:
	lda <.isTreasureNaked
	bmi .finish
		lda #CHIPID_OPENED_TREASURE_BOX	;7d
		sta [.pFloorChips],y
.finish:
	txa
	sec
	rts

floor_getTreasureId:
;[in]
.eventParams = $45
.treasureIdList = $0710
;[out]
;	a : treasureId
;	x : list index
	lda <.eventParams
	and #$0f
	tax
	lda .treasureIdList,x
	rts

floor_getTreasureFlagMaskAndIndex:
;[in]
.eventParams = $45
.worldId = $78
.treasureIdList = $0710
.treasureFlags = $6040
;[out]
;	a : mask value
;	x : bit index
;	y : byte index
	jsr floor_getTreasureId
	pha
	and #$07	;mask to bit index
	tax
	pla
	lsr a
	lsr a
	lsr a
	ldy <.worldId
	beq .test_flag
		clc
		adc #$20
.test_flag:
	tay
	lda floor_setBitMask,x
	rts

floor_setBitMask:
	.db $01,$02,$04,$08,$10,$20,$40,$80
;e9bb
	VERIFY_PC $e9bb
;-----------------------------------------------------------------------------------------------------
; treasure functions
;
	;INIT_PATCH $3f,$f549,$f670
	INIT_PATCH_EX floor.treasure, $3f, $f549, $f670, $f549
;$3f:f549 getTreasure
;//	[in] u8 $0710[0x10] : treasureIds
;//	[in] u8 $45 : eventParam
;//	[in] u8 $49 : warpparam.+01 & 0x20
;//	[in] u8 $ba : 00: chipId=d0-df, FF: chipId=e0-ef
;//		chipId:D0-DF = staticChipId:7C(宝箱)
;//	[out] a : messageId
floor_getTreasure:
;[in]
.eventParams = $45
.isTreasureGil = $49
.worldId = $78
.treasureId = $8f
.eventFlag = $ab
.encounterId = $6a
.isTreasureNaked = $ba
.messageParam = $bb
.treasureItem = $80	;u24
.treasureItemCount = $81
.treasureIdList = $0710
.treasureParams = $9c00	;512params
;------------------------------------------
	jsr floor_getTreasureId
	sta <.treasureId
	tax
.getTreasureParam:
	lda #$01
	jsr call_switch1stBank	;ff06
	lda .treasureParams,x
	ldy <.worldId
	beq .got_param
		lda .treasureParams+$100,x
.got_param:
	tax
	stx <.messageParam

	lda <.isTreasureNaked
	bne .treasure_is_item
	lda <.isTreasureGil
	bne .treasure_is_gil
.treasure_is_item:
		stx <.treasureItem

		lda #$01
		cpx #$57	;leather shield
		bcs .store_increment
			cpx #$4f	;wooden arrow
			bcc .store_increment
				lda #20
	.store_increment:
		sta <.treasureItemCount

		jsr switch_to_character_logics_bank;switchBanksTo3c3d	;f727
		
		;lda <.treasureParam
		;sta <.messageParam	;$bb
		
		jsr floor_searchSpaceForItem	;3c:937e [out] x = index to put
		bcc .put_item
			;item_full
			lda #$50	;"もちものがいっぱいです"
			rts
	.put_item:
		lda <.treasureItem
		sta backpackItems,x
		lda backpackItems+$20,x	;count
		clc
		adc <.treasureItemCount
		cmp #100
		bcc .store_item_count
			lda #99
	.store_item_count:
		sta backpackItems+$20,x

		jsr floor_invertTreasureFlag

		lda <.isTreasureNaked
		beq .treasure_in_box
			lda #$76	;"こんなところにxxが！"
			rts
	.treasure_in_box:
		lda <.treasureId
		cmp #TREASURE_WITH_ENCOUNTER_BASE	;$e0
		bcs .encounter
			lda #$59	;"たからばこのなかから..."
			rts
	.encounter:
		sta <.encounterId
		lda #EVENT_FLAG_ENCOUNTER	;$20
		sta <.eventFlag
		lda #$02	;"たからばこの...とつぜんモンスターが..."
		rts
.treasure_is_gil:
	;here x ==  (itemid)
	jsr floor.get_item_price	;f5d4
	jsr floor_incrementPartyGil
	jsr floor_invertTreasureFlag
	lda #$01	;"たからばこの...ぎるてにいれた"
	rts

;$3f:f640 invertTreasureFlag
floor_invertTreasureFlag:
;[in]
.eventParams = $45
.worldId = $78
.treasureIdList = $0710
.treasureFlags = $6040
	jsr floor_getTreasureFlagMaskAndIndex
	eor .treasureFlags,y
	sta .treasureFlags,y
	rts

	VERIFY_PC $f5d4
;-------------------------------------------------------------------------------------------------
;$3f:f5d4 getItemValue ;getTreasureGil
;	[in] x : itemid
;	[out] u24 $80 : = $10:9e00[x]
;caller:
;	$3d:b230 @ floor::shop::getItemValues
;	$3d:b271 @ floor::shop::getItemValue
;	$3f:ef73 @ field::decodeString 
;	$3f:f5b8 @ floor::getTreasure
;	caller expects y has been unchanged
floor.get_item_price:
;; fixups.
	FIX_ADDR_ON_CALLER $3d,$b230+1
	FIX_ADDR_ON_CALLER $3d,$b271+1
	.ifndef _OPTIMIZE_FIELD_WINDOW
	FIX_ADDR_ON_CALLER $3f,$ef73+1
	.endif
;; ----
.value = $80
.itemValues = $9e00
;------------------------
	lda #$10
	jsr call_switch1stBank

	txa
	asl a
	tax
	bcs .item_80_to_ff
		lda .itemValues,x
		sta <.value
		lda .itemValues+1,x
		bcc .store_value
.item_80_to_ff:
		lda .itemValues+$100,x
		sta <.value
		lda .itemValues+$101,x
.store_value:
	sta <.value+1
	lda #0
	sta <.value+2
	txa
	lsr a
	tax

	lda #$3c
	jmp call_switch1stBank
;--------------------------------------------------------------------------------------------------
;$3f:f5ff incrementGil
;//	[in] u24 $80 : gil
;	INIT_PATCH $3f,$f5ff,$f670
	;.bank	$3d
	;.org	$b1c2
	;jsr floor_incrementPartyGil
floor_incrementPartyGil:
	FIX_ADDR_ON_CALLER $3d,$b1c2+1
;[in]
.gil = $80
.partyGil = $601c
	ldx #0
	txa
.add24:
		ror a
		lda .partyGil,x
		adc <.gil,x
		sta .partyGil,x
		rol	a;save carry
		inx
		cpx #3
		bne .add24

	ldx #$fd
	sec
.cmp24:
		lda .partyGil-$fd,x
		sbc .maxGil-$fd,x
		inx
		bne .cmp24

	bcc .finish

;here x == 0
	ldx #2
.init24:
		lda .maxGil,x
		sta .partyGil,x
		dex
		bpl .init24
.finish:
	rts
.maxGil:
	.db $7f,$96,$98	;9999999

	;VERIFY_PC $f670
	VERIFY_PC_TO_PATCH_END floor.treasure
floor.treasure.FREE_BEGIN:
;=====================================================================================================
	RESTORE_PC ff3_floor_treasure_begin
	
	;.endif	;;ff3_floor_treasure_begin
