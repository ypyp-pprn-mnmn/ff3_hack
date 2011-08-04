; ff3_34-35.h
;
;description:
;	label definition for bank $34-35
;
;version:
;	0.03 (2006-10-19)
;
;======================================================================================================
;$34-35
dispatchBattleFunction_03	= $801e
dispatchBattleFunction_05	= $8026
dispatchBattleFunction_06	= $802a
dispatchBattleFunction_07	= $802e
presentCharacter			= $8185
;playEffect					= $8411 ;hacked
;set52toIndexFromActorBit	= $8532	;[in] $7e98 : target indicator bits?,
dispatchPresentScene_1f		= $8545
targetBitToCharIndex		= $86ab	;[in] x = side? [out] y = index
tileSprites2x2				= $892e
loadCursor					= $8966
getInputAndUpdateCursorWithSound = $899e
clearSprites2x2				= $8adf

draw8LineWindow				= $8b38	;[in] $18:left, $19:right, $1a:borderFlag, $7ac0:tilePtr
setBackgroundProperty		= $8d03	;
draw1LineWindow				= $8d1b	;[in] $18:windowkind
eraseWindow					= $8eb0
eraseFromLeftBottom0Bx0A	= $8f0b
setNoTargetMessage			= $91ce
setBaseAddrTo_8a40			= $95bd
setBaseAddrTo_8c40			= $95c6
set18toTargetCache			= $95cf
itoa_16						= $95e1
strToTileArray				= $966a
;initTileArrayStorage		= $9754 ;hacked (fill $7200[0x200] and set $4e to point $7200)
;getCommandInput_next		= $99fd	;hacked
createCommandWindow			= $9a69
putCanceledItem				= $9ae7
requestSoundEffect18			= $9b79	;setCA_18_and_incC9
requestSoundEffect05			= $9b7d	;setCA_05_and_incC9
requestSoundEffect06			= $9b81	;setCA_06_and_incC9
setYtoOffsetOf				= $9b88	;y = $5f + a
setYtoOffset03				= $9b8d
setYtoOffset2F				= $9b94	;target indicator
setYtoOffset2E				= $9b9b	;action id
drawInfoWindow				= $9ba2
cachePlayerStatus			= $9d1d
drawEnemyNamesWindow		= $9d9e
setActorActionAndClearMode	= $9f7b
setActionTargetToSelf		= $9f87
;getIndexOfGreatest			= $a30f	;hacked [in] u16 $1a[4] : values ,$24[4] : indices [out] x : index
consumeEquippedItem			= $a353	;x unchanges
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
setActionTargetByParam		= $b979
loadTo7400FromBank30		= $ba3a