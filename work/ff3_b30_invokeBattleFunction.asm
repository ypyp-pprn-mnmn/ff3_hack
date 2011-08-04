; ff3_b30_invokeBattleFunction.asm
;
;description:
;	replaces invokeBattleFunction()
;
;version:
;	0.03 (2006-11-07)
;
;======================================================================================================
ff3_b30_invokeBattleFunction_begin:
	INIT_PATCH $30,$9e58,$9e8a
invokeBattleFunction:
;	least value of S = $12 = $20 - ($0a + $06) (original:$14)
;		(dungeon_mainLoop - dungeon_mainLoop - beginBattle - call_doBattle - battleLoop)
;			+(presentBattle - pb_disorderedShot)
;			+(getPlayerCommandInput - commandWindow_OnItem)
;			+(executeAction>command_fight - doCounter - command_fight_doFight)
;[in]
.functionId = $4c
;.pFunctions = $9e76
;note: $18,19,1a are reserved!
	lda <.functionId
	asl a
	tax
	lda .pFunctions,x
	sta <$4c
	lda .pFunctions+1,x
	sta <$4d
	jmp [$004c]
;9e76
.pFunctions:
	.dw $af77	;00 doSpecial
	.dw $a400	;01 
	.dw $a732	;02 decideEnemyAction
	.dw $9e8a	;03 doFight
	.dw $a65e	;04 useItem
	.dw $aa16	;05 calcBattleParams
	.dw $a2e9	;06
	.dw $be9d	;07 calcDataAddress
	.dw $bebf	;08 rebuildBackpackItems
	.dw $bf17	;09
	; end of originally implemented
	.dw pickRandomTargetFromEnemyParty	;0a extra
	.dw getNumberOfRandomSuccess			;0b extra
	.dw calcDamage						;0c extra
;$30:9e8a
;======================================================================================================
	RESTORE_PC ff3_b30_invokeBattleFunction_begin