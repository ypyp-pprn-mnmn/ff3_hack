; ff3_30-31.h
;
;description:
;	include file for bank $30,$31
;
;version:
;	v0.05 (2007-08-21)
;
;======================================================================================================
;$30-31
b31_getActor2C				= $a2b5	;2c:index & flag
cacheStatus					= $a2ba
getRandomTarget				= $a300
sumDamage					= $a368
addValueAtOffsetToAttack	= $a389
isRangedWeapon				= $a397
loadPlayerParam				= $a482
loadEnemyParam				= $a4f6
getActionMode				= $a8c8	;[in] $2c: battleChar* [out] y : #2c, a : $24.+2c
setRandomTargetFromEnemyParty = $a8cd	;[in] BattleChar* $24
getLeastLvInPlayerParty 	= $a8ec
decideEnemyActionTarget		= $a91b
isValidTarget				= $a9f7	;[out] bool zero :valid
recalcPlayerParam			= $aa16
calcAction					= $af77
segmentate					= $b9ab
;getRandomSucceededCount		= $bb28	;$24:count, $25:rate, [out] $30:succeededCount
getNumberOfRandomSuccess	= $bb28
calcDamage					= $bb44	;[out] $1c,1d : damage
isTargetWeakToHoly			= $bbe2	;[out] $27: 2=weak
b31_getTarget2C				= $bc25
;applyDamage					= $bcd2
damageHp					= $bcd2
healHp						= $bd24
shiftRightDamageBy2			= $bdaa
set24ToActor				= $bdb3
set24ToTarget				= $bdbc
checkEnchantedStatus		= $be14
b31_updatePlayerOffset		= $be90
b31_setYtoOffsetOf			= $be98
calcDataAddress				= $be9d
b31_getBattleRandom			= $beb4
checkSegment				= $bf53
