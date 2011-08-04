; ff3_hack_beta.asm
;
; description:
;	creates hacked file with newly implemented features
;
; version:
;	0.07(2007-08-13)
;
;======================================================================================================
;assemble flags
BETA
;BALANCED_VERSION
;TEST_MAP

;TEST_COUNTER_ATTACK
EXPERIMENTAL
EXPERIMENT_IMPL = 5

FIX_DUNGEON_FLOOR_SAVE
FIX_ATTR_BOOST
FIX_HP_GROW
FIX_ITEM99
;FIX_255X_DAMAGE

;EXTEND_GEOMANCE
BOOST_GEOMANCER
BOOST_CHEER
BOOST_INTIMIDATE
BOOST_CHARGE

CHARGE_BREAK_DAMAGE_LIMIT
CHARGE_COUNT_JUMP = $18	;bonus atk +150%
CHARGE_INCREMENT = $14	;bonus atk +125%
CHARGE_MAX = $28+1		;max +250%

PROVOKE_CRITICAL_RATE = 75
PROVOKE_BASE_SUCCESS_RATE = 100
PROVOKE_SHIELD_PENALTY = 20
COUNTER_CRITICAL_RATE = 50

SCHOLAR_ITEM_EFFECT_DOUBLE
GIVE_FIGHTER_RAID
GIVE_HUNTER_DISORDERED_SHOT
GIVE_VIKING_PROVOKE
GIVE_EVILSWORDMAN_ABYSS

ENABLE_EXTRA_ABILITY
ENABLE_EXTRA_ABILITY_TAG

SHOW_INFO_ON_DISORDERED_SHOT
FAST_DISORDERED_SHOT
DISORDERED_SHOT_BASE_RATE = 70

ENABLE_strToTileArray

REDRAW_ON_EQUIP_CHANGE
CONTINUE_ON_EQUIP_CHANGE
USE_ITOA8

COMMAND_WINDOW_WIDTH		= 6		;original: 5
RANDOM_LCG_A				= 11	;original: 3;should be 8n+3; r[n+1] = a*r[n]+c mod #$400

VARIABLE_SWING_FRAMES
SWING_FRAME_COUNT = 6

;---------------------------------------------------------

TAG_PROVOKE_EFFECT
	.ifndef PROVOKE_EFFECT_REMAIN
PROVOKE_EFFECT_REMAIN = 1
	.endif	;PROVOKE_EFFECT_REMAIN

UPDATE_FLAGS				= 0		;0:noupdate
;======================================================================================================
	.include "ff3_hack_master.asm"