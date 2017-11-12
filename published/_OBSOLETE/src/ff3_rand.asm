; ff3_rand.asm
;
; description:
;	small patch for pseudorandom generator for battle
;
; version:
;	0.01 (2006-10-12)
;
;======================================================================================================
ff3_rand_begin:
	.bank	$3f
	.org	$fc27
initBattleRandom:
	.org	$fc37
	
	adc #RANDOM_LCG_A	;original:3
;======================================================================================================
	RESTORE_PC ff3_rand_begin