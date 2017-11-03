; ff3_asm.h
;
; include file for hackcodes
;======================================================================================================
;proc addrs
;$34-35
dispatchBattleCommand_5		= $8026
presentCharacter			= $8185
set52toIndexFromActorBit	= $8532	;[in] $7e98 : target indicator bits?,
tileSprites2x2				= $892e
loadCursor					= $8966
commandWindow_dispatchInput = $899e
clearSprites2x2				= $8adf

draw8LineWindow				= $8b38	;[in] $18:left, $19:right, $1a:borderFlag, $7ac0:tilePtr
setBackgroundProperty		= $8d03	;
draw1LineWindow				= $8d1b	;[in] $18:windowkind
eraseWindow					= $8eb0
eraseFromLeftBottom0Bx0A	= $8f0b
itoa_16						= $95e1
strToTileArray				= $966a
;initTileArrayStorage		= $9754 ;hacked (fill $7200[0x200] and set $4e to point $7200)
getCommandInput_next		= $99fd
createCommandWindow			= $9a69
playSoundEffect18			= $9b79	;setCA_18_and_incC9
playSoundEffect05			= $9b7d	;setCA_05_and_incC9
playSoundEffect06			= $9b81	;setCA_06_and_incC9
setYtoOffsetOf				= $9b88	;y = $5f + a
setYtoOffset03				= $9b8d
setYtoOffset2F				= $9b94	;target indicator
setYtoOffset2E				= $9b9b	;action id
drawSelectedActionNames		= $9ba2
drawEnemyNamesWindow		= $9d9e
getActor2C					= $a42e
getPlayerOffset				= $a541
initString					= $a549	;fill x bytes at $7ad7 #$00ff (null terminated)
offsetTilePtr				= $a558
getSys1Random				= $a564
loadString					= $a609
;itemWindowInputLoop		= $aeaa ;hacked
;endItemWindow				= $b1b0	;hacked
;itemWindow_OnB				= $b198	;hacked
;loadTileArrayForItemWindowColumn = $b48b
;moveCursor					= $b4d4	;hacked
;itemWindow_OnUse			= $b4f7	;hacked
;drawEquipWindow			= $b419	;hacked
;drawEquipWindowNoErase		= $b5f9	;hacked
;isPlayerAllowedToUseItem	= $b8fd	;hacked
loadTo7400FromBank30		= $ba3a
;$3e-3f
updateDmaPpuScrollSyncNmi	= $f8c5	;(y is unchanged)
setVramAddr					= $f8e0	;[in] a:high, x:low
mul_8x8_reg					= $f8ea	;a,x = a * x
call_2e_9d53				= $fa0e
waitNmi						= $fb80	;wait on $05 clear
switchFirst2Banks			= $fb87	;[in] a : per16k bank index
getPad1Input				= $fbaa	;[out] $12 : inputFlags
getBattleRandom				= $fbef	;[out] a : rand [min:x - max:a] max included
initBattleRandom			= $fc27
div_16						= $fc92	;$1c = $18,19 / $1a,1b; $1d = $18,19 % $1a,1b
mul_8x8						= $fcd6	;$1a,1b = a * x
mul_16x16					= $fcf5	;$1c,1d,1e,1f = $18,19 * $1a,1b
flagTargetBit				= $fd20
clearTargetBit				= $fd2c
maskTargetBit				= $fd38
shiftRight6					= $fd43
loadStringWorker			= $fd4a
get2byteAtBank18			= $fd60
;----------------------------------------------------------------------------------------------------------
;well known vars
pNmiHandler			= $0101	;$0100 jmp xxxx
pIrqHandler			= $0104	;$0103 jmp xxxx
nmiFlag				= $05
ppuCtrl1SetOnNmi	= $06
ppuCtrl1SetOnIrq	= $08
ppuCtrl2SetOnNmi	= $09
scrollXSetOnNmi		= $0c
scrollYSetOnNmi		= $0d
scrollXSetOnIrq		= $10
scrollYSetOnIrq		= $11
inputBits			= $12
playerX				= $c0	;*4
playerY				= $c4	;*4
playSoundEffect		= $c9	;1=play
soundEffectId		= $ca	; played on irq if $c9 != 0
playerStatusCache	= $e0	;in process battle phase
enemyStatusCache	= $f0	;
presentActionParams	= $78d5	;?,actor,action,targetflag,effectmsg,messages
stringCache			= $7ad7
battleRandoms		= $7be3
isRendering			= $7cf3

groupToEnemyIdMap	= $7d6b	;*4
;enemyIds			= $7da7
enemyPos			= $7dd7	;{x,y}*8
;param for playing (magic) effect
play_castTargetBits		= $7e99	;battle
play_effectTargetBits	= $7e9b	;param of presentActionEffect($33:b68d)
play_reflectedTargetBits= $7eb8 ;param of presentEffectAtTarget($33:b64f)

effectHandlerIndex	= $7ec2	;
indexToGroupMap		= $7ecd	;*8
;----------------------------------------------------------------------------------------------------------
;in memory structs
backpackItems		= $60c0
playerBaseParams	= $6100
playerEquips		= $6200
playerBattleParams	= $7675	;$40*4
enemyBattleParams	= $7575	;$40*8
;----------------------------------------------------------------------------------------------------------
;in rom structs
userFlags			= $00900
stringPtrTable		= $30000
monsterBaseParams	= $60000	;8*256
monsterBattleParams = $61000
itemBaseParams		= $61400
initialMps			= $73b88
lvupParamPtrTable	= $7ad59
;handler tables
commandIdToEffectMap	= $683f8
commandEffectHandlers	= $6843e
commandWindowHandlers	= $69a16
commandHandlers			= $69fac
;------------------------------------------------------------------------------------------------------
;macros
INIT16	.macro	;addr,val
	lda #LOW(\2)
	sta \1
	lda #HIGH(\2)
	sta \1+1
		.endm
		
ADD16	.macro	;addr,val		
	lda \1
	clc
	adc #LOW(\2)
	sta \1
	lda \1+1
	adc #HIGH(\2)
	sta \1+1
		.endm
				
SUB16	.macro	;addr,val		
	lda \1
	sec
	sbc #LOW(\2)
	sta \1
	lda \1+1
	sbc #HIGH(\2)
	sta \1+1
		.endm
		
FILEORG	.macro
	.bank	(\1) >> 13
	.org	($8000 | ((\1) & $7fff))
		.endm
		
RESTORE_PC	.macro
	.bank	BANK(\1)
	.org	\1
		.endm
		
INIT_PATCH	.macro
	.bank	\1
	.org	\2
	.ds		((\3) - (\2))
	.org	\2
		.endm