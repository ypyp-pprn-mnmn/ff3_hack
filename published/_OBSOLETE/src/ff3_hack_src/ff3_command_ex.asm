; ff3_command_ex.asm
;
; description:
;	replaces originally unimplemented command ($0a)
;	implements 'extra ability' feature
;
; version:
;	0.06 (2006-11-10)
;======================================================================================================
ff3_command_ex_begin:
;------------------------------------------------------------------------------------------------------
EXTRA_ABILITY_OFFSET	= $3c

;PASSIVE_ABILITY_MASK	= $FF
PASSIVE_COUNTER			= $80
PASSIVE_DOUBLE_ITEM_EFFECT = $40
PASSIVE_PROTECT			= $20
PASSIVE_SUMMON_FUSION	= $10
PASSIVE_WRESTLING		= $08
;------------------------------------------------------------------------------------------------------

;replace tables
;$34:9b21(file:69b31) actionId jobActionLists[4][22]
	FILEORG	$69b21
	job_commands:
		.db		$04,$05,$06,$14	;00 onion
	.ifdef GIVE_FIGHTER_RAID
		.db		$04,$19,$06,$14	;01 fighter
	.else
		.db		$04,$05,$06,$14
	.endif	;GIVE_FIGHTER_RAID
		.db		$04,$05,$06,$14	;02 monk
		.db		$04,$15,$06,$14	;03 priest (white
		.db		$04,$15,$06,$14	;04 mage (black
		.db		$04,$15,$06,$14	;05 red
	.ifdef GIVE_HUNTER_DISORDERED_SHOT
			.db		$04,$17,$15,$14
	.else
			.db		$04,$05,$15,$14	;06 hunter
	.endif ;GIVE_HUNTER_DISORDERED_SHOT
		.db		$04,$05,$06,$14	;07
		.db		$04,$0E,$07,$14	;08
		.db		$04,$0C,$0D,$14	;09
		.db		$04,$0B,$05,$14	;0a
		.db		$04,$08,$05,$14	;0b
	.ifdef GIVE_VIKING_PROVOKE
			.db		$04,$16,$05,$14	;0c viking
	.else
			.db		$04,$05,$06,$14	;0c viking
	.endif	
		.db		$04,$0F,$05,$14	;0d	martialist
	.ifdef GIVE_EVILSWORDMAN_ABYSS
		.db		$04,$18,$15,$14	;0e
	.else
		.db		$04,$05,$15,$14	;0e
	.endif
		.db		$04,$15,$06,$14	;0f
		.db		$10,$11,$12,$14	;10	bard
		.db		$04,$15,$06,$14	;11
		.db		$04,$15,$06,$14	;12
		.db		$04,$15,$06,$14	;13
		.db		$04,$15,$06,$14	;14 sage
		.db		$04,$05,$06,$14	;15 ninja
;------------------------------------------------------------------------------------------------------
	.bank	$39

	.ifdef GIVE_FIGHTER_RAID
		.org	$bb1a + ($01 * 5 + 4)
			.db %11110001	;12 12 0 4
	.endif	;raid
	.ifdef GIVE_HUNTER_DISORDERED_SHOT
		.org	$bb1a + ($06 * 5 + 4)
		jobParams_hunter_04:
			.db %11111001	;12 12 8 4 ; original = $d9 (%11011001)
	.endif	;disordered_shot
	
	.ifdef GIVE_VIKING_PROVOKE
		.org	$bb1a + ($0c * 5 + 4)	;viking job param +04 (actionJobExp)
		jobParams_viking_04:
			.db %11111010	;12 12 8 8
	.endif	;provoke
	
	.ifdef GIVE_EVILSWORDMAN_ABYSS
			.org	$bb1a + ($0e * 5 + 4)
			.db %11111001	;12 12 8 4; original = $d9
	.endif	;abyss
;======================================================================================================
	RESTORE_PC infoWindow_free_begin

extraAbilityNameIds:
	.db $0a
	.db EXMSG_DISORDERED_SHOT
	.db EXMSG_ABYSS
	.db EXMSG_RAID

getExtraAbilityNameId:
;[in] u8 a : actionId
	cmp #CMDX_ID_BEGIN
	bcc .normal_command
		tax
		lda extraAbilityNameIds-CMDX_ID_BEGIN,x
.normal_command
	rts


	.ifdef FAST_DISORDERED_SHOT
;v0.6.1
setIndexAndCallPresentScene:
.iPlayer = $52
	pha
	jsr setXtoActorIndex
	stx <.iPlayer
	pla
	jmp call_2e_9d53
	.endif ;FAST_DISORDERED_SHOT

updateTargetStatusByCache:
.pTarget = $70
.targetStatusCache = $e0
	jsr setXtoTargetIndex
	asl a
	tax
	ldy #2
.update:
		;lda [.pTarget],y
		lda <.targetStatusCache+1,x
		sta [.pTarget],y
		dex
		dey
		bne .update
	rts

	VERIFY_PC infoWindow_free_end
;======================================================================================================
	RESTORE_PC calc_player_param_free_begin
extraAbilityFlags:
	.db $00
	.db $00
	.db $88	;monk
	.db $00

	.db $00
	.db $00
	.db $00	;hunter
	.db $20	;knight

	.db $00
	.db $40	;scholar
	.db $00
	.db $00

	.db $00
	.db $08	;martialist
	.db $00
	.db $00

	.db $00,$00,$00
	.db $10	;summoner
	.db $10	;sage
	.db	$00	;ninja
;======================================================================================================
	RESTORE_PC ff3_command_ex_begin