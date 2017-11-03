; ff3_cmdx_raid.asm
;
; description:
;	implements 'raid' command 
;
; version:
;	0.04 (2006-11-13)
;======================================================================================================
ff3_cmdx_raid_begin:

commandWindow_OnRaid = commandWindow_selectSingleTargetAndNext

cmdx_raid:
; [in] x : actionid << 1
	DECLARE_COMMAND_VARS
.pActor = $6e
.targetStatusCache = $e0
.actorStatusCache = $f0
	jsr isTargetActor
	bne .ok
	;target == actor. confuse it as player
		jsr setupNoMotionType01
		lda #$52+$0e	;‚±‚ñ‚ç‚ñ
		sta actionName
		jsr setXtoActorIndex16
		lda <.actorStatusCache+1,x
		ora #$28	;‚±‚ñ‚ç‚ñ (remain1)
		sta <.actorStatusCache+1,x
		rts
.ok:
	lda #4
	sta effectHandlerIndex
	ldy #$2e
	sta [.pActor],y
	jsr cmdx_initDamageCache
	;
	ldy #$0f
	lda [.pActor],y
	lsr a
	lsr a
	lsr a
	clc
	adc #$08
	ldy #$27
	sta [.pActor],y

	jsr command_fight
	jsr updateTargetStatusByCache
	jsr isTargetActive
	bcc .sumDamages
;		jsr isTargetActor
;		beq .sumDamages

		lda #EXMSG_RAID_MESSAGE
		jsr addBattleMessage

		lda play_segmentedGroup
		pha
		lda actionName
		pha
		jsr swapHitCounts

		jsr .sumDamages
		jsr initAllDamages

		jsr command_fight_counter
		jsr setXtoActorIndex
		jsr setupWeaponId
		jsr swapHitCounts

		pla
		sta actionName
		pla
		sta play_segmentedGroup

		jsr swapDamages

.sumDamages:
	jsr setXtoTargetIndex
	jmp cmdx_sumDamagesOfTargetAndActor

cmdx_raid_end:
	VERIFY_PC ff3_magic_window_free_end
;======================================================================================================
	RESTORE_PC ff3_cmdx_raid_begin