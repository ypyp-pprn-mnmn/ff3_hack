; ff3_32-33.h
;
;description:
;	include file for bank $32,33
;
;version:
;	v0.02 (2006-10-23)
;
;======================================================================================================
;$32-33
incrementSwingFrame			= $8ae6 ;a = ++$b6
beginSwingFrame				= $a059	;$b6 = 0
blowEffect_limitHitCount	= $a094
effect_playerBlow			= $a0c0 ;[effectFunction_04]
getSwingCountOfCurrentHand	= $a245
getSys0Random_00_ff			= $a44f