; ff3_command_string.asm
;
;description:
;	defines extra strings
;
;version:
;	0.05 (2006-11-09)
;
;======================================================================================================
ff3_command_string_begin:
	;extra strings (reuse free space)
	FILEORG	$3cbbd
	cmdstr_provoke_fail:
		.db	$8a,$8b,$9c,$9f,$94,$b3,$9e,$8f,$7c,$99,$c4,$00
		
	;FILEORG	$3de12
	cmdstr_provoke_success:
		.db $9c,$90,$29,$8e,$93,$7c,$99,$c4,$00
	
	FILEORG $3a4f4
	cmdstr_provoke:	;ちょうはつ
		.db $9a,$7f,$8c,$a3,$9b,$00	;
	cmdstr_disordered_shot:	;みだれうち
		.db $a9,$33,$b3,$8c,$9a,$00
	cmdstr_abyss:			;あんこく
		.db $8a,$b6,$93,$91,$00
	cmdstr_raid:	;ふみこむ
		.db $a5,$a9,$93,$aa,$00
	cmdstr_counter_message:	;カウンター!!
	 	.db $cf,$cc,$f6,$d9,$c2,$c4,$c4,$00
	cmdstr_abyss_message:	;やみのちからが からだをむしばむ
		.db $ad,$a9,$a2,$9a,$8f,$b0,$29,$ff,$8f,$b0,$33,$7b,$aa,$95,$38,$aa,$00
	cmdstr_raid_message:	;てきのはんげきをうけた!
		.db $9c,$90,$a2,$a3,$b6,$2c,$90,$7b,$8c,$92,$99,$c4,$00
	FILEORG	$3dabd	;string for command 0A (original:$3dafd)

	;----------------------------------------------------------------------------------------	
	.bank	stringPtrTable >> 13
	.org	$8000 + (stringPtrTable & $7fff) + $0c40; + ($87 * 2)
	
	battleMessageOffsets:
.nullstr = $de21
EXTRA_BATTLE_MESSAGE_BEGIN = $57	;87d
	.org	battleMessageOffsets + ($0a * 2)	;string ptr for command 0A
		.dw (cmdstr_provoke & $ffff)
	.org	battleMessageOffsets + (EXTRA_BATTLE_MESSAGE_BEGIN * 2)	;message
		.dw (cmdstr_provoke_success & $ffff)		;57
		.dw	(cmdstr_provoke_fail & $ffff);58
		.dw (cmdstr_counter_message & $ffff); 59
		.dw (cmdstr_disordered_shot & $ffff); 5a
		.dw	(cmdstr_abyss & $ffff)	;5b
		.dw (cmdstr_raid & $ffff)	;5c
		.dw	(cmdstr_abyss_message & $ffff)	;5d
		.dw (cmdstr_raid_message & $ffff)	;5e
		;5f = "HPかいふく!"
;------------------------------------------------------------------------------------------------------
	.rsset EXTRA_BATTLE_MESSAGE_BEGIN
EXMSG_PROVOKE_SUCCESS	.rs 1
EXMSG_PROVOKE_FAIL		.rs 1
EXMSG_COUNTER			.rs 1
EXMSG_DISORDERED_SHOT	.rs 1
EXMSG_ABYSS				.rs 1
EXMSG_RAID				.rs 1
EXMSG_ABYSS_MESSAGE		.rs 1
EXMSG_RAID_MESSAGE		.rs 1
;======================================================================================================
	RESTORE_PC ff3_command_string_begin